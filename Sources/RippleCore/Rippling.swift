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

/// A ripplet is the input function for a rippling value.
///
/// To be used in views initializers when a rippling is needed, with both
/// `@autoclosure` and `@escaping` attributes.
///
/// The compiler will synthetize an internal initializer for user views
/// so that you don't need to explicitely use a ripplet, however
/// library-provided views need an explicit public initializer
/// where ripplets need to be used.
public typealias Ripplet<Value> = () -> Value

/// A value made from an expression of multiple other rippling values or state variables.
///
/// The value can be made from a literal, any variable, a state variable or any expression.
/// If the bound value is an expression and depends on any other rippling or state variable,
/// the expression will automatically be re-evaluated when any dependent values change.
///
/// The `observe(closure:)` method can be used to setup an observer that will be triggered
/// anytime the bound value changes.
///
/// Additionnaly, the value itself can be accessed anytime since `Rippling` is a property wrapper.
@propertyWrapper
public class Rippling<Value>: Observable {
    public let subject = ObservableSubject()
    public var subscriptions: [AnyCancellable] = []
    public var pendingRefresh = false
    public var cachedValue: Value?

    /// The function to evaluate to get the latest value.
    let function: () -> Value

    /// Creates a new rippling to the given value.
    public init(_ function:  @escaping @autoclosure Ripplet<Value>) {
        self.function = function
        self.refreshCachedValue()
    }

    /// Creates a new binding to the given value.
    /// Convenience initializer for property wrapper support.
    public convenience init(wrappedValue: @escaping @autoclosure Ripplet<Value>) {
        self.init(wrappedValue())
    }

    public func evaluate() -> Value {
        return self.function()
    }

    public var wrappedValue: Value {
        return self.value
    }
}
