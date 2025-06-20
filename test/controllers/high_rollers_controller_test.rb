require "test_helper"

class HighRollersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get high_rollers_index_url
    assert_response :success
  end
end
