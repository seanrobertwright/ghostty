const std = @import("std");
const windows = std.os.windows;
const GUID = windows.GUID;
const HRESULT = windows.HRESULT;
const BOOL = windows.BOOL;

const dxgi = @import("dxgi.zig");
const DXGI_FORMAT = dxgi.DXGI_FORMAT;
const DXGI_SAMPLE_DESC = dxgi.DXGI_SAMPLE_DESC;
const RECT = dxgi.RECT;

// ============================================================================
// GUIDs
// ============================================================================

pub const IID_ID3D11Device = GUID{
    .Data1 = 0xdb6f6ddb,
    .Data2 = 0xac77,
    .Data3 = 0x4ee6,
    .Data4 = .{ 0xb3, 0xf0, 0x2f, 0xca, 0x5d, 0x09, 0xe0, 0x95 },
};

pub const IID_ID3D11Texture2D = GUID{
    .Data1 = 0x6f15aaf2,
    .Data2 = 0xd208,
    .Data3 = 0x4e89,
    .Data4 = .{ 0x9a, 0xb4, 0x48, 0x95, 0x35, 0xd3, 0x4f, 0x9c },
};

// ============================================================================
// Enums
// ============================================================================

pub const D3D11_USAGE = enum(u32) {
    DEFAULT = 0,
    IMMUTABLE = 1,
    DYNAMIC = 2,
    STAGING = 3,
};

pub const D3D11_BIND_FLAG = u32;
pub const D3D11_BIND_VERTEX_BUFFER: D3D11_BIND_FLAG = 0x1;
pub const D3D11_BIND_INDEX_BUFFER: D3D11_BIND_FLAG = 0x2;
pub const D3D11_BIND_CONSTANT_BUFFER: D3D11_BIND_FLAG = 0x4;
pub const D3D11_BIND_SHADER_RESOURCE: D3D11_BIND_FLAG = 0x8;
pub const D3D11_BIND_STREAM_OUTPUT: D3D11_BIND_FLAG = 0x10;
pub const D3D11_BIND_RENDER_TARGET: D3D11_BIND_FLAG = 0x20;
pub const D3D11_BIND_DEPTH_STENCIL: D3D11_BIND_FLAG = 0x40;
pub const D3D11_BIND_UNORDERED_ACCESS: D3D11_BIND_FLAG = 0x80;

pub const D3D11_CPU_ACCESS_FLAG = u32;
pub const D3D11_CPU_ACCESS_WRITE: D3D11_CPU_ACCESS_FLAG = 0x10000;
pub const D3D11_CPU_ACCESS_READ: D3D11_CPU_ACCESS_FLAG = 0x20000;

pub const D3D11_MAP = enum(u32) {
    READ = 1,
    WRITE = 2,
    READ_WRITE = 3,
    WRITE_DISCARD = 4,
    WRITE_NO_OVERWRITE = 5,
};

pub const D3D11_FILTER = enum(u32) {
    MIN_MAG_MIP_POINT = 0,
    MIN_MAG_POINT_MIP_LINEAR = 0x1,
    MIN_POINT_MAG_LINEAR_MIP_POINT = 0x4,
    MIN_POINT_MAG_MIP_LINEAR = 0x5,
    MIN_LINEAR_MAG_MIP_POINT = 0x10,
    MIN_LINEAR_MAG_POINT_MIP_LINEAR = 0x11,
    MIN_MAG_LINEAR_MIP_POINT = 0x14,
    MIN_MAG_MIP_LINEAR = 0x15,
    ANISOTROPIC = 0x55,
    _,
};

pub const D3D11_TEXTURE_ADDRESS_MODE = enum(u32) {
    WRAP = 1,
    MIRROR = 2,
    CLAMP = 3,
    BORDER = 4,
    MIRROR_ONCE = 5,
};

pub const D3D11_PRIMITIVE_TOPOLOGY = enum(u32) {
    UNDEFINED = 0,
    POINTLIST = 1,
    LINELIST = 2,
    LINESTRIP = 3,
    TRIANGLELIST = 4,
    TRIANGLESTRIP = 5,
    _,
};

pub const D3D11_INPUT_CLASSIFICATION = enum(u32) {
    PER_VERTEX_DATA = 0,
    PER_INSTANCE_DATA = 1,
};

pub const D3D11_BLEND = enum(u32) {
    ZERO = 1,
    ONE = 2,
    SRC_COLOR = 3,
    INV_SRC_COLOR = 4,
    SRC_ALPHA = 5,
    INV_SRC_ALPHA = 6,
    DEST_ALPHA = 7,
    INV_DEST_ALPHA = 8,
    DEST_COLOR = 9,
    INV_DEST_COLOR = 10,
    SRC_ALPHA_SAT = 11,
    BLEND_FACTOR = 14,
    INV_BLEND_FACTOR = 15,
    SRC1_COLOR = 16,
    INV_SRC1_COLOR = 17,
    SRC1_ALPHA = 18,
    INV_SRC1_ALPHA = 19,
};

pub const D3D11_BLEND_OP = enum(u32) {
    ADD = 1,
    SUBTRACT = 2,
    REV_SUBTRACT = 3,
    MIN = 4,
    MAX = 5,
};

pub const D3D11_FILL_MODE = enum(u32) {
    WIREFRAME = 2,
    SOLID = 3,
};

pub const D3D11_CULL_MODE = enum(u32) {
    NONE = 1,
    FRONT = 2,
    BACK = 3,
};

pub const D3D11_COMPARISON_FUNC = enum(u32) {
    NEVER = 1,
    LESS = 2,
    EQUAL = 3,
    LESS_EQUAL = 4,
    GREATER = 5,
    NOT_EQUAL = 6,
    GREATER_EQUAL = 7,
    ALWAYS = 8,
};

pub const D3D11_DEPTH_WRITE_MASK = enum(u32) {
    ZERO = 0,
    ALL = 1,
};

pub const D3D11_STENCIL_OP = enum(u32) {
    KEEP = 1,
    ZERO = 2,
    REPLACE = 3,
    INCR_SAT = 4,
    DECR_SAT = 5,
    INVERT = 6,
    INCR = 7,
    DECR = 8,
};

pub const D3D11_COLOR_WRITE_ENABLE = u8;
pub const D3D11_COLOR_WRITE_ENABLE_ALL: D3D11_COLOR_WRITE_ENABLE = 0xf;

pub const D3D_FEATURE_LEVEL = enum(u32) {
    @"9_1" = 0x9100,
    @"9_2" = 0x9200,
    @"9_3" = 0x9300,
    @"10_0" = 0xa000,
    @"10_1" = 0xa100,
    @"11_0" = 0xb000,
    @"11_1" = 0xb100,
    _,
};

pub const D3D11_CREATE_DEVICE_FLAG = u32;
pub const D3D11_CREATE_DEVICE_SINGLETHREADED: D3D11_CREATE_DEVICE_FLAG = 0x1;
pub const D3D11_CREATE_DEVICE_DEBUG: D3D11_CREATE_DEVICE_FLAG = 0x2;
pub const D3D11_CREATE_DEVICE_BGRA_SUPPORT: D3D11_CREATE_DEVICE_FLAG = 0x20;

pub const D3D_DRIVER_TYPE = enum(u32) {
    UNKNOWN = 0,
    HARDWARE = 1,
    REFERENCE = 2,
    NULL = 3,
    SOFTWARE = 4,
    WARP = 5,
};

pub const D3D11_RESOURCE_DIMENSION = enum(u32) {
    UNKNOWN = 0,
    BUFFER = 1,
    TEXTURE1D = 2,
    TEXTURE2D = 3,
    TEXTURE3D = 4,
};

pub const D3D11_RTV_DIMENSION = enum(u32) {
    UNKNOWN = 0,
    BUFFER = 1,
    TEXTURE1D = 2,
    TEXTURE1DARRAY = 3,
    TEXTURE2D = 4,
    TEXTURE2DARRAY = 5,
    TEXTURE2DMS = 6,
    TEXTURE2DMSARRAY = 7,
    TEXTURE3D = 8,
};

pub const D3D11_SRV_DIMENSION = enum(u32) {
    UNKNOWN = 0,
    BUFFER = 1,
    TEXTURE1D = 2,
    TEXTURE1DARRAY = 3,
    TEXTURE2D = 4,
    TEXTURE2DARRAY = 5,
    TEXTURE2DMS = 6,
    TEXTURE2DMSARRAY = 7,
    TEXTURE3D = 8,
    TEXTURECUBE = 9,
    TEXTURECUBEARRAY = 10,
    BUFFEREX = 11,
};

pub const D3D11_RESOURCE_MISC_FLAG = u32;

// ============================================================================
// Structs
// ============================================================================

pub const D3D11_BUFFER_DESC = extern struct {
    ByteWidth: u32 = 0,
    Usage: D3D11_USAGE = .DEFAULT,
    BindFlags: D3D11_BIND_FLAG = 0,
    CPUAccessFlags: D3D11_CPU_ACCESS_FLAG = 0,
    MiscFlags: u32 = 0,
    StructureByteStride: u32 = 0,
};

