module Api::V1
  class FaqsController < ApiController
    before_action :check_admin, except: :index

    def index
      @faqs = Faq.all
      lang = params[:lang]
      if lang
        @faqs = @faqs.where(lang: lang)
      end
      @faqs = @faqs.order(:sortcode)
      render :template => '/faqs/index.json'
    end

    def update
      id = params[:id]
      faq = Faq.find_by_id(id)
      if faq.nil?
        send_error_json(nil, "Not found", 404)
      else
        if faq.update(faq_params)
          send_success_json(id)
        else
          send_error_json(id, "Erorr", 400)
        end
      end

    end

    def destroy
      id = params[:id]
      faq = Faq.find_by_id(id)
      if faq.nil?
        send_error_json(nil, "Not found", 404)
      else
        if faq.destroy
          send_success_json(id)
        else
          send_error_json(id, "Erorr", 500)
        end
      end
    end

    def create
      faq = Faq.new(faq_params)
      if faq.save
        send_success_json(faq.id)
      else
        send_error_json(@measurement.id, msg, 400)
      end
    end

    private

    def faq_params
      params.require(:faq).permit(:sortcode, :title, :detail, :lang)
    end
  end
end

