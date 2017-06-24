require 'feature_helper'

RSpec.feature 'FrontPageFeatures', type: :feature do
  # TODO: expect meta[name='viewport'] tag for appropriate scaling on small screens
  # TODO: expect #usermenu (and the appropriate options)
  # TODO: expect nav (and the appropriate links)
  context 'with no root page record' do
    scenario 'Access Front Page' do
      visit '/'
      expect(page).to have_tidy_html
    end
    # TODO: expect content to include new site installation instructions
  end
  context 'with a root page record' do
    scenario 'Access Front Page' do
      root_page = FactoryGirl.create(
        :page,
        filename: '/', title: 'Front Page Feature',
        description: 'Feature for the front page.', content: '<p>Feature test.</p>'
      )
      visit '/'
      expect(page).to have_tidy_html
      root_page.delete
    end
    # TODO: expect title text to eq meta[property='og:title'][content=?] to eq root_page.title
    # TODO: expect meta[name='description'][content=?] to eq root_page.description
    # TODO: expect the root_page.content to be present
  end
  context 'when logged in' do
  end
end
