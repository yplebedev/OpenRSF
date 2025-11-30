# OpenRSF
Documentation, tools &amp; downloads related to OpenRSF; a framework for ReShade developers and users. No more confusing, painful dependencies, less boilerplate.

# The gist
The ORSP consists of three segments:

    - Header:
        A header is provided by maintainers. It will store standardized load OPs, and functions deemed useful by the majority (eg, uv2view). The header must not contain user-friendly ways to write to textures or any other way to break compatibility.
        
    - Reference:
        A small reference *implementation* that has all the functionality that the standard has. Intentionally dumbed down.
        
    - Implementation:
        An .FX shader that generates and writes to all the relevant textures. Developed and optimized only by the community.
        

The user must *only* include the *Header*, but implementations may create their own headers, too. This is intentionally unstandardized. 

# API
Do not use old APIs. Force the use of wrappers where applicable. Recommendations include [DXVK](https://github.com/doitsujin/dxvk) and [dgVoodoo2](https://dege.freeweb.hu/dgVoodoo2/). DX9 and OpenGL are unsupported by the standard, but may be defined and exported by implementations.

# Depth, normals, positions and coordinate spaces
ReShade provides two outputs for us developers:

    - Back Buffer
    
    - Linearized depth
    

The backbuffer is simply the back of the buffer, what the game is currently drawing onto. It is picked up quite late in the process, and as such may contain things like UI, fog, particles etc. This is somewhat limiting, and very little can be done about it. Game-specific addons may be used to pick up and draw to an earlier buffer, but [REST](https://github.com/4lex4nder/ReshadeEffectShaderToggler) is a popular somewhat-universal solution. UI detection and fog accounting is recommended for depth-based shaders.

Depth is provided in a linearized format. Correct setup of the global preproc guarantees its linearity, invertedness and even it being not upside-down. A header then passes the relevant data to our shaders.

The position may be inferred from the depth. The standard defines two transformations: a correct one, that inverts the view and clip matricies from the FOV and resolution, respectively, and, a simple and fast one, that linearly scales the UV by depth.

Normals are curiosly missing. However, since the world transformation exists, we may infer an inherently imprecise view-space normal by using the depth from 4 fragments forming a "+" sign. We use a total of 5 for any time we need precision, but we may get away with 3 when it is not required.


Depth is to be stored in a 16-bit (R16), mipmappable texture. The sampler and header getter must allow the user to easily sample MIPs, hiding away any potential branching. Depth must always be stored at full resolution. The implementation must always also create software mipmaps, where the value of the resulting pixel must be the minimum of a 2x2 block.

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

# Textures and sampler names
First off, this is the namespace structure:

    namespace ORSF {
        namespace header {
            // header defined functions and consts. developers may alias this using preprocs.
        }
        namespace implementation {
            // textures as defined by standard, resides both in header and implementation for compatibility reasons.
        }
    }

Textures must be prefixed with "t". Samplers share the name, but have a prefix "s".

tDepthN: depth, with software MIP level as N
tNormalN: geometric normals, software mips as N, though if none are made, 0 must be put at the end.
tSmoothNormalN: optional smoothed normal, same as before
tTexNormalN: smooth and textured normals, same as before
tAlbedo
tMV: motion

# Header functions
The header must provide a set of getters, to avoid accidental RT use or otherwise illegal mutation.

float3 getPos(...) returns view-space position

float3 getUV(...) inverts the action of getPos()


float3 getNormal(...) gets the geometric normals

float3 getSmoothNormal(...) gets the smooth normals

float3 getTexturedNormal(...) -||-


float3 getAlbedo(...)

float3 getMotion(...) as the alpha is undefined, gets motion and rejection

*todo: expand*
