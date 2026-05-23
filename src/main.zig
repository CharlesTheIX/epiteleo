const Io = std.Io;
const std = @import("std");
const App = @import("epiteleo").App;

pub fn main(init: std.process.Init) !void {
    _ = init; // Avoid unused parameter warning
    // var io = init.io;
    // var env = init.minimal.environ;
    // var stdin_buffer: [1024]u8 = undefined;
    // var stdout_buffer: [1024]u8 = undefined;
    // var stdin_file_reader = std.Io.File.Reader.init(.stdin(), io, &stdin_buffer);
    // var stdout_file_writer = std.Io.File.Writer.init(.stdout(), io, &stdout_buffer);
    // const app_core: AppCore = .{
    //     .io = &io,
    //     .env = &env,
    //     .allocator = std.heap.page_allocator,
    //     .reader = &stdin_file_reader.interface,
    //     .writer = &stdout_file_writer.interface,
    // };

    const allocator = std.heap.page_allocator;
    var app = App.init(allocator);
    defer app.deinit();
    // var args = init.minimal.args.iterate();
    // defer args.deinit();
    // _ = args.next(); // Skip the executable name
    app.run();
    std.process.exit(0);
}
