class SurveyPolicy < ApplicationPolicy

  def continue?
    record
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
