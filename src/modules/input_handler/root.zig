const std = @import("std");
const rl = @import("raylib");
const UI = @import("../ui/root.zig").UI;
const Key = @import("lib/keyboard.zig").Key;
const Mouse = @import("lib/mouse.zig").Mouse;
const Keyboard = @import("lib/keyboard.zig").Keyboard;

pub const InputHandler = struct {
    mouse: Mouse,
    keyboard: Keyboard,

    pub fn init(allocator: std.mem.Allocator) InputHandler {
        const mouse = Mouse.init(allocator);
        const keyboard = Keyboard.init(allocator);
        return InputHandler{ .mouse = mouse, .keyboard = keyboard };
    }

    pub fn deinit(self: *InputHandler) void {
        self.mouse.deinit();
        self.keyboard.deinit();
    }

    pub fn load(self: *InputHandler) void {
        _ = self; // Avoid unused parameter warning
    }

    pub fn update(self: *InputHandler) void {
        self.mouse.update();
        self.keyboard.update();
    }

    // ********************************************************************************************
    // DEV ITEMS
    // ********************************************************************************************

    pub fn drawInfo(self: InputHandler, ui: UI, allocator: std.mem.Allocator) void {
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
        padding.y += 8;

        // Keyboard Active Keys
        const active_keys_title = "Keyboard | Active Keys:";
        const active_keys_title_width = ui.font.measureText(active_keys_title, 16);
        ui.drawText(active_keys_title, padding, 16, rl.Color.white);
        var first = true;
        var active_keys_string: std.ArrayList(u8) = .empty;
        defer active_keys_string.deinit(allocator);
        var active_keys = self.keyboard.active_keys.keyIterator();
        while (active_keys.next()) |key| {
            if (!first) active_keys_string.appendSlice(allocator, ", ") catch continue;
            active_keys_string.appendSlice(allocator, key.toString()) catch continue;
            first = false;
        }
        padding.x += active_keys_title_width.x + 8;
        const active_keys_text = if (active_keys_string.items.len == 0) "None" else active_keys_string.items;
        ui.drawText(active_keys_text, padding, 16, rl.Color.white);
        padding.x = 16;
        padding.y += 16;

        // Keyboard Key Press Order
        const key_press_order_title = "Keyboard | Key Press Order:";
        const key_press_order_title_width = ui.font.measureText(key_press_order_title, 16);
        ui.drawText(key_press_order_title, padding, 16, rl.Color.white);
        first = true;
        var key_press_order_string: std.ArrayList(u8) = .empty;
        defer key_press_order_string.deinit(allocator);
        var last_order: u64 = 0;
        while (true) {
            var next_key: ?Key = null;
            var next_order: ?u64 = null;
            var key_press_order = self.keyboard.key_press_order.iterator();
            while (key_press_order.next()) |entry| {
                const order = entry.value_ptr.*;
                if (order <= last_order) continue;
                if (next_order == null or order < next_order.?) {
                    next_key = entry.key_ptr.*;
                    next_order = order;
                }
            }

            const key = next_key orelse break;
            if (!first) key_press_order_string.appendSlice(allocator, ", ") catch continue;
            key_press_order_string.appendSlice(allocator, key.toString()) catch continue;
            first = false;
            last_order = next_order.?;
        }
        padding.x += key_press_order_title_width.x + 8;
        const key_press_order_text = if (key_press_order_string.items.len == 0) "None" else key_press_order_string.items;
        ui.drawText(key_press_order_text, padding, 16, rl.Color.white);
        padding.x = 16;
        padding.y += 16;
    }
};
