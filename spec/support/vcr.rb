require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!

  # Filter out sensitive data
  # config.filter_sensitive_data('<ADYEN_API_KEY>') { ENV['ADYEN_API_KEY'] }
  # config.filter_sensitive_data('<ADYEN_MERCHANT_ACCOUNT>') { 'SpreeCommerceECOM' }
  
  # Filter out dynamic data that changes between requests
  # config.filter_sensitive_data('<IDEMPOTENCY_KEY>') do |interaction|
  #   interaction.request.headers['Idempotency-Key']&.first
  # end

  # Allow real HTTP connections to localhost for development
  config.allow_http_connections_when_no_cassette = false

  # Default cassette options
  config.default_cassette_options = {
    record: :once,
    match_requests_on: [:method, :uri, :body],
    preserve_exact_body_bytes: true,
    decode_compressed_response: true
  }

  config.before_record do |i|
    i.response.body.force_encoding('UTF-8')
  end

  # Ignore localhost requests
  config.ignore_localhost = true

  # Ignore requests to ngrok (for development)
  config.ignore_hosts 'ngrok.io', 'ngrok-free.app'
end 