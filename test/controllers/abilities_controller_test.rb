require "test_helper"

class AbilitiesControllerTest < ActionDispatch::IntegrationTest
  test "should get use" do
    get abilities_use_url
    assert_response :success
  end
end
