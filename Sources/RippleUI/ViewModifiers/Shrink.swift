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

/// Changes the shrink factor of a view.
public struct ShrinkModifier: ViewModifier {
    @Rippling var shrink: Float

    public init(shrink: Rippling<Float>) {
        self._shrink = shrink
    }

    public static func makeTarget(of modifier: ShrinkModifier) -> ShrinkTarget {
        return ShrinkTarget(observing: modifier._shrink)
    }
}

public extension View {
    /// Changes the shrink factor of the view.
    func shrink(_ shrink: @escaping @autoclosure () -> Float) -> some View {
        return modifier(ShrinkModifier(shrink: .init(shrink())))
    }
}

/// Target for shrink modifier.
public class ShrinkTarget: ObservingViewModifierTarget<Float>, CustomStringConvertible {
    override public func onValueChange(newValue: Float) {
        if var layoutTarget = self.boundTarget as? LayoutTarget {
            layoutTarget.shrink = newValue
        }
    }

    override public func reset() {
        if var layoutTarget = self.boundTarget as? LayoutTarget {
            layoutTarget.shrink = .undefined
        }
    }

    public var description: String {
        return "shrink=\(self.observedValue)"
    }
}
