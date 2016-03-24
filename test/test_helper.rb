ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
require 'capybara/rails'

Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include Sorcery::TestHelpers::Rails
  include Sorcery::TestHelpers::Rails::Controller
end

DatabaseCleaner.strategy = :transaction

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
  setup do
    DatabaseCleaner.start
  end

  teardown do
    DatabaseCleaner.clean
    Capybara.reset_sessions!
  end

end

ActionDispatch::IntegrationTest.extend Minitest::Spec::DSL

require 'mocha/mini_test'