module ResourceAuthHelper

  def check_owner_or_doctor()
    unless owner? || doctor?
      send_error_json(params[:id], "Unauthorized", 403)
    end
  end

  def check_doctor()
    unless doctor?
      send_error_json(nil, "Unauthorized", 403)
    end
  end
  def doctor?
    self.try(:current_resource_owner).try(:doctor?)
  end

  def check_admin()
    unless admin?
      send_error_json(nil, "Unauthorized", 403)
    end
  end

  def admin?
    return self.try(:current_resource_owner).try(:admin?)
  end

  def check_owner()
    unless owner?
      send_error_json(nil, "Unauthorized", 403)
    end
  end

  def owner?
    user_id = params[:user_id].to_i
    return (self.try(:current_resource_owner).try(:id) == user_id)
  end


end
