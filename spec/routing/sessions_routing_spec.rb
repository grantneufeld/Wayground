require 'rails_helper'

describe SessionsController, type: :routing do
  describe 'routing' do
    it 'recognizes and generates #new' do
      expect(get: '/signin').to route_to(controller: 'sessions', action: 'new')
    end
    it 'recognizes and generates #create' do
      expect(post: '/signin').to route_to(controller: 'sessions', action: 'create')
    end

    it 'recognizes and generates #delete' do
      expect(get: '/signout').to route_to(controller: 'sessions', action: 'delete')
    end
    it 'recognizes and generates #destroy' do
      expect(delete: '/signout').to route_to(controller: 'sessions', action: 'destroy')
    end
  end
end
