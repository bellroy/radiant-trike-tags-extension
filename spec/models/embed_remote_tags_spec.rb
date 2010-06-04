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
      end

      describe "because of a non-200 status code" do
        before do
          @response = mock(Net::HTTPResponse, :code => '404', :body => '')
          Net::HTTP.stub! :get_response => @response
        end

        it_should_behave_like "error fetching content"

        it "should set the request response Status header to the same response code" do
          @page.render
          @page.response.headers['Status'].should == '404'
        end
      end

      describe "because of unknown error" do
        before do
          Net::HTTP.stub!(:get_response).and_raise(Net::HTTPError.new("Something bad", mock(Net::HTTPResponse)))
        end

        it_should_behave_like "error fetching content"

        it "should set the request response Status header to Temporarily Unavailable" do
          @page.render
          @page.response.headers['Status'].should == '503'
        end
      end
    end
  end
end
