module NotificationsCommon
  require 'json'
  def create
    @user = User.find(params[:user_id])
    par = notification_params
    if par[:notification_type]
      par[:notification_type] = par[:notification_type].to_sym
    end
    @notification = @user.notifications.new(par)

    respond_to do |format|
      if @notification.save
        send_push(@notification)
        # format.html { redirect_to @notification, notice: 'Notification was successfully created.' }
        format.json { send_success_json(@notification.id, {msg: "created" } ) }
      else
        # format.html { render :new }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /notifications/1
  # PATCH/PUT /notifications/1.json
  def update
    if params[:dismiss]
      @notification.dismissed_on = Time.zone.now
      if @notification.save
        send_success_json(@notification.id, {:msg => "dismissed"})
      else
        send_error_json(@notification.id, "dismiss_error", 400)
      end
      return
    end
    respond_to do |format|
      if @notification.update(notification_params)
        format.html { redirect_to @notification, notice: 'Notification was successfully updated.' }
        format.json { render :show, status: :ok, location: @notification }
      else
        format.html { render :edit }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notifications/1
  # DELETE /notifications/1.json
  def destroy
    if @notification.destroy
      send_success_json(@notification.id, {:msg => "deleted"})
    else
      send_error_json(@notification.id, "delete_error", 400)
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_notification
    @notification = Notification.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def notification_params
    params.require(:notification).permit( :title, :detail, :notification_type, :notification_data, :date, :remind_at, :location, :location_url, :created_by, :recurrence_data, :default_data, :form_name)
  end

  def send_push(notif)
    user = notif.user
    if not user.dev_token.nil?
      pusher = Grocer.pusher(
          certificate: CONNECTION_CONFIG["NOTIF_CERT"],      # required
          passphrase:  CONNECTION_CONFIG["NOTIF_PASS"],                       # optional
          gateway: "gateway.sandbox.push.apple.com",
          port: 2195,
          retries:     3                         # optional
      )

      msg = ""
      if not notif.title.nil?
        msg = msg + notif.title
      end
      if not notif.detail.nil?
        msg = msg + " " + notif.detail
      end
      if msg==""
        msg = "Empty message"
      end

      notif_data = {
          user_name: user.username,
          user_id: user.id,
          notification_id: notif.id,
          form_name: notif.form_name
      }
      logger.debug("Notif data:")
      logger.debug(JSON.pretty_generate(notif_data))
      notification = Grocer::Notification.new(
          device_token:      user.dev_token.upcase,
          alert:             msg,
          badge:             42,
          category:          "a category",         # optional; used for custom notification actions
          sound:             "siren.aiff",         # optional
          expiry:            Time.now + 60*60,     # optional; 0 is default, meaning the message is not stored
          # identifier:        1234,                 # optional; must be an integer
          content_available: true,                  # optional; any truthy value will set 'content-available' to 1
          custom: notif_data
      )

      pusher.push(notification)

    end
  end

end
