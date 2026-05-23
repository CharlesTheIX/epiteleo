const rl = @import("raylib");

pub const Key = enum {
    // Movement
    W,
    A,
    S,
    D,
    Up,
    Down,
    Left,
    Right,
    // Actions
    Space,
    Enter,
    Equal, // Zoom in (with LeftShift or RightShift)
    Minus, // Zoom out
    LeftBracket, // Rotate left (with LeftShift or RightShift)
    RightBracket, // Rotate right (with LeftShift or RightShift)
    P, // Pause
    // Esc
    Escape,
    // Modifiers
    LeftAlt,
    RightAlt,
    LeftShift,
    RightShift,
    LeftControl,
    RightControl,
    // Numbers
    One,
    Two,
    Three,
    Four,
    Five,
    Six,
    Seven,
    Eight,
    Nine,
    Zero,

    pub fn array() []const Key {
        return &[_]Key{ .One, .Two, .Three, .Four, .Five, .Six, .Seven, .Eight, .Nine, .Zero, .W, .A, .S, .D, .Up, .Down, .Left, .Right, .Space, .Enter, .Escape, .LeftShift, .RightShift, .LeftControl, .RightControl, .LeftAlt, .RightAlt, .Equal, .Minus, .LeftBracket, .RightBracket, .P };
    }

    pub fn fromRL(key: rl.KeyboardKey) ?Key {
        return switch (key) {
            // Movement
            rl.KeyboardKey.w => .W,
            rl.KeyboardKey.a => .A,
            rl.KeyboardKey.s => .S,
            rl.KeyboardKey.d => .D,
            rl.KeyboardKey.up => .Up,
            rl.KeyboardKey.down => .Down,
            rl.KeyboardKey.left => .Left,
            rl.KeyboardKey.right => .Right,
            // Actions
            rl.KeyboardKey.space => .Space,
            rl.KeyboardKey.enter => .Enter,
            rl.KeyboardKey.equal => .Equal, // Zoom in (with LeftShift or RightShift)
            rl.KeyboardKey.minus => .Minus, // Zoom out
            rl.KeyboardKey.left_bracket => .LeftBracket, // Rotate left (with LeftShift or RightShift)
            rl.KeyboardKey.right_bracket => .RightBracket, // Rotate right (with LeftShift or RightShift)
            rl.KeyboardKey.p => .P, // Pause
            // Esc
            rl.KeyboardKey.escape => .Escape,
            // Modifiers
            rl.KeyboardKey.left_alt => .LeftAlt,
            rl.KeyboardKey.right_alt => .RightAlt,
            rl.KeyboardKey.left_shift => .LeftShift,
            rl.KeyboardKey.right_shift => .RightShift,
            rl.KeyboardKey.left_control => .LeftControl,
            rl.KeyboardKey.right_control => .RightControl,
            // Numbers
            rl.KeyboardKey.one => .One,
            rl.KeyboardKey.two => .Two,
            rl.KeyboardKey.three => .Three,
            rl.KeyboardKey.four => .Four,
            rl.KeyboardKey.five => .Five,
            rl.KeyboardKey.six => .Six,
            rl.KeyboardKey.seven => .Seven,
            rl.KeyboardKey.eight => .Eight,
            rl.KeyboardKey.nine => .Nine,
            rl.KeyboardKey.zero => .Zero,
            else => null,
        };
    }

    pub fn toRL(self: Key) rl.KeyboardKey {
        return switch (self) {
            // Movement
            .W => rl.KeyboardKey.w,
            .A => rl.KeyboardKey.a,
            .S => rl.KeyboardKey.s,
            .D => rl.KeyboardKey.d,
            .Up => rl.KeyboardKey.up,
            .Down => rl.KeyboardKey.down,
            .Left => rl.KeyboardKey.left,
            .Right => rl.KeyboardKey.right,
            // Actions
            .Space => rl.KeyboardKey.space,
            .Enter => rl.KeyboardKey.enter,
            .Equal => rl.KeyboardKey.equal, // Zoom in (with LeftShift or RightShift)
            .Minus => rl.KeyboardKey.minus, // Zoom out
            .LeftBracket => rl.KeyboardKey.left_bracket, // Rotate left (with LeftShift or RightShift)
            .RightBracket => rl.KeyboardKey.right_bracket, // Rotate right (with LeftShift or RightShift)
            .P => rl.KeyboardKey.p, // Pause
            // Esc
            .Escape => rl.KeyboardKey.escape,
            // Modifiers
            .LeftAlt => rl.KeyboardKey.left_alt,
            .RightAlt => rl.KeyboardKey.right_alt,
            .LeftShift => rl.KeyboardKey.left_shift,
            .RightShift => rl.KeyboardKey.right_shift,
            .LeftControl => rl.KeyboardKey.left_control,
            .RightControl => rl.KeyboardKey.right_control,
            // Numbers
            .One => rl.KeyboardKey.one,
            .Two => rl.KeyboardKey.two,
            .Three => rl.KeyboardKey.three,
            .Four => rl.KeyboardKey.four,
            .Five => rl.KeyboardKey.five,
            .Six => rl.KeyboardKey.six,
            .Seven => rl.KeyboardKey.seven,
            .Eight => rl.KeyboardKey.eight,
            .Nine => rl.KeyboardKey.nine,
            .Zero => rl.KeyboardKey.zero,
        };
    }
};
