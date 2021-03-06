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

/// A view with no body.
public struct EmptyView: View {
    public typealias Body = Never

    public init() {}

    public static func makeTarget(of view: EmptyView) -> EmptyViewTarget {
        return EmptyViewTarget()
    }
}

/// Target for empty views.
public class EmptyViewTarget: ViewTarget, CustomStringConvertible {
    public var description: String {
        return "EmptyViewTarget"
    }
}
