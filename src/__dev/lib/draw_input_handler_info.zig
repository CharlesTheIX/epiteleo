const std = @import("std");
const rl = @import("raylib");
const App = @import("../../root.zig").App;
const _ui = @import("../../_ui/root.zig");
const _ih = @import("../../modules/input_handler/root.zig");

pub fn drawInputHandlerInfo(app: *App) void {
    const spacing: f32 = 16;
    var font = app.ui.font;
    var pos = rl.Vector2.init(spacing, spacing);
    const screen_w = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const screen_h = @as(f32, @floatFromInt(rl.getScreenHeight()));
    _ui.drawRect(.{ .rect = .init(0, 0, screen_w, screen_h), .color = rl.Color.black.alpha(0.8) });

    // Intro Text
    _ui.drawText(.{ .text = "Input Handler Info:", .pos = pos, .font = font, .color = .white });
    pos.y += font.size;

    pos.y += spacing;
    font.size = spacing;

    // Keyboard Active Keys
    const active_keys_title = "Keyboard | Active Keys:";
    const active_keys_title_width = _ui.measureText(active_keys_title, font);
    _ui.drawText(.{ .text = active_keys_title, .pos = pos, .font = font, .color = .white });
    var first = true;
    var active_keys_string: std.ArrayList(u8) = .empty;
    defer active_keys_string.deinit(app.allocator);
    var last_order: u64 = 0;
    while (true) {
        var next_key: ?_ih.Key = null;
        var next_order: ?u64 = null;
        var active_keys = app.ih.keyboard.active_keys.iterator();
        while (active_keys.next()) |entry| {
            const order = entry.value_ptr.*;
            if (order <= last_order) continue;
            if (next_order == null or order < next_order.?) {
                next_key = entry.key_ptr.*;
                next_order = order;
            }
        }
        const key = next_key orelse break;
        if (!first) active_keys_string.appendSlice(app.allocator, ", ") catch continue;
        active_keys_string.appendSlice(app.allocator, key.toString(null)) catch continue;
        first = false;
        last_order = next_order.?;
    }
    pos.x += active_keys_title_width.x + @as(f32, @divFloor(spacing, 2));
    const active_keys_text = if (active_keys_string.items.len == 0) "None" else active_keys_string.items;
    _ui.drawText(.{ .text = active_keys_text, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    // Keyboard Most Recent Key
    const most_recent_key_title = "Keyboard | Most Recent Key:";
    const most_recent_key_title_width = _ui.measureText(most_recent_key_title, font);
    _ui.drawText(.{ .text = most_recent_key_title, .pos = pos, .font = font, .color = .white });
    pos.x += most_recent_key_title_width.x + @as(f32, @divFloor(spacing, 2));
    const most_recent_key_string = if (app.ih.keyboard.mostRecentActiveKey()) |key| key.toString(null) else "None";
    _ui.drawText(.{ .text = most_recent_key_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    pos.y += spacing;

    // Mouse Active Clicks
    const active_clicks_title = "Mouse | Active Clicks:";
    const active_clicks_title_width = _ui.measureText(active_clicks_title, font);
    _ui.drawText(.{ .text = active_clicks_title, .pos = pos, .font = font, .color = .white });
    first = true;
    var active_clicks_string: std.ArrayList(u8) = .empty;
    defer active_clicks_string.deinit(app.allocator);
    last_order = 0;
    while (true) {
        var next_order: ?u64 = null;
        var next_click: ?_ih.Click = null;
        var active_clicks = app.ih.mouse.active_clicks.iterator();
        while (active_clicks.next()) |entry| {
            const order = entry.value_ptr.*;
            if (order <= last_order) continue;
            if (next_order == null or order < next_order.?) {
                next_click = entry.key_ptr.*;
                next_order = order;
            }
        }
        const click = next_click orelse break;
        if (!first) active_clicks_string.appendSlice(app.allocator, ", ") catch continue;
        active_clicks_string.appendSlice(app.allocator, click.toString()) catch continue;
        first = false;
        last_order = next_order.?;
    }
    pos.x += active_clicks_title_width.x + @as(f32, @divFloor(spacing, 2));
    const active_clicks_text = if (active_clicks_string.items.len == 0) "None" else active_clicks_string.items;
    _ui.drawText(.{ .text = active_clicks_text, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    // Mouse Most Recent Click
    const most_recent_click_title = "Mouse | Most Recent Click:";
    const most_recent_click_title_width = _ui.measureText(most_recent_click_title, font);
    _ui.drawText(.{ .text = most_recent_click_title, .pos = pos, .font = font, .color = .white });
    const most_recent_click_string = if (app.ih.mouse.getMostRecentlyPressedClick()) |click| click.toString() else "None";
    pos.x += most_recent_click_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = most_recent_click_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    // Mouse Cursor
    const cursor_title = "Mouse | Cursor:";
    const cursor_title_width = _ui.measureText(cursor_title, font);
    _ui.drawText(.{ .text = cursor_title, .pos = pos, .font = font, .color = .white });
    const cursor_string = app.ih.mouse.cursor.toString();
    pos.x += cursor_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = cursor_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    // Mouse Scroll
    const mouse_scroll_title = "Mouse | Scroll:";
    const mouse_scroll_title_width = _ui.measureText(mouse_scroll_title, font);
    _ui.drawText(.{ .text = mouse_scroll_title, .pos = pos, .font = font, .color = .white });
    const mouse_scroll_string = std.fmt.allocPrint(
        app.allocator,
        "({d}, {d})",
        .{ app.ih.mouse.scroll.x, app.ih.mouse.scroll.y },
    ) catch "Error formatting mouse scroll";
    pos.x += mouse_scroll_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = mouse_scroll_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    // Mouse Position
    const mouse_pos_title = "Mouse | Position:";
    const mouse_pos_title_width = _ui.measureText(mouse_pos_title, font);
    _ui.drawText(.{ .text = mouse_pos_title, .pos = pos, .font = font, .color = .white });
    const mouse_pos_string = std.fmt.allocPrint(
        app.allocator,
        "({d}, {d})",
        .{ app.ih.mouse.pos.x, app.ih.mouse.pos.y },
    ) catch "Error formatting mouse position";
    pos.x += mouse_pos_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = mouse_pos_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    font.size = 32;
}
