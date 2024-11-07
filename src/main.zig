const std = @import("std");
const builtin = @import("builtin");

const data = @import("lib/data.zig");
const errors = @import("lib/error.zig").CharlotteError;
const mirror = @import("lib/rbx/mirror.zig");

pub fn main() !void {
    std.log.debug("target - {s}-{s}-{s}", .{ @tagName(builtin.cpu.arch), @tagName(builtin.os.tag), @tagName(builtin.target.abi) });
    std.log.debug("mode - {s}", .{@tagName(builtin.mode)});
    std.log.debug("zig version - {s}", .{builtin.zig_version_string});

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

    const app = args[1];
    const operation = args[2];

    var executable: []const u8 = "";
    var executable_type: []const u8 = "";

    if (std.mem.eql(u8, app, "player")) {
        executable = "RobloxPlayerBeta.exe";
        executable_type = "WindowsPlayer";
    } else if (std.mem.eql(u8, app, "studio")) {
        executable = "RobloxStudioBeta.exe";
        executable_type = "WindowsStudio64";
    } else {
        std.debug.print("Invalid app value. Please provide 'player' or 'studio'.\n", .{});
        return;
    }

    const appdata = try data.get_appdata_dir(allocator);
    defer allocator.free(appdata);

    std.log.debug("app: {s}, operation: {s}", .{ app, operation });
    std.log.debug("executable: {s}, executable_type: {s}", .{ executable, executable_type });

    const mirror_selected = mirror.get_lowest_latency_mirror(allocator) catch |err| {
        switch (err) {
            errors.mirror.NoMirrorsAvailable => {
                std.debug.print("No mirrors available! Check your internet connection or connection to Roblox's servers.\n", .{});
            },
            else => {
                std.debug.print("An error occurred while fetching the lowest latency mirror: {?}\n", .{err});
            },
        }
        return;
    };

    std.log.debug("lowest latency mirror: {s}", .{mirror_selected});
}
