const std = @import("std");
const rl = @import("raylib");
const gm = @import("../game/root.zig");
const ss = @import("../settings/root.zig");
const ih = @import("../input_handler/root.zig");

const Key = ih.Key;
const Game = gm.Game;
const Settings = ss.Settings;
const State = enum { Init, Start };
const InputHandler = ih.InputHandler;
const UI = @import("../ui/root.zig").UI;
const App = @import("../../root.zig").App;
const Init = @import("./lib/init.zig").Init;
const Start = @import("./lib/start.zig").Start;
const Timer = @import("../timer/root.zig").Timer;
const JobRequest = @import("../../utils.zig").JobRequest;
const loadGameTask = gm.loadGameTask;
const Resources = @import("./lib/resources.zig").Resources;
const loadSettingsTask = ss.loadSettingsTask;

pub const Intro = struct {
    _init: Init = .{},
    _start: Start = .{},
    state: State = .Init,
    resources: Resources = .{},
    has_save_data: bool = false,
    input_timer: Timer = .init(0.3),
    fade_in_timer: Timer = .init(0.5),
    game_data_path: *const [17:0]u8 = ".data/save_data.z",

    pub fn init() Intro {
        return .{};
    }

    pub fn deinit(self: *Intro) void {
        self.resources.deinit();
    }

    pub fn drawIntroScreen(self: *Intro, ui: *UI, allocator: std.mem.Allocator) void {
        var alpha: f32 = 1.0;
        if (self.fade_in_timer.is_active) alpha = 1.0 - self.fade_in_timer.value_ms / self.fade_in_timer.initial_value_ms;
        const template = ui.defaultRect();
        ui.drawRect(template, rl.Color.black.alpha(alpha));
        // const tint = rl.Color.white.alpha(alpha);
        // if (self.resources.texture) |texture| {
        //     rl.drawTextureV(texture, rl.Vector2.init(template.x, template.y), tint);
        // }
        switch (self.state) {
            .Init => return self._init.draw(ui, allocator),
            .Start => return self._start.draw(self, ui, allocator),
        }
    }

    pub fn update(self: *Intro, app: *App) void {
        if (self.input_timer.is_active) return self.input_timer.update();
        var fade_in_active = false;
        if (self.fade_in_timer.is_active) {
            fade_in_active = true;
            self.fade_in_timer.update();
        }
        if (self._init.fade_in_timer.is_active) {
            fade_in_active = true;
            self._init.fade_in_timer.update();
        }
        if (self._start.fade_in_timer.is_active) {
            fade_in_active = true;
            self._start.fade_in_timer.update();
        }
        if (fade_in_active) return;
        switch (self.state) {
            .Init => return self._init.update(self, app),
            .Start => return self._start.update(self, app),
        }
    }
};

pub fn loadIntroTask(ctx: *anyopaque, io: *std.Io) void {
    const cwd = std.Io.Dir.cwd();
    const module: *Intro = @ptrCast(@alignCast(ctx));
    module.resources.load();
    module.fade_in_timer.is_active = true;
    module._init.fade_in_timer.is_active = true;
    const file = cwd.statFile(io.*, module.game_data_path, .{}) catch {
        module.has_save_data = false;
        return;
    };
    module.has_save_data = file.kind == .file;
}
