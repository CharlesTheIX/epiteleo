const std = @import("std");
const App = @import("epiteleo").App;

pub fn main(init: std.process.Init) void {
    _ = init; // Avoid unused parameter warning
    const allocator = std.heap.page_allocator;
    var app = App.init(allocator);
    defer app.deinit();
    app.run();
    std.process.exit(0);
}
