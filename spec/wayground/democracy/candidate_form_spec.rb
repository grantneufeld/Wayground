require 'rails_helper'
require 'democracy/candidate_form'
require 'candidate'

describe Wayground::Democracy::CandidateForm do

  before(:all) do
    Person.delete_all
    @ballot = FactoryGirl.create(:ballot)
    @level = @ballot.election.level
    @party = FactoryGirl.create(:party, level: @level)
    @duplicate_person = FactoryGirl.create(:person, filename: 'duplicate_person', fullname: 'Duplicate Person')
    dup_candidate = @ballot.candidates.build(filename: 'duplicate_candidate', name: 'Duplicate Candidate')
    dup_candidate.person = @duplicate_person
    dup_candidate.save!
  end
  def ballot
    @ballot
  end
  def party
    @party
  end
  def duplicate_person
    @duplicate_person
  end

  let(:person) do
    $person = Person.new(bio: 'Bio.')
  end
  let(:candidate) do
    $candidate = Candidate.new(
      name: 'Candidate', filename: 'candidate',
      is_rumoured: true, is_confirmed: true, is_incumbent: true, is_leader: true,
      is_acclaimed: true, is_elected: true,
      announced_on: '2001-02-03', quit_on: '2002-03-04', vote_count: '1234'
    )
    $candidate.person = person
    $candidate.party = party
    $candidate
  end

  # ATTRIBUTE SECURITY

  describe 'attribute mass assignment security' do
    it 'should not allow ballot to be set' do
      form = Wayground::Democracy::CandidateForm.new(ballot: ballot)
      expect( form.ballot ).to be_nil
    end
    it 'should not allow ‘ballot’ to be set' do
      form = Wayground::Democracy::CandidateForm.new('ballot' => ballot)
      expect( form.ballot ).to be_nil
    end
    it 'should not allow candidate to be set' do
      form = Wayground::Democracy::CandidateForm.new(candidate: candidate)
      expect( form.candidate ).to be_nil
    end
    it 'should not allow ‘candidate’ to be set' do
      form = Wayground::Democracy::CandidateForm.new('candidate' => candidate)
      expect( form.candidate ).to be_nil
    end
    it 'should not allow person to be set' do
      form = Wayground::Democracy::CandidateForm.new(person: person)
      expect( form.person ).to be_nil
    end
    it 'should not allow ‘person’ to be set' do
      form = Wayground::Democracy::CandidateForm.new('person' => person)
      expect( form.person ).to be_nil
    end
  end

  # ATTRIBUTES

  describe '#ballot' do
    it 'should return nil by default' do
      form = Wayground::Democracy::CandidateForm.new
      expect( form.ballot ).to be_nil
    end
    it 'should return the assigned ballot' do
      form = Wayground::Democracy::CandidateForm.new
      form.ballot = ballot
      expect( form.ballot ).to eq ballot
    end
  end
  describe '#ballot=' do
    it 'should assign the ballot' do
      form = Wayground::Democracy::CandidateForm.new
      form.ballot = ballot
      expect( form.ballot ).to eq ballot
    end
  end

  describe '#candidate' do
    it 'should return the candidate' do
      form = Wayground::Democracy::CandidateForm.new
      form.candidate = candidate
      expect( form.candidate ).to eq candidate
    end
  end
  describe '#candidate=' do
    it 'should accept a candidate' do
      form = Wayground::Democracy::CandidateForm.new
      form.candidate = candidate
      expect( form.candidate ).to eq(candidate)
    end
    it 'should assign the ballot based on the candidate' do
      form = Wayground::Democracy::CandidateForm.new
      candidate.ballot = ballot
      form.candidate = candidate
      expect( form.ballot ).to eq(ballot)
    end
    it 'should override the already set ballot based on the candidate' do
      form = Wayground::Democracy::CandidateForm.new
      form.ballot = Ballot.new
      candidate.ballot = ballot
      form.candidate = candidate
      expect( form.ballot ).to eq(ballot)
    end
  end

  describe '#person' do
    context 'with a candidate assigned' do
      context 'with a candidate with a person assigned' do
        it 'should return the person' do
          form = Wayground::Democracy::CandidateForm.new
          form.candidate = candidate
          expect(form.person).to be candidate.person
        end
      end
      context 'without a person assigned' do
        it 'should return a new person' do
          form = Wayground::Democracy::CandidateForm.new
          form.candidate = Candidate.new
          expect(form.person).to be_a(Person)
        end
      end
    end
    context 'with no candidate assigned' do
      context 'with no ballot assigned' do
        it 'should return nil' do
          form = Wayground::Democracy::CandidateForm.new
          expect(form.person).to be_nil
        end
      end
      context 'with a ballot assigned' do
        it 'should create a new person for a new candidate for the ballot' do
          form = Wayground::Democracy::CandidateForm.new
          form.ballot = ballot
          expect(form.person).to be_a(Person)
          expect(form.candidate).to be_a(Candidate)
          expect(form.candidate.ballot).to be(ballot)
        end
      end
    end
  end
  describe '#person=' do
    it 'should accept a person' do
      form = Wayground::Democracy::CandidateForm.new
      form.candidate = Candidate.new
      form.person = person
      expect( form.person ).to eq(person)
    end
    context 'without values set for the candidate, or from params' do
      it 'should assign the filename from the person' do
        form = Wayground::Democracy::CandidateForm.new
        form.ballot = ballot
        form.person = Person.new(filename: 'from_person')
        expect(form.filename).to eq 'from_person'
      end
      it 'should assign the name from the person.fullname' do
        form = Wayground::Democracy::CandidateForm.new
        form.ballot = ballot
        form.person = Person.new(fullname: 'From Person')
        expect(form.name).to eq 'From Person'
      end
      it 'should assign the bio from the person' do
        form = Wayground::Democracy::CandidateForm.new
        form.ballot = ballot
        form.person = Person.new(bio: 'From Person.')
        expect(form.bio).to eq 'From Person.'
      end
    end
  end

  describe '#filename' do
    it 'should return the candidate filename' do
      form = Wayground::Democracy::CandidateForm.new
      form.candidate = candidate
      expect( form.filename ).to eq 'candidate'
    end
    context 'with no candidate' do
      it 'should default to nil' do
        form = Wayground::Democracy::CandidateForm.new
        expect( form.filename ).to be_nil
      end
    end
  end
  describe '#filename=' do
    it 'should assign the filename' do
      form = Wayground::Democracy::CandidateForm.new
      form.candidate = candidate
      form.filename = 'assign_filename'
      expect( form.filename ).to eq 'assign_filename'
    end
  end

  describe '#name' do
    it 'should return the candidate name' do
      form = Wayground::Democracy::CandidateForm.new
      form.candidate = candidate
      expect( form.name ).to eq 'Candidate'
    end
    context 'with no candidate' do
      it 'should default to nil' do
        form = Wayground::Democracy::CandidateForm.new
        expect( form.name ).to be_nil
      end
    end
  end

  describe '#is_rumoured' do
    it 'should return the candidate is_rumoured' do
      form = Wayground::Democracy::CandidateForm.new
      form.candidate = candidate
      expect( form.is_rumoured ).to be_truthy
    end
    context 'with no candidate' do
      it 'should default to false' do
        form = Wayground::Democracy::CandidateForm.new
        expect( form.is_rumoured ).to be_falsey
      end
    end
  end

  describe '#is_confirmed' do
    it 'should return the candidate is_confirmed' do
      form = Wayground::Democracy::CandidateForm.new
      form.candidate = candidate
      expect( form.is_confirmed ).to be_truthy
    end
    context 'with no candidate' do
      it 'should default to false' do
        form = Wayground::Democracy::CandidateForm.new
        expect( form.is_confirmed ).to be_falsey
      end
    end
  end

  describe '#is_incumbent' do
    it 'should return the candidate is_incumbent' do
      form = Wayground::Democracy::CandidateForm.new
      form.candidate = candidate
      expect( form.is_incumbent ).to be_truthy
    end
    context 'with no candidate' do
      it 'should default to false' do
        form = Wayground::Democracy::CandidateForm.new
        expect( form.is_incumbent ).to be_falsey
      end
    end
  end

  describe '#is_leader' do
    it 'should return the candidate is_leader' do
      form = Wayground::Democracy::CandidateForm.new
      form.candidate = candidate
      expect( form.is_leader ).to be_truthy
    end
    context 'with no candidate' do
      it 'should default to false' do
        form = Wayground::Democracy::CandidateForm.new
        expect( form.is_leader ).to be_falsey
      end
    end
  end

  describe '#is_acclaimed' do
    it 'should return the candidate is_acclaimed' do
      form = Wayground::Democracy::CandidateForm.new
      form.candidate = candidate
      expect( form.is_acclaimed ).to be_truthy
    end
    context 'with no candidate' do
      it 'should default to false' do
        form = Wayground::Democracy::CandidateForm.new
        expect( form.is_acclaimed ).to be_falsey
      end
    end
  end

  describe '#is_elected' do
    it 'should return the candidate is_elected' do
      form = Wayground::Democracy::CandidateForm.new
      form.candidate = candidate
      expect( form.is_elected ).to be_truthy
    end
    context 'with no candidate' do
      it 'should default to false' do
        form = Wayground::Democracy::CandidateForm.new
        expect( form.is_elected ).to be_falsey
      end
    end
  end

  describe '#announced_on' do
    it 'should return the candidate announced_on' do
      form = Wayground::Democracy::CandidateForm.new
      form.candidate = candidate
      expect( form.announced_on.to_s ).to eq '2001-02-03'
    end
    context 'with no candidate' do
      it 'should default to nil' do
        form = Wayground::Democracy::CandidateForm.new
        expect( form.announced_on ).to be_nil
      end
    end
  end

  describe '#quit_on' do
    it 'should return the candidate quit_on' do
      form = Wayground::Democracy::CandidateForm.new
      form.candidate = candidate
      expect( form.quit_on.to_s ).to eq '2002-03-04'
    end
    context 'with no candidate' do
      it 'should default to nil' do
        form = Wayground::Democracy::CandidateForm.new
        expect( form.quit_on ).to be_nil
      end
    end
  end

  describe '#vote_count' do
    it 'should return the candidate vote_count' do
      form = Wayground::Democracy::CandidateForm.new
      form.candidate = candidate
      expect( form.vote_count ).to eq 1234
    end
    context 'with no candidate' do
      it 'should default to zero' do
        form = Wayground::Democracy::CandidateForm.new
        expect( form.vote_count ).to eq 0
      end
    end
  end

  describe '#bio' do
    it 'should return the person bio' do
      form = Wayground::Democracy::CandidateForm.new
      form.candidate = candidate
      expect( form.bio ).to eq 'Bio.'
    end
    context 'with no candidate' do
      it 'should default to nil' do
        form = Wayground::Democracy::CandidateForm.new
        expect( form.bio ).to be_nil
      end
    end
  end

  describe '#party_id' do
    it 'should return the party_id' do
      form = Wayground::Democracy::CandidateForm.new
      form.party_id = 123
      expect( form.party_id ).to eq 123
    end
    context 'with no party' do
      it 'should default to nil' do
        form = Wayground::Democracy::CandidateForm.new
        expect( form.party_id ).to be_nil
      end
    end
  end

  # VALIDATIONS

  describe 'validation' do
    let(:minimum_valid_params) { $minimum_valid_params = { 'name' => 'A', 'filename' => 'a' } }
    it 'should pass if the minimum values and the ballot are set' do
      form = Wayground::Democracy::CandidateForm.new(minimum_valid_params)
      form.ballot = ballot
      expect( form.valid? ).to be_truthy
    end
    describe 'of ballot' do
      it 'should fail if ballot is not set' do
        form = Wayground::Democracy::CandidateForm.new(minimum_valid_params)
        expect( form.valid? ).to be_falsey
      end
    end
    describe 'of person' do
      it 'should fail if the person has another candidacy on the ballot' do
        form = Wayground::Democracy::CandidateForm.new(minimum_valid_params)
        form.ballot = ballot
        form.person = duplicate_person
        expect( form.valid? ).to be_falsey
      end
    end
    describe 'of name' do
      it 'should fail if name is not set' do
        minimum_valid_params.delete('name')
        form = Wayground::Democracy::CandidateForm.new(minimum_valid_params)
        form.ballot = ballot
        expect( form.valid? ).to be_falsey
      end
      it 'should fail if name contains an angle-bracket' do
        form = Wayground::Democracy::CandidateForm.new(
          minimum_valid_params.merge('name' => 'Angle < Bracket')
        )
        form.ballot = ballot
        expect( form.valid? ).to be_falsey
      end
      it 'should fail if name contains an ampersand' do
        form = Wayground::Democracy::CandidateForm.new(
          minimum_valid_params.merge('name' => 'Ampersand & Test')
        )
        form.ballot = ballot
        expect( form.valid? ).to be_falsey
      end
      it 'should fail if name is not unique on the ballot' do
        form = Wayground::Democracy::CandidateForm.new(
          minimum_valid_params.merge('name' => 'Duplicate Candidate')
        )
        form.ballot = ballot
        expect( form.valid? ).to be_falsey
      end
    end
    describe 'of filename' do
      it 'should fail if filename is not set' do
        minimum_valid_params.delete('filename')
        minimum_valid_params.delete('name')
        form = Wayground::Democracy::CandidateForm.new(minimum_valid_params)
        form.ballot = ballot
        expect( form.valid? ).to be_falsey
      end
      it 'should fail if filename contains whitespace' do
        form = Wayground::Democracy::CandidateForm.new(
          minimum_valid_params.merge('filename' => 'white space')
        )
        form.ballot = ballot
        expect( form.valid? ).to be_falsey
      end
      it 'should fail if filename is not unique on the ballot' do
        form = Wayground::Democracy::CandidateForm.new(
          minimum_valid_params.merge('filename' => 'duplicate_candidate')
        )
        form.ballot = ballot
        expect( form.valid? ).to be_falsey
      end
      it 'should fail if filename is not unique for the person' do
        form = Wayground::Democracy::CandidateForm.new(
          minimum_valid_params.merge('filename' => 'duplicate_person')
        )
        form.ballot = ballot
        expect( form.valid? ).to be_falsey
      end
    end
    describe 'of dates' do
      it 'should pass if just announced_on is set' do
        form = Wayground::Democracy::CandidateForm.new(
          minimum_valid_params.merge('announced_on' => '2000-01-01')
        )
        form.ballot = ballot
        expect( form.valid? ).to be_truthy
      end
      it 'should pass if just quit_on is set' do
        form = Wayground::Democracy::CandidateForm.new(
          minimum_valid_params.merge('quit_on' => '2000-01-01')
        )
        form.ballot = ballot
        expect( form.valid? ).to be_truthy
      end
      it 'should pass if announced_on and quit_on are the same day' do
        form = Wayground::Democracy::CandidateForm.new(
          minimum_valid_params.merge('announced_on' => '2000-01-01', 'quit_on' => '2000-01-01')
        )
        form.ballot = ballot
        expect( form.valid? ).to be_truthy
      end
      it 'should pass if quit_on is after announced_on' do
        form = Wayground::Democracy::CandidateForm.new(
          minimum_valid_params.merge('announced_on' => '2000-01-01', 'quit_on' => '2000-01-02')
        )
        form.ballot = ballot
        expect( form.valid? ).to be_truthy
      end
      it 'should fail if quit_on is before announced_on' do
        form = Wayground::Democracy::CandidateForm.new(
          minimum_valid_params.merge('announced_on' => '2000-01-02', 'quit_on' => '2000-01-01')
        )
        form.ballot = ballot
        expect( form.valid? ).to be_falsey
      end
    end
  end

  # PUBLIC METHODS

  describe '#attributes=' do
    it 'should not modify attributes that are not present in the passed in params' do
      form = Wayground::Democracy::CandidateForm.new
      form.candidate = candidate
      form.attributes = {}
      expect( form.name ).to eq 'Candidate'
      expect( form.filename ).to eq 'candidate'
      expect( form.is_rumoured ).to be_truthy
      expect( form.is_confirmed ).to be_truthy
      expect( form.is_incumbent ).to be_truthy
      expect( form.is_leader ).to be_truthy
      expect( form.is_acclaimed ).to be_truthy
      expect( form.is_elected ).to be_truthy
      expect( form.announced_on.to_s ).to eq '2001-02-03'
      expect( form.quit_on.to_s ).to eq '2002-03-04'
      expect( form.vote_count.to_i ).to eq 1234
      expect( form.bio ).to eq 'Bio.'
      expect(form.party_id).to eq party.id
    end
    it 'should set filename' do
      form = Wayground::Democracy::CandidateForm.new
      form.attributes = { 'filename' => 'x' }
      expect( form.filename ).to eq 'x'
    end
    it 'should set filename from name when filename not set' do
      form = Wayground::Democracy::CandidateForm.new
      form.attributes = { 'name' => ' Test 123-456 ' }
      expect(form.filename).to eq 'test_123-456'
    end
    it 'should set name' do
      form = Wayground::Democracy::CandidateForm.new
      form.attributes = { 'name' => 'x' }
      expect( form.name ).to eq 'x'
    end
    it 'should set is_rumoured' do
      form = Wayground::Democracy::CandidateForm.new
      form.attributes = { 'is_rumoured' => '1' }
      expect( form.is_rumoured ).to be_truthy
    end
    it 'should set is_confirmed' do
      form = Wayground::Democracy::CandidateForm.new
      form.attributes = { 'is_confirmed' => '1' }
      expect( form.is_confirmed ).to be_truthy
    end
    it 'should set is_incumbent' do
      form = Wayground::Democracy::CandidateForm.new
      form.attributes = { 'is_incumbent' => '1' }
      expect( form.is_incumbent ).to be_truthy
    end
    it 'should set is_leader' do
      form = Wayground::Democracy::CandidateForm.new
      form.attributes = { 'is_leader' => '1' }
      expect( form.is_leader ).to be_truthy
    end
    it 'should set is_acclaimed' do
      form = Wayground::Democracy::CandidateForm.new
      form.attributes = { 'is_acclaimed' => '1' }
      expect( form.is_acclaimed ).to be_truthy
    end
    it 'should set is_elected' do
      form = Wayground::Democracy::CandidateForm.new
      form.attributes = { 'is_elected' => '1' }
      expect( form.is_elected ).to be_truthy
    end
    it 'should set announced_on' do
      form = Wayground::Democracy::CandidateForm.new
      form.attributes = { 'announced_on' => '2012-11-10' }
      expect( form.announced_on.to_s ).to eq '2012-11-10'
    end
    it 'should set quit_on' do
      form = Wayground::Democracy::CandidateForm.new
      form.attributes = { 'quit_on' => '2012-11-10' }
      expect( form.quit_on.to_s ).to eq '2012-11-10'
    end
    it 'should set vote_count' do
      form = Wayground::Democracy::CandidateForm.new
      form.attributes = { 'vote_count' => '456' }
      expect( form.vote_count.to_i ).to eq 456
    end
    it 'should set bio' do
      form = Wayground::Democracy::CandidateForm.new
      form.attributes = { 'bio' => 'x' }
      expect( form.bio ).to eq 'x'
    end
    it 'should set party_id' do
      form = Wayground::Democracy::CandidateForm.new
      form.attributes = { 'party_id' => '123' }
      expect( form.party_id ).to eq 123
    end
  end

  describe '#save' do
    let(:default_attrs) do
      $default_attrs ||= {
        'is_rumoured' => true, 'is_confirmed' => true, 'is_incumbent' => true,
        'is_leader' => true, 'is_acclaimed' => true, 'is_elected' => true,
        'announced_on' => '2001-02-03', 'quit_on' => '2002-03-04', 'vote_count' => 345,
        'bio' => 'Bio.', 'party_id' => 123
      }
    end
    context 'with valid parameters set' do
      context 'without an existing candidate or person' do
        it 'should create the candidate' do
          form = Wayground::Democracy::CandidateForm.new(
            default_attrs.merge('filename' => 'create_candidate', 'name' => 'Create Candidate')
          )
          form.ballot = ballot
          expect { form.save }.to change(Candidate, :count).by(1)
        end
        it 'should create the person' do
          form = Wayground::Democracy::CandidateForm.new(
            default_attrs.merge('filename' => 'create_person_for_candidate', 'name' => 'Create Person')
          )
          form.ballot = ballot
          expect { form.save }.to change(Person, :count).by(1)
        end
      end
      context 'with an existing person' do
        it 'should assign the attributes' do
          existing_person = FactoryGirl.create(:person,
            filename: 'existing_person', fullname: 'Existing Person', bio: nil
          )
          form = Wayground::Democracy::CandidateForm.new
          form.ballot = ballot
          form.person = existing_person
          form.attributes = default_attrs.merge(
            'filename' => 'with_person', 'name' => 'With Person', 'bio' => 'With person.'
          )
          form.save
          existing_person.reload
          expect( existing_person.bio ).to eq 'With person.'
        end
      end
      context 'with an existing candidate' do
        it 'should assign the attributes' do
          existing_candidate = FactoryGirl.create(:candidate,
            filename: 'existing_candidate', name: 'Existing Candidate'
          )
          form = Wayground::Democracy::CandidateForm.new
          form.ballot = ballot
          form.candidate = existing_candidate
          form.attributes = default_attrs.merge('filename' => 'with_candidate', 'name' => 'With Candidate')
          form.save
          existing_candidate.reload
          expect( existing_candidate.name ).to eq 'With Candidate'
        end
      end
    end
    context 'with invalid parameters set' do
      it 'should return false' do
        new_candidate = Candidate.new
        form = Wayground::Democracy::CandidateForm.new
        form.candidate = new_candidate
        expect( form.save ).to be_falsey
      end
    end
  end

end
