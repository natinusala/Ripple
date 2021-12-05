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

import Ripple

struct Separator: View {
    var body: some View {
        Rectangle(color: .white)
            .height(1)
            .margin(10)
    }
}

struct Tab: View {
    var body: some View {
        Row {
            Rectangle(color: .blue)
                .width(100)
                .height(100)
                .margin(right: 50)
            Rectangle(color: .orange)
                .grow(1)
        }
            .margin(bottom: 10)
    }
}

struct Tabs: View {
    var body: some View {
        Column {
            Tab()
            Tab()

            Separator()

            Tab()
            Tab()
        }
    }
}

struct Content: View {
    @State var headerColor: Color = .red

    var body: some View {
        Column {
            Rectangle(color: headerColor)
                .height(50)

            Row {
                Rectangle(color: .orange)
                    .height(100)
                    .margin(right: 20)
                    .grow(0.5)

                Rectangle(color: .yellow)
                    .height(100)
                    .grow(0.5)
            }
                .margin(top: 20)
        }
    }
}

struct MainView: View {
    var body: some View {
        Row {
            Tabs()
                .width(35%)
                .margin(right: 20)
            Content()
                .grow(1)
        }
            .padding(20)
    }
}

@main
struct DemoApp: App {
    var body: some Container {
        Window(title: "Ripple Demo") {
            MainView()
        }
    }
}
