require 'rails_helper'

describe 'layouts/application.ics.erb', type: :view do
  it 'should render a standard icalendar header' do
    render template: 'layouts/application.ics.erb'
    expect(rendered).to match(%r{\ABEGIN:VCALENDAR(\r\n?|\n)VERSION:2\.0(\r\n?|\n)PRODID:-//.+$})
  end
  it 'should render a standard icalendar footer' do
    render template: 'layouts/application.ics.erb'
    expect(rendered).to match(/^END:VCALENDAR[\r\n]*\z/)
  end
end
