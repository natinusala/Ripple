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
import Skia

/// Definition of a font: a typeface associated to properties such as size, skew...
public struct Font {
    /// Native sk_font_t handle.
    let handle = sk_font_new()

    /// The typeface of this font.
    var typeface: Typeface? {
        didSet {
            if let typeface = self.typeface {
                sk_font_set_typeface(self.handle, typeface.handle)
            }
            else {
                sk_font_set_typeface(self.handle, nil)
            }
        }
    }

    /// The size of this font.
    var size: DIP = 0 {
        didSet {
            sk_font_set_size(self.handle, self.size)
        }
    }
}

/// A typeface, which is the "font" file used to draw text.
public struct Typeface {
    /// Static typeface cache.
    private static var cache = [Resource: OpaquePointer]()

    /// The native sk_typeface_t handle.
    let handle: OpaquePointer

    /// Creates a new typeface from the given resource file.
    /// The typeface will be cached to be reused later without
    /// loading it all over again.
    /// Typefaces are currently never unloaded.
    public init?(from resource: Resource) {
        // If the typeface is already cached, load it from the cache
        if let handle = Typeface.cache[resource] {
            Logger.debug(debugFont, "Getting typeface `\(resource)` from cache")
            self.handle = handle
            return
        }

        // Otherwise load it and add it to the cache
        guard let data = resource.toSkData() else {
            Logger.warning("Could not load file `\(resource)`")
            return nil
        }

        guard let handle = sk_typeface_create_from_data(data, 0) else {
            Logger.warning("Could not load typeface `\(resource)`")
            return nil
        }

        self.handle = handle
        Typeface.cache[resource] = handle

        Logger.debug(debugFont, "Loaded typeface `\(resource)`")
    }
}
