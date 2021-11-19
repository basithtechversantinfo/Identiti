class UsersController < ApplicationController
  include OktaAccount
  skip_before_action :authenticate_account!, :only => [:accept_invitation]
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :check_user_add_policy, only: [:create]

  def index
    @users = $community_account.users.where(archived: false)
  end

  def show
  end

  def new
    authorize $community_account, :admin_access?, policy_class: AccountPolicy
    @current_active_user_limit_count = current_account.trial? ? (current_account.user_limit - (current_account.users.where(archived: false, trial: false).count)) : (current_account.user_limit - (current_account.users.where(archived: false, trial: false).count + 1))
    @existing_emails =  Account.where(account_id: $community_account.id, archived: false).pluck(:email)
    @user = User.new
    if request.xhr?
      record = render_to_string partial: "account_settings/new_user_form"
      render json: {message: 'success', data: record}, status: 200
    end
  end

  def edit
    authorize $community_account, :admin_access?, policy_class: AccountPolicy

    @user = User.find(params[:id])
    if request.xhr?
      user_record = render_to_string partial: "account_settings/user_details_popup"
      render json: {message: 'success', data: user_record}, status: 200
    end
  end

  def create
    authorize $community_account, :admin_access?, policy_class: AccountPolicy
    if $community_account.trial
      if $community_account.user_limit <= ($community_account.users.where(archived: false, trial: false).count)
        flash[:warning] = 'You have reached maximum users limit'
        redirect_to account_settings_path(tab: 'user')
        return
      end
    elsif $community_account.user_limit <= ($community_account.users.where(archived: false, trial: false).count + 1)
      flash[:warning] = 'You have reached maximum users limit'
      redirect_to account_settings_path(tab: 'user')
      return
    end
    
    if params[:user][:email].present?
      @account_user = current_account.users.find_by_email(params[:user][:email])
      unless current_account.okta?
        generated_password = Devise.friendly_token.first(8)

        # # @user = User.new(user_params)
        @user = User.where(email: params[:user][:email], account_type: 'user').first_or_create(user_params)
        if @account_user.blank?
          @user.account = $community_account
          @user.account_type = 'user'
          @user.company_name = SecureRandom.hex
          @user.company_email = SecureRandom.hex + '@ep.com'
          @user.invitation_code = SecureRandom.hex
          @user.password = generated_password
          @user.archived = false
          @user.active = 0
          @user.require_new_password = true
          @user.allowed_to_log_in = true
          @user.login_options = 0
        else
          @account_user.password = generated_password
          @account_user.role = user_params[:role]
          @account_user.your_name = user_params[:your_name]
          @account_user.active = 0
          @account_user.require_new_password = true
          @account_user.archived = false
          @account_user.deleted_at = nil
          @account_user.recreated_at = Time.now
          @account_user.allowed_to_log_in = @account_user.allowed_to_log_in
          @account_user.save
        end
      else
        @user = User.where(email: params[:user][:email], account_type: 'user').first_or_create(user_params)
        if @account_user.blank?
          @user.account = $community_account
          @user.your_name = params[:user][:first_name]
          @user.first_name = params[:user][:first_name]
          @user.last_name = params[:user][:last_name]
          @user.account_type = 'user'
          @user.company_name = SecureRandom.hex
          @user.company_email = SecureRandom.hex + '@ep.com'
          @user.invitation_code = SecureRandom.hex
          # @user.password = generated_password
          @user.archived = false
          @user.active = 1
          @user.require_new_password = false
          @user.allowed_to_log_in = true
          @user.login_options = 1
          request_body = {
            "profile": {
              "firstName": params[:user][:first_name],
              "lastName": params[:user][:last_name],
              "email": params[:user][:email],
              "login": params[:user][:email]
            }
          }
          create_okta_account request_body
        else
          @account_user.role = user_params[:role]
          @account_user.active = 0
          @account_user.archived = false
          @account_user.deleted_at = nil
          @account_user.recreated_at = Time.now
          @account_user.allowed_to_log_in = @account_user.allowed_to_log_in
          @user.require_new_password = false
          @account_user.login_options = 1
          @account_user.save
        end
      end

      respond_to do |format|
        is_okta = current_account.okta? ? false : true
        if @user.save(validate: is_okta)
          format.html { 
            flash[:success] = "User created successfully"
            redirect_to account_settings_path(tab: "user")
            # , notice: 'User was successfully created.'
          }

          if params[:user][:image].present?
            image = MiniMagick::Image.open(File.open(params[:user][:image].tempfile).path)
            image.path
            image.format "png"
            image.write "output.png"

            path = image.path

            File.open(path) do |io|
              @user.image.attach(io: io, filename: "output.png", content_type: "image/png")
            end
          end

          unless current_account.okta?
            AccountMailer.invitation_to_collaborate(params[:locale], $community_account, @user, @user.invitation_code, generated_password).deliver
          else
            AccountMailer.invitation_to_collaborate(params[:locale], $community_account, @user, @user.invitation_code, nil).deliver
          end
        else
          format.html { redirect_to account_settings_path, tab: 'user', flash: { error: @user.errors.full_messages.to_sentence } }
        end
      end


    elsif params[:user][:multi_emails].present?
      params[:user][:multi_emails].split(",").each do |user|
        generated_password = Devise.friendly_token.first(8)
        @account_user = current_account.users.find_by_email(user)
        if @account_user.blank?  
          name = user.split("@").first
          invitation_code = SecureRandom.hex
          @user = User.create(account_id: $community_account.id, email: user.strip, invitation_code: invitation_code, your_name: name, role: "analyzer", company_name: SecureRandom.hex, company_email: SecureRandom.hex + '@ep.com', password: generated_password, account_type: 'user', require_new_password: true)
          AccountMailer.invitation_to_collaborate(params[:locale], $community_account, @user, @user.invitation_code, generated_password).deliver
        else
          @account_user.password = generated_password
          @account_user.active = 0
          @account_user.require_new_password = true
          @account_user.archived = false
          @account_user.deleted_at = nil
          @account_user.recreated_at = Time.now
          @account_user.allowed_to_log_in = @account_user.allowed_to_log_in
          @account_user.save
          AccountMailer.invitation_to_collaborate(params[:locale], $community_account, @account_user, @account_user.invitation_code, generated_password).deliver
        end
      end

      respond_to do |format|
        flash[:success] = "Users created successfully"
        format.html { redirect_to account_settings_path(tab: 'user')
          # , notice: 'Users are successfully created.'
        }
      end
    end
  end

  def update
    authorize $community_account, :admin_access?, policy_class: AccountPolicy

    if params[:user][:email] == $community_account.email
      flash[:error] = 'You are not authorized to perform this action'
      redirect_to account_settings_path
    elsif User.where(email: params[:user][:email], account_id: $community_account.id, archived: false).count > 1
      flash[:warning] = 'You have already sent the invitation to collaborate'
      redirect_to account_settings_path
    end

    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user
          # , notice: 'User was successfully updated.'
        }
          AccountMailer.invitation_to_collaborate_update(params[:locale], $community_account, @user).deliver
      else
        format.html { render :edit }
      end
    end
  end

  def update_user
    authorize $community_account, :admin_access?, policy_class: AccountPolicy

    @user = User.find(params[:id])
    temp_role_var = @user.role

    respond_to do |format|
      if @user.update(account_settings_user_params)
        format.html { redirect_to account_settings_path
          # , notice: 'Users are successfully updated.'
        }

        if params[:user][:image].present?
          image = MiniMagick::Image.open(File.open(params[:user][:image].tempfile).path)
          image.path
          image.format "png"
          image.write "output.png"

          path = image.path

          File.open(path) do |io|
            @user.image.attach(io: io, filename: "output.png", content_type: "image/png")
          end
        end

        if temp_role_var != @user.role
          AccountMailer.invitation_to_collaborate_update(params[:locale], $community_account, @user).deliver
        end

      else
        format.html { redirect_to account_settings_path, flash: { notice: 'Something went wrong' } }
      end
    end
  end

  def destroy
    authorize $community_account, :admin_access?, policy_class: AccountPolicy

    @user.archived = true
    @user.require_new_password = true
    @user.deleted_at = Time.now
    @user.save(validate: false)
    
    flash[:danger] = 'User deleted successfully'
    redirect_to account_settings_path(tab: "user")
  end

  def accept_invitation
    user = User.find_by_invitation_code(params[:id])
    if user
      user.update(active: 1)
      account = Account.find_by_email(user.email)

      if !account
        flash[:warning] = 'You need to signup to accept invitation'
        redirect_to new_account_registration_path
      elsif account and !account_signed_in?
        flash[:success] = 'Invitation Accepted Successfully, Please Login to continue collaborating.'
        redirect_to new_account_session_path
      else
        flash[:success] = 'Invitation Accepted Successfully'
        redirect_to root_path
      end

    else
      flash[:warning] = 'This invitation Link is expired'
      redirect_to new_account_session_path
    end
  end

  def check_user_add_policy
    if params[:user][:email] == $community_account.email
      flash[:notice] = 'You are not authorized to perform this action'
      redirect_to account_settings_path
    elsif User.where(email: params[:user][:email], account_id: $community_account.id, archived: false).present?
      flash[:notice] = 'You have already sent the invitation to collaborate'
      redirect_to account_settings_path
    elsif User.where(email: params[:user][:email]).any?
      if current_account.okta?
        if User.where(email: params[:user][:email]).first.deleted_at.blank?
          flash[:notice] = 'Email is already taken'
          redirect_to account_settings_path
        end
      end
    end
  end

  def resend_invitation
    authorize $community_account, :admin_access?, policy_class: AccountPolicy

    @user = User.find(params[:id])
    invitation_code = SecureRandom.hex
    generated_password = Devise.friendly_token.first(8)

    if @user.update(invitation_code: invitation_code, password: generated_password)
      Account.find(params[:id]).update(invite_sent_at: Time.now)
      AccountMailer.invitation_to_collaborate(params[:locale], $community_account, @user, @user.invitation_code, generated_password).deliver
      redirect_back(fallback_location: root_path, notice: 'Invitation link sent to user')
    else
      redirect_back(fallback_location: root_path, notice: 'Something went wrong')
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:your_name, :email, :role, :invitation_code, :active, :account_type,
                                 :allowed_to_log_in, :company_name, :company_email, :archived, :require_new_password)
  end

  def account_settings_user_params
    params.require(:user).permit(:role, :your_name, :email, :image, :account_type, :allowed_to_log_in, :company_name, :company_email, :archived, :first_name, :last_name)
  end
end
