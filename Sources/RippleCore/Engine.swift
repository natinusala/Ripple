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

/// The engine is responsible for parsing the app tree, creating targets and managing
/// target nodes insertions / removals.
///
/// The target library should provide a main function to initialize the engine and run the
/// created target app.
public class Engine<A: App> {
    let root: MountedNode
    public let target: A.Target

    /// Creates a new engine running the given app.
    public init(running app: A) {
        // Mount the root node of the tree: the app
        let output = A.makeOutput(of: app)[0]

        guard let target = output.makeTarget() else {
            Logger.error("Programming error: app does not have a target, cannot continue")
            exit(-1)
        }

        self.target = target as! A.Target
        self.root = MountedNode(output: output, target: target)

        if debugCore {
            self.debugMountedTree(node: self.root)
        }

        if debugTarget {
            self.debugTargetTree(node: self.target)
        }
    }

    func debugMountedTree(node: MountedNode, indent: Int = 0) {
        Logger.debug(debugCore, "\(String(repeating: " ", count: indent))- \(node)")

        for child in node.children {
            self.debugMountedTree(node: child, indent: indent + 4)
        }
    }

    func debugTargetTree(node: TargetNode, indent: Int = 0) {
        Logger.debug(debugTarget, "\(String(repeating: " ", count: indent))- \(node)")

        for child in node.children {
            self.debugTargetTree(node: child, indent: indent + 4)
        }
    }
}

/// Represents an element mounted in the app tree. An element can be an app,
/// a container or a view.
class MountedNode: CustomStringConvertible {
    let output: Output
    let target: TargetNode?

    var parent: MountedNode?
    var children: [MountedNode] = []

    /// Creates a new node.
    init(output: Output, parent: MountedNode? = nil, target: TargetNode? = nil) {
        self.output = output
        self.target = target
        self.parent = parent

        // Evaluate and mount the whole body
        for child in self.output.makeBody() {
            // Create and insert target if any
            let target = child.makeTarget()
            if let childTarget = target {
                // Connect the target to the last view with a target
                self.insertChildTarget(childTarget, in: self)

                // If the child is non-shallow, apply it its own modifiers
                if !child.isShallow {
                    for modifier in child.modifiers {
                        modifier.boundTarget = childTarget
                        modifier.apply()
                    }
                }

                // Apply modifiers of all parent shallow views (stops at the
                // first non shallow parent)
                for modifier in self.gatherModifiers() {
                    modifier.boundTarget = childTarget
                    modifier.apply()
                }
            }

            // Mount node
            let node = MountedNode(output: child, parent: self, target: target)
            self.children.append(node)
        }
    }

    /// Inserts the target to the upper-most parent that also has a target.
    /// Will fatal error if no parent was found with a target after traversing the whole tree.
    func insertChildTarget(_ target: TargetNode, in parent: MountedNode, at position: UInt? = nil) {
        if let parentTarget = parent.target {
            parentTarget.insert(child: target, at: position)
        } else {
            if let grandParent = parent.parent {
                self.insertChildTarget(target, in: grandParent, at: position)
            } else {
                fatalError("Cannot attach target \(target) to any parent (tried \(parent) last)")
            }
        }
    }

    /// Returns all modifiers if the node is shallow, as well
    /// all modifiers of its shallow parents (stops at first non shallow parent).
    func gatherModifiers() -> [ViewModifierTarget] {
        // If we are a shallow view, return all of our modifiers then add modifiers
        // of our (possibly shallow too) parent.
        // Otherwise, return an empty list.

        if self.output.isShallow {
            return self.output.modifiers + (self.parent?.gatherModifiers() ?? [])
        }

        return []
    }

    public var description: String {
        return self.output.description
    }
}
