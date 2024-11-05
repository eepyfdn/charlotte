const std = @import("std");
const fs = std.fs;

fn create_dir_if_not_found(path: []const u8) !void {
    if (fs.openDirAbsolute(path, .{})) |_| {
        return;
    } else |err| switch (err) {
        error.FileNotFound => {
            try fs.makeDirAbsolute(path);
            return;
        },
        else => return err,
    }
}

pub fn get_appdata_dir(allocator: std.mem.Allocator) ![]const u8 {
    const appdata = try fs.getAppDataDir(allocator, "charlotte");

    try create_dir_if_not_found(appdata);

    return appdata;
}

test "get_appdata_dir memory leak test" {
    const allocator = std.testing.allocator;
    const appdata = try get_appdata_dir(allocator);
    allocator.free(appdata);
}
