const std = @import("std");
const rl = @import("raylib");
const UI = @import("../ui/root.zig").UI;
const Key = @import("./lib/keyboard.zig").Key;
const Mouse = @import("./lib/mouse.zig").Mouse;
const Click = @import("./lib/mouse.zig").Click;
const Keyboard = @import("./lib/keyboard.zig").Keyboard;

pub fn drawInfo(keyboard: *const Keyboard, mouse: *const Mouse, ui: *const UI, allocator: std.mem.Allocator) void {
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
    ui.drawText("Input Handler Info:", padding, null, rl.Color.white);
    padding.y += ui.font.size;
    padding.y += 16; // Extra spacing after title

    // Keyboard Active Keys
    const active_keys_title = "Keyboard | Active Keys:";
    const active_keys_title_width = ui.font.measureText(active_keys_title, 16);
    ui.drawText(active_keys_title, padding, 16, rl.Color.white);
    var first = true;
    var active_keys_string: std.ArrayList(u8) = .empty;
    defer active_keys_string.deinit(allocator);
    var last_order: u64 = 0;
    while (true) {
        var next_key: ?Key = null;
        var next_order: ?u64 = null;
        var active_keys = keyboard.active_keys.iterator();
        while (active_keys.next()) |entry| {
            const order = entry.value_ptr.*;
            if (order <= last_order) continue;
            if (next_order == null or order < next_order.?) {
                next_key = entry.key_ptr.*;
                next_order = order;
            }
        }
        const key = next_key orelse break;
        if (!first) active_keys_string.appendSlice(allocator, ", ") catch continue;
        active_keys_string.appendSlice(allocator, key.toString()) catch continue;
        first = false;
        last_order = next_order.?;
    }
    padding.x += active_keys_title_width.x + 8;
    const active_keys_text = if (active_keys_string.items.len == 0) "None" else active_keys_string.items;
    ui.drawText(active_keys_text, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // Keyboard Most Recent Key
    const most_recent_key_title = "Keyboard | Most Recent Key:";
    const most_recent_key_title_width = ui.font.measureText(most_recent_key_title, 16);
    ui.drawText(most_recent_key_title, padding, 16, rl.Color.white);
    padding.x += most_recent_key_title_width.x + 8;
    const most_recent_key_string = if (keyboard.getMostRecentlyPressedKey()) |key| key.toString() else "None";
    ui.drawText(most_recent_key_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    padding.y += 16; // Extra spacing before mouse info

    // Mouse Active Clicks
    const active_clicks_title = "Mouse | Active Clicks:";
    const active_clicks_title_width = ui.font.measureText(active_clicks_title, 16);
    ui.drawText(active_clicks_title, padding, 16, rl.Color.white);
    first = true;
    var active_clicks_string: std.ArrayList(u8) = .empty;
    defer active_clicks_string.deinit(allocator);
    last_order = 0;
    while (true) {
        var next_click: ?Click = null;
        var next_order: ?u64 = null;
        var active_clicks = mouse.active_clicks.iterator();
        while (active_clicks.next()) |entry| {
            const order = entry.value_ptr.*;
            if (order <= last_order) continue;
            if (next_order == null or order < next_order.?) {
                next_click = entry.key_ptr.*;
                next_order = order;
            }
        }
        const click = next_click orelse break;
        if (!first) active_clicks_string.appendSlice(allocator, ", ") catch continue;
        active_clicks_string.appendSlice(allocator, click.toString()) catch continue;
        first = false;
        last_order = next_order.?;
    }
    padding.x += active_clicks_title_width.x + 8;
    const active_clicks_text = if (active_clicks_string.items.len == 0) "None" else active_clicks_string.items;
    ui.drawText(active_clicks_text, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // Mouse Most Recent Click
    const most_recent_click_title = "Mouse | Most Recent Click:";
    const most_recent_click_title_width = ui.font.measureText(most_recent_click_title, 16);
    ui.drawText(most_recent_click_title, padding, 16, rl.Color.white);
    const most_recent_click_string = if (mouse.getMostRecentlyPressedClick()) |click| click.toString() else "None";
    padding.x += most_recent_click_title_width.x + 8;
    ui.drawText(most_recent_click_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // Mouse Cursor
    const cursor_title = "Mouse | Cursor:";
    const cursor_title_width = ui.font.measureText(cursor_title, 16);
    ui.drawText(cursor_title, padding, 16, rl.Color.white);
    const cursor_string = mouse.cursor.toString();
    padding.x += cursor_title_width.x + 8;
    ui.drawText(cursor_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // Mouse Scroll
    const mouse_scroll_title = "Mouse | Scroll:";
    const mouse_scroll_title_width = ui.font.measureText(mouse_scroll_title, 16);
    ui.drawText(mouse_scroll_title, padding, 16, rl.Color.white);
    const mouse_scroll_string = std.fmt.allocPrint(
        allocator,
        "({d}, {d})",
        .{ mouse.scroll.x, mouse.scroll.y },
    ) catch "Error formatting mouse scroll";
    padding.x += mouse_scroll_title_width.x + 8;
    ui.drawText(mouse_scroll_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;

    // Mouse Window Position
    const mouse_window_pos_title = "Mouse | Window Position:";
    const mouse_window_pos_title_width = ui.font.measureText(mouse_window_pos_title, 16);
    ui.drawText(mouse_window_pos_title, padding, 16, rl.Color.white);
    const mouse_window_pos_string = std.fmt.allocPrint(
        allocator,
        "({d}, {d})",
        .{ mouse.pos.x, mouse.pos.y },
    ) catch "Error formatting mouse position";
    padding.x += mouse_window_pos_title_width.x + 8;
    ui.drawText(mouse_window_pos_string, padding, 16, rl.Color.white);
    padding.x = 16;
    padding.y += 16;
}
