module ApplicationHelper
	def show_errors(item, heading=nil)
		render :partial => 'layouts/errors', :locals => {:item => item, :heading => heading}
	end
end
