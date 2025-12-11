#pragma once
#include "ReShade.fxh"

#define RES(x) Width = BUFFER_WIDTH / x; Height = BUFFER_HEIGHT / x

/*
                                           __                                                            __                                        __   ______                                             
                                          |  \                                                          |  \                                      |  \ /      \                                            
  _______   ______   _______    _______  _| $$_     _______                     ______   _______    ____| $$                   __    __  _______   \$$|  $$$$$$\ ______    ______   ______ ____    _______ 
 /       \ /      \ |       \  /       \|   $$ \   /       \                   |      \ |       \  /      $$                  |  \  |  \|       \ |  \| $$_  \$$/      \  /      \ |      \    \  /       \
|  $$$$$$$|  $$$$$$\| $$$$$$$\|  $$$$$$$ \$$$$$$  |  $$$$$$$                    \$$$$$$\| $$$$$$$\|  $$$$$$$                  | $$  | $$| $$$$$$$\| $$| $$ \   |  $$$$$$\|  $$$$$$\| $$$$$$\$$$$\|  $$$$$$$
| $$      | $$  | $$| $$  | $$ \$$    \   | $$ __  \$$    \                    /      $$| $$  | $$| $$  | $$                  | $$  | $$| $$  | $$| $$| $$$$   | $$  | $$| $$   \$$| $$ | $$ | $$ \$$    \ 
| $$_____ | $$__/ $$| $$  | $$ _\$$$$$$\  | $$|  \ _\$$$$$$\                  |  $$$$$$$| $$  | $$| $$__| $$                  | $$__/ $$| $$  | $$| $$| $$     | $$__/ $$| $$      | $$ | $$ | $$ _\$$$$$$\
 \$$     \ \$$    $$| $$  | $$|       $$   \$$  $$|       $$                   \$$    $$| $$  | $$ \$$    $$                   \$$    $$| $$  | $$| $$| $$      \$$    $$| $$      | $$ | $$ | $$|       $$
  \$$$$$$$  \$$$$$$  \$$   \$$ \$$$$$$$     \$$$$  \$$$$$$$                     \$$$$$$$ \$$   \$$  \$$$$$$$                    \$$$$$$  \$$   \$$ \$$ \$$       \$$$$$$  \$$       \$$  \$$  \$$ \$$$$$$$ 
                                                                                                                                                                                                           
                                                                                                                                                                                          */

static const float PI = 3.14159265358979;
static const float TWO_PI = 2 * PI;
static const float HALF_PI = 0.5 * PI;

static const float GAUSS_3[9] = {
    1/16f, 1/8f, 1/16f, 
    1/8f, 1/4f, 1/8f, 
    1/16f, 1/8f, 1/16f, 
};

static const float GAUSS_5[25] = {
    1/273f , 4/273f , 7/273f , 4/273f , 1/273f ,
    4/273f , 16/273f, 26/273f, 16/273f, 4/273f ,
    7/273f , 26/273f, 41/273f, 26/273f, 7/273f ,
    4/273f , 16/273f, 26/273f, 16/273f, 4/273f ,
    1/273f , 4/273f , 7/273f , 4/273f , 1/273f 
};

static const float GAUSS_7[49] = {
    0/1003f  , 0/1003f  , 1/1003f  , 2/1003f  , 1/1003f  , 0/1003f  , 0/1003f  ,
    0/1003f  , 3/1003f  , 13/1003f , 22/1003f , 13/1003f , 3/1003f  , 0/1003f  ,
    1/1003f  , 13/1003f , 59/1003f , 97/1003f , 59/1003f , 13/1003f , 1/1003f  ,
    2/1003f  , 22/1003f , 97/1003f , 159/1003f, 97/1003f , 22/1003f , 2/1003f  ,
    1/1003f  , 13/1003f , 59/1003f , 97/1003f , 59/1003f , 13/1003f , 1/1003f  ,
    0/1003f  , 3/1003f  , 13/1003f , 22/1003f , 13/1003f , 3/1003f  , 0/1003f  ,
    0/1003f  , 0/1003f  , 1/1003f  , 2/1003f  , 1/1003f  , 0/1003f  , 0/1003f  ,
};

uniform float FOV<hidden = true;> = 90.0;

uniform float PEAK_LUMINANCE<hidden=true;> = 1000.0/10000.0; // https://en.wikipedia.org/wiki/Perceptual_quantizer

