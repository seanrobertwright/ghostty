const std = @import("std");
const windows = std.os.windows;
const GUID = windows.GUID;
const HRESULT = windows.HRESULT;
const BOOL = windows.BOOL;

pub const HWND = *opaque {};

pub const RECT = extern struct {
    left: i32 = 0,
    top: i32 = 0,
    right: i32 = 0,
    bottom: i32 = 0,
};

// ============================================================================
// GUIDs
// ============================================================================

pub const IID_IDXGIFactory2 = GUID{
    .Data1 = 0x50c83a1c,
    .Data2 = 0xe072,
    .Data3 = 0x4c48,
    .Data4 = .{ 0x87, 0xb0, 0x36, 0x30, 0xfa, 0x36, 0xa6, 0xd0 },
};

pub const IID_IDXGISwapChain1 = GUID{
    .Data1 = 0x790a45f7,
    .Data2 = 0x0d42,
    .Data3 = 0x4876,
    .Data4 = .{ 0x98, 0x3a, 0x0a, 0x55, 0xcf, 0xe6, 0xf4, 0xaa },
};

pub const IID_IDXGIDevice = GUID{
    .Data1 = 0x54ec77fa,
    .Data2 = 0x1377,
    .Data3 = 0x44e6,
    .Data4 = .{ 0x8c, 0x32, 0x88, 0xfd, 0x5f, 0x44, 0xc8, 0x4c },
};

// ============================================================================
// Enums and Flags
// ============================================================================

pub const DXGI_FORMAT = enum(u32) {
    UNKNOWN = 0,
    R8G8B8A8_UNORM = 28,
    D24_UNORM_S8_UINT = 45,
    R8_UNORM = 61,
    B8G8R8A8_UNORM = 87,
    _,
};

pub const DXGI_SWAP_EFFECT = enum(u32) {
    DISCARD = 0,
    SEQUENTIAL = 1,
    FLIP_SEQUENTIAL = 3,
    FLIP_DISCARD = 4,
};

pub const DXGI_SCALING = enum(u32) {
    STRETCH = 0,
    NONE = 1,
    ASPECT_RATIO_STRETCH = 2,
};

pub const DXGI_ALPHA_MODE = enum(u32) {
    UNSPECIFIED = 0,
    PREMULTIPLIED = 1,
    STRAIGHT = 2,
    IGNORE = 3,
};

pub const DXGI_MODE_ROTATION = enum(u32) {
    UNSPECIFIED = 0,
    IDENTITY = 1,
    ROTATE90 = 2,
    ROTATE180 = 3,
    ROTATE270 = 4,
};

pub const DXGI_USAGE = u32;
pub const DXGI_USAGE_RENDER_TARGET_OUTPUT: DXGI_USAGE = 0x00000020;
pub const DXGI_USAGE_SHADER_INPUT: DXGI_USAGE = 0x00000010;
pub const DXGI_USAGE_BACK_BUFFER: DXGI_USAGE = 0x00000040;

pub const DXGI_PRESENT_FLAGS = u32;
pub const DXGI_PRESENT_TEST: DXGI_PRESENT_FLAGS = 0x00000001;
pub const DXGI_PRESENT_DO_NOT_SEQUENCE: DXGI_PRESENT_FLAGS = 0x00000002;
pub const DXGI_PRESENT_RESTART: DXGI_PRESENT_FLAGS = 0x00000004;
pub const DXGI_PRESENT_DO_NOT_WAIT: DXGI_PRESENT_FLAGS = 0x00000008;
pub const DXGI_PRESENT_ALLOW_TEARING: DXGI_PRESENT_FLAGS = 0x00000200;

pub const DXGI_SWAP_CHAIN_FLAG = u32;

// ============================================================================
// Structs
// ============================================================================

pub const DXGI_SAMPLE_DESC = extern struct {
    Count: u32 = 1,
    Quality: u32 = 0,
};

pub const DXGI_RATIONAL = extern struct {
    Numerator: u32 = 0,
    Denominator: u32 = 0,
};

pub const DXGI_MODE_DESC = extern struct {
    Width: u32 = 0,
    Height: u32 = 0,
    RefreshRate: DXGI_RATIONAL = .{},
    Format: DXGI_FORMAT = .UNKNOWN,
    ScanlineOrdering: u32 = 0,
    Scaling: u32 = 0,
};

