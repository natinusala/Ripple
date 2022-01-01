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
import Dispatch

import OpenCombine
import OpenCombineDispatch
import RippleCore

/// A desktop window.
public struct Window<Content>: Container where Content: View {
    @Rippling var title: String
    @Rippling var mode: WindowMode
    @Rippling var backend: GraphicsBackend

    let content: Content

    /// Creates a new desktop window.
    public init(
        title: Rippling<String>,
        mode: Rippling<WindowMode> = .init(.windowed(1280, 720)),
        backend: Rippling<GraphicsBackend> = .init(GraphicsBackend.getDefault()),
        content: () -> Content
    ) {
        self._title = title
        self._mode = mode
        self._backend = backend

        self.content = content()
    }

    public var body: Content {
        self.content
    }

    public static func makeTarget(of container: Self) -> WindowTarget {
        return WindowTarget(
            title: container._title,
            mode: container._mode,
            backend: container._backend
        )
    }
}

/// Target for a window container.
public class WindowTarget: ContainerTarget, FrameTarget {
    @Rippling var title: String
    @Rippling var mode: WindowMode
    @Rippling var backend: GraphicsBackend

    let handle: NativeWindow
    var windowResizeSubscription: AnyCancellable?

    init(title: Rippling<String>, mode: Rippling<WindowMode>, backend: Rippling<GraphicsBackend>) {
        self._title = title
        self._mode = mode
        self._backend = backend

        do {
            self.handle = try getContext().platform.createWindow(
                title: title.value,
                mode: mode.value,
                backend: backend.value
            )
        } catch {
            Logger.error("Cannot create window: \(error.qualifiedName)")
            exit(-1)
        }

        super.init()

        // Subscribe to the native window resize event
        self.windowResizeSubscription = self.handle.dimensions.observe { _, _ in
            self.onResized()
        }
    }

    override public func insert(child: inout TargetNode, at position: UInt?) {
        super.insert(child: &child, at: position)
        self.resizeChildView()
    }

    /// Resizes the child view to fill the whole window.
    func resizeChildView() {
        if var child = self.children[0] as? LayoutTarget {
            child.width = .dip(self.handle.dimensions.value.width)
            child.height = .dip(self.handle.dimensions.value.height)
        }
    }

    func frame() {
        // Handle window "X" button
        if self.handle.shouldClose {
            getContext().exit()
        }

        // Draw every view
        for view in self.children {
            if let drawableTarget = view as? DrawableTarget {
                drawableTarget.frame(canvas: self.handle.canvas)
            } else if let frameTarget = view as? FrameTarget {
                frameTarget.frame()
            }
        }

        // Swap buffers
        self.handle.swapBuffers()
    }

    /// Called anytime the native window is resized.
    func onResized() {
        self.resizeChildView()
    }
}
