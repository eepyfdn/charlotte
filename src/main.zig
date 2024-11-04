const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Please provide the app to operate on.\nUsage: {s} <app> <operation>\n", .{args[0]});
        return;
    }
    if (args.len < 3) {
        std.debug.print("Please provide the operation to perform.\nUsage: {s} <app> <operation>\n", .{args[0]});
        return;
    }

    // const app = args[1];
    // const operation = args[2];
}
