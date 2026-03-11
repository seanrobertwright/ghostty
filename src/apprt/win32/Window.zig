/// Win32 window wrapper. Manages the native HWND and associated state
/// for a top-level Ghostty window.
const Window = @This();

const std = @import("std");

/// The native Win32 window handle. Null if the window has not been created
/// or has been destroyed.
hwnd: ?std.os.windows.HWND = null,

/// The current width of the client area in pixels.
width: u32 = 800,

/// The current height of the client area in pixels.
height: u32 = 600,

/// The current DPI of the window.
dpi: u32 = 96,

pub fn init(width: u32, height: u32) !Window {
    // TODO: CreateWindowExW, register WNDCLASS, etc.
    return .{
        .hwnd = null,
        .width = width,
        .height = height,
        .dpi = 96,
    };
}

pub fn deinit(self: *Window) void {
    // TODO: DestroyWindow if hwnd is valid
    self.hwnd = null;
}
