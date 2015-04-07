require 'rails_helper'
require 'elections_controller'

describe ElectionsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/levels/def/elections').to route_to('elections#index', level_id: 'def')
    end
    it 'routes to #show' do
      expect(get: '/levels/def/elections/abc').to route_to('elections#show', id: 'abc', level_id: 'def')
    end

    it 'routes to #new' do
      expect(get: '/levels/def/elections/new').to route_to('elections#new', level_id: 'def')
    end
    it 'routes to #create' do
      expect(post: '/levels/def/elections').to route_to('elections#create', level_id: 'def')
    end

    it 'routes to #edit' do
      expect(get: '/levels/def/elections/abc/edit').to route_to(
        'elections#edit', id: 'abc', level_id: 'def'
      )
    end
    it 'routes to #update' do
      expect(patch: '/levels/def/elections/abc').to route_to(
        'elections#update', id: 'abc', level_id: 'def'
      )
    end

    it 'routes to #delete' do
      expect(get: '/levels/def/elections/abc/delete').to route_to(
        'elections#delete', id: 'abc', level_id: 'def'
      )
    end
    it 'routes to #destroy via delete' do
      expect(delete: '/levels/def/elections/abc/delete').to route_to(
        'elections#destroy', id: 'abc', level_id: 'def'
      )
    end
    it 'routes to #destroy' do
      expect(delete: '/levels/def/elections/abc').to route_to(
        'elections#destroy', id: 'abc', level_id: 'def'
      )
    end

    it 'routes to #ballot_maker' do
      expect(get: '/levels/def/elections/abc/ballot_maker').to route_to(
        'elections#ballot_maker', id: 'abc', level_id: 'def'
      )
    end
    it 'routes to #generate_ballots' do
      expect(post: '/levels/def/elections/abc/generate_ballots').to route_to(
        'elections#generate_ballots', id: 'abc', level_id: 'def'
      )
    end

  end
end
