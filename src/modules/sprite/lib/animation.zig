pub const Animation = struct {
    fps: u8 = 0,
    frame: u4 = 0,
    max_frames: u4 = 0,
    time_elapsed: f32 = 0,
    finished: bool = false,

    pub fn reset(self: *Animation) void {
        self.fps = 0;
        self.frame = 0;
        self.max_frames = 0;
        self.finished = true;
        self.time_elapsed = 0;
    }
};
