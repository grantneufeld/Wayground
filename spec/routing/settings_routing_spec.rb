require 'rails_helper'

describe SettingsController, type: :routing do
  describe 'routing' do
    it 'routes to #initialize_defaults' do
      expect(get: '/settings/initialize_defaults').to route_to('settings#initialize_defaults')
    end

    it 'routes to #index' do
      expect(get: '/settings').to route_to('settings#index')
    end
    it 'routes to #show' do
      expect(get: '/settings/1').to route_to('settings#show', id: '1')
    end

    it 'routes to #new' do
      expect(get: '/settings/new').to route_to('settings#new')
    end
    it 'routes to #create' do
      expect(post: '/settings').to route_to('settings#create')
    end

    it 'routes to #edit' do
      expect(get: '/settings/1/edit').to route_to('settings#edit', id: '1')
    end
    it 'routes to #update' do
      expect(patch: '/settings/1').to route_to('settings#update', id: '1')
    end

    it 'routes to #delete' do
      expect(get: '/settings/1/delete').to route_to('settings#delete', id: '1')
    end
    it 'routes to #destroy via delete' do
      expect(delete: '/settings/1/delete').to route_to('settings#destroy', id: '1')
    end
    it 'routes to #destroy' do
      expect(delete: '/settings/1').to route_to('settings#destroy', id: '1')
    end
  end
end