//     /$$$$$$$$                    /$$                                                                             /$$        /$$$$$$                                    /$$                              
//    |__  $$__/                   | $$                                                                            | $$       /$$__  $$                                  | $$                              
//       | $$  /$$$$$$  /$$   /$$ /$$$$$$   /$$   /$$  /$$$$$$   /$$$$$$   /$$$$$$$        /$$$$$$  /$$$$$$$   /$$$$$$$      | $$  \__/  /$$$$$$  /$$$$$$/$$$$   /$$$$$$ | $$  /$$$$$$   /$$$$$$   /$$$$$$$
//       | $$ /$$__  $$|  $$ /$$/|_  $$_/  | $$  | $$ /$$__  $$ /$$__  $$ /$$_____/       |____  $$| $$__  $$ /$$__  $$      |  $$$$$$  |____  $$| $$_  $$_  $$ /$$__  $$| $$ /$$__  $$ /$$__  $$ /$$_____/
//       | $$| $$$$$$$$ \  $$$$/   | $$    | $$  | $$| $$  \__/| $$$$$$$$|  $$$$$$         /$$$$$$$| $$  \ $$| $$  | $$       \____  $$  /$$$$$$$| $$ \ $$ \ $$| $$  \ $$| $$| $$$$$$$$| $$  \__/|  $$$$$$ 
//       | $$| $$_____/  >$$  $$   | $$ /$$| $$  | $$| $$      | $$_____/ \____  $$       /$$__  $$| $$  | $$| $$  | $$       /$$  \ $$ /$$__  $$| $$ | $$ | $$| $$  | $$| $$| $$_____/| $$       \____  $$
//       | $$|  $$$$$$$ /$$/\  $$  |  $$$$/|  $$$$$$/| $$      |  $$$$$$$ /$$$$$$$/      |  $$$$$$$| $$  | $$|  $$$$$$$      |  $$$$$$/|  $$$$$$$| $$ | $$ | $$| $$$$$$$/| $$|  $$$$$$$| $$       /$$$$$$$/
//       |__/ \_______/|__/  \__/   \___/   \______/ |__/       \_______/|_______/        \_______/|__/  |__/ \_______/       \______/  \_______/|__/ |__/ |__/| $$____/ |__/ \_______/|__/      |_______/ 
//                                                                                                                                                             | $$                                        
//                                                                                                                                                             | $$                                        
//                                                                                                                                                             |__/             

namespace OSRFShared {
	texture tAlbedo { RES(1); Format = RGB10A2; };
	sampler sAlbedo { Texture = tAlbedo; };
	
	
	
	texture tDepth0 { RES(1); Format = R16; };
	sampler sDepth0 { Texture = tDepth0; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };
	
	texture tDepth1 { RES(2); Format = R16; };
	sampler sDepth1 { Texture = tDepth1; };
	
	texture tDepth2 { RES(4); Format = R16; MipLevels = 4; };
	sampler sDepth2 { Texture = tDepth2; MinLOD = 0.0f; MaxLOD = 1000.0f; };
	
	
	
	texture tSmoothN { RES(1); Format = RG16; };
	sampler sSmoothN { Texture = tSmoothN; };
	
	texture tTexN { RES(1); Format = RG16; };
	sampler sTexN { Texture = tTexN; };
	
	
	
	texture tNormal0 { RES(1); Format = RG16; };
	sampler sNormal0 { Texture = tNormal0; };
	
	texture tNormal1 { RES(2); Format = RG16; };
	sampler sNormal1 { Texture = tNormal1; };
	
	texture tNormal2 { RES(4); Format = RG16; MipLevels = 4; };
	sampler sNormal2 { Texture = tNormal2; MinLOD = 0.0f; MaxLOD = 1000.0f; };
	
	
	texture tMotion { RES(1); Format = RGBA16F; };
	sampler sMotion { Texture = tMotion; };
	
	
	texture tSTBN { Width = 128; Height = 128; Format = R8; };
	sampler sSTBN { Texture = tSTBN; };
	
}

