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

import Dispatch

import Backtrace
import RippleCore

extension App {
    /// Main entry point for an app.
    ///
    /// Use the `@main` attribute on the app to mark it as the main
    /// entry point of your executable target. Calling this
    /// method directly is not supported.
    public static func main() {
        // Enable backtraces for Linux and Windows
        Backtrace.install()

        let _ = Engine(running: Self.init())

        // Temporary main loop: consume every messages in the queue
        dispatchMain()
    }
}
