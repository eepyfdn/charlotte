const std = @import("std");
const fs = std.fs;

pub fn get_appdata_dir(allocator: std.mem.Allocator) ![]const u8 {
    const appdata = try fs.getAppDataDir(allocator, "charlotte");

    if (fs.openDirAbsolute(appdata, .{})) |_| {
        return appdata;
    } else |err| switch (err) {
        error.FileNotFound => {
            try fs.makeDirAbsolute(appdata);
            return appdata;
        },
        else => return err,
    }
}

test "get_appdata_dir memory leak test" {
    const allocator = std.testing.allocator;
    const appdata = try get_appdata_dir(allocator);
    allocator.free(appdata);
}
