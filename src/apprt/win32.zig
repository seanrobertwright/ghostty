// The required comptime API for any apprt.
pub const App = @import("win32/App.zig");
pub const Surface = @import("win32/Surface.zig");

const internal_os = @import("../os/main.zig");
pub const resourcesDir = internal_os.resourcesDir;

test {
    @import("std").testing.refAllDecls(@This());
}
