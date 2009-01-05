require File.dirname(__FILE__) + '/../spec_helper'

describe ": site_area tags :" do
  scenario :users, :home_page

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
