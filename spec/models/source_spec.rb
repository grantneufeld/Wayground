require 'rails_helper'

describe Source, type: :model do
  before(:all) do
    Authority.delete_all
    User.delete_all
    # first user is automatically an admin
    @user_admin = FactoryGirl.create(:user, name: 'Admin User')
    @user_normal = FactoryGirl.create(:user, name: 'Normal User')
  end

  describe 'validation' do
    let(:minimum_valid_params) do
      $minimum_valid_params = { processor: 'iCalendar', url: 'http://test.tld/test.ics' }
    end
    it 'should pass with minimum valid parameters' do
      expect(Source.new(minimum_valid_params).valid?).to be_truthy
    end
    describe 'of processor' do
      it 'should fail if not set' do
        minimum_valid_params.delete :processor
        expect(Source.new(minimum_valid_params).valid?).to be_falsey
      end
      it 'should fail if set to an invalid value' do
        expect(Source.new(minimum_valid_params.merge(processor: 'invalid')).valid?).to be_falsey
      end
      it 'should pass if set to iCalendar' do
        source = Source.new(minimum_valid_params.merge(processor: 'iCalendar'))
        expect(source.valid?).to be_truthy
      end
    end
    describe 'of url' do
      it 'should fail if not set' do
        minimum_valid_params.delete :url
        expect(Source.new(minimum_valid_params).valid?).to be_falsey
      end
      it 'should fail if not a valid url format' do
        expect(Source.new(minimum_valid_params.merge(url: 'invalid url')).valid?).to be_falsey
      end
    end
    describe 'of method' do
      it 'should default to get' do
        source = Source.new(minimum_valid_params)
        expect(source.method).to eq 'get'
      end
      it 'should fail if invalid' do
        source = Source.new(minimum_valid_params.merge(method: 'invalid'))
        expect(source.valid?).to be_falsey
      end
      it 'should pass if set to get' do
        source = Source.new(minimum_valid_params.merge(method: 'get'))
        expect(source.valid?).to be_truthy
      end
      it 'should pass if set to post' do
        source = Source.new(minimum_valid_params.merge(method: 'post'))
        expect(source.valid?).to be_truthy
      end
    end
    describe 'of last_updated_at' do
      it 'should fail if greater than the current time' do
        source = Source.new(minimum_valid_params)
        source.last_updated_at = 1.minute.from_now
        expect(source.valid?).to be_falsey
      end
      it 'should pass if equal to the current time' do
        source = Source.new(minimum_valid_params)
        source.last_updated_at = Time.zone.now
        expect(source.valid?).to be_truthy
      end
    end
  end

  describe '#name' do
    it 'should return the title, if set' do
      expect(Source.new(title: 'The Title').name).to eq 'The Title'
    end
    it 'should return a Source & ID string if title is missing' do
      source = Source.new
      source.id = 123
      expect(source.name).to eq 'Source 123'
    end
  end

  describe '#run_processor' do
    it 'should do nothing when not a recognized processor' do
      expect(Source.new.run_processor).to be_nil
    end
    context 'with the iCalendar processor' do
      let(:source) do
        $source = FactoryGirl.create(
          :source, processor: 'iCalendar', url: "#{Rails.root}/spec/fixtures/files/sample.ics"
        )
      end
      it 'should run the process' do
        expect { source.run_processor(@user_normal) }.to change(Event, :count).by(2)
      end
      it 'should update the last_updated_at stamp' do
        source.last_updated_at = nil
        source.run_processor(@user_normal)
        expect(source.last_updated_at).to be
      end
    end
    context 'with the old, legacy, IcalProcessor value' do
      let(:source) do
        $source = FactoryGirl.create(
          :source, processor: 'IcalProcessor', url: "#{Rails.root}/spec/fixtures/files/sample.ics"
        )
      end
      it 'should run the process' do
        expect { source.run_processor(@user_normal) }.to change(Event, :count).by(2)
      end
    end
  end
end
