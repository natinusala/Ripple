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

/// Storage for one environment value.
class EnvironmentValueStorage {
    /// The value.
    var value: Any {
        didSet {
            self.subject.send()
        }
    }

    /// Combine subject fired when the value changes.
    let subject = ObservableSubject()

    /// Creates a new environment value storage with an initial value.
    init(value: Any) {
        self.value = value
    }
}

/// Storage for environment values.
public class EnvironmentValues {
    /// All environment values.
    var values: [ObjectIdentifier: EnvironmentValueStorage] = [:]

    /// The last accessed key, used to get the subject from a key path.
    var lastAccessedKey: ObjectIdentifier?

    /// Gets or create an environment value storage of the given
    /// identifier.
    func getOrCreateStorage<K>(of key: K.Type) -> EnvironmentValueStorage where K: EnvironmentKey {
        self.lastAccessedKey = ObjectIdentifier(key)

        // If the storage already exists, just return it
        if let storage = self.values[ObjectIdentifier(key)] {
            return storage
        }

        // Otherwise create it with default value
        let storage = EnvironmentValueStorage(value: key.defaultValue)
        self.values[ObjectIdentifier(key)] = storage
        return storage
    }

    /// Returns an environment value by key.
    public subscript<K>(key: K.Type) -> K.Value where K: EnvironmentKey {
        get { return self.getOrCreateStorage(of: key).value as! K.Value }
        set { self.getOrCreateStorage(of: key).value = newValue }
    }

    /// Returns the Combine subject of an environment value by key path.
    func subjectOf<Value>(keyPath: KeyPath<EnvironmentValues, Value>) -> ObservableSubject {
        /// XXX: This whole method is a bit of a hack

        self.lastAccessedKey = nil

        // Trigger subscript by getting the key path
        let _ = self[keyPath: keyPath]

        // lastAccessedKey should contain the identifier of our storage
        // if not, something went wrong and we should crash
        return self.values[self.lastAccessedKey!]!.subject
    }
}

/// Shared environment values for the whole app.
fileprivate var environmentValues = EnvironmentValues()

/// Returns shared environment values.
public func getEnvironment() -> EnvironmentValues {
    return environmentValues
}

/// An environment value key.
public protocol EnvironmentKey {
    /// The type of the value for this key.
    associatedtype Value

    /// Default value of this key.
    static var defaultValue: Value { get }
}

/// Read-only binding to an environment value, identified by its key path in `EnvironmentValues`.
///
/// To write to an environment value, get the environment store using `getEnvironment()` then
/// explicitely set the property directly in there.
@propertyWrapper
public class Environment<Value>: ObservableValue {
    /// Type of key path associated to this environment value.
    public typealias ValueKeyPath = KeyPath<EnvironmentValues, Value>

    /// The key path to be used to find the environment value.
    let keyPath: ValueKeyPath

    /// The Combine subject for the underlying environment value.
    /// The subject for any given environment value is immutable throughout the whole app lifetime,
    /// so it can be lazyly set and stored to reduce the amount of costly `subjectOf(keyPath:)` calls.
    public lazy var subject: ObservableSubject = getEnvironment().subjectOf(keyPath: self.keyPath)

    public var subscriptions: [AnyCancellable] = []
    public var pendingRefresh = false

    /// Read-only proxy to the stored value.
    public var cachedValue: Value? {
        get { return getEnvironment()[keyPath: self.keyPath] }
        set { /* Do nothing, environment values are immutable when used from this wrapper */ }
    }

    /// Creates a new environment value binding from a key path.
    public init(_ keyPath: ValueKeyPath) {
        self.keyPath = keyPath
    }

    public var wrappedValue: Value {
        get { self.value } // Use self.value for observable value access recording
    }

    public func evaluate() -> Value {
        fatalError("`evaluate()` should never be called on `Environment`, why is `cachedValue` unknown?")
    }
}
