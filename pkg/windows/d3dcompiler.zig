const std = @import("std");
const windows = std.os.windows;
const GUID = windows.GUID;
const HRESULT = windows.HRESULT;

// ============================================================================
// COM Interfaces
// ============================================================================

/// ID3DBlob (ID3D10Blob) — inherits IUnknown
/// Used for shader bytecode and error messages from D3DCompile.
pub const ID3DBlob = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        // IUnknown (3)
        QueryInterface: *const fn (*ID3DBlob, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (*ID3DBlob) callconv(.C) u32,
        Release: *const fn (*ID3DBlob) callconv(.C) u32,
        // ID3DBlob (2)
        GetBufferPointer: *const fn (*ID3DBlob) callconv(.C) *anyopaque,
        GetBufferSize: *const fn (*ID3DBlob) callconv(.C) usize,
    };

    pub fn Release(self: *ID3DBlob) u32 {
        return self.vtable.Release(self);
    }

    pub fn GetBufferPointer(self: *ID3DBlob) *anyopaque {
        return self.vtable.GetBufferPointer(self);
    }

    pub fn GetBufferSize(self: *ID3DBlob) usize {
        return self.vtable.GetBufferSize(self);
    }
};

// ============================================================================
// Compile flags
// ============================================================================

pub const D3DCOMPILE_DEBUG: u32 = 1 << 0;
pub const D3DCOMPILE_SKIP_VALIDATION: u32 = 1 << 1;
pub const D3DCOMPILE_SKIP_OPTIMIZATION: u32 = 1 << 2;
pub const D3DCOMPILE_PACK_MATRIX_ROW_MAJOR: u32 = 1 << 3;
pub const D3DCOMPILE_PACK_MATRIX_COLUMN_MAJOR: u32 = 1 << 4;
pub const D3DCOMPILE_ENABLE_STRICTNESS: u32 = 1 << 11;
pub const D3DCOMPILE_OPTIMIZATION_LEVEL0: u32 = 1 << 14;
pub const D3DCOMPILE_OPTIMIZATION_LEVEL1: u32 = 0;
pub const D3DCOMPILE_OPTIMIZATION_LEVEL2: u32 = (1 << 14) | (1 << 15);
pub const D3DCOMPILE_OPTIMIZATION_LEVEL3: u32 = 1 << 15;

// ============================================================================
// Functions
// ============================================================================

pub extern "d3dcompiler_47" fn D3DCompile(
    pSrcData: [*]const u8,
    SrcDataSize: usize,
    pSourceName: ?[*:0]const u8,
    pDefines: ?*const anyopaque,
    pInclude: ?*const anyopaque,
    pEntrypoint: [*:0]const u8,
    pTarget: [*:0]const u8,
    Flags1: u32,
    Flags2: u32,
    ppCode: *?*ID3DBlob,
    ppErrorMsgs: *?*ID3DBlob,
) callconv(.C) HRESULT;

// ============================================================================
// Tests
// ============================================================================

test "D3DCompiler struct sizes are nonzero" {
    try std.testing.expect(@sizeOf(ID3DBlob) > 0);
    try std.testing.expect(@sizeOf(ID3DBlob.VTable) > 0);
}
