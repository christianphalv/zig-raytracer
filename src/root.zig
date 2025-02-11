const std = @import("std");
const testing = std.testing;
const Allocator = std.mem.Allocator;

fn Vec3(comptime T: type) type {
    return struct {
        const Self = @This();
        x: T,
        y: T,
        z: T,

        pub inline fn new(x: T, y: T, z: T) Self {
            return Self{ .x = x, .y = y, .z = z };
        }

        pub inline fn plus(a: Self, b: Self) Self {
            return Self{ .x = a.x + b.x, .y = a.y + b.y, .z = a.z + b.z };
        }

        pub inline fn add(a: *Self, b: Self) void {
            a.x += b.x;
            a.y += b.y;
            a.z += b.z;
        }

        pub inline fn minus(a: Self, b: Self) Self {
            return Self{ .x = a.x - b.x, .y = a.y - b.y, .z = a.z - b.z };
        }

        pub inline fn subtract(a: *Self, b: Self) void {
            a.x -= b.x;
            a.y -= b.y;
            a.z -= b.z;
        }

        pub inline fn timesScalar(a: Self, scalar: T) Self {
            return Self{ .x = a.x * scalar, .y = a.y * scalar, .z = a.z * scalar };
        }

        pub inline fn dot(a: Self, b: *const Self) T {
            return a.x * b.x + a.y * b.y + a.z * b.z;
        }

        pub inline fn equals(a: Self, b: Self) bool {
            return a.x == b.x and a.y == b.y and a.z == b.z;
        }

        pub inline fn length(a: Self) T {
            return @sqrt(a.x * a.x + a.y * a.y + a.z * a.z);
        }

        pub inline fn normalize(a: *Self) void {
            const len = @sqrt(a.x * a.x + a.y * a.y + a.z * a.z);
            if (len != 0) {
                a.x /= len;
                a.y /= len;
                a.z /= len;
            }
        }

        pub inline fn normalized(a: Self) Self {
            const len = @sqrt(a.x * a.x + a.y * a.y + a.z * a.z);
            if (len != 0) {
                return Self{ .x = a.x / len, .y = a.y / len, .z = a.z / len };
            } else {
                return Self{ .x = 0, .y = 0, .z = 0 };
            }
        }

        pub inline fn print(self: Self) void {
            std.debug.print("Vec3({} {} {})\n", .{ self.x, self.y, self.z });
        }
    };
}

pub const Vec3F = Vec3(f32);

test "Vec3 addition" {
    const Vec3F32 = Vec3(f32);
    const a = Vec3F32{ .x = 1.0, .y = 2.0, .z = 3.0 };
    const b = Vec3F32{ .x = 4.0, .y = 5.0, .z = 6.0 };
    try testing.expect(a.add(b).equals(Vec3F32{ .x = 5.0, .y = 7.0, .z = 9.0 }));

    var c = Vec3F32{ .x = 1.0, .y = 2.0, .z = 3.0 };
    c.plus(b);
    try testing.expect(c.equals(Vec3F32{ .x = 5.0, .y = 7.0, .z = 9.0 }));
}

fn Ray3(comptime T: type) type {
    return struct {
        const Self = @This();
        origin: Vec3(T),
        direction: Vec3(T),

        pub inline fn new(origin: Vec3(T), direction: Vec3(T)) Self {
            return Self{ .origin = origin, .direction = direction };
        }

        pub inline fn at(self: *Self, t: T) Vec3(T) {
            return self.origin.add(self.direction.multiply(t));
        }
    };
}

pub const Ray3F = Ray3(f32);

pub const Sphere = struct {
    const Self = @This();
    center: Vec3F,
    radius: f32,

    pub fn hit(self: *const Sphere, ray: Ray3F) f32 {
        const oc = ray.origin.minus(self.center);
        const a = ray.direction.dot(&ray.direction);
        const b = 2.0 * oc.dot(&ray.direction);
        const c = oc.dot(&oc) - self.radius * self.radius;
        const discriminant = b * b - 4 * a * c;
        if (discriminant < 0) {
            return -1.0;
        } else {
            return (-b - @sqrt(discriminant)) / (2.0 * a);
        }
    }
};

