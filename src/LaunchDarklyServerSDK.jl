module LaunchDarklyServerSDK

using Libdl

const bin = joinpath(@__DIR__, "..", "bin")
Libdl.dlopen("$bin/osx-clang-64bit-dynamic/lib/libldserverapi.dylib")

end
