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

/// Changes the size of a `Text`.
public struct FontSizeModifier: ViewModifier {
    @Rippling var size: DIP

    public init(size: Rippling<DIP>) {
        self._size = size
    }

    public static func makeTarget(of modifier: FontSizeModifier) -> FontSizeTarget {
        return FontSizeTarget(observing: modifier._size)
    }
}

public extension View {
    /// Changes the size of the text.
    func fontSize(_ size: Rippling<DIP>) -> some View {
        return modifier(FontSizeModifier(size: size))
    }
}

public class FontSizeTarget: ObservingViewModifierTarget<DIP> {
    override public func onValueChange(newValue: DIP) {
        if var fontTarget = self.boundTarget as? FontTarget {
            fontTarget.font.size = newValue
        }
    }
}
