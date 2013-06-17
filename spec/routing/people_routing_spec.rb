# encoding: utf-8
require 'spec_helper'
require 'people_controller'

describe PeopleController do
  describe 'routing' do

    it 'routes to #index' do
      get('/people').should route_to('people#index')
    end
    it 'routes to #show' do
      get('/people/abc').should route_to('people#show', id: 'abc')
    end

    it 'routes to #new' do
      get('/people/new').should route_to('people#new')
    end
    it 'routes to #create' do
      post('/people').should route_to('people#create')
    end

    it 'routes to #edit' do
      get('/people/abc/edit').should route_to('people#edit', id: 'abc')
    end
    it 'routes to #update' do
      put('/people/abc').should route_to('people#update', id: 'abc')
    end

    it 'routes to #delete' do
      get('/people/abc/delete').should route_to('people#delete', id: 'abc')
    end
    it 'routes to #destroy via delete' do
      delete('/people/abc/delete').should route_to('people#destroy', id: 'abc')
    end
    it 'routes to #destroy' do
      delete('/people/abc').should route_to('people#destroy', id: 'abc')
    end

  end
end
