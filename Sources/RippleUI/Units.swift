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

/// A percentage, typically ranging from 0 to 100, but can also
/// represent negative percentages or more than 100%.
public struct Percentage: Equatable {
    public let value: Float

    /// Creates a new percentage value from given float.
    init(_ value: Float) {
        self.value = value
    }

    public static func == (lhs: Percentage, rhs: Percentage) -> Bool {
        return lhs.value == rhs.value
    }
}

postfix operator %

public extension Float {
    /// Creates a percentage `Dimension` from a float literal.
    static postfix func % (value: Float) -> Dimension {
        return .percentage(Percentage(value))
    }
}

public typealias DIP = Float

public extension DIP {
    static let undefined: DIP = YGUndefined
}

/// A dimension which unit can vary.
public enum Dimension: CustomStringConvertible, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    case dip(DIP)
    case percentage(Percentage)
    case auto

    public static let undefined = Dimension.dip(YGUndefined)

    public init(floatLiteral: Float) {
        self = .dip(floatLiteral)
    }

    public init(integerLiteral: Int) {
        self = .dip(Float(integerLiteral))
    }

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

public extension YGValue {
    /// Corresponding Ripple dimension.
    var dimension: Dimension {
        switch self.unit {
            case YGUnitUndefined:
                return .undefined
            case YGUnitPoint:
                return .dip(self.value)
            case YGUnitPercent:
                return .percentage(Percentage(self.value))
            case YGUnitAuto:
                return .auto
            default:
                fatalError("Unknown YGValue \(self)")
        }
    }
}