pub const DXGI_SWAP_CHAIN_DESC = extern struct {
    BufferDesc: DXGI_MODE_DESC = .{},
    SampleDesc: DXGI_SAMPLE_DESC = .{},
    BufferUsage: DXGI_USAGE = 0,
    BufferCount: u32 = 0,
    OutputWindow: ?HWND = null,
    Windowed: BOOL = 1,
    SwapEffect: DXGI_SWAP_EFFECT = .DISCARD,
    Flags: u32 = 0,
};

pub const DXGI_SWAP_CHAIN_DESC1 = extern struct {
    Width: u32 = 0,
    Height: u32 = 0,
    Format: DXGI_FORMAT = .B8G8R8A8_UNORM,
    Stereo: BOOL = 0,
    SampleDesc: DXGI_SAMPLE_DESC = .{},
    BufferUsage: DXGI_USAGE = 0,
    BufferCount: u32 = 2,
    Scaling: DXGI_SCALING = .STRETCH,
    SwapEffect: DXGI_SWAP_EFFECT = .FLIP_DISCARD,
    AlphaMode: DXGI_ALPHA_MODE = .UNSPECIFIED,
    Flags: u32 = 0,
};

pub const DXGI_SWAP_CHAIN_FULLSCREEN_DESC = extern struct {
    RefreshRate: DXGI_RATIONAL = .{},
    ScanlineOrdering: u32 = 0,
    Scaling: u32 = 0,
    Windowed: BOOL = 1,
};

pub const DXGI_PRESENT_PARAMETERS = extern struct {
    DirtyRectsCount: u32 = 0,
    pDirtyRects: ?*RECT = null,
    pScrollRect: ?*RECT = null,
    pScrollOffset: ?*POINT = null,
};

pub const POINT = extern struct {
    x: i32 = 0,
    y: i32 = 0,
};

pub const DXGI_ADAPTER_DESC = extern struct {
    Description: [128]u16 = [_]u16{0} ** 128,
    VendorId: u32 = 0,
    DeviceId: u32 = 0,
    SubSysId: u32 = 0,
    Revision: u32 = 0,
    DedicatedVideoMemory: usize = 0,
    DedicatedSystemMemory: usize = 0,
    SharedSystemMemory: usize = 0,
    AdapterLuid: LUID = .{},
};

pub const LUID = extern struct {
    LowPart: u32 = 0,
    HighPart: i32 = 0,
};

pub const DXGI_FRAME_STATISTICS = extern struct {
    PresentCount: u32 = 0,
    PresentRefreshCount: u32 = 0,
    SyncRefreshCount: u32 = 0,
    SyncQPCTime: i64 = 0,
    SyncGPUTime: i64 = 0,
};

pub const DXGI_RGBA = extern struct {
    r: f32 = 0,
    g: f32 = 0,
    b: f32 = 0,
    a: f32 = 0,
};

pub const DXGI_SURFACE_DESC = extern struct {
    Width: u32 = 0,
    Height: u32 = 0,
    Format: DXGI_FORMAT = .UNKNOWN,
    SampleDesc: DXGI_SAMPLE_DESC = .{},
};

pub const DXGI_RESIDENCY = enum(u32) {
    FULLY_RESIDENT = 1,
    RESIDENT_IN_SHARED_MEMORY = 2,
    EVICTED_TO_DISK = 3,
};

pub const DXGI_SHARED_RESOURCE = extern struct {
    Handle: ?windows.HANDLE = null,
};

// ============================================================================
// COM Interfaces
// ============================================================================

