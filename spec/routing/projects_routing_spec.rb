require 'rails_helper'

describe ProjectsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/projects').to route_to('projects#index')
    end
    it 'routes to #show' do
      expect(get: '/projects/1').to route_to('projects#show', id: '1')
    end
    it 'routes to #show with a projecturl' do
      expect(get: '/project/filename').to route_to('projects#show', projecturl: 'filename')
    end

    it 'routes to #new' do
      expect(get: '/projects/new').to route_to('projects#new')
    end
    it 'routes to #create' do
      expect(post: '/projects').to route_to('projects#create')
    end

    it 'routes to #edit' do
      expect(get: '/projects/1/edit').to route_to('projects#edit', id: '1')
    end
    it 'routes to #update' do
      expect(patch: '/projects/1').to route_to('projects#update', id: '1')
    end

    it 'routes to #delete' do
      expect(get: '/projects/1/delete').to route_to('projects#delete', id: '1')
    end
    it 'routes to #destroy via delete' do
      expect(delete: '/projects/1/delete').to route_to('projects#destroy', id: '1')
    end
    it 'routes to #destroy' do
      expect(delete: '/projects/1').to route_to('projects#destroy', id: '1')
    end

    context 'using filename' do
      it 'routes to #show' do
        expect(get: '/project/name/subname').to route_to('projects#show', projecturl: 'name/subname')
      end
    end
  end
end
