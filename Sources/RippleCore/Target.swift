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

/// Type of a target.
public enum TargetType {
    case app
    case container
    case view
}

/// The "target" is the actual, concrete, view that's drawn on screen.
/// Changes on the mounted view tree will be reflected on the target tree.
/// Target views have a Yoga node and coordinates.
public protocol TargetNode {
    /// The type of this node.
    var type: TargetType { get }

    /// Called when a child node needs to be inserted in this node
    /// at the given position. If position is `nil`, the child must
    /// be inserted at the end of the list.
    /// `parent` property of the child must be set to `self`.
    func insert(child: inout TargetNode, at position: UInt?)

    /// Called when a child node needs to be removed from this node.
    func remove(child: TargetNode)

    /// Parent of this node.
    var parent: TargetNode? { get set }

    /// Children of this node.
    var children: [TargetNode] { get }
}

extension Never: TargetNode {}

extension Never {
    public var type: TargetType {
        fatalError("`type` called on `Never`")
    }

    public var children: [TargetNode] {
        fatalError("`children` called on `Never`")
    }

    public func insert(child: inout TargetNode, at position: UInt?) {
        fatalError("`insert(child:at:)` called on `Never`")
    }

    public func remove(child: TargetNode) {
        fatalError("`remove(child:)` called on `Never`")
    }

    public var parent: TargetNode? {
        get {
            fatalError("`parent` called on `Never`")
        }
        set {
            fatalError("`parent` called on `Never`")
        }
    }
}
