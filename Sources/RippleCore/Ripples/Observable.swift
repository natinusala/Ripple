/*
    Copyright 2021 natinusala

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

import Dispatch

import Async
import OpenCombine
import OpenCombineDispatch

public typealias ObservableSubject = PassthroughSubject<Void, Never>
extension ObservableSubject: Hashable, Equatable {} // Uses default implementations defined in Extensions.swift

/// Subscription created when starting an observation on an `Observable`.
///
/// Observing an observable value gives you a `Subscription` handle, which can be used
/// to later cancel the subscription and stop running the closure when the value changes
/// again.
///
/// The subscription is automatically cancelled when it goes out of scope. This is useful to prevent
/// leaking, but it also means that you must store it somewhere during the whole time the observation
/// needs to run to prevent the subscription from being cancelled too early.
public typealias Subscription = AnyCancellable

/// A value that can be observed for changes.
///
/// If used directly, always use the `value` property to make sure
/// to trigger the caching and rippling mechanisms.
public protocol Observable: AnyObject {
    /// Type of the observed value.
    associatedtype Value

    /// The cached value, aka the last known value returned by `evaluate()`.
    /// `nil` means "unknown".
    var cachedValue: Value? { get set }

    /// Combine subject fired when the cached value has changed.
    /// Listeners can assume that `cachedValue` is set and up-to-date when
    /// this event is fired.
    var subject: ObservableSubject { get }

    /// List of other observables this observable depends on, in the form of Combine subscriptions.
    /// This observable will be refreshed if any of those dependent values change.
    var dependencies: [AnyCancellable] { get set }

    /// Is there already a refresh call pending in a dispatch queue?
    var pendingRefresh: Bool { get set }

    /// Returns the current value of this observable.
    /// This function acts as the source of truth, and not
    /// the cached value (which is the last known value returned by this
    /// function).
    func evaluate() -> Value
}

/// An entry of the observable recording stack.
class ObservableRecordingEntry {
    /// All subjects this observable depends on.
    var subjects: Set<ObservableSubject> = []
}

/// Stack of observable access recording. The last entry is the observable that is currently
/// being evaluated.
var observableRecordingStack = [ObservableRecordingEntry]()

extension Observable {
    /// Runs the given closure when the observed value changes. The closure will be executed
    /// on the main event queue, so at least one frame after the value actually changes.
    ///
    /// Returns a `Subscription` that can be cancelled anytime using `cancel()`.
    ///
    /// The subscription must be stored for the lifetime of the observation, otherwise it will
    /// be cancelled, even if a closure has already been put into the queue before cancellation.
    public func observe(closure: @escaping (Value) -> ()) -> Subscription {
        // This method is for "final" observations, and users should be fine with waiting 16.66ms
        // before triggering the closure. This is why we can keep `.receive(on: DispatchQueue.main)`.
        self.subject
            .receive(on: DispatchQueue.main)
            .sink {
                guard let value = self.cachedValue else {
                    fatalError("Subject fired with no cached value")
                }

                closure(value)
            }
    }

    /// Evaluates the observed value again, updating the cached value.
    /// Every other observable access is recorded to create a tree of dependencies
    /// between observable values.
    @discardableResult
    func refreshCachedValue() -> Value {
        self.pendingRefresh = false

        // Setup observable access recording
        observableRecordingStack.append(ObservableRecordingEntry())

        // Evaluate the observable
        let value = self.evaluate()

        // Cancel previous subscriptions
        for subscription in self.dependencies {
            subscription.cancel()
        }
        self.dependencies = []

        // Setup new subscriptions: call this method every time any of the depending
        // observables change
        guard let entry = observableRecordingStack.popLast() else {
            fatalError("Bad observable recording stack state")
        }

        for subject in entry.subjects {
            self.dependencies.append(
                // Do not receive on main queue for performance reasons: `drainMainQueue()` does not run closures
                // that have been added to the queue from inside another closure. Instead, it waits for the next `drainMainQueue()` call.
                // This is possibly to prevent hogging the main thread for too long, which is what we want.
                // As a result, if we have an observable value that ripples down 10 levels, it will take 166.66ms
                // for it to reach the last level which is above the 100ms latency limit for UI responsiveness.
                // TODO: do we need our own scheduler that dispatches the work load across multiple frames (possibly under 100ms)?
                subject
                    .sink { _ in
                        // Only trigger one refresh at a time, this is in case an observable
                        // depends on the same observable as another of its dependency
                        if !self.pendingRefresh {
                            self.pendingRefresh = true

                            Async.main {
                                self.refreshCachedValue()
                            }
                        }
                    }
            )
        }

        // Update our cached value and fire our own subject to notify that
        // our value changed
        self.cachedValue = value
        self.subject.send()

        return value
    }

    /// Primary access point for the observed value. Will return the cached value
    /// if known or re-evaluate the observed value otherwise.
    public var value: Value {
        // Register this access
        if let entry = observableRecordingStack.last {
            entry.subjects.insert(self.subject)
        }

        // If cached value is available, return it directly
        if let cachedValue = self.cachedValue {
            return cachedValue
        }

        // Otherwise evaluate the observable again
        return self.refreshCachedValue()
    }
}
