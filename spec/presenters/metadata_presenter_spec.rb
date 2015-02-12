require 'spec_helper'
require 'metadata_presenter'
require 'image_variant'
require 'image'

describe MetadataPresenter do

  let(:path) { $path = '/test' }
  let(:url) { $url = "http://test.tld#{path}" }

  def view_stub
    view = double('View')
    view.stub_chain(:request, :path).and_return(path)
    #allow(view).to receive_message_chain(:request, :path) { path }
    view.stub_chain(:request, :url).and_return(url)
    #allow(view).to receive_message_chain(:request, :url) { url }
    view
  end

  describe "initialization" do
    it "should take a view parameter" do
      view = view_stub
      presenter = MetadataPresenter.new(view: view)
      expect( presenter.view ).to eq view
    end
    context "with an url param" do
      it "should take an url parameter" do
        presenter = MetadataPresenter.new(view: view_stub, url: 'http://param.tld/')
        expect( presenter.url ).to eq 'http://param.tld/'
      end
    end
    context "with no url param" do
      let(:url) { $url = 'http://request.tld/' }
      it "should use the request url" do
        presenter = MetadataPresenter.new(view: view_stub)
        expect( presenter.url ).to eq 'http://request.tld/'
      end
    end
    it "should take a title parameter" do
      presenter = MetadataPresenter.new(view: view_stub, title: 'Parameter')
      expect( presenter.title ).to eq 'Parameter'
    end
    it "should take a description parameter" do
      presenter = MetadataPresenter.new(view: view_stub, description: 'Parameter.')
      expect( presenter.description ).to eq 'Parameter.'
    end
    it "should take a image_url parameter" do
      presenter = MetadataPresenter.new(view: view_stub, image_url: 'http://parameter.tld/')
      expect( presenter.image_url ).to eq 'http://parameter.tld/'
    end
    it "should take a image_height parameter" do
      presenter = MetadataPresenter.new(view: view_stub, image_height: 1234)
      expect( presenter.image_height ).to eq 1234
    end
    it "should take a image_width parameter" do
      presenter = MetadataPresenter.new(view: view_stub, image_width: 4321)
      expect( presenter.image_width ).to eq 4321
    end
    context "with an ImageVariant" do
      let(:variant) { $variant = ImageVariant.new(url: 'http://variant.tld/', height: 123, width: 321) }
      it "should set the image_url" do
        presenter = MetadataPresenter.new(view: view_stub, image_variant: variant)
        expect( presenter.image_url ).to eq 'http://variant.tld/'
      end
      it "should set the image_height" do
        presenter = MetadataPresenter.new(view: view_stub, image_variant: variant)
        expect( presenter.image_height ).to eq 123
      end
      it "should set the image_width" do
        presenter = MetadataPresenter.new(view: view_stub, image_variant: variant)
        expect( presenter.image_width ).to eq 321
      end
    end
    context "with an Image" do
      before(:all) do
        @image = Image.new
        scaled = @image.image_variants.new(url: 'http://s.tld/', format: 'png',
          height: 1, width: 2, style: 'scaled'
        )
        original = @image.image_variants.new(url: 'http://o.tld/', format: 'png',
          height: 3, width: 6, style: 'original'
        )
        another = @image.image_variants.new(url: 'http://a.tld/', format: 'png',
          height: 2, width: 4, style: 'scaled'
        )
        @image.save!
      end
      before(:each) do
        @presenter = MetadataPresenter.new(view: view_stub, image: @image)
      end
      it "should use the original variant url" do
        expect( @presenter.image_url ).to eq 'http://o.tld/'
      end
      it "should use the original variant height" do
        expect( @presenter.image_height ).to eq 3
      end
      it "should use the original variant width" do
        expect( @presenter.image_width ).to eq 6
      end
    end
    it "should take a twitter_creator parameter" do
      presenter = MetadataPresenter.new(view: view_stub, twitter_creator: '@parameter')
      expect( presenter.twitter_creator ).to eq '@parameter'
    end
    it "should take a twitter_creator parameter and prepend the missing ‘@’" do
      presenter = MetadataPresenter.new(view: view_stub, twitter_creator: 'parameter')
      expect( presenter.twitter_creator ).to eq '@parameter'
    end
    it "should take a cache parameter" do
      presenter = MetadataPresenter.new(view: view_stub, nocache: :parameter)
      expect( presenter.nocache ).to eq :parameter
    end
  end

  describe "#present_title" do
    context "on the root page" do
      let(:path) { $path = '/' }
      it "should use just the site name, even if a title is given" do
        presenter = MetadataPresenter.new(view: view_stub, title: 'Sub-page Test')
        allow(presenter).to receive(:site_name).and_return('Sitename')
        expect( presenter.present_title ).to eq "<title>Sitename</title>"
      end
    end
    context "on a sub-page" do
      let(:path) { $path = '/sub/page.html' }
      it "should use the title and the site name" do
        presenter = MetadataPresenter.new(view: view_stub, title: 'Sub-page Test')
        allow(presenter).to receive(:site_name).and_return('Sitename')
        expect( presenter.present_title ).to eq "<title>Sub-page Test [Sitename]</title>"
      end
      it "should use just the site name when no title is given" do
        presenter = MetadataPresenter.new(view: view_stub)
        allow(presenter).to receive(:site_name).and_return('Sitename')
        expect( presenter.present_title ).to eq "<title>Sitename</title>"
      end
    end
    it "should be html safe" do
      expect( MetadataPresenter.new(view: view_stub).present_title.html_safe? ).to be_truthy
    end
  end

  describe "#present_metatags" do
    context "with all the possible params set" do
      let(:big_params) do
        $big_params = {
          type: 'param', title: 'Param', url: 'http://param.tld/', description: 'Param.',
          image_url: 'http://image.tld/', image_height: 12, image_width: 34, twitter_creator: 'param',
          nocache: true
        }
      end
      it "should be all the meta tags" do
        presenter = MetadataPresenter.new(big_params.merge(view: view_stub))
        allow(presenter).to receive(:site_name).and_return('Sitename')
        allow(presenter).to receive(:twitter_site).and_return('@site')
        expect( presenter.present_metatags ).to eq(
          "<meta name=\"description\" content=\"Param.\" />\n" +
          "<meta property=\"og:type\" content=\"param\" />\n" +
          "<meta property=\"og:title\" content=\"Param\" />\n" +
          "<meta property=\"og:url\" content=\"http://param.tld/\" />\n" +
          "<meta property=\"og:description\" content=\"Param.\" />\n" +
          "<meta property=\"og:site_name\" content=\"Sitename\" />\n" +
          "<meta property=\"og:image\" content=\"http://image.tld/\" />\n" +
          "<meta property=\"og:image:height\" content=\"12\" />\n" +
          "<meta property=\"og:image:width\" content=\"34\" />\n" +
          "<meta name=\"twitter:card\" value=\"summary\" />\n" +
          "<meta name=\"twitter:site\" value=\"@site\" />\n" +
          "<meta name=\"twitter:creator\" value=\"@param\" />\n" +
          "<meta name=\"robots\" content=\"noindex\" />\n"
        )
      end
      it "should be html safe" do
        presenter = MetadataPresenter.new(big_params.merge(view: view_stub))
        expect( presenter.present_metatags.html_safe? ).to be_truthy
      end
    end
  end

  describe "#present_description" do
    context "with no description" do
      it "should be blank" do
        presenter = MetadataPresenter.new(view: view_stub)
        expect( presenter.present_description ).to eq ''
      end
      it "should be html safe" do
        presenter = MetadataPresenter.new(view: view_stub)
        expect( presenter.present_description.html_safe? ).to be_truthy
      end
    end
    context "with a description" do
      it "should be both the meta description tag" do
        presenter = MetadataPresenter.new(view: view_stub, description: 'Test.')
        expect( presenter.present_description ).to eq(
          "<meta name=\"description\" content=\"Test.\" />\n"
        )
      end
      it "should be html safe" do
        presenter = MetadataPresenter.new(view: view_stub, description: 'Test.')
        expect( presenter.present_description.html_safe? ).to be_truthy
      end
    end
  end

  describe "#present_open_graph_specific" do
    context "with a given graph type" do
      it "should be both the og and normal description tags" do
        presenter = MetadataPresenter.new(view: view_stub, type: 'param')
        expect( presenter.present_open_graph_specific ).to eq(
          "<meta property=\"og:type\" content=\"param\" />\n"
        )
      end
    end
    context "with no graph type given" do
      context "on the root page" do
        let(:path) { $path = '/' }
        it "should be the og website type" do
          presenter = MetadataPresenter.new(view: view_stub)
          expect( presenter.present_open_graph_specific ).to eq(
            "<meta property=\"og:type\" content=\"website\" />\n"
          )
        end
      end
      context "on a non-root page" do
        let(:path) { $path = '/sub/page.html' }
        it "should be the og article type" do
          presenter = MetadataPresenter.new(view: view_stub)
          expect( presenter.present_open_graph_specific ).to eq(
            "<meta property=\"og:type\" content=\"article\" />\n"
          )
        end
      end
    end
    it "should be html safe" do
      presenter = MetadataPresenter.new(view: view_stub)
      expect( presenter.present_open_graph_specific.html_safe? ).to be_truthy
    end
  end

  describe "#present_open_graph_common" do
    context "with all the possible params set" do
      let(:big_params) { $big_params = {title: 'Param', url: 'http://param.tld/', description: 'Param.'} }
      it "should be all the meta tags" do
        presenter = MetadataPresenter.new(big_params.merge(view: view_stub))
        allow(presenter).to receive(:site_name).and_return('Sitename')
        expect( presenter.present_open_graph_common ).to eq(
          "<meta property=\"og:title\" content=\"Param\" />\n" +
          "<meta property=\"og:url\" content=\"http://param.tld/\" />\n" +
          "<meta property=\"og:description\" content=\"Param.\" />\n" +
          "<meta property=\"og:site_name\" content=\"Sitename\" />\n"
        )
      end
      it "should be html safe" do
        presenter = MetadataPresenter.new(big_params.merge(view: view_stub))
        expect( presenter.present_open_graph_common.html_safe? ).to be_truthy
      end
    end
    context "with no params set" do
      it "should be just the url and site_name meta tags" do
        presenter = MetadataPresenter.new(view: view_stub)
        allow(presenter).to receive(:site_name).and_return('Sitename')
        expect( presenter.present_open_graph_common ).to eq(
          "<meta property=\"og:url\" content=\"http://test.tld/test\" />\n" +
          "<meta property=\"og:site_name\" content=\"Sitename\" />\n"
        )
      end
      it "should be html safe" do
        presenter = MetadataPresenter.new(view: view_stub)
        expect( presenter.present_open_graph_common.html_safe? ).to be_truthy
      end
    end
  end

  describe "#present_image" do
    context "with no image" do
      it "should be blank" do
        presenter = MetadataPresenter.new(view: view_stub)
        expect( presenter.present_image ).to eq ''
      end
      it "should be html safe" do
        presenter = MetadataPresenter.new(view: view_stub)
        expect( presenter.present_image.html_safe? ).to be_truthy
      end
    end
    context "with an image url" do
      it "should be an image meta tag" do
        presenter = MetadataPresenter.new(view: view_stub, image_url: 'http://image.tld/')
        expect( presenter.present_image ).to eq(
          "<meta property=\"og:image\" content=\"http://image.tld/\" />\n"
        )
      end
      it "should be html safe" do
        presenter = MetadataPresenter.new(view: view_stub, image_url: 'http://image.tld/')
        expect( presenter.present_image.html_safe? ).to be_truthy
      end
    end
    context "with an image url and size" do
      it "should be an image, height and width, meta tags" do
        presenter = MetadataPresenter.new(view: view_stub,
          image_url: 'http://image.tld/', image_height: 12, image_width: 34
        )
        expect( presenter.present_image ).to eq(
          "<meta property=\"og:image\" content=\"http://image.tld/\" />\n" +
          "<meta property=\"og:image:height\" content=\"12\" />\n" +
          "<meta property=\"og:image:width\" content=\"34\" />\n"
        )
      end
      it "should be html safe" do
        presenter = MetadataPresenter.new(view: view_stub,
          image_url: 'http://image.tld/', image_height: 12, image_width: 34
        )
        expect( presenter.present_image.html_safe? ).to be_truthy
      end
    end
  end

  describe "#present_twitter" do
    context "with no site or creator" do
      it "should just return the card meta tag" do
        presenter = MetadataPresenter.new(view: view_stub)
        allow(presenter).to receive(:twitter_site).and_return(nil)
        expect( presenter.present_twitter ).to eq "<meta name=\"twitter:card\" value=\"summary\" />\n"
      end
      it "should be html safe" do
        presenter = MetadataPresenter.new(view: view_stub)
        allow(presenter).to receive(:twitter_site).and_return(nil)
        expect( presenter.present_twitter.html_safe? ).to be_truthy
      end
    end
    context "with a site" do
      it "should be the twitter card and site meta tags" do
        presenter = MetadataPresenter.new(view: view_stub)
        allow(presenter).to receive(:twitter_site).and_return('@test')
        expect( presenter.present_twitter ).to eq(
          "<meta name=\"twitter:card\" value=\"summary\" />\n" +
          "<meta name=\"twitter:site\" value=\"@test\" />\n"
        )
      end
      it "should be html safe" do
        presenter = MetadataPresenter.new(view: view_stub)
        allow(presenter).to receive(:twitter_site).and_return('@test')
        expect( presenter.present_twitter.html_safe? ).to be_truthy
      end
    end
    context "with a creator" do
      it "should be the twitter card and creator meta tags" do
        presenter = MetadataPresenter.new(view: view_stub, twitter_creator: 'testcreate')
        allow(presenter).to receive(:twitter_site).and_return(nil)
        expect( presenter.present_twitter ).to eq(
          "<meta name=\"twitter:card\" value=\"summary\" />\n" +
          "<meta name=\"twitter:creator\" value=\"@testcreate\" />\n"
        )
      end
      it "should be html safe" do
        presenter = MetadataPresenter.new(view: view_stub, twitter_creator: 'testcreate')
        allow(presenter).to receive(:twitter_site).and_return(nil)
        expect( presenter.present_twitter.html_safe? ).to be_truthy
      end
    end
    context "with a site and creator" do
      it "should be the twitter card, site and creator meta tags" do
        presenter = MetadataPresenter.new(view: view_stub, twitter_creator: 'testcreate')
        allow(presenter).to receive(:twitter_site).and_return('@testsite')
        expect( presenter.present_twitter ).to eq(
          "<meta name=\"twitter:card\" value=\"summary\" />\n" +
          "<meta name=\"twitter:site\" value=\"@testsite\" />\n" +
          "<meta name=\"twitter:creator\" value=\"@testcreate\" />\n"
        )
      end
      it "should be html safe" do
        presenter = MetadataPresenter.new(view: view_stub, twitter_creator: 'testcreate')
        allow(presenter).to receive(:twitter_site).and_return('@testsite')
        expect( presenter.present_twitter.html_safe? ).to be_truthy
      end
    end
  end

  describe "#present_cache" do
    context "with cache flag not set" do
      it "should be blank" do
        presenter = MetadataPresenter.new(view: view_stub)
        expect( presenter.present_cache ).to eq ''
      end
      it "should be html safe" do
        presenter = MetadataPresenter.new(view: view_stub)
        expect( presenter.present_cache.html_safe? ).to be_truthy
      end
    end
    context "with cache flag set to :no" do
      it "should be the no cache tag" do
        presenter = MetadataPresenter.new(view: view_stub, nocache: true)
        expect( presenter.present_cache ).to eq "<meta name=\"robots\" content=\"noindex\" />\n"
      end
      it "should be html safe" do
        presenter = MetadataPresenter.new(view: view_stub, nocache: true)
        expect( presenter.present_cache.html_safe? ).to be_truthy
      end
    end
  end

end
