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

/// Changes the height of a view.
public struct HeightModifier: ViewModifier {
    @Rippling var height: Dimension

    init(height: Rippling<Dimension>) {
        self._height = height
    }

    public static func makeTarget(of modifier: HeightModifier) -> HeightTarget {
        return HeightTarget(observing: modifier._height)
    }
}

public extension View {
    /// Changes the height of the view.
    func height(_ height: Rippling<Dimension>) -> some View {
        return modifier(HeightModifier(height: height))
    }
}

/// Target for height modifier.
public class HeightTarget: ObservingViewModifierTarget<Dimension>, CustomStringConvertible {
    override public func onValueChange(newValue: Dimension) {
        if var layoutTarget = self.boundTarget as? LayoutTarget {
            layoutTarget.height = newValue
        }
    }

    override public func reset() {
        if var layoutTarget = self.boundTarget as? LayoutTarget {
            layoutTarget.height = .undefined
        }
    }

    public var description: String {
        return "height=\(self.observedValue)"
    }
}
