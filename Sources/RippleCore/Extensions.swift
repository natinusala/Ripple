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

/// `Hashable` extension to provide a default `hash(into:)` implementation for
/// classes.
public extension Hashable where Self: AnyObject {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

/// `Equatable` extension to provide a default `==` implementation for classes.
public extension Equatable where Self: AnyObject {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs === rhs
    }
}

public extension UnsafePointer where Pointee == CChar {
    /// Converts an unsafe char* pointer to a Swift string.
    var str: String {
        return String(cString: self)
    }
}

public extension Optional where Wrapped == UnsafePointer<CChar> {
    /// Converts an optional unsafe char* pointer to a Swift string.
    var str: String? {
        if let cStr = self {
            return String(cString: cStr)
        }

        return nil
    }
}

public extension Error {
    /// Returns the full qualified name of the error ("Type.error").
    var qualifiedName: String {
        return "\(type(of: self)).\(self)"
    }
}
