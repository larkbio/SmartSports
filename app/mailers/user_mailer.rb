class UserMailer < ActionMailer::Base
  default from: "info@smartdiab.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.reset_password_email.subject
  #
  def reset_password_email(mail_job)
    logger.info(mail_job.as_json)
    loc = mail_job.try(:lang) || "en"
    @email = mail_job.email
    logger.info("UserMailer.reset_password_email to: #{@email}, loc:#{loc}")

    @url  = mail_job.mail_params[:reset_url]
    I18n.with_locale(loc.to_sym) do
      subj = I18n.t :reset_password_email_subj
      mail(:to => @email, :subject => subj)
    end
  end

  def doctor_invite_email(mail_job)
    logger.info(mail_job.as_json)
    loc = mail_job.try(:lang) || "en"
    @email = mail_job.email
    logger.info("UserMailer.doctor_invite_email to: #{@email}, loc:#{loc}")

    @url  = mail_job.mail_params[:reset_url]
    I18n.with_locale(loc.to_sym) do
      subj = I18n.t :doctor_invite_email_subj
      mail(:to => @email, :subject => subj)
    end
  end

  def user_created_email(mail_job)
    logger.info(mail_job.as_json)
    @url  = login_url
    loc = mail_job.lang || "en"
    dest_email = mail_job.email
    logger.info "UserMailer.user_created_email to: #{dest_email}, url: @url, lang=#{loc}"
    I18n.with_locale(loc.to_sym) do
      subj = I18n.t :user_created_email_subj
      mail(:to => dest_email, :subject => subj)
    end
  end
end
