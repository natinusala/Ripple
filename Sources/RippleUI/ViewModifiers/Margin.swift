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

/// Sets the margin of a view.
public struct MarginModifier: ViewModifier {
    public typealias Margin = (top: DIP, right: DIP, bottom: DIP, left: DIP)

    let margin: Margin

    public init(margin: Margin) {
        self.margin = margin
    }

    public static func makeTarget(of modifier: MarginModifier) -> MarginTarget {
        return MarginTarget(margin: modifier.margin)
    }

    public static func updateTarget(_ target: MarginTarget, with modifier: MarginModifier) {}
}

public extension View {
    /// Sets the margin of the view for all 4 edges.
    func margin(_ margin: DIP) -> some View {
        return modifier(MarginModifier(margin: (top: margin, right: margin, bottom: margin, left: margin)))
    }

    /// Sets the margin of the view for specified edges.
    func margin(top: DIP = 0, right: DIP = 0, bottom: DIP = 0, left: DIP = 0) -> some View {
        return modifier(MarginModifier(margin: (top: top, right: right, bottom: bottom, left: left)))
    }
}

/// Target for margin modifier.
public class MarginTarget: ViewModifierTarget, CustomStringConvertible {
    let margin: MarginModifier.Margin

    public init(margin: MarginModifier.Margin) {
        self.margin = margin
    }

    public var description: String {
        return "margin=\(self.margin)"
    }

    public func apply(to target: TargetNode) {
        if let ygNode = (target as? ViewTarget)?.ygNode {
            YGNodeStyleSetMargin(ygNode, YGEdgeTop, self.margin.top)
            YGNodeStyleSetMargin(ygNode, YGEdgeRight, self.margin.right)
            YGNodeStyleSetMargin(ygNode, YGEdgeBottom, self.margin.bottom)
            YGNodeStyleSetMargin(ygNode, YGEdgeLeft, self.margin.left)
        }
    }
}
