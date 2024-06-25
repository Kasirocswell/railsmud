require "test_helper"

class NpcInteractionsControllerTest < ActionDispatch::IntegrationTest
  test "should get interact" do
    get npc_interactions_interact_url
    assert_response :success
  end

  test "should get assign_quest" do
    get npc_interactions_assign_quest_url
    assert_response :success
  end
end
