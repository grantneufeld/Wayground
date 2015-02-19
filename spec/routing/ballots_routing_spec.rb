require 'rails_helper'
require 'ballots_controller'

describe BallotsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/levels/def/elections/ghi/ballots').to route_to(
        'ballots#index', level_id: 'def', election_id: 'ghi'
      )
    end
    it 'routes to #show' do
      expect(get: '/levels/def/elections/ghi/ballots/abc').to route_to(
        'ballots#show', id: 'abc', level_id: 'def', election_id: 'ghi'
      )
    end

    it 'routes to #new' do
      expect(get: '/levels/def/elections/ghi/ballots/new').to route_to(
        'ballots#new', level_id: 'def', election_id: 'ghi'
      )
    end
    it 'routes to #create' do
      expect(post: '/levels/def/elections/ghi/ballots').to route_to(
        'ballots#create', level_id: 'def', election_id: 'ghi'
      )
    end

    it 'routes to #edit' do
      expect(get: '/levels/def/elections/ghi/ballots/abc/edit').to route_to(
        'ballots#edit', id: 'abc', level_id: 'def', election_id: 'ghi'
      )
    end
    it 'routes to #update' do
      expect(patch: '/levels/def/elections/ghi/ballots/abc').to route_to(
        'ballots#update', id: 'abc', level_id: 'def', election_id: 'ghi'
      )
    end

    it 'routes to #delete' do
      expect(get: '/levels/def/elections/ghi/ballots/abc/delete').to route_to(
        'ballots#delete', id: 'abc', level_id: 'def', election_id: 'ghi'
      )
    end
    it 'routes to #destroy via delete' do
      expect(delete: '/levels/def/elections/ghi/ballots/abc/delete').to route_to(
        'ballots#destroy', id: 'abc', level_id: 'def', election_id: 'ghi'
      )
    end
    it 'routes to #destroy' do
      expect(delete: '/levels/def/elections/ghi/ballots/abc').to route_to(
        'ballots#destroy', id: 'abc', level_id: 'def', election_id: 'ghi'
      )
    end

  end
end
