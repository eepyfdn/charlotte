const std = @import("std");

const endpoints = [_][]const u8{
    "https://setup.rbxcdn.com",
    "https://roblox-setup.cachefly.net",
};

fn get_latency(allocator: std.mem.Allocator, endpoint: []const u8) !i64 {
    const start_time = std.time.milliTimestamp();
    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();

    const buf = try allocator.alloc(u8, 1024 * 1024 * 4);
    defer allocator.free(buf);

    _ = try client.fetch(.{
        .method = .GET,
        .location = .{ .url = endpoint },
    });

    return std.time.milliTimestamp() - start_time;
}

test "get_latency" {
    const allocator = std.testing.allocator;
    _ = try get_latency(allocator, "https://roblox.com"); // If Roblox's down, so are we!
}

pub fn get_lowest_latency_mirror(allocator: std.mem.Allocator) ![]const u8 {
    var lowest_latency: i64 = std.math.maxInt(i64);
    var lowest_latency_endpoint: []const u8 = "";

    for (endpoints) |endpoint| {
        const latency = try get_latency(allocator, endpoint);
        if (latency < lowest_latency) {
            lowest_latency = latency;
            lowest_latency_endpoint = endpoint;
        }
    }

    return lowest_latency_endpoint;
}

test "get_lowest_latency_mirror" {
    const allocator = std.testing.allocator;
    _ = try get_lowest_latency_mirror(allocator);
}
