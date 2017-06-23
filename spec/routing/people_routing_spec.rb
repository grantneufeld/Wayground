require 'rails_helper'
require 'people_controller'

describe PeopleController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/people').to route_to('people#index')
    end
    it 'routes to #show' do
      expect(get: '/people/abc').to route_to('people#show', id: 'abc')
    end

    it 'routes to #new' do
      expect(get: '/people/new').to route_to('people#new')
    end
    it 'routes to #create' do
      expect(post: '/people').to route_to('people#create')
    end

    it 'routes to #edit' do
      expect(get: '/people/abc/edit').to route_to('people#edit', id: 'abc')
    end
    it 'routes to #update' do
      expect(patch: '/people/abc').to route_to('people#update', id: 'abc')
    end

    it 'routes to #delete' do
      expect(get: '/people/abc/delete').to route_to('people#delete', id: 'abc')
    end
    it 'routes to #destroy via delete' do
      expect(delete: '/people/abc/delete').to route_to('people#destroy', id: 'abc')
    end
    it 'routes to #destroy' do
      expect(delete: '/people/abc').to route_to('people#destroy', id: 'abc')
    end
  end
end
