module Api::V1
  class ProfileController < ApiController

    def show
      res = { :id => current_resource_owner.id,
              :member_since => current_resource_owner.created_at,
              :full_name => current_resource_owner.name,
              :email => current_resource_owner.email
      }
      if current_resource_owner.profile
        prf =current_resource_owner.profile
        res[:profile] = true
        res[:first_name] = prf.firstname
        res[:last_name] = prf.lastname
        res[:weight] = prf.weight
        res[:height] = prf.height
        res[:sex] = prf.sex
        res[:smoke] = prf.smoke
        res[:insulin] = prf.insulin
        res[:year_of_birth] = prf.year_of_birth
        res[:default_lang] = prf.default_lang
        res[:blood_glucose_min] = prf.blood_glucose_min
        res[:blood_glucose_max] = prf.blood_glucose_max
        res[:blood_glucose_unit] = prf.blood_glucose_unit
        res[:morning_start] = prf.morning_start
        res[:noon_start] = prf.noon_start
        res[:evening_start] = prf.evening_start
        res[:night_start] = prf.night_start
      else
        res[:profile] = false
      end

      if current_resource_owner.profile && current_resource_owner.profile.firstname && current_resource_owner.profile.lastname
        res[:full_name] = "#{current_resource_owner.profile.firstname} #{current_resource_owner.profile.lastname}"
      else
        res[:full_name] = current_resource_owner.name
      end

      if current_resource_owner.avatar
        res[:avatar_url] = current_resource_owner.avatar.url
      end
      res[:connections] = current_resource_owner.connections.collect{|it| it.name}
      render json: res
    end

    def update
      user = current_resource_owner
      prf = user.profile
      if  prf.nil?
        prf = Profile.create()
        user.profile = prf
        user.save!
      end

      pw_changed = false;

      respond_to do |format|
        par = params.require(:profile).permit(:firstname, :lastname, :height, :weight, :sex, :smoke, :insulin, :year_of_birth, :blood_glucose_min, :blood_glucose_max, :blood_glucose_unit, :morning_start, :noon_start, :evening_start, :night_start, :default_lang)
        parUser = params.require(:user).permit(:password, :password_confirmation)

        if (parUser[:password] && !parUser[:password].empty?) || (parUser[:password_confirmation] && !parUser[:password_confirmation].empty?)
          if user.update(parUser)
            pw_changed = true;
          else
            pw_keys = user.errors.full_messages().collect{|it| it.split()[-1]}
          end
        end

          if par['default_lang']
            I18n.locale = par['default_lang']
          end
          if prf.update(par)
            format.json { render json: { :ok => true, :msg => "update_profile_success", :pw_changed => pw_changed, :pw_msg =>pw_keys}}
          else
            keys = prf.errors.full_messages().collect{|it| it.split()[-1]}
            # message = (I18n.translate(key))
            format.json { render json: { :ok => false, :msg => keys, :pw_changed => pw_changed, :pw_msg =>pw_keys}}
          end
        end

    end

    def profile_image
      @user = User.find_by_id(current_resource_owner.id)
      @user.avatar = params[:avatar]
      if @user.save
        render json: { :ok => true, :msg => "save_success" }
      else
        render json: { :ok => false, :msg => "not_implemented" }
      end
    end

  end
end

