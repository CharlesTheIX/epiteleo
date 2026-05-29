const std = @import("std");
const rl = @import("raylib");
const d = @import("../draw.zig");
const Font = @import("../font.zig").Font;
const measureText = @import("../font.zig").measureText;

pub const TextBoxProps = struct {
    content: []const u8 = "",
    rect: rl.Rectangle = .init(0, 0, 0, 0),
    padding: rl.Rectangle = .init(0, 0, 0, 0),
};

pub const TextBox = struct {
    rect: rl.Rectangle,
    content: []const u8,
    padding: rl.Rectangle,

    pub fn init(props: TextBoxProps) TextBox {
        return .{ .content = props.content, .rect = props.rect, .padding = props.padding };
    }

    pub fn deinit(self: *TextBox) void {
        _ = self;
    }

    fn measureTextWidth(self: *TextBox, text: []const u8, font: *Font) f32 {
        var buffer: [1024]u8 = undefined;
        if (text.len + 1 > buffer.len) return self.rect.width + 1;
        @memcpy(buffer[0..text.len], text);
        buffer[text.len] = 0;
        const txt: [:0]const u8 = buffer[0..text.len :0];
        return measureText(txt, font.*).x;
    }

    pub fn draw(self: *TextBox, fnt: *Font, pos: *rl.Vector2) void {
        var font = fnt.*;
        font.size = 24;
        font.line_height = 28;
        const rect: rl.Rectangle = .init(self.rect.x + pos.x, self.rect.y + pos.y, self.rect.width, self.rect.height);
        d.drawRect(.{ .rect = rect, .color = rl.Color.white.alpha(0.5) });
        const text_pos = rl.Vector2{ .x = rect.x + self.padding.x, .y = rect.y + self.padding.y };
        const content_width = rect.width - self.padding.x - self.padding.width;
        const content_height = rect.height - self.padding.y - self.padding.height;
        if (content_width <= 0 or content_height <= 0) return;

        const line_step = @as(f32, @floatFromInt(font.line_height));
        const max_lines_by_height: usize = @intFromFloat(@floor(content_height / line_step));
        if (max_lines_by_height == 0) return;

        var index: usize = 0;
        var line_count: usize = 0;
        var lines: [256][]const u8 = undefined;
        while (index < self.content.len and line_count < lines.len and line_count < max_lines_by_height) {
            if (self.content[index] == '\n') {
                lines[line_count] = "";
                line_count += 1;
                index += 1;
                continue;
            }

            var scan = index;
            var wrapped = false;
            var line_end = index;
            var last_space: ?usize = null;
            const line_start = index;
            while (scan < self.content.len and self.content[scan] != '\n') : (scan += 1) {
                if (self.content[scan] == ' ' or self.content[scan] == '\t') last_space = scan;
                const candidate_end = scan + 1;
                const candidate = self.content[line_start..candidate_end];

                if (self.measureTextWidth(candidate, &font) > content_width) {
                    wrapped = true;
                    if (last_space) |space_index| {
                        if (space_index > line_start) {
                            line_end = space_index;
                            index = space_index + 1;
                            while (index < self.content.len and (self.content[index] == ' ' or self.content[index] == '\t')) : (index += 1) {}
                        } else {
                            index = candidate_end;
                            line_end = candidate_end;
                        }
                    } else if (candidate_end > line_start + 1) {
                        index = candidate_end - 1;
                        line_end = candidate_end - 1;
                    } else {
                        index = candidate_end;
                        line_end = candidate_end;
                    }
                    break;
                }
                line_end = candidate_end;
            }

            if (!wrapped) {
                if (scan < self.content.len and self.content[scan] == '\n') {
                    line_end = scan;
                    index = scan + 1;
                } else index = line_end;
            }

            const line = std.mem.trim(u8, self.content[line_start..line_end], " \t");
            lines[line_count] = line;
            line_count += 1;
            if (index <= line_start) index = line_start + 1;
        }

        var y = text_pos.y;
        var i: usize = 0;
        while (i < line_count) : (i += 1) {
            d.drawText(.{ .text = lines[i], .pos = .init(text_pos.x, y), .color = .black, .font = font });
            y += line_step;
        }
    }
};
