class HighRollersController < ApplicationController
  before_action :authenticate_user!
  PLAYING_SLOTS_MESSAGE = "Playing the slot machine".freeze
  WINNING_SLOTS_MESSAGE = "Winning from the slot machine".freeze
  CASINO_MESSAGES = [
    PLAYING_SLOTS_MESSAGE,
    WINNING_SLOTS_MESSAGE
  ].freeze

  def index
    casino_transactions = fetch_all_casino_transactions
    @casino_user_stats = process_casino_transactions(casino_transactions)
  end

  def fetch_all_casino_transactions
    all_transactions = []
    page_number = 1
    page_size = 10_000
    base_url = "https://panopticon.cacheblasters.com/libcoin/transactions"

    api_key = ENV["DEEPSTATE_PANOPTICON_KEY"]
    headers = { "ApiKey" => api_key }

    hydra = Typhoeus::Hydra.new(max_concurrency: 5)
    client_batch_size = 5

    loop do
      current_batch_results = Array.new(client_batch_size) { [] }
      any_page_empty_in_this_batch = false

            client_batch_size.times do |i|
        current_page_to_fetch = page_number + i
        params = { pageNumber: current_page_to_fetch, pageSize: page_size }
        request = Typhoeus::Request.new(
          base_url,
          headers: headers,
          params: params,
          method: :get,
          timeout: 10
        )

        request.on_complete do |response|
          if response.success?
            fetched_txns = JSON.parse(response.body)
            current_batch_results[i] = fetched_txns
            any_page_empty_in_this_batch = true if fetched_txns.empty?
          else
            Rails.logger.error "API error fetching page #{current_page_to_fetch}: #{response.code} - #{response.status_message}"
            any_page_empty_in_this_batch = true
          end
        end
        hydra.queue(request)
      end

      hydra.run

      transactions_added_this_batch = 0
      current_batch_results.each do |txns_for_page|
        all_transactions.concat(txns_for_page)
        transactions_added_this_batch += txns_for_page.length
      end

      break if any_page_empty_in_this_batch || transactions_added_this_batch == 0

      page_number += client_batch_size
    end

    all_transactions.select do |transaction|
      CASINO_MESSAGES.include?(transaction["transactionMessage"])
    end
  end

  private

  def process_casino_transactions(transactions)
    user_stats = {}

    transactions.each do |transaction|
      user_id = transaction["receivingUser"].to_s
      user_stats[user_id] ||= { winnings: 0, losses: 0 }
      amount = transaction["amount"].to_i
      case transaction["transactionMessage"]
      when WINNING_SLOTS_MESSAGE
        user_stats[user_id][:winnings] += amount
      when PLAYING_SLOTS_MESSAGE
        user_stats[user_id][:losses] += amount
      end
    end

    processed_stats = user_stats.map do |user_id, data|
      display_name = DISCORD_SERVICE.fetch_user_display_name(user_id)
      net_winnings = data[:winnings] - data[:losses]
      {
        user_id: user_id,
        winnings: data[:winnings],
        losses: data[:losses],
        display_name: display_name,
        net: net_winnings
      }
    end

    processed_stats.sort_by! { |stat| -stat[:net] }
  end
end