/// IDXGIAdapter — inherits IDXGIObject
pub const IDXGIAdapter = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        // IUnknown (3)
        QueryInterface: *const fn (*IDXGIAdapter, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (*IDXGIAdapter) callconv(.C) u32,
        Release: *const fn (*IDXGIAdapter) callconv(.C) u32,
        // IDXGIObject (4)
        SetPrivateData: *const fn (*IDXGIAdapter, *const GUID, u32, ?*const anyopaque) callconv(.C) HRESULT,
        SetPrivateDataInterface: *const fn (*IDXGIAdapter, *const GUID, ?*const anyopaque) callconv(.C) HRESULT,
        GetPrivateData: *const fn (*IDXGIAdapter, *const GUID, *u32, ?*anyopaque) callconv(.C) HRESULT,
        GetParent: *const fn (*IDXGIAdapter, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        // IDXGIAdapter (3)
        EnumOutputs: *const fn (*IDXGIAdapter, u32, *?*anyopaque) callconv(.C) HRESULT,
        GetDesc: *const fn (*IDXGIAdapter, *DXGI_ADAPTER_DESC) callconv(.C) HRESULT,
        CheckInterfaceSupport: *const fn (*IDXGIAdapter, *const GUID, *i64) callconv(.C) HRESULT,
    };

    pub fn Release(self: *IDXGIAdapter) u32 {
        return self.vtable.Release(self);
    }

    pub fn GetDesc(self: *IDXGIAdapter, desc: *DXGI_ADAPTER_DESC) HRESULT {
        return self.vtable.GetDesc(self, desc);
    }

    pub fn GetParent(self: *IDXGIAdapter, riid: *const GUID, parent: *?*anyopaque) HRESULT {
        return self.vtable.GetParent(self, riid, parent);
    }
};

/// IDXGIDevice — inherits IDXGIObject
pub const IDXGIDevice = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        // IUnknown (3)
        QueryInterface: *const fn (*IDXGIDevice, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (*IDXGIDevice) callconv(.C) u32,
        Release: *const fn (*IDXGIDevice) callconv(.C) u32,
        // IDXGIObject (4)
        SetPrivateData: *const fn (*IDXGIDevice, *const GUID, u32, ?*const anyopaque) callconv(.C) HRESULT,
        SetPrivateDataInterface: *const fn (*IDXGIDevice, *const GUID, ?*const anyopaque) callconv(.C) HRESULT,
        GetPrivateData: *const fn (*IDXGIDevice, *const GUID, *u32, ?*anyopaque) callconv(.C) HRESULT,
        GetParent: *const fn (*IDXGIDevice, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        // IDXGIDevice (5)
        GetAdapter: *const fn (*IDXGIDevice, *?*IDXGIAdapter) callconv(.C) HRESULT,
        CreateSurface: *const fn (*IDXGIDevice, *const DXGI_SURFACE_DESC, u32, DXGI_USAGE, ?*const DXGI_SHARED_RESOURCE, *?*anyopaque) callconv(.C) HRESULT,
        QueryResourceResidency: *const fn (*IDXGIDevice, [*]const *anyopaque, [*]DXGI_RESIDENCY, u32) callconv(.C) HRESULT,
        SetGPUThreadPriority: *const fn (*IDXGIDevice, i32) callconv(.C) HRESULT,
        GetGPUThreadPriority: *const fn (*IDXGIDevice, *i32) callconv(.C) HRESULT,
    };

    pub fn Release(self: *IDXGIDevice) u32 {
        return self.vtable.Release(self);
    }

    pub fn GetAdapter(self: *IDXGIDevice, adapter: *?*IDXGIAdapter) HRESULT {
        return self.vtable.GetAdapter(self, adapter);
    }

    pub fn GetParent(self: *IDXGIDevice, riid: *const GUID, parent: *?*anyopaque) HRESULT {
        return self.vtable.GetParent(self, riid, parent);
    }
};

