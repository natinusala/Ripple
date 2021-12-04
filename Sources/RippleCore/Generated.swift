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

/// Generated by make_view_builder.py.
extension ViewBuilder {
    /// buildBlock for 2 child view(s).
    public static func buildBlock<V0, V1>(_ v0: V0, _ v1: V1) -> TupleView<(V0, V1)> where V0: View, V1: View {
        return TupleView(v0, v1)
    }

    /// buildBlock for 3 child view(s).
    public static func buildBlock<V0, V1, V2>(_ v0: V0, _ v1: V1, _ v2: V2) -> TupleView<(V0, V1, V2)> where V0: View, V1: View, V2: View {
        return TupleView(v0, v1, v2)
    }

    /// buildBlock for 4 child view(s).
    public static func buildBlock<V0, V1, V2, V3>(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3) -> TupleView<(V0, V1, V2, V3)> where V0: View, V1: View, V2: View, V3: View {
        return TupleView(v0, v1, v2, v3)
    }

    /// buildBlock for 5 child view(s).
    public static func buildBlock<V0, V1, V2, V3, V4>(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4) -> TupleView<(V0, V1, V2, V3, V4)> where V0: View, V1: View, V2: View, V3: View, V4: View {
        return TupleView(v0, v1, v2, v3, v4)
    }

    /// buildBlock for 6 child view(s).
    public static func buildBlock<V0, V1, V2, V3, V4, V5>(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5) -> TupleView<(V0, V1, V2, V3, V4, V5)> where V0: View, V1: View, V2: View, V3: View, V4: View, V5: View {
        return TupleView(v0, v1, v2, v3, v4, v5)
    }

    /// buildBlock for 7 child view(s).
    public static func buildBlock<V0, V1, V2, V3, V4, V5, V6>(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5, _ v6: V6) -> TupleView<(V0, V1, V2, V3, V4, V5, V6)> where V0: View, V1: View, V2: View, V3: View, V4: View, V5: View, V6: View {
        return TupleView(v0, v1, v2, v3, v4, v5, v6)
    }

    /// buildBlock for 8 child view(s).
    public static func buildBlock<V0, V1, V2, V3, V4, V5, V6, V7>(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5, _ v6: V6, _ v7: V7) -> TupleView<(V0, V1, V2, V3, V4, V5, V6, V7)> where V0: View, V1: View, V2: View, V3: View, V4: View, V5: View, V6: View, V7: View {
        return TupleView(v0, v1, v2, v3, v4, v5, v6, v7)
    }

    /// buildBlock for 9 child view(s).
    public static func buildBlock<V0, V1, V2, V3, V4, V5, V6, V7, V8>(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5, _ v6: V6, _ v7: V7, _ v8: V8) -> TupleView<(V0, V1, V2, V3, V4, V5, V6, V7, V8)> where V0: View, V1: View, V2: View, V3: View, V4: View, V5: View, V6: View, V7: View, V8: View {
        return TupleView(v0, v1, v2, v3, v4, v5, v6, v7, v8)
    }

    /// buildBlock for 10 child view(s).
    public static func buildBlock<V0, V1, V2, V3, V4, V5, V6, V7, V8, V9>(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5, _ v6: V6, _ v7: V7, _ v8: V8, _ v9: V9) -> TupleView<(V0, V1, V2, V3, V4, V5, V6, V7, V8, V9)> where V0: View, V1: View, V2: View, V3: View, V4: View, V5: View, V6: View, V7: View, V8: View, V9: View {
        return TupleView(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9)
    }
}

/// Generated by make_view_builder.py.
extension TupleView {
    /// Constructor for 2 child view(s).
    init<V0: View, V1: View>(_ v0: V0, _ v1: V1) where T == (V0, V1) {
        self.content = (v0, v1)
        self.output = { return V0.makeOutput(of: v0) + V1.makeOutput(of: v1) }
    }

    /// Constructor for 3 child view(s).
    init<V0: View, V1: View, V2: View>(_ v0: V0, _ v1: V1, _ v2: V2) where T == (V0, V1, V2) {
        self.content = (v0, v1, v2)
        self.output = { return V0.makeOutput(of: v0) + V1.makeOutput(of: v1) + V2.makeOutput(of: v2) }
    }

