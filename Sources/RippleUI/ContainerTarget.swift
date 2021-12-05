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

/// Target of a container.
public class ContainerTarget: TargetNode {
    public let type: TargetType = .container

    public var children: [TargetNode] = []

    public func insert(child: TargetNode, at position: UInt?) {
        // Only allow one child view for now
        if !self.children.isEmpty {
            fatalError("Container targets can only have one view")
        }

        // Ensure the target node is a view
        if child.type != .view {
            fatalError("Container targets can only contain views")
        }

        // Add the child
        self.children = [child]
    }

    public func remove(child: TargetNode) {

    }
}
