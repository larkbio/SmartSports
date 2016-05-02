module LifestylesCommon
  # POST /lifestyles
  # POST /lifestyles.json
  def create
    user = User.find(params[:user_id])
    name = params['lifestyle']['name']
    params[:lifestyle].delete :name

    lifestyle = user.lifestyles.build(lifestyle_params)
    lt = LifestyleType.where(name: name).first
    if lt.nil?
      send_error_json(name, "Invalid lifestyle type", 404)
      return
    end
    lifestyle.lifestyle_type = lt


    if not lifestyle.start_time
      lifestyle.start_time = DateTime.now
    end
    # This is to add the time to stress and illness start_time, so the ordering will not be mixed for today
    if lifestyle.start_time.today?
      new_time = Time.zone.now
      if lt.category=='stress' or lt.category=='illness' or lt.category=='period'
        param_time = lifestyle.start_time
        lifestyle.start_time = DateTime.new(param_time.year, param_time.month, param_time.day,
                                            new_time.hour, new_time.min, 0, new_time.zone)
      end
      if lt.category=='illness' or lt.category=='period'
        param_time = lifestyle.end_time
        lifestyle.end_time = DateTime.new(param_time.year, param_time.month, param_time.day,
                                            new_time.hour, new_time.min, 0, new_time.zone)
      end
    end

    if lifestyle.save
      send_success_json(lifestyle.id, {name: lifestyle.lifestyle_type.name,
                                        category: lifestyle.lifestyle_type.category})
    else
      send_error_json(nil, lifestyle.errors.full_messages.to_sentence, 400)
    end
  end

  # PATCH/PUT /lifestyles/1
  # PATCH/PUT /lifestyles/1.json
  def update
    if params['lifestyle'] && params['lifestyle']['lifestyle_type_name']
      lt = LifeStyleType.where(name: params['lifestyle']['lifestyle_type_name']).first
      if lt.nil?
        send_error_json(@lifestyle.id,  "Invalid lifestyle type", 404)
        return
      end
      @lifestyle.lifestyle_type_id = lt.id

    end

    if @lifestyle.update(lifestyle_params)
      send_success_json(@lifestyle.id, {})
    else
      send_error_json(@lifestyle.id, @lifestyle.errors.full_messages.to_sentence, 400)
    end
  end

  # DELETE /lifestyles/1
  # DELETE /lifestyles/1.json
  def destroy
    if @lifestyle.destroy
      send_success_json(@lifestyle.id, {:msg => "Deleted successfully"})
    else
      send_error_json(@lifestyle.id, "Delete failed", 400)
    end
  end

  private
  def get_lifestyles()
    user_id = params[:user_id]
    user = User.find_by_id(user_id)
    @lifestyles = user.lifestyles
    if params[:source]
      @lifestyles = @lifestyles.where(source: params[:source])
    end
    @lifestyles = @lifestyles.order("start_time desc, id desc")
    if params[:limit]
      @lifestyles = @lifestyles.limit( params[:limit].to_i )
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_lifestyle
    @lifestyle = Lifestyle.find_by_id(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def lifestyle_params
    params.require(:lifestyle).permit(:user_id, :source, :name, :details, :amount, :period_volume, :start_time, :end_time, :favourite)
  end
end