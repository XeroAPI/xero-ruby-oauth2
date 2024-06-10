require 'omniauth-oauth2'
require 'jwt'

module OmniAuth
  module Strategies
    class XeroOauth2 < OmniAuth::Strategies::OAuth2
      option :name, :xero_oauth2

      option :client_options, {
        site: 'https://api.xero.com/api.xro/2.0',
        authorize_url: 'https://login.xero.com/identity/connect/authorize',
        token_url: 'https://identity.xero.com/connect/token'
      }

      option :authorize_options, %i[login_hint state redirect_uri callback_url scope]

      option :token_params, {}
      option :scope, 'openid email profile'

      uid { raw_info['xero_userid'] }

      extra do
        {
          id_token: id_token,
          xero_tenants: xero_tenants,
          raw_info: raw_info,
        }
      end

      info do
        {
          name: [raw_info['given_name'], raw_info['family_name']].compact.join(' '),
          first_name: raw_info['given_name'],
          last_name: raw_info['family_name'],
          email: raw_info['email'],
        }
      end

      def authorize_params
        super.tap do |params|
          options[:authorize_options].each do |k|
            params[k] = request.params[k.to_s] unless [nil, ''].include?(request.params[k.to_s])
          end

          session['omniauth.state'] = params[:state] if params[:state]
        end
      end

      def callback_url
        options[:redirect_uri] || (full_host + callback_path)
      end

      private

      def id_token
        @id_token ||= access_token['id_token']
      end

      def raw_info
        if access_token['id_token'].nil?
          @raw_info = {
            'xero_userid' => '',
            'given_name' => '',
            'family_name' => '',
            'email' => ''
          }
        else
          begin
            decoded_info = JWT.decode access_token['id_token'], nil, false
            @raw_info ||= decoded_info[0]
          rescue JWT::DecodeError => e
            logger.warn "JWT Decode Error: #{e.message}"
            @raw_info = {}
          end
        end
      end

      def xero_tenants
        @xero_tenants ||= begin
          response = access_token.get(
            "https://api.xero.com/connections",
            { 'Authorization' => "Bearer #{access_token.token}", 'Accept' => 'application/json' }
          )
          JSON.parse(response.body)
        rescue StandardError => e
          logger.warn "Error fetching Xero tenants: #{e.message}"
          []
        end
      end

      def build_access_token
        redirect_uri = request.params['redirect_uri'] || callback_url
        authorization_code = request.params['code'] || JSON.parse(request.body.read)['code']

        client.auth_code.get_token(
          authorization_code,
          { redirect_uri: redirect_uri }.merge(token_params.to_hash(symbolize_keys: true)),
          deep_symbolize(options.auth_token_params || {})
        )
      rescue JSON::ParserError => e
        raise(OmniAuth::Error, 'Error parsing authorization code.')
      rescue StandardError => e
        raise(OmniAuth::Error, e)
      end
    end
  end
end
