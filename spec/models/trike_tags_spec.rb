require File.dirname(__FILE__) + '/../spec_helper'

class VirtualPage < Page
  def virtual?
    true
  end
end

describe "TrikeTags module" do 
  scenario :users, :home_page

  describe ": site_area tags :" do

    before do
      create_page "First" do
        create_page "First Child"
      end
      create_page "Parent" do
        create_page "Child" do
          create_page "Grandchild" do
            create_page "Great Grandchild"
          end
        end
      end
    end

    describe "<r:site_area />" do
      fixture = [
        #  From page          Expectation
        [:home,             'homepage'],
        [:parent,           'parent'],  
        [:child,            'parent'],
        [:grandchild,       'parent'],
        [:great_grandchild, 'parent'],
      ]
      fixture.each do |page, expectation|
        it "should return the top level parent page slug (from #{page})" do
          page(page).should render("<r:site_area />").as(expectation)
        end
      end

      it "should return the content of page part 'site_area' unless it does not exist" do
        child = page(:child)
        create_page_part "site_area", :content => "Hello World", :page_id => child.id 
        child.should render("<r:site_area />").as("Hello World") 
      end
    end

    describe "<r:site_subarea />" do
      fixture = [
        #  From page          Expectation
        [:home,             ''],  
        [:parent,           ''],  
        [:child,            'child'],
        [:grandchild,       'child'],
        [:great_grandchild, 'child'],
      ]
      fixture.each do |page, expectation|
        it "should return the second level parent page slug (from #{page})" do
          page(page).should render("<r:site_subarea />").as(expectation)
        end
      end
         
      it "should return the content of page part 'site_subarea' unless it does not exist" do
        child = page(:child)
        create_page_part "site_subarea", :content => "Hello World", :page_id => child.id
        child.should render("<r:site_subarea />").as("Hello World") 
      end
    end
    
    describe '<r:current_if_same_site_area />' do
      fixture = [
        #  From page    Found page path             Expectation
        [:parent,     "/",                        ''],
        [:parent,     "/parent",                  'current'],
        [:parent,     "/parent/child",            'current'],
        [:parent,     "/parent/child/grandchild", 'current'],

        [:child,      "/",                        ''],
        [:child,      "/parent",                  'current'],
        [:child,      "/parent/child",            'current'],
        [:child,      "/parent/child/grandchild", 'current'],

        [:grandchild, "/",                        ''],
        [:grandchild, "/parent",                  'current'],
        [:grandchild, "/parent/child",            'current'],
        [:grandchild, "/parent/child/grandchild", 'current'],

        [:home,       "/parent/child",            ''],

        [:first,      "/parent",                  ''],
        [:first_child,"/parent/child/grandchild", ''],
      ]
      fixture.each do |page, path, expectation|
        it "should return 'current' if the local page context is in the same site_area as the global page context (from #{page})" do
          page(page).should render("<r:find url='#{path}'><r:current_if_same_site_area /></r:find>").as(expectation)
        end
      end

    end
    
    describe "<r:if_same_site_area />" do
      fixture = [
        #  From page    Found page path             Expectation
        [:parent,     "/",                        ''],
        [:parent,     "/parent",                  'yes'],
        [:parent,     "/parent/child",            'yes'],
        [:parent,     "/parent/child/grandchild", 'yes'],

        [:child,      "/",                        ''],
        [:child,      "/parent",                  'yes'],
        [:child,      "/parent/child",            'yes'],
        [:child,      "/parent/child/grandchild", 'yes'],

        [:grandchild, "/",                        ''],
        [:grandchild, "/parent",                  'yes'],
        [:grandchild, "/parent/child",            'yes'],
        [:grandchild, "/parent/child/grandchild", 'yes'],

        [:home,       "/parent/child",            ''],

        [:first,      "/parent",                  ''],
        [:first_child,"/parent/child/grandchild", ''],
      ]
      fixture.each do |page, path, expectation|
        it "should render contained text if the local page context is in the same site_area as the global page context (from #{page})" do
          page(page).should render("<r:find url='#{path}'><r:if_same_site_area>yes</r:if_same_site_area></r:find>").as(expectation)
        end
      end
    end
    
    describe "<r:unless_same_site_area />" do
      fixture = [
        #  From page    Found page path             Expectation
        [:parent,     "/",                        'no'],
        [:parent,     "/parent",                  ''],
        [:parent,     "/parent/child",            ''],
        [:parent,     "/parent/child/grandchild", ''],

        [:child,      "/",                        'no'],
        [:child,      "/parent",                  ''],
        [:child,      "/parent/child",            ''],
        [:child,      "/parent/child/grandchild", ''],

        [:grandchild, "/",                        'no'],
        [:grandchild, "/parent",                  ''],
        [:grandchild, "/parent/child",            ''],
        [:grandchild, "/parent/child/grandchild", ''],

        [:home,       "/parent/child",            'no'],

        [:first,      "/parent",                  'no'],
        [:first_child,"/parent/child/grandchild", 'no'],
      ]
      fixture.each do |page, path, expectation|
        it "should render contained text unless the local page context is in the same site_area as the global page context (from #{page})" do
          page(page).should render("<r:find url='#{path}'><r:unless_same_site_area>no</r:unless_same_site_area></r:find>").as(expectation)
        end
      end
    end
    
    describe "<r:current_if_same_site_subarea />" do
      fixture = [
        #  From page    Found page path             Expectation
        [:parent,     "/",                        ''],
        [:parent,     "/parent",                  ''],
        [:parent,     "/parent/child",            ''],
        [:parent,     "/parent/child/grandchild", ''],

        [:child,      "/",                        ''],
        [:child,      "/parent",                  ''],
        [:child,      "/parent/child",            'current'],
        [:child,      "/parent/child/grandchild", 'current'],

        [:grandchild, "/",                        ''],
        [:grandchild, "/parent",                  ''],
        [:grandchild, "/parent/child",            'current'],
        [:grandchild, "/parent/child/grandchild", 'current'],

        [:home,       "/parent/child",            ''],

        [:first,      "/parent",                  ''],
        [:first_child,"/parent/child/grandchild", ''],
      ]
      fixture.each do |page, path, expectation|
        it "should return 'current' if the local page context is in the same site_subarea as the global page context (from #{page})" do
          page(page).should render("<r:find url='#{path}'><r:current_if_same_site_subarea /></r:find>").as(expectation)
        end
      end
    end
    
    describe "<r:current_if_same_site_subarea />" do
      fixture = [
        #  From page    Found page path             Expectation
        [:parent,     "/",                        ''],
        [:parent,     "/parent",                  ''],
        [:parent,     "/parent/child",            ''],
        [:parent,     "/parent/child/grandchild", ''],

        [:child,      "/",                        ''],
        [:child,      "/parent",                  ''],
        [:child,      "/parent/child",            'current'],
        [:child,      "/parent/child/grandchild", 'current'],

        [:grandchild, "/",                        ''],
        [:grandchild, "/parent",                  ''],
        [:grandchild, "/parent/child",            'current'],
        [:grandchild, "/parent/child/grandchild", 'current'],

        [:home,       "/parent/child",            ''],

        [:first,      "/parent",                  ''],
        [:first_child,"/parent/child/grandchild", ''],
      ]
      fixture.each do |page, path, expectation|
        it "should render 'current' if the local page context is in the same site_subarea as the global page context (from #{page})" do
          page(page).should render("<r:find url='#{path}'><r:current_if_same_site_subarea /></r:find>").as(expectation)
        end
      end
    end
    
    describe "<r:if_same_site_subarea />" do
      fixture = [
        #  From page    Found page path             Expectation
        [:parent,     "/",                        ''],
        [:parent,     "/parent",                  ''],
        [:parent,     "/parent/child",            ''],
        [:parent,     "/parent/child/grandchild", ''],

        [:child,      "/",                        ''],
        [:child,      "/parent",                  ''],
        [:child,      "/parent/child",            'yes'],
        [:child,      "/parent/child/grandchild", 'yes'],

        [:grandchild, "/",                        ''],
        [:grandchild, "/parent",                  ''],
        [:grandchild, "/parent/child",            'yes'],
        [:grandchild, "/parent/child/grandchild", 'yes'],

        [:home,       "/parent/child",            ''],

        [:first,      "/parent",                  ''],
        [:first_child,"/parent/child/grandchild", ''],
      ]
      fixture.each do |page, path, expectation|
        it "should render contained elements if the local page context is in the same site_subarea as the global page context (from #{page})" do
          page(page).should render("<r:find url='#{path}'><r:if_same_site_subarea>yes</r:if_same_site_subarea></r:find>").as(expectation)
        end
      end
    end
    
    describe "<r:unless_same_site_subarea />" do
      fixture = [
        #  From page    Found page path             Expectation
        [:parent,     "/",                        'no'],
        [:parent,     "/parent",                  'no'],
        [:parent,     "/parent/child",            'no'],
        [:parent,     "/parent/child/grandchild", 'no'],

        [:child,      "/",                        'no'],
        [:child,      "/parent",                  'no'],
        [:child,      "/parent/child",            ''],
        [:child,      "/parent/child/grandchild", ''],

        [:grandchild, "/",                        'no'],
        [:grandchild, "/parent",                  'no'],
        [:grandchild, "/parent/child",            ''],
        [:grandchild, "/parent/child/grandchild", ''],

        [:home,       "/parent/child",            'no'],

        [:first,      "/parent",                  'no'],
        [:first_child,"/parent/child/grandchild", 'no'],
      ]
      fixture.each do |page, path, expectation|
        it "should render contained elements unless the local page context is in the same site_subarea as the global page context (from #{page})" do
          page(page).should render("<r:find url='#{path}'><r:unless_same_site_subarea>no</r:unless_same_site_subarea></r:find>").as(expectation)
        end
      end
    end
    
    describe "<r:current_if_same_page />" do
      fixture = [
        #  From page    Found page path             Expectation
        [:parent,     "/",                        ''],  
        [:parent,     "/parent",                  'current'],    
        [:parent,     "/parent/child",            ''],      
        [:parent,     "/parent/child/grandchild", ''],  

        [:child,      "/",                        ''],
        [:child,      "/parent",                  ''],
        [:child,      "/parent/child",            'current'],
        [:child,      "/parent/child/grandchild", ''],

        [:grandchild, "/",                        ''],
        [:grandchild, "/parent",                  ''],
        [:grandchild, "/parent/child",            ''],
        [:grandchild, "/parent/child/grandchild", 'current'],

        [:home,       "/",                        'current'],
        [:home,       "/parent/child",            ''],

        [:first,      "/parent",                  ''],
        [:first_child,"/parent/child/grandchild", ''],
      ] 
      fixture.each do |page, path, expectation|
        it "should return 'current' if the local page context is in the same as the global page context (from #{page})" do
          page(page).should render("<r:find url='#{path}'><r:current_if_same_page /></r:find>").as(expectation)
        end
      end
    end

    describe "<r:link_with_current>" do
      fixture = [
      #  From page    href                          Link text           Expectation
        [:parent,     "/",                          "Home",             '<a href="/">Home</a>'],  
        [:parent,     "/parent",                    "Parent",           '<a href="/parent" class="current">Parent</a>'],    
        [:parent,     "/parent/child",              "Child",            '<a href="/parent/child">Child</a>'],      
        [:parent,     "/parent/child/grandchild",   "GrandChild",       '<a href="/parent/child/grandchild">GrandChild</a>'],  

        [:child,      "/",                          "Home",             '<a href="/">Home</a>'],  
        [:child,      "/parent",                    "Parent",           '<a href="/parent">Parent</a>'],    
        [:child,      "/parent/child",              "Child",            '<a href="/parent/child" class="current">Child</a>'],      
        [:child,      "/parent/child/grandchild",   "GrandChild",       '<a href="/parent/child/grandchild">GrandChild</a>'],  

        [:grandchild, "/",                          "Home",             '<a href="/">Home</a>'],  
        [:grandchild, "/parent",                    "Parent",           '<a href="/parent">Parent</a>'],    
        [:grandchild, "/parent/child",              "Child",            '<a href="/parent/child">Child</a>'],      
        [:grandchild, "/parent/child/grandchild",   "GrandChild",       '<a href="/parent/child/grandchild" class="current">GrandChild</a>'],  

        [:home,       "/",                          "Home",             '<a href="/" class="current">Home</a>'],  
        [:home,       "/first",                     "First",             '<a href="/first">First</a>'],    

        [:first,      "/parent",                    "Parent",           '<a href="/parent">Parent</a>'],
        [:first_child,"/parent/child/grandchild",   "GrandChild",       '<a href="/parent/child/grandchild">GrandChild</a>'],        
      ]
      fixture.each do |page, path, link_text, expectation|
        it "should render a simple link and add class='current' if it's a link to the current page (from #{page})" do
          page(page).should render("<r:link_with_current href='#{path}'>#{link_text}</r:link_with_current>").as(expectation)
        end    
      end 

      it "should render a simple link to the current page and add class='current' if attribute 'href' is not provided" do
        page(:parent).should render("<r:link_with_current >Parent</r:link_with_current>").as('<a href="/parent/" class="current">Parent</a>')
      end    
    end
  end

  describe ": sibling tags :" do

    describe "<r:next> and <r:previous>", "with 'by' property supplied" do
      before do
        create_page "First"
        create_page "News" do
          create_page "Article",      :published_at => DateTime.parse('2002-01-01 08:41:07')
          create_page "Draft Article",:status_id => Status[:draft].id
          create_page "Article 2",    :published_at => DateTime.parse('2001-01-01 08:42:04')
          create_page "Hidden Article",:status_id => Status[:hidden].id
          create_page "Article 3",    :published_at => DateTime.parse('2004-01-01 12:02:43')
          create_page "Virtual Article", :class_name => "VirtualPage", :virtual => true, :slug => "virtual"
          create_page "Article 4",    :published_at => DateTime.parse('2003-01-01 03:32:31')
        end
        create_page "Third"
      end

      describe "<r:next>" do
        fixture = [
          #  From page    Order by          Expectation
            [:article,    "title",          "Article 2"],
            [:article_2,  "title",          "Article 3"],
            [:article_3,  "title",          "Article 4"],
            [:article_4,  "title",          ""],
            [:first,      "title",          "News"],
            [:news,       "title",          "Third"],
            [:third,      "title",          ""],

            [:article_2,  "published_at",   "Article"],
            [:article,    "published_at",   "Article 4"],
            [:article_4,  "published_at",   "Article 3"],
            [:article_3,  "published_at",   ""],
        ]
        fixture.each do |page, order_by, expectation|
          it "should set the page context to the next page sibling." do
            page(page).should render("<r:next by='#{order_by}'><r:title /></r:next>").as(expectation) 
          end
        end

        it "should error with invalid 'by' attribute" do
          page(:first).should render("<r:next by='no_such_column'><r:title /></r:next>").with_error("`by' attribute of `next' tag must be set to a valid page attribute name.")  
        end
      end

      describe "<r:previous>" do
        fixture = [
          #  From page    Order by          Expectation
            [:article,    "title",          ""],
            [:article_2,  "title",          "Article"],
            [:article_3,  "title",          "Article 2"],
            [:article_4,  "title",          "Article 3"],
            [:first,      "title",          ""],
            [:news,       "title",          "First"],
            [:third,      "title",          "News"],

            [:article_2,  "published_at",   ""],
            [:article,    "published_at",   "Article 2"],
            [:article_4,  "published_at",   "Article"],
            [:article_3,  "published_at",   "Article 4"],

        ]
        fixture.each do |page, order_by, expectation|
          it "should set the page context to the previous page sibling." do
            page(page).should render("<r:previous by='#{order_by}'><r:title /></r:previous>").as(expectation) 
          end
        end

        it "should error with invalid 'by' attribute" do
          page(:first).should render("<r:previous by='no_such_column'><r:title /></r:previous>").with_error("`by' attribute of `previous' tag must be set to a valid page attribute name.")  
        end
      end
    end

    describe "<r:next> and <r:previous>", "without 'by' property supplied" do
      before do
        if Page.column_names.include?("position") then
          create_page "First", :position => 2
          create_page "News", :position => 1 do
            create_page "Article"
          end
          create_page "Third", :position => 0
        else
          create_page "First"
          create_page "News" do
            create_page "Article"
          end
          create_page "Third"
        end
      end

      describe "<r:next>" do
        fixture = [
          #  From page       Expectation w/ position  Expectation w/o positon
            [:first,         "",                      "News"],
            [:news,          "First",                 "Third"], 
            [:third,         "News",                  ""],
        ]
        fixture.each do |page,  expectation_with_position, expectation_without_position|
          if Page.column_names.include?("position") then
            # NOTE: we only test the condition that applies (install Reorder extension to test this case)
            it "should set the page context to the next page sibling ordered by position." do
              page(page).should render("<r:next><r:title /></r:next>").as(expectation_with_position) 
            end
          else
            it "should set the page context to the next page sibling ordered by title." do
              page(page).should render("<r:next><r:title /></r:next>").as(expectation_without_position) 
            end
          end
        end
      end 

      describe "<r:previous>" do
        fixture = [
          #  From page       Expectation w/ position  Expectation w/o positon
            [:first,         "News",                  ""],
            [:news,          "Third",                 "First"], 
            [:third,         "",                      "News"],
        ]
        fixture.each do |page,  expectation_with_position, expectation_without_position|
          if Page.column_names.include?("position") then
            # NOTE: we only test the condition that applies (install Reorder extension to test this case)
            it "should set the page context to the previous page sibling ordered by position." do
              page(page).should render("<r:previous><r:title /></r:previous>").as(expectation_with_position) 
            end
          else
            it "should set the page context to the previous page sibling ordered by title." do
              page(page).should render("<r:previous><r:title /></r:previous>").as(expectation_without_position) 
            end
          end
        end
      end   
    end
  end

  describe ": url tags :" do

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

  describe ": changed standard tags :" do
    scenario :users, :home_page

    describe "<r:url />" do
      before do
        create_page "First"
        Radiant::Config.delete_all(:key => "defaults.trailingslash")
      end

      it "should default to true behaviour when Radiant::Config['defaults.trailingslash'] is absent" do
        Radiant::Config.delete_all(:key => "defaults.trailingslash")
        page(:home).should render("<r:url />").as("/")
        page(:first).should render("<r:url />").as("/first/")
      end
      it "should respect Radiant::Config['defaults.trailingslash'] = true" do
        Radiant::Config['defaults.trailingslash'] = true
        page(:home).should render("<r:url />").as("/")
        page(:first).should render("<r:url />").as("/first/")
      end
      it "should respect Radiant::Config['defaults.trailingslash'] = false" do
        Radiant::Config['defaults.trailingslash'] = false
        page(:home).should render("<r:url />").as("/")
        page(:first).should render("<r:url />").as("/first")
      end
      it 'should respect trailingslash="true"' do
        page(:home).should render("<r:url trailingslash='true' />").as("/")
        page(:first).should render("<r:url trailingslash='true' />").as("/first/")
      end
      it 'should respect trailingslash="false"' do
        page(:home).should render("<r:url trailingslash='false' />").as("/")
        page(:first).should render("<r:url trailingslash='false' />").as("/first")
      end
      it 'should respect trailingslash="true" even when Radiant::Config["defaults.trailingslash"] disagrees' do
        Radiant::Config['defaults.trailingslash'] = false
        page(:home).should render("<r:url trailingslash='true' />").as("/")
        page(:first).should render("<r:url trailingslash='true' />").as("/first/")
      end
      it 'should respect trailingslash="false" even when Radiant::Config["defaults.trailingslash"] disagrees' do
        Radiant::Config['defaults.trailingslash'] = true
        page(:home).should render("<r:url trailingslash='false' />").as("/")
        page(:first).should render("<r:url trailingslash='false' />").as("/first")
      end

    end

    describe "<r:link />" do
      before do
        create_page "First" do
          create_page "Child",   :published_at => DateTime.parse('2000-1-01 08:00:00')
          create_page "Child 2", :published_at => DateTime.parse('2000-1-01 09:00:00')
          create_page "Child 3", :published_at => DateTime.parse('2000-1-01 10:00:00')
        end
        Radiant::Config.delete_all(:key => "defaults.trailingslash")
      end

      describe "(legacy behaviour)" do
        it "should render a link to the current page" do
          page(:first).should render('<r:link />').as('<a href="/first/">First</a>')
        end

        it "should render its contents as the text of the link" do
          page(:first).should render('<r:link>Test</r:link>').as('<a href="/first/">Test</a>')
        end

        it "should pass HTML attributes to the <a> tag" do
          expected = '<a href="/first/" class="test" id="first">First</a>'
          page(:first).should render('<r:link class="test" id="first" />').as(expected)
        end

        it "should add the anchor attribute to the link as a URL anchor" do
          page(:first).should render('<r:link anchor="test">Test</r:link>').as('<a href="/first/#test">Test</a>')
        end

        it "should render a link for the current contextual page" do
          expected = %{<a href="/first/child/">Child</a> <a href="/first/child-2/">Child 2</a> <a href="/first/child-3/">Child 3</a> }
          page(:first).should render('<r:children:each><r:link /> </r:children:each>' ).as(expected)
        end

        # NOTE: this is voodoo - I have no idea what this test means, but it's
        # a pretty clean copy of core functionality, and it shows we preserve it
        it "should scope the link within the relative URL root" do
          page(:first).should render('<r:link />').with_relative_root('/foo').as('<a href="/foo/first/">First</a>')
        end
      end

      it "should default to true behaviour when Radiant::Config['defaults.trailingslash'] is absent" do
        Radiant::Config.delete_all(:key => "defaults.trailingslash")
        page(:home).should render("<r:link />").as('<a href="/">Home</a>')
        page(:first).should render("<r:link />").as('<a href="/first/">First</a>')
      end
      it "should respect Radiant::Config['defaults.trailingslash'] = true" do
        Radiant::Config['defaults.trailingslash'] = true
        page(:home).should render("<r:link />").as('<a href="/">Home</a>')
        page(:first).should render("<r:link />").as('<a href="/first/">First</a>')
      end
      it "should respect Radiant::Config['defaults.trailingslash'] = false" do
        Radiant::Config['defaults.trailingslash'] = false
        page(:home).should render("<r:link />").as('<a href="/">Home</a>')
        page(:first).should render("<r:link />").as('<a href="/first">First</a>')
      end
      it 'should respect trailingslash="true"' do
        page(:home).should render("<r:link trailingslash='true' />").as('<a href="/">Home</a>')
        page(:first).should render("<r:link trailingslash='true' />").as('<a href="/first/">First</a>')
      end
      it 'should respect trailingslash="false"' do
        page(:home).should render("<r:link trailingslash='false' />").as('<a href="/">Home</a>')
        page(:first).should render("<r:link trailingslash='false' />").as('<a href="/first">First</a>')
      end
      it 'should respect trailingslash="true" even when Radiant::Config["defaults.trailingslash"] disagrees' do
        Radiant::Config['defaults.trailingslash'] = false
        page(:home).should render("<r:link trailingslash='true' />").as('<a href="/">Home</a>')
        page(:first).should render("<r:link trailingslash='true' />").as('<a href="/first/">First</a>')
      end
      it 'should respect trailingslash="false" even when Radiant::Config["defaults.trailingslash"] disagrees' do
        Radiant::Config['defaults.trailingslash'] = true
        page(:home).should render("<r:link trailingslash='false' />").as('<a href="/">Home</a>')
        page(:first).should render("<r:link trailingslash='false' />").as('<a href="/first">First</a>')
      end

    end
  end

  private

  def page(symbol = nil)
      @page = pages(symbol)
  end

end
