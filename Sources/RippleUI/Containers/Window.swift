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

import RippleCore

/// A desktop window.
public struct Window<Content>: Container where Content: View {
    @Rippling var title: String
    @Rippling var mode: WindowMode
    @Rippling var graphicsApi: GraphicsAPI

    let content: Content

    public init(
        title: @escaping @autoclosure Ripplet<String>,
        mode: @escaping @autoclosure Ripplet<WindowMode> = .windowed(1280, 720),
        graphicsApi: @escaping @autoclosure Ripplet<GraphicsAPI> = .auto,
        content: () -> Content
    ) {
        self._title = .init(title())
        self._mode = .init(mode())
        self._graphicsApi = .init(graphicsApi())

        self.content = content()
    }

    public var body: Content {
        self.content
    }

    public static func makeTarget(of container: Self) -> WindowTarget {
        return WindowTarget(
            title: container._title,
            mode: container._mode,
            graphicsApi: container._graphicsApi
        )
    }
}

/// Target for a window container.
public class WindowTarget: ContainerTarget, FrameTarget {
    @Rippling var title: String
    @Rippling var mode: WindowMode
    @Rippling var graphicsApi: GraphicsAPI

    let handle: NativeWindow

    init(title: Rippling<String>, mode: Rippling<WindowMode>, graphicsApi: Rippling<GraphicsAPI>) {
        self._title = title
        self._mode = mode
        self._graphicsApi = graphicsApi

        do {
            self.handle = try getContext().platform.createWindow(
                title: title.value,
                mode: mode.value,
                graphicsApi: graphicsApi.value
            )
        } catch {
            Logger.error("Cannot create window: \(error.qualifiedName)")
            exit(-1)
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
}
