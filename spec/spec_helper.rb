# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require 'dotenv/load'
require 'timecop'

require File.expand_path('../dummy/config/environment.rb', __FILE__)

require 'spree_dev_tools/rspec/spec_helper'
require 'spree_adyen/factories'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].sort.each { |f| require f }

# Load VCR configuration
require 'support/vcr'

RSpec::Matchers.define_negated_matcher :not_change, :change

def json_response
  case body = JSON.parse(response.body)
  when Hash
    body.with_indifferent_access
  when Array
    body
  end
end
