module HttpAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate
  end
  def authenticate
    authenticate_or_request_with_http_basic('Administration') do |username, password|
      username == .ENV['admin_username'] && password == ENV['admin_password']
    end
  end
end