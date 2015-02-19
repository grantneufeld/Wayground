require 'rails_helper'

describe Document, type: :model do
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
        expect(document.valid?).to be_truthy
      end
      it "should not allow slashes in the filename, except for the root path" do
        document = Document.new(:custom_filename => '/filename')
        document.content_type = 'text/plain'
        document.data = ''
        expect(document.valid?).to be_falsey
      end
      it "should not allow leading periods in the filename" do
        document = Document.new(:custom_filename => '.filename')
        document.content_type = 'text/plain'
        document.data = ''
        expect(document.valid?).to be_falsey
      end
      it "should not allow trailing periods in the filename" do
        document = Document.new(:custom_filename => 'filename.')
        document.content_type = 'text/plain'
        document.data = ''
        expect(document.valid?).to be_falsey
      end
      it "should not allow series of periods in the filename" do
        document = Document.new(:custom_filename => 'file..name')
        document.content_type = 'text/plain'
        document.data = ''
        expect(document.valid?).to be_falsey
      end
      it "should not allow high-byte characters in the filename" do
        document = Document.new(:custom_filename => 'ƒilename')
        document.content_type = 'text/plain'
        document.data = ''
        expect(document.valid?).to be_falsey
      end
      it "should not allow ampersands in the filename" do
        document = Document.new(:custom_filename => 'file&name')
        document.content_type = 'text/plain'
        document.data = ''
        expect(document.valid?).to be_falsey
      end
      it "should not allow spaces in the filename" do
        document = Document.new(:custom_filename => 'file name')
        document.content_type = 'text/plain'
        document.data = ''
        expect(document.valid?).to be_falsey
      end
      it "should not allow the filename to exceed 127 characters" do
        document = Document.new(:custom_filename => 'a' * 128)
        document.content_type = 'text/plain'
        document.data = ''
        expect(document.valid?).to be_falsey
      end
      it "should allow the filename to reach 127 characters" do
        document = Document.new(:custom_filename => 'a' * 127)
        document.content_type = 'text/plain'
        document.data = ''
        expect(document.valid?).to be_truthy
      end
      it "should allow letters, numbers, dashes, underscores and a file extension in the filename" do
        document = Document.new(
          custom_filename: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ-abcdefghijklmnopqrstuvwxyz_01234567.89'
        )
        document.content_type = 'text/plain'
        document.data = ''
        expect(document.valid?).to be_truthy
      end
    end
    describe "of content_type" do
      it "should not allow a blank content_type" do
        document = Document.new(:custom_filename => 'a')
        document.content_type = ''
        document.data = ''
        expect(document.valid?).to be_falsey
      end
      it "should not allow an invalid content_type" do
        document = Document.new(:custom_filename => 'a')
        document.content_type = 'invalid'
        document.data = ''
        expect(document.valid?).to be_falsey
      end
    end
    describe "of data" do
      it "should require data to be set" do
        document = Document.new(:custom_filename => 'a')
        document.content_type = 'text/plain'
        expect(document.valid?).to be_falsey
      end
      it "should allow data to be empty" do
        document = Document.new(:custom_filename => 'a')
        document.content_type = 'text/plain'
        document.data = ''
        expect(document.valid?).to be_truthy
      end
    end
  end

  describe ".for_user" do
    before(:all) do
      User.delete_all
      Document.delete_all
      Authority.delete_all
      @admin = FactoryGirl.create(:user)
      @admin.make_admin!
      @user = FactoryGirl.create(:user)
      @admin_doc = FactoryGirl.create(:document, filename: 'admin', is_authority_controlled: true)
      @controlled_doc = FactoryGirl.create(:document, filename: 'controlled', is_authority_controlled: true)
      @user.set_authority_on_item(@controlled_doc)
      @public_doc = FactoryGirl.create(:document, filename: 'public')
      @user_doc = FactoryGirl.create(:document, filename: 'user', is_authority_controlled: true, user: @user)
    end
    it "should find everything for admins" do
      expect(Document.for_user(@admin).order(:filename)).to eq [
        @admin_doc, @controlled_doc, @public_doc, @user_doc
      ]
    end
    it "should exclude documents the user doesn’t have authority to view" do
      expect(Document.for_user(@user).order(:filename)).to eq [@controlled_doc, @public_doc, @user_doc]
    end
    it "should exclude all authority controlled documents for anonymous users" do
      expect(Document.for_user(nil).order(:filename)).to eq [@public_doc]
    end
    it "should return a subset of all possible results when limit set" do
      expect(Document.for_user(@admin).order(:filename).limit(2).offset(1)).to eq [@controlled_doc,@public_doc]
    end
  end

  describe "#determine_size" do
    it "should set the size to the size of the data" do
      document = Document.new()
      document.data = 'a' * 10
      document.determine_size
      expect(document.size).to eq 10
    end
    it "should set the size to zero if no data" do
      document = Document.new()
      document.determine_size
      expect(document.size).to eq 0
    end
  end

  describe "#generate_path" do
    it "should be called when the Document is saved" do
      container = FactoryGirl.create(:page).path
      document = Document.new(:custom_filename => 'document')
      document.content_type = 'text/plain'
      document.data = ''
      document.container_path = container
      document.save!
      expect(document.path).not_to be_nil
    end
  end

  describe "#update_path" do
    before(:all) do
      @container = FactoryGirl.create(:page, :filename => 'container').path
    end
    it "should destroy the path if the Document’s container_path is removed" do
      document = Document.new(:custom_filename => 'original')
      document.content_type = 'text/plain'
      document.data = ''
      document.container_path = @container
      document.save!
      document.container_path = nil
      document.update_path
      expect(document.path).to be_nil
    end
    it "should make no change to the path if the Document’s filename and container did not change" do
      document = Document.new(:custom_filename => 'original')
      document.content_type = 'text/plain'
      document.data = ''
      document.container_path = @container
      document.save!
      document.update!(description: 'Not changing the filename.')
      expect(document.sitepath).to eq '/container/original'
    end
    it "should update the path if the Document’s filename changed" do
      document = Document.new(:custom_filename => 'original')
      document.content_type = 'text/plain'
      document.data = ''
      document.container_path = @container
      document.save!
      document.update!(custom_filename: 'changed')
      expect(document.sitepath).to eq '/container/changed'
    end
    it "should add a path if a container_path is added" do
      document = FactoryGirl.create(:document, :filename => 'original')
      document.container_path = @container
      document.update_path
      expect(document.sitepath).to eq '/container/original'
    end
  end

  describe "#calculate_sitepath" do
    it "should return nil if no container" do
      document = Document.new(:custom_filename => 'document')
      document.content_type = 'text/plain'
      expect(document.calculate_sitepath).to be_nil
    end
    it "should have be the container’s sitepath plus a slash and the filename" do
      container = FactoryGirl.create(:page, :filename => 'contain').path
      document = Document.new(:custom_filename => 'document.txt')
      document.content_type = 'text/plain'
      document.container_path = container
      expect(document.calculate_sitepath).to eq '/contain/document.txt'
    end
  end

  describe "#sitepath" do
    it "should return nil when the Document does not have a container_path" do
      document = FactoryGirl.create(:document)
      expect(document.sitepath).to be_nil
    end
    it "should be the path’s sitepath" do
      document = Document.new(:custom_filename => 'testdoc')
      document.content_type = 'text/plain'
      document.data = ''
      document.container_path = FactoryGirl.create(:page, :filename => 'container').path
      document.save!
      expect(document.sitepath).to eq '/container/testdoc'
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
    it "should convert runs of spaces to single underscores" do
      doc = Document.new
      doc.filename = '    test    with lots  of    spaces '
      doc.cleanup_filename
      expect(doc.filename).to eq '_test_with_lots_of_spaces_'
    end
    it "should convert em and en dashes to simple dashes" do
      doc = Document.new
      doc.filename = '–en—em-plain'
      doc.cleanup_filename
      expect(doc.filename).to eq '-en-em-plain'
    end
    it "should convert accented characters" do
      doc = Document.new
      doc.filename = "ªáÁàÀâÂåÅäÄãÃèéëêÈÉËÊìíïîÌÍÏÎòóöôõÒÓÖÔÕøØºùúüûÙÚÛµæÆœŒç¢ƒﬁﬂñÑ"
      doc.cleanup_filename
      expect(doc.filename).to eq 'aaaaaaaaaaaaaeeeeeeeeiiiiiiiiooooooooooooouuuuuuuuaeaeoeoeccffiflnn'
    end
    it "should strip forbidden characters" do
      doc = Document.new
      doc.filename = "`=¡™£∞§¶•≠`⁄€‹›‡·‚±∑´®†¥¨ˆπ“‘«„´‰ˇ¨ˆ∏”’»ß∂©˙∆˚¬…˝Ω≈√∫˜≤≥÷¸˛Ç◊ı˜¯˘¿"
      doc.cleanup_filename
      expect(doc.filename).to eq ''
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
      expect(Document.new.custom_filename).to be_nil
    end
  end

  context "#data" do
    it "should return the document’s Datastore.data" do
      doc = Document.new
      doc.datastore = Datastore.new(:data => 'abc')
      expect(doc.data).to eq('abc')
    end
    it "should return nil if the document does not have a Datastore yet" do
      expect(Document.new.data).to be_nil
    end
  end
  context "#data=" do
    it "should create a Datastore for the document if none yet" do
      doc = Document.new
      doc.data = 'abc'
      expect(doc.datastore.data).to eq('abc')
    end
    it "should update the document’s Datastore" do
      doc = Document.new
      datastore = Datastore.new(:data => 'abc')
      doc.datastore = datastore
      doc.data = 'def'
      expect(datastore.data).to eq 'def'
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
      expect(response['Last-Modified']).to eq @update.to_s(:http_header)
    end
    it "should set the Last-Modified if updated_at not set" do
      response = ActionDispatch::Response.new
      document = Document.new
      document.created_at = @create
      document.assign_headers(response)
      expect(response['Last-Modified']).to eq @create.to_s(:http_header)
    end
    it "should set the Cache-Control for privacy when document is authority controlled" do
      response = ActionDispatch::Response.new
      document = Document.new
      document.updated_at = @update
      document.is_authority_controlled = true
      document.assign_headers(response)
      expect(response.cache_control[:public]).to be_falsey
    end
    it "should set the Cache-Control for public access when document is not authority controlled" do
      response = ActionDispatch::Response.new
      document = Document.new
      document.updated_at = @update
      document.assign_headers(response)
      expect(response.cache_control[:public]).to be_truthy
    end
    it "should set the Content-Type" do
      response = ActionDispatch::Response.new
      document = Document.new
      document.updated_at = @update
      document.content_type = 'text/plain'
      document.assign_headers(response)
      expect(response['Content-Type']).to eq 'text/plain'
    end
  end

end
