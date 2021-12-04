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
import Yoga

/// Modifies the axis of a node.
public struct AxisModifier: ViewModifier {
    let axis: Axis

    init(axis: Axis) {
        self.axis = axis
    }

    public static func makeTarget(of modifier: AxisModifier) -> AxisTarget {
        return AxisTarget(axis: modifier.axis)
    }

    public static func updateTarget(_ target: AxisTarget, with modifier: AxisModifier) {}
}

public extension Node {
    /// Modifies the axis of the node.
    func axis(_ axis: Axis) -> some View {
        return modifier(AxisModifier(axis: axis))
    }
}

/// Target for axis view modifier.
public class AxisTarget: ViewModifierTarget, CustomStringConvertible {
    let axis: Axis

    init(axis: Axis) {
        self.axis = axis
    }

    public func apply(to target: TargetNode) {
        if let ygNode = (target as? ViewTarget)?.ygNode {
            YGNodeStyleSetFlexDirection(ygNode, self.axis.yogaFlexDirection)
        }
    }

    public var description: String {
        return "axis=\(self.axis)"
    }
}

/// A node axis.
public enum Axis {
    case row
    case column

    /// Corresponding Yoga YGFlexDirection.
    var yogaFlexDirection: YGFlexDirection {
        switch self {
            case .column:
                return YGFlexDirectionColumn
            case .row:
                return YGFlexDirectionRow
        }
    }
}

public extension YGFlexDirection {
    /// Corresponding Skylark axis.
    var axis: Axis {
        switch self {
            case YGFlexDirectionColumn:
                return .column
            case YGFlexDirectionRow:
                return .row
            default:
                fatalError("Unsupported YGFlexDirection \(self)")
        }
    }
}
