class NotificationsController < ApplicationController
  before_action :set_notification, only: [:show, :edit, :update, :destroy]
  before_action :check_owner_or_doctor, only: [:index, :show, :edit, :create, :update, :destroy]

  include NotificationsCommon
  include NotificationsHelper

  # GET /notifications
  # GET /notifications.json
  def index
    @patient = false
    if params[:patient] && params[:patient]=='true'
      @patient = true
    end

    @user = User.find(params[:user_id])
    @notifications = @user.notifications
    if params[:order] && params[:order]=='asc'
      @notifications = @notifications.order(created_at: :asc)
    else
      @notifications = @notifications.order(created_at: :desc)
    end

    if params[:ntype] == 'visits'
      @notifications = @notifications.where("notification_type=1 or notification_type=2")
    end
    if params[:active]
      @notifications = active_notifications(@notifications)
    end

  end

  # GET /notifications/1
  # GET /notifications/1.json
  def show

  end

  # GET /notifications/new
  def new
    @user = User.find(user_id)
    @notification = @user.notifications.create
  end

  # GET /notifications/1/edit
  def edit
  end

  private

  def active_notifications(arr)
    today = Time.zone.now.strftime("%F")
    day = Time.zone.now.strftime("%a").downcase
    result = arr.select do |notif|
      ret = false
      if notif.date.nil?||notif.date==""
        logger.warn("notification #{notif.id} has no date assigned")
      else
        if recurringOnDay(notif.recurrence_data, day)
          if notif.dismissed_on.nil? || notif.dismissed_on<Time.zone.now.midnight
            ret = true
          end
        else
          if notif.date.strftime("%F") == today
            if notif.dismissed_on.nil? || notif.dismissed_on<Time.zone.now.midnight
              ret = true
            end
          end
        end
      end
      ret
    end
    return result
  end

end
