require File.dirname(__FILE__) + '/../spec_helper'

describe ": url tags :" do
  scenario :users, :home_page

  before do
    create_page "First", :updated_at => DateTime.parse('2008-05-10 7:30:45')
    create_page "Second"
    create_page "Parent" do
      create_page "Child" do
        create_page "Grandchild" do
          create_page "Great Grandchild"
        end
      end
    end

    @hostname = "testhost.tld"

    create_page "StubPage"
    @stub_page = page(:stub_page)
    @stub_page.stub!(:request).and_return(ActionController::TestRequest.new)

    @page = pages(:second)
    @context = PageContext.new(@page)
    @parser = Radius::Parser.new(@context, :tag_prefix => 'r')
  end

  describe "<r:full_url />" do
    
    hostname_url = "http://testhost.tld"
    fixture = [
      # From page            Expectation 
      [:home,                hostname_url + "/"],
      [:parent,              hostname_url + "/parent/"],
      [:child,               hostname_url + "/parent/child/"],
      [:grandchild,          hostname_url + "/parent/child/grandchild/"],
      [:great_grandchild,    hostname_url + "/parent/child/grandchild/great-grandchild/"],
    ]
    fixture.each do |page,  expectation|
      it "should render full url, including the http:// (from #{page})" do
        page(page).should render("<r:full_url />").as(expectation)
      end
    end
  end

  describe "<r:host />" do

    hostname = "testhost.tld"
    fixture = [
      # From page            Expectation 
      [:home,                hostname],
      [:parent,              hostname],
      [:child,               hostname],
      [:grandchild,          hostname],
      [:great_grandchild,    hostname],
    ]
    fixture.each do |page,  expectation|
      it "should render host name (from #{page})" do
        page(page).should render("<r:host />").as(expectation)
      end
    end    

    it "should error with empty host." do
      @stub_page.request.stub!(:host).and_return('')
      @stub_page.should render("<r:host />").with_error("request.host is returning something very unexpected (#{@stub_page.request.host.inspect}). You could override this behaviour by providing a 'host' page part on the site root page that contains the hostname.")
    end

    it "should render the content of page part 'host' of the page's root if it exists, after removing the contents trailing slash or leading protocol." do
      create_page_part "host", :content => 'http://www.example.com/'
      @stub_page.stub!(:root).and_return(page(:home))
      @stub_page.root.stub!(:part).and_return(page_parts(:host))
      @stub_page.should render("<r:host />").as('www.example.com')
    end

    it "should render the base_domain of the site of the page's root if it exists." do
      create_page_part "host", :content => 'http://www.example.com'
      @stub_page.stub!(:root).and_return(page(:home))
      @stub_page.root.stub!(:site).and_return(stub('Site', :base_domain => 'www.example.com'))
      @stub_page.should render("<r:host />").as('www.example.com')
    end

  end

  describe "<r:bare_host />" do

    it "should render the site's bare host i.e. without the 'www' part in the host" do
      @stub_page.request.stub!(:host).and_return('www.example.com')
      @stub_page.should render("<r:bare_host />").as('example.com')
    end 
  end

  describe "<r:base_domain />" do

    it "should render the site's base domain i.e. host, less any subdomains." do
      @stub_page.request.stub!(:host).and_return('www.sub.example.com')
      @stub_page.should render("<r:base_domain />").as('example.com')
    end 

    it "should render the site's base domain i.e. host, less any subdomains." do
      @stub_page.request.stub!(:host).and_return('sub3.sub2.sub.example.com')
      @stub_page.should render("<r:base_domain />").as('sub2.sub.example.com')
    end 

    it 'should raise an error when it encounters a missing tag base_domain' do
      lambda { @parser.parse('<r:base_domain />') }.should raise_error(StandardTags::TagError)
    end
  end

  describe "<r:img_host />" do
    it "should render images.[bare_host]" do
      page(:parent).should render("<r:img_host />").as("images.#{@hostname}")           
    end
 
    it 'should raise an error when it encounters a missing tag img_host ' do
      lambda { @parser.parse('<r:img_host />') }.should raise_error(StandardTags::TagError)
    end
  end

  describe "<r:img src='image_source' [other attributes...] />" do

    it "should inject 'http://{{img_host}}{{src}}' into a normal img tag." do
      page(:parent).should render("<r:img src='image_source' />").as("<img src=\"http://images.#{@hostname}/image_source\" />")        
    end

    it "should with error when no 'src' attribute is specified." do
      page(:parent).should render("<r:img />").with_error("`img' tag must contain a `src' attribute.")
    end

    it 'should raise an error when it encounters a missing tag img_host ' do
      lambda { @parser.parse("<r:img src='image_source' />") }.should raise_error(StandardTags::TagError)
    end
  end

  describe "<r:asset_link href='asset_path'>" do
    it "should render a link to an asset relative to <r:img_host />" do
       page(:parent).should render("<r:asset_link href='asset_path' />").as("<a href=\"http://images.#{@hostname}/asset_path\"></a>")        
    end

    it 'should raise an error when it encounters a missing tag asset_link' do
      lambda { @parser.parse('<r:asset_link />') }.should raise_error(StandardTags::TagError)
    end
  end

  describe "<r:updated_at />" do
     it "should give the date the page was last modified in xmlschema format (ideal for xml feeds like sitemap.xml)" do
       page(:first).should render("<r:updated_at />").as('2008-05-10T07:30:45Z')
     end
  end

  describe "<r:section_root />" do

    fixture = [
      # From page            Expectation 
      [:home,                ""],
      [:parent,              "Parent"],
      [:child,               "Parent"],
      [:grandchild,          "Parent"],
      [:great_grandchild,    "Parent"],
    ]
    fixture.each do |page,  expectation|
      it "should set page context to the page which is current page's ancestor who is the child of site root (from #{page})" do
        page(page).should render("<r:section_root><r:title /></r:section_root>").as(expectation)
      end
    end
  end 


  describe "<r:if_referer>" do
    it "should render the containing elements only if the page's referer matches the regular expression" do
      @stub_page.request.stub!(:env).and_return({'HTTP_REFERER' => 'www.example.com'})

      @stub_page.should render("<r:if_referer matches='www.example.com'>Display this</r:if_referer>").as('Display this')
      @stub_page.should render("<r:if_referer matches='example'>Display this</r:if_referer>").as('Display this')
      @stub_page.should render("<r:if_referer matches='www.[a-z]+.com'>Display this</r:if_referer>").as('Display this')
    end 

    it "should not render containing elements if the page's referer does not match the regular expression" do
      @stub_page.request.stub!(:env).and_return({'HTTP_REFERER' => 'www.dontmatch.com'})

      @stub_page.should render("<r:if_referer matches='www.example.com'>Display this</r:if_referer>").as('')
      @stub_page.should render("<r:if_referer matches='example'>Display this</r:if_referer>").as('')
      @stub_page.should render("<r:if_referer matches='www.[0-9]+.com'>Display this</r:if_referer>").as('')
    end 

    it "should error with no 'matches' attribute" do
      @stub_page.request.stub!(:env).and_return({'HTTP_REFERER' => 'www.example.com'})
      @stub_page.should render("<r:if_referer>Display this</r:if_referer>").with_error("`if_referer' tag must contain a `matches' attribute.")
    end
  end

  describe "<r:unless_referer>" do
    it "should render the containing elements only if the page's referer does not match the regular expression" do
      @stub_page.request.stub!(:env).and_return({'HTTP_REFERER' => 'www.helloworld.com'})

      @stub_page.should render("<r:unless_referer matches='www.example.com'>Display this</r:unless_referer>").as('Display this')
      @stub_page.should render("<r:unless_referer matches='example'>Display this</r:unless_referer>").as('Display this')
      @stub_page.should render("<r:unless_referer matches='www.[0-9]+.com'>Display this</r:unless_referer>").as('Display this')
    end

    it "should not render containing elements if the page's referer matches the regular expression" do
      @stub_page.request.stub!(:env).and_return({'HTTP_REFERER' => 'www.example.com'})

      @stub_page.should render("<r:unless_referer matches='www.example.com'>Display this</r:unless_referer>").as('')
      @stub_page.should render("<r:unless_referer matches='example'>Display this</r:unless_referer>").as('')
      @stub_page.should render("<r:unless_referer matches='www.[a-z]+.com'>Display this</r:unless_referer>").as('')
    end

    it "should error with no 'matches' attribute" do
      @stub_page.request.stub!(:env).and_return({'HTTP_REFERER' => 'www.example.com'})
      @stub_page.should render("<r:unless_referer>Display this</r:unless_referer>").with_error("`unless_referer' tag must contain a `matches' attribute.")
    end
  end
end
