using LaunchDarklyServerSDK
using Test

@testset "user" begin
    @test User("test-user-id") == User(key="test-user-id")
    @test User("test-user-id", name = "nathan") == User(key="test-user-id", name = "nathan")

    user = User("test-user-id", name = "nathan", last_name = "awesome")

    # internal
    c_usr = LaunchDarklyServerSDK._make_c_user(user)
    LaunchDarklyServerSDK._free_c_user!(c_usr)
    # Test multiple frees
    LaunchDarklyServerSDK._free_c_user!(c_usr)
    LaunchDarklyServerSDK._free_c_user!(c_usr)
    LaunchDarklyServerSDK._free_c_user!(c_usr)
end
