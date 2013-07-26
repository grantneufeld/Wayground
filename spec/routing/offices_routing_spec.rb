# encoding: utf-8
require 'spec_helper'
require 'offices_controller'

describe OfficesController do
  describe 'routing' do

    it 'routes to #index' do
      get('/levels/def/offices').should route_to('offices#index', level_id: 'def')
    end
    it 'routes to #show' do
      get('/levels/def/offices/abc').should route_to('offices#show', id: 'abc', level_id: 'def')
    end

    it 'routes to #new' do
      get('/levels/def/offices/new').should route_to('offices#new', level_id: 'def')
    end
    it 'routes to #new with previous' do
      get('/levels/def/offices/new/abc').should route_to('offices#new', previous_id: 'abc', level_id: 'def')
    end
    it 'routes to #create' do
      post('/levels/def/offices').should route_to('offices#create', level_id: 'def')
    end

    it 'routes to #edit' do
      get('/levels/def/offices/abc/edit').should route_to('offices#edit', id: 'abc', level_id: 'def')
    end
    it 'routes to #update' do
      patch('/levels/def/offices/abc').should route_to('offices#update', id: 'abc', level_id: 'def')
    end

    it 'routes to #delete' do
      get('/levels/def/offices/abc/delete').should route_to('offices#delete', id: 'abc', level_id: 'def')
    end
    it 'routes to #destroy via delete' do
      delete('/levels/def/offices/abc/delete').should route_to('offices#destroy', id: 'abc', level_id: 'def')
    end
    it 'routes to #destroy' do
      delete('/levels/def/offices/abc').should route_to('offices#destroy', id: 'abc', level_id: 'def')
    end

  end
end
