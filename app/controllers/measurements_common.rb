module MeasurementsCommon

  # POST
  def create
    user_id = params[:user_id].to_i

    par = measurement_params
    par.merge!(:user_id => user_id)

    @measurement = Measurement.new(par)
    if @measurement.date.nil?
      @measurement.date = DateTime.now
    end

    if @measurement.save
      send_success_json(@measurement.id, {msg: create_success_message() } )
    else
      msg =  @measurement.errors.full_messages.to_sentence+"\n"
      send_error_json(@measurement.id, msg, 400)
    end
  end

  # PATCH/PUT /measurements/1
  # PATCH/PUT /measurements/1.json
  def update
    @measurement = Measurement.find_by_id(params[:id])

    if @measurement.nil?
      send_error_json(nil, "Param 'measurement' missing", 400)
      return
    end

    fav = true
    if params['measurement'].nil? || params['measurement']['favourite'].nil? || params['measurement']['favourite']=='false'
      fav = false
    end
    update_hash = {:favourite => fav}

    if params['measurement']
      if params['measurement']['systolicbp']
        update_hash[:systolicbp] = params['measurement']['systolicbp'].to_i
      end
      if params['measurement']['diastolicbp']
        update_hash[:diastolicbp] = params['measurement']['diastolicbp'].to_i
      end
      if params['measurement']['pulse']
        update_hash[:pulse] = params['measurement']['pulse'].to_i
      end
      if params['measurement']['blood_sugar']
        update_hash[:blood_sugar] = params['measurement']['blood_sugar'].to_f
      end
      if params['measurement']['stress_amount']
        update_hash[:stress_amount] = params['measurement']['stress_amount'].to_f
      end
      if params['measurement']['weight']
        update_hash[:weight] = params['measurement']['weight'].to_f
      end
      if params['measurement']['waist']
        update_hash[:waist] = params['measurement']['waist'].to_f
      end
      if params['measurement']['blood_sugar_time']
        update_hash[:blood_sugar_time] = params['measurement']['blood_sugar_time'].to_i
      end
    end

    if @measurement.update_attributes(update_hash)
      send_success_json(@measurement.id, {})
    else
      send_error_json(nil, "Update error", 400)
    end

  end

# DELETE /measurements/1
# DELETE /measurements/1.json
  def destroy
    @measurement = Measurement.find(params[:id])
    if @measurement.nil?
      send_error_json(nil, "Delete error", 400)
      return
    end

    if @measurement.destroy
      send_success_json(@measurement.id, {})
    else
      send_error_json(@measurement.id, "Delete error", 400)
    end
  end

  private

  def set_measurement
    @measurement = Measurement.find(params[:id])
  end

  def measurement_params
    params.require(:measurement).permit(:source, :systolicbp, :diastolicbp, :pulse, :blood_sugar, :weight, :waist, :date, :meas_type, :favourite, :stress_amount, :blood_sugar_time)
  end

  def create_success_message()
    if @measurement.meas_type == 'blood_pressure'
      sys = @measurement.systolicbp || '-'
      dia = @measurement.diastolicbp|| '-'
      pulse = @measurement.pulse|| '-'
      return "Blood pressure #{sys}/#{dia}/#{pulse} created"
    end
    if @measurement.meas_type == 'blood_sugar'
      return "Blood glucose measurement #{@measurement.blood_sugar} created"
    end
    if @measurement.meas_type == 'weight'
      return "Weight measurement #{@measurement.weight} created"
    end
    if @measurement.meas_type == 'waist'
      return "Waist circumfence measurement #{@measurement.waist} created"
    end
  end
end

