module LifestylesCommon
  # POST /lifestyles
  # POST /lifestyles.json
  def create
    @user = User.find(params[:user_id])

    user_id = @user.id
    par = lifestyle_params
    par.merge!(:user_id => user_id)
    print par
    @lifestyle = Lifestyle.new(par)
    if not @lifestyle.start_time
      @lifestyle.start_time = DateTime.now
    end
    if params['lifestyle'] && params['lifestyle']['lifestyle_type_name']
      lt = LifestyleType.where(name: params['lifestyle']['lifestyle_type_name']).first
      if lt != nil
        @lifestyle.lifestyle_type_id = lt.id
      end
    end

    if @lifestyle.save
      illness_name = nil
      if @lifestyle.lifestyle_type
        illness_name = @lifestyle.lifestyle_type.name
      end
      send_success_json(@lifestyle.id, {group: @lifestyle.group,
                                        pain_name: illness_name,
                                        illness_name: illness_name})
    else
      send_error_json(nil, @lifestyle.errors.full_messages.to_sentence, 400)
    end
  end

  # PATCH/PUT /lifestyles/1
  # PATCH/PUT /lifestyles/1.json
  def update
    if params['lifestyle'] && params['lifestyle']['lifestyle_type_name']
      lt = LifeStyleType.where(name: params['lifestyle']['lifestyle_type_name']).first
      if !lt.nil?
        @lifestyle.lifestyle_type_id = lt.id
      else
        send_error_json(@lifestyle.id,  "Invalid lifestyle type", 400)
        return
      end
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
    user = @lifestyle.user
    if @lifestyle.destroy
      send_success_json(@lifestyle.id, {:msg => "Deleted successfully"})
    else
      send_error_json(@lifestyle.id, "Delete failed", 400)
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_lifestyle
    @lifestyle = Lifestyle.find_by_id(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def lifestyle_params
    params.require(:lifestyle).permit(:user_id, :lifestyle_type_id, :lifestyle_type_name, :source, :group, :name, :details, :amount, :period_volume, :start_time, :end_time, :favourite)
  end
end