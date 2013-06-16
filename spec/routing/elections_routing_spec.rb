# encoding: utf-8
require 'spec_helper'
require 'elections_controller'

describe ElectionsController do
  describe 'routing' do

    it 'routes to #index' do
      get('/levels/def/elections').should route_to('elections#index', level_id: 'def')
    end
    it 'routes to #show' do
      get('/levels/def/elections/abc').should route_to('elections#show', id: 'abc', level_id: 'def')
    end

    it 'routes to #new' do
      get('/levels/def/elections/new').should route_to('elections#new', level_id: 'def')
    end
    it 'routes to #create' do
      post('/levels/def/elections').should route_to('elections#create', level_id: 'def')
    end

    it 'routes to #edit' do
      get('/levels/def/elections/abc/edit').should route_to('elections#edit', id: 'abc', level_id: 'def')
    end
    it 'routes to #update' do
      put('/levels/def/elections/abc').should route_to('elections#update', id: 'abc', level_id: 'def')
    end

    it 'routes to #delete' do
      get('/levels/def/elections/abc/delete').should route_to('elections#delete', id: 'abc', level_id: 'def')
    end
    it 'routes to #destroy via delete' do
      delete('/levels/def/elections/abc/delete').should route_to('elections#destroy', id: 'abc', level_id: 'def')
    end
    it 'routes to #destroy' do
      delete('/levels/def/elections/abc').should route_to('elections#destroy', id: 'abc', level_id: 'def')
    end

  end
end
