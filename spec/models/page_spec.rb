require 'rails_helper'

describe Page, type: :model do
  before(:all) do
    @editor = FactoryGirl.create(:user)
  end

  describe "acts_as_authority_controlled" do
    it "should be in the “Content” area" do
      expect(Page.authority_area).to eq 'Content'
    end
  end

  describe "validation" do
    describe "of filename" do
      it "should allow the filename to be a single slash for the root path" do
        page = Page.new(:title => 'A', :filename => '/')
        expect(page.valid?).to be_truthy
      end
      it "should not allow slashes in the filename, except for the root path" do
        page = Page.new(:title => 'A', :filename => '/filename')
        expect(page.valid?).to be_falsey
      end
      it "should not allow leading periods in the filename" do
        page = Page.new(:title => 'A', :filename => '.filename')
        expect(page.valid?).to be_falsey
      end
      it "should not allow trailing periods in the filename" do
        page = Page.new(:title => 'A', :filename => 'filename.')
        expect(page.valid?).to be_falsey
      end
      it "should not allow series of periods in the filename" do
        page = Page.new(:title => 'A', :filename => 'file..name')
        expect(page.valid?).to be_falsey
      end
      it "should not allow high-byte characters in the filename" do
        page = Page.new(:title => 'A', :filename => 'ƒilename')
        expect(page.valid?).to be_falsey
      end
      it "should not allow ampersands in the filename" do
        page = Page.new(:title => 'A', :filename => 'file&name')
        expect(page.valid?).to be_falsey
      end
      it "should not allow spaces in the filename" do
        page = Page.new(:title => 'A', :filename => 'file name')
        expect(page.valid?).to be_falsey
      end
      #it "should not allow  in the filename" do
      #  page = Page.new(:filename => 'filename')
      #  expect(page.valid?).to be_falsey
      #end
      it "should not allow the filename to exceed 127 characters" do
        page = Page.new(:title => 'A', :filename => 'a' * 128)
        expect(page.valid?).to be_falsey
      end
      it "should allow the filename to reach 127 characters" do
        page = Page.new(:title => 'A', :filename => 'a' * 127)
        expect(page.valid?).to be_truthy
      end
      it "should allow letters, numbers, dashes, underscores and a file extension in the filename" do
        page = Page.new(:title => 'A',
          :filename => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-abcdefghijklmnopqrstuvwxyz_01234567.89'
        )
        expect(page.valid?).to be_truthy
      end
    end
    describe "of title" do
      it "should not allow a blank title" do
        page = Page.new(:title => '', :filename => 'a')
        expect(page.valid?).to be_falsey
      end
      it "should not allow a missing title" do
        page = Page.new(:filename => 'a')
        expect(page.valid?).to be_falsey
      end
    end
  end

  describe "#generate_path" do
    it "should be called after the Page is saved" do
      page = Page.new(:filename => 'page', :title => 'Page')
      page.editor = @editor
      page.save!
      expect(page.path).not_to be_nil
    end
  end

  describe "#update_path" do
    it "should make no change to the path if the Page’s filename did not change" do
      page = FactoryGirl.create(:page, :filename => 'original')
      page.update!(description: 'Not changing the filename.')
      expect(page.sitepath).to eq '/original'
    end
    it "should update the path if the Page’s filename changed" do
      page = FactoryGirl.create(:page, :filename => 'original')
      page.update!(filename: 'changed')
      expect(page.sitepath).to eq '/changed'
    end
    it "should create the path if the Page doesn’t have one" do
      page = FactoryGirl.create(:page, :filename => 'original')
      page.path.destroy
      page.path = nil
      page.filename = 'changed'
      page.update_path
      expect(page.sitepath).to eq '/changed'
    end
  end

  describe "#calculate_sitepath" do
    it "should just be the filename with a leading slash if no parent Page" do
      expect(Page.new(:filename => 'page', :title => 'Page').calculate_sitepath).to eq '/page'
    end
    it "should have be the parent’s sitepath plus a slash and the filename" do
      parent = FactoryGirl.create(:page, :filename => 'parent')
      page = Page.new(:filename => 'page', :title => 'Page')
      page.parent = parent
      expect(page.calculate_sitepath).to eq '/parent/page'
    end
    it "should just be a slash for the home Page" do
      expect(Page.new(:filename => '/', :title => 'Page').calculate_sitepath).to eq '/'
    end
  end

  describe "#breadcrumbs" do
    it "should be an empty array if no parent" do
      expect(Page.new.breadcrumbs).to eq []
    end
    it "should point to the parent, if there is one" do
      parent = FactoryGirl.create(:page, :filename => 'parent', :title => 'Parent')
      page = Page.new(:filename => 'page', :title => 'Page')
      page.parent = parent
      expect(page.breadcrumbs).to eq [{:text => 'Parent', :url => '/parent'}]
    end
    it "should point to the parents, if there is more than one in the parent chain" do
      grandparent = FactoryGirl.create(:page, :filename => 'grandparent', :title => 'Grandparent')
      parent = FactoryGirl.create(:page, :parent => grandparent, :filename => 'parent', :title => 'Parent')
      page = Page.new(:filename => 'page', :title => 'Page')
      page.parent = parent
      expect(page.breadcrumbs).to eq [
        {:text => 'Grandparent', :url => '/grandparent'},
        {:text => 'Parent', :url => '/grandparent/parent'}
      ]
    end
  end

  describe "#sitepath" do
    it "should be the path’s sitepath" do
      page = Page.new(:filename => 'testpage', :title => 'Page')
      page.editor = @editor
      page.save!
      expect(page.sitepath).to eq '/testpage'
    end
  end

end
