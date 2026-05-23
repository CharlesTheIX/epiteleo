const rl = @import("raylib");

pub const Color = enum {
    Black,
    Blue,
    Green,
    Orange,
    Red,
    White,
    Yellow,

    pub fn toRL(self: Color, a: ?u8) rl.Color {
        switch (self) {
            .Black => return rl.Color{ .r = 55, .g = 55, .b = 55, .a = a orelse 255 },
            .Blue => return rl.Color{ .r = 0, .g = 0, .b = 255, .a = a orelse 255 },
            .Green => return rl.Color{ .r = 0, .g = 255, .b = 0, .a = a orelse 255 },
            .Orange => return rl.Color{ .r = 255, .g = 165, .b = 0, .a = a orelse 255 },
            .Red => return rl.Color{ .r = 255, .g = 0, .b = 0, .a = a orelse 255 },
            .White => return rl.Color{ .r = 255, .g = 255, .b = 255, .a = a orelse 255 },
            .Yellow => return rl.Color{ .r = 255, .g = 255, .b = 0, .a = a orelse 255 },
        }
    }

    pub fn toString(self: Color) []const u8 {
        return switch (self) {
            .Black => "Black",
            .Blue => "Blue",
            .Green => "Green",
            .Orange => "Orange",
            .Red => "Red",
            .White => "White",
            .Yellow => "Yellow",
        };
    }
};
