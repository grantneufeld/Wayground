require 'spec_helper'

describe Path, type: :model do
  describe "validation" do
    describe "of sitepath" do
      it "should reject an empty sitepath" do
        path = Path.new(:sitepath => '', :redirect => '/')
        path.valid?.should be_false
      end
      it "should reject multiple periods" do
        path = Path.new(:sitepath => '/file.name.etc', :redirect => '/')
        path.valid?.should be_false
      end
      it "should reject spaces" do
        path = Path.new(:sitepath => '/file name', :redirect => '/')
        path.valid?.should be_false
      end
      it "should accept a single slash" do
        path = Path.new(:sitepath => '/', :redirect => '/home')
        path.valid?.should be_true
      end
      it "should accept letters, numbers, dashes, percentage signs, underscores and slashes" do
        path = Path.new(:sitepath => '/AZaz/09-%_', :redirect => '/')
        path.valid?.should be_true
      end
      it "should accept a file extension" do
        path = Path.new(:sitepath => '/file.extension', :redirect => '/')
        path.valid?.should be_true
      end
      it "should reject a duplicate sitepath" do
        FactoryGirl.create(:path, :sitepath => '/duplciate', :redirect => '/')
        path = Path.new(:sitepath => '/duplciate', :redirect => '/dupe')
        path.valid?.should be_false
      end
    end
    describe "of redirect" do
      it "should be required if Path has no item" do
        path = Path.new(:sitepath => '/', :redirect => '')
        path.valid?.should be_false
      end
      it "should allow an http url" do
        path = Path.new(:sitepath => '/', :redirect => 'http://host.tld/')
        path.valid?.should be_true
      end
      it "should allow an https url" do
        path = Path.new(:sitepath => '/', :redirect => 'https://host.tld/')
        path.valid?.should be_true
      end
      it "should reject other urls" do
        path = Path.new(:sitepath => '/', :redirect => 'ftp://host.tld/')
        path.valid?.should be_false
      end
      it "should allow paths relative to root" do
        path = Path.new(:sitepath => '/', :redirect => '/redirect')
        path.valid?.should be_true
      end
    end
  end

  describe "scope" do
    context ":for_sitepath" do
      before(:all) do
        Path.delete_all
        @path = FactoryGirl.create(:path, :sitepath => '/valid_sitepath', :redirect => '/')
      end
      it "should return nil when no matching Path" do
        Path.for_sitepath('/non-existant').should eq []
      end
      it "should return the Path when the sitepath matches" do
        Path.for_sitepath('/valid_sitepath').should eq [@path]
      end
      it "should return the Path when the sitepath to search for has an extra trailing slash" do
        Path.for_sitepath('/valid_sitepath/').should eq [@path]
      end
    end
    context ":home" do
      it "should return nil when no home path record exists" do
        Path.home.should be_nil
      end
      it "should return the home Path" do
        home = FactoryGirl.create(:path, :sitepath => '/', :redirect => '/home')
        Path.home.should eq home
      end
    end
    context ":for_user" do
      before(:all) do
        User.delete_all
        Page.delete_all
        Path.delete_all
        Authority.delete_all
        @admin = FactoryGirl.create(:user)
        @admin.make_admin!
        @user = FactoryGirl.create(:user)
        @admin_path = FactoryGirl.create(:page, filename: 'admin', is_authority_controlled: true).path
        @controlled_path = FactoryGirl.create(:page,
          filename: 'controlled', is_authority_controlled: true
        ).path
        @user.set_authority_on_item(@controlled_path.item)
        @public_path = FactoryGirl.create(:redirect_path, sitepath: '/public')
        @user_path = FactoryGirl.create(:page,
          filename: 'user', is_authority_controlled: true, editor: @user
        ).path
        @user.set_authority_on_item(@user_path.item)
      end
      it "should find everything for admins" do
        Path.for_user(@admin).order(:sitepath).should eq [
          @admin_path, @controlled_path, @public_path, @user_path
        ]
      end
      it "should exclude paths the user doesn’t have authority to view" do
        Path.for_user(@user).order(:sitepath).should eq [@controlled_path, @public_path, @user_path]
      end
      it "should exclude all authority controlled paths for anonymous users" do
        Path.for_user(nil).order(:sitepath).should eq [@public_path]
      end
      it "should return a subset of all possible results when limit set" do
        Path.for_user(@admin).order(:sitepath).limit(2).offset(1).should eq [@controlled_path,@public_path]
      end
    end
  end

  describe ".find_for_path" do
    before(:all) do
      Path.delete_all
      @path = FactoryGirl.create(:path, :sitepath => '/valid_sitepath', :redirect => '/')
    end
    it "should return nil if no matching path" do
      Path.find_for_path('/non-existant').should be_nil
    end
    it "should return the Path for a given sitepath" do
      Path.find_for_path('/valid_sitepath').should eq @path
    end
    it "should return the Path that matches the sitepath plus a leading slash" do
      Path.find_for_path('valid_sitepath').should eq @path
    end
  end

  describe "#clean_sitepath" do
    it "should leave a sitepath with no trailing slash alone" do
      path = Path.new(:sitepath => '/no-trailing', :redirect => '/')
      path.clean_sitepath
      path.sitepath.should eq '/no-trailing'
    end
    it "should ignore the root sitepath" do
      path = Path.new(:sitepath => '/', :redirect => '/redirect')
      path.clean_sitepath
      path.sitepath.should eq '/'
    end
    it "should strip a trailing slash from sitepath" do
      path = Path.new(:sitepath => '/trailing/', :redirect => '/')
      path.clean_sitepath
      path.sitepath.should eq '/trailing'
    end
    it "should filter the sitepath before validating the Path" do
      path = Path.new(:sitepath => '/trailing/', :redirect => '/')
      path.valid?
      path.sitepath.should eq '/trailing'
    end
  end

end
