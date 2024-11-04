const std = @import("std");
const builtin = @import("builtin");

const data = @import("data.zig");

const debug = if (builtin.mode == .Debug) true else false;

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

    if (debug) {
        std.log.info("app: {s}, operation: {s}", .{ app, operation });
        std.log.info("executable: {s}, executable_type: {s}", .{ executable, executable_type });
    }
}
