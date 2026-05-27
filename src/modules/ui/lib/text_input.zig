const rl = @import("raylib");
const UI = @import("../root.zig").UI;

pub const TextInput = struct {
    ui: *UI,
    len: usize = 0,
    rect: rl.Rectangle,
    focused: bool = false,
    buffer: [256]u8 = undefined,
    padding: rl.Rectangle = .init(0, 0, 0, 0),

    pub fn init(ui: *UI, rect: rl.Rectangle, content: ?[]const u8, padding: ?rl.Rectangle) TextInput {
        var text_input = TextInput{ .rect = rect, .ui = ui };
        if (padding) |p| text_input.padding = p;
        if (content) |c| {
            const len = @min(c.len, text_input.buffer.len - 1);
            @memcpy(text_input.buffer[0..len], c[0..len]);
            text_input.len = len;
        }
        return text_input;
    }

    pub fn deinit(self: *TextInput) void {
        self.len = 0;
        self.focused = false;
        self.buffer = undefined;
    }

    pub fn asStr(self: TextInput) []const u8 {
        return self.buffer[0..self.len];
    }

    pub fn draw(self: TextInput) void {
        const text = self.asStr();
        var border_color = rl.Color.gray.alpha(0.5);
        if (self.focused) border_color = rl.Color.blue.alpha(0.8);
        self.ui.drawRect(self.rect, rl.Color.white.alpha(0.5));
        rl.drawRectangleLinesEx(self.rect, 4, border_color);
        const pos = rl.Vector2{ .x = self.rect.x + self.padding.x, .y = self.rect.y + self.padding.y };
        self.ui.drawText(text, pos, null, rl.Color.black);
    }

    pub fn update(self: *TextInput) void {
        if (!self.focused) return;
        if ((rl.isKeyPressed(rl.KeyboardKey.backspace) or rl.isKeyPressedRepeat(rl.KeyboardKey.backspace)) and self.len > 0) {
            self.len -= 1;
            return;
        }

        var char = rl.getCharPressed();
        while (char > 0) : (char = rl.getCharPressed()) {
            if (char < 32 or char > 126) continue;
            if (self.len >= self.buffer.len - 1) continue;
            self.buffer[self.len] = @as(u8, @intCast(char));
            self.len += 1;
        }
    }
};
