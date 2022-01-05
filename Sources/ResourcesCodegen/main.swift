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

import TSCBasic

// Simple code generator that takes a resource file and makes a `Resource` extension
// to get that file content from the target program.

let input = AbsolutePath(CommandLine.arguments[1])
let output = AbsolutePath(CommandLine.arguments[2])

// Build generated code
let ext = input.extension ?? ""
var varName = input.basenameWithoutExt

let toReplace = [
    " ",
    ".",
    "-",
]

for token in toReplace {
    varName = varName.replacingOccurrences(of: token, with: "_")
}

var lines: [String] = [
    "import Foundation",
    "import Ripple",
    "extension URL {",
    "    static var \(varName): Self {",
    "        guard let url = Bundle.module.url(forResource: \"\(input.basenameWithoutExt)\", withExtension: \"\(ext)\") else {",
    "            Logger.error(\"Could not find resource `\(input.basenameWithoutExt)` (with extension `\(ext)`)\")",
    "            exit(-1)",
    "        }",
    "        return url",
    "    }",
    "}",
]

// Write output to file
var generated = lines.joined(separator: "\n")
try! generated.write(toFile: output.pathString, atomically: false, encoding: .utf8)
