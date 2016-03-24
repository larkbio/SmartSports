module DataHelper

  def dup_data( from_uid = 1 , to_uid = 15)
    u = User.find_by_id(from_uid)
    u.diets.each do |it|
      if it.diet_type=='Smoke' || it.food_type
        d = it.dup
        d.user_id = to_uid
        d.save!
      end
    end

    # dup_summaries
    arr = Summary.where(user_id: from_uid)
    arr.each do |s|
      snew = s.dup
      snew.user_id = to_uid
      snew.save
    end

    # ========================
    u.measurements.each do |it|
      d = it.dup
      d.user_id = to_uid
      d.save!
    end

    u.activities.each do |it|
      if it.activity_type
        d = it.dup
        d.user_id = to_uid
        d.save!
      end
    end
  end


  # ========================


  def export_food_types
    arr = FoodType.all
    File.open("/data/tmp1/food_types.json", 'w') do |f|
      JSON.dump(arr.as_json, f)
    end
  end

  def export_activity_types
    arr = ActivityType.all
    File.open("/data/tmp1/activity_types.json", 'w') do |f|
      JSON.dump(arr.as_json, f)
    end
  end
  def export_medication_types
    arr = MedicationType.all
    File.open("/data/tmp1/medication_types.json", 'w') do |f|
      JSON.dump(arr.as_json, f)
    end
  end
  def export_illness_types
    arr = LifestyleType.all
    i = 1
    for a in arr do
      a.id = i
      i = i+1
    end
    File.open("/data/tmp1/lifestyle_types.json", 'w') do |f|
      JSON.dump(arr.as_json, f)
    end
  end


  def import_food_types
    File.open('/home/deploy/food_types.json', 'r') do |f|
      arr = JSON.parse(f.read())
      arr.each do |d|
        at = FoodType.create(d)
      end
    end
  end
  def import_activity_types
    File.open('/home/deploy/activity_types.json', 'r') do |f|
      arr = JSON.parse(f.read())
      arr.each do |d|
        at = ActivityType.create(d)
      end
    end
  end

  def import_medication_types
    File.open('/home/deploy/medication_types.json', 'r') do |f|
      arr = JSON.parse(f.read())
      arr.each do |d|
        at = MedicationType.create(d)
      end
    end
  end

  def import_illness_types
    File.open('/home/deploy/lifestyle_types.json', 'r') do |f|
      arr = JSON.parse(f.read())
      arr.each do |d|
        at = LifestyleType.create(d)
      end
    end
  end


  def export_conn_data
    from_uid = 1
    u = User.find_by_id(from_uid)
    arr = u.tracker_data.all
    File.open("/data/tmp/tracker_data_uid_#{from_uid}.json", 'w') do |f|
      JSON.dump(arr.as_json, f)
    end
  end

  def export_tracker_data
    from_uid = 1
    u = User.find_by_id(from_uid)
    arr = u.tracker_data.all
    File.open("/data/tmp/tracker_data_uid_#{from_uid}.json", 'w') do |f|
      JSON.dump(arr.as_json, f)
    end
  end

  def export_summary_data
    from_uid = 1
    u = User.find_by_id(from_uid)
    arr = u.summaries.all
    File.open("/data/tmp/summaries_uid_#{from_uid}.json", 'w') do |f|
      JSON.dump(arr.as_json, f)
    end
  end
  # =================

  def export_diets
    from_uid = 1
    to_uid =
    u = User.find_by_id(from_uid)
    arr = u.diets.select { |it| it.type=='Smoke' || it.food_type }
    File.open("/data/tmp/diets_uid_1.json", 'w') do |f|
      JSON.dump(arr.as_json, f)
    end
  end

  # =================

  def export_exercise(from_uid, to_uid)
    u = User.find_by_id(from_uid)
    arr = u.activities.select { |it| it.activity_type }
    for a in arr do
      a.user_id = to_uid
    end
    File.open("/data/tmp/activities_uid_#{from_uid}.json", 'w') do |f|
      JSON.dump(arr.as_json, f)
    end
  end

  # =================

  def export_health(from_uid, to_uid)
    u = User.find_by_id(from_uid)
    arr = u.measurements.all
    for a in arr do
      a.user_id = to_uid
    end
    File.open("/data/tmp/measurements_uid_#{from_uid}_#{to_uid}.json", 'w') do |f|
      JSON.dump(arr.as_json, f)
    end
  end

  def export_medications
    from_uid = 1
    u = User.find_by_id(from_uid)
    arr = u.medications.select {|it| it.medication_type}
    File.open("/data/tmp/medications_uid_1.json", 'w') do |f|
      JSON.dump(arr.as_json, f)
    end
  end

  def export_wellbeing
    from_uid = 1
    u = User.find_by_id(from_uid)
    arr = u.lifestyles.select { |it| it.group == 'sleep' }
    File.open("/data/tmp/lifestyles_uid_1.json", 'w') do |f|
      JSON.dump(arr.as_json, f)
    end
  end

  def import_data(fname, model, uid)
    u = User.find_by_id(uid)
    arr = nil
    File.open(fname, 'r') do |f|
      arr = JSON.parse(f.read())
      arr.each do |d|
        d.delete('id')
        u.try(model.to_sym).create(d)
      end
    end
  end
end
