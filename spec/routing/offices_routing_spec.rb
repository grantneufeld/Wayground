require 'rails_helper'
require 'offices_controller'

describe OfficesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/levels/def/offices').to route_to('offices#index', level_id: 'def')
    end
    it 'routes to #show' do
      expect(get: '/levels/def/offices/abc').to route_to('offices#show', id: 'abc', level_id: 'def')
    end

    it 'routes to #new' do
      expect(get: '/levels/def/offices/new').to route_to('offices#new', level_id: 'def')
    end
    it 'routes to #new with previous' do
      expect(get: '/levels/def/offices/new/abc').to route_to(
        'offices#new', previous_id: 'abc', level_id: 'def'
      )
    end
    it 'routes to #create' do
      expect(post: '/levels/def/offices').to route_to('offices#create', level_id: 'def')
    end

    it 'routes to #edit' do
      expect(get: '/levels/def/offices/abc/edit').to route_to('offices#edit', id: 'abc', level_id: 'def')
    end
    it 'routes to #update' do
      expect(patch: '/levels/def/offices/abc').to route_to('offices#update', id: 'abc', level_id: 'def')
    end

    it 'routes to #delete' do
      expect(get: '/levels/def/offices/abc/delete').to route_to(
        'offices#delete', id: 'abc', level_id: 'def'
      )
    end
    it 'routes to #destroy via delete' do
      expect(delete: '/levels/def/offices/abc/delete').to route_to(
        'offices#destroy', id: 'abc', level_id: 'def'
      )
    end
    it 'routes to #destroy' do
      expect(delete: '/levels/def/offices/abc').to route_to('offices#destroy', id: 'abc', level_id: 'def')
    end
  end
end
