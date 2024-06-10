require_relative 'lib/xero-oauth2/version'

Gem::Specification.new do |spec|
  spec.name        = 'omniauth-xero-oauth2'
  spec.version     = OmniAuth::XeroOauth2::VERSION
  spec.licenses    = ['MIT']
  spec.summary     = 'OAuth2 Omniauth strategy for Xero.'
  spec.description = 'OAuth2 Omniauth straetgy for Xero API.'
  spec.authors     = ['Xero API']
  spec.email       = 'api@xero.com'
  spec.homepage    = 'https://rubygems.org/gems/omniauth-xero-oauth2'
  spec.metadata    = { 'source_code_uri' => 'https://github.com/XeroAPI/xero-oauth2-omniauth-strategy' }
  spec.files       = ['lib/omniauth-xero-oauth2.rb','lib/xero-oauth2/version.rb','lib/omniauth/strategies/xero_oauth2.rb']

  spec.add_runtime_dependency 'jwt', '~> 2.0'
  spec.add_runtime_dependency 'omniauth', '>= 2.0.0', '< 2.2.0'
  spec.add_runtime_dependency 'omniauth-oauth2', '~> 1.8.0'

  spec.add_development_dependency 'rspec', '~> 3.6'
end
