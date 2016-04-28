require 'json'
require 'smarter_csv'

namespace :smartdiab do

  def updateVersion
    if InitVersion.all.size == 1
      actualVersion = InitVersion.last
      actualVersion.update(:version_number => actualVersion.version_number+1)
    else
      InitVersion.all.delete_all
      v = InitVersion.new(:id => 1, :version_number =>  1)
      v.save!
    end
  end

  task init_db: :environment do
    Rake::Task['smartdiab:init_activity'].execute
    Rake::Task['smartdiab:init_food'].execute
    Rake::Task['smartdiab:init_labresult'].execute
    Rake::Task['smartdiab:init_lifestyle'].execute
    updateVersion()
  end

  task init_medication: :environment do
    if MedicationType.all.size != 0
      MedicationType.all.delete_all
    end

    dirName = File.dirname(__FILE__)
    csv_text = dirName + "/init_medication.csv"
    SmarterCSV.process(csv_text, headers: true, col_sep: ",", chunk_size: 2000) do |chunk|
      MedicationType.create!(chunk)
    end
    MedicationType.all.update_all('name = id')
    updateVersion()
    puts 'MedicationTypes loaded'
  end

  task init_faq: :environment do
    if Faq.all.size != 0
      Faq.all.delete_all
    end

    dirName = File.dirname(__FILE__)
    csv_text = dirName + "/smartdiab_faq.csv"
    ret = SmarterCSV.process(csv_text, headers: true, col_sep: ",", chunk_size: 100) do |chunk|
      Faq.create!(chunk)
    end
    puts 'Faqs loaded'
  end

  task init_activity: :environment do
    if ActivityType.all.size != 0
      ActivityType.all.delete_all
    end

    dirName = File.dirname(__FILE__)
    csv_text = dirName + "/init_activity.csv"
    ret = SmarterCSV.process(csv_text, headers: true, col_sep: ";", chunk_size: 2000) do |chunk|
      ActivityType.create!(chunk)
    end
    puts 'Activities loaded'
  end

  task init_food: :environment do
    if FoodType.all.size != 0
      FoodType.all.delete_all
    end

    dirName = File.dirname(__FILE__)
    f = dirName + "/init_food.csv"
    ret = SmarterCSV.process(f, headers: true, col_sep: ";", chunk_size: 2000) do |chunk|
      FoodType.create!(chunk)
    end
    puts 'FoodTypes loaded'
  end

  task init_labresult: :environment do
    if LabresultType.all.size != 0
      LabresultType.all.delete_all
    end

    dirName = File.dirname(__FILE__)
    csv_text = dirName + "/init_labresult.csv"
    ret = SmarterCSV.process(csv_text, headers: true, col_sep: ";", chunk_size: 2000) do |chunk|
      LabresultType.create!(chunk)
    end
    puts 'LabresultTypes loaded'
  end

  task init_lifestyle: :environment do
    if LifestyleType.all.size != 0
      LifestyleType.all.delete_all
    end

    dirName = File.dirname(__FILE__)
    csv_text = dirName + "/init_lifestyle.csv"
    ret = SmarterCSV.process(csv_text, headers: true, col_sep: ";", chunk_size: 2000) do |chunk|
      LifestyleType.create!(chunk)
    end
    puts 'LifestyleTypes loaded'
  end

end
