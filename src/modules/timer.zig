pub const Timer = struct {
    value_ms: f32,
    initial_value_ms: f32,
    is_active: bool = false,

    pub fn init(value: f32) Timer {
        return Timer{ .initial_value_ms = value, .value_ms = value };
    }

    pub fn update(self: *Timer, delta_time: f32) void {
        if (!self.is_active) return;
        self.value_ms -= delta_time;
        if (self.value_ms <= 0) {
            self.is_active = false;
            self.value_ms = self.initial_value_ms;
        }
    }
};
