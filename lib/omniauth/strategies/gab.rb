# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Gab < OmniAuth::Strategies::OAuth2
      option :name, 'gab'

      option :client_options,
        site: 'https://api.gab.com',
        authorize_url: 'https://api.gab.com/oauth/authorize',
        token_url: 'https://api.gab.com/oauth/token',
        grant_type: 'authorization_code'

      uid { raw_info['id'].to_s }

      info do
        {
          name: raw_info['name'],
          username: raw_info['username'],
          verified: raw_info['verified'],
          image: raw_info['picture_url_full']
        }
      end

      extra do
        { raw_info: raw_info }
      end

      def raw_info
        access_token.options[:parse] = :json
        @raw_info ||= access_token.get('/v1.0/me/').parsed
      end

      def authorize_params(params = {})
        params.merge(
          'response_type' => 'code',
          'client_id' => options.client_id,
          'redirect_uri' => options.redirect_uri,
          'scope' => options.scope
        )
      end

      private

      def callback_url
        options['redirect_uri'] || (full_host + script_name + callback_path)
      end
    end
  end
end

OmniAuth.config.add_camelization 'gab', 'Gab'
