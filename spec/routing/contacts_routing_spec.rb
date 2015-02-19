require 'rails_helper'

describe ContactsController, type: :routing do
  describe 'routing' do
    describe 'nested under candidates' do
      it 'routes to #index' do
        expect(get: '/levels/1/elections/2/ballots/3/candidates/4/contacts').to route_to(
          'contacts#index', level_id: '1', election_id: '2', ballot_id: '3', candidate_id: '4'
        )
      end
      it 'routes to #show' do
        expect(get: '/levels/1/elections/2/ballots/3/candidates/4/contacts/5').to route_to(
          'contacts#show', id: '5', level_id: '1', election_id: '2', ballot_id: '3', candidate_id: '4'
        )
      end

      it 'routes to #new' do
        expect(get: '/levels/1/elections/2/ballots/3/candidates/4/contacts/new').to route_to(
          'contacts#new', level_id: '1', election_id: '2', ballot_id: '3', candidate_id: '4'
        )
      end
      it 'routes to #create' do
        expect(post: '/levels/1/elections/2/ballots/3/candidates/4/contacts').to route_to(
          'contacts#create', level_id: '1', election_id: '2', ballot_id: '3', candidate_id: '4'
        )
      end

      it 'routes to #edit' do
        expect(get: '/levels/1/elections/2/ballots/3/candidates/4/contacts/5/edit').to route_to(
          'contacts#edit', id: '5', level_id: '1', election_id: '2', ballot_id: '3', candidate_id: '4'
        )
      end
      it 'routes to #update' do
        expect(patch: '/levels/1/elections/2/ballots/3/candidates/4/contacts/5').to route_to(
          'contacts#update', id: '5', level_id: '1', election_id: '2', ballot_id: '3', candidate_id: '4'
        )
      end

      it 'routes to #delete' do
        expect(get: '/levels/1/elections/2/ballots/3/candidates/4/contacts/5/delete').to route_to(
          'contacts#delete', id: '5', level_id: '1', election_id: '2', ballot_id: '3', candidate_id: '4'
        )
      end
      it 'routes to #destroy via delete' do
        expect(delete: '/levels/1/elections/2/ballots/3/candidates/4/contacts/5/delete').to route_to(
          'contacts#destroy', id: '5', level_id: '1', election_id: '2', ballot_id: '3', candidate_id: '4'
        )
      end
      it 'routes to #destroy' do
        expect(delete: '/levels/1/elections/2/ballots/3/candidates/4/contacts/5').to route_to(
          'contacts#destroy', id: '5', level_id: '1', election_id: '2', ballot_id: '3', candidate_id: '4'
        )
      end
    end

    describe 'nested under people' do
      it 'routes to #index' do
        expect(get: '/people/1/contacts').to route_to(
          'contacts#index', person_id: '1'
        )
      end
      it 'routes to #show' do
        expect(get: '/people/1/contacts/2').to route_to(
          'contacts#show', id: '2', person_id: '1'
        )
      end

      it 'routes to #new' do
        expect(get: '/people/1/contacts/new').to route_to(
          'contacts#new', person_id: '1'
        )
      end
      it 'routes to #create' do
        expect(post: '/people/1/contacts').to route_to(
          'contacts#create', person_id: '1'
        )
      end

      it 'routes to #edit' do
        expect(get: '/people/1/contacts/2/edit').to route_to(
          'contacts#edit', id: '2', person_id: '1'
        )
      end
      it 'routes to #update' do
        expect(patch: '/people/1/contacts/2').to route_to(
          'contacts#update', id: '2', person_id: '1'
        )
      end

      it 'routes to #delete' do
        expect(get: '/people/1/contacts/2/delete').to route_to(
          'contacts#delete', id: '2', person_id: '1'
        )
      end
      it 'routes to #destroy via delete' do
        expect(delete: '/people/1/contacts/2/delete').to route_to(
          'contacts#destroy', id: '2', person_id: '1'
        )
      end
      it 'routes to #destroy' do
        expect(delete: '/people/1/contacts/2').to route_to(
          'contacts#destroy', id: '2', person_id: '1'
        )
      end
    end
  end
end
