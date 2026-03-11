/// Win32 terminal surface. A surface is a single terminal "widget" where
/// the terminal content is drawn and input events are processed.
const Surface = @This();

const std = @import("std");
const apprt = @import("../../apprt.zig");
const configpkg = @import("../../config.zig");
const CoreSurface = @import("../../Surface.zig");
const App = @import("App.zig");

/// The core surface. This is the platform-agnostic terminal surface
/// that manages the actual terminal state.
core_surface: *CoreSurface,

/// The app that owns this surface.
app: *App,

pub fn deinit(self: *Surface) void {
    _ = self;
}

pub fn close(self: *Surface, process_active: bool) void {
    _ = self;
    _ = process_active;
}

pub fn getTitle(self: *Surface) ?[:0]const u8 {
    _ = self;
    return null;
}

pub fn getContentScale(self: *const Surface) !apprt.ContentScale {
    _ = self;
    // TODO: query actual DPI from Win32 (GetDpiForWindow)
    return .{ .x = 1.0, .y = 1.0 };
}

pub fn getSize(self: *const Surface) !apprt.SurfaceSize {
    _ = self;
    // TODO: query actual client rect from Win32 (GetClientRect)
    return .{ .width = 800, .height = 600 };
}

pub fn getCursorPos(self: *const Surface) !apprt.CursorPos {
    _ = self;
    // TODO: query actual cursor position from Win32 (GetCursorPos / ScreenToClient)
    return .{ .x = 0, .y = 0 };
}

pub fn supportsClipboard(
    self: *const Surface,
    clipboard_type: apprt.Clipboard,
) bool {
    _ = self;
    return switch (clipboard_type) {
        // Windows supports the standard clipboard (Ctrl+C/V)
        .standard => true,
        // Windows does not have selection or primary clipboards
        .selection, .primary => false,
    };
}

pub fn clipboardRequest(
    self: *Surface,
    clipboard_type: apprt.Clipboard,
    state: apprt.ClipboardRequest,
) !bool {
    _ = self;
    _ = clipboard_type;
    _ = state;
    // TODO: implement Win32 clipboard reading
    return false;
}

pub fn setClipboard(
    self: *Surface,
    clipboard_type: apprt.Clipboard,
    contents: []const apprt.ClipboardContent,
    confirm: bool,
) !void {
    _ = self;
    _ = clipboard_type;
    _ = contents;
    _ = confirm;
    // TODO: implement Win32 clipboard writing
}

pub fn defaultTermioEnv(self: *Surface) !std.process.EnvMap {
    _ = self;
    // Return an empty env map; the termio layer will populate from
    // the process environment.
    return std.process.EnvMap.init(std.heap.page_allocator);
}

pub fn rtApp(self: *Surface) *App {
    return self.app;
}

pub fn core(self: *Surface) *CoreSurface {
    return self.core_surface;
}
