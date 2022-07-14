using LaunchDarklyServerSDK

# Set sdk_key to your LaunchDarkly SDK key before running
sdk_key = get(ENV, "LD_SDK_KEY", "")

# Set feature_flag_key to the feature flag key you want to evaluate
feature_flag_key = "testSDKFlag"

function main()
    if isempty(sdk_key)
        println("Set ENV variable LD_SDK_KEY to your LaunchDarkly SDK key first")
        return
    end

    config = Config(sdk_key)
    client = Client(config, 5_000)
    try

        # The SDK starts up the first time ldclient.get() is called
        if LaunchDarklyServerSDK.is_initialized(client)
            println("SDK successfully initialized!")
        else
            println("SDK failed to initialize - check your SDK key.")
            return
        end

        # Set up the user properties. This user should appear on your LaunchDarkly users dashboard
        # soon after you run the demo.
        user = User(
            key = "example-user-key",
            name = "Sandy The Example User",
            #account = "relationalai-team-default",
        )

        flag_value = bool_variation(client, user, feature_flag_key, false)

        println("Feature flag '$feature_flag_key' is $flag_value for this user.")

    # Here we ensure that the SDK shuts down cleanly and has a chance to deliver analytics
    # events to LaunchDarkly before the program exits. If analytics events are not delivered,
    # the user properties and flag usage statistics will not appear on your dashboard. In a
    # normal long-running application, the SDK would continue running and events would be
    # delivered automatically in the background.
    finally
        close!(client)
        free!(config)
    end
end

if !Base.isinteractive()
    main()
end
