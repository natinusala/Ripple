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

import Yoga

public extension Float {
    static let undefined = YGUndefined
}

public extension Auto {
    static let auto = Auto()
}

public struct Percentage: Equatable {
    public let value: Float

    public static func == (lhs: Percentage, rhs: Percentage) -> Bool {
        return lhs.value == rhs.value
    }
}

postfix operator %

public extension Float {
    static postfix func % (value: Float) -> Percentage {
        return Percentage(value: value)
    }
}

public struct Auto {}

public typealias DIP = Float

public enum Dimension: CustomStringConvertible {
    case dip(DIP)
    case percentage(Percentage)
    case auto

    public var description: String {
        switch self {
            case let .dip(value):
                return "\(value)dip"
            case let .percentage(value):
                return "\(value)%"
            case .auto:
                return "auto"
        }
    }
}
