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
    end

    describe "<r:current_if_same_site_area />" do
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
    end  
  end

  describe ": sibling tags :" do

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
    
    describe "<r:next>", "with 'by' property supplied" do
    
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

   describe "<r:next>", "without 'by' property supplied" do
      
      fixture = [
      #  From page                   Expectation
        [:first,                     "News"],
        [:news,                      "Third"], 
        [:third,                     ""],
      ]
      fixture.each do |page,  expectation|
        it "should set the page context to the next page sibling ordered by title." do
          page(page).should render("<r:next><r:title /></r:next>").as(expectation) 
        end
      end
   end 

   describe "<r:previous>", "with 'by' property supplied" do
     
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
   end

   describe "<r:previous>", "without 'by' property supplied" do

      it "should error with invalid 'by' attribute" do
        page(:first).should render("<r:previous by='no_such_column'><r:title /></r:previous>").with_error("`by' attribute of `previous' tag must be set to a valid page attribute name.")  
      end
      
      fixture = [
      #  From page                   Expectation
        [:first,                     ""],
        [:news,                      "First"], 
        [:third,                     "News"],
      ]
      fixture.each do |page,  expectation|
        it "should set the page context to the previous page sibling ordered by title." do
          page(page).should render("<r:previous><r:title /></r:previous>").as(expectation) 
        end
      end
   end   
  end

  describe ": url tags :" do

    before do
      create_page "First", :updated_at => DateTime.parse('2008-05-10 7:30:45')
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
   end

   describe "<r:bare_host />" do

      it "should render the site's base domain" do
        @stub_page.request.stub!(:host).and_return('www.example.com')
        @stub_page.should render("<r:bare_host />").as('example.com')
      end 
   end

   describe "<r:base_domain />" do

      it "should render the site's base domain" do
        @stub_page.request.stub!(:host).and_return('www.sub.example.com')
        @stub_page.should render("<r:base_domain />").as('example.com')
      end 

      it "should render the site's base domain" do
        @stub_page.request.stub!(:host).and_return('sub3.sub2.sub.example.com')
        @stub_page.should render("<r:base_domain />").as('sub2.sub.example.com')
      end 
   end

   describe "<r:img_host />" do
      it "should render images.{{bare_host}}" do
        page(:parent).should render("<r:img_host />").as("images.#{@hostname}")           
      end
   end

   describe "<r:img src='image_source' [other attributes...] />" do

      it "should inject 'http://{{img_host}}{{src}}' into a normal img tag." do
        page(:parent).should render("<r:img src='image_source' />").as("<img src=\"http://images.#{@hostname}/image_source\" />")        
      end
   end

   describe "<r:asset_link href='asset_path'>" do

      it "should renders a link to an asset relative to <r:img_host />" do
         page(:parent).should render("<r:asset_link href='asset_path' />").as("<a href=\"http://images.#{@hostname}/asset_path\"></a>")        
      end
   end

   describe "<r:updated_at />" do
       it "should give the date the page was last modified (from first)" do
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
        it "should render host name (from #{page})" do
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

      it "should error with no matches attribute" do
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

      it "should error with no matches attribute" do
        @stub_page.request.stub!(:env).and_return({'HTTP_REFERER' => 'www.example.com'})
        @stub_page.should render("<r:unless_referer>Display this</r:unless_referer>").with_error("`unless_referer' tag must contain a `matches' attribute.")
      end
    end    
  end     

  private

  def page(symbol = nil)
    if symbol.nil?
      @page ||= pages(:assorted)
    else
      @page = pages(symbol)
    end
  end

end
