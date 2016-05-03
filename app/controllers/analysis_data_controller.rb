require 'csv'
class AnalysisDataController < ApplicationController
  respond_to :json

  def index
    user_id = params[:user_id]
    user = User.find(user_id)

    f=nil
    t=nil
    if params[:date]
      date = params[:date]
      if params[:weekly]
        f = Time.zone.parse(date).at_beginning_of_week
        t = Time.zone.parse(date).at_end_of_week
      else
        f = Time.zone.parse(date).at_beginning_of_day
        t = Time.zone.parse(date).at_end_of_day
        end
    end
    lang = params[:lang]
    if !lang
      lang = 'hu'
    end
    result = nil
    if params[:tabular]
      result = get_tabular_data(user, f, t)
    elsif params[:dashboard]
      result = get_timeline_data(user, f, t, true,lang)
      sorted = result.sort_by{|e| e[:dates][0]}
      result = sorted.last(15)
    else
      result = get_timeline_data(user, f, t, false,lang)
    end

    respond_to do |format|
      format.csv {
        d = result.collect do |it|
          if it.member?(:start) && it[:start]
            start = it[:start].strftime("%F %R")
          else
            start = nil
          end
          if it.member?(:end) && it[:end]
            e = it[:end].strftime("%F %R")
          else
            e = nil
          end
          [start, e, it[:evt_type], it[:group], it[:value1], it[:value2] ].to_csv(row_sep:nil)
        end.join("\n")
        send_data d
      }
      format.json { render json: result}
    end
  end

  def get_timeline_data(user, f, t, dashboard, lang)
    result = []
    activities_key_list = ActivityType.all
    food_key_list = FoodType.all
    if lang == 'hu'
      activities_val_list = DB_HU_CONFIG['activities']
      food_val_list = DB_HU_CONFIG['diets']
    else
      activities_val_list = DB_EN_CONFIG['activities']
      food_val_list = DB_EN_CONFIG['diets']
    end
    activities = user.activities

    if f
      activities = activities.where("start_time between ? and ?", f, t)
    end

    result.concat(activities.collect{|act|
                    item = {
                      id: act.id,
                      tooltip: activities_val_list[activities_key_list.find(act.activity_type_id).name],
                      title: 'Exercise',
                      depth: 0,
                      dates: [act.start_time, act.end_time],
                      kind: 'exercise',
                      evt_type: 'exercise',
                      source: 'SmartDiab'}
                    if act['activity_type_id']==6
                      item['evt_type']='cycling'
                    elsif act['activity_type_id']==60 || !act['steps'].nil? && act['steps']>0
                      item['evt_type']='steps'
                      if item['tooltip']
                        item['tooltip'] = item['tooltip']+" "+act.steps+" steps"
                      end
                    end
                    item
                  })

    diets = user.diets
    if f
      diets = diets.where("date between ? and ?", f, t)
    end
    result.concat(diets.collect{|diet|
                    item = {
                      id: diet.id,
                      tooltip: diet.try(:food_type).try(:name),
                      title: 'Diet',
                      depth: 0,
                      dates: [diet.date],
                      kind: 'diet',
                      evt_type: 'food',
                      source: 'SmartDiab'
                    }
                    if diet.diet_type== 'Calory'
                      item['tooltip'] = (I18n.t :quick_calories)
                    else
                      category = food_key_list.find_by_id(diet.food_type_id).try(:category)
                      name = food_key_list.find_by_id(diet.food_type_id).try(:name)
                      unless category.nil? || name.nil?
                        item['tooltip'] = food_val_list[category][name]
                        item['evt_type'] = category.downcase
                      end
                    end

                    item
                  })


    measurements = user.measurements
    if f
      measurements = measurements.where("date between ? and ?", f, t)
    end
    meas_arr = []
    meas_arr.concat(measurements.collect do |measurement|
                      ret = {
                          id: measurement.id,
                          tooltip: measurement.get_title,
                          title: 'Health',
                          depth: 0,
                          dates: [measurement.date],
                          kind: 'health',
                          evt_type: measurement.meas_type,
                          source: 'SmartDiab'
                      }

                      if measurement.meas_type=='blood_pressure'
                        ret['values']= [measurement.systolicbp, measurement.diastolicbp, measurement.pulse]
                      elsif measurement.meas_type=='blood_sugar'
                        ret['values'] = [measurement.blood_sugar]
                      elsif measurement.meas_type=='weight'
                        ret['values'] = [measurement.weight]
                      elsif measurement.meas_type=='waist'
                        ret['values'] = [measurement.waist]
                      end

                      ret
                    end
    )
    result.concat(meas_arr)

    if(!dashboard)
      lifestyles = user.lifestyles
      if f
        lifestyles = lifestyles.where("(start_time between ? and ?) OR (end_time between ? and ?)", f, t, f, t )
      end
      lifes_arr = []
      lifes_arr.concat(lifestyles.collect do |lifestyle|
        ret = {
            id: lifestyle.id,
            tooltip: lifestyle.tooltip,
            title: 'Lifestyle',
            depth: 0,
            dates: [lifestyle.start_time, lifestyle.end_time],
            kind: 'lifestyle',
            evt_type: 'lifestyle',
            amount: lifestyle.amount,
            source: 'SmartDiab'
        }
        if lifestyle.lifestyle_type.try(:category)=='stress'
          ret['lf_group']= ['stress', "Stress"]
        elsif lifestyle.lifestyle_type.try(:category)=='illness'
          ret['lf_group']= ['illness', lifestyle.name]
        elsif lifestyle.lifestyle_type.try(:category)=='pain'
          ret['lf_group']= ['pain', lifestyle.name+"(pain)"]
        end
        ret
      end
      )
      result.concat(lifes_arr)

      medications = user.medications.where("date between ? and ?", f, t)
      result.concat(medications.collect{|med|
                      item = {
                        id: med.id,
                        tooltip: med.try(:medication_type).try(:name)+" : #{med.amount}",
                        title: 'Medication',
                        depth: 0,
                        dates: [med.date],
                        kind: 'medication',
                        evt_type: 'drug',
                        group: med.try(:medication_type).try(:group),
                        source: 'SmartDiab'
                      }
                      if med.medication_type.try(:group)=='insulin'
                        item['evt_type'] = 'insulin'
                      end
                      item
                    })

      sensors = user.sensor_measurements.where("(start_time between ? and ?) OR (end_time between ? and ?)", f, t, f, t)
      for sens in sensors do
        if sens.version && sens.version =='2.0'
          proc_20_sensor(sens, result)
        else
          proc_old_sensor(sens, result)
        end
      end

      # tracker data
      tracker_data = user.tracker_data.where("(start_time between ? and ?) OR (end_time between ? and ?)", f, t, f, t).where.not(group: 'transport')
      tracker_filtered = tracker_data.select{|d|
        !d.activity.nil? && d.activity!='transport' && (d.activity!='walking'||(d.end_time-d.start_time>240.0))
      }.collect {|d|
        title = 'Exercise'
        etype = 'exercise'
        if d.activity=='sleep'
          title = 'Well-being'
          etype = 'sleep'
        end
        {
            id: d.id,
            tooltip: d.activity.try(:capitalize),
            title: title,
            source: d.source.capitalize,
            depth: 0,
            kind: 'wellbeing',
            evt_type: etype,
            dates: [d.start_time, d.end_time]
        }
      }
      result.concat(tracker_filtered)
    end
    return result
  end

  def get_tabular_data(user, f, t)
    result = []

    activities = user.activities

    if f
      activities = activities.where("start_time between ? and ?", f, t)
    end

    result.concat(activities.collect{|act| {
                      start: act.start_time,
                      end: act.end_time,
                      evt_type: 'activity',
                      group: act.group=='sport'?'exercise':'regular',
                      value1: act.activity_type_id,
                      value2: nil
                  }})

    diets = user.diets
    if f
      diets = diets.where("date between ? and ?", f, t)
    end
    result.concat(diets.collect{|diet| {
                      start: diet.date,
                      end: nil,
                      evt_type: 'diet',
                      group: diet.diet_type.downcase,
                      value1: diet.calories,
                      value2: diet.carbs
                  }})

    measurements = user.measurements
    if f
      measurements = measurements.where("date between ? and ?", f, t)
    end
    meas_arr = []
    meas_arr.concat(measurements.collect do |measurement|
                      grp = measurement.meas_type
                      ret = []
                      if grp=='blood_pressure'
                        if measurement.systolicbp
                          item = {
                              start: measurement.date,
                              end: nil,
                              evt_type: 'measurement',
                              group: 'systolic',
                              value1: measurement.systolicbp,
                              value2: nil
                          }
                          ret.append(item)
                        end
                        if measurement.diastolicbp
                          item = {
                              start: measurement.date,
                              end: nil,
                              evt_type: 'measurement',
                              group: 'diastolic',
                              value1: measurement.diastolicbp,
                              value2: nil
                          }
                          ret.append(item)
                        end
                        if measurement.pulse
                          item = {
                              start: measurement.date,
                              end: nil,
                              evt_type: 'measurement',
                              group: 'pulse',
                              value1: measurement.pulse,
                              value2: nil
                          }
                          ret.append(item)
                        end
                      else
                        ret = {
                            start: measurement.date,
                            end: nil,
                            evt_type: 'measurement',
                            group: grp,
                            value1: nil,
                            value2: nil
                        }

                        if measurement.meas_type=='blood_sugar'
                          ret[:value1] = measurement.blood_sugar.try(:round, 2)
                        elsif measurement.meas_type=='weight'
                          ret[:value1] = measurement.weight
                        elsif measurement.meas_type=='waist'
                          ret[:value1] = measurement.waist
                        end

                      end

                      ret
                    end
    )
    result.concat(meas_arr.flatten)

    lifestyles = user.lifestyles
    if f
      lifestyles = lifestyles.where("(start_time between ? and ?) OR (end_time between ? and ?)", f, t, f, t )
    end
    lifes_arr = []
    lifes_arr.concat(lifestyles.collect do |lifestyle|
      ret = {
          start: lifestyle.start_time,
          evt_type: 'lifestyle',
          group: lifestyle.lifestyle_type.try(:category),
          value1: lifestyle.amount
      }
      if lifestyle.lifestyle_type.try(:category) != 'stress'
        ret['end'] = lifestyle.end_time
      else
        ret['end'] = lifestyle.start_time+1.day
      end
      ret['value2']= lifestyle.lifestyle_type.try(:category)
      ret
    end
    )
    result.concat(lifes_arr)

    return result
  end

  def proc_20_sensor(sens, result)
    sens.sensor_data.select{ |d| d.sensor_type=='HEART'}.each do |sd|
      sd.sensor_segments.each do |seg|
        result.concat(extract_hr_data(sens.id, sens.group, seg.data_a, seg.start_time))
      end
    end
  end
  def proc_old_sensor(sens, result)
    if sens.hr_data
      result.concat(extract_hr_data(sens.id, sens.group, sens.hr_data, sens.start_time))
    end
  end

  def extract_hr_data(id, group, encData, start_time)
    raw = Base64.decode64(encData).bytes.each_slice(2).to_a.collect{|it| it[1]*256+it[0]}
    curr_time = start_time.to_f
    last_time = curr_time
    val = []
    bufsize = 30
    tot = [0]*bufsize
    n = 0
    raw.in_groups_of(2) do |delta, hr|
      curr_time += delta/1000.0
      if curr_time-last_time > 60.0
        val.append({time: curr_time.to_i, data:tot.inject{|a,b| a+b}/bufsize.to_f})
        last_time = curr_time
      else
        if hr>0
          tot << hr
        end
        if(tot.size>bufsize)
          tot = tot.drop(1)
        end
        n += 1
      end
    end
    return([{
                       id: id,
                       tooltip: group,
                       title: 'Sensor',
                       start_time: start_time,
                       values: val,
                       evt_type: 'sensor',
                       source: 'SmartDiab'
                   }])
  end
end
