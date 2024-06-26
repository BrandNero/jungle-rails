module HttpAuthenticatable
  extend ActiveSupport::Concern


  def authenticate
    authenticate_or_request_with_http_basic('Administration') do |username, password|
      username == ENV['admin_username'] && password == ENV['admin_password']
    end
  end
end