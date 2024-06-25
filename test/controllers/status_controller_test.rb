require "test_helper"

class StatusControllerTest < ActionDispatch::IntegrationTest
  test "should get check" do
    get status_check_url
    assert_response :success
  end
end
