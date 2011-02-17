require 'authorization'
require 'token'

class AuthorizationsController < ApplicationController
  before_filter :check_token, :except => [:oauth, :callback]

  def oauth
    redirect_to Authorization::oauth request
  end

  def callback
    begin
      if Token::get_token.nil?
        Token::set_token Authorization::callback request, params[:code]
      end
      redirect_to :controller => 'pages', :action => 'index'
    rescue => msg
      redirect_to error_form_url, :e => msg
    end
  end

end