fn Color(comptime T: type) type {
    return struct {
        const Self = @This();
        r: T,
        g: T,
        b: T,
        a: T,

        pub fn new(r: T, g: T, b: T, a: T) Self {
            return Self{ .r = r, .g = g, .b = b, .a = a };
        }

        pub inline fn mix(a: Self, b: Self, t: f32) Self {
            return Self{
                .r = 1.0 - t * @as(f32, a.r) + t * @as(f32, b.r),
                .g = 1.0 - t * @as(f32, a.g) + t * @as(f32, b.g),
                .b = 1.0 - t * @as(f32, a.b) + t * @as(f32, b.b),
                .a = 1.0 - t * @as(f32, a.a) + t * @as(f32, b.a),
            };
        }
    };
}

pub const ColorF = Color(f32);

fn Size(comptime T: type) type {
    return struct {
        const Self = @This();
        width: T,
        height: T,

        pub inline fn new(width: T, height: T) Self {
            return Self{ .width = width, .height = height };
        }
    };
}

pub const Camera = struct {
    position: Vec3(f32),
    direction: Vec3(f32),
    up: Vec3(f32), // TODO: add to camera settings eventually
    focal_length: f32, // TODO: add to camera settings eventually
    aspect_ratio: f32,
    image_width: usize,
    image_height: usize,
    viewport_width: f32,
    viewport_height: f32,

    pub fn new(position: Vec3(f32), direction: Vec3(f32), aspect_ratio: f32, image_width: usize, viewport_width: f32) Camera {
        const image_height: usize = @max(@as(usize, @intFromFloat(@as(f32, @floatFromInt(image_width)) / aspect_ratio)), 1);
        const viewport_height: f32 = viewport_width * (@as(f32, @floatFromInt(image_height)) / @as(f32, @floatFromInt(image_width)));

        return Camera{
            .position = position,
            .direction = direction,
            .up = Vec3(f32).new(0.0, 1.0, 0.0),
            .focal_length = 1.0,
            .aspect_ratio = aspect_ratio,
            .image_width = image_width,
            .image_height = image_height,
            .viewport_width = viewport_width,
            .viewport_height = viewport_height,
        };
    }

    pub fn ray_color(ray: Ray3F) ColorF {
        const unit_direction = ray.direction.normalized();
        const t = 0.5 * (unit_direction.y + 1.0);
        if (Sphere.hit(&Sphere{ .center = Vec3F.new(0.0, 0.0, -1.0), .radius = 0.5 }, ray) > 0.0) {
            return ColorF.new(1.0, 0.0, 0.0, 1.0);
        }
        return ColorF.new(1.0, 1.0, 1.0, 1.0).mix(ColorF.new(0.5, 0.7, 1.0, 1.0), t);
    }

    // Renders from the top-left corner of the image
    pub fn render(self: *Camera, image: *Image) void {
        const viewport_u = Vec3F.new(self.viewport_width, 0.0, 0.0);
        const viewport_v = Vec3F.new(0.0, -self.viewport_height, 0.0);

        const pixel_delta_u = viewport_u.timesScalar(1 / @as(f32, @floatFromInt(image.width)));
        const pixel_delta_v = viewport_v.timesScalar(1 / @as(f32, @floatFromInt(image.height)));

        const viewport_center = viewport_u.timesScalar(0.5).plus(viewport_v.timesScalar(0.5));
        const viewport_top_left = self.position.minus(Vec3F.new(0.0, 0.0, self.focal_length)).minus(viewport_center);
        const pixel_00_position = viewport_top_left.plus(pixel_delta_u.plus(pixel_delta_v).timesScalar(0.5));

        for (0..image.height) |j| {
            for (0..image.width) |i| {
                const u: Vec3F = pixel_delta_u.timesScalar(@as(f32, @floatFromInt(i)));
                const v: Vec3F = pixel_delta_v.timesScalar(@as(f32, @floatFromInt(j)));
                const pixel_center = pixel_00_position.plus(u.plus(v));
                const ray = Ray3F.new(self.position, pixel_center.minus(self.position));
                const pixel_color = ray_color(ray);
                image.data[image.at(i, j)] = pixel_color;
            }
        }
    }
};

pub const Image = struct {
    width: usize,
    height: usize,
    data: []ColorF,

    pub fn new(allocator: Allocator, width: usize, height: usize) !Image {
        return Image{ .width = width, .height = height, .data = try allocator.alloc(ColorF, @intCast(width * height)) };
    }

    pub inline fn at(self: *Image, x: usize, y: usize) usize {
        return self.width * y + x;
    }

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
};
