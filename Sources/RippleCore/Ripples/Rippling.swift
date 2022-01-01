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

/// A value made from an expression of multiple other rippling values or state variables.
///
/// The value can be made from a literal, any variable, a state variable or any expression.
/// If the bound value is an expression and depends on any other rippling or state variable,
/// the expression will automatically be re-evaluated when any dependent values change.
///
/// Most of the time, the default compiler synthetized initializer for your views will be enough.
/// However, if you need a custom initializer use `Rippling<Value>` as the parameter type
/// and set the rippling property with an underscore prefix to access the underlying `Rippling` and not the
/// wrapped value. The Ripple SwiftPM plugin will then take care of generating an extension for the struct
/// containing a new `init` implementation with the correct type. The generated `init` will call your
/// own `init`.
///
/// If you need default values for a rippling parameter in `init`, you have to give Swift a `Rippling<Value>`
/// and not a `Value`. The shortest way is to do `parameter: Rippling<Value> = .init(value)`.
///
/// The `observe(closure:)` method can be used to setup an observer that will be triggered
/// anytime the bound value changes.
///
/// Additionnaly, the value itself can be accessed anytime since `Rippling` is a property wrapper.
@propertyWrapper
public class Rippling<Value>: Observable {
    public let subject = ObservableSubject()
    public var dependencies: [AnyCancellable] = []
    public var pendingRefresh = false
    public var cachedValue: Value?

    /// The function to evaluate to get the latest value.
    let function: () -> Value

    /// Creates a new rippling to the given value.
    public init(_ function: @escaping @autoclosure () -> Value) {
        self.function = function
        self.refreshCachedValue()
    }

    /// Creates a new binding to the given value.
    /// This convenience init is used by compiler synthetized structs initializers.
    public convenience init(wrappedValue: @escaping @autoclosure () -> Value) {
        self.init(wrappedValue())
    }

    public func evaluate() -> Value {
        return self.function()
    }

    public var wrappedValue: Value {
        return self.value
    }
}
