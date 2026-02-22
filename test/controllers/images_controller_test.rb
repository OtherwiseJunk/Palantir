require "test_helper"

class ImagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get images_index_url, as: :json
    assert_response :success
  end
end
