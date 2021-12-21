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

/// A modifier that you apply to a view or another view modifier, producing a different version of the original value.
public protocol ViewModifier {
    /// The type of view representing the body of this modifier.
    associatedtype Body: View

    /// The type of implementation for this view modifier.
    associatedtype Target: ViewModifierTarget

    /// Type of content views passed to `body(content:)`.
    typealias Content = ViewModifierContent<Self>

    /// Content and behavior of this modifier.
    func body(content: Content) -> Body

    /// Creates the target of this view modifier.
    static func makeTarget(of modifier: Self) -> Target
}

extension ViewModifier {
    /// Default implementation of `body(content:)`.
    public func body(content: Content) -> some View {
        return content
    }

    /// Default implementation of `makeTarget(of:)`.
    public static func makeTarget(of modifier: Self) -> Never {
        fatalError("`makeTarget(of:)` called on a view modifier without a target")
    }
}

/// Type of content views passed to the `body(content:)` function of a modifier.
public struct ViewModifierContent<Modifier> where Modifier: ViewModifier {

}

extension ViewModifierContent: View {
    public typealias Body = Never
}

public extension View {
    /// Applies a modifier to a view and returns a new view.
    func modifier<T: ViewModifier>(_ modifier: T) -> ModifiedContent<Self, T> {
        return .init(content: self, modifier: modifier)
    }
}

/// A view with a modifier applied to it.
public struct ModifiedContent<Content, Modifier> {
    let content: Content
    let modifier: Modifier
}

extension ModifiedContent: View where Content: View, Modifier: ViewModifier {
    public typealias Body = Never
    public typealias Target = Never

    public static func makeOutput(of view: ModifiedContent<Content, Modifier>) -> [Output] {
        // Make output of wrapped view
        let output = Content.makeOutput(of: view.content)

        if output.count != 1 {
            fatalError("Cannot make output of view modifier on a view that outputs multiple views")
        }

        guard let output = output[0] as? ViewOutput else {
            fatalError("View modifier applied on something else than a view")
        }

        // Attach the modifier target, if any
        if Modifier.Target.self != Never.self {
            let impl = Modifier.makeTarget(of: view.modifier)
            output.modifiers.append(impl)
        }

        return [output]
    }
}

/// A view modifier target, aka the actual modifier implementation.
public protocol ViewModifierTarget: AnyObject {
    var boundTarget: TargetNode? { get set }

    /// Applies the modifier to its bound target view.
    func apply()

    /// Resets the modifier on the bound target view. The end result
    /// should be as if the modifier was never applied to the target.
    func reset()
}

public extension ViewModifierTarget {
    /// Default implementation of `apply()`.
    func apply() {}

    /// Default implementation of `reset()`.
    func reset() {}
}

/// Convenience class for modifier targets that takes care of
/// observing its value for changes and re-applying the modifier when
/// that happens.
///
/// Override the `onValueChange(newValue:)` method to implement your changes.
/// `apply()` does not need to be overridden as it already calls `onValueChange(newValue:)`.
/// `reset()` can be overridden if needed.
open class ObservingViewModifierTarget<Value>: ViewModifierTarget {
    public internal(set) var observedValue: Value

    public var boundTarget: TargetNode?

    var subscription: Subscription?

    /// Creates a new target observing the given value.
    public init<V: Observable>(observing value: V) where V.Value == Value {
        self.observedValue = value.value

        self.subscription = value.observe { newValue in
            self.observedValue = newValue
            self.onValueChange(newValue: newValue)
        }
    }

    /// Called whenever the observer value changes to reflect the change
    /// on the bound target view.
    open func onValueChange(newValue: Value) {
        // Nothing by default
    }

    public func apply() {
        self.onValueChange(newValue: self.observedValue)
    }

    open func reset() {
        // Nothing to do by default
    }
}
