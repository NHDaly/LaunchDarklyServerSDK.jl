module LaunchDarklyServerSDK

using Libdl

const bin = joinpath(@__DIR__, "..", "bin")
libldserver = Libdl.dlopen("$bin/osx-clang-64bit-dynamic/lib/libldserverapi.dylib")

struct LDClient
    ptr::Ptr{Nothing}
end

Base.@kwdef struct User
    key::String
    secondary::String = ""
    ip::String = ""
    country::String = ""
    email::String = ""
    first_name::String = ""
    last_name::String = ""
    avatar::String = ""
    name::String = ""
    anonymous::Bool = false
    custom::Dict{String,String} = Dict{String,String}()
end
User(key::String) = User(key=key)

function bool_variation(client::LDClient, user::User, flag_key::String,
                        fallback::Bool = false, details = C_NULL)
    c_usr = Internal.make_c_user(user::User)
    try
        return @ccall LDBoolVariation(
            client.ptr::Ptr{Nothing},
            c_usr::Ptr{Nothing},
            flag_key::String,
            details::Ptr{Nothing}
        )::Bool
    finally
        Internal.free_user(c_usr)
    end
end


module Internal
using ..LaunchDarklyServerSDK: User

struct CUser
    ptr::Ptr{Nothing}
end

function make_c_user(user::User)
    c_usr = new_user(user.key)
    c_usr = @ccall LDUserSetSecondary(user.secondary::String)::Nothing
    c_usr = @ccall LDUserSetIP(user.ip::String)::Nothing
    c_usr = @ccall LDUserSetCountry(user.country::String)::Nothing
    c_usr = @ccall LDUserSetEmail(user.email::String)::Nothing
    c_usr = @ccall LDUserSetFirstName(user.first_name::String)::Nothing
    c_usr = @ccall LDUserSetLastName(user.last_name::String)::Nothing
    c_usr = @ccall LDUserSetAvatar(user.avatar::String)::Nothing
    c_usr = @ccall LDUserSetName(user.name::String)::Nothing
    c_usr = @ccall LDUserSetAnonymous(user.anonymous::Bool)::Nothing
    #c_usr = @ccall LDUserSetCustom(user.custom::String)::Nothing
    return c_usr
end

new_user(user_key::AbstractString) = @ccall LDUserNew(string(user_key)::String)::CUser
free_user(user::CUser) = @ccall LDUserFree(user.ptr::Ptr{Nothing})::Nothing

end

end
