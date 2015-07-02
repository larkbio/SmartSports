module DietsCommon

  # POST /diets
  # POST /diets.json
  def create
    user_id = params[:user_id]
    user = User.find(user_id)
    puts diet_params
    @diet = user.diets.build(diet_params)
    if not @diet.date
      @diet.date = DateTime.now
    end
    if (@diet.diet_type=='Food' || @diet.diet_type=='Drink' )
      ft = FoodType.find_by_id(@diet.food_type_id)
      @diet.calories = @diet.amount*ft.kcal
      @diet.carbs = @diet.amount*ft.carb
      @diet.fat = @diet.amount*ft.fat
      @diet.prot = @diet.amount*ft.prot
    end

    if @diet.save
      send_success_json(@diet.id, { diet_name: @diet.diet_name})
    else
      send_error_json(nil,  @diet.errors.full_messages.to_sentence, 400)
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
    if params['diet'] && params['diet']['food_type_id']
      ft = FoodType.find_by_id(params['diet']['food_type_id'].to_i)
      if !ft.nil?
        amount = @diet.amount
        if !update_hash[:amount].nil?
          amount = update_hash[:amount].to_f
        end
        update_hash[:food_type_id] = ft.id
        update_hash[:calories] = amount*ft.kcal
        update_hash[:carbs] = amount*ft.carb
        update_hash[:fat] = amount*ft.fat
        update_hash[:prot] = amount*ft.prot
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

    if !check_owner()
      send_error_json(@diet.id,  "Unauthorized", 403)
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
    params.require(:diet).permit(:user_id, :source, :name, :date, :calories, :carbs, :amount, :category, :diet_type, :fat, :prot, :food_type_id, :favourite)
  end
  def diet_update_params
    params.require(:diet).permit(:favourite, :amount, :date)
  end

  def check_owner()
    puts "try"
    if self.try(:current_user)
      puts "current_user defined"
    else
      puts "current_user NOT defined"
    end
    if self.try(:current_resource_owner)
      puts "current_resource_owner defined"
    else
      puts "current_resource_owner NOT defined"
    end

    if self.try(:current_user).try(:id) == @diet.user_id
      return true
    end
    if self.try(:current_resource_owner).try(:id) == @diet.user_id
      return true
    end
    return false
  end
end