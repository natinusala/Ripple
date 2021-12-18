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

/// A "fill" color or shader.
public struct Fill {
    /// Function to call to create the paint from the
    /// boundaries.
    typealias Factory = (Rect) -> Paint

    /// This function will be called whenever the fill
    /// position or dimensions change to recreate the
    /// paint.
    var paintFactory: Factory

    /// Creates a new fill with the given solid color.
    public static func color(_ color: Color) -> Fill {
        let factory: Factory = { _ in
            return Paint(color: color)
        }

        return Fill(paintFactory: factory)
    }

    /// Creates a new fill with the given radial gradient. Radius will be applied
    /// for both horizontal and vertical axis.
    public static func radialGradient(
        center: (x: Dimension, y: Dimension),
        radius: Dimension,
        stops: [(Color, Dimension)]
    ) -> Fill {
        return .radialGradient(
            center: center,
            radius: (h: radius, v: radius),
            stops: stops
        )
    }

    /// Creates a new fill with the given radial gradient.
    public static func radialGradient(
        center: (x: Dimension, y: Dimension),
        radius: (h: Dimension, v: Dimension),
        stops: [(Color, Dimension)]
    ) -> Fill {
        let factory: Factory = { layout in
            return Paint(shader: .radialGradient(
                center: (x: applyDimension(center.x, on: layout.width), y: applyDimension(center.y, on: layout.height)),
                radius: (h: applyDimension(radius.h, on: layout.width), v: applyDimension(radius.v, on: layout.height)),
                colors: stops.map { // (Color, 0.0 -> 1.0) tuple
                    switch $0.1 {
                        case .dip:
                            fatalError("`dip` values are not allowed for gradient color stops")
                        case .auto:
                            fatalError("`auto` values are not allowed for gradient color stops")
                        case let .percentage(percentage):
                            return ($0.0, percentage.scaleFactor)
                    }
                }
            ))
        }

        return Fill(
            paintFactory: factory
        )
    }

    /// Takes a dimension and converts it to float, appliying percentage if needed.
    static func applyDimension(_ dimension: Dimension, on size: Float) -> Float {
        switch dimension {
            case let .dip(dip):
                return dip
            case let .percentage(percentage):
                return percentage.scaleFactor * size
            case .auto:
                fatalError("`auto` is not a valid value for fills")
        }
    }
}

/// Holds the "style" of something: fill color, stroke, shadow...
public struct Style {
    /// Fill definition.
    var fill: Fill?
}