//      /$$$$$$              /$$     /$$                                  
//     /$$__  $$            | $$    | $$                                  
//    | $$  \__/  /$$$$$$  /$$$$$$ /$$$$$$    /$$$$$$   /$$$$$$   /$$$$$$$
//    | $$ /$$$$ /$$__  $$|_  $$_/|_  $$_/   /$$__  $$ /$$__  $$ /$$_____/
//    | $$|_  $$| $$$$$$$$  | $$    | $$    | $$$$$$$$| $$  \__/|  $$$$$$ 
//    | $$  \ $$| $$_____/  | $$ /$$| $$ /$$| $$_____/| $$       \____  $$
//    |  $$$$$$/|  $$$$$$$  |  $$$$/|  $$$$/|  $$$$$$$| $$       /$$$$$$$/
//     \______/  \_______/   \___/   \___/   \_______/|__/      |_______/ 
//                                                                        
//                                                                        
//    (And utility)                                                             

// directly from https://knarkowicz.wordpress.com/2014/04/16/octahedron-normal-vector-encoding/
// Krzysztof Narkowicz <--> ^
float2 OctWrap(float2 v) {
    return (1.0 - abs(v.yx)) * (v.xy >= 0.0 ? 1.0 : -1.0);
}
 
float2 Encode(float3 n) {
    n /= (abs(n.x) + abs(n.y) + abs(n.z));
    n.xy = n.z >= 0.0 ? n.xy : OctWrap(n.xy);
    n.xy = n.xy * 0.5 + 0.5;
    return n.xy;
}
 
float3 Decode(float2 f) {
    f = f * 2.0 - 1.0;
 
    // https://twitter.com/Stubbesaurus/status/937994790553227264
    float3 n = float3(f.x, f.y, 1.0 - abs(f.x) - abs(f.y));
    float t = saturate(-n.z);
    n.xy += n.xy >= 0.0 ? -t : t;
    return normalize(n);
}

float3 getNormal(float2 uv, float LOD) {
	float2 encoded = 0.;
	if (LOD < 1.0) {
		encoded = tex2D(OSRFShared::sNormal0, uv).rg;
	} else if (LOD < 2.0) {
		encoded = tex2D(OSRFShared::sNormal1, uv).rg;
	} else if (LOD < 3.0) {
		encoded = tex2D(OSRFShared::sNormal2, uv).rg;
	} else {
		encoded = tex2Dlod(OSRFShared::sNormal2, float4(uv, 0., floor(LOD))).rg;
	}
	return Decode(encoded);
}

float3 getAlbedo(float2 uv) {
	return tex2D(OSRFShared::sAlbedo, uv).rgb;
}

float getDepth(float2 uv, float LOD) {
	if (LOD < 1.0) {
		return tex2D(OSRFShared::sDepth0, uv).r;
	} else if (LOD < 2.0) {
		return tex2D(OSRFShared::sDepth1, uv).r;
	} else if (LOD < 3.0) {
		return tex2D(OSRFShared::sDepth2, uv).r;
	} else {
		return tex2Dlod(OSRFShared::sDepth2, float4(uv, 0., floor(LOD))).r;
	}
	return 1.0;
}

float3 getMotion(float2 uv) {
	return tex2D(OSRFShared::sMotion, uv).r;
}



float blur3x3_1(sampler input, float2 uv, float scale) {
	float accum = 0;
	for (int deltaX = -1; deltaX <= 1; deltaX++) {
		for (int deltaY = -1; deltaY <= 1; deltaY++) {
			float2 offset = ReShade::PixelSize * scale * float2(deltaX, deltaY);
			accum += tex2Dlod(input, float4(uv + offset, 0., 0.)).r * GAUSS_3[(deltaX + 1) + 3*(deltaY + 1)];
		}
	}
	return accum;
}

float2 blur3x3_2(sampler input, float2 uv, float scale) {
	float2 accum = 0;
	for (int deltaX = -1; deltaX <= 1; deltaX++) {
		for (int deltaY = -1; deltaY <= 1; deltaY++) {
			float2 offset = ReShade::PixelSize * scale * float2(deltaX, deltaY);
			accum += tex2Dlod(input, float4(uv + offset, 0., 0.)).rg * GAUSS_3[(deltaX + 1) + 3*(deltaY + 1)];
		}
	}
	return accum;
}

float3 blur3x3_3(sampler input, float2 uv, float scale) {
	float3 accum = 0;
	for (int deltaX = -1; deltaX <= 1; deltaX++) {
		for (int deltaY = -1; deltaY <= 1; deltaY++) {
			float2 offset = ReShade::PixelSize * scale * float2(deltaX, deltaY);
			accum += tex2Dlod(input, float4(uv + offset, 0., 0.)).rgb * GAUSS_3[(deltaX + 1) + 3*(deltaY + 1)];
		}
	}
	return accum;
}

