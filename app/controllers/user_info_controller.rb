class UserInfoController < ApplicationController
  def index
    render json: request.headers[:bearer]
  end
end
