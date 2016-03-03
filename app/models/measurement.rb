require 'csv'

class MeasValidator < ActiveModel::Validator
  def validate(record)
    if record.meas_type == 'blood_pressure' &&
        ((record.systolicbp == nil && record.diastolicbp == nil && record.pulse == nil) ||
        (record.systolicbp != nil && record.diastolicbp == nil)||(record.systolicbp == nil && record.diastolicbp != nil))
      record.errors[:systolicbp] << 'Invalid blood pressure and pulse measurements'
    elsif record.meas_type == 'blood_sugar' && record.blood_sugar == nil
      record.errors[:blood_sugar] << 'Missing blood sugar value'
    elsif record.meas_type == 'weight' && record.weight == nil
      record.errors[:weight] << 'Missing weight value'
    elsif record.meas_type == 'waist' && record.waist == nil
      record.errors[:waist] << 'Missing waist value'
    end
  end
end

class Measurement < ActiveRecord::Base
  belongs_to :user
  validates :user_id, :presence => true
  validates :systolicbp, :numericality => true, :allow_nil => true
  validates :diastolicbp, :numericality => true, :allow_nil => true
  validates :pulse, :numericality => true, :allow_nil => true
  validates :blood_sugar, :numericality => true, :allow_nil => true
  validates :weight, :numericality => true, :allow_nil => true
  validates :waist, :numericality => true, :allow_nil => true
  # validates :SPO2, :numericality => true
  validates_with MeasValidator

  def get_title
    result = self.meas_type
    if self.meas_type == 'blood_pressure'
      if self.systolicbp.nil? && !self.pulse.nil?
        result = (I18n.t :pulse) +": #{self.pulse}"
      elsif !self.systolicbp.nil? && self.pulse.nil?
        result = (I18n.t :sysdias) +": #{self.systolicbp}/#{self.diastolicbp}"
      else
        result = (I18n.t :sysdiaspulse) +": #{self.systolicbp}/#{self.diastolicbp}/#{self.pulse}"
      end
    elsif self.meas_type == 'blood_sugar'
      result = (I18n.t :blood_glucose) +": #{self.blood_sugar} mmol/L"
    elsif self.meas_type == 'weight'
      result = (I18n.t :body_weight) +": #{self.weight}kg"
    elsif self.meas_type == 'waist'
      result = (I18n.t :waist_circumfence) +": #{self.waist}cm"
    end

    return result
  end

  def self.to_csv(options={})
    CSV.generate(options) do |csv|
      csv << ['ID', 'date', 'type', 'value']
      all.each do |meas|
        if !meas.meas_type.nil?
          value = ''
          if meas.meas_type == 'blood_pressure'
            if meas.systolicbp
              value = meas.systolicbp.to_s
            end
            if value != ''
              value = value+'/'
            end
            if meas.diastolicbp
              value = value+meas.diastolicbp.to_s
            end
            if value != ''
              value = value+' '
            end
            if meas.pulse
              value = value+meas.pulse.to_s
            end
          elsif meas.meas_type == 'blood_sugar'
            value = meas.blood_sugar
          elsif meas.meas_type == 'weight'
            value = meas.weight
          elsif meas.meas_type == 'waist'
            value = meas.waist
          end
          csv << [meas.id, meas.date.strftime("%Y-%m-%d %H:%M"), meas.meas_type, value]
        end
      end
    end
  end

end
