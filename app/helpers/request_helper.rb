module RequestHelper
  def check_valid_user()
    if !params[:user_id] or !User.find_by_id(params[:user_id].to_i)
      send_error_json(params[:user_id], "Invalid request", 401)
    end
  end

end