# from http://railscasts.com/episodes/77-destroy-without-javascript-revised

# Extend the Routing mapper to include a delete method on resources routes.
module DeleteResourceRoute
  def resources(*args)
    super(*args) do
      yield if block_given?
      member do
        get :delete
        delete :delete, action: :destroy
      end
    end
  end
end

ActionDispatch::Routing::Mapper.public_send(:include, DeleteResourceRoute)
