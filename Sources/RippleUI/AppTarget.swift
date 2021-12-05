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

public extension App {
    typealias Target = AppTarget

    /// Override the default `Never` target to provide our own instead.
    static func makeTarget(of app: Self) -> AppTarget {
        return AppTarget()
    }
}

/// The target of a Ripple app.
public class AppTarget: TargetNode {
    public let type: TargetType = .app

    public var children: [TargetNode] = []

    public func insert(child: TargetNode, at position: UInt?) {
        // Only allow one child container for now
        if !self.children.isEmpty {
            fatalError("App targets can only have one container")
        }

        // Ensure the target node is a container
        if child.type != .container {
            fatalError("App targets can only contain containers, tried to insert a \(child.type): \(child)")
        }

        // Add the child
        self.children = [child]
    }

    public func remove(child: TargetNode) {
        fatalError("Removing containers from an app target is not implemented yet")
    }
}
