class CscController < ApplicationController
  skip_before_action :authenticate_account!
  skip_authorize_resource

  def get_states
    @states = CS.get(params[:country]).map{|k, v| [v,k]}
  end

  def get_cities
    @cities = CS.get(params[:country], params["submission"]["data_json"]["data"]["#{params[:category_id].to_s}"]["#{params[:question_id].to_s}"]["state"])
  end
end