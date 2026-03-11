//! Represents the context for drawing a given frame in D3D11.
const Self = @This();

const std = @import("std");

const Direct3D11 = @import("../Direct3D11.zig");
const Renderer = @import("../generic.zig").Renderer(Direct3D11);
const Target = @import("Target.zig");
const RenderPass = @import("RenderPass.zig");

const Health = @import("../../renderer.zig").Health;

/// Options for beginning a frame.
pub const Options = struct {};

renderer: *Renderer,
target: *Target,

/// Begin encoding a frame.
pub fn begin(
    opts: Options,
    renderer: *Renderer,
    target: *Target,
) !Self {
    _ = opts;
    return .{
        .renderer = renderer,
        .target = target,
    };
}

/// Add a render pass to this frame with the provided attachments.
pub inline fn renderPass(
    self: *const Self,
    attachments: []const RenderPass.Options.Attachment,
) RenderPass {
    _ = self;
    return RenderPass.begin(.{ .attachments = attachments });
}

/// Complete this frame and present the target.
pub fn complete(self: *const Self, sync: bool) void {
    _ = sync;

    // TODO: D3D11 frame completion - wait for GPU, present swap chain

    // For now, report healthy since we're stubbed out.
    self.renderer.frameCompleted(.healthy);
}
