class AddTimestampsToAdverses < ActiveRecord::Migration
  def change
    add_timestamps :adverses
  end
end
