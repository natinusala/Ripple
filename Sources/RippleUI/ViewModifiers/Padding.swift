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

/// Sets the padding of a view.
public struct PaddingModifier: ViewModifier {
    public typealias Padding = (top: DIP, right: DIP, bottom: DIP, left: DIP)

    let padding: Padding

    public init(padding: Padding) {
        self.padding = padding
    }

    public static func makeTarget(of modifier: PaddingModifier) -> PaddingTarget {
        return PaddingTarget(padding: modifier.padding)
    }

    public static func updateTarget(_ target: PaddingTarget, with modifier: PaddingModifier) {}
}

public extension View {
    /// Sets the padding of the view for all 4 edges.
    func padding(_ padding: DIP) -> some View {
        return modifier(PaddingModifier(padding: (top: padding, right: padding, bottom: padding, left: padding)))
    }

    /// Sets the padding of the view for specified edges.
    func padding(top: DIP = 0, right: DIP = 0, bottom: DIP = 0, left: DIP = 0) -> some View {
        return modifier(PaddingModifier(padding: (top: top, right: right, bottom: bottom, left: left)))
    }
}

/// Target for padding modifier.
public class PaddingTarget: ViewModifierTarget, CustomStringConvertible {
    let padding: PaddingModifier.Padding

    public init(padding: PaddingModifier.Padding) {
        self.padding = padding
    }

    public var description: String {
        return "padding=\(self.padding)"
    }

    public func apply(to target: TargetNode) {
        if let ygNode = (target as? ViewTarget)?.ygNode {
            YGNodeStyleSetPadding(ygNode, YGEdgeTop, self.padding.top)
            YGNodeStyleSetPadding(ygNode, YGEdgeRight, self.padding.right)
            YGNodeStyleSetPadding(ygNode, YGEdgeBottom, self.padding.bottom)
            YGNodeStyleSetPadding(ygNode, YGEdgeLeft, self.padding.left)
        }
    }
}
