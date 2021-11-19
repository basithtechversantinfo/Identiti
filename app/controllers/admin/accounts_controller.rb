class Admin::AccountsController < AdminController
  include OktaAccount
  def index
    authorize nil, :is_admin?, policy_class: AdminPolicy
    if params[:trial].present?
      @accounts = Account.where(admin: false, account_type: 'client', trial: true).order(created_at: :asc)
    else
      @accounts = Account.where(admin: false, account_type: 'client', trial: false)
    end
  end

  def new
    authorize nil, :is_admin?, policy_class: AdminPolicy
    
    @account = Account.new
  end

  def show
    authorize nil, :is_admin?, policy_class: AdminPolicy
    
    @account = Account.find(params[:id])
    @users = @account.users.where(archived: false)
    @users_count = @users.count + 1
    @deleted_users = @account.users.where(archived: true)
    @users = @users.sort_by { |row| [row.archived ? 1: 0] }
  end

  def create
    authorize nil, :is_admin?, policy_class: AdminPolicy
    account_email = Account.where(email: params[:account][:email], account_type: 'client').first rescue nil
    unless account_email.nil?
      flash[:danger] = "Email already taken"
      redirect_to admin_accounts_path
      return
    end

    generated_password = Devise.friendly_token.first(8)
    @account = Account.new(account_params)
    @account.your_name = params[:account][:first_name]
    @account.password = generated_password unless @account.okta?
    if @account.okta?
      request_body = {
        "profile": {
          "firstName": @account.first_name,
          "lastName": @account.last_name,
          "email": @account.email,
          "login": @account.email
        }
      }
      create_okta_account request_body
    end
    account_validate = @account.okta? ? false : true
    if @account.save(validate: account_validate)
      AccountMailer.new_client_account_created(@account, generated_password).deliver unless @account.okta?
      redirect_to admin_accounts_path
    else
      render :new
    end
  end

  def update
    authorize nil, :is_admin?, policy_class: AdminPolicy
    
    @account = Account.find(params[:id])
    @account.user_limit = params[:account][:user_limit]
    @account.survey_limit = params[:account][:survey_limit] if params[:account][:survey_limit].present?
    @account.block_limit = params[:account][:block_limit] if params[:account][:block_limit].present?
    @account.question_limit = params[:account][:question_limit] if params[:account][:question_limit].present?
    @account.login_options = params[:account][:login_options].to_i
    if @account.okta?
      request_body = {
        "profile": {
          "firstName": @account.first_name,
          "lastName": @account.last_name,
          "email": @account.email,
          "login": @account.email
        }
      }
      create_okta_account request_body
    end
    if @account.save
      @account.users.update_all(user_limit: params[:account][:user_limit], survey_limit: @account.survey_limit, block_limit: @account.block_limit, question_limit: @account.question_limit)
      if params[:trial].present?
        redirect_to admin_accounts_path(trial: true)
      else
        redirect_to admin_accounts_path
      end
    else
      redirect_to admin_accounts_path
    end
        
  end

  def activate_or_disable
    authorize nil, :is_admin?, policy_class: AdminPolicy
    account = Account.find(params[:id])
    account.toggle(:allowed_to_log_in).save

    if account.new_account?
      account.toggle(:new_account).save
      AccountMailer.new_client_account_activate_alert(account).deliver
    end

    if account.okta?
      request_body = {
        "profile": {
          "firstName": account.your_name,
          "lastName": account.your_name,
          "email": account.email,
          "login": account.email
        }
      }
      create_okta_account request_body
    end
    
    respond_to do |format|
      format.html { redirect_to admin_accounts_url }
    end
  end

  # def okta_enable
  #   authorize nil, :is_admin?, policy_class: AdminPolicy
  #   account = Account.find(params[:id])
  #   account.login_options = "okta"
  #   account.save

  #   respond_to do |format|
  #     format.html { redirect_to admin_accounts_url }
  #   end
  # end

  # def okta_disable
  #   authorize nil, :is_admin?, policy_class: AdminPolicy
  #   account = Account.find(params[:id])
  #   account.login_options = "normal"
  #   account.save

  #   respond_to do |format|
  #     format.html { redirect_to admin_accounts_url }
  #   end
  # end

  def reinstate 
    authorize nil, :is_admin?, policy_class: AdminPolicy
    account = Account.find(params[:id])
    account.archived = false
    account.deleted_at = ''
    account.save

    respond_to do |format|
      format.html { redirect_to admin_account_path(params[:client_id]) }
    end
  end

  def destroy
    authorize nil, :is_admin?, policy_class: AdminPolicy
    account = Account.find(params[:id])
    account.archived = true
    account.require_new_password = true
    account.deleted_at = Time.now
    account.save(validate: false)
     
    respond_to do |format|
      format.html { redirect_to admin_account_path(params[:client_id]) }
    end
  end

  def add_trial
    authorize nil, :is_admin?, policy_class: AdminPolicy
    
    @account = Account.new
  end

  def add_trial_submit
    authorize nil, :is_admin?, policy_class: AdminPolicy
    # account_email = Account.where(email: params[:account][:email], account_type: 'client').first rescue nil
    # unless account_email.nil?
    #   flash[:danger] = "Email already taken"
    #   redirect_to admin_accounts_path
    #   return
    # end

    generated_password = Devise.friendly_token.first(8)
    @account = Account.new
    trials_name = get_trial_name
    @account.email = trials_name.to_s + "@elasticpersonas.ai"
    @account.company_name = trials_name
    @account.company_email = trials_name.to_s + "@elasticpersonas.ai"
    @account.sender_email = trials_name.to_s + "@elasticpersonas.ai"
    @account.your_name = trials_name
    @account.password = generated_password
    @account.trial_password = generated_password
    @account.account_type = "client"
    @account.trial = 1
    # @account.password = generated_password unless @account.okta?
    # if @account.okta?
    #   request_body = {
    #     "profile": {
    #       "firstName": @account.first_name,
    #       "lastName": @account.last_name,
    #       "email": @account.email,
    #       "login": @account.email
    #     }
    #   }
    #   create_okta_account request_body
    # end
    account_validate = @account.okta? ? false : true
    if @account.save!(validate: account_validate)
      # AccountMailer.new_client_account_created(@account, generated_password).deliver unless @account.okta?
      redirect_to admin_accounts_path(trial: true)
    else
      render :new
    end
  end

  private

  def account_params
    params.require(:account).permit(:your_name, :email, :password, :password_confirmation, :company, :company_name, :company_email, :sender_email, :login_options, :first_name, :last_name, :user_limit, :survey_limit, :question_limit, :block_limit)  
  end

  def update_params
    params.require(:account).permit(:user_limit, :login_options)
  end

  def get_trial_name
    @trial_account = Account.where(trial: true).last rescue nil
    if @trial_account.nil?
      trial_name = "trial_0101" 
    else
      trial_name = @trial_account.your_name
      trial_name = "trial_" + (trial_name.split("_").last.to_i + 1).to_s
    end
    trial_name
  end
end