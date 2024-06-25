require "test_helper"

class CombatsControllerTest < ActionDispatch::IntegrationTest
  test "should get attack" do
    get combats_attack_url
    assert_response :success
  end
end
