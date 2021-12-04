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

/// A binding to a value stored somewhere else.
///
/// The bound value can be a literal, any variable, a state variable or any expression.
/// If the bound value is an expression and depends on any other binding or state variable,
/// the expression will automatically be re-evaluated when any dependent values change.
///
/// The `observe(closure:)` method can be used to setup an observer that will be triggered
/// anytime the bound value changes.
///
/// Additionnaly, the value itself can be accessed anytime since `Binding` is a property wrapper.
@propertyWrapper
public class Binding<Value>: ObservableValue {
    public typealias Function = () -> Value

    let subject = ObservableSubject()
    var subscriptions: [AnyCancellable] = []
    var pendingRefresh = false
    var cachedValue: Value?

    /// The function to evaluate to get the latest value.
    let function: () -> Value

    /// Creates a new binding to the given value.
    public init(_ function:  @escaping @autoclosure Function) {
        self.function = function
        self.refreshCachedValue()
    }

    /// Creates a new binding to the given value.
    /// Convenience initializer for property wrapper support.
    public convenience init(wrappedValue: @escaping @autoclosure Function) {
        self.init(wrappedValue())
    }

    func evaluate() -> Value {
        return self.function()
    }

    public var wrappedValue: Value {
        return self.value
    }

    /// Returns the underlying binding.
    public var projectedValue: Binding<Value> {
        return self
    }
}
