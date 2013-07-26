# encoding: utf-8
require 'spec_helper'
require 'levels_controller'

describe LevelsController do
  describe 'routing' do

    it 'routes to #index' do
      get('/levels').should route_to('levels#index')
    end
    it 'routes to #show' do
      get('/levels/abc').should route_to('levels#show', id: 'abc')
    end

    it 'routes to #new' do
      get('/levels/new').should route_to('levels#new')
    end
    it 'routes to #new with parent' do
      get('/levels/new/abc').should route_to('levels#new', parent_id: 'abc')
    end
    it 'routes to #create' do
      post('/levels').should route_to('levels#create')
    end

    it 'routes to #edit' do
      get('/levels/abc/edit').should route_to('levels#edit', id: 'abc')
    end
    it 'routes to #update' do
      patch('/levels/abc').should route_to('levels#update', id: 'abc')
    end

    it 'routes to #delete' do
      get('/levels/abc/delete').should route_to('levels#delete', id: 'abc')
    end
    it 'routes to #destroy via delete' do
      delete('/levels/abc/delete').should route_to('levels#destroy', id: 'abc')
    end
    it 'routes to #destroy' do
      delete('/levels/abc').should route_to('levels#destroy', id: 'abc')
    end

  end
end
