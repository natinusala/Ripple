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

/// Changes the background color of a view.
public struct BackgroundColorModifier: ViewModifier {
    let color: Color

    public init(color: Color) {
        self.color = color
    }

    public static func makeTarget(of modifier: BackgroundColorModifier) -> BackgroundColorTarget {
        return BackgroundColorTarget(color: modifier.color)
    }
}

extension View {
    /// Changes the background color of the view.
    func backgroundColor(_ color: Color) -> some View {
        return modifier(BackgroundColorModifier(color: color))
    }
}

/// Target for background color modifier.
public class BackgroundColorTarget: ViewModifierTarget, CustomStringConvertible {
    let color: Color

    public var boundTarget: TargetNode?

    public init(color: Color) {
        self.color = color
    }

    public var description: String {
        return "backgroundColor=\(self.color)"
    }
}
