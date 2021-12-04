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

/// Changes the width of a view.
public struct WidthModifier: ViewModifier {
    let width: Dimension

    init(width: Dimension) {
        self.width = width
    }

    public static func makeTarget(of view: WidthModifier) -> WidthTarget {
        return WidthTarget(width: view.width)
    }

    public static func updateTarget(_ target: WidthTarget, with modifier: WidthModifier) {}
}

public extension View {
    /// Changes the width of the view.
    func width(_ width: DIP) -> some View {
        return modifier(WidthModifier(width: .dip(width)))
    }

    /// Changes the width of the view.
    func width(_ width: Percentage) -> some View {
        return modifier(WidthModifier(width: .percentage(width)))
    }

    /// Changes the width of the view.
    func width(_ width: Auto) -> some View {
        return modifier(WidthModifier(width: .auto))
    }
}

/// Target for width modifier.
public class WidthTarget: ViewModifierTarget, CustomStringConvertible {
    let width: Dimension

    init(width: Dimension) {
        self.width = width
    }

    public var description: String {
        return "width=\(self.width)"
    }

    public func apply(to target: TargetNode) {
        if let ygNode = (target as? ViewTarget)?.ygNode {
            switch self.width {
                case let .dip(dip):
                    YGNodeStyleSetMinWidth(ygNode, dip)
                    YGNodeStyleSetWidth(ygNode, dip)
                case let .percentage(percentage):
                    YGNodeStyleSetMinWidthPercent(ygNode, percentage.value)
                    YGNodeStyleSetWidthPercent(ygNode, percentage.value)
                case .auto:
                    YGNodeStyleSetMinWidth(ygNode, YGUndefined)
                    YGNodeStyleSetWidthAuto(ygNode)
            }
        }
    }
}
