module DietsCommon

  # POST /diets
  # POST /diets.json
  def create
    user_id = params[:user_id]
    user = User.find(user_id)

    name = params['diet']['name']
    params[:diet].delete :name

    @diet = user.diets.build(diet_params)
    if not @diet.date
      @diet.date = DateTime.now
    end

    foodType = FoodType.where(name: name).first
    if foodType.nil?
      send_error_json(name, "Invalid food type", 404)
      return
    end
    @diet.food_type_id = foodType.id

    if @diet.save
      send_success_json(@diet.id, { name: @diet.food_type.name, category: @diet.food_type.category})
    else
      send_error_json(name,  @diet.errors.full_messages.to_sentence, 400)
    end
  end

  # PATCH/PUT /diets/1
  # PATCH/PUT /diets/1.json
  def update
    if @diet.nil?
      send_error_json(nil,  "Param 'diet' missing", 400)
      return
    end

    if !check_owner()
      send_error_json(@diet.id,  'Unauthorized', 403)
      return
    end

    fav = true
    if params['diet'].nil? || params['diet']['favourite'].nil? || params['diet']['favourite']=='false'
      fav = false
    end
    update_hash = {:favourite => fav}
    if params['diet'] && params['diet']['amount']
      update_hash[:amount] = params['diet']['amount'].to_f
    end
    if params['diet'] && params['diet']['food_type_name']
      ft = FoodType.where(name: params['diet']['food_type_name']).first
      if !ft.nil?
        amount = @diet.amount
        if !update_hash[:amount].nil?
          amount = update_hash[:amount].to_f
        end
        update_hash[:food_type_id] = ft.id
        update_hash[:name] = ft.name
        # update_hash[:calories] = amount*ft.kcal
        # update_hash[:carbs] = amount*ft.carb
        # update_hash[:fat] = amount*ft.fat
        # update_hash[:prot] = amount*ft.prot
      else
        send_error_json(@diet.id,  "Invalid food type", 400)
        return
      end

    end

    if @diet.update_attributes(update_hash)
      send_success_json(@diet.id, { diet_name: @diet.diet_name})
    else
      send_error_json(@diet.id,  @diet.errors.full_messages.to_sentence, 400)
    end

  end

  # DELETE /diets/1
  # DELETE /diets/1.json
  def destroy

    if @diet.nil?
      send_error_json(nil,  "Failed to delete", 400)
      return
    end

    if @diet.destroy
      send_success_json(@diet.id, { diet_name: @diet.diet_name})
    else
      send_error_json(@diet.id,  "Delete error", 400)
    end

  end

  private

  def set_diet
    @diet = Diet.find_by_id(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def diet_params
    params.require(:diet).permit(:user_id, :source, :name, :date, :calories, :carbs, :amount, :category, :fat, :prot, :favourite)
  end
  def diet_update_params
    params.require(:diet).permit(:favourite, :amount, :date)
  end

end