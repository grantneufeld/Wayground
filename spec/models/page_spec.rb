# encoding: utf-8
require 'spec_helper'

describe Page do
  before(:all) do
    @editor = FactoryGirl.create(:user)
  end

  describe "acts_as_authority_controlled" do
    it "should be in the “Content” area" do
      Page.authority_area.should eq 'Content'
    end
  end

  describe "validation" do
    describe "of filename" do
      it "should allow the filename to be a single slash for the root path" do
        page = Page.new(:title => 'A', :filename => '/')
        page.valid?.should be_true
      end
      it "should not allow slashes in the filename, except for the root path" do
        page = Page.new(:title => 'A', :filename => '/filename')
        page.valid?.should be_false
      end
      it "should not allow leading periods in the filename" do
        page = Page.new(:title => 'A', :filename => '.filename')
        page.valid?.should be_false
      end
      it "should not allow trailing periods in the filename" do
        page = Page.new(:title => 'A', :filename => 'filename.')
        page.valid?.should be_false
      end
      it "should not allow series of periods in the filename" do
        page = Page.new(:title => 'A', :filename => 'file..name')
        page.valid?.should be_false
      end
      it "should not allow high-byte characters in the filename" do
        page = Page.new(:title => 'A', :filename => 'ƒilename')
        page.valid?.should be_false
      end
      it "should not allow ampersands in the filename" do
        page = Page.new(:title => 'A', :filename => 'file&name')
        page.valid?.should be_false
      end
      it "should not allow spaces in the filename" do
        page = Page.new(:title => 'A', :filename => 'file name')
        page.valid?.should be_false
      end
      #it "should not allow  in the filename" do
      #  page = Page.new(:filename => 'filename')
      #  page.valid?.should be_false
      #end
      it "should not allow the filename to exceed 127 characters" do
        page = Page.new(:title => 'A', :filename => 'a' * 128)
        page.valid?.should be_false
      end
      it "should allow the filename to reach 127 characters" do
        page = Page.new(:title => 'A', :filename => 'a' * 127)
        page.valid?.should be_true
      end
      it "should allow letters, numbers, dashes, underscores and a file extension in the filename" do
        page = Page.new(:title => 'A',
          :filename => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-abcdefghijklmnopqrstuvwxyz_01234567.89'
        )
        page.valid?.should be_true
      end
    end
    describe "of title" do
      it "should not allow a blank title" do
        page = Page.new(:title => '', :filename => 'a')
        page.valid?.should be_false
      end
      it "should not allow a missing title" do
        page = Page.new(:filename => 'a')
        page.valid?.should be_false
      end
    end
  end

  describe "#generate_path" do
    it "should be called after the Page is saved" do
      page = Page.new(:filename => 'page', :title => 'Page')
      page.editor = @editor
      page.save!
      page.path.should_not be_nil
    end
  end

  describe "#update_path" do
    it "should make no change to the path if the Page’s filename did not change" do
      page = FactoryGirl.create(:page, :filename => 'original')
      page.update_attributes!(:description => 'Not changing the filename.')
      page.sitepath.should eq '/original'
    end
    it "should update the path if the Page’s filename changed" do
      page = FactoryGirl.create(:page, :filename => 'original')
      page.update_attributes!(:filename => 'changed')
      page.sitepath.should eq '/changed'
    end
    it "should create the path if the Page doesn’t have one" do
      page = FactoryGirl.create(:page, :filename => 'original')
      page.path.destroy
      page.path = nil
      page.filename = 'changed'
      page.update_path
      page.sitepath.should eq '/changed'
    end
  end

  describe "#calculate_sitepath" do
    it "should just be the filename with a leading slash if no parent Page" do
      Page.new(:filename => 'page', :title => 'Page').calculate_sitepath.should eq '/page'
    end
    it "should have be the parent’s sitepath plus a slash and the filename" do
      parent = FactoryGirl.create(:page, :filename => 'parent')
      page = Page.new(:filename => 'page', :title => 'Page')
      page.parent = parent
      page.calculate_sitepath.should eq '/parent/page'
    end
    it "should just be a slash for the home Page" do
      Page.new(:filename => '/', :title => 'Page').calculate_sitepath.should eq '/'
    end
  end

  describe "#breadcrumbs" do
    it "should be an empty array if no parent" do
      Page.new.breadcrumbs.should eq []
    end
    it "should point to the parent, if there is one" do
      parent = FactoryGirl.create(:page, :filename => 'parent', :title => 'Parent')
      page = Page.new(:filename => 'page', :title => 'Page')
      page.parent = parent
      page.breadcrumbs.should eq [{:text => 'Parent', :url => '/parent'}]
    end
    it "should point to the parents, if there is more than one in the parent chain" do
      grandparent = FactoryGirl.create(:page, :filename => 'grandparent', :title => 'Grandparent')
      parent = FactoryGirl.create(:page, :parent => grandparent, :filename => 'parent', :title => 'Parent')
      page = Page.new(:filename => 'page', :title => 'Page')
      page.parent = parent
      page.breadcrumbs.should eq [
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
      page.sitepath.should eq '/testpage'
    end
  end

end
