class UserPresenter
  include ActionView::Helpers::UrlHelper
  def initialize(user)
    @user = user
  end

  def user_pending_section
    if @user.active == 'pending'
      "#{I18n.t('account_settings.sent')}  #{@user.invite_sent_at.present? ? @user.invite_sent_at.strftime("%b %d, %Y") : @user.created_at.strftime("%b %d, %Y")}"
    else
      "#{I18n.t('account_settings.joined')} #{@user.updated_at.strftime("%b %d, %Y")}"
    end
  end
end