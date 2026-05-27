const std = @import("std");
const rl = @import("raylib");
const UI = @import("../root.zig").UI;

pub const TextInput = struct {
    ui: *UI,
    len: usize = 0,
    cursor_position: usize = 0,
    rect: rl.Rectangle,
    focused: bool = false,
    buffer: [256]u8 = undefined,
    padding: rl.Rectangle = .init(0, 0, 0, 0),

    pub fn init(ui: *UI, rect: rl.Rectangle, content: ?[]const u8, padding: ?rl.Rectangle) TextInput {
        var text_input = TextInput{ .rect = rect, .ui = ui };
        text_input.buffer = undefined;
        if (padding) |p| text_input.padding = p;
        if (content) |c| {
            const len = @min(c.len, text_input.buffer.len - 1);
            @memcpy(text_input.buffer[0..len], c[0..len]);
            text_input.len = len;
            text_input.cursor_position = len;
        }
        return text_input;
    }

    pub fn deinit(self: *TextInput) void {
        self.len = 0;
        self.cursor_position = 0;
        self.focused = false;
        self.buffer = undefined;
    }

    pub fn focus(self: *TextInput) void {
        self.focused = true;
    }

    pub fn blur(self: *TextInput) void {
        self.focused = false;
    }

    pub fn getText(self: TextInput) []const u8 {
        return self.buffer[0..self.len];
    }

    pub fn asStr(self: TextInput) []const u8 {
        return self.getText();
    }

    pub fn clear(self: *TextInput) void {
        self.cursor_position = 0;
        self.len = 0;
    }

    fn writtenLen(self: *TextInput) usize {
        return self.len;
    }

    fn insertChar(self: *TextInput, index: usize, c: u8) void {
        const len = self.writtenLen();
        if (len >= self.buffer.len - 1 or index > len) return;

        std.mem.copyBackwards(u8, self.buffer[index + 1 .. len + 1], self.buffer[index..len]);
        self.buffer[index] = c;
        self.len = len + 1;
    }

    fn removeChar(self: *TextInput, index: usize) void {
        const len = self.writtenLen();
        if (index >= len) return;

        if (index + 1 < len) {
            std.mem.copyForwards(u8, self.buffer[index .. len - 1], self.buffer[index + 1 .. len]);
        }
        self.len = len - 1;
    }

    pub fn draw(self: TextInput) void {
        const text = self.asStr();
        var border_color = rl.Color.gray.alpha(0.5);
        if (self.focused) border_color = rl.Color.blue.alpha(0.8);
        self.ui.drawRect(self.rect, rl.Color.white.alpha(0.5));
        rl.drawRectangleLinesEx(self.rect, 4, border_color);
        const pos = rl.Vector2{ .x = self.rect.x + self.padding.x, .y = self.rect.y + self.padding.y };
        self.ui.drawText(text, pos, null, rl.Color.black);

        if (self.focused) {
            const cursor_y1 = pos.y;
            const cursor_y2 = pos.y + @as(f32, @floatFromInt(self.ui.font.size));
            var cursor_x_buf: [257:0]u8 = undefined;
            @memcpy(cursor_x_buf[0..self.cursor_position], self.buffer[0..self.cursor_position]);
            cursor_x_buf[self.cursor_position] = 0;
            const cursor_width = self.ui.font.measureText(cursor_x_buf[0..self.cursor_position :0], self.ui.font.size).x;
            const cursor_x = pos.x + cursor_width;

            const time = rl.getTime();
            const blink_state = @mod(time * 2.0, 1.0) < 0.4;
            if (blink_state) {
                rl.drawLine(
                    @intFromFloat(cursor_x),
                    @intFromFloat(cursor_y1),
                    @intFromFloat(cursor_x),
                    @intFromFloat(cursor_y2),
                    rl.Color.black,
                );
            }
        }
    }

    pub fn update(self: *TextInput) void {
        if (!self.focused) return;
        var char_code = rl.getCharPressed();
        while (char_code > 0) : (char_code = rl.getCharPressed()) {
            if (char_code < 32 or char_code > 126) continue;
            const char_byte: u8 = @intCast(char_code);
            const before = self.writtenLen();
            self.insertChar(self.cursor_position, char_byte);
            if (self.writtenLen() > before) self.cursor_position += 1;
        }

        if (rl.isKeyPressed(rl.KeyboardKey.backspace)) {
            if (self.cursor_position > 0) {
                self.cursor_position -= 1;
                self.removeChar(self.cursor_position);
            }
        }

        if (rl.isKeyPressed(rl.KeyboardKey.delete)) {
            if (self.cursor_position < self.writtenLen()) self.removeChar(self.cursor_position);
        }

        if (rl.isKeyPressed(rl.KeyboardKey.left)) {
            if (self.cursor_position > 0) self.cursor_position -= 1;
        }

        if (rl.isKeyPressed(rl.KeyboardKey.right)) {
            if (self.cursor_position < self.writtenLen()) self.cursor_position += 1;
        }
    }
};
