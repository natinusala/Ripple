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

/// Displays one or multiple lines of text.
///
/// By default, a `Text` does not have any font or style. Appropriate
/// modifiers must always be used with every `Text` otherwise nothing
/// will be rendered on screen.
///
/// As a result, the recommended way to use `Text` is to create views for
/// the most often used text styles: `Heading`, `Paragraph`, `Label`...
/// This way, you can directly use the `Label` view instead of repeating `Text`
/// views with identical font and style modifiers.
public struct Text: View {
    public typealias Body = Never

    @Rippling var text: String

    /// Creates a new text with given string.
    public init(_ text: Rippling<String>) {
        self._text = text
    }

    public static func makeTarget(of view: Text) -> TextTarget {
        return TextTarget(text: view._text)
    }
}

/// Target for text views.
public class TextTarget: ViewTarget, FontTarget {
    @Rippling var text: String

    public var font = Font()
    public var fontStyle = Style()

    init(text: Rippling<String>) {
        self._text = text
    }
}
