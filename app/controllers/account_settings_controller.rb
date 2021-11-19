class AccountSettingsController < ApplicationController
  require 'will_paginate/array'
  def settings
    @per_page = params[:per_page].present? ? params[:per_page] : 10

    if $community_account.company
      @company_name = $community_account.company_name
      @company_email = $community_account.company_email
    else
      @company_name = "#{t 'account_settings.dont_know_company_name'}"
      @company_email = "#{t 'account_settings.dont_know_company_email'}"
    end
    @created_by = $community_account.your_name
    @created_at = $community_account.created_at
    # if params[:sort].present?
    #   users = $community_account.users.where(archived: false).includes(:account).order(params[:sort].downcase)
    #   @users = users.paginate(page: params[:page], per_page: @per_page)
    #   @account_users = users 
    # else
      @account_users = $community_account.users.where(archived: false).includes(:account)
      @users = Account.where(id: $community_account.id) + @account_users
      @users = @users.paginate(page: params[:page], per_page: @per_page)
    # end
    @pending_users = @account_users.where(active: "pending").where(allowed_to_log_in: true).count
    @disabled_users = @account_users.where(allowed_to_log_in: false).count
    @active_users = @account_users.where(active: "active").where(allowed_to_log_in: true).count
    @settings = $community_account.account_setting || AccountSetting.new
    @admin_users = $community_account.users.where(role: "admin")
  end

  def overview_update
    authorize $community_account, :owner_access?, policy_class: AccountPolicy

    if params["company_image"]
      $community_account.company_image.attach(params["company_image"])
    end

    begin
      AccountSetting.find_or_initialize_by(account_id: $community_account.id).update(overview_params)
      redirect_to account_settings_path
    rescue
      flash[:danger] = "Something went wrong"
      redirect_to account_settings_path
    end
  end

  def settings_update
    authorize $community_account, :owner_access?, policy_class: AccountPolicy

    account = $community_account
    begin
      admin_ids = settings_params[:admin_user_ids] << account.id.to_s
      accounts = Account.where(id: admin_ids)
      accounts.update_all(company_email: settings_params[:company_email], company_name: settings_params[:company_name])
      redirect_to account_settings_path(tab: 'settings')
    rescue
      flash[:danger] = "Something went wrong"
      redirect_to account_settings_path(tab: 'settings')
    end
  end

  def delete_image_attachment
    authorize $community_account, :owner_access?, policy_class: AccountPolicy

    @image = ActiveStorage::Blob.find_signed(params[:id])
    @image.attachments.first.purge_later
    redirect_back(fallback_location: root_path)
  end

  def new_billing_email
    authorize $community_account, :owner_access?, policy_class: AccountPolicy

    new_email = params[:account_setting][:billing_emails]
    if $community_account.account_setting.billing_emails.present?
      $community_account.account_setting.billing_emails
      new_hash = $community_account.account_setting.billing_emails
      new_hash[(new_hash.count+1)] = new_email
      $community_account.account_setting.update(billing_emails: new_hash)
    else
      $community_account.account_setting.update(billing_emails: {0=> new_email})
    end
    redirect_back(fallback_location: root_path)
  end

  def update_billing_email
    authorize $community_account, :owner_access?, policy_class: AccountPolicy

    emails = params[:billing_email].values
    new_hash = {}
    emails.each_with_index do |x,i|
      new_hash[i] = x
    end
    $community_account.account_setting.update(billing_emails: new_hash)
  end

  private

  def overview_params
    params.require(:account_setting).permit(:industry_id,:no_of_employees)
  end

  def settings_params
    params.require(:account).permit(:company_name, :company_email, admin_user_ids: [])
  end
end
