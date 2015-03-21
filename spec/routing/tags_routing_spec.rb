require 'rails_helper'

describe TagsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/tags').to route_to('tags#index')
    end
    it 'routes to #tag' do
      expect(get: '/tags/test').to route_to('tags#tag', tag: 'test')
    end

  end
end
