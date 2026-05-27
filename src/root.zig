const std = @import("std");
const rl = @import("raylib");
const gm = @import("./modules/game/root.zig");
const is = @import("./modules/intro/root.zig");
const l = @import("./modules/loader/root.zig");
const ih = @import("./modules/input_handler/root.zig");

const Game = gm.Game;
const Intro = is.Intro;
const Loader = l.Loader;
const InputHandler = ih.InputHandler;
const UI = @import("./modules/ui/root.zig").UI;
const JobRequest = @import("utils.zig").JobRequest;
const Dev = @import("./modules/__dev/root.zig").Dev;
const Camera = @import("./modules/camera/root.zig").Camera;
const Canvas = @import("./modules/canvas/root.zig").Canvas;
const loadIntroTask = is.loadIntroTask;
const NewGame = @import("./modules/new_game/root.zig").NewGame;
const Settings = @import("./modules/settings/root.zig").Settings;

pub const App = struct {
    io: *std.Io,
    ui: UI = .init(),
    game: ?Game = null,
    state: State = .Init,
    __dev: ?Dev = .init(),
    intro: ?Intro = .init(),
    shut_down: bool = false,
    camera: Camera = .init(),
    canvas: Canvas = .init(),
    loader: Loader = .init(),
    prev_state: State = .Init,
    new_game: ?NewGame = null,
    input_handler: InputHandler,
    settings: Settings = .init(),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, io: *std.Io) App {
        return App{ .io = io, .allocator = allocator, .input_handler = .init(allocator) };
    }

    pub fn deinit(self: *App) void {
        self.ui.deinit();
        self.camera.deinit();
        self.loader.deinit();
        self.settings.deinit();
        self.input_handler.deinit();
        if (self.game) |*g| g.deinit();
        if (self.intro) |*i| i.deinit();
        if (self.__dev) |*dev| dev.deinit();
        if (self.new_game) |*ng| ng.deinit();
        self.io.close();
    }

    fn draw(self: *App) void {
        if (self.shut_down) return;
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.black);
        if (self.loader.showing) return self.loader.drawLoadingScreen(&self.ui);

        switch (self.state) {
            .Init => return,
            .NewGame => if (self.new_game) |*ng| ng.draw(&self.ui),
            .Settings => self.settings.drawSettingsScreen(&self.ui),
            .Intro => if (self.intro) |*i| i.drawIntroScreen(&self.ui, self.allocator),
            .Game => {
                rl.beginMode2D(self.camera.camera);
                if (self.game) |*g| g.draw(&self.ui);
                self.canvas.draw(&self.ui);
                rl.endMode2D();
            },
        }
        if (self.__dev) |*dev| dev.draw(self);
    }

    fn handleResize(self: *App) void {
        if (!rl.isWindowResized()) return;
        const screen_w = @as(f32, @floatFromInt(rl.getScreenWidth()));
        const screen_h = @as(f32, @floatFromInt(rl.getScreenHeight()));
        self.camera.resize(rl.Vector2.init(screen_w, screen_h).scale(0.5));
        self.canvas.rect = rl.Rectangle.init(0, 0, screen_w, screen_h);
    }

    fn load(self: *App) void {
        self.ui.load();
        self.settings.load(self.io);
        self.loader.resources.load(self.io);
        const screen_w = @as(f32, @floatFromInt(rl.getScreenWidth()));
        const screen_h = @as(f32, @floatFromInt(rl.getScreenHeight()));
        self.camera.load(rl.Vector2.init(screen_w, screen_h).scale(0.5));
        self.canvas.rect = rl.Rectangle.init(0, 0, screen_w, screen_h);
    }

    pub fn run(self: *App) void {
        var config_flags = rl.ConfigFlags{ .vsync_hint = true };
        if (self.__dev != null) config_flags.window_resizable = true;
        rl.setTargetFPS(60);
        rl.setConfigFlags(config_flags);
        rl.initWindow(960, 540, "Epiteleo");
        defer rl.closeWindow();
        self.load();
        while (!rl.windowShouldClose() and !self.shut_down) {
            self.update();
            self.draw();
        }
    }

    pub fn setState(self: *App, state: State, job_request: ?JobRequest) void {
        if (self.loader.loading) return;
        if (job_request) |request| return self.loader.load(request, state) catch return;
        self.prev_state = self.state;
        self.state = state;
        switch (state) {
            // TODO: update the game - this is here for testing - CIX
            .Game => self.camera.state = .Free,
            else => self.camera.state = .Fixed,
        }
    }

    fn update(self: *App) void {
        if (self.shut_down) return;
        self.handleResize();
        self.input_handler.update();
        self.camera.update(&self.input_handler, null, &self.canvas.rect);
        self.canvas.update(&self.input_handler, &self.camera);
        if (self.__dev) |*dev| dev.update(self);
        if (self.loader.showing) return self.loader.update(self);
        switch (self.state) {
            .Game => if (self.game) |*g| return g.update(),
            .Settings => return self.settings.update(self),
            .Intro => if (self.intro) |*i| return i.update(self),
            .NewGame => if (self.new_game) |*ng| return ng.update(),
            .Init => {
                if (self.intro) |*i| {
                    const job_request: JobRequest = .{ .Task = .{
                        .io = self.io,
                        .ctx = @ptrCast(i),
                        .run_on_main_thread = true,
                        .run = loadIntroTask,
                    } };
                    return self.setState(.Intro, job_request);
                }
                return std.debug.panic("Failed to initialize the application\n", .{});
            },
        }
    }
};

pub const State = enum {
    Init,
    Game,
    Intro,
    NewGame,
    Settings,

    pub fn toString(self: State) []const u8 {
        return switch (self) {
            .Game => "Game",
            .Init => "Init",
            .Intro => "Intro",
            .NewGame => "New Game",
            .Settings => "Settings",
        };
    }
};
