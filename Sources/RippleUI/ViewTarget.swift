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

/// Target of a view.
public class ViewTarget: TargetNode, DrawableTarget, LayoutTarget, StyleTarget {
    public let type: TargetType = .view

    public var children: [TargetNode] = []
    public var parent: TargetNode?

    private let ygNode: YGNodeRef

    var style = Style() {
        didSet {
            self.recreateStylePaints()
        }
    }

    var fillPaint: Paint?

    public private(set) var layout = Rect(
        x: 0,
        y: 0,
        width: 0,
        height: 0
    ) {
        didSet {
            self.recreateStylePaints()
        }
    }

    init() {
        self.ygNode = YGNodeNew()
    }

    /// Called whenever the view layout changes or the style changes to recreate
    /// the drawn paints.
    func recreateStylePaints() {
        // Only make fill if the view has a width and a height
        if self.layout.width > 0 && self.layout.height > 0 {
            self.fillPaint = self.style.fill?.paintFactory(self.layout)
        }
        else {
            self.fillPaint = nil
        }
    }

    public func insert(child: inout TargetNode, at position: UInt?) {
        // Ensure the target node is a view
        guard let view = child as? ViewTarget else {
            fatalError("View targets can only contain views")
        }

        let position = position ?? UInt(self.children.count)

        self.children.insert(child, at: Int(position))
        child.parent = self

        YGNodeInsertChild(self.ygNode, view.ygNode, UInt32(position))
    }

    public func remove(child: TargetNode) {

    }

    /// Called when the parent view layout changes.
    private func updateLayout(parentX: DIP, parentY: DIP) {
        self.layout = Rect(
            x: parentX + YGNodeLayoutGetLeft(self.ygNode),
            y: parentY + YGNodeLayoutGetTop(self.ygNode),
            width: YGNodeLayoutGetWidth(self.ygNode),
            height: YGNodeLayoutGetHeight(self.ygNode)
        )

        Logger.debug(debugLayout, "New layout of \(self): \(self.layout)")

        for child in self.children {
            if let child = child as? ViewTarget {
                child.updateLayout(parentX: self.layout.x, parentY: self.layout.y)
            }
        }

        self.onLayout()
    }

    /// Calculates layout of this view, either by calculating layout of its parent
    /// or calculating its layout directly if the view doesn't have a parent.
    private func calculateLayout() {
        if let parent = self.parent as? ViewTarget {
            parent.calculateLayout()
        } else {
            Logger.debug(debugLayout, "Calling `YGNodeCalculateLayout` on \(self)")

            // Use Yoga to calculate layout
            YGNodeCalculateLayout(self.ygNode, YGUndefined, YGUndefined, YGDirectionLTR)

            // Propagate newly calculated layout to our properties and all our children
            self.updateLayout(parentX: 0, parentY: 0)
        }
    }

    func frame(canvas: Canvas) {
        // Call layout if needed
        if YGNodeIsDirty(self.ygNode) {
            Logger.debug(debugLayout, "\(self) is dirty, calculating layout")

            self.calculateLayout()
        }

        // Draw ourselves
        self.draw(canvas: canvas)

        // Draw every child
        for view in self.children {
            if let drawableTarget = view as? DrawableTarget {
                drawableTarget.frame(canvas: canvas)
            } else if let frameTarget = view as? FrameTarget {
                frameTarget.frame()
            }
        }
    }

    /// Called when this view's layout changes.
    open func onLayout() {}

    open func draw(canvas: Canvas) {
        // Fill
        if let paint = self.fillPaint {
            canvas.drawRect(self.layout, paint: paint)
        }
    }

    var axis: Axis {
        set { YGNodeStyleSetFlexDirection(self.ygNode, newValue.yogaFlexDirection) }
        get { return YGNodeStyleGetFlexDirection(self.ygNode).axis }
    }

    var grow: Float {
        set { YGNodeStyleSetFlexGrow(self.ygNode, newValue) }
        get { return YGNodeStyleGetFlexGrow(self.ygNode) }
    }

