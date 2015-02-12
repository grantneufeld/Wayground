require 'spec_helper'

describe RoutesHelper, type: :helper do
  describe ".calendar_day_path_for_date" do
    it "should make a calendar url using the full date" do
      date = Date.parse '2012-03-04'
      expect(helper.calendar_day_path_for_date(date)).to eq "/calendar/2012/03/04"
    end
  end
end
