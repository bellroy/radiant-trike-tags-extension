require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EmbedRemoteTags do
  dataset :home_page
  
  describe '<r:embed />' do
    before { @page = page(:home) }
    
    it "should require a url parameter" do
      @page.parts.first.update_attribute(:content, "<r:embed_remote />")
      lambda { @page.render }.should raise_error(StandardTags::TagError)
    end
    it "should replace the tag with the fetched site" do
      #TODO: move this into a helper function we can stub out
      URI.should_receive(:parse).with("http://a.co").and_return "a uri"
      Net::HTTP.should_receive(:get).with("a uri").and_return "results"
      #HACK: wanted to use page.should render as, but couldn't get it working
      @page.parts.first.update_attribute(:content, "<r:embed_remote uri='http://a.co' />")
      @page.render.should == "results"
    end
  end
end