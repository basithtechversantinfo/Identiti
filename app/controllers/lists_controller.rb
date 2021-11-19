class ListsController < ApplicationController
  before_action :set_list, only: [:show, :edit, :update, :destroy]

  def index
    authorize nil, :is_account?, policy_class: AccountPolicy

    @per_page = params[:per_page].present? ? params[:per_page] : 10

    @lists = List.where(account_id: $community_account.id, archived: false).paginate(page: params[:page], per_page: @per_page)
  end

  def show
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize @list.account, :can_view?, policy_class: AccountPolicy

    @per_page = params[:per_page].present? ? params[:per_page] : 10

    @list_recipients = @list.recipients.paginate(page: params[:page], per_page: @per_page)
  end

  def new
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    @list = List.new

    respond_to do |format|
      format.js
    end
  end

  def edit
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    respond_to do |format|
      format.js
    end
  end

  def create
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    @list = List.new(list_params)
    @list.account_id = $community_account.id
    @list.created_by_id = current_account.id

    respond_to do |format|
      if @list.save
        format.html { redirect_to @list
        # , notice: 'List was successfully created.'
        }
        format.json { render :show, status: :created, location: @list }
      else
        format.html { render :new }
        format.json { render json: @list.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    respond_to do |format|
      if @list.update(list_params)
        format.html { redirect_to @list
        # , notice: 'List was successfully updated.'
        }
        format.json { render :show, status: :ok, location: @list }
      else
        format.html { render :edit }
        format.json { render json: @list.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    @list.toggle(:archived).save

    respond_to do |format|
      format.html { redirect_to lists_url
      # , notice: 'List was successfully deleted.'
      }
      format.json { head :no_content }
    end
  end

  private
    def set_list
      @list = List.not_deleted.find(params[:id])
    end

    def list_params
      params.require(:list).permit(:title, :account_id, :created_by_id)
    end
end
