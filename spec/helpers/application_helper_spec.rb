require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the ApplicationHelper. For example:
#	describe ApplicationHelper do
#		describe "string concat" do
#			it "concats two strings with spaces" do
#				helper.concat_strings("this","that").should == "this that"
#			end
#		end
#	end
describe ApplicationHelper do
	describe "#show_errors" do
		it "displays errors (ActiveRecord-style) from an object" do
			item = User.new({:email => 'invalid'})
			item.valid?
			helper.show_errors(item).should match /[0-9]+ errors? prevented this User from being saved:/i
		end
	end

  ## Generate the pagination header, telling the user where they are in the pagination.
  ## item_plural: The pluralized name of the type of item (e.g., “documents”).
  #def show_pagination_header(item_plural = nil)
  #  render :partial => 'layouts/pagination_header', :locals => {:item_plural => item_plural}
  #end
  context "#show_pagination_header" do
    it "renders the pagination header partial" do
      @source_total = 42
      @selected_total = 10
      helper.show_pagination_header('tests').should match /Showing 10 of 42 tests\./
    end
  end

  ## Generate the pagination selector (links to numbered pages), if there is more than one page.
  #def show_pagination_selector
  #  render :partial => 'layouts/pagination_selector'
  #end
  context "#show_pagination_selector" do
    it "renders the pagination selector partial" do
      @max = 10
      @page = 3
      @offset = 20
      @default_max = 20
      @source_total = 42
      @selected_total = 10
      helper.show_pagination_selector.should match /<p class="pagination">Pages:\s*<a [^>]+>First<\/a>\s*<a [^>]+>1<\/a>\s*<a [^>]+>2<\/a>\s*<a [^>]+>3<\/a>\s*<a [^>]+>4<\/a>\s*<a [^>]+>5<\/a>\s*<a [^>]+>Last<\/a>\s*<\/p>/
    end
  end

end
