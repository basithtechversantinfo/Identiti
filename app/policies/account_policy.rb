class AccountPolicy < ApplicationPolicy

  def is_account?
    !account.admin?
  end

  def owner_access?
    if account.id == record.id and account.account_type == "client"
      true
    else
      false
    end
  end

  def admin_access?
    if account.id == record.id and account.account_type == "client"
      true
    elsif account.account_id == record.id and
        account.account_type == "user" and
        account.active == 1 and
        account.role == 0 and
        User.roles.first(3).flatten.include?(account.role)
      true
    else
      false
    end
  end

  def admin_and_creator_access?
    if account.id == record.id and account.account_type == "client"
      true
    elsif account.account_id == record.id and
        account.account_type == "user" and
        account.active == 1 and
        (account.role == 0 || account.role == 1 || account.role == 2) and
        User.roles.first(3).flatten.include?(account.role)
      true
    else
      false
    end
  end

  def creator_access?
    if account.id == record.id and account.account_type == "client"
      true
    elsif account.account_id == record.id and
        account.account_type == "user" and
        account.active == 1 and
        account.role == 1 and
        User.roles.first(3).flatten.include?(account.role)
      true
    else
      false
    end
  end

  def analyzer_access?
    if account.id == record.id and account.account_type == "client"
      true
    elsif account.account_id == record.id and
        account.account_type == "user" and
        account.active == 1 and
        account.role == 2 and
        User.roles.first(3).flatten.include?(account.role)
      true
    else
      false
    end
  end

  def can_view?
    if account.id == record.id and account.account_type == "client"
      true
    elsif account.account_id == record.id and
        account.account_type == "user" and
        account.active == 1 and
        User.roles.first(3).flatten.include?(account.role)
      true
    else
      false
    end
  end

  def can_add_edit_delete_global?
    if account.id == record.id and account.account_type == "client"
      true
    elsif account.account_id == record.id and
        account.account_type == "user" and
        account.active == 1 and
        User.roles.first(2).flatten.include?(account.role)
      true
    else
      false
    end
  end

  def can_access_preview?
    if account.id == record.id and account.account_type == "client"
      true
    elsif account.account_id == record.id and
        account.account_type == "user" and
        account.active == 1 and
        (account.role == 0 || account.role == 1) and
        User.roles.first(3).flatten.include?(account.role)
      true
    else
      false
    end
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
