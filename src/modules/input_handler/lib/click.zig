const std = @import("std");
const rl = @import("raylib");

pub const Click = enum {
    Left,
    Right,
    Middle,

    pub fn array() []const Click {
        return &[_]Click{ .Left, .Right, .Middle };
    }

    pub fn fromRL(rlButton: rl.MouseButton) ?Click {
        return switch (rlButton) {
            rl.MouseButton.left => .Left,
            rl.MouseButton.right => .Right,
            rl.MouseButton.middle => .Middle,
        };
    }

    pub fn toRL(self: Click) rl.MouseButton {
        return switch (self) {
            .Left => rl.MouseButton.left,
            .Right => rl.MouseButton.right,
            .Middle => rl.MouseButton.middle,
        };
    }
};
