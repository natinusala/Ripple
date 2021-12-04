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

/// Target of a view.
public class ViewTarget: TargetNode {
    public let type: TargetType = .view

    public var children: [TargetNode] = []

    let ygNode: YGNodeRef

    init() {
        self.ygNode = YGNodeNew()
    }

    public func insert(child: TargetNode, at position: UInt?) {
        // Ensure the target node is a view
        guard let view = child as? ViewTarget else {
            fatalError("View targets can only contain views")
        }

        let position = position ?? UInt(self.children.count)

        self.children.insert(child, at: Int(position))
        YGNodeInsertChild(self.ygNode, view.ygNode, UInt32(position))
    }

    public func remove(child: TargetNode) {

    }

    deinit {
        YGNodeFree(self.ygNode)
    }
}
