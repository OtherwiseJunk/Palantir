require "net/http"

class DiscordService
  DISCORD_API_URL = "https://discord.com/api"
  LIBCRAFT_GUILD_ID = "698639095940907048"
  ADMIN_PERMISSION = 0x8

  def initialize()
    @bot_token = ENV["DISCORD_BOT_TOKEN"]
    @cache = {}
  end

  def is_libcrafter?(user, token)
    guilds = get_user_guilds(user, token)

    guild = guilds.find { |g| g["id"] == LIBCRAFT_GUILD_ID }
    return false unless guild
    configure_user_access(user, guild)
    true
  end

  def configure_user_access(user, guild)
    user.admin = is_libcraft_admin? guild["permissions"]
    user.owner = is_bot_owner? user.email
    user.save
  end

  def get_user_guilds(user, token)
    url = URI("#{DISCORD_API_URL}/users/@me/guilds")
    request = Net::HTTP::Get.new(url)
    request["Authorization"] = "Bearer #{token}"

    response = Net::HTTP.start(url.hostname, url.port, use_ssl: true) { |http| http.request(request) }
    guilds = JSON.parse(response.body)

    guilds
  end

  def is_libcraft_admin?(permissions)
    (permissions & ADMIN_PERMISSION) != 0
  end

  def is_bot_owner?(user_email)
    user_email == ENV["OWNER_EMAIL"]
  end

  def map_ooc_user_id_to_name(ooc_item, current_user)
    user_id = ooc_item["reportingUserId"]

    if user_id == current_user.id
      ooc_item["display_name"] = "You"
    else
      ooc_item["display_name"] = fetch_user_display_name(user_id)
    end

    ooc_item
  end


  def fetch_user_display_name(user_id)
    return @cache[user_id] if @cache.key?(user_id)

    url = "https://discord.com/api/v10/users/#{user_id}"
    headers = { "Authorization" => "Bot #{@bot_token}" }

    response = HTTParty.get(url, headers: headers)

    if response.success?
      data = response.parsed_response
      display_name = data["global_name"] || "#{data["username"]}##{data["discriminator"]}"

      @cache[user_id] = display_name

      display_name
    else
      @cache[user_id] = "A Sexy, Unknowable Stranger"
    end
  end
end
