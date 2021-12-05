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

import OpenCombine

/// A value representing the state of your view.
///
/// Any change to a state variable will trigger a re-evaluation of every
/// binding that depends on this variable (and any binding that depends on those bindings...).
@propertyWrapper
public class State<Value>: ObservableValue {
    public let subject = ObservableSubject()
    public var subscriptions: [AnyCancellable] = []
    public var pendingRefresh = false

    public var cachedValue: Value? {
        didSet {
            self.subject.send()
        }
    }

    public var wrappedValue: Value {
        get {
            return self.value
        }
        set {
            self.cachedValue = newValue
        }
    }

    /// Creates a new state variable with the given initial value.
    public init(wrappedValue: Value) {
        self.cachedValue = wrappedValue
    }

    public func evaluate() -> Value {
        fatalError("`evaluate()` should never be called on `State`, why is `cachedValue` unknown?")
    }
}
