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

    var leftSideList = std.ArrayList(i32).init(allocator);
    defer leftSideList.deinit();
    var rightSideList = std.ArrayList(i32).init(allocator);
    defer rightSideList.deinit();

    //Itterate over buffer, parse values and append to lists
    var lines = std.mem.splitSequence(u8, buffer, "\r\n");
    while (lines.next()) |line| {
        var elements = std.mem.tokenizeScalar(u8, line, ' ');
        const leftSide = elements.next();
        const rightSide = elements.next();

        try leftSideList.append(try std.fmt.parseInt(i32, leftSide.?, 10));
        try rightSideList.append(try std.fmt.parseInt(i32, rightSide.?, 10));
    }

    // Sort lists
    std.mem.sort(i32, leftSideList.items, {}, std.sort.asc(i32));
    std.mem.sort(i32, rightSideList.items, {}, std.sort.asc(i32));

    var accumulator: u32 = 0;
    for (0.., leftSideList.items) |i, value| {
        const rhs = rightSideList.items[i];
        const difference: u32 = @abs(value - rhs);
        accumulator += difference;
    }

    std.debug.print("Result part 1: {}\n", .{accumulator});

    var simularityScore: i32 = 0;
    for (leftSideList.items) |value| {
        var instancesFound: i32 = 0;
        for (rightSideList.items) |rhs| {
            if (rhs == value) {
                instancesFound += 1;
            }
        }

        simularityScore += value * instancesFound;
    }

    std.debug.print("Result part 2: {}\n", .{simularityScore});

    leftSideList.clearAndFree();
    rightSideList.clearAndFree();
}
