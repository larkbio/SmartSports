module AdversesCommon
  def create
    user_id = params[:user_id]
    user = User.find(user_id)

    @adverse = user.adverses.build(adverse_params)

    puts @adverse
    if @adverse.save
      send_success_json(@adverse.id, {})
    else
      send_error_json(nil, "Can't create", 400)
    end
  end


  def update
    id = params[:id]
    adverse = Adverse.find_by_id(id)
    if adverse.nil?
      send_error_json(nil, "Not found", 404)
    else
      if adverse.update(adverse_params)
        send_success_json(id)
      else
        send_error_json(id, "Erorr", 400)
      end
    end

  end

  def destroy
    id = params[:id]
    adverse = Adverse.find_by_id(id)
    if adverse.nil?
      send_error_json(nil, "Not found", 404)
    else
      if adverse.destroy
        send_success_json(id)
      else
        send_error_json(id, "Erorr", 500)
      end
    end
  end

  private

  def adverse_params
    params.require(:adverse).permit(:effect_present, :effect_detail, :time)
  end
end
