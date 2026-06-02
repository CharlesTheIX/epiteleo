const std = @import("std");
const rl = @import("raylib");
const _ui = @import("../../_ui/root.zig");
const App = @import("../../root.zig").App;

pub fn drawMapInfo(app: *App) void {
    const spacing: f32 = 16;
    var font = app.ui.font;
    var pos = rl.Vector2.init(spacing, spacing);
    const screen_w = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const screen_h = @as(f32, @floatFromInt(rl.getScreenHeight()));
    _ui.drawRect(.{ .rect = rl.Rectangle.init(0, 0, screen_w, screen_h), .color = rl.Color.black.alpha(0.8) });

    // Intro Text
    _ui.drawText(.{ .text = "Map Info:", .pos = pos, .font = font, .color = .white });
    pos.y += font.size;

    pos.y += spacing;
    font.size = spacing;

    if (app.game) |game| {
        // Map State
        const rect_title = "Map | Rectangle:";
        const rect_title_width = _ui.measureText(rect_title, font);
        _ui.drawText(.{ .text = rect_title, .pos = pos, .font = font, .color = .white });
        var rect_buf: [96]u8 = undefined;
        const rect_string = std.fmt.bufPrint(
            &rect_buf,
            "({d}, {d}, {d}, {d})",
            .{ game.map.rect.x, game.map.rect.y, game.map.rect.width, game.map.rect.height },
        ) catch "ERR";
        pos.x += rect_title_width.x + @as(f32, @divFloor(spacing, 2));
        _ui.drawText(.{ .text = rect_string, .pos = pos, .font = font, .color = .white });
        pos.x = spacing;
        pos.y += spacing;

        // Mouse Map Position
        const mouse_title = "Mouse | Map Position:";
        const mouse_title_width = _ui.measureText(mouse_title, font);
        const mouse_map_pos = rl.getScreenToWorld2D(app.ih.mouse.pos, app.camera.camera);
        _ui.drawText(.{ .text = mouse_title, .pos = pos, .font = font, .color = .white });
        var mouse_buf: [64]u8 = undefined;
        const mouse_string = std.fmt.bufPrint(
            &mouse_buf,
            "({d}, {d})",
            .{ mouse_map_pos.x, mouse_map_pos.y },
        ) catch "ERR";
        pos.x += mouse_title_width.x + @as(f32, @divFloor(spacing, 2));
        _ui.drawText(.{ .text = mouse_string, .pos = pos, .font = font, .color = .white });
        pos.x = spacing;
        pos.y += spacing;

        // Selection state
        const selection_title = "Selection | Start:";
        const selection_title_width = _ui.measureText(selection_title, font);
        _ui.drawText(.{ .text = selection_title, .pos = pos, .font = font, .color = .white });
        if (game.map.selection.start) |start| {
            var selection_start_buf: [64]u8 = undefined;
            const selection_start_string = std.fmt.bufPrint(&selection_start_buf, "({d}, {d})", .{ start.x, start.y }) catch "ERR";
            pos.x += selection_title_width.x + @as(f32, @divFloor(spacing, 2));
            _ui.drawText(.{ .text = selection_start_string, .pos = pos, .font = font, .color = .white });
        }
        pos.x = spacing;
        pos.y += spacing;

        // Selection End
        const selection_end_title = "Selection | End:";
        const selection_end_title_width = _ui.measureText(selection_end_title, font);
        _ui.drawText(.{ .text = selection_end_title, .pos = pos, .font = font, .color = .white });
        if (game.map.selection.end) |end| {
            var selection_end_buf: [64]u8 = undefined;
            const selection_end_string = std.fmt.bufPrint(&selection_end_buf, "({d}, {d})", .{ end.x, end.y }) catch "ERR";
            pos.x += selection_end_title_width.x + @as(f32, @divFloor(spacing, 2));
            _ui.drawText(.{ .text = selection_end_string, .pos = pos, .font = font, .color = .white });
        }
        pos.x = spacing;
        pos.y += spacing;

        // Selection Rect
        const selection_rect_title = "Selection | Rect:";
        const selection_rect_title_width = _ui.measureText(selection_rect_title, font);
        _ui.drawText(.{ .text = selection_rect_title, .pos = pos, .font = font, .color = .white });
        if (game.map.selection.rect) |rect| {
            var selection_rect_buf: [96]u8 = undefined;
            const selection_rect_string = std.fmt.bufPrint(
                &selection_rect_buf,
                "({d}, {d}, {d}, {d})",
                .{ rect.x, rect.y, rect.width, rect.height },
            ) catch "ERR";
            pos.x += selection_rect_title_width.x + @as(f32, @divFloor(spacing, 2));
            _ui.drawText(.{ .text = selection_rect_string, .pos = pos, .font = font, .color = .white });
        }
        pos.x = spacing;
        pos.y += spacing;
    }

    font.size = 32;
}
