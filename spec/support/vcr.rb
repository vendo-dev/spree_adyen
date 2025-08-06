require 'vcr'
require 'webmock/rspec'

WebMock.disable_net_connect!(net_http_connect_on_start: true, allow_localhost: true)

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = false
  c.cassette_library_dir = File.join(SpreeAdyen::Engine.root, 'spec', 'vcr')
  c.hook_into :webmock
  c.ignore_localhost = true
  c.configure_rspec_metadata!
  c.default_cassette_options = { record: :new_episodes }
  c.filter_sensitive_data('<ADYEN_API_KEY>') { |i| i.request.headers['X-Api-Key']&.first }

  c.before_record do |interaction|
    header_names = %w[X-Stripe-Client-User-Agent]
    headers = header_names.flat_map { |header_name| interaction.request.headers[header_name] }.compact

    headers.each { |header| interaction.filter!(header, '<FILTERED>') }
  end
end
