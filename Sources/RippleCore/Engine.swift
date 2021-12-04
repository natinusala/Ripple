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

/// The engine is responsible for parsing the app tree, creating targets and managing
/// target nodes insertions / removals.
///
/// The target library should provide a main function to initialize the engine and run the
/// created target app.
class Engine {
    let root: MountedNode
    let target: TargetNode

    /// Creates a new engine running the given app.
    public init<A: App>(running app: A) {
        // Mount the root node of the tree: the app
        let output = A.makeOutput(of: app)[0]

        guard let target = output.makeTarget() else {
            fatalError("App does not have a target, cannot continue")
        }

        self.target = target
        self.root = MountedNode(output: output, target: target)

        // Mount the whole tree
        self.root.mountBody()
    }
}
