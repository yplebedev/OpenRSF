# OpenRSF
Documentation, tools &amp; downloads related to OpenRSF; a framework for ReShade developers and users. No more confusing, painful dependencies, less boilerplate.

# The gist
The ORSP consists of three segments:

1. Header:
        A header is provided by maintainers. It will store standardized load OPs, and functions deemed useful by the majority (eg, uv2view). The header must not contain user-friendly ways to write to textures or any other way to break compatibility.
        
2. Reference:
        A small reference *implementation* that has all the functionality that the standard has. Intentionally dumbed down.
        
3. Implementation:
        An .FX shader that generates and writes to all the relevant textures. Developed and optimized only by the community.
        

The user must *only* include the *Header*, but implementations may create their own headers, too. This is intentionally unstandardized.

Implementations may be one of three types; official, where the creator intentionally implements the standard, in a different branch or otherwise, unofficial, where they give permission for maintainers to modify their code, and the safest licence-wise, the adapter, that acts as a translation later. The performance and applicability reduces with each level.

# API
Do not use old APIs. Force the use of wrappers where applicable. Recommendations include [DXVK](https://github.com/doitsujin/dxvk) and [dgVoodoo2](https://dege.freeweb.hu/dgVoodoo2/). DX9 and OpenGL are unsupported by the standard, but may be defined and exported by implementations.

# Depth, normals, positions and coordinate spaces
ReShade provides two outputs for us developers:

1. Back Buffer
    
2. Linearized depth
    

Please note that because of the standard, implementations and game-specific addons may, in the future, interconnect.

The backbuffer is simply the back of the buffer, what the game is currently drawing onto. It is picked up quite late in the process, and as such may contain things like UI, fog, particles etc. This is somewhat limiting, and very little can be done about it. Game-specific addons may be used to pick up and draw to an earlier buffer, but [REST](https://github.com/4lex4nder/ReshadeEffectShaderToggler) is a popular somewhat-universal solution. UI detection and fog accounting is recommended for depth-based shaders.

Depth is provided in a linearized format. Correct setup of the global preproc guarantees its linearity, invertedness and even it being not upside-down. A header then passes the relevant data to our shaders.

The position may be inferred from the depth. The standard defines two transformations: a correct one, that inverts the view and clip matricies from the FOV and resolution, respectively, and, a simple and fast one, that linearly scales the UV by depth. Please note that the transformation matricies must be stored as uniforms. We define the coordinate space as a sensible for screen-space one; Y points down, X, right and Z forward.

[Normals are curiosly missing](https://wickedengine.net/2019/09/improved-normal-reconstruction-from-depth/). However, since the world transformation exists, we may infer an inherently imprecise view-space normal by using the depth from 4 fragments forming a "+" sign. We use a total of 5 for any time we need precision, but we may get away with 3 when it is not required.


Depth is to be stored in a 16-bit ([R16](https://github.com/crosire/reshade-shaders/blob/slim/REFERENCE.md#reshade-fx-allows-semantics-to-be-used-on-texture-declarations-this-is-used-to-request-special-textures)), mipmappable texture. The sampler and header getter must allow the user to easily [sample MIPs](https://github.com/crosire/reshade-shaders/blob/slim/REFERENCE.md#sampler-object), hiding away any potential branching. Depth must always be stored at full resolution. The implementation must always also create software mipmaps, where the value of the resulting pixel must be the minimum of a 2x2 block.

    if (x) {
        return tex2Dlod(sampler, float4(uv, 0., 0.)) 
    } else if (y) { return tex2Dlod(lowerQuality..... // fugly

Position is gathered from either:

    - uv (float2)

    - uv + z (float2, float)

    - uvz (float3)

    - uv + q (float2, float)

    - uv + z + q (float2, float, float)

    - uvz + q (float3, float)
where z is a user-defined depth, and q is a quality level for depth.


Normals are to be stored in a 16-bit (RG16) texture, with optional lower-precision quality levels. Normals must be encoded using octaheral encoding. Must also similarly be sample-able with a single call and no branching.

# Filtered Normals

The normals as generated from depth lack geometric detail that games might inherintly have. Whatever the implementation is for the game, the end result is a shaded fragment. By emplying a set of heuristics (ie, crevices are dark and all detail is limited to high-frequency only), implementations may compute an approximation, helping the look of otherwise flat surfaces. Filtered normals are basically entirely implementation-defined, but they must also provide at least one quality drop.

# Albedo

Albedo is, unfortunately, always multiplied with light before being written to the buffer. By employing more heuristics, an implementation *may* define albedo. In the case where it doesn't, it must write the linearized BackBuffer to albedo. Must be stored as RGB10A2. Alpha is unused, but may, for example, be used to differentiate between materials, or to approximate roughness.

# MVs

Motion vectors must store the UV offset of a fragment between the previous frame, essentially minimizing the following:

    float x = abs(tex2D(prev, uv + mv) - tex2D(cur, uv));

The way optical flow is done is entirely up to the implementation but, they must be stored as RGBA16F. The R and G must store u and v delta motion, the B must store *some* disocclusion/error mask. It doesn't have to be complex, and yet again, it's up to the implementation to define. The alpha is a freebie; it's usually should be filled with 1.0, as it helps debugging.

# Color

Color transformations are a somewhat complicated matter, so to avoid confusion and lower the rate of error, this module contains industry-leading, battle-tested color ops. 

## Color spaces

The BackBuffer contains data in an sRGB format in most titles. We reccommend the developer to conditionally handle scRGB and other types of HDR data explocitly using [preprocessors](https://github.com/crosire/reshade-shaders/blob/slim/REFERENCE.md#macros). But for simplicity's sake, the header provides you with automagic transformers and getter. Most color space defenitions are ported directly from [OpenColorIO](https://github.com/AcademySoftwareFoundation/OpenColorIO). Defined are transformations for:

1. sRGB
2. Linear sRGB
3. scRGB
4. HDR10 ST2084
5. HDR10 HLG
6. CIE XYZ
7. [OkLab and OkLCh](https://bottosson.github.io/posts/oklab/)
8. ACEScg

We reccommend transforming into a wide-gamut scene-reffered space, by first going linear, and then optionally applying one of of the predefined inverse-tonemappers, and transforming into something like ACEScg for general workflows, and OkLab for color proccessing. Before presenting, the image must be tonemapped, and transformed into its native color space. Make sure to mirror the order of operations, essentially keeping track of a transformation "stack". In case of HDR color spaces, whitepoints must be explicitly defined with uniform.

## Inverse Tonemapping

Inverse tonemapping serves to attempt to recover game HDR data, or make it up, with an ad-hoc function. We provide a few useful ones:

1. Log exposure
2. Luma-aware Reinhard
3. Lottes

While extra efforts could be made to match some common operators, it's relatively nieche as a use-case.

We also reccommend pairing an inverse tonemapper with the same one. This helps protect the image's original contrast, whitepoint and exposure. Strating off of this general rule may lead to perceptually nicer images, particularly because of the filmic toe.

## Tonemappers

A large collection of tonemappers is provided. This is because for the few times where you will "just tonemap", getting the perfect look for a certain scenario may be desired. Always pair a tonemapper with HDR data! Some tonemappers take in a specific color space. Failing to transform those correctly will create noticably incorrect hues.

1. Luma-aware Reinhard
2. Log exposure
3. [Lottes](https://www.shadertoy.com/view/Xdd3Rr)
4. [ACES fit](https://knarkowicz.wordpress.com/2016/01/06/aces-filmic-tone-mapping-curve/)
5. [Baking Lab ACES](https://github.com/TheRealMJP/BakingLab/blob/master/BakingLab/ACES.hlsl)
6. [Legacy Unreal Engine ACES port](https://github.com/yplebedev/UjelFX-ReShade-Effect-Pack-by-BFB/blob/d2e5713343b4f50175f4fd83e2c91a416c379b95/reshade-shaders/Shaders/UjelFX/UjelFX_includes/UjelUtilities.fxh#L74)
7. ACES 1.3[reference needed]
8. ACES 2.0 (That's enough aces!)[reference needed]
9. AgX [reference needed]
10. GT7 [ref]
11. Uncharted 2 [ref]

While, when applicable, actual arithmetics are used, in case of specific and complex transforms we bake LUTs from OCIO. This unfortunately incurrs a pretty high cost.

If you'd like to use a tonemapper that doesn't implicitly collapse the color space, stick to ACES fits and the few simple ones we invert.

## Good Practices

1. Use the simplest and shortest set of transforms unless absolutely nescesarry
2. Keep all actual internal math in HDR
3. Do color correction in perceptual color spaces
4. Separate luminance and color operations
   4.1 Abuse OkLab
5. Explicitly transform; while automatic methods do exist on the preproccessor base,  its highly not reccommended to use them for large projects

# PRNG, QRNG and Dithering
A lot of modern applications requre some form of random numbers. Uses include Monte-Carlo (GI, AO), and dithering/debanding. The standard defines a few practical approaches.

1. [Hash](https://www.shadertoy.com/view/4djSRW)
2. Bayer
3. [GR](https://extremelearning.com.au/unreasonable-effectiveness-of-quasirandom-sequences/)
4. [R2](https://extremelearning.com.au/unreasonable-effectiveness-of-quasirandom-sequences/)
5. SBN
6. [STBN](https://developer.nvidia.com/blog/rendering-in-real-time-with-spatiotemporal-blue-noise-textures-part-1/)

These are split between the header and implementations. Blue noise, for one, uses precomputed textures, and to encourage improvements in spectral energy distribution, it's up to the implementation to define the time length and exact texture names. Hashes, bayer and R2 are all runtime-computable, and as such aren't implementable. Blue noise, on the other hand, is.

We define SBN as a 512x512 tilable RGBA16 polychrome texture, where each channel stores an independant, uncorrelated source. This is expensive, but is useful for when it's useless to animate the texture. We would like to point out that any scroll, channel swap etc. of a SBN texture will not produce blue noise along time.

STBN is a 128x128, monochrome R8 texture. Vectorization must occur via a large enough texture-space offset of the sample location to [not cause visible correlation](https://developer.nvidia.com/blog/rendering-in-real-time-with-spatiotemporal-blue-noise-textures-part-1/).

Noise getters must consume VPOS.

Everything but STBN must never be written to by implementations.

## Good Practices

1. Do not inject randomness everywhere. If you add random, you get random.
2. Use blue noise where repetition is a concern.
3. Use LDS sparingly, with simple, low noise, low dimentional integrals, and/or aggresive filtering.
4. Test the quality/perf ratios. Do not go off a whim.


# Constants

Since ReShade doesn't come with a math library, some constants have been header-defined. Constants are defined in ALL_CAPS_SNAKE, with the const keyword where possible. Hash-defs tend to have hard-to-debug issues, so this is entirely for stability's sake.

We also include precomputed gaussian weights and offsets in 

1. 3x3
2. 5x5
3. 7x7

windows. The values must be normalized for energy conservation and preservation.

# Textures and sampler names
First off, this is the namespace structure:

    namespace ORSF {
        namespace header {
            // header defined functions and consts. developers may alias this using preprocs.
        }
        namespace shared {
            // textures as defined by standard, resides both in header and implementation for compatibility reasons.
        }
    }
Inside of each inner namespace, all of the functions are categorized with their own (inner namespaces) modules. Those modules are:

1. pos
2. motion
3. color
4. random

Pos contains everything for depth, normals, transformations etc.

Motion houses everything for MVs

Color contains color transformations

Random houses RNG

Everything that doesnt neatly fit into one category is contained outside of the modules.



Textures must be prefixed with "t". Samplers share the name, but have a prefix "s".


tDepthN: depth, with software MIP level as N

tNormalN: geometric normals, software mips as N, though if none are made, 0 must be put at the end.

tSmoothNormalN: optional smoothed normal, same as before

tTexNormalN: smooth and textured normals, same as before

tAlbedo

tMV: motion

tBN: spatial blue noise

tSTBN: animated blue noise (must store current frame, not the atlas!)

# Header uniforms

For future support, things like FOV are defined as a uniform. An addon may force a certain value, but it defaults to 90.

# Header functions
The header must provide a set of getters, to avoid accidental RT use or otherwise illegal mutation.

float3 getPos(...) returns view-space position

float3 getUV(...) inverts the action of getPos()


float3 getNormal(...) gets the geometric normals

float3 getSmoothNormal(...) gets the smooth normals

float3 getTexturedNormal(...) -||-


float3 getAlbedo(...)

float3 getMotion(...) as the alpha is undefined, gets motion and rejection


floatn getRandom(...) gets you white noise (ND)

float R1(...) computes R2 with offset (1D)

float2 R2(...) (2D)

float GRNoise(...) returns R1 based noise (2D)

float getBayer(...) (2D)

floatn getBlue(...) (2D)

floatn getSTBN(...) (2D)

floatn blurNxN(sampler, uv, scalar = 1.0) is a shorthand blur call. it runs a single pass, and is not a substitute for dual kawase or the like.