float4 blur3x3_4(sampler input, float2 uv, float scale) {
	float4 accum = 0;
	for (int deltaX = -1; deltaX <= 1; deltaX++) {
		for (int deltaY = -1; deltaY <= 1; deltaY++) {
			float2 offset = ReShade::PixelSize * scale * float2(deltaX, deltaY);
			accum += tex2Dlod(input, float4(uv + offset, 0., 0.)).rgba * GAUSS_3[(deltaX + 1) + 3*(deltaY + 1)];
		}
	}
	return accum;
}




float blur5x5_1(sampler input, float2 uv, float scale) {
	float accum = 0;
	for (int deltaX = -2; deltaX <= 2; deltaX++) {
		for (int deltaY = -2; deltaY <= 2; deltaY++) {
			float2 offset = ReShade::PixelSize * scale * float2(deltaX, deltaY);
			accum += tex2Dlod(input, float4(uv + offset, 0., 0.)).r * GAUSS_5[(deltaX + 2) + 5*(deltaY + 2)];
		}
	}
	return accum;
}

float2 blur5x5_2(sampler input, float2 uv, float scale) {
	float2 accum = 0;
	for (int deltaX = -2; deltaX <= 2; deltaX++) {
		for (int deltaY = -2; deltaY <= 2; deltaY++) {
			float2 offset = ReShade::PixelSize * scale * float2(deltaX, deltaY);
			accum += tex2Dlod(input, float4(uv + offset, 0., 0.)).rg * GAUSS_5[(deltaX + 2) + 5*(deltaY + 2)];
		}
	}
	return accum;
}

float3 blur5x5_3(sampler input, float2 uv, float scale) {
	float3 accum = 0;
	for (int deltaX = -2; deltaX <= 2; deltaX++) {
		for (int deltaY = -2; deltaY <= 2; deltaY++) {
			float2 offset = ReShade::PixelSize * scale * float2(deltaX, deltaY);
			accum += tex2Dlod(input, float4(uv + offset, 0., 0.)).rgb * GAUSS_5[(deltaX + 2) + 5*(deltaY + 2)];
		}
	}
	return accum;
}

float4 blur5x5_4(sampler input, float2 uv, float scale) {
	float4 accum = 0;
	for (int deltaX = -2; deltaX <= 2; deltaX++) {
		for (int deltaY = -2; deltaY <= 2; deltaY++) {
			float2 offset = ReShade::PixelSize * scale * float2(deltaX, deltaY);
			accum += tex2Dlod(input, float4(uv + offset, 0., 0.)).rgba * GAUSS_5[(deltaX + 2) + 5*(deltaY + 2)];
		}
	}
	return accum;
}



float blur7x7_1(sampler input, float2 uv, float scale) {
	float accum = 0;
	for (int deltaX = -3; deltaX <= 3; deltaX++) {
		for (int deltaY = -3; deltaY <= 3; deltaY++) {
			float2 offset = ReShade::PixelSize * scale * float2(deltaX, deltaY);
			accum += tex2Dlod(input, float4(uv + offset, 0., 0.)).r * GAUSS_7[(deltaX + 3) + 7*(deltaY + 3)];
		}
	}
	return accum;
}


float2 blur7x7_2(sampler input, float2 uv, float scale) {
	float2 accum = 0;
	for (int deltaX = -3; deltaX <= 3; deltaX++) {
		for (int deltaY = -3; deltaY <= 3; deltaY++) {
			float2 offset = ReShade::PixelSize * scale * float2(deltaX, deltaY);
			accum += tex2Dlod(input, float4(uv + offset, 0., 0.)).rg * GAUSS_7[(deltaX + 3) + 7*(deltaY + 3)];
		}
	}
	return accum;
}

float3 blur7x7_3(sampler input, float2 uv, float scale) {
	float3 accum = 0;
	for (int deltaX = -3; deltaX <= 3; deltaX++) {
		for (int deltaY = -3; deltaY <= 3; deltaY++) {
			float2 offset = ReShade::PixelSize * scale * float2(deltaX, deltaY);
			accum += tex2Dlod(input, float4(uv + offset, 0., 0.)).rgb * GAUSS_7[(deltaX + 3) + 7*(deltaY + 3)];
		}
	}
	return accum;
}