pub const D3D11_TEXTURE2D_DESC = extern struct {
    Width: u32 = 0,
    Height: u32 = 0,
    MipLevels: u32 = 1,
    ArraySize: u32 = 1,
    Format: DXGI_FORMAT = .UNKNOWN,
    SampleDesc: DXGI_SAMPLE_DESC = .{},
    Usage: D3D11_USAGE = .DEFAULT,
    BindFlags: D3D11_BIND_FLAG = 0,
    CPUAccessFlags: D3D11_CPU_ACCESS_FLAG = 0,
    MiscFlags: u32 = 0,
};

pub const D3D11_SUBRESOURCE_DATA = extern struct {
    pSysMem: ?*const anyopaque = null,
    SysMemPitch: u32 = 0,
    SysMemSlicePitch: u32 = 0,
};

pub const D3D11_INPUT_ELEMENT_DESC = extern struct {
    SemanticName: [*:0]const u8 = "",
    SemanticIndex: u32 = 0,
    Format: DXGI_FORMAT = .UNKNOWN,
    InputSlot: u32 = 0,
    AlignedByteOffset: u32 = 0,
    InputSlotClass: D3D11_INPUT_CLASSIFICATION = .PER_VERTEX_DATA,
    InstanceDataStepRate: u32 = 0,
};

pub const D3D11_VIEWPORT = extern struct {
    TopLeftX: f32 = 0,
    TopLeftY: f32 = 0,
    Width: f32 = 0,
    Height: f32 = 0,
    MinDepth: f32 = 0,
    MaxDepth: f32 = 1,
};

pub const D3D11_BOX = extern struct {
    left: u32 = 0,
    top: u32 = 0,
    front: u32 = 0,
    right: u32 = 0,
    bottom: u32 = 0,
    back: u32 = 0,
};

pub const D3D11_MAPPED_SUBRESOURCE = extern struct {
    pData: ?*anyopaque = null,
    RowPitch: u32 = 0,
    DepthPitch: u32 = 0,
};

pub const D3D11_RENDER_TARGET_BLEND_DESC = extern struct {
    BlendEnable: BOOL = 0,
    SrcBlend: D3D11_BLEND = .ONE,
    DestBlend: D3D11_BLEND = .ZERO,
    BlendOp: D3D11_BLEND_OP = .ADD,
    SrcBlendAlpha: D3D11_BLEND = .ONE,
    DestBlendAlpha: D3D11_BLEND = .ZERO,
    BlendOpAlpha: D3D11_BLEND_OP = .ADD,
    RenderTargetWriteMask: u8 = D3D11_COLOR_WRITE_ENABLE_ALL,
};

pub const D3D11_BLEND_DESC = extern struct {
    AlphaToCoverageEnable: BOOL = 0,
    IndependentBlendEnable: BOOL = 0,
    RenderTarget: [8]D3D11_RENDER_TARGET_BLEND_DESC = [_]D3D11_RENDER_TARGET_BLEND_DESC{.{}} ** 8,
};

pub const D3D11_SAMPLER_DESC = extern struct {
    Filter: D3D11_FILTER = .MIN_MAG_MIP_LINEAR,
    AddressU: D3D11_TEXTURE_ADDRESS_MODE = .CLAMP,
    AddressV: D3D11_TEXTURE_ADDRESS_MODE = .CLAMP,
    AddressW: D3D11_TEXTURE_ADDRESS_MODE = .CLAMP,
    MipLODBias: f32 = 0,
    MaxAnisotropy: u32 = 1,
    ComparisonFunc: D3D11_COMPARISON_FUNC = .NEVER,
    BorderColor: [4]f32 = .{ 0, 0, 0, 0 },
    MinLOD: f32 = -std.math.floatMax(f32),
    MaxLOD: f32 = std.math.floatMax(f32),
};

pub const D3D11_RASTERIZER_DESC = extern struct {
    FillMode: D3D11_FILL_MODE = .SOLID,
    CullMode: D3D11_CULL_MODE = .BACK,
    FrontCounterClockwise: BOOL = 0,
    DepthBias: i32 = 0,
    DepthBiasClamp: f32 = 0,
    SlopeScaledDepthBias: f32 = 0,
    DepthClipEnable: BOOL = 1,
    ScissorEnable: BOOL = 0,
    MultisampleEnable: BOOL = 0,
    AntialiasedLineEnable: BOOL = 0,
};

pub const D3D11_DEPTH_STENCILOP_DESC = extern struct {
    StencilFailOp: D3D11_STENCIL_OP = .KEEP,
    StencilDepthFailOp: D3D11_STENCIL_OP = .KEEP,
    StencilPassOp: D3D11_STENCIL_OP = .KEEP,
    StencilFunc: D3D11_COMPARISON_FUNC = .ALWAYS,
};

pub const D3D11_DEPTH_STENCIL_DESC = extern struct {
    DepthEnable: BOOL = 1,
    DepthWriteMask: D3D11_DEPTH_WRITE_MASK = .ALL,
    DepthFunc: D3D11_COMPARISON_FUNC = .LESS,
    StencilEnable: BOOL = 0,
    StencilReadMask: u8 = 0xff,
    StencilWriteMask: u8 = 0xff,
    FrontFace: D3D11_DEPTH_STENCILOP_DESC = .{},
    BackFace: D3D11_DEPTH_STENCILOP_DESC = .{},
};

// Shader resource view desc uses a union but we simplify with the most common case
pub const D3D11_TEX2D_SRV = extern struct {
    MostDetailedMip: u32 = 0,
    MipLevels: u32 = 0xffffffff,
};

pub const D3D11_SHADER_RESOURCE_VIEW_DESC = extern struct {
    Format: DXGI_FORMAT = .UNKNOWN,
    ViewDimension: D3D11_SRV_DIMENSION = .UNKNOWN,
    // Union — we use the Texture2D variant as it's most common.
    // Other union members share the same or smaller layout.
    u: extern union {
        Buffer: extern struct { FirstElement: u32, NumElements: u32 },
        Texture1D: extern struct { MostDetailedMip: u32, MipLevels: u32 },
        Texture2D: D3D11_TEX2D_SRV,
        Texture3D: extern struct { MostDetailedMip: u32, MipLevels: u32 },
        TextureCube: extern struct { MostDetailedMip: u32, MipLevels: u32 },
        Texture1DArray: extern struct { MostDetailedMip: u32, MipLevels: u32, FirstArraySlice: u32, ArraySize: u32 },
        Texture2DArray: extern struct { MostDetailedMip: u32, MipLevels: u32, FirstArraySlice: u32, ArraySize: u32 },
        Texture2DMS: extern struct { UnusedField_NothingToDefine: u32 },
        Texture2DMSArray: extern struct { FirstArraySlice: u32, ArraySize: u32 },
        TextureCubeArray: extern struct { MostDetailedMip: u32, MipLevels: u32, First2DArrayFace: u32, NumCubes: u32 },
        BufferEx: extern struct { FirstElement: u32, NumElements: u32, Flags: u32 },
    } = .{ .Texture2D = .{} },
};

pub const D3D11_TEX2D_RTV = extern struct {
    MipSlice: u32 = 0,
};

pub const D3D11_RENDER_TARGET_VIEW_DESC = extern struct {
    Format: DXGI_FORMAT = .UNKNOWN,
    ViewDimension: D3D11_RTV_DIMENSION = .UNKNOWN,
    u: extern union {
        Buffer: extern struct { FirstElement: u32, NumElements: u32 },
        Texture1D: extern struct { MipSlice: u32 },
        Texture1DArray: extern struct { MipSlice: u32, FirstArraySlice: u32, ArraySize: u32 },
        Texture2D: D3D11_TEX2D_RTV,
        Texture2DArray: extern struct { MipSlice: u32, FirstArraySlice: u32, ArraySize: u32 },
        Texture2DMS: extern struct { UnusedField_NothingToDefine: u32 },
        Texture2DMSArray: extern struct { FirstArraySlice: u32, ArraySize: u32 },
        Texture3D: extern struct { MipSlice: u32, FirstWSlice: u32, WSize: u32 },
    } = .{ .Texture2D = .{} },
};

// ============================================================================
// COM Interfaces
// ============================================================================

/// ID3D11DeviceChild — inherits IUnknown
/// Base for many D3D11 objects.
pub const ID3D11DeviceChild = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        // IUnknown (3)
        QueryInterface: *const fn (*ID3D11DeviceChild, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (*ID3D11DeviceChild) callconv(.C) u32,
        Release: *const fn (*ID3D11DeviceChild) callconv(.C) u32,
        // ID3D11DeviceChild (3)
        GetDevice: *const fn (*ID3D11DeviceChild, *?*anyopaque) callconv(.C) void,
        GetPrivateData: *const fn (*ID3D11DeviceChild, *const GUID, *u32, ?*anyopaque) callconv(.C) HRESULT,
        SetPrivateData: *const fn (*ID3D11DeviceChild, *const GUID, u32, ?*const anyopaque) callconv(.C) HRESULT,
        SetPrivateDataInterface: *const fn (*ID3D11DeviceChild, *const GUID, ?*const anyopaque) callconv(.C) HRESULT,
    };

    pub fn Release(self: *ID3D11DeviceChild) u32 {
        return self.vtable.Release(self);
    }
};

