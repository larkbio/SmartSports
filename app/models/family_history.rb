class FamilyHistory < ActiveRecord::Base
  belongs_to :user
  belongs_to :genetics_type
  validates :user_id, presence: true
  validates :relative, presence: true
  # validates :disease, presence: true

  @@relativeList = [ { label: "szülő", value: "szülő" },
                   { label: "nagyszülő", value: "nagyszülő" },
                   { label: "dédszülő", value: "dédszülő" },
                   { label: "testvér", value: "testvér" },
                   { label: "unakaöcs/unokahúg", value: "unakaöcs/unokahúg" },
                   { label: "unokatestvér", value: "unokatestvér" },
                   { label: "nagybácsi/nagynéni(nem házassági rokon)", value: "nagybácsi/nagynéni" }
  ]

  @@diseaseList = [ { label: "none", value: "none" },
                  { label: "diabetes type 1", value: "diabetes type 1" },
                  { label: "diabetes type 2", value: "diabetes type 2" },
                  { label: "gestational diabetes", value: "gestational diabetes" }
  ]

  def self.relativeList
    @@relativeList
  end

  def self.diseaseList
    @@diseaseList
  end

end
