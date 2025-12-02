# OpenRSF
Documentation, tools &amp; downloads related to OpenRSF; a framework for ReShade developers and users. No more confusing, painful dependencies, less boilerplate.

WARNING: Supremely unfinished. Nothing even close to a pre-aplha.
Second warning: most of this info will move to the wiki page. I'll go insane trying to sift through all of this slop I've written.

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

# Contributing:
There are a few ways one may help the project. You may clean up the wiki, give general feedback or write code, for the implementations or otherwise. You may join my [discord server](https://discord.gg/KUX5xREHdw) to communicate with me directly.
