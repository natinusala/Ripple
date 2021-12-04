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

import Foundation

/// Represents a part of your user interface.
public protocol View {
    /// The type of view representing the body of this view.
    associatedtype Body: View

    /// The type of target for this view.
    /// Defaults to `Never`.
    associatedtype Target: TargetNode

    /// The content and behavior of this view.
    var body: Body { get }

    /// Makes the output of that view. May return multiple views
    /// if the view corresponds to multiple views.
    static func makeOutput(of view: Self) -> [Output]

    /// Makes the target of that view.
    static func makeTarget(of view: Self) -> Target

    /// Updates the target of that view.
    static func updateTarget(_ target: Target, with view: Self)
}

public extension View {
    static func makeTarget(of view: Self) -> Never {
        fatalError("`makeTarget(of:)` called on a view without a target")
    }

    static func updateTarget(_ target: Never, with view: Self) {}
}

extension Never: View {}

extension Never {
    public var body: Never {
        fatalError("`body` called on `Never`")
    }
}

public extension View where Body == Never {
    var body: Never {
        fatalError("`body` called on `View` with `Never` as `Body`")
    }
}

extension View {
    /// Default implementation of `makeOutput(of:)`: return itself.
    public static func makeOutput(of view: Self) -> [Output] {
        return [ViewOutput(of: view)]
    }
}

/// A view composed of a series of other views.
public struct TupleView<T>: View {
    public typealias Body = Never

    let content: T
    let output: () -> [Output]

    public static func makeOutput(of view: Self) -> [Output] {
        return view.output()
    }
}

/// Result builder to create one or multiple views.
@resultBuilder
public class ViewBuilder {
    public static func buildBlock() -> VoidView {
        return VoidView()
    }

    public static func buildBlock<V0>(_ v0: V0) -> V0 where V0: View {
        return v0
    }
}

/// A view with no output or target.
public struct VoidView: View {
    public typealias Body = Never

    public static func makeOutput(of view: VoidView) -> [Output] {
        return []
    }

    public static func makeTarget(of view: VoidView) -> Never {
        fatalError("`makeTarget(of:)` called on VoidView")
    }

    public static func updateTarget(_ target: Never, with view: VoidView) {}
}

/// The output of a view, aka the actual view(s) represented by
/// a view in the tree.
public class ViewOutput: CustomStringConvertible, Output {
    /// Underlying view.
    public let value: Any

    /// Type of underlying view.
    public let type: Any.Type

    /// Creates and returns children of that view.
    public let makeBody: () -> [Output]

    /// Modifiers for this view.
    public var modifiers: [ViewModifierTarget] = []

    public let makeTarget: () -> TargetNode?
    public let updateTarget: (TargetNode) -> ()

    public let isShallow: Bool

    public init<V>(of view: V) where V: View {
        self.value = view
        self.type = V.self

        self.makeBody = {
            // Body == Never means leaf node
            if V.Body.self == Never.self {
                return []
            }

            return V.Body.makeOutput(of: view.body)
        }

        self.makeTarget = {
            if V.Target.self == Never.self {
                return nil
            }

            return V.makeTarget(of: view)
        }

        self.updateTarget = { target in
            guard let target = target as? V.Target else {
                fatalError("`updateTarget()` called with a target of the wrong type")
            }

            V.updateTarget(target, with: view)
        }

        self.isShallow = V.Body.self != Never.self && V.Target.self == Never.self
    }

    public var description: String {
        let name = String(describing: self.type).components(separatedBy: "<")[0]
        var modifiers = ""

        if !self.modifiers.isEmpty {
            modifiers = String(describing: self.modifiers)
        }

        return "\(name) \(modifiers)"
    }
}
