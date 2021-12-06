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
import Dispatch

import Backtrace
import RippleCore

extension App where Target == AppTarget {
    /// Main entry point for an app.
    ///
    /// Use the `@main` attribute on the app to mark it as the main
    /// entry point of your executable target. Calling this
    /// method directly is not supported.
    public static func main() {
        // Enable backtraces for Linux and Windows
        Backtrace.install()

        let engine = Engine(running: Self.init())
        engine.target.run()
    }
}

public extension App {
    typealias Target = AppTarget

    /// Overrides the default `Never` target to provide our own instead.
    static func makeTarget(of app: Self) -> AppTarget {
        do {
            return try AppTarget()
        }
        catch {
            Logger.error("Cannot initialize app: \(error.qualifiedName)")
            exit(-1)
        }
    }
}

/// The target of a Ripple app.
public class AppTarget: TargetNode {
    public let type: TargetType = .app

    public var children: [TargetNode] = []

    /// Creates a new app target.
    init() throws {
        // Init platform
        guard let platform = try createPlatform() else {
            throw AppError.noPlatformFound
        }
    }

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

    /// Runs the app until it exits.
    func run() {
        // Temporary main loop: consume every messages in the queue
        dispatchMain()
    }
}

/// Errors that can occur when the app is initialized.
enum AppError: Error {
    case noPlatformFound
}
