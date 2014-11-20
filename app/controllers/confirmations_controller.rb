class ConfirmationsController < Devise::ConfirmationsController

def show
	super do |resource|
		sign_in(resource)
	end
end
	
end