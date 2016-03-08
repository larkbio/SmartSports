module ResponseHelper

  def send_success_json(id, data={})
    save_click_record( :success, id )
    resp = data.merge({id: id, ok: true})
    render json: resp
  end

  def send_success_json_norecord(id, data={})
    resp = data.merge({id: id, ok: true})
    render json: resp
  end

  def send_error_json(id, msg, status=200)
    click_msg = ""
    if msg.class==Array
      if msg.length >0
        click_msg = msg[0]
      end
    else
      click_msg = msg
    end

    save_click_record( :failure, id, click_msg )
    render json: { msg:  msg, ok: false, data: id }, :status => status
  end

end
