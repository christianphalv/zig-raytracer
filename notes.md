### Vec generator that doesn't work how I want but is interesting.

```
// pub fn Vec(comptime dimensions: []const [:0]const u8, comptime T: type) type {
//     var fields: [dimensions.len]std.builtin.Type.StructField = undefined;
//     for (dimensions, 0..) |d, i| {
//         const fieldType = T;
//         const fieldName: [:0]const u8 = d[0..];

//         fields[i] = .{
//             .name = fieldName,
//             .type = fieldType,
//             .default_value = null,
//             .is_comptime = false,
//             .alignment = 0,
//         };
//     }

//     return @Type(.{ .Struct = .{
//         .layout = .auto,
//         .fields = fields[0..],
//         .decls = &.{},
//         .is_tuple = false,
//     } });
// }

// fn Vec(comptime dimensionality: u8, comptime T: type) type {
//     return struct {
//         const Self = @This();
//         d: [dimensionality]T,

//         pub fn add(a: Self, b: Self) Self {
//             var result: Self = undefined;
//             for (0..dimensionality) |i| {
//                 result.d[i] = a.d[i] + b.d[i];
//             }
//             return result;
//         }

//         pub fn equals(a: Self, b: Self) bool {
//             for (0..dimensionality) |i| {
//                 if (a.d[i] != b.d[i]) {
//                     return false;
//                 }
//             }
//             return true;
//         }
//     };
// }
```