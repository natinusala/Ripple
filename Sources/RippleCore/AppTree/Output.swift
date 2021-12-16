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

import Foundation

/// Type-erased output of an app, container or view.
public protocol Output: CustomStringConvertible {
    /// The underlying app, container or view.
    /// Must be settable for bitwise comparison.
    var value: Any { get }

    /// Creates and returns children of the app, container or view.
    /// Will call their `body` property.
    var makeBody: () -> [Output] { get }

    /// Makes the target of that app, container of view, or returns
    /// `nil` if there is no target associated to that node.
    var makeTarget: () -> TargetNode? { get }

    /// Is this app, container or view shallow? Shallow views are views that
    /// don't exist in the final tree because they are not made of any target, but have a body
    /// containing another (possibly also shallow) view.
    var isShallow: Bool { get }

    /// Associated modifiers targets.
    var modifiers: [ViewModifierTarget] { get }
}

public extension Output {
    /// Default implementation of `Output` description.
    var description: String {
        return String(describing: type(of: self)).components(separatedBy: "<")[0]
    }
}
