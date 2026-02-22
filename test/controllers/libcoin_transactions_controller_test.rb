require "test_helper"
require "minitest/mock"
require "ostruct"

class LibcoinTransactionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  test "should redirect for unauthorized user" do
    get libcoin_transactions_index_url
    assert_response :redirect
  end
  test "should get index for authorized user" do
    user = users(:one)
    sign_in user

    mock_response = OpenStruct.new(body: "[]")
    HTTParty.stub :get, mock_response do
      get libcoin_transactions_index_url
      assert_response :success
    end
  end
end
