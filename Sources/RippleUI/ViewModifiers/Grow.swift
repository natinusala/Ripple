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

import Yoga

/// Changes the grow factor of a view.
public struct GrowModifier: ViewModifier {
    let grow: Float

    public init(grow: Float) {
        self.grow = grow
    }

    public static func makeTarget(of modifier: GrowModifier) -> GrowTarget {
        return GrowTarget(grow: modifier.grow)
    }
}

public extension View {
    /// Changes the grow factor of the view.
    func grow(_ grow: Float) -> some View {
        return modifier(GrowModifier(grow: grow))
    }
}

/// Target for grow modifier.
public class GrowTarget: ViewModifierTarget, CustomStringConvertible {
    let grow: Float

    public var boundTarget: TargetNode?

    public init(grow: Float) {
        self.grow = grow
    }

    public var description: String {
        return "grow=\(self.grow)"
    }

    public func apply() {
        if let ygNode = (self.boundTarget as? ViewTarget)?.ygNode {
            YGNodeStyleSetFlexGrow(ygNode, self.grow)
        }
    }
}
