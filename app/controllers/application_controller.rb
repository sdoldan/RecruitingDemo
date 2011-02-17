require 'token'

class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_token

  private
    def check_token
      if Token::get_token.nil?
        redirect_to :controller => 'pages', :action => 'index'
      end
    end

end
