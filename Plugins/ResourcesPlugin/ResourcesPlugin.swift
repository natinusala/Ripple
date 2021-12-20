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

import PackagePlugin

#if os(Linux)
let separator = "/"
#else
#error("Please set `separator` for your platform")
#endif

/// SwiftPM plugin that calls `ResourcesCodegen` for every declared resource file in the target.
@main
struct ResourcesPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        var commands: [Command] = []

        guard let target = target as? SourceModuleTarget else {
            return []
        }

        let codegen = try context.tool(named: "ResourcesCodegen")

        // Make a command for every resource file
        for input in target.sourceFiles.filter({ $0.type == .resource }) {
            let outputName = "\(input.path.string.split(separator: "/").joined(separator: "_")).swift"
            let output = context.pluginWorkDirectory.appending(outputName)

            commands.append(
                .buildCommand(
                    displayName: "Processing \(input.path.lastComponent)",
                    executable: codegen.path,
                    arguments: [input.path.string, output.string],
                    inputFiles: [input.path],
                    outputFiles: [output]
                )
            )
        }

        return commands
    }
}
