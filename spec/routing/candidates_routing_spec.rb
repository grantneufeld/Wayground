# encoding: utf-8
require 'spec_helper'
require 'candidates_controller'

describe CandidatesController do
  describe 'routing' do

    it 'routes to #index' do
      expect( get('/levels/def/elections/ghi/ballots/jkl/candidates') ).to route_to(
        'candidates#index', level_id: 'def', election_id: 'ghi', ballot_id: 'jkl'
      )
    end
    it 'routes to #show' do
      expect( get('/levels/def/elections/ghi/ballots/jkl/candidates/abc') ).to route_to(
        'candidates#show', id: 'abc', level_id: 'def', election_id: 'ghi', ballot_id: 'jkl'
      )
    end

    it 'routes to #new' do
      expect( get('/levels/def/elections/ghi/ballots/jkl/candidates/new') ).to route_to(
        'candidates#new', level_id: 'def', election_id: 'ghi', ballot_id: 'jkl'
      )
    end
    it 'routes to #create' do
      expect( post('/levels/def/elections/ghi/ballots/jkl/candidates') ).to route_to(
        'candidates#create', level_id: 'def', election_id: 'ghi', ballot_id: 'jkl'
      )
    end

    it 'routes to #edit' do
      expect( get('/levels/def/elections/ghi/ballots/jkl/candidates/abc/edit') ).to route_to(
        'candidates#edit', id: 'abc', level_id: 'def', election_id: 'ghi', ballot_id: 'jkl'
      )
    end
    it 'routes to #update' do
      expect( put('/levels/def/elections/ghi/ballots/jkl/candidates/abc') ).to route_to(
        'candidates#update', id: 'abc', level_id: 'def', election_id: 'ghi', ballot_id: 'jkl'
      )
    end

    it 'routes to #delete' do
      expect( get('/levels/def/elections/ghi/ballots/jkl/candidates/abc/delete') ).to route_to(
        'candidates#delete', id: 'abc', level_id: 'def', election_id: 'ghi', ballot_id: 'jkl'
      )
    end
    it 'routes to #destroy via delete' do
      expect( delete('/levels/def/elections/ghi/ballots/jkl/candidates/abc/delete') ).to route_to(
        'candidates#destroy', id: 'abc', level_id: 'def', election_id: 'ghi', ballot_id: 'jkl'
      )
    end
    it 'routes to #destroy' do
      expect( delete('/levels/def/elections/ghi/ballots/jkl/candidates/abc') ).to route_to(
        'candidates#destroy', id: 'abc', level_id: 'def', election_id: 'ghi', ballot_id: 'jkl'
      )
    end

  end
end
