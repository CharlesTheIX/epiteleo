const std = @import("std");
const rl = @import("raylib");
const UI = @import("../root.zig").UI;

pub const TextInput = struct {
    ui: *UI,
    rect: rl.Rectangle,
    focused: bool = false,
    writer: std.Io.Writer,
    cursor_position: usize = 0,
    buffer: [256]u8 = undefined,
    padding: rl.Rectangle = .init(0, 0, 0, 0),

    fn rebindWriter(self: *TextInput) void {
        const end = self.writer.end;
        self.writer = std.Io.Writer.fixed(&self.buffer);
        self.writer.end = @min(end, self.buffer.len - 1);
    }

    pub fn init(ui: *UI, rect: rl.Rectangle, content: ?[]const u8, padding: ?rl.Rectangle) TextInput {
        var text_input: TextInput = undefined;
        text_input.ui = ui;
        text_input.rect = rect;
        text_input.focused = false;
        text_input.buffer = undefined;
        text_input.cursor_position = 0;
        text_input.padding = .init(0, 0, 0, 0);
        if (padding) |p| text_input.padding = p;
        text_input.writer = std.Io.Writer.fixed(&text_input.buffer);
        text_input.writer.end = 0;
        if (content) |c| {
            const len = @min(c.len, text_input.buffer.len - 1);
            @memcpy(text_input.buffer[0..len], c[0..len]);
            text_input.writer.end = len;
            text_input.cursor_position = len;
        }
        return text_input;
    }

    pub fn deinit(self: *TextInput) void {
        self.rebindWriter();
        self.writer.end = 0;
        self.focused = false;
        self.buffer = undefined;
        self.cursor_position = 0;
    }

    pub fn focus(self: *TextInput) void {
        self.focused = true;
    }

    pub fn blur(self: *TextInput) void {
        self.focused = false;
    }

    pub fn getText(self: *TextInput) []const u8 {
        self.rebindWriter();
        return self.buffer[0..self.writer.end];
    }

    pub fn clear(self: *TextInput) void {
        self.rebindWriter();
        self.cursor_position = 0;
        self.writer.end = 0;
    }

    fn writtenLen(self: *TextInput) usize {
        self.rebindWriter();
        return self.writer.end;
    }

    fn insertChar(self: *TextInput, index: usize, c: u8) void {
        const len = self.writtenLen();
        if (len >= self.buffer.len - 1 or index > len) return;
        std.mem.copyBackwards(u8, self.buffer[index + 1 .. len + 1], self.buffer[index..len]);
        self.buffer[index] = c;
        self.writer.end = len + 1;
    }

    fn removeChar(self: *TextInput, index: usize) void {
        const len = self.writtenLen();
        if (index >= len) return;
        if (index + 1 < len) {
            std.mem.copyForwards(u8, self.buffer[index .. len - 1], self.buffer[index + 1 .. len]);
        }
        self.writer.end = len - 1;
    }

    pub fn draw(self: *TextInput) void {
        self.rebindWriter();
        const text = self.getText();
        var border_color = rl.Color.gray.alpha(0.5);
        if (self.focused) border_color = rl.Color.blue.alpha(0.8);
        self.ui.drawRect(self.rect, rl.Color.white.alpha(0.5));
        rl.drawRectangleLinesEx(self.rect, 4, border_color);
        const pos = rl.Vector2{ .x = self.rect.x + self.padding.x, .y = self.rect.y + self.padding.y };
        const text_z = self.ui.allocator.dupeZ(u8, text) catch return;
        defer self.ui.allocator.free(text_z);
        if (self.ui.font.custom) |font| {
            rl.drawTextEx(font, text_z, pos, @as(f32, @floatFromInt(self.ui.font.size)), 0, rl.Color.black);
        } else {
            rl.drawText(text_z, @intFromFloat(pos.x), @intFromFloat(pos.y), self.ui.font.size, rl.Color.black);
        }
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
        self.rebindWriter();
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
