#include "header\OpenRSF.fxh"
#define qf tex2D(ReShade::BackBuffer, uv).rgb

texture t_sRGB { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F; };
texture t_XYZ { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F; };
texture t_ACES2065 { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F; };
texture t_ACEScg { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F; };

texture tDiff { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA32F; };

void main(float4 vpos : SV_Position, float2 uv : TEXCOORD, out float4 sRGB : SV_Target0, out float4 XYZ : SV_Target1, out float4 ACES2065 : SV_Target2, out float4 ACEScg : SV_Target3, out float4 diff : SV_Target4) {
	sRGB = float4(getLSRGB(qf), 1.0);
	XYZ = float4(lsrbg2xyz(sRGB.rgb), 1.0);
	ACES2065 = float4(xyz2aces2065(XYZ.rgb), 1.0);
	ACEScg = float4(aces20652cg(ACES2065.rgb), 1.0);
	diff = float4(XYZ.rgb - aces20652xyz(xyz2aces2065(XYZ.rgb)), 1.0);
}

technique ORSFRef {
	pass Test {
		VertexShader = PostProcessVS;
		PixelShader = main;
		RenderTarget0 = t_sRGB;
		RenderTarget1 = t_XYZ;
		RenderTarget2 = t_ACES2065;
		RenderTarget3 = t_ACEScg;
		RenderTarget4 = tDiff;
	}
}