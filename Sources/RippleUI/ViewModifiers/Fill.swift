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

/// Changes the fill of a view.
public struct FillModifier: ViewModifier {
    @Rippling var fill: Fill

    public init(fill: Rippling<Fill>) {
        self._fill = fill
    }

    public static func makeTarget(of modifier: FillModifier) -> FillTarget {
        return FillTarget(observing: modifier._fill)
    }
}

public extension View {
    /// Changes the fill of the view.
    func fill(_ fill: @escaping @autoclosure () -> Fill) -> some View {
        return modifier(FillModifier(fill: .init(fill())))
    }
}

/// Target for fill modifier.
public class FillTarget: ObservingViewModifierTarget<Fill>, CustomStringConvertible {
    override public func onValueChange(newValue: Fill) {
        if var styleTarget = self.boundTarget as? StyleTarget {
            styleTarget.style.fill = newValue
        }
    }

    override public func reset() {
        if var styleTarget = self.boundTarget as? StyleTarget {
            styleTarget.style.fill = nil
        }
    }

    public var description: String {
        return "fill=\(self.observedValue)"
    }
}
