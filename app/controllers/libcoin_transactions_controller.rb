class LibcoinTransactionsController < ApplicationController
  before_action :authenticate_user!

  def index
    user_id = current_user.id
    @page_number = params[:pageNumber].to_i > 0 ? params[:pageNumber].to_i : 1
    @page_size = params[:pageSize].to_i > 0 ? params[:pageSize].to_i : 25

    @transactions = fetch_transactions(user_id, @page_number, @page_size)
    @transactions = @transactions.map{ |transaction| DISCORD_SERVICE.map_transaction_user_ids_to_names(transaction, current_user) }
  end

  private

  def fetch_transactions(user_id, page_number, page_size=25)
    url = "https://panopticon.cacheblasters.com/libcoin/transactions/#{user_id}"

    api_key = ENV['DEEPSTATE_PANOPTICON_KEY']
    headers = { 'ApiKey' => api_key }

    response = HTTParty.get(url, headers: headers, query: { pageNumber: page_number, pageSize: page_size })
    JSON.parse(response.body)
  end
end
