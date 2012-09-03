class ApplicationController < ActionController::Base
  
  protect_from_forgery

  before_filter :authenticate
  
  AUTH_USERS = { "$app_name" => "$app_name123" }

  private
  def authenticate
    return true unless Rails.env.production?
    authenticate_or_request_with_http_basic do |username|
      AUTH_USERS[username]
    end
  end

end