    /// Constructor for 4 child view(s).
    init<V0: View, V1: View, V2: View, V3: View>(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3) where T == (V0, V1, V2, V3) {
        self.content = (v0, v1, v2, v3)
        self.output = { return V0.makeOutput(of: v0) + V1.makeOutput(of: v1) + V2.makeOutput(of: v2) + V3.makeOutput(of: v3) }
    }

    /// Constructor for 5 child view(s).
    init<V0: View, V1: View, V2: View, V3: View, V4: View>(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4) where T == (V0, V1, V2, V3, V4) {
        self.content = (v0, v1, v2, v3, v4)
        self.output = { return V0.makeOutput(of: v0) + V1.makeOutput(of: v1) + V2.makeOutput(of: v2) + V3.makeOutput(of: v3) + V4.makeOutput(of: v4) }
    }

    /// Constructor for 6 child view(s).
    init<V0: View, V1: View, V2: View, V3: View, V4: View, V5: View>(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5) where T == (V0, V1, V2, V3, V4, V5) {
        self.content = (v0, v1, v2, v3, v4, v5)
        self.output = { return V0.makeOutput(of: v0) + V1.makeOutput(of: v1) + V2.makeOutput(of: v2) + V3.makeOutput(of: v3) + V4.makeOutput(of: v4) + V5.makeOutput(of: v5) }
    }

    /// Constructor for 7 child view(s).
    init<V0: View, V1: View, V2: View, V3: View, V4: View, V5: View, V6: View>(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5, _ v6: V6) where T == (V0, V1, V2, V3, V4, V5, V6) {
        self.content = (v0, v1, v2, v3, v4, v5, v6)
        self.output = { return V0.makeOutput(of: v0) + V1.makeOutput(of: v1) + V2.makeOutput(of: v2) + V3.makeOutput(of: v3) + V4.makeOutput(of: v4) + V5.makeOutput(of: v5) + V6.makeOutput(of: v6) }
    }

    /// Constructor for 8 child view(s).
    init<V0: View, V1: View, V2: View, V3: View, V4: View, V5: View, V6: View, V7: View>(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5, _ v6: V6, _ v7: V7) where T == (V0, V1, V2, V3, V4, V5, V6, V7) {
        self.content = (v0, v1, v2, v3, v4, v5, v6, v7)
        self.output = { return V0.makeOutput(of: v0) + V1.makeOutput(of: v1) + V2.makeOutput(of: v2) + V3.makeOutput(of: v3) + V4.makeOutput(of: v4) + V5.makeOutput(of: v5) + V6.makeOutput(of: v6) + V7.makeOutput(of: v7) }
    }

    /// Constructor for 9 child view(s).
    init<V0: View, V1: View, V2: View, V3: View, V4: View, V5: View, V6: View, V7: View, V8: View>(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5, _ v6: V6, _ v7: V7, _ v8: V8) where T == (V0, V1, V2, V3, V4, V5, V6, V7, V8) {
        self.content = (v0, v1, v2, v3, v4, v5, v6, v7, v8)
        self.output = { return V0.makeOutput(of: v0) + V1.makeOutput(of: v1) + V2.makeOutput(of: v2) + V3.makeOutput(of: v3) + V4.makeOutput(of: v4) + V5.makeOutput(of: v5) + V6.makeOutput(of: v6) + V7.makeOutput(of: v7) + V8.makeOutput(of: v8) }
    }

    /// Constructor for 10 child view(s).
    init<V0: View, V1: View, V2: View, V3: View, V4: View, V5: View, V6: View, V7: View, V8: View, V9: View>(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5, _ v6: V6, _ v7: V7, _ v8: V8, _ v9: V9) where T == (V0, V1, V2, V3, V4, V5, V6, V7, V8, V9) {
        self.content = (v0, v1, v2, v3, v4, v5, v6, v7, v8, v9)
        self.output = { return V0.makeOutput(of: v0) + V1.makeOutput(of: v1) + V2.makeOutput(of: v2) + V3.makeOutput(of: v3) + V4.makeOutput(of: v4) + V5.makeOutput(of: v5) + V6.makeOutput(of: v6) + V7.makeOutput(of: v7) + V8.makeOutput(of: v8) + V9.makeOutput(of: v9) }
    }
}