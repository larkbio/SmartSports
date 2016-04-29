module Api::V1
  class NotificationsController < ApiController
    before_action :check_owner_or_doctor
    include NotificationsCommon

    def index
      user_id = params[:user_id].to_i
      user = User.find(user_id)
      notif = user.notifications

      if params[:upcoming] && params[:upcoming]=='true'
        notif = notif.where('date > ?', Time.zone.now)
      end
      if params[:order] && params[:order]=='asc'
        notif = notif.order(date: :asc)
      else
        notif = notif.order(date: :desc)
      end
      if params[:limit]
        lim = params[:limit].to_i
        notif = notif.limit(lim)
      end

      render json: notif
    end

  end
end