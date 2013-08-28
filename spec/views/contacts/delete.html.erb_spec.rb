# encoding: utf-8
require 'spec_helper'
require 'person'

describe "contacts/delete.html.erb" do
  let(:person) { $person = Person.new(filename: 'prsn') }
  let(:contact) { $contact = person.contacts.build(name: 'Delete me.') }

  before(:each) do
    assign(:item, person)
    contact.stub(:to_param).and_return('123')
    assign(:contact, contact)
    render
  end

  it "should render the deletion form" do
    assert_select 'form', action: '/person/prsn/contacts/123', method: 'delete' do
      assert_select 'input', type: 'submit', value: 'Delete Contact'
    end
  end

end
