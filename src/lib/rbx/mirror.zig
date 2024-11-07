const std = @import("std");

const errors = @import("../error.zig").CharlotteError.mirror;

const endpoints = [_][]const u8{
    "https://setup.rbxcdn.com",
    "https://roblox-setup.cachefly.net",
    "https://s3.amazonaws.com/setup.roblox.com",
};

const LatencyResult = struct {
    allocator: std.mem.Allocator,
    endpoint: []const u8,
    latency: i64,
};

fn get_latency(allocator: std.mem.Allocator, endpoint: []const u8) !i64 {
    const start_time = std.time.milliTimestamp();
    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();

    _ = try client.fetch(.{
        .method = .GET,
        .location = .{ .url = endpoint },
    });

    return std.time.milliTimestamp() - start_time;
}

fn latencyWorker(result: *LatencyResult) void {
    result.latency = get_latency(result.allocator, result.endpoint) catch std.math.maxInt(i64);
}

pub fn get_lowest_latency_mirror(allocator: std.mem.Allocator) ![]const u8 {
    var results: [endpoints.len]LatencyResult = undefined;
    var threads: [endpoints.len]std.Thread = undefined;

    for (endpoints, 0..) |endpoint, i| {
        results[i] = LatencyResult{ .allocator = allocator, .endpoint = endpoint, .latency = std.math.maxInt(i64) };
        std.log.debug("endpoint: {s}", .{endpoint});
        threads[i] = try std.Thread.spawn(.{}, latencyWorker, .{&results[i]});
    }

    for (threads) |thread| {
        thread.join();
    }

    var lowest_latency: i64 = std.math.maxInt(i64);
    var lowest_latency_endpoint: []const u8 = "";

    for (results) |result| {
        if (result.latency < lowest_latency) {
            lowest_latency = result.latency;
            lowest_latency_endpoint = result.endpoint;
        }
    }

    if (std.mem.eql(u8, lowest_latency_endpoint, "")) {
        return errors.NoMirrorsAvailable;
    }

    return lowest_latency_endpoint;
}

test "get_lowest_latency_mirror" {
    const allocator = std.testing.allocator;
    _ = try get_lowest_latency_mirror(allocator);
}
