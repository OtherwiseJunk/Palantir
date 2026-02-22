require "test_helper"

class HighRollersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should get redirect for unauthorized user" do
    get high_rollers_url
    assert_response :redirect
  end

  test "should get index for authorized user" do
    user = users(:one)
    sign_in user

    get high_rollers_url
    assert_response :success
  end
end