/// ID3D11Resource — inherits ID3D11DeviceChild
pub const ID3D11Resource = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        // IUnknown (3)
        QueryInterface: *const fn (*ID3D11Resource, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (*ID3D11Resource) callconv(.C) u32,
        Release: *const fn (*ID3D11Resource) callconv(.C) u32,
        // ID3D11DeviceChild (4)
        GetDevice: *const fn (*ID3D11Resource, *?*anyopaque) callconv(.C) void,
        GetPrivateData: *const fn (*ID3D11Resource, *const GUID, *u32, ?*anyopaque) callconv(.C) HRESULT,
        SetPrivateData: *const fn (*ID3D11Resource, *const GUID, u32, ?*const anyopaque) callconv(.C) HRESULT,
        SetPrivateDataInterface: *const fn (*ID3D11Resource, *const GUID, ?*const anyopaque) callconv(.C) HRESULT,
        // ID3D11Resource (3)
        GetType: *const fn (*ID3D11Resource, *D3D11_RESOURCE_DIMENSION) callconv(.C) void,
        SetEvictionPriority: *const fn (*ID3D11Resource, u32) callconv(.C) void,
        GetEvictionPriority: *const fn (*ID3D11Resource) callconv(.C) u32,
    };

    pub fn Release(self: *ID3D11Resource) u32 {
        return self.vtable.Release(self);
    }
};

/// ID3D11Buffer — inherits ID3D11Resource
pub const ID3D11Buffer = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        // IUnknown (3)
        QueryInterface: *const fn (*ID3D11Buffer, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (*ID3D11Buffer) callconv(.C) u32,
        Release: *const fn (*ID3D11Buffer) callconv(.C) u32,
        // ID3D11DeviceChild (4)
        GetDevice: *const fn (*ID3D11Buffer, *?*anyopaque) callconv(.C) void,
        GetPrivateData: *const fn (*ID3D11Buffer, *const GUID, *u32, ?*anyopaque) callconv(.C) HRESULT,
        SetPrivateData: *const fn (*ID3D11Buffer, *const GUID, u32, ?*const anyopaque) callconv(.C) HRESULT,
        SetPrivateDataInterface: *const fn (*ID3D11Buffer, *const GUID, ?*const anyopaque) callconv(.C) HRESULT,
        // ID3D11Resource (3)
        GetType: *const fn (*ID3D11Buffer, *D3D11_RESOURCE_DIMENSION) callconv(.C) void,
        SetEvictionPriority: *const fn (*ID3D11Buffer, u32) callconv(.C) void,
        GetEvictionPriority: *const fn (*ID3D11Buffer) callconv(.C) u32,
        // ID3D11Buffer (1)
        GetDesc: *const fn (*ID3D11Buffer, *D3D11_BUFFER_DESC) callconv(.C) void,
    };

    pub fn Release(self: *ID3D11Buffer) u32 {
        return self.vtable.Release(self);
    }
};

/// ID3D11Texture2D — inherits ID3D11Resource
pub const ID3D11Texture2D = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        // IUnknown (3)
        QueryInterface: *const fn (*ID3D11Texture2D, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (*ID3D11Texture2D) callconv(.C) u32,
        Release: *const fn (*ID3D11Texture2D) callconv(.C) u32,
        // ID3D11DeviceChild (4)
        GetDevice: *const fn (*ID3D11Texture2D, *?*anyopaque) callconv(.C) void,
        GetPrivateData: *const fn (*ID3D11Texture2D, *const GUID, *u32, ?*anyopaque) callconv(.C) HRESULT,
        SetPrivateData: *const fn (*ID3D11Texture2D, *const GUID, u32, ?*const anyopaque) callconv(.C) HRESULT,
        SetPrivateDataInterface: *const fn (*ID3D11Texture2D, *const GUID, ?*const anyopaque) callconv(.C) HRESULT,
        // ID3D11Resource (3)
        GetType: *const fn (*ID3D11Texture2D, *D3D11_RESOURCE_DIMENSION) callconv(.C) void,
        SetEvictionPriority: *const fn (*ID3D11Texture2D, u32) callconv(.C) void,
        GetEvictionPriority: *const fn (*ID3D11Texture2D) callconv(.C) u32,
        // ID3D11Texture2D (1)
        GetDesc: *const fn (*ID3D11Texture2D, *D3D11_TEXTURE2D_DESC) callconv(.C) void,
    };

    pub fn Release(self: *ID3D11Texture2D) u32 {
        return self.vtable.Release(self);
    }

    pub fn GetDesc(self: *ID3D11Texture2D, desc: *D3D11_TEXTURE2D_DESC) void {
        self.vtable.GetDesc(self, desc);
    }
};

/// ID3D11View — inherits ID3D11DeviceChild
pub const ID3D11View = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        // IUnknown (3)
        QueryInterface: *const fn (*ID3D11View, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (*ID3D11View) callconv(.C) u32,
        Release: *const fn (*ID3D11View) callconv(.C) u32,
        // ID3D11DeviceChild (4)
        GetDevice: *const fn (*ID3D11View, *?*anyopaque) callconv(.C) void,
        GetPrivateData: *const fn (*ID3D11View, *const GUID, *u32, ?*anyopaque) callconv(.C) HRESULT,
        SetPrivateData: *const fn (*ID3D11View, *const GUID, u32, ?*const anyopaque) callconv(.C) HRESULT,
        SetPrivateDataInterface: *const fn (*ID3D11View, *const GUID, ?*const anyopaque) callconv(.C) HRESULT,
        // ID3D11View (1)
        GetResource: *const fn (*ID3D11View, *?*ID3D11Resource) callconv(.C) void,
    };

    pub fn Release(self: *ID3D11View) u32 {
        return self.vtable.Release(self);
    }
};

/// ID3D11ShaderResourceView — inherits ID3D11View
pub const ID3D11ShaderResourceView = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        // IUnknown (3)
        QueryInterface: *const fn (*ID3D11ShaderResourceView, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (*ID3D11ShaderResourceView) callconv(.C) u32,
        Release: *const fn (*ID3D11ShaderResourceView) callconv(.C) u32,
        // ID3D11DeviceChild (4)
        GetDevice: *const fn (*ID3D11ShaderResourceView, *?*anyopaque) callconv(.C) void,
        GetPrivateData: *const fn (*ID3D11ShaderResourceView, *const GUID, *u32, ?*anyopaque) callconv(.C) HRESULT,
        SetPrivateData: *const fn (*ID3D11ShaderResourceView, *const GUID, u32, ?*const anyopaque) callconv(.C) HRESULT,
        SetPrivateDataInterface: *const fn (*ID3D11ShaderResourceView, *const GUID, ?*const anyopaque) callconv(.C) HRESULT,
        // ID3D11View (1)
        GetResource: *const fn (*ID3D11ShaderResourceView, *?*ID3D11Resource) callconv(.C) void,
        // ID3D11ShaderResourceView (1)
        GetDesc: *const fn (*ID3D11ShaderResourceView, *D3D11_SHADER_RESOURCE_VIEW_DESC) callconv(.C) void,
    };

    pub fn Release(self: *ID3D11ShaderResourceView) u32 {
        return self.vtable.Release(self);
    }
};

/// ID3D11RenderTargetView — inherits ID3D11View
pub const ID3D11RenderTargetView = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        // IUnknown (3)
        QueryInterface: *const fn (*ID3D11RenderTargetView, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (*ID3D11RenderTargetView) callconv(.C) u32,
        Release: *const fn (*ID3D11RenderTargetView) callconv(.C) u32,
        // ID3D11DeviceChild (4)
        GetDevice: *const fn (*ID3D11RenderTargetView, *?*anyopaque) callconv(.C) void,
        GetPrivateData: *const fn (*ID3D11RenderTargetView, *const GUID, *u32, ?*anyopaque) callconv(.C) HRESULT,
        SetPrivateData: *const fn (*ID3D11RenderTargetView, *const GUID, u32, ?*const anyopaque) callconv(.C) HRESULT,
        SetPrivateDataInterface: *const fn (*ID3D11RenderTargetView, *const GUID, ?*const anyopaque) callconv(.C) HRESULT,
        // ID3D11View (1)
        GetResource: *const fn (*ID3D11RenderTargetView, *?*ID3D11Resource) callconv(.C) void,
        // ID3D11RenderTargetView (1)
        GetDesc: *const fn (*ID3D11RenderTargetView, *D3D11_RENDER_TARGET_VIEW_DESC) callconv(.C) void,
    };

    pub fn Release(self: *ID3D11RenderTargetView) u32 {
        return self.vtable.Release(self);
    }
};

/// ID3D11DepthStencilView — inherits ID3D11View
pub const ID3D11DepthStencilView = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        // IUnknown (3)
        QueryInterface: *const fn (*ID3D11DepthStencilView, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (*ID3D11DepthStencilView) callconv(.C) u32,
        Release: *const fn (*ID3D11DepthStencilView) callconv(.C) u32,
        // ID3D11DeviceChild (4)
        GetDevice: *const fn (*ID3D11DepthStencilView, *?*anyopaque) callconv(.C) void,
        GetPrivateData: *const fn (*ID3D11DepthStencilView, *const GUID, *u32, ?*anyopaque) callconv(.C) HRESULT,
        SetPrivateData: *const fn (*ID3D11DepthStencilView, *const GUID, u32, ?*const anyopaque) callconv(.C) HRESULT,
        SetPrivateDataInterface: *const fn (*ID3D11DepthStencilView, *const GUID, ?*const anyopaque) callconv(.C) HRESULT,
        // ID3D11View (1)
        GetResource: *const fn (*ID3D11DepthStencilView, *?*ID3D11Resource) callconv(.C) void,
        // ID3D11DepthStencilView (1)
        GetDesc: *const fn (*ID3D11DepthStencilView, *anyopaque) callconv(.C) void,
    };

    pub fn Release(self: *ID3D11DepthStencilView) u32 {
        return self.vtable.Release(self);
    }
};

