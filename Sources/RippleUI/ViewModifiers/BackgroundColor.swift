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

/// Changes the background color of a view.
public struct BackgroundColorModifier: ViewModifier {
    @Rippling var color: Color

    public init(color: Rippling<Color>) {
        self._color = color
    }

    public static func makeTarget(of modifier: BackgroundColorModifier) -> BackgroundColorTarget {
        return BackgroundColorTarget(observing: modifier._color)
    }
}

public extension View {
    /// Changes the background color of the view.
    func backgroundColor(_ color: @autoclosure @escaping Ripplet<Color>) -> some View {
        return modifier(BackgroundColorModifier(color: .init(color())))
    }
}

/// Target for background color modifier.
public class BackgroundColorTarget: ObservingViewModifierTarget<Color>, CustomStringConvertible {
    override public func onValueChange(newValue: Color) {
        if var backgroundTarget = self.boundTarget as? BackgroundTarget {
            backgroundTarget.background.background = Paint(color: newValue)
        }
    }

    override public func reset() {
        if var backgroundTarget = self.boundTarget as? BackgroundTarget {
            backgroundTarget.background.background = nil
        }
    }

    public var description: String {
        return "backgroundColor=\(self.observedValue)"
    }
}
