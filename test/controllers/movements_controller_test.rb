require "test_helper"

class MovementsControllerTest < ActionDispatch::IntegrationTest
  test "should get move" do
    get movements_move_url
    assert_response :success
  end
end
