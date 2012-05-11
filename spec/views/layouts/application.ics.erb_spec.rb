# encoding: utf-8
require 'spec_helper'

describe "layouts/application.ics.erb" do
  it "should render a standard icalendar header" do
    render
    rendered.should match(/\ABEGIN:VCALENDAR(\r\n?|\n)VERSION:2\.0(\r\n?|\n)PRODID:-\/\/.+$/)
  end
  it "should render a standard icalendar footer" do
    render
    rendered.should match(/^END:VCALENDAR[\r\n]*\z/)
  end
end