/// IDXGISwapChain — inherits IDXGIDeviceSubObject (which inherits IDXGIObject)
pub const IDXGISwapChain = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        // IUnknown (3)
        QueryInterface: *const fn (*IDXGISwapChain, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (*IDXGISwapChain) callconv(.C) u32,
        Release: *const fn (*IDXGISwapChain) callconv(.C) u32,
        // IDXGIObject (4)
        SetPrivateData: *const fn (*IDXGISwapChain, *const GUID, u32, ?*const anyopaque) callconv(.C) HRESULT,
        SetPrivateDataInterface: *const fn (*IDXGISwapChain, *const GUID, ?*const anyopaque) callconv(.C) HRESULT,
        GetPrivateData: *const fn (*IDXGISwapChain, *const GUID, *u32, ?*anyopaque) callconv(.C) HRESULT,
        GetParent: *const fn (*IDXGISwapChain, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        // IDXGIDeviceSubObject (1)
        GetDevice: *const fn (*IDXGISwapChain, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        // IDXGISwapChain (10)
        Present: *const fn (*IDXGISwapChain, u32, u32) callconv(.C) HRESULT,
        GetBuffer: *const fn (*IDXGISwapChain, u32, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        SetFullscreenState: *const fn (*IDXGISwapChain, BOOL, ?*anyopaque) callconv(.C) HRESULT,
        GetFullscreenState: *const fn (*IDXGISwapChain, ?*BOOL, ?*?*anyopaque) callconv(.C) HRESULT,
        GetDesc: *const fn (*IDXGISwapChain, *DXGI_SWAP_CHAIN_DESC) callconv(.C) HRESULT,
        ResizeBuffers: *const fn (*IDXGISwapChain, u32, u32, u32, DXGI_FORMAT, u32) callconv(.C) HRESULT,
        ResizeTarget: *const fn (*IDXGISwapChain, *const DXGI_MODE_DESC) callconv(.C) HRESULT,
        GetContainingOutput: *const fn (*IDXGISwapChain, *?*anyopaque) callconv(.C) HRESULT,
        GetFrameStatistics: *const fn (*IDXGISwapChain, *DXGI_FRAME_STATISTICS) callconv(.C) HRESULT,
        GetLastPresentCount: *const fn (*IDXGISwapChain, *u32) callconv(.C) HRESULT,
    };

    pub fn Release(self: *IDXGISwapChain) u32 {
        return self.vtable.Release(self);
    }

    pub fn Present(self: *IDXGISwapChain, sync_interval: u32, flags: u32) HRESULT {
        return self.vtable.Present(self, sync_interval, flags);
    }

    pub fn GetBuffer(self: *IDXGISwapChain, buffer: u32, riid: *const GUID, surface: *?*anyopaque) HRESULT {
        return self.vtable.GetBuffer(self, buffer, riid, surface);
    }

    pub fn ResizeBuffers(self: *IDXGISwapChain, buffer_count: u32, width: u32, height: u32, format: DXGI_FORMAT, flags: u32) HRESULT {
        return self.vtable.ResizeBuffers(self, buffer_count, width, height, format, flags);
    }

    pub fn GetDesc(self: *IDXGISwapChain, desc: *DXGI_SWAP_CHAIN_DESC) HRESULT {
        return self.vtable.GetDesc(self, desc);
    }
};

/// IDXGISwapChain1 — inherits IDXGISwapChain
pub const IDXGISwapChain1 = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        // IUnknown (3)
        QueryInterface: *const fn (*IDXGISwapChain1, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (*IDXGISwapChain1) callconv(.C) u32,
        Release: *const fn (*IDXGISwapChain1) callconv(.C) u32,
        // IDXGIObject (4)
        SetPrivateData: *const fn (*IDXGISwapChain1, *const GUID, u32, ?*const anyopaque) callconv(.C) HRESULT,
        SetPrivateDataInterface: *const fn (*IDXGISwapChain1, *const GUID, ?*const anyopaque) callconv(.C) HRESULT,
        GetPrivateData: *const fn (*IDXGISwapChain1, *const GUID, *u32, ?*anyopaque) callconv(.C) HRESULT,
        GetParent: *const fn (*IDXGISwapChain1, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        // IDXGIDeviceSubObject (1)
        GetDevice: *const fn (*IDXGISwapChain1, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        // IDXGISwapChain (10)
        Present: *const fn (*IDXGISwapChain1, u32, u32) callconv(.C) HRESULT,
        GetBuffer: *const fn (*IDXGISwapChain1, u32, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        SetFullscreenState: *const fn (*IDXGISwapChain1, BOOL, ?*anyopaque) callconv(.C) HRESULT,
        GetFullscreenState: *const fn (*IDXGISwapChain1, ?*BOOL, ?*?*anyopaque) callconv(.C) HRESULT,
        GetDesc: *const fn (*IDXGISwapChain1, *DXGI_SWAP_CHAIN_DESC) callconv(.C) HRESULT,
        ResizeBuffers: *const fn (*IDXGISwapChain1, u32, u32, u32, DXGI_FORMAT, u32) callconv(.C) HRESULT,
        ResizeTarget: *const fn (*IDXGISwapChain1, *const DXGI_MODE_DESC) callconv(.C) HRESULT,
        GetContainingOutput: *const fn (*IDXGISwapChain1, *?*anyopaque) callconv(.C) HRESULT,
        GetFrameStatistics: *const fn (*IDXGISwapChain1, *DXGI_FRAME_STATISTICS) callconv(.C) HRESULT,
        GetLastPresentCount: *const fn (*IDXGISwapChain1, *u32) callconv(.C) HRESULT,
        // IDXGISwapChain1 (12)
        GetDesc1: *const fn (*IDXGISwapChain1, *DXGI_SWAP_CHAIN_DESC1) callconv(.C) HRESULT,
        GetFullscreenDesc: *const fn (*IDXGISwapChain1, *DXGI_SWAP_CHAIN_FULLSCREEN_DESC) callconv(.C) HRESULT,
        GetHwnd: *const fn (*IDXGISwapChain1, *HWND) callconv(.C) HRESULT,
        GetCoreWindow: *const fn (*IDXGISwapChain1, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        Present1: *const fn (*IDXGISwapChain1, u32, u32, *const DXGI_PRESENT_PARAMETERS) callconv(.C) HRESULT,
        IsTemporaryMonoSupported: *const fn (*IDXGISwapChain1) callconv(.C) BOOL,
        GetRestrictToOutput: *const fn (*IDXGISwapChain1, *?*anyopaque) callconv(.C) HRESULT,
        SetBackgroundColor: *const fn (*IDXGISwapChain1, *const DXGI_RGBA) callconv(.C) HRESULT,
        GetBackgroundColor: *const fn (*IDXGISwapChain1, *DXGI_RGBA) callconv(.C) HRESULT,
        SetRotation: *const fn (*IDXGISwapChain1, DXGI_MODE_ROTATION) callconv(.C) HRESULT,
        GetRotation: *const fn (*IDXGISwapChain1, *DXGI_MODE_ROTATION) callconv(.C) HRESULT,
    };

    pub fn QueryInterface(self: *IDXGISwapChain1, riid: *const GUID, obj: *?*anyopaque) HRESULT {
        return self.vtable.QueryInterface(self, riid, obj);
    }

    pub fn Release(self: *IDXGISwapChain1) u32 {
        return self.vtable.Release(self);
    }

    pub fn Present1(self: *IDXGISwapChain1, sync_interval: u32, flags: u32, params: *const DXGI_PRESENT_PARAMETERS) HRESULT {
        return self.vtable.Present1(self, sync_interval, flags, params);
    }

    pub fn GetBuffer(self: *IDXGISwapChain1, buffer: u32, riid: *const GUID, surface: *?*anyopaque) HRESULT {
        return self.vtable.GetBuffer(self, buffer, riid, surface);
    }

    pub fn ResizeBuffers(self: *IDXGISwapChain1, buffer_count: u32, width: u32, height: u32, format: DXGI_FORMAT, flags: u32) HRESULT {
        return self.vtable.ResizeBuffers(self, buffer_count, width, height, format, flags);
    }

    pub fn GetDesc1(self: *IDXGISwapChain1, desc: *DXGI_SWAP_CHAIN_DESC1) HRESULT {
        return self.vtable.GetDesc1(self, desc);
    }

    pub fn SetBackgroundColor(self: *IDXGISwapChain1, color: *const DXGI_RGBA) HRESULT {
        return self.vtable.SetBackgroundColor(self, color);
    }
};

/// IDXGIFactory — inherits IDXGIObject
pub const IDXGIFactory = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        // IUnknown (3)
        QueryInterface: *const fn (*IDXGIFactory, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (*IDXGIFactory) callconv(.C) u32,
        Release: *const fn (*IDXGIFactory) callconv(.C) u32,
        // IDXGIObject (4)
        SetPrivateData: *const fn (*IDXGIFactory, *const GUID, u32, ?*const anyopaque) callconv(.C) HRESULT,
        SetPrivateDataInterface: *const fn (*IDXGIFactory, *const GUID, ?*const anyopaque) callconv(.C) HRESULT,
        GetPrivateData: *const fn (*IDXGIFactory, *const GUID, *u32, ?*anyopaque) callconv(.C) HRESULT,
        GetParent: *const fn (*IDXGIFactory, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        // IDXGIFactory (5)
        EnumAdapters: *const fn (*IDXGIFactory, u32, *?*IDXGIAdapter) callconv(.C) HRESULT,
        MakeWindowAssociation: *const fn (*IDXGIFactory, ?HWND, u32) callconv(.C) HRESULT,
        GetWindowAssociation: *const fn (*IDXGIFactory, *?HWND) callconv(.C) HRESULT,
        CreateSwapChain: *const fn (*IDXGIFactory, *anyopaque, *DXGI_SWAP_CHAIN_DESC, *?*IDXGISwapChain) callconv(.C) HRESULT,
        CreateSoftwareAdapter: *const fn (*IDXGIFactory, ?*anyopaque, *?*IDXGIAdapter) callconv(.C) HRESULT,
    };

    pub fn Release(self: *IDXGIFactory) u32 {
        return self.vtable.Release(self);
    }

    pub fn EnumAdapters(self: *IDXGIFactory, index: u32, adapter: *?*IDXGIAdapter) HRESULT {
        return self.vtable.EnumAdapters(self, index, adapter);
    }

    pub fn CreateSwapChain(self: *IDXGIFactory, device: *anyopaque, desc: *DXGI_SWAP_CHAIN_DESC, swap_chain: *?*IDXGISwapChain) HRESULT {
        return self.vtable.CreateSwapChain(self, device, desc, swap_chain);
    }
};

/// IDXGIFactory2 — inherits IDXGIFactory1 (which inherits IDXGIFactory)
pub const IDXGIFactory2 = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        // IUnknown (3)
        QueryInterface: *const fn (*IDXGIFactory2, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (*IDXGIFactory2) callconv(.C) u32,
        Release: *const fn (*IDXGIFactory2) callconv(.C) u32,
        // IDXGIObject (4)
        SetPrivateData: *const fn (*IDXGIFactory2, *const GUID, u32, ?*const anyopaque) callconv(.C) HRESULT,
        SetPrivateDataInterface: *const fn (*IDXGIFactory2, *const GUID, ?*const anyopaque) callconv(.C) HRESULT,
        GetPrivateData: *const fn (*IDXGIFactory2, *const GUID, *u32, ?*anyopaque) callconv(.C) HRESULT,
        GetParent: *const fn (*IDXGIFactory2, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        // IDXGIFactory (5)
        EnumAdapters: *const fn (*IDXGIFactory2, u32, *?*IDXGIAdapter) callconv(.C) HRESULT,
        MakeWindowAssociation: *const fn (*IDXGIFactory2, ?HWND, u32) callconv(.C) HRESULT,
        GetWindowAssociation: *const fn (*IDXGIFactory2, *?HWND) callconv(.C) HRESULT,
        CreateSwapChain: *const fn (*IDXGIFactory2, *anyopaque, *DXGI_SWAP_CHAIN_DESC, *?*IDXGISwapChain) callconv(.C) HRESULT,
        CreateSoftwareAdapter: *const fn (*IDXGIFactory2, ?*anyopaque, *?*IDXGIAdapter) callconv(.C) HRESULT,
        // IDXGIFactory1 (2)
        EnumAdapters1: *const fn (*IDXGIFactory2, u32, *?*anyopaque) callconv(.C) HRESULT,
        IsCurrent: *const fn (*IDXGIFactory2) callconv(.C) BOOL,
        // IDXGIFactory2 (11)
        IsWindowedStereoEnabled: *const fn (*IDXGIFactory2) callconv(.C) BOOL,
        CreateSwapChainForHwnd: *const fn (*IDXGIFactory2, *anyopaque, ?HWND, *const DXGI_SWAP_CHAIN_DESC1, ?*const DXGI_SWAP_CHAIN_FULLSCREEN_DESC, ?*anyopaque, *?*IDXGISwapChain1) callconv(.C) HRESULT,
        CreateSwapChainForCoreWindow: *const fn (*IDXGIFactory2, *anyopaque, *anyopaque, *const DXGI_SWAP_CHAIN_DESC1, ?*anyopaque, *?*IDXGISwapChain1) callconv(.C) HRESULT,
        GetSharedResourceAdapterLuid: *const fn (*IDXGIFactory2, windows.HANDLE, *LUID) callconv(.C) HRESULT,
        RegisterStereoStatusWindow: *const fn (*IDXGIFactory2, ?HWND, u32, *u32) callconv(.C) HRESULT,
        RegisterStereoStatusEvent: *const fn (*IDXGIFactory2, ?windows.HANDLE, *u32) callconv(.C) HRESULT,
        UnregisterStereoStatus: *const fn (*IDXGIFactory2, u32) callconv(.C) void,
        RegisterOcclusionStatusWindow: *const fn (*IDXGIFactory2, ?HWND, u32, *u32) callconv(.C) HRESULT,
        RegisterOcclusionStatusEvent: *const fn (*IDXGIFactory2, ?windows.HANDLE, *u32) callconv(.C) HRESULT,
        UnregisterOcclusionStatus: *const fn (*IDXGIFactory2, u32) callconv(.C) void,
        CreateSwapChainForComposition: *const fn (*IDXGIFactory2, *anyopaque, *const DXGI_SWAP_CHAIN_DESC1, ?*anyopaque, *?*IDXGISwapChain1) callconv(.C) HRESULT,
    };

    pub fn QueryInterface(self: *IDXGIFactory2, riid: *const GUID, obj: *?*anyopaque) HRESULT {
        return self.vtable.QueryInterface(self, riid, obj);
    }

    pub fn Release(self: *IDXGIFactory2) u32 {
        return self.vtable.Release(self);
    }

    pub fn CreateSwapChainForHwnd(
        self: *IDXGIFactory2,
        device: *anyopaque,
        hwnd: ?HWND,
        desc: *const DXGI_SWAP_CHAIN_DESC1,
        fullscreen_desc: ?*const DXGI_SWAP_CHAIN_FULLSCREEN_DESC,
        restrict_to_output: ?*anyopaque,
        swap_chain: *?*IDXGISwapChain1,
    ) HRESULT {
        return self.vtable.CreateSwapChainForHwnd(self, device, hwnd, desc, fullscreen_desc, restrict_to_output, swap_chain);
    }

    pub fn MakeWindowAssociation(self: *IDXGIFactory2, hwnd: ?HWND, flags: u32) HRESULT {
        return self.vtable.MakeWindowAssociation(self, hwnd, flags);
    }
};

// ============================================================================
// Functions
// ============================================================================

pub extern "dxgi" fn CreateDXGIFactory2(Flags: u32, riid: *const GUID, ppFactory: *?*anyopaque) callconv(.C) HRESULT;

// ============================================================================
// Tests
// ============================================================================

test "DXGI struct sizes are nonzero" {
    try std.testing.expect(@sizeOf(DXGI_SWAP_CHAIN_DESC1) > 0);
    try std.testing.expect(@sizeOf(DXGI_SAMPLE_DESC) > 0);
    try std.testing.expect(@sizeOf(DXGI_SWAP_CHAIN_DESC) > 0);
    try std.testing.expect(@sizeOf(DXGI_MODE_DESC) > 0);
    try std.testing.expect(@sizeOf(DXGI_ADAPTER_DESC) > 0);
    try std.testing.expect(@sizeOf(DXGI_FRAME_STATISTICS) > 0);
    try std.testing.expect(@sizeOf(DXGI_PRESENT_PARAMETERS) > 0);
    try std.testing.expect(@sizeOf(DXGI_RGBA) > 0);
    try std.testing.expect(@sizeOf(IDXGIFactory.VTable) > 0);
    try std.testing.expect(@sizeOf(IDXGIFactory2.VTable) > 0);
    try std.testing.expect(@sizeOf(IDXGISwapChain.VTable) > 0);
    try std.testing.expect(@sizeOf(IDXGISwapChain1.VTable) > 0);
    try std.testing.expect(@sizeOf(IDXGIDevice.VTable) > 0);
    try std.testing.expect(@sizeOf(IDXGIAdapter.VTable) > 0);
}
