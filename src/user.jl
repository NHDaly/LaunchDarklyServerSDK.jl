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
    #custom::Dict{String,String} = Dict{String,String}()
end
User(key::String; kwargs...) = User(;key=key, kwargs...)

# -----------
# C implementation

mutable struct _LDUser
    ptr::Ptr{Nothing}
    function _LDUser(ptr::Ptr{Nothing})
        this = new(ptr)
        finalizer(_free_c_user!, this)
        return this
    end
end
function _LDUser(key::AbstractString)
    return _LDUser(@ccall LDUserNew(key::Cstring)::Ptr{Nothing})
end

function _free_c_user!(c_usr::_LDUser)
    if c_usr.ptr != C_NULL
        @ccall LDUserFree(c_usr.ptr::Ptr{Nothing})::Nothing
        c_usr.ptr = C_NULL
    end
    return nothing
end

function _err(user::User, field)
    throw(ArgumentError("Failed to construct LDUser. Failed to set field $field from $(user)."))
end

macro _set_string_if_present(c_usr, user, field, func)
    esc(quote
        if !isempty($user.$field)
            @ccall($func($c_usr.ptr::Ptr{Nothing}, $user.$field::String)::Bool) || $_err($user, $field)
            nothing
        end
    end)
end

function _make_c_user(user::User)
    c_usr = _LDUser(user.key)
    @ccall LDUserSetAnonymous(c_usr.ptr::Ptr{Nothing}, user.anonymous::Bool)::Nothing
    @_set_string_if_present(c_usr, user, ip, LDUserSetIP)
    @_set_string_if_present(c_usr, user, country, LDUserSetCountry)
    @_set_string_if_present(c_usr, user, email, LDUserSetEmail)
    @_set_string_if_present(c_usr, user, first_name, LDUserSetFirstName)
    @_set_string_if_present(c_usr, user, last_name, LDUserSetLastName)
    @_set_string_if_present(c_usr, user, avatar, LDUserSetAvatar)
    @_set_string_if_present(c_usr, user, name, LDUserSetName)
    #if !isempty(user.custom)
    #    @ccall($func(c_usr, $user.$field::$_type)::Bool) || $_err($user, $field)
    #end
    return c_usr
end
