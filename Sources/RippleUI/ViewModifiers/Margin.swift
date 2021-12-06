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

import OpenCombine

import RippleCore
import Yoga

/// Sets the margin of a view.
public struct MarginModifier: ViewModifier {
    @Rippling var top: Float
    @Rippling var right: Float
    @Rippling var bottom: Float
    @Rippling var left: Float

    public init(top: Rippling<DIP>, right: Rippling<DIP>, bottom: Rippling<DIP>, left: Rippling<DIP>) {
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
    func margin(_ margin: @autoclosure @escaping Ripplet<DIP>) -> some View {
        let rippling = Rippling<DIP>(margin())
        return modifier(MarginModifier(top: rippling, right: rippling, bottom: rippling, left: rippling))
    }

    /// Sets the margin of the view for specified edges.
    func margin(
        top: @autoclosure @escaping Ripplet<DIP> = 0,
        right: @autoclosure @escaping Ripplet<DIP> = 0,
        bottom: @autoclosure @escaping Ripplet<DIP> = 0,
        left: @autoclosure @escaping Ripplet<DIP> = 0
    ) -> some View {
        return modifier(
            MarginModifier(
                top: .init(top()),
                right: .init(right()),
                bottom: .init(bottom()),
                left: .init(left())
            )
        )
    }
}

/// Target for margin modifier.
public class MarginTarget: ViewModifierTarget, CustomStringConvertible {
    @Rippling var top: DIP
    @Rippling var right: DIP
    @Rippling var bottom: DIP
    @Rippling var left: DIP

    var topSub: AnyCancellable?
    var rightSub: AnyCancellable?
    var bottomSub: AnyCancellable?
    var leftSub: AnyCancellable?

    public var boundTarget: TargetNode?

    public init(top: Rippling<DIP>, right: Rippling<DIP>, bottom: Rippling<DIP>, left: Rippling<DIP>) {
        self._top = top
        self._right = right
        self._bottom = bottom
        self._left = left

        self.topSub = top.observe { newValue in
            if let ygNode = (self.boundTarget as? ViewTarget)?.ygNode {
                YGNodeStyleSetMargin(ygNode, YGEdgeTop, newValue)
            }
        }
        self.rightSub = right.observe { newValue in
            if let ygNode = (self.boundTarget as? ViewTarget)?.ygNode {
                YGNodeStyleSetMargin(ygNode, YGEdgeRight, newValue)
            }
        }
        self.bottomSub = bottom.observe { newValue in
            if let ygNode = (self.boundTarget as? ViewTarget)?.ygNode {
                YGNodeStyleSetMargin(ygNode, YGEdgeBottom, newValue)
            }
        }
        self.leftSub = left.observe { newValue in
            if let ygNode = (self.boundTarget as? ViewTarget)?.ygNode {
                YGNodeStyleSetMargin(ygNode, YGEdgeLeft, newValue)
            }
        }
    }

    public func apply() {
        if let ygNode = (self.boundTarget as? ViewTarget)?.ygNode {
            YGNodeStyleSetMargin(ygNode, YGEdgeTop, self.top)
            YGNodeStyleSetMargin(ygNode, YGEdgeRight, self.right)
            YGNodeStyleSetMargin(ygNode, YGEdgeBottom, self.bottom)
            YGNodeStyleSetMargin(ygNode, YGEdgeLeft, self.left)
        }
    }

    public func reset() {
        if let ygNode = (self.boundTarget as? ViewTarget)?.ygNode {
            YGNodeStyleSetMargin(ygNode, YGEdgeTop, 0)
            YGNodeStyleSetMargin(ygNode, YGEdgeRight, 0)
            YGNodeStyleSetMargin(ygNode, YGEdgeBottom, 0)
            YGNodeStyleSetMargin(ygNode, YGEdgeLeft, 0)
        }
    }

    public var description: String {
        return "margin=(top: \(self.top), right: \(self.right), bottom: \(self.bottom), left: \(self.left))"
    }
}
