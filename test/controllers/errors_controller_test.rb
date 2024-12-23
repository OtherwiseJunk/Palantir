require "test_helper"

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  test "should get access_denied" do
    get errors_access_denied_url
    assert_response :success
  end
end
