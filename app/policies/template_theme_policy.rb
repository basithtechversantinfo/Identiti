class TemplateThemePolicy < ApplicationPolicy
	def can_view?
	    if account.id == record.account_id
	      true
	    elsif record.default_template
	  		true
	    elsif account.account_id == record.account_id and
	        account.account_type == "user" and
	        account.active == 1 and
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
