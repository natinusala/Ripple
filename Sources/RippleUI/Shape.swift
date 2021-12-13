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

/// The background of a shape.
public struct Background {
    /// Background paint.
    var paint: Paint?

    /// Draws the background in the given rectangle.
    func draw(canvas: Canvas, in layout: Rect) {
        if let paint = self.paint {
            canvas.drawRect(layout, paint: paint)
        }
    }

    /// Creates a new background with the given solid color.
    public static func color(_ color: Color) -> Background {
        return Background(paint: Paint(color: color))
    }

    /// Creates a new background with the given radial gradient.
    public static func radialGradient(
        center: (Dimension, Dimension),
        radius: Dimension,
        colors: [(Color, Dimension)]
    ) -> Background {
        fatalError()
        // return Background(
        //     paint: Paint(shader: .radialGradient(
        //         center: center, radius: radius, colors: colors
        //     ))
        // )
    }
}

/// A shape.
public struct Shape {
    /// Background.
    var background: Background?

    /// Draws the shape in the given rectangle.
    func draw(canvas: Canvas, in layout: Rect) {
        self.background?.draw(canvas: canvas, in: layout)
    }
}
