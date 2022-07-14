module LaunchDarklyServerSDK

using Libdl

const bin = joinpath(@__DIR__, "..", "bin")
function __init__()
global libldserver = Libdl.dlopen("$bin/osx-clang-64bit-dynamic/lib/libldserverapi.dylib")
end


include("config.jl")
include("user.jl")
include("variation.jl")


export Config, Client, User, bool_variation, close!, free!

end  # module
