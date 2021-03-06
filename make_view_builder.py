"""
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
"""

print("/// Generated by make_view_builder.py.")
print("extension ViewBuilder {")

blocksCount = 10

for i in range(2, blocksCount + 1):
    views = [f"v{vi}" for vi in range(0, i)]
    viewsClass = [f"V{vi}" for vi in range(0, i)]

    print(f"    /// buildBlock for {i} child view(s).")

    print(f"    public static func buildBlock<{', '.join(viewsClass)}>({', '.join([f'_ {view}: {viewsClass[i]}' for i, view in enumerate(views)])}) -> TupleView<({', '.join(viewsClass)})> where {': View, '.join(viewsClass)}: View {{")
    print(f"        return TupleView({', '.join(views)})")
    print("    }")

    if i != blocksCount:
        print("")  # just for the newline

print("}")

print("")

print("/// Generated by make_view_builder.py.")
print("extension TupleView {")
for i in range(2, blocksCount + 1):
    views = [f"v{vi}" for vi in range(0, i)]
    viewsClass = [f"V{vi}" for vi in range(0, i)]

    print(f"    /// Constructor for {i} child view(s).")
    print(f"    init<{': View, '.join(viewsClass)}: View>({', '.join([f'_ {view}: {viewsClass[i]}' for i, view in enumerate(views)])}) where T == ({', '.join(viewsClass)}) {{")
    print(f"        self.content = ({', '.join(views)})")
    print(f"        self.output = {{ return {' + '.join([f'V{i}.makeOutput(of: v{i})' for i in range(0, i)])} }}")
    print("    }")

    if i != blocksCount:
        print("")  # just for the newline
print("}")
