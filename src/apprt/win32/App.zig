/// Win32 application runtime for Ghostty. This is the Windows-native
/// backend using the Win32 API for window management and input.
const App = @This();

const std = @import("std");
const Allocator = std.mem.Allocator;
const apprt = @import("../../apprt.zig");
const CoreApp = @import("../../App.zig");

const Surface = @import("Surface.zig");

const log = std.log.scoped(.win32);

/// The core Ghostty app. This is the instance of the platform-agnostic
/// App.zig that contains all terminal-related state.
core_app: *CoreApp,

pub fn init(
    self: *App,
    core_app: *CoreApp,

    // Required by the apprt interface but unused for now.
    opts: struct {},
) !void {
    _ = opts;
    self.* = .{ .core_app = core_app };
}

pub fn deinit(self: *App) void {
    _ = self;
}

pub fn terminate(self: *App) void {
    _ = self;
}

pub fn run(self: *App) !void {
    // TODO: Win32 message loop with MsgWaitForMultipleObjectsEx
    _ = self;
    @panic("TODO: Win32 message loop");
}

/// Called by CoreApp to wake up the event loop.
pub fn wakeup(self: *App) void {
    // TODO: PostMessage to wake up the message loop
    _ = self;
}

pub fn performAction(
    self: *App,
    target: apprt.Target,
    comptime action: apprt.Action.Key,
    value: apprt.Action.Value(action),
) !bool {
    _ = self;
    _ = target;
    _ = value;
    return false;
}

/// Send the given IPC to a running Ghostty. Returns `true` if the action was
/// able to be performed, `false` otherwise.
///
/// Note that this is a static function. Since this is called from a CLI app (or
/// some other process that is not Ghostty) there is no full-featured apprt App
/// to use.
pub fn performIpc(
    _: Allocator,
    _: apprt.ipc.Target,
    comptime action: apprt.ipc.Action.Key,
    _: apprt.ipc.Action.Value(action),
) !bool {
    return false;
}

/// Redraw the inspector for the given surface.
pub fn redrawInspector(_: *App, surface: *Surface) void {
    _ = surface;
}
