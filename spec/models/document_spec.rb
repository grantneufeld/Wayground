# encoding: utf-8
require 'spec_helper'

describe Document do
  before(:all) do
    @sample_file = File.new("#{Rails.root}/spec/fixtures/files/sample.txt")
  end
  describe "validation" do
    # the "of filename" stuff here is a direct copy from page_spec.rb
    # TODO: make a generic set of filename validation specs that can be included into specs like this
    describe "of filename" do
      it "should allow the filename to be a single slash for the root path" do
        document = Document.new(:custom_filename => '/')
        document.content_type = 'text/plain'
        document.data = ''
        document.valid?.should be_true
      end
      it "should not allow slashes in the filename, except for the root path" do
        document = Document.new(:custom_filename => '/filename')
        document.content_type = 'text/plain'
        document.data = ''
        document.valid?.should be_false
      end
      it "should not allow leading periods in the filename" do
        document = Document.new(:custom_filename => '.filename')
        document.content_type = 'text/plain'
        document.data = ''
        document.valid?.should be_false
      end
      it "should not allow trailing periods in the filename" do
        document = Document.new(:custom_filename => 'filename.')
        document.content_type = 'text/plain'
        document.data = ''
        document.valid?.should be_false
      end
      it "should not allow series of periods in the filename" do
        document = Document.new(:custom_filename => 'file..name')
        document.content_type = 'text/plain'
        document.data = ''
        document.valid?.should be_false
      end
      it "should not allow high-byte characters in the filename" do
        document = Document.new(:custom_filename => 'ƒilename')
        document.content_type = 'text/plain'
        document.data = ''
        document.valid?.should be_false
      end
      it "should not allow ampersands in the filename" do
        document = Document.new(:custom_filename => 'file&name')
        document.content_type = 'text/plain'
        document.data = ''
        document.valid?.should be_false
      end
      it "should not allow spaces in the filename" do
        document = Document.new(:custom_filename => 'file name')
        document.content_type = 'text/plain'
        document.data = ''
        document.valid?.should be_false
      end
      it "should not allow the filename to exceed 127 characters" do
        document = Document.new(:custom_filename => 'a' * 128)
        document.content_type = 'text/plain'
        document.data = ''
        document.valid?.should be_false
      end
      it "should allow the filename to reach 127 characters" do
        document = Document.new(:custom_filename => 'a' * 127)
        document.content_type = 'text/plain'
        document.data = ''
        document.valid?.should be_true
      end
      it "should allow letters, numbers, dashes, underscores and a file extension in the filename" do
        document = Document.new(:custom_filename => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-abcdefghijklmnopqrstuvwxyz_01234567.89')
        document.content_type = 'text/plain'
        document.data = ''
        document.valid?.should be_true
      end
    end
    describe "of content_type" do
      it "should not allow a blank content_type" do
        document = Document.new(:custom_filename => 'a')
        document.content_type = ''
        document.data = ''
        document.valid?.should be_false
      end
      it "should not allow an invalid content_type" do
        document = Document.new(:custom_filename => 'a')
        document.content_type = 'invalid'
        document.data = ''
        document.valid?.should be_false
      end
    end
    describe "of data" do
      it "should require data to be set" do
        document = Document.new(:custom_filename => 'a')
        document.content_type = 'text/plain'
        document.valid?.should be_false
      end
      it "should allow data to be empty" do
        document = Document.new(:custom_filename => 'a')
        document.content_type = 'text/plain'
        document.data = ''
        document.valid?.should be_true
      end
    end
  end

  describe "#determine_size" do
    it "should set the size to the size of the data" do
      document = Document.new()
      document.data = 'a' * 10
      document.determine_size
      document.size.should eq 10
    end
    it "should set the size to zero if no data" do
      document = Document.new()
      document.determine_size
      document.size.should eq 0
    end
  end

  describe "#generate_path" do
    it "should be called when the Document is saved" do
      container = Factory.create(:page).path
      document = Document.new(:custom_filename => 'document')
      document.content_type = 'text/plain'
      document.data = ''
      document.container_path = container
      document.save!
      document.path.should_not be_nil
    end
  end

  describe "#update_path" do
    before(:all) do
      @container = Factory.create(:page, :filename => 'container').path
    end
    it "should destroy the path if the Document’s container_path is removed" do
      document = Document.new(:custom_filename => 'original')
      document.content_type = 'text/plain'
      document.data = ''
      document.container_path = @container
      document.save!
      document.container_path = nil
      document.update_path
      document.path.should be_nil
    end
    it "should make no change to the path if the Document’s filename and container did not change" do
      document = Document.new(:custom_filename => 'original')
      document.content_type = 'text/plain'
      document.data = ''
      document.container_path = @container
      document.save!
      document.update_attributes!(:description => 'Not changing the filename.')
      document.sitepath.should eq '/container/original'
    end
    it "should update the path if the Document’s filename changed" do
      document = Document.new(:custom_filename => 'original')
      document.content_type = 'text/plain'
      document.data = ''
      document.container_path = @container
      document.save!
      document.update_attributes!(:custom_filename => 'changed')
      document.sitepath.should eq '/container/changed'
    end
    it "should add a path if a container_path is added" do
      document = Factory.create(:document, :filename => 'original')
      document.container_path = @container
      document.update_path
      document.sitepath.should eq '/container/original'
    end
  end

  describe "#calculate_sitepath" do
    it "should return nil if no container" do
      document = Document.new(:custom_filename => 'document')
      document.content_type = 'text/plain'
      document.calculate_sitepath.should be_nil
    end
    it "should have be the container’s sitepath plus a slash and the filename" do
      container = Factory.create(:page, :filename => 'contain').path
      document = Document.new(:custom_filename => 'document.txt')
      document.content_type = 'text/plain'
      document.container_path = container
      document.calculate_sitepath.should eq '/contain/document.txt'
    end
  end

  describe "#sitepath" do
    it "should return nil when the Document does not have a container_path" do
      document = Factory.create(:document)
      document.sitepath.should be_nil
    end
    it "should be the path’s sitepath" do
      document = Document.new(:custom_filename => 'testdoc')
      document.content_type = 'text/plain'
      document.data = ''
      document.container_path = Factory.create(:page, :filename => 'container').path
      document.save!
      document.sitepath.should eq '/container/testdoc'
    end
  end

  describe "#file=" do
    it "should do nothing if not supplied with a File or UploadedFile" do
    end
    it "should not modify the filename if already set" do
    end
    it "should set the filename from the file if not already set" do
    end
    it "should not modify the content_type if already set" do
    end
    it "should set the content_type from the file if not already set" do
    end
    it "should set the data from the file" do
    end
  end

  describe "#cleanup_filename" do
    it "should really be a more efficient method from a library or something" do
    end
  end

  describe "#custom_filename=" do
    it "should not change the filename if the supplied value is blank" do
    end
    it "should update the filename" do
    end
  end

  describe "#custom_filename" do
    it "should always return nil" do
      Document.new.custom_filename.should be_nil
    end
  end

  describe "#assign_headers" do
    before(:all) do
      @create = Time.new(2009,6,7,8,9,10,0).getutc
      @update = Time.new(2011,1,2,3,4,5,0).getutc
    end
    it "should set the Last-Modified" do
      response = ActionDispatch::Response.new
      document = Document.new
      document.created_at = @create
      document.updated_at = @update
      document.assign_headers(response)
      response['Last-Modified'].should eq @update.to_s(:http_header)
    end
    it "should set the Last-Modified if updated_at not set" do
      response = ActionDispatch::Response.new
      document = Document.new
      document.created_at = @create
      document.assign_headers(response)
      response['Last-Modified'].should eq @create.to_s(:http_header)
    end
    it "should set the Cache-Control for privacy when document is authority controlled" do
      response = ActionDispatch::Response.new
      document = Document.new
      document.updated_at = @update
      document.is_authority_controlled = true
      document.assign_headers(response)
      response.cache_control[:public].should be_false
    end
    it "should set the Cache-Control for public access when document is not authority controlled" do
      response = ActionDispatch::Response.new
      document = Document.new
      document.updated_at = @update
      document.assign_headers(response)
      response.cache_control[:public].should be_true
    end
    it "should set the Content-Type" do
      response = ActionDispatch::Response.new
      document = Document.new
      document.updated_at = @update
      document.content_type = 'text/plain'
      document.assign_headers(response)
      response['Content-Type'].should eq 'text/plain'
    end
  end

end