module DashboardHelper
  def get_thisweek_summary()
    @calories_taken = Diet.where("user_id = :user_id AND date >= :start_date", {user_id: current_user.id, start_date: (DateTime.now-1.week)})
                          .sum("calories").round(2)
    @calories_burned = Activity.where("user_id = :user_id AND start_time >= :start_date", {user_id: current_user.id, start_date: (DateTime.now-1.week)})
                           .sum("calories").round(2)
    @steps_walked = Activity.where("user_id = :user_id AND start_time >= :start_date", {user_id: current_user.id, start_date: (DateTime.now-1.week)})
                        .sum("steps")

  end

  def get_todays_summary()
    @calories_taken = Diet.where(user_id: current_user.id).where("date between ? and ?", Time.zone.now.midnight, Time.zone.now.midnight+1.day)
                          .sum("calories").round
    if @calories_taken>0
      calories_yesterday = Diet.where(user_id: current_user.id).where("date between ? and ?", Time.zone.now.midnight-1.day, Time.zone.now.midnight)
                               .sum("calories").round

      @calories_diff = (@calories_taken-calories_yesterday)

      if calories_yesterday>0
        calories_diff_percent = @calories_diff.to_f/calories_yesterday
        @calories_diff_percent = sprintf("%+.1f%%", calories_diff_percent*100.0)
      end

      @calories_diff_show = (calories_yesterday>0) && @calories_taken>0
      @calories_status = "improve"
      @calories_arrow = "down"
      if @calories_diff>0
        @calories_status = "worsen"
        @calories_arrow = "up"
      end
    end

    day_act = Activity.where(user_id: current_user.id).where("start_time between ? and ?", Time.zone.now.midnight, Time.zone.now.midnight+1.day)
    @calories_burned = day_act.sum("calories").round
    if @calories_burned >0
      calories_burned_yesterday = Activity.where(user_id: current_user.id).where("start_time between ? and ?",
                            Time.zone.now.midnight-1.day, Time.zone.now.midnight)
                            .sum("calories").round
      @calories_burned_diff = @calories_burned-calories_burned_yesterday
      if calories_burned_yesterday>0
        calories_burned_diff_percent = @calories_burned_diff.to_f/calories_burned_yesterday
        @calories_burned_diff_percent = sprintf("%+.1f%%", calories_burned_diff_percent*100.0)
      end

      @calories_burned_diff_show = (calories_burned_yesterday>0) && @calories_burned>0
      @calories_burned_status = "worsen"
      @calories_burned_arrow = "down"
      if @calories_burned_diff>0
        @calories_burned_status = "improve"
        @calories_burned_arrow = "up"
      end
    end

    @day_exercise_time = 0
    if day_act.length>0
      @day_exercise_time = day_act.sum("duration").round
    end

    @show_bg = current_user.profile.insulin
    bg = Measurement.where(user_id: current_user.id).where("date between ? and ?", Time.zone.now.midnight, Time.zone.now.midnight+1.day).where(meas_type: 'blood_sugar')
    @show_day_bg = bg.length>0
    @bg_status = ""
    if @show_day_bg
      @day_bg_min = bg.minimum("blood_sugar").to_f.round(1)
      @day_bg_avg = bg.average("blood_sugar").to_f.round(1)
      @day_bg_max = bg.maximum("blood_sugar").to_f.round(1)
      if @day_bg_min<3 || @day_bg_max>7
        @day_bg_status = "worsen"
      end
    end

    bw = Measurement.where(user_id: current_user.id)
             .where("date between ? and ?", Time.zone.now.midnight, Time.zone.now.midnight+1.day)
             .where(meas_type: 'weight').order(date: :desc).last
    last2_bw = Measurement.where(user_id: current_user.id).where(meas_type: 'weight').order(date: :desc).limit(2)

    @show_weight_diff = false
    @bw_today = 0
    @show_bw = false
    if bw
      @show_bw = true
      @bw_today = bw.weight.round(1)
      if last2_bw.length==2
        @show_bw_diff = true
        @bw_diff = last2_bw.last.weight-last2_bw.first.weight
        @bw_arrow = "up"
        if @bw_diff<0
          @bw_arrow = "down"
        end
        @bw_diff_percent = (@bw_diff/last2_bw.first.weight.to_f*100.0).round(1)
        @bw_diff = @bw_diff.round(1)
      end
    else
      if last2_bw.length >0
        @show_bw = true
        @bw_last = last2_bw.last.weight.round(1)
        @bw_last_time = last2_bw.last.date.strftime("%F %H:%M")
      end
    end

    @show_sleep = false
    sleep_today = current_user.lifestyles.where("end_time between ? and ?", Time.zone.now.midnight, Time.zone.now.midnight+1.day).where(group: 'sleep')
    if sleep_today.length >0
      @show_sleep = true
      @sleep_amount = get_duration_amount(sleep_today)
    else
      sleep_today = current_user.tracker_data.where("(end_time between ? and ?)",DateTime.now.midnight, DateTime.now.midnight+1.day).where(group: 'sleep')
      if sleep_today.length >0
        @show_sleep = true
        @sleep_amount = get_duration_amount(sleep_today)
      end
    end

    @show_cycle_today = false
    cycle_today = current_user.tracker_data.where("end_time between ? and ?",DateTime.now.midnight, DateTime.now.midnight+1.day)
                      .where(group: 'cycling').where(source: 'moves')
    if cycle_today.length >0
      @show_cycle_today = true
      @cycle_today_value = (cycle_today.sum("distance")/1000.0).round(1)
      @cycle_today_unit = "km"
    else
      cycle_today = current_user.activities.where("end_time between ? and ?",DateTime.now.midnight, DateTime.now.midnight+1.day).where(activity_type_id: 6)
      if cycle_today.length >0
        @show_cycle_today = true
        @cycle_today_value = get_duration_amount(cycle_today)
        @cycle_today_unit = ""
      end
    end

    @show_walk_today = false
    walks_today = current_user.summaries.where("date between ? and ?",DateTime.now.midnight, DateTime.now.midnight+1.day).where(group: 'walking')
    if walks_today.length>0
      walks_for_source = walks_today.select{|it| it.source =='withings'}
      if walks_for_source.length>0
        @show_walk_today = true
        @walk_today_value = walks_today.sum("steps").round
        @walk_today_unit = "steps"
      end

      if !@show_walk_today
        walks_for_source = walks_today.select{|it| it.source =='moves'}
        if walks_for_source.length>0
          @show_walk_today = true
          @walk_today_value = walks_today.sum("steps").round
          @walk_today_unit = "steps"
        end
      end
    end
    if !@show_walk_today
      walks_today = current_user.activities.where("end_time between ? and ?",DateTime.now.midnight, DateTime.now.midnight+1.day).where(activity_type_id: 60)
      if walks_today.length >0
        @show_walk_today = true
        @walk_today_value = get_duration_amount(walks_today)
        @walk_today_unit = ""
      end
    end

    #current_user.summaries.create({source: 'withings', group: 'walking', date: Time.now, steps: 9874})
    #walks_today = current_user.tracker_data.where("(end_time between ? and ?)",DateTime.now.midnight, DateTime.now.midnight+1.day).where(group: 'walking')


    @steps_walked = Activity.where("user_id = :user_id AND start_time >= :start_date", {user_id: current_user.id, start_date: (DateTime.now-1.week)})
                        .sum("steps")

  end

  private
  def get_duration_amount(arr)
    sec = arr.collect{ |it| it.end_time-it.start_time}.sum.to_i
    hours = sec/3600
    sleep_min = (sec%3600)/60
    return sprintf("%02d:%02d", hours, sleep_min)
  end
end