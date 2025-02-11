# Benchmarks

## Initial Commit

```
Image width: 256
Image height: 144
Total number of pixels: 36864
Render time: 3 ms
Average time per pixel: 8.138021e-5 ms
Write time: 300 ms
Average time per pixel: 8.1380205e-3 ms
```

## Write to image at once as buffer

This reduced the write time by `300 / 10 = 30` times!

```
Image width: 256
Image height: 144
Total number of pixels: 36864
Render time: 3 ms
Average time per pixel: 8.138021e-5 ms
Write time: 10 ms
Average time per pixel: 2.7126737e-4 ms
```

### Before
```
pub fn write_image(image: *Image) !void {
    const file = try std.fs.cwd().createFile("output.ppm", .{});
    defer file.close();
    var writer = file.writer();

    try writer.print("P3\n{} {}\n255\n", .{ image.width, image.height });

    for (0..image.height) |j| {
        for (0..image.width) |i| {
            const r: u8 = @intFromFloat(image.data[image.at(i, j)].r * 255.0);
            const g: u8 = @intFromFloat(image.data[image.at(i, j)].g * 255.0);
            const b: u8 = @intFromFloat(image.data[image.at(i, j)].b * 255.0);
            try writer.print("{} {} {}\n", .{ r, g, b });
        }
    }
}
```

### After
```
pub fn write_image(image: *Image, allocator: Allocator) !void {
    const file = try std.fs.cwd().createFile("output.ppm", .{});
    defer file.close();
    var writer = file.writer();

    try writer.print("P3\n{} {}\n255\n", .{ image.width, image.height });

    var buffer: []u8 = try allocator.alloc(u8, image.width * image.height * 15);
    defer allocator.free(buffer);

    var index: usize = 0;
    for (0..image.height) |j| {
        for (0..image.width) |i| {
            const r: u8 = @intFromFloat(image.data[image.at(i, j)].r * 255.0);
            const g: u8 = @intFromFloat(image.data[image.at(i, j)].g * 255.0);
            const b: u8 = @intFromFloat(image.data[image.at(i, j)].b * 255.0);
            const written = std.fmt.bufPrint(buffer[index..], "{} {} {}\n", .{ r, g, b }) catch unreachable;
            index += written.len;
        }
    }

    _ = try writer.write(buffer[0..index]);
}
```