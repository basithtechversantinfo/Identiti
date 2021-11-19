class Admin::IndustriesController < AdminController
  before_action :set_industry, only: [:show, :edit, :update, :destroy]

  def index
    authorize nil, :is_admin?, policy_class: AdminPolicy

    @industries = Industry.all
  end

  def show
    authorize nil, :is_admin?, policy_class: AdminPolicy
  end

  def new
    authorize nil, :is_admin?, policy_class: AdminPolicy

    @industry = Industry.new
  end

  def edit
    authorize nil, :is_admin?, policy_class: AdminPolicy
  end

  def create
    authorize nil, :is_admin?, policy_class: AdminPolicy

    @industry = Industry.new(industry_params)
    @industry.slug_id = SecureRandom.hex(3)

    respond_to do |format|
      if @industry.save
        format.html { redirect_to admin_industry_path(@industry)
        # , notice: 'Industry was successfully created.'
        }
      else
        format.html { render :new }
      end
    end
  end

  def update
    authorize nil, :is_admin?, policy_class: AdminPolicy

    respond_to do |format|
      if @industry.update(industry_params)
        format.html { redirect_to admin_industry_path(@industry)
        # , notice: 'Industry was successfully updated.'
        }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    authorize nil, :is_admin?, policy_class: AdminPolicy

    respond_to do |format|
      if @industry.destroy
        format.html { redirect_to admin_industries_url
        # , notice: 'Industry was successfully destroyed.'
        }
      else
        format.html { redirect_to admin_industries_url, notice: @industry.errors.full_messages.to_sentence }
      end
    end
  end

  private
  def set_industry
    @industry = Industry.find(params[:id])
  end

  def industry_params
    params.require(:industry).permit(:title, :description, :slug_id)
  end
end