    var shrink: Float {
        set { YGNodeStyleSetFlexShrink(self.ygNode, newValue) }
        get { return YGNodeStyleGetFlexShrink(self.ygNode) }
    }

    var width: Dimension {
        set {
            switch newValue {
                case let .dip(dip):
                    YGNodeStyleSetMinWidth(ygNode, dip)
                    YGNodeStyleSetWidth(ygNode, dip)
                case let .percentage(percentage):
                    YGNodeStyleSetMinWidthPercent(ygNode, percentage.value)
                    YGNodeStyleSetWidthPercent(ygNode, percentage.value)
                case .auto:
                    YGNodeStyleSetMinWidth(ygNode, YGUndefined)
                    YGNodeStyleSetWidthAuto(ygNode)
            }
        }
        get { return YGNodeStyleGetWidth(self.ygNode).dimension }
    }

    var height: Dimension {
        set {
            switch newValue {
                case let .dip(dip):
                    YGNodeStyleSetMinHeight(ygNode, dip)
                    YGNodeStyleSetHeight(ygNode, dip)
                case let .percentage(percentage):
                    YGNodeStyleSetMinHeightPercent(ygNode, percentage.value)
                    YGNodeStyleSetHeightPercent(ygNode, percentage.value)
                case .auto:
                    YGNodeStyleSetMinHeight(ygNode, YGUndefined)
                    YGNodeStyleSetHeightAuto(ygNode)
            }
        }
        get { return YGNodeStyleGetHeight(self.ygNode).dimension }
    }

    var marginTop: Dimension {
        set { self.setMargin(edge: YGEdgeTop, value: newValue) }
        get { return YGNodeStyleGetMargin(self.ygNode, YGEdgeTop).dimension }
    }

    var marginRight: Dimension {
        set { self.setMargin(edge: YGEdgeRight, value: newValue) }
        get { return YGNodeStyleGetMargin(self.ygNode, YGEdgeRight).dimension }
    }

    var marginBottom: Dimension {
        set { self.setMargin(edge: YGEdgeBottom, value: newValue) }
        get { return YGNodeStyleGetMargin(self.ygNode, YGEdgeBottom).dimension }
    }

    var marginLeft: Dimension {
        set { self.setMargin(edge: YGEdgeLeft, value: newValue) }
        get { return YGNodeStyleGetMargin(self.ygNode, YGEdgeLeft).dimension }
    }

    private func setMargin(edge: YGEdge, value: Dimension) {
        switch value {
            case let .dip(dip):
                YGNodeStyleSetMargin(self.ygNode, edge, dip)
            case let .percentage(percentage):
                YGNodeStyleSetMarginPercent(self.ygNode, edge, percentage.value)
            case .auto:
                YGNodeStyleSetMarginAuto(self.ygNode, edge)
        }
    }

    var paddingTop: Dimension {
        set { self.setPadding(edge: YGEdgeTop, value: newValue) }
        get { return YGNodeStyleGetPadding(self.ygNode, YGEdgeTop).dimension }
    }

    var paddingRight: Dimension {
        set { self.setPadding(edge: YGEdgeRight, value: newValue) }
        get { return YGNodeStyleGetPadding(self.ygNode, YGEdgeRight).dimension }
    }

    var paddingBottom: Dimension {
        set { self.setPadding(edge: YGEdgeBottom, value: newValue) }
        get { return YGNodeStyleGetPadding(self.ygNode, YGEdgeBottom).dimension }
    }

    var paddingLeft: Dimension {
        set { self.setPadding(edge: YGEdgeLeft, value: newValue) }
        get { return YGNodeStyleGetPadding(self.ygNode, YGEdgeLeft).dimension }
    }

    private func setPadding(edge: YGEdge, value: Dimension) {
        switch value {
            case let .dip(dip):
                YGNodeStyleSetPadding(self.ygNode, edge, dip)
            case let .percentage(percentage):
                YGNodeStyleSetPaddingPercent(self.ygNode, edge, percentage.value)
            case .auto:
                Logger.error(".auto is not supported for padding modifiers")
                exit(-1)
        }
    }

    deinit {
        YGNodeFree(self.ygNode)
    }
}
