mutable struct Config
    ptr::Ptr{Nothing}
    function Config(ptr::Ptr{Nothing})
        this = new(ptr)
        finalizer(free!, this)
        return this
    end
end
function Config(str::AbstractString)
    return Config(@ccall LDConfigNew(str::Cstring)::Ptr{Nothing})
end

function free!(cfg::Config)
    if cfg.ptr != C_NULL
        #Core.println("FREEING: $(cfg.ptr)")
        # TODO: This is causing segfaults. Better to leak, for now... :'(
        #@ccall LDConfigFree(cfg.ptr::Ptr{Nothing})::Nothing
        cfg.ptr = C_NULL
    end
    return nothing
end

mutable struct Client
    ptr::Ptr{Nothing}
    function Client(ptr::Ptr{Nothing})
        this = new(ptr)
        finalizer(close!, this)
        return this
    end
end
function Client(config::Config, max_wait_timeout_ms::Number)
    return Client(
        @ccall LDClientInit(
            config.ptr::Ptr{Nothing},
            max_wait_timeout_ms::Cuint,
        )::Ptr{Nothing}
    )
end

function close!(client::Client)
    if client.ptr != C_NULL
        #Core.println("CLOSING: $(client.ptr)")
        # TODO: This is causing segfaults. Better to leak, for now... :'(
        #success = @ccall LDClientClose(client.ptr::Ptr{Nothing})::Bool
        success = true
        if !success
            Core.println(stderr, "Failed to close LDClient: $(client)")
            return
        end
        client.ptr = C_NULL
    end
    return nothing
end

function is_initialized(client::Client)
    @ccall LDClientIsInitialized(client.ptr::Ptr{Nothing})::Bool
end
