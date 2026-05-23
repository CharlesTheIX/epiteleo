const std = @import("std");
const rl = @import("raylib");
const UI = @import("./modules/ui/root.zig").UI;

pub const AppState = enum {
    Intro,
    Loading,
    Playing,
    Settings,
};

pub fn drawInfo(state: *const AppState, ui: *UI) void {
    // Set initial padding and spacing
    var padding = rl.Vector2.init(16, 16);

    // Background
    ui.drawRect(
        rl.Rectangle.init(
            0,
            0,
            @as(f32, @floatFromInt(rl.getScreenWidth())),
            @as(f32, @floatFromInt(rl.getScreenHeight())),
        ),
        rl.Color.black.alpha(0.8),
    );

    // Intro Text
    ui.drawText("App Info:", padding, null, rl.Color.white);
    padding.y += ui.font.size;
    padding.y += 16; // Extra spacing after title

    // State
    const state_title = "App | State:";
    const state_title_width = ui.font.measureText(state_title, 16);
    ui.drawText(state_title, padding, 16, rl.Color.white);
    const state_string = state.toString();
    padding.x += state_title_width.x + 8;
    ui.drawText(state_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;
}
