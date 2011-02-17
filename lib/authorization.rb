require 'oauth2'

module Authorization

  def Authorization.client
    OAuth2::Client.new(
      '3MVG9zeKbAVObYjPWX7.1fNTRQweoQ2LPrwV7Xiqc5kwFLkkPbuyo9lI9fR7bCbB61nOZ5RTbG1m448xxJ65i', 
      '8239832435732356986', 
      :site => 'https://login.salesforce.com', 
      :authorize_path =>'/services/oauth2/authorize', 
      :access_token_path => '/services/oauth2/token'
    )
  end

  def Authorization.oauth request
    client.web_server.authorize_url(
      :response_type => 'code',
      :redirect_uri => "http://localhost:3000/authorizations/callback"
    )
  end

  def Authorization.callback request, params
    client.web_server.get_access_token(params, :redirect_uri => 
                     "http://localhost:3000/authorizations/callback", 
                     :grant_type => 'authorization_code')
  end
end
