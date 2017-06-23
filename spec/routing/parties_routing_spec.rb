require 'rails_helper'
require 'parties_controller'

describe PartiesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/levels/def/parties').to route_to('parties#index', level_id: 'def')
    end
    it 'routes to #show' do
      expect(get: '/levels/def/parties/abc').to route_to('parties#show', id: 'abc', level_id: 'def')
    end

    it 'routes to #new' do
      expect(get: '/levels/def/parties/new').to route_to('parties#new', level_id: 'def')
    end
    it 'routes to #create' do
      expect(post: '/levels/def/parties').to route_to('parties#create', level_id: 'def')
    end

    it 'routes to #edit' do
      expect(get: '/levels/def/parties/abc/edit').to route_to('parties#edit', id: 'abc', level_id: 'def')
    end
    it 'routes to #update' do
      expect(patch: '/levels/def/parties/abc').to route_to('parties#update', id: 'abc', level_id: 'def')
    end

    it 'routes to #delete' do
      expect(get: '/levels/def/parties/abc/delete').to route_to(
        'parties#delete', id: 'abc', level_id: 'def'
      )
    end
    it 'routes to #destroy via delete' do
      expect(delete: '/levels/def/parties/abc/delete').to route_to(
        'parties#destroy', id: 'abc', level_id: 'def'
      )
    end
    it 'routes to #destroy' do
      expect(delete: '/levels/def/parties/abc').to route_to('parties#destroy', id: 'abc', level_id: 'def')
    end
  end
end
