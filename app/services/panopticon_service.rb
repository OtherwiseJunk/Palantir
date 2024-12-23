class PanopticonService
  attr_accessor :auth0_client_id, :auth0_client_secret, :auth0_audience,
                :auth0_grant_type, :auth0_scope

  @jwt = nil

  def initialize
    @auth0_client_id = ENV["AUTH0CLIENTID"]
    @auth0_client_secret = ENV["AUTH0CLIENTSECRET"]
    @auth0_audience = ENV["AUTH0AUDIENCE"]
    @auth0_grant_type = ENV["AUTH0GRANTTYPE"]
  end

  def request_jwt
    Rails.logger.info("====Starting JWT Request Function====")
    Rails.logger.info("Is JWT Null? #{@jwt.nil?}")

    token = decode_jwt(@jwt) unless @jwt.nil?
    if token && token[:exp] > Time.now.to_i
      Rails.logger.info("Reusing existing JWT...")
      return @jwt
    end

    Rails.logger.info("Requesting Panopticon JWT...")
    uri = URI("https://dev-apsgkx34.us.auth0.com/oauth/token")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request["Accept"] = "application/json"
    request['Content-Type'] = 'application/json'
    request.body = {
      client_id: @auth0_client_id,
      client_secret: @auth0_client_secret,
      audience: @auth0_audience,
      grant_type: @auth0_grant_type,
    }.to_json

    response = http.request(request)
    Rails.logger.info("Panopticon JWT Status Code: #{response.code}")

    if response.code.to_i == 200
      json_response = JSON.parse(response.body)
      @jwt = json_response["access_token"]
      @jwt
    else
      Rails.logger.error("Failed to fetch JWT: #{response.body}")
      nil
    end
  end

  private

  def decode_jwt(jwt)
    decoded_token = JWT.decode(jwt, nil, false)
    {
      exp: decoded_token.first["exp"]
    }
  rescue JWT::DecodeError => e
    Rails.logger.error("Failed to decode JWT: #{e.message}")
    nil
  end
end
