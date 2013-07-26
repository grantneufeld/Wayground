# encoding: utf-8
require 'spec_helper'
require 'ballots_controller'

describe BallotsController do
  describe 'routing' do

    it 'routes to #index' do
      get('/levels/def/elections/ghi/ballots').should route_to('ballots#index', level_id: 'def', election_id: 'ghi')
    end
    it 'routes to #show' do
      get('/levels/def/elections/ghi/ballots/abc').should route_to('ballots#show', id: 'abc', level_id: 'def', election_id: 'ghi')
    end

    it 'routes to #new' do
      get('/levels/def/elections/ghi/ballots/new').should route_to('ballots#new', level_id: 'def', election_id: 'ghi')
    end
    it 'routes to #create' do
      post('/levels/def/elections/ghi/ballots').should route_to('ballots#create', level_id: 'def', election_id: 'ghi')
    end

    it 'routes to #edit' do
      get('/levels/def/elections/ghi/ballots/abc/edit').should route_to('ballots#edit', id: 'abc', level_id: 'def', election_id: 'ghi')
    end
    it 'routes to #update' do
      patch('/levels/def/elections/ghi/ballots/abc').should route_to('ballots#update', id: 'abc', level_id: 'def', election_id: 'ghi')
    end

    it 'routes to #delete' do
      get('/levels/def/elections/ghi/ballots/abc/delete').should route_to('ballots#delete', id: 'abc', level_id: 'def', election_id: 'ghi')
    end
    it 'routes to #destroy via delete' do
      delete('/levels/def/elections/ghi/ballots/abc/delete').should route_to('ballots#destroy', id: 'abc', level_id: 'def', election_id: 'ghi')
    end
    it 'routes to #destroy' do
      delete('/levels/def/elections/ghi/ballots/abc').should route_to('ballots#destroy', id: 'abc', level_id: 'def', election_id: 'ghi')
    end

  end
end
