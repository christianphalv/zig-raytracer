const std = @import("std");
const gfx = @import("root.zig");
const ColorF = gfx.ColorF;
const Image = gfx.Image;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const aspect_ratio: f32 = 16.0 / 9.0;
    const image_width: usize = 256;
    const viewport_width: f32 = 4.0;
    var camera = gfx.Camera.new(
        gfx.Vec3F.new(0.0, 0.0, 0.0),
        gfx.Vec3F.new(0.0, 0.0, -1.0),
        aspect_ratio,
        image_width,
        viewport_width,
    );

    var image = try Image.new(allocator, camera.image_width, camera.image_height);

    for (0..image.height) |j| {
        for (0..image.width) |i| {
            image.data[image.at(i, j)] = ColorF{ .r = 0, .g = 0, .b = 0, .a = 255 };
        }
    }

    std.debug.print("Image width: {}\n", .{image.width});
    std.debug.print("Image height: {}\n", .{image.height});
    std.debug.print("Total number of pixels: {}\n", .{image.width * image.height});

    const render_time = render_block: {
        const start = std.time.milliTimestamp();
        camera.render(&image);
        const end = std.time.milliTimestamp();
        break :render_block end - start;
    };
    std.debug.print("Render time: {} ms\n", .{render_time});
    const average_render_time_per_pixel = @as(f32, @floatFromInt(render_time)) / @as(f32, @floatFromInt(image.width * image.height));
    std.debug.print("Average time per pixel: {} ms\n", .{average_render_time_per_pixel});

    const write_time = write_block: {
        const start = std.time.milliTimestamp();
        try image.write_image();
        const end = std.time.milliTimestamp();
        break :write_block end - start;
    };
    std.debug.print("Write time: {} ms\n", .{write_time});
    const average_write_time_per_pixel = @as(f32, @floatFromInt(write_time)) / @as(f32, @floatFromInt(image.width * image.height));
    std.debug.print("Average time per pixel: {} ms\n", .{average_write_time_per_pixel});
}