/// ID3D11VertexShader — inherits ID3D11DeviceChild (no additional methods)
pub const ID3D11VertexShader = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        // IUnknown (3)
        QueryInterface: *const fn (*ID3D11VertexShader, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (*ID3D11VertexShader) callconv(.C) u32,
        Release: *const fn (*ID3D11VertexShader) callconv(.C) u32,
        // ID3D11DeviceChild (4)
        GetDevice: *const fn (*ID3D11VertexShader, *?*anyopaque) callconv(.C) void,
        GetPrivateData: *const fn (*ID3D11VertexShader, *const GUID, *u32, ?*anyopaque) callconv(.C) HRESULT,
        SetPrivateData: *const fn (*ID3D11VertexShader, *const GUID, u32, ?*const anyopaque) callconv(.C) HRESULT,
        SetPrivateDataInterface: *const fn (*ID3D11VertexShader, *const GUID, ?*const anyopaque) callconv(.C) HRESULT,
    };

    pub fn Release(self: *ID3D11VertexShader) u32 {
        return self.vtable.Release(self);
    }
};

/// ID3D11PixelShader — inherits ID3D11DeviceChild (no additional methods)
pub const ID3D11PixelShader = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        // IUnknown (3)
        QueryInterface: *const fn (*ID3D11PixelShader, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (*ID3D11PixelShader) callconv(.C) u32,
        Release: *const fn (*ID3D11PixelShader) callconv(.C) u32,
        // ID3D11DeviceChild (4)
        GetDevice: *const fn (*ID3D11PixelShader, *?*anyopaque) callconv(.C) void,
        GetPrivateData: *const fn (*ID3D11PixelShader, *const GUID, *u32, ?*anyopaque) callconv(.C) HRESULT,
        SetPrivateData: *const fn (*ID3D11PixelShader, *const GUID, u32, ?*const anyopaque) callconv(.C) HRESULT,
        SetPrivateDataInterface: *const fn (*ID3D11PixelShader, *const GUID, ?*const anyopaque) callconv(.C) HRESULT,
    };

    pub fn Release(self: *ID3D11PixelShader) u32 {
        return self.vtable.Release(self);
    }
};

/// ID3D11InputLayout — inherits ID3D11DeviceChild (no additional methods)
pub const ID3D11InputLayout = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        // IUnknown (3)
        QueryInterface: *const fn (*ID3D11InputLayout, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (*ID3D11InputLayout) callconv(.C) u32,
        Release: *const fn (*ID3D11InputLayout) callconv(.C) u32,
        // ID3D11DeviceChild (4)
        GetDevice: *const fn (*ID3D11InputLayout, *?*anyopaque) callconv(.C) void,
        GetPrivateData: *const fn (*ID3D11InputLayout, *const GUID, *u32, ?*anyopaque) callconv(.C) HRESULT,
        SetPrivateData: *const fn (*ID3D11InputLayout, *const GUID, u32, ?*const anyopaque) callconv(.C) HRESULT,
        SetPrivateDataInterface: *const fn (*ID3D11InputLayout, *const GUID, ?*const anyopaque) callconv(.C) HRESULT,
    };

    pub fn Release(self: *ID3D11InputLayout) u32 {
        return self.vtable.Release(self);
    }
};

/// ID3D11SamplerState — inherits ID3D11DeviceChild
pub const ID3D11SamplerState = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        // IUnknown (3)
        QueryInterface: *const fn (*ID3D11SamplerState, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (*ID3D11SamplerState) callconv(.C) u32,
        Release: *const fn (*ID3D11SamplerState) callconv(.C) u32,
        // ID3D11DeviceChild (4)
        GetDevice: *const fn (*ID3D11SamplerState, *?*anyopaque) callconv(.C) void,
        GetPrivateData: *const fn (*ID3D11SamplerState, *const GUID, *u32, ?*anyopaque) callconv(.C) HRESULT,
        SetPrivateData: *const fn (*ID3D11SamplerState, *const GUID, u32, ?*const anyopaque) callconv(.C) HRESULT,
        SetPrivateDataInterface: *const fn (*ID3D11SamplerState, *const GUID, ?*const anyopaque) callconv(.C) HRESULT,
        // ID3D11SamplerState (1)
        GetDesc: *const fn (*ID3D11SamplerState, *D3D11_SAMPLER_DESC) callconv(.C) void,
    };

    pub fn Release(self: *ID3D11SamplerState) u32 {
        return self.vtable.Release(self);
    }
};

/// ID3D11BlendState — inherits ID3D11DeviceChild
pub const ID3D11BlendState = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        // IUnknown (3)
        QueryInterface: *const fn (*ID3D11BlendState, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (*ID3D11BlendState) callconv(.C) u32,
        Release: *const fn (*ID3D11BlendState) callconv(.C) u32,
        // ID3D11DeviceChild (4)
        GetDevice: *const fn (*ID3D11BlendState, *?*anyopaque) callconv(.C) void,
        GetPrivateData: *const fn (*ID3D11BlendState, *const GUID, *u32, ?*anyopaque) callconv(.C) HRESULT,
        SetPrivateData: *const fn (*ID3D11BlendState, *const GUID, u32, ?*const anyopaque) callconv(.C) HRESULT,
        SetPrivateDataInterface: *const fn (*ID3D11BlendState, *const GUID, ?*const anyopaque) callconv(.C) HRESULT,
        // ID3D11BlendState (1)
        GetDesc: *const fn (*ID3D11BlendState, *D3D11_BLEND_DESC) callconv(.C) void,
    };

    pub fn Release(self: *ID3D11BlendState) u32 {
        return self.vtable.Release(self);
    }
};

/// ID3D11RasterizerState — inherits ID3D11DeviceChild
pub const ID3D11RasterizerState = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        // IUnknown (3)
        QueryInterface: *const fn (*ID3D11RasterizerState, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (*ID3D11RasterizerState) callconv(.C) u32,
        Release: *const fn (*ID3D11RasterizerState) callconv(.C) u32,
        // ID3D11DeviceChild (4)
        GetDevice: *const fn (*ID3D11RasterizerState, *?*anyopaque) callconv(.C) void,
        GetPrivateData: *const fn (*ID3D11RasterizerState, *const GUID, *u32, ?*anyopaque) callconv(.C) HRESULT,
        SetPrivateData: *const fn (*ID3D11RasterizerState, *const GUID, u32, ?*const anyopaque) callconv(.C) HRESULT,
        SetPrivateDataInterface: *const fn (*ID3D11RasterizerState, *const GUID, ?*const anyopaque) callconv(.C) HRESULT,
        // ID3D11RasterizerState (1)
        GetDesc: *const fn (*ID3D11RasterizerState, *D3D11_RASTERIZER_DESC) callconv(.C) void,
    };

    pub fn Release(self: *ID3D11RasterizerState) u32 {
        return self.vtable.Release(self);
    }
};

/// ID3D11DepthStencilState — inherits ID3D11DeviceChild
pub const ID3D11DepthStencilState = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        // IUnknown (3)
        QueryInterface: *const fn (*ID3D11DepthStencilState, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (*ID3D11DepthStencilState) callconv(.C) u32,
        Release: *const fn (*ID3D11DepthStencilState) callconv(.C) u32,
        // ID3D11DeviceChild (4)
        GetDevice: *const fn (*ID3D11DepthStencilState, *?*anyopaque) callconv(.C) void,
        GetPrivateData: *const fn (*ID3D11DepthStencilState, *const GUID, *u32, ?*anyopaque) callconv(.C) HRESULT,
        SetPrivateData: *const fn (*ID3D11DepthStencilState, *const GUID, u32, ?*const anyopaque) callconv(.C) HRESULT,
        SetPrivateDataInterface: *const fn (*ID3D11DepthStencilState, *const GUID, ?*const anyopaque) callconv(.C) HRESULT,
        // ID3D11DepthStencilState (1)
        GetDesc: *const fn (*ID3D11DepthStencilState, *D3D11_DEPTH_STENCIL_DESC) callconv(.C) void,
    };

    pub fn Release(self: *ID3D11DepthStencilState) u32 {
        return self.vtable.Release(self);
    }
};

