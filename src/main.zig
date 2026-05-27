const std = @import("std");
const App = @import("epiteleo").App;

pub fn main(init: std.process.Init) void {
    var io = init.io;
    const allocator = std.heap.page_allocator;
    var app = App.init(allocator, &io);
    defer app.deinit();
    app.run();
    std.process.exit(0);
}
