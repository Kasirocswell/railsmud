require "test_helper"

class CombatLogsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get combat_logs_index_url
    assert_response :success
  end
end
