class LifeStyleValidator < ActiveModel::Validator
  def validate(record)
    if record.start_time && record.end_time
      if record.end_time < record.start_time
        record.errors[:base] << (I18n.t :error_end_time_greater)
      end
    end
  end
end

class Lifestyle < ActiveRecord::Base
  belongs_to :user
  belongs_to :lifestyle_type
  validates :user_id, presence: true
  validates :start_time, presence: true
  validates :amount, :numericality => true, :allow_nil => true
  validates_with LifeStyleValidator

  def title
    if self.lifestyle_type
      if self.lifestyle_type.category=="illness"
        return self.lifestyle_type.name
      elsif self.lifestyle_type.category == "pain"
        return "#{self.lifestyle_type.name} pain"
      else
        return self.lifestyle_type.category.capitalize
      end
    else
      return "Unknown"
    end
  end

  def subtitle
    result = "Unknown"
    if self.lifestyle_type
      case self.lifestyle_type.categoryqn
        when "sleep"
          result = t(:sleepList)[self.amount] if self.amount
        when "stress"
          result = t(:stressList)[self.amount] if self.amount
        when "illness"
          result = t(:illnessList)[self.amount] if self.amount
        when "pain"
          result = t(:painList)[self.amount] if self.amount
        when "period"
          result = "#{t(:periodPainList)[self.amount]}, #{t(:periodVolumeList)[self.period_volume]} volume" if self.amount
      end
    end
    return result
  end

  def tooltip
    result = "Unknown"
    if self.lifestyle_type
      result = self.lifestyle_type.category
      if self.lifestyle_type.category=='sleep'
        result = "Sleep, #{ t(:sleepList)[self.amount] if self.amount}"
      end
    end
    return result
  end

  def interval
    if self.lifestyle_type && self.lifestyle_type.category == 'stress'
      result = "On: #{self.start_time.strftime('%F')}"
      return result
    end

    if self.start_time
      start_time = self.start_time.strftime("%F %H:%M")
    else
      start_time = ""
    end
    if self.end_time
      end_time = self.end_time.strftime("%F %H:%M")
    else
      end_time = ""
    end
    return "From: #{start_time} To: #{end_time}"
  end
end
