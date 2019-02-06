// Pcx - Point cloud importer & renderer for Unity
// https://github.com/keijiro/Pcx

#include "UnityCG.cginc"
#include "Common.cginc"

// Uniforms
half4 _Tint;
half _PointSize;
float4x4 _Transform;

StructuredBuffer<float4> _PointBuffer;

// Vertex input attributes
struct Attributes
{
    uint vertexID : SV_VertexID;
};

// Fragment varyings
struct Varyings
{
    float4 position : SV_POSITION;
    half3 color : COLOR;
    float2 uv : TEXCOORD0;
    UNITY_FOG_COORDS(0)
};

// Vertex phase
Varyings Vertex(Attributes input)
{
    // Retrieve vertex attributes.
    float4 pt = _PointBuffer[input.vertexID];
    float4 pos = mul(_Transform, float4(pt.xyz, 1));
    half3 col = PcxDecodeColor(asuint(pt.w));

        col *= _Tint.rgb;

    // Set vertex output.
    Varyings o;
    o.position = UnityObjectToClipPos(pos);
#if !PCX_SHADOW_CASTER
    o.color = col;
    UNITY_TRANSFER_FOG(o, o.position);
#endif
    return o;
}

// Geometry phase
[maxvertexcount(36)]
void Geometry(point Varyings input[1], inout TriangleStream<Varyings> outStream)
{
    float4 origin = input[0].position;
    float2 extent = abs(UNITY_MATRIX_P._11_22 * _PointSize);

    // Copy the basic information.
    Varyings o = input[0];

    // Top vertex
    o.position.y = origin.y + extent.y;
    o.position.xzw = origin.xzw;
    o.uv = float2(0.0, 0.0);

    outStream.Append(o);

    UNITY_LOOP for (uint i = 1; i < 2; i++)
    {
        float sn, cs;
        sincos(UNITY_PI / 2.0 * i, sn, cs);

        // Right side vertex
        o.position.xy = origin.xy + extent * float2(sn, cs);
        o.uv = float2(0.0, 1.0);
        outStream.Append(o);

        // Left side vertex
        o.position.x = origin.x - extent.x * sn;
    o.uv = float2(1.0, 0.0);
        outStream.Append(o);
    }

    // Bottom vertex
    o.position.x = origin.x;
    o.position.y = origin.y - extent.y;
        o.uv = float2(1.0, 1.0);
    outStream.Append(o);

    outStream.RestartStrip();
}

half4 Fragment(Varyings input) : SV_Target
{
    float d = length(input.uv - 0.5);
    d = smoothstep(0.4, 0.3, d);

    half4 c = half4(10.0 * input.color, _Tint.a * d);
    UNITY_APPLY_FOG(input.fogCoord, c);
    return c;
}

