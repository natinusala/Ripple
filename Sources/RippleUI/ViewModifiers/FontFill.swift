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

// TODO: add a convenience FontColor modifier once modifiers body property is implemented

/// Changes the fill of a `Text`.
public struct FontFillModifier: ViewModifier {
    @Rippling var fill: Fill

    public init(fill: Rippling<Fill>) {
        self._fill = fill
    }

    public static func makeTarget(of modifier: FontFillModifier) -> FontFillTarget {
        return FontFillTarget(observing: modifier._fill)
    }
}

public extension View {
    /// Changes the fill of the text.
    func fontFill(_ fill: Rippling<Fill>) -> some View {
        return modifier(FontFillModifier(fill: fill))
    }
}

public class FontFillTarget: ObservingViewModifierTarget<Fill> {
    override public func onValueChange(newValue: Fill) {
        if var fontTarget = self.boundTarget as? FontTarget {
            fontTarget.fontStyle.fill = newValue
        }
    }
}
