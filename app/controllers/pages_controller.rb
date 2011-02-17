require 'token'
require 'sfrequest'

class PagesController < ApplicationController
  before_filter :check_token, :except => :index

  def index
    @access_token = Token::get_token
    unless @access_token.nil?

    else
      redirect_to :controller => 'authorizations', :action => 'oauth'
    end
  end

  def error
  end

  def form

  end

end
