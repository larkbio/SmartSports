class LifeStyleValidator < ActiveModel::Validator
  def validate(record)
    if (record.group == 'illness' && record.illness_type_id == nil)
      record.errors[:illness_type_id] << 'no_value'
    elsif (record.group == 'pain' && record.pain_type_name == nil || record.pain_type_name == "")
      record.errors[:pain_type_name] << 'no_value'
    end
    if record.start_time && record.end_time
      if record.end_time < record.start_time
        record.errors[:base] << (I18n.t :error_end_time_greater)
      end
    end
  end
end

class Lifestyle < ActiveRecord::Base
  belongs_to :user
  belongs_to :illness_type
  belongs_to :pain_type
  validates :user_id, presence: true
  validates :group, presence: true
  validates :start_time, presence: true
  validates :amount, :numericality => true, :allow_nil => true
  validates_with LifeStyleValidator

  @@sleepList = ["Very bad", "Fairly bad", "Fairly good", "Very good"]
  @@stressList = ["Below average", "Average", "Medium", "High"]
  @@illnessList = ["Slight mild", "Mild", "Moderate", "Severe", "More severe"]
  @@painList = ["Slight mild", "Mild", "Moderate", "Severe", "Worst possible"]
  @@periodPainList = ["No pain","Mild pain","Moderate pain","Severe pain","Very painful"]
  @@periodVolumeList = ["Light", "Moderate", "Strong", "Quite heavy","Heavy"]
  @@painTypeList = ["Szövetsérüléssel járó fájdalom","Zsigeri fájdalom","Idegi eredetű fájdalom","Lelki eredetű fájdalom","Mellkasi szorító fájdalom","Migrén","Ízületi fájdalom", "Hát-derékfájdalom"]

  def self.sleepList
    @@sleepList
  end
  def self.stressList
    @@stressList
  end
  def self.illnessList
    @@illnessList
  end
  def self.painList
    @@painList
  end
  def self.periodPainList
    @@periodPainList
  end
  def self.periodVolumeList
    @@periodVolumeList
  end
  def self.painTypeList
    @@painTypeList
  end

  def title
    if self.group
      if self.group=="illness"
        return self.illness_type.name
      elsif self.group == "pain"
        return "#{self.pain_type_name} pain"
      else
        return self.group.capitalize
      end
    else
      return "Unknown"
    end
  end

  def subtitle
    result = "Unknown"
    case self.group
      when "sleep"
        result = @@sleepList[self.amount] if self.amount
      when "stress"
        result = @@stressList[self.amount] if self.amount
      when "illness"
        result = @@illnessList[self.amount] if self.amount
      when "pain"
        result = @@painList[self.amount] if self.amount
      when "period"
        result = "#{@@periodPainList[self.amount]}, #{@@periodVolumeList[self.period_volume]} volume" if self.amount
    end
    return result
  end

  def tooltip
    result = self.group
    if self.group=='sleep'
      result = "Sleep, #{@@sleepList[self.amount] if self.amount}"
    end
    return result
  end

  def interval
    if self.group == 'stress'
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
    return   "From: #{start_time} To: #{end_time}"
  end
end
