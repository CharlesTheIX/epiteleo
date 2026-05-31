const std = @import("std");
const rl = @import("raylib");
const App = @import("../../root.zig").App;
const _ui = @import("../../_ui/root.zig");
const _ih = @import("../../_ih/root.zig");

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
    var active_keys_buf: [256]u8 = undefined;
    var active_keys_len: usize = 0;
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
        if (!first) {
            const sep = ", ";
            const sep_len = @min(sep.len, active_keys_buf.len - active_keys_len);
            @memcpy(active_keys_buf[active_keys_len .. active_keys_len + sep_len], sep[0..sep_len]);
            active_keys_len += sep_len;
        }
        const key_txt = key.toString(null);
        const key_len = @min(key_txt.len, active_keys_buf.len - active_keys_len);
        @memcpy(active_keys_buf[active_keys_len .. active_keys_len + key_len], key_txt[0..key_len]);
        active_keys_len += key_len;
        first = false;
        last_order = next_order.?;
    }
    pos.x += active_keys_title_width.x + @as(f32, @divFloor(spacing, 2));
    const active_keys_text = if (active_keys_len == 0) "None" else active_keys_buf[0..active_keys_len];
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
    var active_clicks_buf: [256]u8 = undefined;
    var active_clicks_len: usize = 0;
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
        if (!first) {
            const sep = ", ";
            const sep_len = @min(sep.len, active_clicks_buf.len - active_clicks_len);
            @memcpy(active_clicks_buf[active_clicks_len .. active_clicks_len + sep_len], sep[0..sep_len]);
            active_clicks_len += sep_len;
        }
        const click_txt = click.toString();
        const click_len = @min(click_txt.len, active_clicks_buf.len - active_clicks_len);
        @memcpy(active_clicks_buf[active_clicks_len .. active_clicks_len + click_len], click_txt[0..click_len]);
        active_clicks_len += click_len;
        first = false;
        last_order = next_order.?;
    }
    pos.x += active_clicks_title_width.x + @as(f32, @divFloor(spacing, 2));
    const active_clicks_text = if (active_clicks_len == 0) "None" else active_clicks_buf[0..active_clicks_len];
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
    var mouse_scroll_buf: [64]u8 = undefined;
    const mouse_scroll_string = std.fmt.bufPrint(
        &mouse_scroll_buf,
        "({d}, {d})",
        .{ app.ih.mouse.scroll.x, app.ih.mouse.scroll.y },
    ) catch "ERR";
    pos.x += mouse_scroll_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = mouse_scroll_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    // Mouse Position
    const mouse_pos_title = "Mouse | Position:";
    const mouse_pos_title_width = _ui.measureText(mouse_pos_title, font);
    _ui.drawText(.{ .text = mouse_pos_title, .pos = pos, .font = font, .color = .white });
    var mouse_pos_buf: [64]u8 = undefined;
    const mouse_pos_string = std.fmt.bufPrint(
        &mouse_pos_buf,
        "({d}, {d})",
        .{ app.ih.mouse.pos.x, app.ih.mouse.pos.y },
    ) catch "ERR";
    pos.x += mouse_pos_title_width.x + @as(f32, @divFloor(spacing, 2));
    _ui.drawText(.{ .text = mouse_pos_string, .pos = pos, .font = font, .color = .white });
    pos.x = spacing;
    pos.y += spacing;

    font.size = 32;
}
