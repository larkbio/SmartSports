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
        res[:weight] = prf.weight
        res[:height] = prf.height
        res[:sex] = prf.sex
        res[:smoke] = prf.smoke
        res[:insulin] = prf.insulin
        res[:year_of_birth] = prf.year_of_birth
        res[:default_lang] = prf.default_lang
      else
        res[:profile] = false
      end

      if current_resource_owner.profile && current_resource_owner.profile.firstname && current_resource_owner.profile.lastname
        res[:full_name] = "#{current_resource_owner.profile.firstname} #{current_resource_owner.profile.lastname}"
        res[:first_name] = current_resource_owner.profile.firstname
        res[:last_name] = current_resource_owner.profile.lastname
      else
        res[:full_name] = current_resource_owner.name
        res[:first_name] = ""
        res[:last_name] = ""
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

      respond_to do |format|
        par = params.require(:profile).permit(:full_name, :height, :weight, :sex, :smoke, :insulin, :year_of_birth, :default_lang)
        if par[:full_name]
          user.name = par[:full_name]
          user.save!
          par.delete(:full_name)
        end

        if par['default_lang']
          I18n.locale = par['default_lang']
        end
        if prf.update(par)
          format.json { render json: { :ok => true, :msg => "save_success" } }
        else
          keys = prf.errors.full_messages().collect{|it| it.split()[-1]}
          # message = (I18n.translate(key))
          format.json { render json: { :ok => false, :msg => keys } }
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

