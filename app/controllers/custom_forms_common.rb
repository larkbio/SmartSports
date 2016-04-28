module CustomFormsCommon


  def index
    if params[:user_id]
      @user_id = params[:user_id].to_i
      user = User.find(@user_id)
      @custom_forms = user.custom_forms.order(order_index: :desc)
    else
      @custom_forms = CustomForm.all.order(id: :desc)
    end
  end

  def create
    @user_id = params[:user_id]
    user = User.find(@user_id)
    n = user.custom_forms.collect{|it| it.order_index }.select{|it| !it.nil?}.max
    if n.nil?
      n = 0
    end
    @custom_form = user.custom_forms.build(custom_form_params)
    @custom_form.order_index = n+1

    if @custom_form.save
      send_success_json(@custom_form.id, {custom_form_name: @custom_form.form_name})
    else
      send_error_json(nil, @custom_form.errors.full_messages.to_sentence, 400)
    end
  end

  def update
    @user_id = params[:user_id].to_i
    user = User.find(@user_id)
    custom_form_id = params[:id].to_i
    cf = user.custom_forms.where(id: custom_form_id).first
    if !cf
      send_error_json(user.id, "custom_form_id missing", 400)
      return
    end
    if request.patch?
      # To update custom form order

      o = params[:custom_form_element_order]
      if o.nil?
        send_error_json(user.id, "order missing", 400)
        return
      end
      arr = o.split(',')
      n = cf.custom_form_elements.size
      if n!=arr.size
        send_error_json(user.id, "order wrong_length", 400)
        return
      end
      CustomForm.transaction do
        i = 0
        for c in cf.custom_form_elements.order(:id) do
          c.order_index = arr[i]
          i += 1
          c.save
        end
      end
      send_success_json(cf.id, {:msg => "order updated"})
    else
      # PUT request, update params
      # update_hash = {:form_name => params['custom_form']['form_name'], :image_name => params['custom_form']['image_name']}
      if cf.update_attributes(custom_form_params)
        send_success_json(cf.id)
      else
        send_error_json(cf.id, cf.errors.full_messages.to_sentence, 400)
      end
    end


  end

  def destroy
    @user_id = params[:user_id].to_i
    user = User.find(@user_id)

    cf = user.custom_forms.where(id: params[:id].to_i).try(:first)
    if cf.nil?
      send_error_json(params[:id].to_i, "custom_form_not_found", 400)
      return
    end
    if cf.destroy
      send_success_json(params[:id].to_i, {})
    else
      send_error_json(params[:id].to_i, "custom_form_delete_failed", 400)
    end
  end

  private

  def custom_form_params
    params.require(:custom_form).permit(:form_name, :form_tag, :image_name, :order_index)
  end

end