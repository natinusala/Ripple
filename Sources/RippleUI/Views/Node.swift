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

import RippleCore

import Yoga

/// A view containing a layout node, with a position and dimensions.
public struct Node<Content>: View where Content: View {
    public typealias ContentBuilder = () -> Content

    @ViewBuilder let content: ContentBuilder

    /// Creates a new node.
    public init(@ViewBuilder content: @escaping ContentBuilder) {
        self.content = content
    }

    public var body: some View {
        self.content()
    }

    public static func makeOutput(of view: Node<Content>) -> [Output] {
        // `Node` is a special case that has a body but also has `makeOutput(of:)` return itself
        // because the node must exist in the tree as well as its children
        return [ViewOutput(of: view)]
    }

    public static func makeTarget(of view: Self) -> NodeTarget {
        return NodeTarget()
    }

    public static func updateTarget(_ target: NodeTarget, with view: Self) {
        fatalError("Node updateTarget unimplemented")
    }
}

/// Target for a node.
public class NodeTarget: ViewTarget, CustomStringConvertible {
    public var description: String {
        return "NodeTarget (axis: \(YGNodeStyleGetFlexDirection(self.ygNode).axis))"
    }
}
