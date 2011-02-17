require 'oauth2'

module OAuth2

  # Monkey patch to correct the Authorization header
  class OAuth2::AccessToken
      def request(verb, path, params = {}, headers = {})
        @client.request(verb, path, params, headers.merge('Authorization' => "OAuth #{@token}"))
      end
  end

  # Monkey patch to correct status handling
  class OAuth2::Client
      def request(verb, url, params = {}, headers = {})
        if verb == :get || verb == :delete
          resp = connection.run_request(verb, url, nil, headers) do |req|
            req.params.update(params)
          end
        else
          resp = connection.run_request(verb, url, params, headers)
        end
        
        case resp.status
          when 200, 201, 204
            if json?
              return OAuth2::ResponseObject.from(resp)
            else
              return OAuth2::ResponseString.new(resp)
            end
          when 401
            e = OAuth2::AccessDenied.new("Received HTTP 401 during request.")
            e.response = resp
            raise e
          else
            e = OAuth2::HTTPError.new("Received HTTP #{resp.status} during request.")
            e.response = resp
            raise e
        end
      end
  end
end
