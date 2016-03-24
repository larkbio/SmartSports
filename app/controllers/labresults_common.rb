module LabresultsCommon

  # POST /users/[user_id]/labresults
  # POST /users/[user_id]/labresults.json
  def create
    user_id = params[:user_id]
    par = labresult_params
    par.merge!(:user_id => user_id)
    print par
    labresult = Labresult.new(par)

    if params['labresult'] && params['labresult']['labresult_type_name']
      lt = LabresultType.where(name: params['labresult']['labresult_type_name']).first
      if lt != nil
        labresult.labresult_type_id = lt.id
      end
    end

    if labresult.save
      send_success_json(labresult.id, {category: labresult.category})
    else
      h = labresult.errors.to_hash()
      print h
      msgs = []
      for k in h.keys()
        for err in h[k]
          msgs << "#{k}_#{err}"
        end
      end
      keys = labresult.errors.full_messages().collect{|it| it}
      send_error_json(nil, msgs)
    end
  end

  # PATCH/PUT /labresults/1
  # PATCH/PUT /labresults/1.json
  def update
    @labresult = Labresult.find_by_id(params[:id])

    if @labresult.nil?
      send_error_json(nil, "Param 'labresult' missing", 400)
      return
    end

    if !check_owner()
      send_error_json(@labresult.id, "Unauthorized", 403)
      return
    end

    if params['labresult'] && params['labresult']['labresult_type_name']
      lt = LabresultType.where(name: params['labresult']['labresult_type_name']).first
      if lt != nil
         update_hash[:labresult_type_id] = lt.id
      end
    end
    if params['labresult'] && params['labresult']['hba1c']
      update_hash[:hba1c] = params['labresult']['hba1c'].to_f
    end
    if params['labresult'] && params['labresult']['ldl_chol']
      update_hash[:ldl_chol] = params['labresult']['ldl_chol'].to_f
    end
    if params['labresult'] && params['labresult']['egfr_epi']
      update_hash[:egfr_epi] = params['labresult']['egfr_epi'].to_f
    end
    if params['labresult'] && params['labresult']['ketone']
      update_hash[:ketone] = params['labresult']['ketone'].to_s
    end
    if params['labresult'] && params['labresult']['controll_type']
      update_hash[:controll_type] = params['labresult']['controll_type'].to_s
    end

    if @labresult.update_attributes(update_hash)
      send_success_json(@labresult.id, {:msg => "Updated successfully"})
    else
      send_error_json(@labresult.id, "Update error", 400)
    end

  end

  # DELETE /users/:user_id/labresults/:id
  # DELETE /users/:user_id/labresults/:id.json
  def destroy
    @labresult = Labresult.find(params[:id])
    if @labresult.nil?
      send_error_json(nil, "Delete error", 400)
      return
    end

    if !check_owner()
      send_error_json(@labresult.id, "Unauthorized", 403)
      return
    end

    if @labresult.destroy
      send_success_json(@labresult.id, {:msg => "Deleted successfully"})
    else
      send_error_json(@labresult.id, "Delete error", 400)
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def labresult_params
    params.require(:labresult).permit(:user_id, :source, :category, :hba1c, :ldl_chol, :egfr_epi, :ketone, :date, :controll_type, :remainder_date, :labresult_type_id, :labresult_type_name)
  end

end