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

    // Create list of reports
    var listOfReports = std.ArrayList([]i32).init(allocator);
    defer {
        // Free all reports then deinit report list
        for (listOfReports.items) |item| {
            allocator.free(item);
        }
        listOfReports.deinit();
    }

    //Itterate over buffer, parse values and append to lists
    var lines = std.mem.splitSequence(u8, buffer, "\r\n");
    while (lines.next()) |line| {

        // Create report array list
        var reportElements = std.ArrayList(i32).init(allocator);
        defer reportElements.deinit();

        // Itterate over tokens
        var elements = std.mem.tokenizeScalar(u8, line, ' ');
        while (elements.next()) |tok| {
            // Patse token and add to report
            const val = try std.fmt.parseInt(i32, tok, 10);
            try reportElements.append(val);
        }

        // Take ownership of report
        const report = try reportElements.toOwnedSlice();

        // Append to list of reports
        try listOfReports.append(report);
    }

    var safeReportCount: i32 = 0;
    for (listOfReports.items) |report| {
        if (CheckReportSafety(report)) {
            safeReportCount += 1;
        }
    }

    std.debug.print("Part 1 Result: {}\n", .{safeReportCount});

    var safeReportCount2: i32 = 0;
    for (listOfReports.items) |report| {
        // Check report
        if (CheckReportSafety(report)) {
            safeReportCount2 += 1;
            continue;
        }

        // Try mutation report by removing one element.
        for (0..report.len) |i| {
            var newReport = std.ArrayList(i32).init(allocator);
            defer newReport.deinit();
            // Copy the report leaving out the item at index 'i'
            for (0.., report) |j, val| {
                if (i == j) {
                    continue;
                }

                try newReport.append(val);
            }

            // Test report
            if (CheckReportSafety(newReport.items)) {
                safeReportCount2 += 1;
                break;
            }
        }
    }

    std.debug.print("Part 2 Result: {}\n", .{safeReportCount2});
}

fn CheckReportSafety(report: []i32) bool {
    var ascending = false;
    var safe = true;

    // Look at first 2 values to work out if we should be ascending or decending
    if (report[0] < report[1]) {
        ascending = true;
    } else if (report[0] > report[1]) {
        ascending = false;
    } else {
        return false;
    }

    // Make sure all elements follow the rules
    var lastVal: i32 = 0;
    for (0.., report) |i, val| {
        if (i == 0) {
            lastVal = val;
            continue;
        }

        // Check that we are following the ascending/decending rule
        if (ascending) {
            if (lastVal > val) {
                safe = false;
                break;
            }
        } else {
            if (lastVal < val) {
                safe = false;
                break;
            }
        }

        // Check difference is between 1-3
        if (@abs(lastVal - val) > 3 or @abs(lastVal - val) == 0) {
            safe = false;
            break;
        }

        lastVal = val;
    }

    return safe;
}
