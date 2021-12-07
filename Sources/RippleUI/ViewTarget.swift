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
public class ViewTarget: TargetNode, DrawableTarget, LayoutTarget {
    public let type: TargetType = .view

    public var children: [TargetNode] = []

    private let ygNode: YGNodeRef

    init() {
        self.ygNode = YGNodeNew()
    }

    public func insert(child: TargetNode, at position: UInt?) {
        // Ensure the target node is a view
        guard let view = child as? ViewTarget else {
            fatalError("View targets can only contain views")
        }

        let position = position ?? UInt(self.children.count)

        self.children.insert(child, at: Int(position))
        YGNodeInsertChild(self.ygNode, view.ygNode, UInt32(position))
    }

    public func remove(child: TargetNode) {

    }

    open func frame(canvas: Canvas) {
        // By default, only draw ourselves
        self.draw(canvas: canvas)
    }

    open func draw(canvas: Canvas) {

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
