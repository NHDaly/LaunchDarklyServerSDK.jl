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
        # NOTE: I was previously seeing segfaults here..... Let's pay attention to it...
        @ccall LDConfigFree(cfg.ptr::Ptr{Nothing})::Nothing
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
        # NOTE: I was previously seeing segfaults here..... Let's pay attention to it...
        success = @ccall LDClientClose(client.ptr::Ptr{Nothing})::Bool
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
