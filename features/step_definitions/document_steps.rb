# encoding: utf-8

Given /^a document "([^\"]*)"$/ do |filename|
  Factory.create(:document, :filename => filename)
end

Given /^a document "([^\"]*)" requiring access authority$/ do |filename|
  Factory.create(:document, :filename => filename, :is_authority_controlled => true)
end

Given /^there is no document "([^\"]*)" in the system$/ do |filename|
  docs = Document.where(:filename => filename)
  return if docs.nil?
  docs.each do |doc|
    doc.delete
  end
end

Given /^I have uploaded a document "([^\"]*)"$/ do |filename|
  Given %{I am authorized to upload documents}
  When %{I upload a document "#{filename}"}
end

# IMPORTANT: filename must be a file in spec/fixtures/files
When /^I upload a document "([^\"]*)"$/ do |filename|
  raise 'invalid filename' if filename.match(/^(\.|.*\/)/)
  visit new_document_url
  attach_file('File', "#{Rails.root}/spec/fixtures/files/#{filename}")
  click_on 'Save Document'
end

When /^I edit the document "([^\"]*)"$/ do |filename|
  visit edit_document_url(Document.where(:filename => filename).first)
end

When /^I save the document$/ do
  click_on 'Save Document'
end

When /^I delete the document "([^\"]*)"$/ do |filename|
  doc = Document.where(:filename => filename).first
  visit delete_document_url(doc)
  click_on 'Delete Document'
end

Then /^there should be a document "([^\"]*)"(?:| in the system)$/ do |filename|
  Document.where(:filename => filename).first.should_not be_nil
end

Then /^there should not be a document "([^\"]*)"(?:| in the system)$/ do |filename|
  Document.where(:filename => filename).first.should be_nil
end

Then /^I should be able to download the document file "([^\"]*)"$/ do |filename|
  doc = Document.where(:filename => filename).first
  visit "/download/#{doc.id}/#{filename}"
  page.source.should eq 'data'
  page.response_headers['Content-Type'].should match /^text\/plain/
end

Then /^I should not be able to download the document file "([^\"]*)"$/ do |filename|
  doc = Document.where(:filename => filename).first
  visit "/download/#{doc.id}/#{filename}"
  page.status_code.should eq 403
end

Then /^the document "([^\"]*)" should have the description "([^\"]*)"$/ do |filename, description|
  Document.where(:filename => filename).first.description.should eq description
end
