const std = @import("std");

/// Options for initializing a buffer.
pub const Options = struct {};

/// Opaque handle representing a D3D11 GPU buffer.
/// This will hold the actual ID3D11Buffer pointer once COM bindings are available.
pub const Handle = struct {
    /// Placeholder ID for the buffer. Will be replaced with COM pointer.
    id: usize = 0,
};

/// D3D11 data storage for a certain set of equal types. This mirrors
/// the OpenGL Buffer pattern: a function that returns a type specialized
/// for a particular element type T.
pub fn Buffer(comptime T: type) type {
    return struct {
        const Self = @This();

        /// Underlying buffer handle.
        buffer: Handle,

        /// Options this buffer was allocated with.
        opts: Options,

        /// Current allocated length of the data store.
        /// Note this is the number of `T`s, not the size in bytes.
        len: usize,

        /// Initialize a buffer with the given length pre-allocated.
        pub fn init(opts: Options, len: usize) !Self {
            return .{
                .buffer = .{},
                .opts = opts,
                .len = len,
            };
        }

        /// Init the buffer filled with the given data.
        pub fn initFill(opts: Options, data: []const T) !Self {
            return .{
                .buffer = .{},
                .opts = opts,
                .len = data.len,
            };
        }

        pub fn deinit(self: Self) void {
            _ = self;
            // TODO: Release D3D11 buffer resources
        }

        /// Sync new contents to the buffer.
        pub fn sync(self: *Self, data: []const T) !void {
            _ = data;
            _ = self;
            @panic("TODO: D3D11 buffer sync");
        }

        /// Like Buffer.sync but takes data from an array of ArrayLists.
        pub fn syncFromArrayLists(self: *Self, lists: []const std.ArrayListUnmanaged(T)) !usize {
            var total_len: usize = 0;
            for (lists) |list| {
                total_len += list.items.len;
            }
            _ = self;
            @panic("TODO: D3D11 buffer syncFromArrayLists");
        }
    };
}
