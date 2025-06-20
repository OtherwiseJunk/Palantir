class OutOfContextController < ApplicationController
  before_action :authenticate_user!

  def index
    jwt = PANOPTICON_SERVICE.request_jwt

    response = HTTParty.get(
      "https://panopticon.cacheblasters.com/ooc",
      headers: { "Authorization" => "Bearer #{jwt}" }
    )

    if response.success?
      @ooc_entries = JSON.parse(response.body)
      @ooc_entries = @ooc_entries.sort_by { |entry| entry["dateStored"] }.reverse
      @ooc_entries = @ooc_entries.map { |entry| DISCORD_SERVICE.map_ooc_user_id_to_name(entry, current_user) }
    else
      @ooc_entries = []
      flash[:alert] = "Failed to fetch out-of-context entries."
    end
  end

  def destroy
    if current_user.admin || current_user.owner
      jwt = PANOPTICON_SERVICE.request_jwt
      item_id = params[:id]

      response = HTTParty.delete(
        "https://panopticon.cacheblasters.com/ooc/#{item_id}",
        headers: { "Authorization" => "Bearer #{jwt}" }
      )

      if response.success?
        flash[:notice] = "Item successfully deleted."
      else
        flash[:alert] = "Failed to delete item."
      end

      redirect_to out_of_context_index_path
    end
  end
end
