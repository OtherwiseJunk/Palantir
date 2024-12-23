require "#{Rails.root}/app/services/panopticon_service"
require "#{Rails.root}/app/services/discord_service"

PANOPTICON_SERVICE = PanopticonService.new
DISCORD_SERVICE = DiscordService.new
