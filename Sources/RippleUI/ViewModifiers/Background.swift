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

/// Changes the background of a view.
public struct BackgroundModifier: ViewModifier {
    @Rippling var background: Background

    public init(background: Rippling<Background>) {
        self._background = background
    }

    public static func makeTarget(of modifier: BackgroundModifier) -> BackgroundTarget {
        return BackgroundTarget(observing: modifier._background)
    }
}

public extension View {
    /// Changes the background of the view.
    func background(_ background: @autoclosure @escaping Ripplet<Background>) -> some View {
        return modifier(BackgroundModifier(background: .init(background())))
    }
}

/// Target for background modifier.
public class BackgroundTarget: ObservingViewModifierTarget<Background>, CustomStringConvertible {
    override public func onValueChange(newValue: Background) {
        if var backgroundTarget = self.boundTarget as? BackgroundShapeTarget {
            backgroundTarget.background.background = newValue
        }
    }

    override public func reset() {
        if var backgroundTarget = self.boundTarget as? BackgroundShapeTarget {
            backgroundTarget.background.background = nil
        }
    }

    public var description: String {
        return "background=\(self.observedValue)"
    }
}
