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

    func createWindow(title: String, mode: WindowMode, graphicsApi: GraphicsAPI) throws -> NativeWindow {
        return try GLFWWindow(title: title, mode: mode, graphicsApi: graphicsApi)
    }
}

class GLFWWindow: NativeWindow {
    let handle: OpaquePointer?

    let width: Float
    let height: Float

    let skContext: OpaquePointer

    let canvas: Canvas

    init(title: String, mode: WindowMode, graphicsApi: GraphicsAPI) throws {
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

        switch graphicsApi {
            case .gl:
                gladLoadGLLoaderFromGLFW()

                if debugGraphicsAPI {
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
            switch graphicsApi {
                case .gl:
                    glEnable(UInt32(GL_FRAMEBUFFER_SRGB))
            }
        }

        var actualWindowWidth: Int32 = 0
        var actualWindowHeight: Int32 = 0
        glfwGetWindowSize(handle, &actualWindowWidth, &actualWindowHeight)

        self.width = Float(actualWindowWidth)
        self.height = Float(actualWindowHeight)

        // Initialize Skia
        var backendRenderTarget: OpaquePointer?
        var context: OpaquePointer?

        switch graphicsApi {
            case .gl:
                let interface = gr_glinterface_create_native_interface()
                context = gr_direct_context_make_gl(interface)

                var framebufferInfo = gr_gl_framebufferinfo_t(
                    fFBOID: 0,
                    fFormat: UInt32(enableSRGB ? GL_SRGB8_ALPHA8 : GL_RGBA8)
                )

                backendRenderTarget = gr_backendrendertarget_new_gl(
                    actualWindowWidth,
                    actualWindowHeight,
                    0,
                    0,
                    &framebufferInfo
                )
        }

        guard let context = context else {
            throw SkiaError.cannotInitSkiaContext
        }

        self.skContext = context

        guard let target = backendRenderTarget else {
            throw SkiaError.cannotInitSkiaTarget
        }

        let colorSpace: OpaquePointer? = enableSRGB ? sk_colorspace_new_srgb() : nil

        let surface = sk_surface_new_backend_render_target(
            context,
            target,
            BOTTOM_LEFT_GR_SURFACE_ORIGIN,
            RGBA_8888_SK_COLORTYPE,
            colorSpace,
            nil
        )

        if surface == nil {
            throw SkiaError.cannotInitSkiaSurface
        }

        Logger.info("Created \(graphicsApi) context:")

        switch graphicsApi {
            case .gl:
                var majorVersion: GLint = 0
                var minorVersion: GLint = 0
                glGetIntegerv(GLenum(GL_MAJOR_VERSION), &majorVersion)
                glGetIntegerv(GLenum(GL_MINOR_VERSION), &minorVersion)

                Logger.info("   - Version: \(majorVersion).\(minorVersion)")
                Logger.info("   - GLSL version: \(String(cString: glGetString(GLenum(GL_SHADING_LANGUAGE_VERSION))!))")
        }

        // Finalize init
        glfwSwapInterval(1)

        guard let nativeCanvas = sk_surface_get_canvas(surface) else {
            throw SkiaError.cannotInitSkiaCanvas
        }

        self.canvas = SkiaCanvas(handle: nativeCanvas)
    }

    var shouldClose: Bool {
        return glfwWindowShouldClose(self.handle) == 1
    }

    func swapBuffers() {
        gr_direct_context_flush(self.skContext)
        glfwSwapBuffers(self.handle)
    }
}

enum GLFWError: Error {
    case initFailed
    case noPrimaryMonitor
    case noVideoMode
    case cannotCreateWindow
}

enum SkiaError: Error {
    case cannotInitSkiaSurface
    case cannotInitSkiaTarget
    case cannotInitSkiaContext
    case cannotInitSkiaCanvas
}

private func onGlDebugMessage(severity: GLenum, type: GLenum, id: GLuint, message: UnsafePointer<CChar>?) {
    Logger.debug(debugGraphicsAPI, "OpenGL \(severity) \(id): \(message.str ?? "unspecified")")
}
