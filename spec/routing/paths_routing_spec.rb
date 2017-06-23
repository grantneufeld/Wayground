require 'rails_helper'

describe PathsController, type: :routing do
  describe 'routing' do
    it 'handles the root url' do
      expect(get: '/').to route_to(controller: 'paths', action: 'sitepath', url: '/')
    end
    it 'recognizes custom paths' do
      expect(get: '/custom/path').to route_to(controller: 'paths', action: 'sitepath', url: 'custom/path')
    end
    it 'recognizes custom paths with a filename extension' do
      expect(get: '/custom/path.extension').to route_to(
        controller: 'paths', action: 'sitepath', url: 'custom/path.extension'
      )
    end

    it 'recognizes and generates #index' do
      expect(get: '/paths').to route_to(controller: 'paths', action: 'index')
    end
    it 'recognizes and generates #show' do
      expect(get: '/paths/1').to route_to(controller: 'paths', action: 'show', id: '1')
    end

    it 'recognizes and generates #new' do
      expect(get: '/paths/new').to route_to(controller: 'paths', action: 'new')
    end
    it 'recognizes and generates #create' do
      expect(post: '/paths').to route_to(controller: 'paths', action: 'create')
    end

    it 'recognizes and generates #edit' do
      expect(get: '/paths/1/edit').to route_to(controller: 'paths', action: 'edit', id: '1')
    end
    it 'recognizes and generates #update' do
      expect(patch: '/paths/1').to route_to(controller: 'paths', action: 'update', id: '1')
    end

    it 'recognizes and generates #delete' do
      expect(get: '/paths/1/delete').to route_to(controller: 'paths', action: 'delete', id: '1')
    end
    it 'routes to #destroy via delete' do
      expect(delete: '/paths/1/delete').to route_to('paths#destroy', id: '1')
    end
    it 'recognizes and generates #destroy' do
      expect(delete: '/paths/1').to route_to(controller: 'paths', action: 'destroy', id: '1')
    end
  end
end
