const std = @import("std");
const App = @import("epiteleo").App;

pub fn main(init: std.process.Init) void {
    var io = init.io;
    var stdout_buffer: [1024]u8 = undefined;
    const allocator = std.heap.page_allocator;
    var stdout_file_writer = std.Io.File.Writer.init(.stdout(), io, &stdout_buffer);
    var app = App.init(allocator, &io, &stdout_file_writer.interface);
    defer app.deinit();
    app.run();
    std.process.exit(0);
}
