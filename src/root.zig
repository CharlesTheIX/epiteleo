const std = @import("std");
const rl = @import("raylib");
const _ui = @import("./_ui/root.zig");
const Dev = @import("./__dev/root.zig").Dev;
const _intro = @import("./modules/intro/root.zig");
const _job = @import("./modules/loader/lib/job.zig");
const Game = @import("./modules/game/root.zig").Game;
const _ih = @import("./modules/input_handler/root.zig");
const Loader = @import("./modules/loader/root.zig").Loader;
const Camera = @import("./modules/camera/root.zig").Camera;
const Canvas = @import("./modules/canvas/root.zig").Canvas;
const NewGame = @import("./modules/new_game/root.zig").NewGame;
const Settings = @import("./modules/settings/root.zig").Settings;

pub const AppProps = struct { allocator: std.mem.Allocator, io: *std.Io };

pub const App = struct {
    io: *std.Io,
    game: ?Game = null,
    ih: _ih.InputHandler,
    state: State = .Init,
    __dev: ?Dev = .init(),
    ui: _ui.Ui = .init(.{}),
    shut_down: bool = false,
    camera: Camera = .init(),
    canvas: Canvas = .init(),
    loader: Loader = .init(),
    prev_state: State = .Init,
    new_game: ?NewGame = null,
    settings: Settings = .init(),
    allocator: std.mem.Allocator,
    intro: ?_intro.Intro = .init(),

    pub fn init(props: AppProps) App {
        return App{ .io = props.io, .allocator = props.allocator, .ih = .init(props.allocator) };
    }

    pub fn deinit(self: *App) void {
        self.ui.deinit();
        self.camera.deinit();
        self.loader.deinit();
        self.settings.deinit();
        self.ih.deinit();
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
        const font = &self.ui.font;
        if (self.loader.showing) return self.loader.drawLoadingScreen(font); // check

        switch (self.state) {
            .Init => return,
            .NewGame => if (self.new_game) |*ng| ng.draw(self.allocator, font),
            .Settings => self.settings.drawSettingsScreen(font), // check
            .Intro => if (self.intro) |*i| i.drawIntroScreen(font, self.allocator), // check
            .Game => {
                rl.beginMode2D(self.camera.camera);
                if (self.game) |*g| g.draw();
                self.canvas.draw();
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
        // self.canvas.rect = rl.Rectangle.init(0, 0, screen_w, screen_h);
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

    pub fn setState(self: *App, state: State, request: ?_job.Request) void {
        if (self.loader.loading) return;
        if (request) |r| return self.loader.load(r, state) catch return;
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
        self.ih.update();
        self.camera.update(&self.ih, null, &self.canvas.rect);
        self.canvas.update(&self.ih, &self.camera);
        if (self.__dev) |*dev| dev.update(self);
        if (self.loader.showing) return self.loader.update(self);
        switch (self.state) {
            .Game => if (self.game) |*g| return g.update(),
            .Settings => return self.settings.update(self),
            .Intro => if (self.intro) |*i| return i.update(self),
            .NewGame => if (self.new_game) |*ng| return ng.update(self),
            .Init => {
                if (self.intro) |*i| {
                    const request: _job.Request = .{ .Task = .{
                        .io = self.io,
                        .ctx = @ptrCast(i),
                        .run_on_main_thread = true,
                        .run = _intro.loadIntroTask,
                    } };
                    return self.setState(.Intro, request);
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

    pub fn fromInt(raw: u8) State {
        return switch (raw) {
            0 => .Init,
            1 => .Game,
            2 => .Intro,
            3 => .NewGame,
            4 => .Settings,
            else => .Init,
        };
    }

    pub fn toInt(self: State) u8 {
        return @intFromEnum(self);
    }

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
