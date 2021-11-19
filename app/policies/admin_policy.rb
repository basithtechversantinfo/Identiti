class AdminPolicy < ApplicationPolicy

  def is_admin?
    account.admin?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
