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

/// Changes the typeface of a `Text`.
public struct TypefaceModifier: ViewModifier {
    @Rippling var typeface: Resource

    public init(typeface: Rippling<Resource>) {
        self._typeface = typeface
    }

    public static func makeTarget(of modifier: TypefaceModifier) -> TypefaceTarget {
        return TypefaceTarget(observing: modifier._typeface)
    }
}

public extension View {
    /// Changes the typeface of the text.
    func typeface(_ typeface: Rippling<Resource>) -> some View {
        return modifier(TypefaceModifier(typeface: typeface))
    }
}

public class TypefaceTarget: ObservingViewModifierTarget<Resource> {
    override public func onValueChange(newValue: Resource) {
        if var fontTarget = self.boundTarget as? FontTarget {
            fontTarget.font.typeface = Typeface(from: newValue)
        }
    }
}
