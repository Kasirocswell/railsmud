require "test_helper"

class InventoriesControllerTest < ActionDispatch::IntegrationTest
  test "should get equip" do
    get inventories_equip_url
    assert_response :success
  end

  test "should get unequip" do
    get inventories_unequip_url
    assert_response :success
  end

  test "should get list" do
    get inventories_list_url
    assert_response :success
  end
end
