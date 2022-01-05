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
    @Rippling var top: Dimension
    @Rippling var right: Dimension
    @Rippling var bottom: Dimension
    @Rippling var left: Dimension

    public init(top: Rippling<Dimension>, right: Rippling<Dimension>, bottom: Rippling<Dimension>, left: Rippling<Dimension>) {
        self._top = top
        self._right = right
        self._bottom = bottom
        self._left = left
    }

    public static func makeTarget(of modifier: MarginModifier) -> MarginTarget {
        return MarginTarget(top: modifier._top, right: modifier._right, bottom: modifier._bottom, left: modifier._left)
    }
}

public extension View {
    /// Sets the margin of the view for all 4 edges.
    func margin(_ margin: Rippling<Dimension>) -> some View {
        return modifier(MarginModifier(top: margin, right: margin, bottom: margin, left: margin))
    }

    /// Sets the margin of the view for specified edges.
    func margin(
        top: Rippling<Dimension> = .init(0),
        right: Rippling<Dimension> = .init(0),
        bottom: Rippling<Dimension> = .init(0),
        left: Rippling<Dimension> = .init(0)
    ) -> some View {
        return modifier(
            MarginModifier(
                top: top,
                right: right,
                bottom: bottom,
                left: left
            )
        )
    }

    /// Sets the margin of the view for both horizontal edges (left / right)
    /// and vertical edges (top / bottom).
    func margin(
        horizontal: Rippling<Dimension> = .init(0),
        vertical: Rippling<Dimension> = .init(0)
    ) -> some View {
        return modifier(
            MarginModifier(
                top: vertical,
                right: horizontal,
                bottom: vertical,
                left: horizontal
            )
        )
    }
}

/// Target for margin modifier.
public class MarginTarget: ViewModifierTarget, CustomStringConvertible {
    @Rippling var top: Dimension
    @Rippling var right: Dimension
    @Rippling var bottom: Dimension
    @Rippling var left: Dimension

    var topSub: Subscription?
    var rightSub: Subscription?
    var bottomSub: Subscription?
    var leftSub: Subscription?

    public var boundTarget: TargetNode?

    public init(top: Rippling<Dimension>, right: Rippling<Dimension>, bottom: Rippling<Dimension>, left: Rippling<Dimension>) {
        self._top = top
        self._right = right
        self._bottom = bottom
        self._left = left

        self.topSub = top.observe { newValue in
            if var layoutTarget = self.boundTarget as? LayoutTarget {
                layoutTarget.marginTop = newValue
            }
        }
        self.rightSub = right.observe { newValue in
            if var layoutTarget = self.boundTarget as? LayoutTarget {
                layoutTarget.marginRight = newValue
            }
        }
        self.bottomSub = bottom.observe { newValue in
            if var layoutTarget = self.boundTarget as? LayoutTarget {
                layoutTarget.marginBottom = newValue
            }
        }
        self.leftSub = left.observe { newValue in
            if var layoutTarget = self.boundTarget as? LayoutTarget {
                layoutTarget.marginLeft = newValue
            }
        }
    }

    public func apply() {
        if var layoutTarget = self.boundTarget as? LayoutTarget {
            layoutTarget.marginTop = self.top
            layoutTarget.marginRight = self.right
            layoutTarget.marginBottom = self.bottom
            layoutTarget.marginLeft = self.left
        }
    }

    public func reset() {
        if var layoutTarget = self.boundTarget as? LayoutTarget {
            layoutTarget.marginTop = .undefined
            layoutTarget.marginRight = .undefined
            layoutTarget.marginBottom = .undefined
            layoutTarget.marginLeft = .undefined
        }
    }

    public var description: String {
        return "margin=(top: \(self.top), right: \(self.right), bottom: \(self.bottom), left: \(self.left))"
    }
}
