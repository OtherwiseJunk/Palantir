require "test_helper"

class LibcoinTransactionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get libcoin_transactions_index_url
    assert_response :success
  end
end
