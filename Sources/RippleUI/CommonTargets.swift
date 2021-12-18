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

/// Target protocol for anything that runs every frame.
protocol FrameTarget {
    /// Runs the target for one frame.
    func frame()
}

/// Target protocol for anything that can be drawn onscreen.
protocol DrawableTarget {
    /// Runs the target for one frame.
    func frame(canvas: Canvas)

    /// Draws the target onscreen.
    /// Must be called by `frame(canvas:)` when appropriate.
    func draw(canvas: Canvas)
}

/// Target protocol for anything that has a layout.
protocol LayoutTarget {
    /// Flex axis.
    var axis: Axis { get set }

    /// Grow factor.
    var grow: Float { get set }

    /// Shrink factor.
    var shrink: Float { get set }

    /// Width.
    var width: Dimension { get set }

    /// Height.
    var height: Dimension { get set }

    /// Top margin.
    var marginTop: Dimension { get set }

    /// Right margin.
    var marginRight: Dimension { get set }

    /// Bottom margin.
    var marginBottom: Dimension { get set }

    /// Left margin.
    var marginLeft: Dimension { get set }

    /// Top padding.
    var paddingTop: Dimension { get set }

    /// Right padding.
    var paddingRight: Dimension { get set }

    /// Bottom padding.
    var paddingBottom: Dimension { get set }

    /// Left padding.
    var paddingLeft: Dimension { get set }
}

/// Target protocol for anything that has a style.
protocol StyleTarget {
    var style: Style { get set }
}
