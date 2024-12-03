const std = @import("std");

pub fn main() !void {
    // Get an allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        _ = gpa.deinit();
    }

    // Open file
    const file = std.fs.cwd().openFile("input.txt", .{}) catch |err| {
        std.debug.print("An error occured opening the file: {}\n", .{err});
        return;
    };
    defer file.close();

    // Get file info
    const fileStat = try file.stat();

    //Read file into buffer
    const buffer = try file.readToEndAlloc(allocator, fileStat.size);
    defer allocator.free(buffer);

    for (0..buffer.len) |i| {
        const c = buffer[i];
        std.debug.print("{c}", .{c});
    }
}
