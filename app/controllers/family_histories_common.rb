module FamilyHistoriesCommon

  # POST /users/:id/family_histories
  def create
    user_id = params[:user_id]
    user = User.find(user_id)
    @family_history = user.family_histories.build(family_history_params)

    if @family_history.save
      send_success_json(@family_history.id, {disease: @family_history.relative})
    else
      send_error_json(nil, @family_history.errors.full_messages.to_sentence, 400)
    end

  end

  # DELETE /users/:user_id/family_histories/:id
  def destroy
    set_family_history
    if @family_history.destroy
      send_success_json(@family_history.id, {:msg => "Deleted successfully"})
    else
      send_error_json(@family_history.id, "Delete error", 400)
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_family_history
    @family_history = FamilyHistory.find_by_id(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def family_history_params
    params.require(:family_history).permit(:source, :relative, :disease, :note, :genetics_type_id)
  end
end