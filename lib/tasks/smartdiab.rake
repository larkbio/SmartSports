require 'json'
require 'csv'

namespace :smartdiab do
  "Load default medications"
  task init_medication: :environment do
    if MedicationType.all.size != 0
      MedicationType.all.delete_all
    end

    insulin = Regexp.new(/insulin/)
    injection = Regexp.new(/injekc/)

    File.open("#{ENV['HOME']}/Downloads/medications.json") do |f|
      medlist = JSON.load(f)

      #print medlist.first.as_json.pretty_inspect
      medlist.each do |m|

        grp = "oral"
        if insulin === m['substance']
          grp = "insulin"
        else
          if injection === m['name'] or m['name'].start_with?('[')
            next
          end
        end

        mt = MedicationType.new(:name =>  m['name'], :group => grp)
        mt.save!
      end
    end
  end

  task init_db: :environment do
    Rake::Task['smartdiab:init_activity'].execute
    Rake::Task['smartdiab:init_food'].execute
    Rake::Task['smartdiab:init_genetics'].execute
    Rake::Task['smartdiab:init_illness'].execute
    Rake::Task['smartdiab:init_labresult'].execute
    Rake::Task['smartdiab:init_lifestyle'].execute
    if InitVersion.all.size == 1
      actualVersion = InitVersion.last
      actualVersion.update(:version_number => actualVersion.version_number+1)
    else
      InitVersion.all.delete_all
      v = InitVersion.new(:id => 1, :version_number =>  1)
      v.save!
    end
  end

  task init_activity: :environment do
    if ActivityType.all.size != 0
      ActivityType.all.delete_all
    end

    dirName = File.dirname(__FILE__)
    csv_text = dirName + "/init_activity.csv"
    csv = CSV.read(csv_text, headers: true, col_sep: ";")
    csv.each do |row|
      ActivityType.create!(row.to_hash)
    end
  end

  task init_food: :environment do
    if FoodType.all.size != 0
      FoodType.all.delete_all
    end

    foodList = nil
    dirName = File.dirname(__FILE__)
    f = dirName + "/init_food.csv"
    foodList = CSV.read(f, headers: true, col_sep: ";")

    foodList.each do |m|
      FoodType.create!(m.to_hash)
    end

  end

  task init_genetics: :environment do
    if GeneticsType.all.size != 0
      GeneticsType.all.delete_all
    end

    dirName = File.dirname(__FILE__)
    csv_text = dirName + "/init_genetics.csv"
    csv = CSV.read(csv_text, headers: true, col_sep: ";")
    csv.each do |row|
      GeneticsType.create!(row.to_hash)
    end
  end

  task init_labresult: :environment do
    if LabresultType.all.size != 0
      LabresultType.all.delete_all
    end

    dirName = File.dirname(__FILE__)
    csv_text = dirName + "/init_labresult.csv"
    csv = CSV.read(csv_text, headers: true, col_sep: ";")
    csv.each do |row|
      LabresultType.create!(row.to_hash)
    end
  end

  task init_lifestyle: :environment do
    if LifestyleType.all.size != 0
      LifestyleType.all.delete_all
    end

    dirName = File.dirname(__FILE__)
    csv_text = dirName + "/init_lifestyle.csv"
    csv = CSV.read(csv_text, headers: true, col_sep: ";")
    csv.each do |row|
      LifestyleType.create!(row.to_hash)
    end
  end

  task init_illness: :environment do
    if IllnessType.all.size != 0
      IllnessType.all.delete_all
    end

    dirName = File.dirname(__FILE__)
    csv_text = dirName + "/init_illness.csv"
    csv = CSV.read(csv_text, headers: true, col_sep: ";")

    csv.each do |row|
      ft = IllnessType.new(:id => row['id'], :name =>  row['name'])
      ft.save!
    end
  end

  # task load_foods_csv: :environment do
  #   if FoodType.all.size != 0
  #     FoodType.all.each {|mt|
  #       mt.destroy!
  #     }
  #   end
  #
  #   foodlist = nil
  #   f = "#{ENV['HOME']}/Downloads/foods_exported_final.csv"
  #   foodlist = CSV.read(f, headers: true)
  #
  #   #print foodlist.first.as_json.pretty_inspect
  #   foodlist.each do |m|
  #     # ["id", "name", "category", "amount", "kcal", "prot", "carb", "fat"]
  #     ft = FoodType.new(:id => m['ID'], :name =>  m['Description'], :category => m['Category'], :amount => m['Quantity'], :kcal => m['Kcal'], :prot => m['Protein'], :carb => m['Carb'], :fat => m['Fat'])
  #     ft.save!
  #   end
  #
  # end
  #
  # task export_foods: :environment do
  #   k = ["id", "name", "category", "amount", "kcal", "prot", "carb", "fat"]
  #   CSV.open("#{ENV['HOME']}/Downloads/foods_exported.csv", 'w') do |csv|
  #     csv << k
  #     prev = nil
  #     FoodType.all.order("name").order("kcal").each do |ft|
  #       row = ft.as_json
  #       cmp = row.clone
  #       cmp.delete('id')
  #       if cmp!=prev
  #         prev=cmp
  #         csv << k.map{|it| row[it]}
  #       end
  #     end
  #   end
  # end
  #
  # task export_json: :environment do
  #   File.open("#{ENV['HOME']}/Downloads/foods_exported.json", 'w') do |f|
  #     arr = []
  #     prev = nil
  #     FoodType.all.order("name").order("kcal").each do |ft|
  #       curr = ft.as_json
  #       cmp = curr.clone
  #       cmp.delete('id')
  #       if cmp!=prev
  #         arr << curr
  #         prev = cmp
  #       end
  #     end
  #     JSON.dump(arr, f)
  #   end
  # end
  #
  # task export_activities: :environment do
  #   k = ["name", "kcal", "category"]
  #   CSV.open("#{ENV['HOME']}/Downloads/activity_exported.csv", 'w') do |csv|
  #     csv << k
  #     prev = nil
  #     ActivityType.all.order("id").each do |at|
  #       row = at.as_json
  #       cmp = row.clone
  #       cmp.delete('id')
  #       if cmp!=prev
  #         prev=cmp
  #         csv << k.map{|it| row[it]}
  #       end
  #     end
  #   end
  # end
end
