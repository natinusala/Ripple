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

/// Enable sRGB color space?
/// TODO: make it user-customizable should anyone care about sRGB
let enableSRGB = false

/// The mode of a window.
public enum WindowMode {
    /// Windowed window with given width and height.
    case windowed(Float, Float)
    /// Fullscreen borderless window.
    case borderlessWindow
    /// Fullscreen application.
    case fullscreen
}

/// Protocol for functions to interface with the platform.
protocol Platform {
    init() throws

    /// Poll events.
    func poll()

    /// Creates, opens and makes current a new window.
    func createWindow(title: String, mode: WindowMode, graphicsApi: GraphicsAPI) throws -> NativeWindow
}

/// Creates and returns the `Platform` handle for the currently running platform,
/// or returns `nil` if none has been found.
func createPlatform() throws -> Platform? {
    return try GLFWPlatform() // TODO: only return GLFW if it's actually available
}

/// The graphics API / renderer of an application.
public enum GraphicsAPI {
    /// OpenGL.
    case gl

    /// Let Ripple select the best one.
    case auto

    /// Selects the best available graphics API, or raises an exception if
    /// none was found.
    public static func getDefault() throws -> GraphicsAPI {
        // TODO: only return OpenGL if it's actually available
        return .gl
    }
}

/// Represents a native, platform-dependent window.
protocol NativeWindow {
    var shouldClose: Bool { get }
    var width: Float { get }
    var height: Float { get }
    var canvas: Canvas { get }

    func swapBuffers()
}