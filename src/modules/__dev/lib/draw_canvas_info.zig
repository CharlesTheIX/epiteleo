const std = @import("std");
const rl = @import("raylib");
const _ui = @import("../../../_ui/root.zig");
const App = @import("../../../root.zig").App;

pub fn drawCanvasInfo(app: *App) void {
    const spacing: f32 = 16;
    var font = app.ui.font;
    var pos = rl.Vector2.init(spacing, spacing);
    const screen_w = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const screen_h = @as(f32, @floatFromInt(rl.getScreenHeight()));
    _ui.drawRect(.{ .rect = rl.Rectangle.init(0, 0, screen_w, screen_h), .color = rl.Color.black.alpha(0.8) });

    // Intro Text
    _ui.drawText(.{ .text = "Canvas Info:", .pos = pos, .font = font, .color = .white });
    pos.y += font.size;

    pos.y += spacing;
    font.size = spacing;

    // Camera State
    const rect_title = "Canvas | Rectangle:";
    const rect_title_width = _ui.measureText(rect_title, font);
    _ui.drawText(.{ .text = rect_title, .pos = pos, .font = font, .color = .white });
    const rect_string = std.fmt.allocPrint(
        app.allocator,
        "({d}, {d}, {d}, {d})",
        .{ app.canvas.rect.x, app.canvas.rect.y, app.canvas.rect.width, app.canvas.rect.height },
    ) catch "";
    pos.x += rect_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = rect_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    // Mouse Canvas Position
    const mouse_title = "Mouse | Canvas Position:";
    const mouse_title_width = _ui.measureText(mouse_title, font);
    const mouse_canvas_pos = rl.getScreenToWorld2D(app.input_handler.mouse.pos, app.camera.camera);
    _ui.drawText(.{ .text = mouse_title, .pos = pos, .font = font, .color = .white });
    const mouse_string = std.fmt.allocPrint(
        app.allocator,
        "({d}, {d})",
        .{ mouse_canvas_pos.x, mouse_canvas_pos.y },
    ) catch "";
    pos.x += mouse_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = mouse_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    // Selection state
    const selection_title = "Selection | Start:";
    const selection_title_width = _ui.measureText(selection_title, font);
    _ui.drawText(.{ .text = selection_title, .pos = pos, .font = font, .color = .white });
    if (app.canvas.selection.start) |start| {
        const selection_start_string = std.fmt.allocPrint(app.allocator, "({d}, {d})", .{ start.x, start.y }) catch "";
        pos.x += selection_title_width.x + @as(f32, @divFloor(spacing, 2));
        _ui.drawText(.{ .text = selection_start_string, .pos = pos, .font = font, .color = .white });
    }
    pos.x = spacing;
    pos.y += spacing;

    // Selection End
    const selection_end_title = "Selection | End:";
    const selection_end_title_width = _ui.measureText(selection_end_title, font);
    _ui.drawText(.{ .text = selection_end_title, .pos = pos, .font = font, .color = .white });
    if (app.canvas.selection.end) |end| {
        const selection_end_string = std.fmt.allocPrint(app.allocator, "({d}, {d})", .{ end.x, end.y }) catch "";
        pos.x += selection_end_title_width.x + @as(f32, @divFloor(spacing, 2));
        _ui.drawText(.{ .text = selection_end_string, .pos = pos, .font = font, .color = .white });
    }
    pos.x = spacing;
    pos.y += spacing;

    // Selection Rect
    const selection_rect_title = "Selection | Rect:";
    const selection_rect_title_width = _ui.measureText(selection_rect_title, font);
    _ui.drawText(.{ .text = selection_rect_title, .pos = pos, .font = font, .color = .white });
    if (app.canvas.selection.rect) |rect| {
        const selection_rect_string = std.fmt.allocPrint(
            app.allocator,
            "({d}, {d}, {d}, {d})",
            .{ rect.x, rect.y, rect.width, rect.height },
        ) catch "";
        pos.x += selection_rect_title_width.x + @as(f32, @divFloor(spacing, 2));
        _ui.drawText(.{ .text = selection_rect_string, .pos = pos, .font = font, .color = .white });
    }
    pos.x = spacing;
    pos.y += spacing;

    font.size = 32;
}
