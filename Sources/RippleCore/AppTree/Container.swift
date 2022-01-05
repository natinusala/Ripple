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

/// Top-level container for views of an app. An app is made
/// of exactly one container, and a container is made of a tree
/// of views.
public protocol Container {
    /// The type of view representing the body of this container.
    associatedtype Body: View

    /// The type of target for this container.
    /// Defaults to `Never`.
    associatedtype Target: TargetNode

    /// The content and behavior of this container.
    var body: Body { get }

    /// Makes the output of that container.
    static func makeOutput(of container: Self) -> [Output]

    /// Makes the target of that container.
    static func makeTarget(of container: Self) -> Target
}

extension Container where Body == Never {
    public var body: Never {
        fatalError("`body` called on `Container` with `Never` as `Body`")
    }
}

public extension Container {
    /// Default implementation of `makeOutput(of:)` for containers: return itself.
    static func makeOutput(of container: Self) -> [Output] {
        return [ContainerOutput(of: container)]
    }

    static func makeTarget(of container: Self) -> Never {
        fatalError("`makeTarget(of:)` called on a container without a target")
    }
}

/// The output of a container, aka the actual container represented by
/// a container in the tree.
public class ContainerOutput: Output {
    /// Underlying container.
    public let value: Any

    /// Type of underlying container.
    public let type: Any.Type

    /// Creates and returns children of that container.
    public let makeBody: () -> [Output]

    public let makeTarget: () -> TargetNode?

    public var isShallow: Bool
    public let modifiers = [ViewModifierTarget]()

    init<C>(of container: C) where C: Container {
        self.value = container
        self.type = C.self

        self.makeBody = {
            // Body == Never means leaf node
            if C.Body.self == Never.self {
                return []
            }

            return C.Body.makeOutput(of: container.body)
        }

        self.makeTarget = {
            if C.Target.self == Never.self {
                return nil
            }

            return C.makeTarget(of: container)
        }

        self.isShallow = C.Body.self != Never.self && C.Target.self == Never.self
    }
}
