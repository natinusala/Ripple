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
public struct SizeModifier: ViewModifier {
    @Rippling var size: DIP

    public init(size: Rippling<DIP>) {
        self._size = size
    }

    public static func makeTarget(of modifier: SizeModifier) -> SizeTarget {
        return SizeTarget(size: modifier._size)
    }
}

public extension View {
    /// Changes the size of the text.
    func size(_ size: Rippling<DIP>) -> some View {
        return modifier(SizeModifier(size: size))
    }
}

public class SizeTarget: ViewModifierTarget {
    @Rippling var size: DIP

    public var boundTarget: TargetNode?

    public init(size: Rippling<DIP>) {
        self._size = size
    }
}
