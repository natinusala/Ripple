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
    @Rippling var grow: Float

    public init(grow: Rippling<Float>) {
        self._grow = grow
    }

    public static func makeTarget(of modifier: GrowModifier) -> GrowTarget {
        return GrowTarget(observing: modifier._grow)
    }
}

public extension View {
    /// Changes the grow factor of the view.
    /// TODO: change to `Dimension` to allow using percentages
    func grow(_ grow: @autoclosure @escaping Ripplet<Float>) -> some View {
        return modifier(GrowModifier(grow: .init(grow())))
    }
}

/// Target for grow modifier.
public class GrowTarget: ObservingViewModifierTarget<Float>, CustomStringConvertible {
    override public func onValueChange(newValue: Float) {
        if var layoutTarget = self.boundTarget as? LayoutTarget {
            layoutTarget.grow = newValue
        }
    }

    override public func reset() {
        if var layoutTarget = self.boundTarget as? LayoutTarget {
            layoutTarget.grow = .undefined
        }
    }

    public var description: String {
        return "grow=\(self.observedValue)"
    }
}
