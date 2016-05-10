class User < ActiveRecord::Base
  has_many :connections
  has_many :activities
  has_many :measurements
  has_many :diets
  has_many :medications
  has_many :lifestyles
  has_many :personal_records
  has_many :family_records
  has_many :notifications
  has_many :sensor_measurements
  has_many :labresults
  has_many :click_records
  has_many :tracker_data
  has_many :summaries
  has_many :custom_forms
  has_many :adverses
  has_one :profile, :dependent => :destroy
  authenticates_with_sorcery!
  validates :password, length: { minimum: 4, message: "error_registration_password"}, allow_nil: true
  validates :password, confirmation: {message: "error_registration_password_confirmation2"}
  validates :password_confirmation, presence: { message: "error_registration_password_confirmation"}, if: :password
  validates :email, uniqueness: { message: "error_registration_email_used"}
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create, message: "error_registration_email_format"}

  has_attached_file :avatar, :styles => { :medium => "150x150#", :thumb => "75x75#" },
                    :default_url => "unknown.jpeg",
                    :url => "/system/:class/:attachment/:id/:style/:basename.:extension",
                    :path => APP_CONFIG['PAPERCLIP_PATH']

  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  attr_accessor :mail_lang

  def get_name
    if !self.profile.nil? && (!self.profile.firstname.nil?||!self.profile.lastname.nil?)&&(self.profile.firstname!=""||self.profile.lastname!="")
      name = ""
      name += self.profile.firstname+" " if self.profile.firstname
      name += self.profile.lastname if self.profile.lastname
    else
      name = self.name
    end
    return name
  end
  def is_friend?(fid)
    f = Friendship.where("authorized = 't' and (( user1_id = #{self.id} and user2_id = #{fid} ) or ( user1_id = #{fid} and user2_id = #{self.id} ))")
    return (f.size == 1)
  end

  def has_profile
    p = Profile.where("user_id = #{self.id}")
    return (p.size == 1)
  end
end
