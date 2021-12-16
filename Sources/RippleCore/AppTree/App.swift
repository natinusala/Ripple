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

/// A Ripple application.
///
/// An app contains one single `Container`, which is the top-level
/// container for the views.
///
/// See your target documentation to know how to run a Ripple app with
/// that one particular target.
public protocol App {
    /// The type of container representing the body of this app.
    associatedtype Body: Container

    /// The type of target for this app.
    /// Defaults to `Never` - the target library is
    /// responsible for extending `App` and change that `Never`
    /// to an actual implementation.
    associatedtype Target: TargetNode

    /// The content and behavior of this app.
    var body: Body { get }

    /// Empty initializer for `@main` entry point.
    init()

    /// Makes the output of that app.
    static func makeOutput(of app: Self) -> [Output]

    /// Makes the target of that app.
    static func makeTarget(of app: Self) -> Target
}

extension App {
    /// Default implementation of `makeOutput(of:)` for apps: return itself.
    public static func makeOutput(of app: Self) -> [Output] {
        return [AppOutput(of: app)]
    }
}

public extension App {
    /// Default implementation of `makeTarget(of:)`.
    static func makeTarget(of app: Self) -> Never {
        Logger.error("Programming error: apps do not have a target by default, please import a target library")
        exit(-1)
    }
}

/// The output of an app, aka the actual app represented by
/// an app in the tree.
public class AppOutput: Output {
    public let value: Any

    public let type: Any.Type

    /// Creates and returns app container.
    public let makeBody: () -> [Output]

    public let makeTarget: () -> TargetNode?

    public let isShallow: Bool
    public let modifiers: [ViewModifierTarget] = []

    init<A: App>(of app: A) {
        self.value = app
        self.type = A.self

        self.makeBody = {
            return A.Body.makeOutput(of: app.body)
        }

        self.makeTarget = {
            if A.Target.self == Never.self {
                return nil
            }

            return A.makeTarget(of: app)
        }

        self.isShallow = A.Body.self != Never.self && A.Target.self == Never.self
    }
}
