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

import GLFW
import Glad
import Skia
import CRippleUI
import RippleCore

/// GLFW as a platform.
class GLFWPlatform: Platform {
    required init() throws {
        // Set error callback
        glfwSetErrorCallback {code, error in
            Logger.error("GLFW error \(code): \(error.str ?? "unknown")")
        }

        // Init GLFW
        if glfwInit() != GLFW_TRUE {
            throw GLFWError.initFailed
        }
    }

    func poll() {
        glfwPollEvents()
    }

    func createWindow(title: String, mode: WindowMode, backend: GraphicsBackend) throws -> NativeWindow {
        return try GLFWWindow(title: title, mode: mode, backend: backend)
    }
}

class GLFWWindow: NativeWindow {
    let handle: OpaquePointer?

    var dimensions: ObservedValue<Dimensions>

    /// Current graphics context.
    var context: GraphicsContext

    var skContext: OpaquePointer {
        return self.context.skContext
    }

    var canvas: Canvas {
        return self.context.canvas
    }

    init(title: String, mode: WindowMode, backend: GraphicsBackend) throws {
        // Setup hints
        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3)
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3)
        glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GLFW_TRUE)
        glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE)
        if enableSRGB {
            glfwWindowHint(GLFW_SRGB_CAPABLE, GLFW_TRUE)
        }
        glfwWindowHint(GLFW_STENCIL_BITS, 0)
        glfwWindowHint(GLFW_ALPHA_BITS, 0)
        glfwWindowHint(GLFW_DEPTH_BITS, 0)

        // Reset mode specific values
        glfwWindowHint(GLFW_RED_BITS, GLFW_DONT_CARE)
        glfwWindowHint(GLFW_GREEN_BITS, GLFW_DONT_CARE)
        glfwWindowHint(GLFW_BLUE_BITS, GLFW_DONT_CARE)
        glfwWindowHint(GLFW_REFRESH_RATE, GLFW_DONT_CARE)

        // Get monitor and mode
        let monitor = glfwGetPrimaryMonitor()

        if monitor == nil {
            throw GLFWError.noPrimaryMonitor
        }

        guard let videoMode = glfwGetVideoMode(monitor) else {
            throw GLFWError.noVideoMode
        }

        // Create the new window
        switch mode {
            // Windowed mode
            case let .windowed(width, height):
                self.handle = glfwCreateWindow(
                    Int32(width),
                    Int32(height),
                    title,
                    nil,
                    nil
                )
            // Borderless mode
            case .borderlessWindow:
                glfwWindowHint(GLFW_RED_BITS, videoMode.pointee.redBits)
                glfwWindowHint(GLFW_GREEN_BITS, videoMode.pointee.greenBits)
                glfwWindowHint(GLFW_BLUE_BITS, videoMode.pointee.blueBits)
                glfwWindowHint(GLFW_REFRESH_RATE, videoMode.pointee.refreshRate)

                self.handle = glfwCreateWindow(
                    videoMode.pointee.width,
                    videoMode.pointee.height,
                    title,
                    monitor,
                    nil
                )
            // Fullscreen mode
            case .fullscreen:
                self.handle = glfwCreateWindow(
                    videoMode.pointee.width,
                    videoMode.pointee.height,
                    title,
                    monitor,
                    nil
                )
        }

        if self.handle == nil {
            throw GLFWError.cannotCreateWindow
        }

        // Initialize graphics API
        glfwMakeContextCurrent(handle)

        switch backend {
            case .gl:
                gladLoadGLLoaderFromGLFW()

                if debugGraphicsBackend {
                    glEnable(GLenum(GL_DEBUG_OUTPUT))
                    glDebugMessageCallback(
                        { _, type, id, severity, _, message, _ in
                            onGlDebugMessage(severity: severity, type: type,  id: id, message: message)
                        },
                        nil
                    )
                }
        }

        // Enable sRGB if requested
        if enableSRGB {
            switch backend {
                case .gl:
                    glEnable(UInt32(GL_FRAMEBUFFER_SRGB))
            }
        }

        var actualWindowWidth: Int32 = 0
        var actualWindowHeight: Int32 = 0
        glfwGetWindowSize(handle, &actualWindowWidth, &actualWindowHeight)

        self.dimensions = ObservedValue<Dimensions>(value: (width: Float(actualWindowWidth), height: Float(actualWindowHeight)))

        // Initialize context
        self.context = try GraphicsContext(
            width: self.dimensions.value.width,
            height: self.dimensions.value.height,
            backend: backend
        )

        // Finalize init
        glfwSwapInterval(1)

        // Set the `GLFWWindow` pointer as GLFW window userdata
        let unretainedSelf = Unmanaged.passUnretained(self)
        glfwSetWindowUserPointer(self.handle, unretainedSelf.toOpaque())

        // Setup resize callback
        glfwSetWindowSizeCallback(self.handle) { window, width, height in
            guard let window = window else {
                fatalError("GLFW window size callback called with `nil`")
            }
            onWindowResized(window: window, width: width, height: height)
        }
    }

    var shouldClose: Bool {
        return glfwWindowShouldClose(self.handle) == 1
    }

    func swapBuffers() {
        gr_direct_context_flush(self.skContext)
        glfwSwapBuffers(self.handle)
    }

    /// Called whenever this window is resized.
    func onResized(width: Float, height: Float) {
        // Set new dimensions
        self.dimensions.set((width: width, height: height))

        // Create a new context with new dimensions
        do {
            self.context = try GraphicsContext(
                width: width,
                height: height,
                backend: self.context.backend
            )
        } catch {
            Logger.error("Cannot create new graphics context: \(error)")
            exit(-1)
        }
    }
}

enum GLFWError: Error {
    case initFailed
    case noPrimaryMonitor
    case noVideoMode
    case cannotCreateWindow
}

/// Called when any GLFW window is resized. `GLFWWindow` reference can be retrieved
/// from the window user pointer.
private func onWindowResized(window: OpaquePointer, width: Int32, height: Int32) {
    let unmanagedWindow = Unmanaged<GLFWWindow>.fromOpaque(UnsafeRawPointer(glfwGetWindowUserPointer(window)))
    let glfwWindow = unmanagedWindow.takeUnretainedValue()
    glfwWindow.onResized(width: Float(width), height: Float(height))
}

private func onGlDebugMessage(severity: GLenum, type: GLenum, id: GLuint, message: UnsafePointer<CChar>?) {
    Logger.debug(debugGraphicsBackend, "OpenGL \(severity) \(id): \(message.str ?? "unspecified")")
}
