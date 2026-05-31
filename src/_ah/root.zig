const std = @import("std");
const rl = @import("raylib");

pub const AudioHandler = struct {
    sfx: ?rl.Sound = null,
    master_volume: f32 = 50,
    music: ?rl.Music = null,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) AudioHandler {
        return .{ .allocator = allocator };
    }

    pub fn deinit(self: *AudioHandler) void {
        if (self.sfx) |sfx| rl.unloadSound(sfx);
        if (self.music) |music| rl.unloadMusicStream(music);
        self.sfx = null;
        self.music = null;
    }

    pub fn load(self: *AudioHandler, master_volume: f32) void {
        self.setMasterVolume(master_volume);
    }

    pub fn loadAudio(self: *AudioHandler, io: *std.Io, audio_type: enum { Music, Sfx }, file_path: []const u8, key: [:0]const u8) void {
        _ = key; // Placeholder for future use, e.g., to manage multiple audio tracks
        const cwd = std.Io.Dir.cwd();
        const file_path_z = self.allocator.dupeZ(u8, file_path) catch return;
        const file = cwd.statFile(io.*, file_path_z, .{}) catch return;
        defer self.allocator.free(file_path_z);
        if (file.size == 0) return;
        switch (audio_type) {
            .Music => {
                if (self.music) |music| rl.unloadMusicStream(music);
                self.music = null;
                self.music = rl.loadMusicStream(file_path_z) catch null;
                errdefer if (self.music) |music| rl.unloadMusicStream(music);
            },
            .Sfx => {
                if (self.sfx) |sfx| rl.unloadSound(sfx);
                self.sfx = null;
                self.sfx = rl.loadSound(file_path_z) catch null;
                errdefer if (self.sfx) |sfx| rl.unloadSound(sfx);
            },
        }
    }

    pub fn playAudio(self: *AudioHandler, audio_type: enum { Music, Sfx }, key: [:0]const u8) void {
        _ = key; // Placeholder for future use, e.g., to manage multiple audio tracks.s
        switch (audio_type) {
            .Music => {
                if (self.music) |music| {
                    if (rl.isMusicStreamPlaying(music)) return;
                    rl.playMusicStream(music);
                }
            },
            .Sfx => {
                if (self.sfx) |sfx| {
                    if (rl.isSoundPlaying(sfx)) rl.stopSound(sfx);
                    rl.playSound(sfx);
                }
            },
        }
    }

    pub fn setMasterVolume(self: *AudioHandler, volume: f32) void {
        self.master_volume = volume;
        rl.setMasterVolume(std.math.clamp(self.master_volume / 100.0, 0.0, 1.0));
    }

    pub fn update(self: *AudioHandler) void {
        if (self.music) |music| rl.updateMusicStream(music);
    }

    pub fn unloadAudio(self: *AudioHandler, audio_type: enum { Music, Sfx }, key: [:0]const u8) void {
        _ = key; // Placeholder for future use, e.g., to manage multiple audio tracks
        switch (audio_type) {
            .Music => {
                if (self.music) |music| rl.unloadMusicStream(music);
                self.music = null;
            },
            .Sfx => {
                if (self.sfx) |sfx| rl.unloadSound(sfx);
                self.sfx = null;
            },
        }
    }
};
