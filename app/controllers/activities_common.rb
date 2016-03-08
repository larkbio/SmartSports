module ActivitiesCommon

  # POST /activities
  # POST /activities.json
  def create
    user_id = params[:user_id]
    user = User.find(user_id)

    @activity = user.activities.build(activity_params)
    if not @activity.start_time
      @activity.start_time = DateTime.now
    end
    actType = ActivityType.find_by_id(@activity.activity_type_id)
    if actType.nil?
      send_error_json(nil, "Invalid activity type", 404)
      return
    elsif not @activity.duration
      if @activity.start_time && @activity.end_time
        @activity.duration = ((@activity.end_time-@activity.start_time) / 60).to_i
      end
    end

    if user.profile && user.profile.year_of_birth && user.profile.weight && user.profile.height && actType.kcal && @activity.duration
      ages = Time.now.year - user.profile.year_of_birth

      durationInHour = @activity.duration/60.0
      if user.profile.sex == "female"
        @activity.calories = (actType.kcal * 3.5/((655.0955+(1.8496 * user.profile.height)+(9.5634 * user.profile.weight)-(4.6756 * ages))/1440/5/user.profile.weight * 1000))*user.profile.weight*durationInHour
      elsif user.profile.sex == "male"
        @activity.calories = (actType.kcal * 3.5/((66.4730+(5.0033 * user.profile.height)+(13.7516 * user.profile.weight)-(6.7550 * ages))/1440/5/user.profile.weight * 1000))*user.profile.weight*durationInHour
      end
    end

    # respond_to do |format|
    if @activity.save
      cal_message = ""
      if !(user.profile.height && user.profile.weight && user.profile.year_of_birth && user.profile.sex)
        cal_message = (I18n.t :cal_message)
      end
      send_success_json(@activity.id, {activity_name: @activity.activity, cal_message: cal_message})
    else
      send_error_json(nil, @activity.errors.full_messages.to_sentence, 400)
    end
    # end
  end


  # PATCH/PUT /diets/1
  # PATCH/PUT /diets/1.json
  def update
    if @activity.nil?
      send_error_json( @activity.id, "Param 'activity' missing", 400)
      return
    end

    if !check_owner()
      send_error_json(@activity.id, "Unauthorized", 403)
      return
    end

    fav = true
    if params['activity'].nil? || params['activity']['favourite'].nil? || params['activity']['favourite']=='false'
      fav = false
    end
    update_hash = {:favourite => fav}

    if params['activity'] && params['activity']['intensity']
      update_hash[:intensity] = params['activity']['intensity'].to_f
    end

    if params['activity'] && params['activity']['group']
      update_hash[:group] = params['activity']['group']
    end


    if @activity.update_attributes(update_hash)
      send_success_json(@activity.id)
    else
      send_error_json(@activity.id, @activity.errors.full_messages.to_sentence, 400)
    end

  end

  # DELETE /diets/1
  # DELETE /diets/1.json
  def destroy

    if @activity.nil?
      send_error_json(nil, "Delete error", 400)
      return
    end

    currid = @activity.id
    if !check_owner()
      send_error_json(currid, "Unauthorized", 403)
      return
    end

    if @activity.destroy
      send_success_json(currid, {})
    else
      send_error_json(currid, "Delete error", 400)
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_activity
    @activity = Activity.find_by_id(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def activity_params
    params.require(:activity).permit(:source, :activity, :group, :game_id, :start_time, :end_time, :steps, :duration, :distance, :calories, :manual, :intensity, :favourite, :activity_type_id)
  end
end