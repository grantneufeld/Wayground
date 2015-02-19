require 'rails_helper'
require 'levels_controller'

describe LevelsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/levels').to route_to('levels#index')
    end
    it 'routes to #show' do
      expect(get: '/levels/abc').to route_to('levels#show', id: 'abc')
    end

    it 'routes to #new' do
      expect(get: '/levels/new').to route_to('levels#new')
    end
    it 'routes to #new with parent' do
      expect(get: '/levels/new/abc').to route_to('levels#new', parent_id: 'abc')
    end
    it 'routes to #create' do
      expect(post: '/levels').to route_to('levels#create')
    end

    it 'routes to #edit' do
      expect(get: '/levels/abc/edit').to route_to('levels#edit', id: 'abc')
    end
    it 'routes to #update' do
      expect(patch: '/levels/abc').to route_to('levels#update', id: 'abc')
    end

    it 'routes to #delete' do
      expect(get: '/levels/abc/delete').to route_to('levels#delete', id: 'abc')
    end
    it 'routes to #destroy via delete' do
      expect(delete: '/levels/abc/delete').to route_to('levels#destroy', id: 'abc')
    end
    it 'routes to #destroy' do
      expect(delete: '/levels/abc').to route_to('levels#destroy', id: 'abc')
    end

  end
end
