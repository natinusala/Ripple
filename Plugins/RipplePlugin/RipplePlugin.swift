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

/// SwiftPM plugin that creates commands for various codegen executables:
///     - `ResourcesCodegen` for every resource file in the target
///     - `RipplingCodegen` for every Swift file in the target
@main
struct RipplePlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        var commands: [Command] = []

        guard let target = target as? SwiftSourceModuleTarget else {
            return []
        }

        let resCodegen = try context.tool(named: "ResourcesCodegen")
        let ripplingCodegen = try context.tool(named: "RipplingCodegen")

        for input in target.sourceFiles {
            if input.type == .resource {
                commands.append(createResourcesCommand(tool: resCodegen, input: input, context: context, target: target))
            } else if input.type == .source {
                commands.append(createRipplingCommand(tool: ripplingCodegen, input: input, context: context, target: target))
            }
        }

        return commands
    }
}

/// Creates a resource generation command.
func createResourcesCommand(tool codegen: PluginContext.Tool, input: File, context: PluginContext, target: Target) -> Command {
    // Plugin work directory is already scoped by module, and two resources with the same file name
    // will already have the same Swift variable and clash so it doesn't matter if we overwrite generated files
    let outputName = "\(input.path.lastComponent).swift"
    let output = context.pluginWorkDirectory.appending(outputName)

    return .buildCommand(
        displayName: "Processing \(target.name) \(input.path.lastComponent)",
        executable: codegen.path,
        arguments: [input.path.string, output.string],
        inputFiles: [input.path],
        outputFiles: [output]
    )
}

/// Creates a rippling extension generation command.
func createRipplingCommand(tool codegen: PluginContext.Tool, input: File, context: PluginContext, target: Target) -> Command {
    // Plugin work directory is already scoped by module and a module cannot have multiple
    // Swift files with the same name so this is safe
    let outputName = "\(input.path.stem)_RipplingExtensions.swift"
    let output = context.pluginWorkDirectory.appending(outputName)

    return .buildCommand(
        displayName: "Generating rippling extensions of \(target.name) \(input.path.lastComponent)",
        executable: codegen.path,
        arguments: [input.path.string, output.string],
        inputFiles: [input.path],
        outputFiles: [output]
    )
}
