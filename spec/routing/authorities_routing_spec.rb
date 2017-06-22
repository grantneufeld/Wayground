require 'rails_helper'

describe AuthoritiesController, type: :routing do
  describe 'routing' do
    it 'recognizes and generates #index' do
      expect(get: '/authorities').to route_to(controller: 'authorities', action: 'index')
    end
    it 'recognizes and generates #show' do
      expect(get: '/authorities/1').to route_to(controller: 'authorities', action: 'show', id: '1')
    end

    it 'recognizes and generates #new' do
      expect(get: '/authorities/new').to route_to(controller: 'authorities', action: 'new')
    end
    it 'recognizes and generates #create (post)' do
      expect(post: '/authorities').to route_to(controller: 'authorities', action: 'create')
    end

    it 'recognizes and generates #edit' do
      expect(get: '/authorities/1/edit').to route_to(controller: 'authorities', action: 'edit', id: '1')
    end
    it 'recognizes and generates #update (patch)' do
      expect(patch: '/authorities/1').to route_to(controller: 'authorities', action: 'update', id: '1')
    end

    it 'recognizes and generates #delete' do
      expect(get: '/authorities/1/delete').to route_to(controller: 'authorities', action: 'delete', id: '1')
    end
    it 'routes to #destroy via delete' do
      expect(delete: '/authorities/1/delete').to route_to('authorities#destroy', id: '1')
    end
    it 'recognizes and generates #destroy (delete)' do
      expect(delete: '/authorities/1').to route_to(controller: 'authorities', action: 'destroy', id: '1')
    end
  end
end
