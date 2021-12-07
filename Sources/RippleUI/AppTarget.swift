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
import CRippleUI

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
public class AppTarget: TargetNode, Context {
    public let type: TargetType = .app

    public var children: [TargetNode] = []

    /// Has the user requested that the app exits?
    var exitRequested = false

    var canvas: Canvas?
    let platform: Platform

    /// Creates a new app target.
    init() throws {
        // Init platform
        guard let platform = try createPlatform() else {
            throw AppError.noPlatformFound
        }
        self.platform = platform

        // Register ourself as running context
        sharedContext = self
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

    /// Must the app exit on next frame?
    var mustExit: Bool {
        // TODO: handle SIGINT to exit gracefully
        return exitRequested
    }

    /// Runs the app until it exits.
    func run() {
        while !self.mustExit {
            let beginFrameTime = Date()

            // Poll events
            self.platform.poll()

            // Run one frame
            self.frame()

            // Consume all messages in main queue
            drainMainQueue()

            // Sleep for however much time is needed
            let frameTime = 0.016666666 // TODO: make it an env variable
            if frameTime > 0 {
                let endFrameTime = Date()
                let currentFrameTime = beginFrameTime.distance(to: endFrameTime)
                var sleepAmount: TimeInterval = 0

                // Only sleep if the frame took less time to render
                // than desired frame time
                if currentFrameTime < frameTime {
                    sleepAmount = frameTime - currentFrameTime
                }

                if sleepAmount > 0 {
                    Thread.sleep(forTimeInterval: sleepAmount)
                }
            }
        }

        Logger.info("Exiting...")
    }

    /// Runs the app for one frame.
    func frame() {
        for container in self.children {
            (container as? FrameTarget)?.frame()
        }
    }

    func exit() {
        self.exitRequested = true
    }
}

/// Errors that can occur when the app is initialized.
enum AppError: Error {
    case noPlatformFound
}

/// Runs everything in the main queue.
func drainMainQueue() {
    // XXX: Dispatch does not expose a way to drain the main queue
    // without parking the main thread, so we need to use obscure
    // CoreFoundation / Cocoa functions.
    // See https://github.com/apple/swift-corelibs-libdispatch/blob/macosforge/trac/ticket/38.md
    _dispatch_main_queue_callback_4CF(nil)
}

/// Represents the currently running app. Used to get global
/// objects as well as manipulate the app.
protocol Context {
    /// Currently running platform.
    var platform: Platform { get }

    /// The canvas used by views to draw themselves.
    /// Set by the `Container` implementation when it gets created.
    var canvas: Canvas? { get set }

    /// Exits the app on next frame.
    func exit()
}

/// Returns the `Context` instance of the currently running app.
func getContext() -> Context {
    return sharedContext
}

/// Currently running app as `Context`.
var sharedContext: Context!
