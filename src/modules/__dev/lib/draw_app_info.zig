const std = @import("std");
const rl = @import("raylib");
const App = @import("../../../root.zig").App;

pub fn drawAppInfo(app: *App) void {
    var padding = rl.Vector2.init(16, 16);
    app.ui.drawRect(
        rl.Rectangle.init(
            0,
            0,
            @as(f32, @floatFromInt(rl.getScreenWidth())),
            @as(f32, @floatFromInt(rl.getScreenHeight())),
        ),
        rl.Color.black.alpha(0.8),
    );

    // Intro Text
    app.ui.drawText("App Info:", padding, null, rl.Color.white);
    padding.y += app.ui.font.size;
    padding.y += 16; // Extra spacing after title

    // State
    const state_title = "App | State:";
    const state_title_width = app.ui.font.measureText(state_title, 16);
    app.ui.drawText(state_title, padding, 16, rl.Color.white);
    const state_string = app.state.toString();
    padding.x += state_title_width.x + 8;
    app.ui.drawText(state_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // Is Loading
    const is_loading_title = "App | Is Loading:";
    const is_loading_title_width = app.ui.font.measureText(is_loading_title, 16);
    app.ui.drawText(is_loading_title, padding, 16, rl.Color.white);
    const is_loading_string = if (app.loader.loading) "True" else "False";
    padding.x += is_loading_title_width.x + 8;
    app.ui.drawText(is_loading_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // FPS
    const fps_title = "App | FPS:";
    const fps_title_width = app.ui.font.measureText(fps_title, 16);
    app.ui.drawText(fps_title, padding, 16, rl.Color.white);
    const fps_string = std.fmt.allocPrint(app.allocator, "{d}", .{rl.getFPS()}) catch "";
    padding.x += fps_title_width.x + 8;
    app.ui.drawText(fps_string, padding, 16, rl.Color.white);
}
