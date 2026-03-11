// Ghostty D3D11 cell vertex shader stub
// TODO: Implement actual cell vertex shader

struct VSInput {
    float4 position : POSITION;
};

struct PSInput {
    float4 position : SV_POSITION;
};

PSInput main(VSInput input) {
    PSInput output;
    output.position = input.position;
    return output;
}
