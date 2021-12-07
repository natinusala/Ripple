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
    func margin(_ margin: @autoclosure @escaping Ripplet<Dimension>) -> some View {
        let rippling = Rippling<Dimension>(margin())
        return modifier(MarginModifier(top: rippling, right: rippling, bottom: rippling, left: rippling))
    }

    /// Sets the margin of the view for specified edges.
    func margin(
        top: @autoclosure @escaping Ripplet<Dimension> = 0,
        right: @autoclosure @escaping Ripplet<Dimension> = 0,
        bottom: @autoclosure @escaping Ripplet<Dimension> = 0,
        left: @autoclosure @escaping Ripplet<Dimension> = 0
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
    @Rippling var top: Dimension
    @Rippling var right: Dimension
    @Rippling var bottom: Dimension
    @Rippling var left: Dimension

    var topSub: AnyCancellable?
    var rightSub: AnyCancellable?
    var bottomSub: AnyCancellable?
    var leftSub: AnyCancellable?

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
