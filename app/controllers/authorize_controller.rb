require 'oidc/request'
require 'oidc/response'

class AuthorizeController < ApplicationController
  def new
    @req = OIDC::Request.new(params)
    return deal_error_at_new unless @req.valid?
    render :new
  end

  def create
    res = OIDC::Response.new(params)
    res.owner = User.find_by(name: params[:name], pass: params[:pass])

    redirect_to res.build_response
  end

  private

  def deal_error_at_new
    if Client.valid_redirect_uri?(params[:client_id], params[:redirect_uri])
      render_error_with_redirect_uri
    else
      render json: @req.error.response
    end
  end

  def render_error_with_redirect_uri
    redirect_to @req.error.with_fragment(params[:redirect_uri])
  end
end
