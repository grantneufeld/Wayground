require 'rails_helper'

describe VersionsController, type: :routing do
  describe 'routing' do
    describe 'nested under pages' do
      it 'recognizes and generates #index' do
        expect(get: '/pages/1/versions').to route_to(
          controller: 'versions', action: 'index', page_id: '1'
        )
      end
      it 'recognizes and generates #show' do
        expect(get: '/pages/1/versions/2').to route_to(
          controller: 'versions', action: 'show', id: '2', page_id: '1'
        )
      end
    end
    describe 'nested under events' do
      it 'recognizes and generates #index' do
        expect(get: '/events/1/versions').to route_to(
          controller: 'versions', action: 'index', event_id: '1'
        )
      end
      it 'recognizes and generates #show' do
        expect(get: '/events/1/versions/2').to route_to(
          controller: 'versions', action: 'show', id: '2', event_id: '1'
        )
      end
    end
  end
end
