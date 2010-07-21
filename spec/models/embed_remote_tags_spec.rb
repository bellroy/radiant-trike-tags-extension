require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EmbedRemoteTags do
  dataset :home_page

  describe '<r:embed />' do
    before { @page = page(:home) }

    it "should require a url parameter" do
      @page.parts.first.update_attribute(:content, "<r:embed_remote />")
      lambda { @page.render }.should raise_error(StandardTags::TagError)
    end

    it "should parse the uri, and request it" do
      @url = "http://example.com/"
      @uri = URI.parse(@url)
      URI.should_receive(:parse).with(@url).and_return @uri

      @response = mock(Net::HTTPResponse, :code => '200', :body => 'results')
      Net::HTTP.should_receive(:get_response).with(@uri).and_return @response

      @page.parts.first.update_attribute(:content, "<r:embed_remote uri='http://example.com/' />")
      @page.render
    end

    describe "when the site can be fetched" do
      before do
        @response = mock(Net::HTTPResponse, :code => '200', :body => 'results')
        Net::HTTP.stub! :get_response => @response
      end

      it "replaces the tag with the fetched site" do
        @page.parts.first.update_attribute(:content, "<r:embed_remote uri='http://example.com/' />")
        @page.render.should == "results"
      end
    end

    shared_examples_for "error fetching content" do
      it "returns a notice" do
        @page.render.should == "This information is temporarily unavailable."
      end
    end

    describe "when it can't fetch content" do
      before do
        @page.stub! :response => ActionController::TestResponse.new
        @page.parts.first.update_attribute(:content, "<r:embed_remote uri='http://example.com/' />")
        @response = mock(Net::HTTPResponse, :code => '404', :body => '')
        Net::HTTP.stub! :get_response => @response
      end

      it_should_behave_like "error fetching content"

      it "should set the request response Status header to 503" do
        @page.render
        @page.response.headers['Status'].should == '503'
      end

      it "should set the cacheability of the page to uncachable" do
        @page.render
        @page.should_not be_cache
      end
    end
  end
end
