const std = @import("std");
const rl = @import("raylib");
const _ui = @import("../../../_ui/root.zig");
const App = @import("../../../root.zig").App;

pub fn drawAppInfo(app: *App) void {
    var font = app.ui.font;
    const spacing: f32 = 16;
    var pos = rl.Vector2.init(spacing, spacing);
    const screen_w = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const screen_h = @as(f32, @floatFromInt(rl.getScreenHeight()));
    _ui.drawRect(.{ .color = rl.Color.black.alpha(0.8), .rect = .init(0, 0, screen_w, screen_h) });

    // Intro Text
    _ui.drawText(.{ .text = "App Info:", .pos = pos, .color = .white });
    pos.y += font.size;

    pos.y += spacing;
    font.size = spacing;

    // State
    const state_title = "App | State:";
    _ui.drawText(.{ .text = state_title, .pos = pos, .font = font, .color = .white });
    pos.x += _ui.measureText(state_title, font).x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = app.state.toString(), .pos = pos, .font = font, .color = .white });

    pos.x = spacing;
    pos.y += spacing;

    // Is Loading
    const is_loading_title = "App | Is Loading:";
    _ui.drawText(.{ .text = is_loading_title, .pos = pos, .font = font, .color = .white });
    pos.x += _ui.measureText(is_loading_title, null).x + @as(f32, @divFloor(spacing, 2));
    const is_loading_string = if (app.loader.loading) "True" else "False";
    _ui.drawText(.{ .text = is_loading_string, .pos = pos, .font = font, .color = .white });

    pos.x = spacing;
    pos.y += spacing;

    // FPS
    const fps_title = "App | FPS:";
    _ui.drawText(.{ .text = fps_title, .pos = pos, .font = font, .color = .white });
    pos.x += _ui.measureText(fps_title, null).x + @as(f32, @divFloor(spacing, 2));
    const fps_string = std.fmt.allocPrint(app.allocator, "{d}", .{rl.getFPS()}) catch "";
    _ui.drawText(.{ .text = fps_string, .pos = pos, .font = font, .color = .white });
}
