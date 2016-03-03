module ApplicationHelper
  
  def get_duration(secs)
    if secs.nil?
      return "-"
    end
    if secs<60
      return "#{secs} sec"
    elsif secs < 3600
      return "%02d:%02d"%[secs/60, secs % 60]
    end
    h = secs/60/60
    secs = secs - h*60*60
    m = secs/60
    s = secs-m*60
    return "%02d:%02d:%02d"%[h, m, s]
  end

  def get_sensor_image(group)
    if /sleep/i =~ group
      return "sleep40.png"
    end
    if /ping/i =~ group
      return "pingpong40.png"
    end
    if /cycl/i =~ group
      return "cycling40.png"
    end
    if /walk/i =~ group
      return "walking40.png"
    end
    if /run/i =~ group
      return "running40.png"
    end
    if /work/i =~ group
      return "regular40.png"
    end

    return "sensor40.png"
  end

  def get_activity_image(name)
    if /alvás/i =~ name
      return "sleep40.png"
    end
    if /ping/i =~ name
      return "pingpong40.png"
    end
    if /kerékpár/i =~ name
      return "cycling40.png"
    end
    if /bicikli/i =~ name
      return "cycling40.png"
    end
    if /séta/i =~ name
      return "walking40.png"
    end
    if /futás/i =~ name
      return "running40.png"
    end
    if /"Álló munka"/i =~ name || /"fizikai munka"/i =~ name
      return "walking40.png"
    end
    if /ülés/i =~ name || /Űlő/i =~ name
      return "regular40.png"
    end
    return "walking40.png"
  end

  def get_lifestyle_elem(elem_str, lifestyle_item)
    if lifestyle_item.amount
      elem_str.split(",")[lifestyle_item.amount]
    else
      ""
    end
  end

  def get_lifestyle_time(lifestyle_time)
    if lifestyle_time
      lifestyle_time.strftime("%F %H:%M")
    else
      ""
    end
  end

  def get_lifestyle_time_min(start_time, end_time)
    if start_time && end_time
      d = end_time - start_time
      (d/60).to_i
    else
      ""
    end
  end

  def get_lifestyle_date(lifestyle_date)
    if lifestyle_date
      lifestyle_date.strftime("%F")
    else
      ""
    end
  end

  def get_notification_icon(notif)
    if notif.notification_type== 'doctor'
      return 'fa-user-md'
    elsif notif.notification_type== 'medication'
      return 'fa-medkit'
    elsif notif.notification_type== 'reminder'
      return 'fa-check-square-o'
    else
      return 'fa-list'
    end
  end
end
