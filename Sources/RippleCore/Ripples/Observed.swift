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

/// A value that can be observed for changes. This is a non-property wrapper variant of `State`
/// so that it can be used in protocols.
///
/// Use the `value` property to get the value, and the `set(_:)` method to set it.
/// TODO: State should be using an ObservedValue internally and not the other way around
public class ObservedValue<Value>: Observable {
    @State var state: Value

    /// Creates a new observed value with given initial value.
    public init(value: Value) {
        self._state = State(wrappedValue: value)
    }

    /// Sets the new value.
    public func set(_ value: Value) {
        self.state = value
    }

    public func evaluate() -> Value {
        return self._state.evaluate()
    }

    public var subject: ObservableSubject {
        return self._state.subject
    }

    public var pendingRefresh: Bool {
        get { return self._state.pendingRefresh}
        set { self._state.pendingRefresh = newValue }
    }

    public var cachedValue: Value? {
        get { return self._state.cachedValue }
        set { self._state.cachedValue = newValue }
    }
    
    public var dependencies: [AnyCancellable] {
        get { return self._state.dependencies}
        set { self._state.dependencies = newValue }
    }
}
