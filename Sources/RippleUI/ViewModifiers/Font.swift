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

/// Changes the font of a `Text`.
public struct FontModifier: ViewModifier {
    @Rippling var typeface: Resource
    @Rippling var size: DIP

    public init(
        typeface: Rippling<Resource>,
        size: Rippling<DIP>
    ) {
        self._typeface = typeface
        self._size = size
    }

    public static func makeTarget(of modifier: FontModifier) -> FontTarget {
        return FontTarget(typeface: modifier._typeface, size: modifier._size)
    }
}

public extension View {
    /// Changes the font of the text (typeface and size).
    func font(
        typeface: @escaping @autoclosure () -> Resource,
        size: @escaping @autoclosure () -> DIP
    ) -> some View {
        return modifier(FontModifier(typeface: .init(typeface()), size: .init(size())))
    }
}

public class FontTarget: ViewModifierTarget {
    @Rippling var typeface: Resource
    @Rippling var size: DIP

    public var boundTarget: TargetNode?

    public init(
        typeface: Rippling<Resource>,
        size: Rippling<DIP>
    ) {
        self._typeface = typeface
        self._size = size
    }
}
