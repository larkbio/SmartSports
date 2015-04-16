require 'json'

namespace :smartdiab do
  "Load default medications"
  task init_medication: :environment do
    if MedicationType.all.size != 0
      MedicationType.all.each {|mt|
        mt.destroy!
      }
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

  task init_foods: :environment do
    if FoodType.all.size != 0
      FoodType.all.each {|mt|
        mt.destroy!
      }
    end

    File.open("#{ENV['HOME']}/Downloads/foods_filtered.json") do |f|
      foodlist = JSON.load(f)

      #print foodlist.first.as_json.pretty_inspect
      foodlist.each do |m|
        ft = FoodType.new(:name =>  m[1], :category => m[7], :amount => m[2], :kcal => m[3], :prot => m[5], :carb => m[4], :fat => m[6])
        ft.save!
      end
    end
  end

end
