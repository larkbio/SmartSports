module MedicationsCommon

  # POST /users/[user_id]/medications
  # POST /users/[user_id]/medications.json
  def create
    user_id = params[:user_id]
    user = User.find(user_id)
    name = params['medication']['name']
    params[:medication].delete :name
    mt = MedicationType.find_by_name(name)

    medication = user.medications.build(medication_params)
    medication.medication_type = mt

    if medication.save
      send_success_json(medication.id, {name: medication.medication_type.name, title: medication.medication_type.title})
    else
      send_error_json(medication.id, medication.errors.full_messages.to_sentence, 400)
    end

  end

  # PATCH/PUT /medications/1
  # PATCH/PUT /medications/1.json
  def update
    @medication = Medication.find_by_id(params[:id])
    @user_id = @medication.user_id

    if @medication.nil?
      send_error_json(nil, "Param 'medication' missing", 400)
      return
    end

    fav = true
    if params['medication'].nil? || params['medication']['favourite'].nil? || params['medication']['favourite']=='false'
      fav = false
    end
    update_hash = {:favourite => fav}

    if params['medication'] && params['medication']['amount']
      update_hash[:amount] = params['medication']['amount'].to_i
    end
    if params['medication'] && params['medication']['medication_type_id']
      mt = MedicationType.find_by_id(params['medication']['medication_type_id'].to_i)
      if !mt.nil?
        update_hash[:medication_type_id] = mt.id
      else
        send_error_json(nil, "Invalid medication_type_id", 400)
        return
      end
    end

    if @medication.update_attributes(update_hash)
      send_success_json(@medication.id, {:msg => "Updated successfully"})
    else
      send_error_json(@medication.id, "Update error", 400)
    end

  end

  # DELETE /users/:user_id/medications/:id
  # DELETE /users/:user_id/medications/:id.json
  def destroy
    @medication = Medication.find(params[:id])
    @user_id = @medication.user_id
    if @medication.nil?
      send_error_json(nil, "Delete error", 400)
      return
    end

    if @medication.destroy
      send_success_json(@medication.id, {:msg => "Deleted successfully"})
    else
      send_error_json(@medication.id, "Delete error", 400)
    end

  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def medication_params
    params.require(:medication).permit(:user_id, :source, :name, :amount, :date, :favourite)
  end

end