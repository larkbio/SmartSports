module PasswordResetsCommon
  require 'json'

  def create
      @user = User.find_by_email(params[:email])
      begin
        if @user
          logger.info "delivering password reset instructions to #{params[:email]}, locale: #{params[:lang]}"
          if params[:lang]
            @user.mail_lang = params[:lang]
          end
          @user.generate_reset_password_token!
          url = edit_password_reset_url({id: @user.reset_password_token, locale: I18n.locale})
          Delayed::Job.enqueue InfoMailJob.new(:reset_password_email, @user.email, I18n.locale, {reset_url: url})

          render json: {:ok => true, :locale => I18n.locale}
        else
          render json: {:ok => false, :locale => I18n.locale}
        end
      rescue => e
        logger.info "Exception"
        logger.error e
        logger.error e.backtrace.join("\n")
        #redirect_to(root_path, :notice => 'Failed to send email.')
        render json: {:ok => false, :locale => I18n.locale}
      end
  end

end