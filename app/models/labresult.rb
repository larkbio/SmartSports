class LabValidator < ActiveModel::Validator

  def validate(record)

    if record.hba1c == nil && record.ldl_chol == nil && record.egfr_epi == nil && record.ketone == nil
      record.errors[:category] << 'unknown'
    else
      if record.hba1c
        record.category = 'hba1c'
      end
      if record.ldl_chol
        record.category = 'ldl_chol'
      end
      if record.egfr_epi
        record.category = 'egfr_epi'
      end
      if record.ketone
        record.category = 'ketone'
      end
    end

    if record.invalid_date
      print "set invalid #{@invalid_date}"
      record.errors[:date] << 'invalid'
    elsif record.date.nil?
      print "set missing"
      record.errors[:date] << 'missing'
    end

  end
end

class Labresult < ActiveRecord::Base
  belongs_to :user
  belongs_to :labresult_type
  validates :user_id, :presence => true, :allow_nil => true
  validates :hba1c, :numericality => {message: 'should_be_number'}, :allow_nil => true
  validates :ldl_chol, :numericality => {message: 'should_be_number'}, :allow_nil => true
  validates :egfr_epi, :numericality => {message: 'should_be_number'}, :allow_nil => true
  #validates :date, :presence => false, :allow_nil => true
  validates_with LabValidator

  def date=(datestr)
    val = Chronic.parse(datestr)
    if !datestr.nil? && val.nil?
      @invalid_date = true
    end
    self.send(:write_attribute, :date, val)
  end

  def invalid_date
    return @invalid_date
  end
end
