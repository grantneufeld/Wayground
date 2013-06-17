# encoding: utf-8
require 'spec_helper'
require 'parties_controller'

describe PartiesController do
  describe 'routing' do

    it 'routes to #index' do
      get('/levels/def/parties').should route_to('parties#index', level_id: 'def')
    end
    it 'routes to #show' do
      get('/levels/def/parties/abc').should route_to('parties#show', id: 'abc', level_id: 'def')
    end

    it 'routes to #new' do
      get('/levels/def/parties/new').should route_to('parties#new', level_id: 'def')
    end
    it 'routes to #create' do
      post('/levels/def/parties').should route_to('parties#create', level_id: 'def')
    end

    it 'routes to #edit' do
      get('/levels/def/parties/abc/edit').should route_to('parties#edit', id: 'abc', level_id: 'def')
    end
    it 'routes to #update' do
      put('/levels/def/parties/abc').should route_to('parties#update', id: 'abc', level_id: 'def')
    end

    it 'routes to #delete' do
      get('/levels/def/parties/abc/delete').should route_to('parties#delete', id: 'abc', level_id: 'def')
    end
    it 'routes to #destroy via delete' do
      delete('/levels/def/parties/abc/delete').should route_to('parties#destroy', id: 'abc', level_id: 'def')
    end
    it 'routes to #destroy' do
      delete('/levels/def/parties/abc').should route_to('parties#destroy', id: 'abc', level_id: 'def')
    end

  end
end
