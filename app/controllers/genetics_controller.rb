class GeneticsController < ApplicationController

  include GeneticsCommon

  # GET /users/:id/genetics
  # GET /users/:id/genetics
  def index
    user_id = params[:user_id]
    source = params[:source]

    order = params[:order]
    limit = params[:limit]

    @genetics = Genetic.where("user_id = #{user_id}")
    if source
      @genetics = @genetics.where("source = '#{source}'")
    end
    if order and order=="desc"
      @genetics = @genetics.order(created_at: :desc)
    else
      @genetics = @genetics.order(created_at: :asc)
    end
    if limit and limit.to_i>0
      @genetics = @genetics.limit(limit)
    end

    respond_to do |format|
      format.html
      format.json {render json: @genetics }
      format.js
    end
  end

end