float4 blur7x7_4(sampler input, float2 uv, float scale) {
	float4 accum = 0;
	for (int deltaX = -3; deltaX <= 3; deltaX++) {
		for (int deltaY = -3; deltaY <= 3; deltaY++) {
			float2 offset = ReShade::PixelSize * scale * float2(deltaX, deltaY);
			accum += tex2Dlod(input, float4(uv + offset, 0., 0.)).rgba * GAUSS_7[(deltaX + 3) + 7*(deltaY + 3)];
		}
	}
	return accum;
}

//      /$$$$$$            /$$                    
//     /$$__  $$          | $$                    
//    | $$  \__/  /$$$$$$ | $$  /$$$$$$   /$$$$$$ 
//    | $$       /$$__  $$| $$ /$$__  $$ /$$__  $$
//    | $$      | $$  \ $$| $$| $$  \ $$| $$  \__/
//    | $$    $$| $$  | $$| $$| $$  | $$| $$      
//    |  $$$$$$/|  $$$$$$/| $$|  $$$$$$/| $$      
//     \______/  \______/ |__/ \______/ |__/      
//                                                
//                                                
//                                                

float3 getAutoLSRGB(float3 BackBufferColor) {
	#if BUFFER_COLOR_SPACE == 0
		return BackBufferColor; // Unknown, probably rare enough atp.
	#endif
	
	#if BUFFER_COLOR_SPACE == 1 // sRGB
		float r = BackBufferColor.r;
		float g = BackBufferColor.g;
		float b = BackBufferColor.b;
		
		r = (r <= 0.04045 ? r / 12.92 : pow((r + 0.055)/1.055, 2.4));
		g = (g <= 0.04045 ? g / 12.92 : pow((g + 0.055)/1.055, 2.4));
		b = (b <= 0.04045 ? b / 12.92 : pow((b + 0.055)/1.055, 2.4));
		
		return saturate(float3(r, g, b));
	#endif
	
	#if BUFFER_COLOR_SPACE == 2 // scRGB
		return BackBufferColor;
	#endif
	
	#if BUFFER_COLOR_SPACE == 2 // HDR10 ST2084
		float m1 = 0.1593017578125;
		float m2 = 78.84375;
		float c2 = 18.8515625;
		float c3 = 18.6875;
		float c1 = c3 - c2 + 1.0;
		
		return pow((c1 + c2 * pow(PEAK_LUMINANCE, m1)) / (1.0 + c3 * pow(PEAK_LUMINANCE, m1)), m2); // oh god, this will be fun in about six months or so
	#endif
	
	#if BUFFER_COLOR_SPACE == 3 // HDR10 HLG, https://en.wikipedia.org/wiki/Hybrid_log%E2%80%93gamma
		return 0.rrr; // Fake
	#endif
}


float3 getInverse(float3 ToDisplay) {
	#if BUFFER_COLOR_SPACE == 0
		return ToDisplay; // Unknown, probably rare enough atp.
	#endif
	
	#if BUFFER_COLOR_SPACE == 1 // sRGB
		float r = ToDisplay.r;
		float g = ToDisplay.g;
		float b = ToDisplay.b;
		
		r = (r <= 0.0031308 ? r * 12.92 : 1.055 * pow(r, 1/2.4) - 0.055);
		g = (g <= 0.0031308 ? g * 12.92 : 1.055 * pow(g, 1/2.4) - 0.055);
		b = (b <= 0.0031308 ? b * 12.92 : 1.055 * pow(b, 1/2.4) - 0.055);
		
		return saturate(float3(r, g, b));
	#endif
	
	#if BUFFER_COLOR_SPACE == 2 // scRGB
		return ToDisplay;
	#endif
	
	#if BUFFER_COLOR_SPACE == 2 // HDR10 ST2084
		float m1 = 0.1593017578125;
		float m2 = 78.84375;
		float c2 = 18.8515625;
		float c3 = 18.6875;
		float c1 = c3 - c2 + 1.0;
		
		return pow(max(pow(ToDisplay, 1.0/m2) - c1, 0.0) / (c2 - c3 * pow(ToDisplay, 1.0/m2)), 1.0/m1); // oh god, this will be fun in about six months or so
	#endif
	
	#if BUFFER_COLOR_SPACE == 3 // HDR10 HLG, https://en.wikipedia.org/wiki/Hybrid_log%E2%80%93gamma
		return 0.rrr; // Literally not real
	#endif
}

