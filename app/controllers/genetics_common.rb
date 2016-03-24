module GeneticsCommon

  # POST /users/:id/genetics
  def create
    user_id = params[:user_id]
    user = User.find(user_id)
    @genetics = user.genetics.build(genetics_params)
    if params['genetics'] && params['genetics']['relative_type_name']
      gt = GeneticsType.where(name: params['genetics']['relative_type_name']).first
      if gt != nil
        @genetics.relative_type_id = gt.id
      end
    end
    if params['genetics'] && params['genetics']['diabetes_type_name']
      gt = GeneticsType.where(name: params['genetics']['diabetes_type_name']).first
      if gt != nil
        @genetics.diabetes_type_id = gt.id
      end
    end
    if params['genetics'] && params['genetics']['antibody_type_name']
      gt = GeneticsType.where(name: params['genetics']['antibody_type_name']).first
      if gt != nil
        @genetics.antibody_type_id = gt.id
      end
    end


    if @genetics.save
      send_success_json(@genetics.id)
    else
      send_error_json(nil, @genetics.errors.full_messages.to_sentence, 400)
    end

  end

  # DELETE /users/:user_id/genetics/:id
  def destroy
    set_genetics
    if @genetics.destroy
      send_success_json(@genetics.id, {:msg => "Deleted successfully"})
    else
      send_error_json(@genetics.id, "Delete error", 400)
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_genetics
    @genetics = Genetic.find_by_id(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def genetics_params
    params.require(:genetics).permit(:source, :relative, :diabetes, :antibody, :note, :group, :relative_type_id, :relative_type_name, :diabetes_type_id, :diabetes_type_name, :antibody_type_id, :antibody_type_name, :antibody_kind, :antibody_value)
  end
end