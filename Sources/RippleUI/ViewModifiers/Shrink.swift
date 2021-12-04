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

/// Changes the shrink factor of a view.
public struct ShrinkModifier: ViewModifier {
    let shrink: Float

    public init(shrink: Float) {
        self.shrink = shrink
    }

    public static func makeTarget(of modifier: ShrinkModifier) -> ShrinkTarget {
        return ShrinkTarget(shrink: modifier.shrink)
    }

    public static func updateTarget(_ target: ShrinkTarget, with modifier: ShrinkModifier) {}
}

public extension View {
    /// Changes the shrink factor of the view.
    func shrink(_ shrink: Float) -> some View {
        return modifier(ShrinkModifier(shrink: shrink))
    }
}

/// Target for shrink modifier.
public class ShrinkTarget: ViewModifierTarget, CustomStringConvertible {
    let shrink: Float

    public init(shrink: Float) {
        self.shrink = shrink
    }

    public var description: String {
        return "shrink=\(self.shrink)"
    }
}
