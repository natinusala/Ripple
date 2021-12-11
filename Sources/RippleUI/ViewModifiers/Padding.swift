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

/// Sets the padding of a view.
public struct PaddingModifier: ViewModifier {
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

    public static func makeTarget(of modifier: PaddingModifier) -> PaddingTarget {
        return PaddingTarget(top: modifier._top, right: modifier._right, bottom: modifier._bottom, left: modifier._left)
    }
}

public extension View {
    /// Sets the padding of the view for all 4 edges.
    func padding(_ padding: @autoclosure @escaping Ripplet<Dimension>) -> some View {
        let rippling = Rippling<Dimension>(padding())
        return modifier(PaddingModifier(top: rippling, right: rippling, bottom: rippling, left: rippling))
    }

    /// Sets the padding of the view for specified edges.
    func padding(
        top: @autoclosure @escaping Ripplet<Dimension> = 0,
        right: @autoclosure @escaping Ripplet<Dimension> = 0,
        bottom: @autoclosure @escaping Ripplet<Dimension> = 0,
        left: @autoclosure @escaping Ripplet<Dimension> = 0
    ) -> some View {
        return modifier(
            PaddingModifier(
                top: .init(top()),
                right: .init(right()),
                bottom: .init(bottom()),
                left: .init(left())
            )
        )
    }

    /// Sets the padding of the view for both horizontal edges (left / right)
    /// and vertical edges (top / bottom).
    func padding(
        horizontal: @autoclosure @escaping Ripplet<Dimension> = 0,
        vertical: @autoclosure @escaping Ripplet<Dimension> = 0
    ) -> some View {
        return modifier(
            PaddingModifier(
                top: .init(vertical()),
                right: .init(horizontal()),
                bottom: .init(vertical()),
                left: .init(horizontal())
            )
        )
    }
}

/// Target for padding modifier.
public class PaddingTarget: ViewModifierTarget, CustomStringConvertible {
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
                layoutTarget.paddingTop = newValue
            }
        }
        self.rightSub = right.observe { newValue in
            if var layoutTarget = self.boundTarget as? LayoutTarget {
                layoutTarget.paddingRight = newValue
            }
        }
        self.bottomSub = bottom.observe { newValue in
            if var layoutTarget = self.boundTarget as? LayoutTarget {
                layoutTarget.paddingBottom = newValue
            }
        }
        self.leftSub = left.observe { newValue in
            if var layoutTarget = self.boundTarget as? LayoutTarget {
                layoutTarget.paddingLeft = newValue
            }
        }
    }

    public func apply() {
        if var layoutTarget = self.boundTarget as? LayoutTarget {
            layoutTarget.paddingTop = self.top
            layoutTarget.paddingRight = self.right
            layoutTarget.paddingBottom = self.bottom
            layoutTarget.paddingLeft = self.left
        }
    }

    public func reset() {
        if var layoutTarget = self.boundTarget as? LayoutTarget {
            layoutTarget.paddingTop = .undefined
            layoutTarget.paddingRight = .undefined
            layoutTarget.paddingBottom = .undefined
            layoutTarget.paddingLeft = .undefined
        }
    }

    public var description: String {
        return "padding=(top: \(self.top), right: \(self.right), bottom: \(self.bottom), left: \(self.left))"
    }
}