/// ID3D11DeviceContext — inherits ID3D11DeviceChild
/// This is the largest vtable. The methods are listed in exact SDK order.
/// From d3d11.h: ID3D11DeviceContext inherits ID3D11DeviceChild.
/// Vtable order: IUnknown(3) + ID3D11DeviceChild(4) + ID3D11DeviceContext methods
pub const ID3D11DeviceContext = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        // IUnknown (3)
        QueryInterface: *const fn (*ID3D11DeviceContext, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (*ID3D11DeviceContext) callconv(.C) u32,
        Release: *const fn (*ID3D11DeviceContext) callconv(.C) u32,
        // ID3D11DeviceChild (4)
        GetDevice: *const fn (*ID3D11DeviceContext, *?*anyopaque) callconv(.C) void,
        GetPrivateData: *const fn (*ID3D11DeviceContext, *const GUID, *u32, ?*anyopaque) callconv(.C) HRESULT,
        SetPrivateData: *const fn (*ID3D11DeviceContext, *const GUID, u32, ?*const anyopaque) callconv(.C) HRESULT,
        SetPrivateDataInterface: *const fn (*ID3D11DeviceContext, *const GUID, ?*const anyopaque) callconv(.C) HRESULT,

        // ID3D11DeviceContext methods in vtable order (from d3d11.h)
        // Slot 7
        VSSetConstantBuffers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]const ?*ID3D11Buffer) callconv(.C) void,
        // Slot 8
        PSSetShaderResources: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]const ?*ID3D11ShaderResourceView) callconv(.C) void,
        // Slot 9
        PSSetShader: *const fn (*ID3D11DeviceContext, ?*ID3D11PixelShader, ?[*]const ?*anyopaque, u32) callconv(.C) void,
        // Slot 10
        PSSetSamplers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]const ?*ID3D11SamplerState) callconv(.C) void,
        // Slot 11
        VSSetShader: *const fn (*ID3D11DeviceContext, ?*ID3D11VertexShader, ?[*]const ?*anyopaque, u32) callconv(.C) void,
        // Slot 12
        DrawIndexed: *const fn (*ID3D11DeviceContext, u32, u32, i32) callconv(.C) void,
        // Slot 13
        Draw: *const fn (*ID3D11DeviceContext, u32, u32) callconv(.C) void,
        // Slot 14
        Map: *const fn (*ID3D11DeviceContext, *anyopaque, u32, D3D11_MAP, u32, *D3D11_MAPPED_SUBRESOURCE) callconv(.C) HRESULT,
        // Slot 15
        Unmap: *const fn (*ID3D11DeviceContext, *anyopaque, u32) callconv(.C) void,
        // Slot 16
        PSSetConstantBuffers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]const ?*ID3D11Buffer) callconv(.C) void,
        // Slot 17
        IASetInputLayout: *const fn (*ID3D11DeviceContext, ?*ID3D11InputLayout) callconv(.C) void,
        // Slot 18
        IASetVertexBuffers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]const ?*ID3D11Buffer, ?[*]const u32, ?[*]const u32) callconv(.C) void,
        // Slot 19
        IASetIndexBuffer: *const fn (*ID3D11DeviceContext, ?*ID3D11Buffer, DXGI_FORMAT, u32) callconv(.C) void,
        // Slot 20
        DrawIndexedInstanced: *const fn (*ID3D11DeviceContext, u32, u32, u32, i32, u32) callconv(.C) void,
        // Slot 21
        DrawInstanced: *const fn (*ID3D11DeviceContext, u32, u32, u32, u32) callconv(.C) void,
        // Slot 22
        GSSetConstantBuffers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]const ?*ID3D11Buffer) callconv(.C) void,
        // Slot 23
        GSSetShader: *const fn (*ID3D11DeviceContext, ?*anyopaque, ?[*]const ?*anyopaque, u32) callconv(.C) void,
        // Slot 24
        IASetPrimitiveTopology: *const fn (*ID3D11DeviceContext, D3D11_PRIMITIVE_TOPOLOGY) callconv(.C) void,
        // Slot 25
        VSSetShaderResources: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]const ?*ID3D11ShaderResourceView) callconv(.C) void,
        // Slot 26
        VSSetSamplers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]const ?*ID3D11SamplerState) callconv(.C) void,
        // Slot 27
        Begin: *const fn (*ID3D11DeviceContext, ?*anyopaque) callconv(.C) void,
        // Slot 28
        End: *const fn (*ID3D11DeviceContext, ?*anyopaque) callconv(.C) void,
        // Slot 29
        GetData: *const fn (*ID3D11DeviceContext, ?*anyopaque, ?*anyopaque, u32, u32) callconv(.C) HRESULT,
        // Slot 30
        SetPredication: *const fn (*ID3D11DeviceContext, ?*anyopaque, BOOL) callconv(.C) void,
        // Slot 31
        GSSetShaderResources: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]const ?*ID3D11ShaderResourceView) callconv(.C) void,
        // Slot 32
        GSSetSamplers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]const ?*ID3D11SamplerState) callconv(.C) void,
        // Slot 33
        OMSetRenderTargets: *const fn (*ID3D11DeviceContext, u32, ?[*]const ?*ID3D11RenderTargetView, ?*ID3D11DepthStencilView) callconv(.C) void,
        // Slot 34
        OMSetRenderTargetsAndUnorderedAccessViews: *const fn (*ID3D11DeviceContext, u32, ?[*]const ?*ID3D11RenderTargetView, ?*ID3D11DepthStencilView, u32, u32, ?[*]const ?*anyopaque, ?[*]const u32) callconv(.C) void,
        // Slot 35
        OMSetBlendState: *const fn (*ID3D11DeviceContext, ?*ID3D11BlendState, ?*const [4]f32, u32) callconv(.C) void,
        // Slot 36
        OMSetDepthStencilState: *const fn (*ID3D11DeviceContext, ?*ID3D11DepthStencilState, u32) callconv(.C) void,
        // Slot 37
        SOSetTargets: *const fn (*ID3D11DeviceContext, u32, ?[*]const ?*ID3D11Buffer, ?[*]const u32) callconv(.C) void,
        // Slot 38
        DrawAuto: *const fn (*ID3D11DeviceContext) callconv(.C) void,
        // Slot 39
        DrawIndexedInstancedIndirect: *const fn (*ID3D11DeviceContext, ?*ID3D11Buffer, u32) callconv(.C) void,
        // Slot 40
        DrawInstancedIndirect: *const fn (*ID3D11DeviceContext, ?*ID3D11Buffer, u32) callconv(.C) void,
        // Slot 41
        Dispatch: *const fn (*ID3D11DeviceContext, u32, u32, u32) callconv(.C) void,
        // Slot 42
        DispatchIndirect: *const fn (*ID3D11DeviceContext, ?*ID3D11Buffer, u32) callconv(.C) void,
        // Slot 43
        RSSetState: *const fn (*ID3D11DeviceContext, ?*ID3D11RasterizerState) callconv(.C) void,
        // Slot 44
        RSSetViewports: *const fn (*ID3D11DeviceContext, u32, ?[*]const D3D11_VIEWPORT) callconv(.C) void,
        // Slot 45
        RSSetScissorRects: *const fn (*ID3D11DeviceContext, u32, ?[*]const RECT) callconv(.C) void,
        // Slot 46
        CopySubresourceRegion: *const fn (*ID3D11DeviceContext, *anyopaque, u32, u32, u32, u32, *anyopaque, u32, ?*const D3D11_BOX) callconv(.C) void,
        // Slot 47
        CopyResource: *const fn (*ID3D11DeviceContext, *anyopaque, *anyopaque) callconv(.C) void,
        // Slot 48
        UpdateSubresource: *const fn (*ID3D11DeviceContext, *anyopaque, u32, ?*const D3D11_BOX, *const anyopaque, u32, u32) callconv(.C) void,
        // Slot 49
        CopyStructureCount: *const fn (*ID3D11DeviceContext, ?*ID3D11Buffer, u32, ?*anyopaque) callconv(.C) void,
        // Slot 50
        ClearRenderTargetView: *const fn (*ID3D11DeviceContext, *ID3D11RenderTargetView, *const [4]f32) callconv(.C) void,
        // Slot 51
        ClearUnorderedAccessViewUint: *const fn (*ID3D11DeviceContext, ?*anyopaque, *const [4]u32) callconv(.C) void,
        // Slot 52
        ClearUnorderedAccessViewFloat: *const fn (*ID3D11DeviceContext, ?*anyopaque, *const [4]f32) callconv(.C) void,
        // Slot 53
        ClearDepthStencilView: *const fn (*ID3D11DeviceContext, ?*ID3D11DepthStencilView, u32, f32, u8) callconv(.C) void,
        // Slot 54
        GenerateMips: *const fn (*ID3D11DeviceContext, ?*ID3D11ShaderResourceView) callconv(.C) void,
        // Slot 55
        SetResourceMinLOD: *const fn (*ID3D11DeviceContext, ?*anyopaque, f32) callconv(.C) void,
        // Slot 56
        GetResourceMinLOD: *const fn (*ID3D11DeviceContext, ?*anyopaque) callconv(.C) f32,
        // Slot 57
        ResolveSubresource: *const fn (*ID3D11DeviceContext, *anyopaque, u32, *anyopaque, u32, DXGI_FORMAT) callconv(.C) void,
        // Slot 58
        ExecuteCommandList: *const fn (*ID3D11DeviceContext, ?*anyopaque, BOOL) callconv(.C) void,
        // Slot 59
        HSSetShaderResources: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]const ?*ID3D11ShaderResourceView) callconv(.C) void,
        // Slot 60
        HSSetShader: *const fn (*ID3D11DeviceContext, ?*anyopaque, ?[*]const ?*anyopaque, u32) callconv(.C) void,
        // Slot 61
        HSSetSamplers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]const ?*ID3D11SamplerState) callconv(.C) void,
        // Slot 62
        HSSetConstantBuffers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]const ?*ID3D11Buffer) callconv(.C) void,
        // Slot 63
        DSSetShaderResources: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]const ?*ID3D11ShaderResourceView) callconv(.C) void,
        // Slot 64
        DSSetShader: *const fn (*ID3D11DeviceContext, ?*anyopaque, ?[*]const ?*anyopaque, u32) callconv(.C) void,
        // Slot 65
        DSSetSamplers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]const ?*ID3D11SamplerState) callconv(.C) void,
        // Slot 66
        DSSetConstantBuffers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]const ?*ID3D11Buffer) callconv(.C) void,
        // Slot 67
        CSSetShaderResources: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]const ?*ID3D11ShaderResourceView) callconv(.C) void,
        // Slot 68
        CSSetUnorderedAccessViews: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]const ?*anyopaque, ?[*]const u32) callconv(.C) void,
        // Slot 69
        CSSetShader: *const fn (*ID3D11DeviceContext, ?*anyopaque, ?[*]const ?*anyopaque, u32) callconv(.C) void,
        // Slot 70
        CSSetSamplers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]const ?*ID3D11SamplerState) callconv(.C) void,
        // Slot 71
        CSSetConstantBuffers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]const ?*ID3D11Buffer) callconv(.C) void,
        // Slot 72
        VSGetConstantBuffers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]?*ID3D11Buffer) callconv(.C) void,
        // Slot 73
        PSGetShaderResources: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]?*ID3D11ShaderResourceView) callconv(.C) void,
        // Slot 74
        PSGetShader: *const fn (*ID3D11DeviceContext, *?*ID3D11PixelShader, ?[*]?*anyopaque, *u32) callconv(.C) void,
        // Slot 75
        PSGetSamplers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]?*ID3D11SamplerState) callconv(.C) void,
        // Slot 76
        VSGetShader: *const fn (*ID3D11DeviceContext, *?*ID3D11VertexShader, ?[*]?*anyopaque, *u32) callconv(.C) void,
        // Slot 77
        PSGetConstantBuffers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]?*ID3D11Buffer) callconv(.C) void,
        // Slot 78
        IAGetInputLayout: *const fn (*ID3D11DeviceContext, *?*ID3D11InputLayout) callconv(.C) void,
        // Slot 79
        IAGetVertexBuffers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]?*ID3D11Buffer, ?[*]u32, ?[*]u32) callconv(.C) void,
        // Slot 80
        IAGetIndexBuffer: *const fn (*ID3D11DeviceContext, *?*ID3D11Buffer, *DXGI_FORMAT, *u32) callconv(.C) void,
        // Slot 81
        GSGetConstantBuffers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]?*ID3D11Buffer) callconv(.C) void,
        // Slot 82
        GSGetShader: *const fn (*ID3D11DeviceContext, *?*anyopaque, ?[*]?*anyopaque, *u32) callconv(.C) void,
        // Slot 83
        IAGetPrimitiveTopology: *const fn (*ID3D11DeviceContext, *D3D11_PRIMITIVE_TOPOLOGY) callconv(.C) void,
        // Slot 84
        VSGetShaderResources: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]?*ID3D11ShaderResourceView) callconv(.C) void,
        // Slot 85
        VSGetSamplers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]?*ID3D11SamplerState) callconv(.C) void,
        // Slot 86
        GetPredication: *const fn (*ID3D11DeviceContext, ?*?*anyopaque, ?*BOOL) callconv(.C) void,
        // Slot 87
        GSGetShaderResources: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]?*ID3D11ShaderResourceView) callconv(.C) void,
        // Slot 88
        GSGetSamplers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]?*ID3D11SamplerState) callconv(.C) void,
        // Slot 89
        OMGetRenderTargets: *const fn (*ID3D11DeviceContext, u32, ?[*]?*ID3D11RenderTargetView, ?*?*ID3D11DepthStencilView) callconv(.C) void,
        // Slot 90
        OMGetRenderTargetsAndUnorderedAccessViews: *const fn (*ID3D11DeviceContext, u32, ?[*]?*ID3D11RenderTargetView, ?*?*ID3D11DepthStencilView, u32, u32, ?[*]?*anyopaque) callconv(.C) void,
        // Slot 91
        OMGetBlendState: *const fn (*ID3D11DeviceContext, ?*?*ID3D11BlendState, ?*[4]f32, ?*u32) callconv(.C) void,
        // Slot 92
        OMGetDepthStencilState: *const fn (*ID3D11DeviceContext, ?*?*ID3D11DepthStencilState, ?*u32) callconv(.C) void,
        // Slot 93
        SOGetTargets: *const fn (*ID3D11DeviceContext, u32, ?[*]?*ID3D11Buffer) callconv(.C) void,
        // Slot 94
        RSGetState: *const fn (*ID3D11DeviceContext, *?*ID3D11RasterizerState) callconv(.C) void,
        // Slot 95
        RSGetViewports: *const fn (*ID3D11DeviceContext, *u32, ?[*]D3D11_VIEWPORT) callconv(.C) void,
        // Slot 96
        RSGetScissorRects: *const fn (*ID3D11DeviceContext, *u32, ?[*]RECT) callconv(.C) void,
        // Slot 97
        HSGetShaderResources: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]?*ID3D11ShaderResourceView) callconv(.C) void,
        // Slot 98
        HSGetShader: *const fn (*ID3D11DeviceContext, *?*anyopaque, ?[*]?*anyopaque, *u32) callconv(.C) void,
        // Slot 99
        HSGetSamplers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]?*ID3D11SamplerState) callconv(.C) void,
        // Slot 100
        HSGetConstantBuffers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]?*ID3D11Buffer) callconv(.C) void,
        // Slot 101
        DSGetShaderResources: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]?*ID3D11ShaderResourceView) callconv(.C) void,
        // Slot 102
        DSGetShader: *const fn (*ID3D11DeviceContext, *?*anyopaque, ?[*]?*anyopaque, *u32) callconv(.C) void,
        // Slot 103
        DSGetSamplers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]?*ID3D11SamplerState) callconv(.C) void,
        // Slot 104
        DSGetConstantBuffers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]?*ID3D11Buffer) callconv(.C) void,
        // Slot 105
        CSGetShaderResources: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]?*ID3D11ShaderResourceView) callconv(.C) void,
        // Slot 106
        CSGetUnorderedAccessViews: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]?*anyopaque) callconv(.C) void,
        // Slot 107
        CSGetShader: *const fn (*ID3D11DeviceContext, *?*anyopaque, ?[*]?*anyopaque, *u32) callconv(.C) void,
        // Slot 108
        CSGetSamplers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]?*ID3D11SamplerState) callconv(.C) void,
        // Slot 109
        CSGetConstantBuffers: *const fn (*ID3D11DeviceContext, u32, u32, ?[*]?*ID3D11Buffer) callconv(.C) void,
        // Slot 110
        ClearState: *const fn (*ID3D11DeviceContext) callconv(.C) void,
        // Slot 111
        Flush: *const fn (*ID3D11DeviceContext) callconv(.C) void,
        // Slot 112
        GetType: *const fn (*ID3D11DeviceContext) callconv(.C) u32,
        // Slot 113
        GetContextFlags: *const fn (*ID3D11DeviceContext) callconv(.C) u32,
        // Slot 114
        FinishCommandList: *const fn (*ID3D11DeviceContext, BOOL, *?*anyopaque) callconv(.C) HRESULT,
    };

    // Convenience methods

    pub fn Release(self: *ID3D11DeviceContext) u32 {
        return self.vtable.Release(self);
    }

    pub fn VSSetConstantBuffers(self: *ID3D11DeviceContext, start_slot: u32, num_buffers: u32, buffers: ?[*]const ?*ID3D11Buffer) void {
        self.vtable.VSSetConstantBuffers(self, start_slot, num_buffers, buffers);
    }

    pub fn PSSetShaderResources(self: *ID3D11DeviceContext, start_slot: u32, num_views: u32, views: ?[*]const ?*ID3D11ShaderResourceView) void {
        self.vtable.PSSetShaderResources(self, start_slot, num_views, views);
    }

    pub fn PSSetShader(self: *ID3D11DeviceContext, shader: ?*ID3D11PixelShader, class_instances: ?[*]const ?*anyopaque, num_class_instances: u32) void {
        self.vtable.PSSetShader(self, shader, class_instances, num_class_instances);
    }

    pub fn PSSetSamplers(self: *ID3D11DeviceContext, start_slot: u32, num_samplers: u32, samplers: ?[*]const ?*ID3D11SamplerState) void {
        self.vtable.PSSetSamplers(self, start_slot, num_samplers, samplers);
    }

    pub fn VSSetShader(self: *ID3D11DeviceContext, shader: ?*ID3D11VertexShader, class_instances: ?[*]const ?*anyopaque, num_class_instances: u32) void {
        self.vtable.VSSetShader(self, shader, class_instances, num_class_instances);
    }

    pub fn DrawIndexed(self: *ID3D11DeviceContext, index_count: u32, start_index_location: u32, base_vertex_location: i32) void {
        self.vtable.DrawIndexed(self, index_count, start_index_location, base_vertex_location);
    }

    pub fn Draw(self: *ID3D11DeviceContext, vertex_count: u32, start_vertex_location: u32) void {
        self.vtable.Draw(self, vertex_count, start_vertex_location);
    }

    pub fn Map(self: *ID3D11DeviceContext, resource: *anyopaque, subresource: u32, map_type: D3D11_MAP, map_flags: u32, mapped: *D3D11_MAPPED_SUBRESOURCE) HRESULT {
        return self.vtable.Map(self, resource, subresource, map_type, map_flags, mapped);
    }

    pub fn Unmap(self: *ID3D11DeviceContext, resource: *anyopaque, subresource: u32) void {
        self.vtable.Unmap(self, resource, subresource);
    }

    pub fn PSSetConstantBuffers(self: *ID3D11DeviceContext, start_slot: u32, num_buffers: u32, buffers: ?[*]const ?*ID3D11Buffer) void {
        self.vtable.PSSetConstantBuffers(self, start_slot, num_buffers, buffers);
    }

    pub fn IASetInputLayout(self: *ID3D11DeviceContext, layout: ?*ID3D11InputLayout) void {
        self.vtable.IASetInputLayout(self, layout);
    }

    pub fn IASetVertexBuffers(self: *ID3D11DeviceContext, start_slot: u32, num_buffers: u32, buffers: ?[*]const ?*ID3D11Buffer, strides: ?[*]const u32, offsets: ?[*]const u32) void {
        self.vtable.IASetVertexBuffers(self, start_slot, num_buffers, buffers, strides, offsets);
    }

    pub fn IASetIndexBuffer(self: *ID3D11DeviceContext, buffer: ?*ID3D11Buffer, format: DXGI_FORMAT, offset: u32) void {
        self.vtable.IASetIndexBuffer(self, buffer, format, offset);
    }

    pub fn DrawInstanced(self: *ID3D11DeviceContext, vertex_count: u32, instance_count: u32, start_vertex: u32, start_instance: u32) void {
        self.vtable.DrawInstanced(self, vertex_count, instance_count, start_vertex, start_instance);
    }

    pub fn IASetPrimitiveTopology(self: *ID3D11DeviceContext, topology: D3D11_PRIMITIVE_TOPOLOGY) void {
        self.vtable.IASetPrimitiveTopology(self, topology);
    }

    pub fn VSSetShaderResources(self: *ID3D11DeviceContext, start_slot: u32, num_views: u32, views: ?[*]const ?*ID3D11ShaderResourceView) void {
        self.vtable.VSSetShaderResources(self, start_slot, num_views, views);
    }

    pub fn OMSetRenderTargets(self: *ID3D11DeviceContext, num_views: u32, render_targets: ?[*]const ?*ID3D11RenderTargetView, depth_stencil: ?*ID3D11DepthStencilView) void {
        self.vtable.OMSetRenderTargets(self, num_views, render_targets, depth_stencil);
    }

    pub fn OMSetBlendState(self: *ID3D11DeviceContext, blend_state: ?*ID3D11BlendState, blend_factor: ?*const [4]f32, sample_mask: u32) void {
        self.vtable.OMSetBlendState(self, blend_state, blend_factor, sample_mask);
    }

    pub fn RSSetViewports(self: *ID3D11DeviceContext, num_viewports: u32, viewports: ?[*]const D3D11_VIEWPORT) void {
        self.vtable.RSSetViewports(self, num_viewports, viewports);
    }

    pub fn ClearRenderTargetView(self: *ID3D11DeviceContext, view: *ID3D11RenderTargetView, color: *const [4]f32) void {
        self.vtable.ClearRenderTargetView(self, view, color);
    }

    pub fn UpdateSubresource(self: *ID3D11DeviceContext, resource: *anyopaque, subresource: u32, box: ?*const D3D11_BOX, data: *const anyopaque, row_pitch: u32, depth_pitch: u32) void {
        self.vtable.UpdateSubresource(self, resource, subresource, box, data, row_pitch, depth_pitch);
    }

    pub fn Flush(self: *ID3D11DeviceContext) void {
        self.vtable.Flush(self);
    }

    pub fn RSSetState(self: *ID3D11DeviceContext, state: ?*ID3D11RasterizerState) void {
        self.vtable.RSSetState(self, state);
    }

    pub fn OMSetDepthStencilState(self: *ID3D11DeviceContext, state: ?*ID3D11DepthStencilState, stencil_ref: u32) void {
        self.vtable.OMSetDepthStencilState(self, state, stencil_ref);
    }

    pub fn ClearState(self: *ID3D11DeviceContext) void {
        self.vtable.ClearState(self);
    }
};

