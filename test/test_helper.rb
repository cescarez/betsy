require 'simplecov'
SimpleCov.start do
  add_filter 'test/'
  add_filter 'helper'
end
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require "minitest/rails"
require "minitest/reporters"  # for Colorized output
#  For colorful output!
Minitest::Reporters.use!(
  Minitest::Reporters::SpecReporter.new,
  ENV,
  Minitest.backtrace_filter
)

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  # parallelize(workers: :number_of_processor) # causes out of order output.

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def setup
    OmniAuth.config.test_mode = true
  end

  def mock_auth_hash(user)
    return {
        uid: user.uid,
        provider: user.provider,
        info: {
            name: user.username,
            email: user.email,
            image: user.avatar
        }
    }
  end

  # Helper method that performs a log-in w/ either
  # a passed-in user or the first test user
  def perform_login(user = nil)
    user ||= User.first
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))
    # Act Try to call the callback route
    get omniauth_callback_path(:github)
    # find the user
    user = User.find_by(uid: user.uid, username: user.username)
    expect(user).wont_be_nil
    # Verify the user ID was saved - if that didn't work, this test is invalid
    expect(session[:user_id]).must_equal user.id
  end
  # Add more helper methods to be used by all tests here...

  def start_cart
    post orders_path, params: {order: {status: "pending", submit_date: Time.now}}
    expect(session[:order_id]).wont_be_nil
    return Order.last
  end

end

