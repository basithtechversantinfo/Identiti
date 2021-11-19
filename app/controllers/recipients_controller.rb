class RecipientsController < ApplicationController
  before_action :set_recipient, only: [:show, :edit, :update, :destroy]

  def index
    authorize nil, :is_account?, policy_class: AccountPolicy

    @recipients = Recipient.all
  end

  def show
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize @recipient.account, :can_view?, policy_class: AccountPolicy
  end

  def new
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    @recipient = Recipient.new
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

    if params[:recipient][:single_email].present?

      recipient = Recipient.find_or_create_by(account_id: $community_account.id, email: params[:recipient][:single_email], created_by_id: current_account.id)
      ListsRecipient.find_or_create_by(recipient_id: recipient.id, list_id: params[:list_id])

      respond_to do |format|
          format.html { redirect_to list_path(params[:list_id])
          # , notice: 'Recipient was successfully created.'
          }
      end

    elsif params[:recipient][:multi_emails].present?

      # params[:recipient][:multi_emails].split(",").each do |recipient|
      #   recipient = Recipient.find_or_create_by(account_id: $community_account.id, email: recipient.strip, created_by_id: current_account.id)
      #   ListsRecipient.find_or_create_by(recipient_id: recipient.id, list_id: params[:list_id])
      # end
      CreateMultipleRecipientsJob.perform_later(params[:recipient][:multi_emails], params[:list_id], current_account.id, $community_account)

      respond_to do |format|
          format.html { redirect_to lists_path
          # , notice: 'Recipient was successfully created.'
          }
      end
    end
  end

  def update
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    respond_to do |format|
      if @recipient.update(recipient_params)
        format.html { redirect_to list_path(params[:list_id])
        # , notice: 'Recipient was successfully updated.'
        }
        format.json { render :show, status: :ok, location: @recipient }
      else
        format.html { redirect_to list_path(params[:list_id]) }
        format.json { render json: @recipient.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    ListsRecipient.where(recipient_id: @recipient.id, list_id: params[:list_id]).destroy_all

    respond_to do |format|
      format.html { redirect_to list_path(params[:list_id])
      # , notice: 'Recipient was successfully deleted.'
      }
      format.json { head :no_content }
    end
  end

  private
  def set_recipient
    @recipient = Recipient.find(params[:id])
  end

  def recipient_params
    params.require(:recipient).permit(:account_id, :email, :created_by_id)
  end
end
