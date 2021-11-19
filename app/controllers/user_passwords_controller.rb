class UserPasswordsController < ApplicationController
  layout "survey_build"

  def index
    authorize nil, :is_account?, policy_class: AccountPolicy

    @account = current_account
  end

  def create
    authorize nil, :is_account?, policy_class: AccountPolicy

    if current_account.update(account_params)
      current_account.update(require_new_password: false)
      sign_in(current_account, :bypass => true)

      flash[:success] = "Password updated successfully."
      redirect_to root_path
    else
      flash.now[:error_medium] = "There was a problem, please try again."
      render :index
    end
  end

  private
  def account_params
    params.require(:account).permit(:password, :password_confirmation)
  end
end
