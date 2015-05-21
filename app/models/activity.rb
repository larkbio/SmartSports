class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :activity_type
  validates :user_id, presence: true
  validates :activity_type_id, presence: true
  validates :steps, allow_blank: true, numericality: {only_integer: true}
  validates :duration, allow_blank: true, numericality: true

  @@intensity_values = [(I18n.t :activity_intensity_low), (I18n.t :activity_intensity_moderate), (I18n.t :activity_intensity_high)]

  def self.intensity_values
    @@intensity_values
  end

  def title
    self.try(:activity_type).try(:name) || (I18n.t :activity_unknown)
  end

  def subtitle
    intensity = ""
    if self.intensity && self.intensity<=3
      index = self.intensity.to_i
      intensity = "#{(I18n.t :intensity)}: #{@@intensity_values[index-1]}"
     end
    duration = ""
    if self.duration
      duration = "#{I18n.t :duration}: #{self.duration} #{I18n.t :minute_abbr}"
    end
    return "#{intensity},  #{duration}"
  end

  def interval

  end
end
