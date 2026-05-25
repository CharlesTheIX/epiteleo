const std = @import("std");
const rl = @import("raylib");
const App = @import("../root.zig").App;
const UI = @import("../modules/ui/root.zig").UI;

pub const AppState = enum {
    Init,
    Intro,
    Playing,
    Settings,

    pub fn toString(self: AppState) []const u8 {
        return switch (self) {
            .Init => "Init",
            .Intro => "Intro",
            .Playing => "Playing",
            .Settings => "Settings",
        };
    }
};

pub fn drawInfo(app: *const App, allocator: std.mem.Allocator) void {
    // Set initial padding and spacing
    var padding = rl.Vector2.init(16, 16);

    // Background
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
    const is_loading_string = if (app.loading_screen.loading) "True" else "False";
    padding.x += is_loading_title_width.x + 8;
    app.ui.drawText(is_loading_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // FPS
    const fps_title = "App | FPS:";
    const fps_title_width = app.ui.font.measureText(fps_title, 16);
    app.ui.drawText(fps_title, padding, 16, rl.Color.white);
    const fps_string = std.fmt.allocPrint(allocator, "{d}", .{rl.getFPS()}) catch "";
    padding.x += fps_title_width.x + 8;
    app.ui.drawText(fps_string, padding, 16, rl.Color.white);
}

pub fn invertScroll(scroll: *rl.Vector2) rl.Vector2 {
    return rl.Vector2{ .x = scroll.x * -1, .y = scroll.y * -1 };
}

pub fn rotateVector(v: rl.Vector2, angle_degrees: f32) rl.Vector2 {
    const angle_radians = angle_degrees * std.math.pi / 180.0;
    const cos_a = @cos(angle_radians);
    const sin_a = @sin(angle_radians);
    return .{
        .x = v.x * cos_a - v.y * sin_a,
        .y = v.x * sin_a + v.y * cos_a,
    };
}