/// ID3D11Device — inherits IUnknown
pub const ID3D11Device = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        // IUnknown (3)
        QueryInterface: *const fn (*ID3D11Device, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (*ID3D11Device) callconv(.C) u32,
        Release: *const fn (*ID3D11Device) callconv(.C) u32,

        // ID3D11Device methods in vtable order (from d3d11.h)
        // Slot 3
        CreateBuffer: *const fn (*ID3D11Device, *const D3D11_BUFFER_DESC, ?*const D3D11_SUBRESOURCE_DATA, ?*?*ID3D11Buffer) callconv(.C) HRESULT,
        // Slot 4
        CreateTexture1D: *const fn (*ID3D11Device, *const anyopaque, ?*const D3D11_SUBRESOURCE_DATA, ?*?*anyopaque) callconv(.C) HRESULT,
        // Slot 5
        CreateTexture2D: *const fn (*ID3D11Device, *const D3D11_TEXTURE2D_DESC, ?*const D3D11_SUBRESOURCE_DATA, ?*?*ID3D11Texture2D) callconv(.C) HRESULT,
        // Slot 6
        CreateTexture3D: *const fn (*ID3D11Device, *const anyopaque, ?*const D3D11_SUBRESOURCE_DATA, ?*?*anyopaque) callconv(.C) HRESULT,
        // Slot 7
        CreateShaderResourceView: *const fn (*ID3D11Device, *anyopaque, ?*const D3D11_SHADER_RESOURCE_VIEW_DESC, ?*?*ID3D11ShaderResourceView) callconv(.C) HRESULT,
        // Slot 8
        CreateUnorderedAccessView: *const fn (*ID3D11Device, *anyopaque, ?*const anyopaque, ?*?*anyopaque) callconv(.C) HRESULT,
        // Slot 9
        CreateRenderTargetView: *const fn (*ID3D11Device, *anyopaque, ?*const D3D11_RENDER_TARGET_VIEW_DESC, ?*?*ID3D11RenderTargetView) callconv(.C) HRESULT,
        // Slot 10
        CreateDepthStencilView: *const fn (*ID3D11Device, *anyopaque, ?*const anyopaque, ?*?*ID3D11DepthStencilView) callconv(.C) HRESULT,
        // Slot 11
        CreateInputLayout: *const fn (*ID3D11Device, [*]const D3D11_INPUT_ELEMENT_DESC, u32, *const anyopaque, usize, ?*?*ID3D11InputLayout) callconv(.C) HRESULT,
        // Slot 12
        CreateVertexShader: *const fn (*ID3D11Device, *const anyopaque, usize, ?*anyopaque, ?*?*ID3D11VertexShader) callconv(.C) HRESULT,
        // Slot 13
        CreateGeometryShader: *const fn (*ID3D11Device, *const anyopaque, usize, ?*anyopaque, ?*?*anyopaque) callconv(.C) HRESULT,
        // Slot 14
        CreateGeometryShaderWithStreamOutput: *const fn (*ID3D11Device, *const anyopaque, usize, ?*const anyopaque, u32, ?*const u32, u32, u32, ?*anyopaque, ?*?*anyopaque) callconv(.C) HRESULT,
        // Slot 15
        CreatePixelShader: *const fn (*ID3D11Device, *const anyopaque, usize, ?*anyopaque, ?*?*ID3D11PixelShader) callconv(.C) HRESULT,
        // Slot 16
        CreateHullShader: *const fn (*ID3D11Device, *const anyopaque, usize, ?*anyopaque, ?*?*anyopaque) callconv(.C) HRESULT,
        // Slot 17
        CreateDomainShader: *const fn (*ID3D11Device, *const anyopaque, usize, ?*anyopaque, ?*?*anyopaque) callconv(.C) HRESULT,
        // Slot 18
        CreateComputeShader: *const fn (*ID3D11Device, *const anyopaque, usize, ?*anyopaque, ?*?*anyopaque) callconv(.C) HRESULT,
        // Slot 19
        CreateClassLinkage: *const fn (*ID3D11Device, ?*?*anyopaque) callconv(.C) HRESULT,
        // Slot 20
        CreateBlendState: *const fn (*ID3D11Device, *const D3D11_BLEND_DESC, ?*?*ID3D11BlendState) callconv(.C) HRESULT,
        // Slot 21
        CreateDepthStencilState: *const fn (*ID3D11Device, *const D3D11_DEPTH_STENCIL_DESC, ?*?*ID3D11DepthStencilState) callconv(.C) HRESULT,
        // Slot 22
        CreateRasterizerState: *const fn (*ID3D11Device, *const D3D11_RASTERIZER_DESC, ?*?*ID3D11RasterizerState) callconv(.C) HRESULT,
        // Slot 23
        CreateSamplerState: *const fn (*ID3D11Device, *const D3D11_SAMPLER_DESC, ?*?*ID3D11SamplerState) callconv(.C) HRESULT,
        // Slot 24
        CreateQuery: *const fn (*ID3D11Device, *const anyopaque, ?*?*anyopaque) callconv(.C) HRESULT,
        // Slot 25
        CreatePredicate: *const fn (*ID3D11Device, *const anyopaque, ?*?*anyopaque) callconv(.C) HRESULT,
        // Slot 26
        CreateCounter: *const fn (*ID3D11Device, *const anyopaque, ?*?*anyopaque) callconv(.C) HRESULT,
        // Slot 27
        CreateDeferredContext: *const fn (*ID3D11Device, u32, ?*?*anyopaque) callconv(.C) HRESULT,
        // Slot 28
        OpenSharedResource: *const fn (*ID3D11Device, ?windows.HANDLE, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        // Slot 29
        CheckFormatSupport: *const fn (*ID3D11Device, DXGI_FORMAT, *u32) callconv(.C) HRESULT,
        // Slot 30
        CheckMultisampleQualityLevels: *const fn (*ID3D11Device, DXGI_FORMAT, u32, *u32) callconv(.C) HRESULT,
        // Slot 31
        CheckCounterInfo: *const fn (*ID3D11Device, *anyopaque) callconv(.C) void,
        // Slot 32
        CheckCounter: *const fn (*ID3D11Device, *const anyopaque, *u32, *u32, ?[*]u8, ?*u32, ?[*]u8, ?*u32, ?[*]u8, ?*u32) callconv(.C) HRESULT,
        // Slot 33
        CheckFeatureSupport: *const fn (*ID3D11Device, u32, *anyopaque, u32) callconv(.C) HRESULT,
        // Slot 34
        GetPrivateData: *const fn (*ID3D11Device, *const GUID, *u32, ?*anyopaque) callconv(.C) HRESULT,
        // Slot 35
        SetPrivateData: *const fn (*ID3D11Device, *const GUID, u32, ?*const anyopaque) callconv(.C) HRESULT,
        // Slot 36
        SetPrivateDataInterface: *const fn (*ID3D11Device, *const GUID, ?*const anyopaque) callconv(.C) HRESULT,
        // Slot 37
        GetFeatureLevel: *const fn (*ID3D11Device) callconv(.C) D3D_FEATURE_LEVEL,
        // Slot 38
        GetCreationFlags: *const fn (*ID3D11Device) callconv(.C) u32,
        // Slot 39
        GetDeviceRemovedReason: *const fn (*ID3D11Device) callconv(.C) HRESULT,
        // Slot 40
        GetImmediateContext: *const fn (*ID3D11Device, *?*ID3D11DeviceContext) callconv(.C) void,
        // Slot 41
        SetExceptionMode: *const fn (*ID3D11Device, u32) callconv(.C) HRESULT,
        // Slot 42
        GetExceptionMode: *const fn (*ID3D11Device) callconv(.C) u32,
    };

    // Convenience methods

    pub fn QueryInterface(self: *ID3D11Device, riid: *const GUID, obj: *?*anyopaque) HRESULT {
        return self.vtable.QueryInterface(self, riid, obj);
    }

    pub fn Release(self: *ID3D11Device) u32 {
        return self.vtable.Release(self);
    }

    pub fn CreateBuffer(self: *ID3D11Device, desc: *const D3D11_BUFFER_DESC, initial_data: ?*const D3D11_SUBRESOURCE_DATA, buffer: ?*?*ID3D11Buffer) HRESULT {
        return self.vtable.CreateBuffer(self, desc, initial_data, buffer);
    }

    pub fn CreateTexture2D(self: *ID3D11Device, desc: *const D3D11_TEXTURE2D_DESC, initial_data: ?*const D3D11_SUBRESOURCE_DATA, texture: ?*?*ID3D11Texture2D) HRESULT {
        return self.vtable.CreateTexture2D(self, desc, initial_data, texture);
    }

    pub fn CreateShaderResourceView(self: *ID3D11Device, resource: *anyopaque, desc: ?*const D3D11_SHADER_RESOURCE_VIEW_DESC, view: ?*?*ID3D11ShaderResourceView) HRESULT {
        return self.vtable.CreateShaderResourceView(self, resource, desc, view);
    }

    pub fn CreateRenderTargetView(self: *ID3D11Device, resource: *anyopaque, desc: ?*const D3D11_RENDER_TARGET_VIEW_DESC, view: ?*?*ID3D11RenderTargetView) HRESULT {
        return self.vtable.CreateRenderTargetView(self, resource, desc, view);
    }

    pub fn CreateDepthStencilView(self: *ID3D11Device, resource: *anyopaque, desc: ?*const anyopaque, view: ?*?*ID3D11DepthStencilView) HRESULT {
        return self.vtable.CreateDepthStencilView(self, resource, desc, view);
    }

    pub fn CreateInputLayout(self: *ID3D11Device, descs: [*]const D3D11_INPUT_ELEMENT_DESC, num_elements: u32, bytecode: *const anyopaque, bytecode_length: usize, layout: ?*?*ID3D11InputLayout) HRESULT {
        return self.vtable.CreateInputLayout(self, descs, num_elements, bytecode, bytecode_length, layout);
    }

    pub fn CreateVertexShader(self: *ID3D11Device, bytecode: *const anyopaque, bytecode_length: usize, class_linkage: ?*anyopaque, shader: ?*?*ID3D11VertexShader) HRESULT {
        return self.vtable.CreateVertexShader(self, bytecode, bytecode_length, class_linkage, shader);
    }

    pub fn CreatePixelShader(self: *ID3D11Device, bytecode: *const anyopaque, bytecode_length: usize, class_linkage: ?*anyopaque, shader: ?*?*ID3D11PixelShader) HRESULT {
        return self.vtable.CreatePixelShader(self, bytecode, bytecode_length, class_linkage, shader);
    }

    pub fn CreateBlendState(self: *ID3D11Device, desc: *const D3D11_BLEND_DESC, state: ?*?*ID3D11BlendState) HRESULT {
        return self.vtable.CreateBlendState(self, desc, state);
    }

    pub fn CreateDepthStencilState(self: *ID3D11Device, desc: *const D3D11_DEPTH_STENCIL_DESC, state: ?*?*ID3D11DepthStencilState) HRESULT {
        return self.vtable.CreateDepthStencilState(self, desc, state);
    }

    pub fn CreateRasterizerState(self: *ID3D11Device, desc: *const D3D11_RASTERIZER_DESC, state: ?*?*ID3D11RasterizerState) HRESULT {
        return self.vtable.CreateRasterizerState(self, desc, state);
    }

    pub fn CreateSamplerState(self: *ID3D11Device, desc: *const D3D11_SAMPLER_DESC, state: ?*?*ID3D11SamplerState) HRESULT {
        return self.vtable.CreateSamplerState(self, desc, state);
    }

    pub fn GetFeatureLevel(self: *ID3D11Device) D3D_FEATURE_LEVEL {
        return self.vtable.GetFeatureLevel(self);
    }

    pub fn GetImmediateContext(self: *ID3D11Device, context: *?*ID3D11DeviceContext) void {
        self.vtable.GetImmediateContext(self, context);
    }

    pub fn GetDeviceRemovedReason(self: *ID3D11Device) HRESULT {
        return self.vtable.GetDeviceRemovedReason(self);
    }
};

