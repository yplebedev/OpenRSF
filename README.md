# OpenRSF
Documentation, tools &amp; downloads related to OpenRSF; a framework for ReShade developers and users. No more confusing, painful dependencies, less boilerplate.

# The gist
The ORSP cosists of three segments:

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

Depth is provided in a linearized format. Correct setup of the global preproc guarantees it's linearity, invertedness and even it being not upside-down. A header then passes the relevant data to our shaders.

The position may be inferred from the depth. The standard defines two transformations: a correct one, that inverts the view and clip matricies from the FOV and resolution, respectively, and, a simple and fast one, that linearly scales the UV by depth.

Normals are curiosly missing. However, since the world transformation exists, we may infer an inherently imprecise view-space normal by using the depth from 4 fragments forming a "+" sign. We use a total of 5 for any time we need precision, but we may get away with 3 when it is not required.


Depth is to be stored in a 16-bit (R16), mipmappable texture. The sampler and header getter must allow the user to easily sample MIPs, hiding away any potential branching. Depth must always be stored at full resolutions. The implementation must always also create software mipmaps, where the value of the resulting pixel must be the minimum of a 2x2 block.

Position is gathered from either:

    - uv (float2)

    - uv + z (float2, float)

    - uvz (float3)

    - uv + q (float2, float)

    - uv + z + q (float2, float, float)

    - uvz + q (float3, float)
where z is a user-defined depth, and q is a quality level for depth.


Normals are to be stored in a 16-bit (RG16) texture, with optional lower-precision quality levels. Normals must be encoded using octaheral encoding. Must also similarly be sample-able with a single call and no branching.

# Tex normals

# MVs
