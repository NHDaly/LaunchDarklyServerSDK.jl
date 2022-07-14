# Must match https://launchdarkly.github.io/c-server-sdk/structLDDetails.html
const LDBoolean = Cchar
@enum LDEvalReason begin
    LD_UNKNOWN
    LD_ERROR
    LD_OFF
    LD_PREREQUISITE_FAILED
    LD_TARGET_MATCH
    LD_RULE_MATCH
    LD_FALLTHROUGH
end

mutable struct LDDetails
    variationIndex::Cuint
    hasVariation::LDBoolean
    reason::LDEvalReason
    # The rest of this is too complicated for now
    _word1::UInt
    _word2::UInt
    _word3::UInt
    _word4::UInt
    _word5::UInt
    _word6::UInt
    LDDetails() = new()
end


function bool_variation(client::Client, user::User, flag_key::String,
                        fallback::Bool = false)
    #out_details = Ref{LDDetails}(LDDetails())

    c_usr = _make_c_user(user::User)
    try
        result = @ccall LDBoolVariation(
            client.ptr::Ptr{Nothing},
            c_usr.ptr::Ptr{Nothing},
            flag_key::Cstring,
            fallback::Bool,
            #out_details::Ref{LDDetails},
            C_NULL::Ptr{Nothing},
        )::Bool
        #@show out_details
        return result
    finally
        _free_c_user!(c_usr)
    end
end