// ============================================================================
// Functions
// ============================================================================

pub extern "d3d11" fn D3D11CreateDevice(
    pAdapter: ?*anyopaque,
    DriverType: D3D_DRIVER_TYPE,
    Software: ?*anyopaque,
    Flags: D3D11_CREATE_DEVICE_FLAG,
    pFeatureLevels: ?[*]const D3D_FEATURE_LEVEL,
    FeatureLevels: u32,
    SDKVersion: u32,
    ppDevice: ?*?*ID3D11Device,
    pFeatureLevel: ?*D3D_FEATURE_LEVEL,
    ppImmediateContext: ?*?*ID3D11DeviceContext,
) callconv(.C) HRESULT;

pub const D3D11_SDK_VERSION: u32 = 7;

// ============================================================================
// Tests
// ============================================================================

test "D3D11 struct sizes are nonzero" {
    try std.testing.expect(@sizeOf(D3D11_BUFFER_DESC) > 0);
    try std.testing.expect(@sizeOf(D3D11_TEXTURE2D_DESC) > 0);
    try std.testing.expect(@sizeOf(D3D11_SUBRESOURCE_DATA) > 0);
    try std.testing.expect(@sizeOf(D3D11_INPUT_ELEMENT_DESC) > 0);
    try std.testing.expect(@sizeOf(D3D11_VIEWPORT) > 0);
    try std.testing.expect(@sizeOf(D3D11_BOX) > 0);
    try std.testing.expect(@sizeOf(D3D11_MAPPED_SUBRESOURCE) > 0);
    try std.testing.expect(@sizeOf(D3D11_BLEND_DESC) > 0);
    try std.testing.expect(@sizeOf(D3D11_SAMPLER_DESC) > 0);
    try std.testing.expect(@sizeOf(D3D11_RASTERIZER_DESC) > 0);
    try std.testing.expect(@sizeOf(D3D11_DEPTH_STENCIL_DESC) > 0);
    try std.testing.expect(@sizeOf(D3D11_SHADER_RESOURCE_VIEW_DESC) > 0);
    try std.testing.expect(@sizeOf(D3D11_RENDER_TARGET_VIEW_DESC) > 0);
    try std.testing.expect(@sizeOf(ID3D11Device.VTable) > 0);
    try std.testing.expect(@sizeOf(ID3D11DeviceContext.VTable) > 0);
    try std.testing.expect(@sizeOf(ID3D11Buffer.VTable) > 0);
    try std.testing.expect(@sizeOf(ID3D11Texture2D.VTable) > 0);
    try std.testing.expect(@sizeOf(ID3D11ShaderResourceView.VTable) > 0);
    try std.testing.expect(@sizeOf(ID3D11RenderTargetView.VTable) > 0);
}
