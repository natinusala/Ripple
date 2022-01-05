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
    @Rippling var width: Dimension

    init(width: Rippling<Dimension>) {
        self._width = width
    }

    public static func makeTarget(of view: WidthModifier) -> WidthTarget {
        return WidthTarget(observing: view._width)
    }
}

public extension View {
    /// Changes the width of the view.
    func width(_ width: Rippling<Dimension>) -> some View {
        return modifier(WidthModifier(width: width))
    }
}

/// Target for width modifier.
public class WidthTarget: ObservingViewModifierTarget<Dimension>, CustomStringConvertible {
    override public func onValueChange(newValue: Dimension) {
        if var layoutTarget = self.boundTarget as? LayoutTarget {
            layoutTarget.width = newValue
        }
    }

    override public func reset() {
        if var layoutTarget = self.boundTarget as? LayoutTarget {
            layoutTarget.width = .undefined
        }
    }

    public var description: String {
        return "width=\(self.observedValue)"
    }
}