float3 getSRGB(float3 linearSRGB) {
	float r = linearSRGB.r;
	float g = linearSRGB.g;
	float b = linearSRGB.b;
	
	r = (r <= 0.0031308 ? r * 12.92 : 1.055 * pow(r, 1/2.4) - 0.055);
	g = (g <= 0.0031308 ? g * 12.92 : 1.055 * pow(g, 1/2.4) - 0.055);
	b = (b <= 0.0031308 ? b * 12.92 : 1.055 * pow(b, 1/2.4) - 0.055);
	
	return saturate(float3(r, g, b));
}

// directly from https://bottosson.github.io/posts/oklab/
#define cbrtf(x) pow(x, 0.33333333)
float3 lin2ok(float3 c) 
{
    float l = 0.4122214708f * c.r + 0.5363325363f * c.g + 0.0514459929f * c.b;
	float m = 0.2119034982f * c.r + 0.6806995451f * c.g + 0.1073969566f * c.b;
	float s = 0.0883024619f * c.r + 0.2817188376f * c.g + 0.6299787005f * c.b;

    float l_ = cbrtf(l);
    float m_ = cbrtf(m);
    float s_ = cbrtf(s);

    return float3 (
        0.2104542553f*l_ + 0.7936177850f*m_ - 0.0040720468f*s_,
        1.9779984951f*l_ - 2.4285922050f*m_ + 0.4505937099f*s_,
        0.0259040371f*l_ + 0.7827717662f*m_ - 0.8086757660f*s_
    );
}

float3 ok2lin(float3 c) 
{
    float l_ = c.r + 0.3963377774f * c.g + 0.2158037573f * c.b;
    float m_ = c.r - 0.1055613458f * c.g - 0.0638541728f * c.b;
    float s_ = c.r - 0.0894841775f * c.g - 1.2914855480f * c.b;

    float l = l_*l_*l_;
    float m = m_*m_*m_;
    float s = s_*s_*s_;

    return float3(
		+4.0767416621f * l - 3.3077115913f * m + 0.2309699292f * s,
		-1.2684380046f * l + 2.6097574011f * m - 0.3413193965f * s,
		-0.0041960863f * l - 0.7034186147f * m + 1.7076147010f * s
    );
}

float3 lsrbg2xyz(float3 rgb) {
	float3x3 toXYZ = float3x3(
		float3(0.4124564, 0.3575761, 0.1804375),
		float3(0.2126729, 0.7151522, 0.0721750),
		float3(0.0193339, 0.1191920, 0.9503041)
	);
	
	return mul(toXYZ, rgb);
}

float3 xyz2lsrgb(float3 xyz) {
	float3x3 tosrgb = float3x3(
		float3( 3.24045,   -1.53714, -0.498532),
		float3(-0.969266,   1.87601,  0.0415561),
		float3( 0.0556434, -0.204026, 1.05723)
	);
	
	return mul(tosrgb, xyz);
}

float3 xyz2aces2065(float3 xyz) {
	float3x3 toACES2065_1 = float3x3(
		float3( 1.0498110175, 0.0000000000,-0.0000974845),
		float3(-0.4959030231, 1.3733130458, 0.0982400361),
		float3( 0.0000000000, 0.0000000000, 0.9912520182)
	);
	
	return mul(toACES2065_1, xyz);
}

float3 aces20652cg(float3 ACES2065_1) {
	float3x3 toACEScg = float3x3(
		float3( 1.4514393161,-0.2365107469,-0.2149285693),
		float3(-0.0765537734, 1.1762296998,-0.0996759264),
		float3( 0.0083161484,-0.0060324498, 0.9912520182)
	);
	
	return mul(toACEScg, ACES2065_1);
}

float3 cg2aces2065(float3 cg) {
	float3x3 to2065 = float3x3(
		float3( 0.695446,   0.140683,   0.164937 ),
		float3( 0.0447911,  0.859674,   0.0961568),
		float3(-0.00556189, 0.00405144, 1.00803  )
	);
	
	return mul(to2065, cg);
}

float3 aces20652xyz(float3 ACES2065_1) {
	float3x3 toxyz = float3x3(
		float3( 0.952552, 0.0,       0.0000936786),
		float3( 0.343966, 0.728166, -0.0721325),
		float3( 0.0,      0.0,       1.00883)
	);
	
	return mul(toxyz, ACES2065_1);
}

float3 xyz2cg(float3 xyz) {
	return aces20652cg(xyz2aces2065(xyz));
}

float3 cg2xyz(float3 cg) {
	return aces20652xyz(cg2aces2065(cg));
}