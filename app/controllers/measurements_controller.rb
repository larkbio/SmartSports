require 'csv'
class MeasurementsController < ApplicationController
  before_action :set_measurement, only: [:show, :edit, :update, :destroy]
  before_action :check_owner_or_doctor
  include MeasurementsCommon

  def new
    @measurement = Measurement.new
  end

  def load_recent
    user_id = params[:user_id]
    user = User.find(user_id)
    @measurements = user.measurements.where(source: source).order(date: :desc).limit(4)
    respond_to do |format|
      format.js
    end
  end

  def index
    user_id = params[:user_id]
    meas_type = params[:meas_type]
    summary = (params[:summary] and params[:summary] == "true")
    start = params[:start]
    user = User.find(user_id)
    hourly = params[:hourly]
    source = params[:source]
    order = params[:order]
    limit = params[:limit]
    favourites = params[:favourites]

    @measurements = user.measurements
    if start
      @measurements = @measurements.where("date >= '#{start}'")
    end
    if source
      @measurements = @measurements.where(:source => [source, 'demo'])
    end
    if meas_type
      @measurements = @measurements.where(meas_type: meas_type)
    end
    if order
      @measurements = @measurements.order(date: :desc)
    else
      @measurements = @measurements.order(date: :asc)
    end
    if limit
      @measurements = @measurements.limit(limit)
    end
    if favourites and favourites == "true"
      @measurements = @measurements.where(favourite: true)
    end

    if summary
      daily_data = Hash.new { |h,k| h[k] = [] }
      for m in @measurements
        if m.date
          k = m.date.strftime("%F")
          daily_data[k] << m
        end
      end

      days = daily_data.keys().sort()
      result = []
      for day in days
        daily = daily_data[day]
        aggr = {"date" => day, "systolicbp"=>0, "diastolicbp"=>0, "pulse"=>0, "SPO2"=>0, "blood_sugar" => nil, "weight" => nil, "waist" => nil}
        for meas in ["systolicbp", "diastolicbp", "pulse", "SPO2", "blood_sugar", "weight", "waist"]
          values = daily.select { |d| !d[meas].nil?}.map { |d| d[meas] }
          num = values.length
          if num > 0
            aggr[meas] = (values.inject {|sum, curr| sum+curr}.to_f/num)
          else
            aggr[meas] = nil
          end
        end
        result << aggr
      end

      respond_to do |format|
        format.json {render json: result}
      end
    else if hourly
      result = []
      data = user.measurements.collect{|it| [it.date.hour, it[hourly]]}.select{|it| !it[1].nil?}

      hash = Hash.new{ |h,k| h[k] = []}
      data.each do |it|
        hash[it[0]] << it[1]
      end

      hours = hash.keys().sort()
      hours.each do |hour|
        if hash[hour] and hash[hour].size!=0
          stats = get_stats(hash[hour])
          result << {
              :hour => hour,
              :min => hash[hour].min,
              :max => hash[hour].max,
              :avg => stats[:avg],
              :median => stats[:median],
              :lower => stats[:lower],
              :upper => stats[:upper],
              :sd => stats[:sd],
              :size => hash[hour].size
          }
        end
      end
      respond_to do |format|
        format.json {render json: result}
      end
    else
      respond_to do |format|
        format.html
        format.json {render json: @measurements}
        format.csv { send_data @measurements.to_csv}
        format.js
      end
    end
    end
  end

  def get_stats(arr)
    len = arr.size
    if len == 0
      return nil
    end
    result = {}
    avg = arr.reduce{|c, s| c+s}/len.to_f
    result[:avg] = avg
    arr.sort!
    med_index = len/2
    if (len>1)
      med_index -= 1
    end
    result[:median] = arr[med_index]
    result[:lower] = arr[(len*0.25).floor()]
    result[:upper] = arr[(len*0.75).floor()]
    result[:sd] = Math.sqrt(arr.reduce{|s, c| s+(c-avg)**2}/len.to_f)
    return result
  end

  def show
  end

end
