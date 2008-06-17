require File.dirname(__FILE__) + '/../spec_helper'

describe "TrikeTags module" do 
  scenario :users_and_pages

  before do
    # from pages scenario    
    # - Home
    # -- First
    # -- Parent
    # --- Child
    # ---- Grandchild
    # ----- Great Grandchild
  end

  describe "<r:site_area />" do
    fixture = [
      #  From page          Expectation
      [:home,             'homepage'],
      [:parent,           'parent'],  
      [:child,            'parent'],
      [:grandchild,       'parent'],
      [:great_grandchild, 'parent']
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
      [:great_grandchild, 'child']
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

      [:news,       "/parent",                  ''],
      [:article_2,  "/parent/child/grandchild", '']
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
      [:parent,     "/parent/child",            'current'],
      [:parent,     "/parent/child/grandchild", 'current'],

      [:child,      "/",                        ''],
      [:child,      "/parent",                  ''],
      [:child,      "/parent/child",            'current'],
      [:child,      "/parent/child/grandchild", 'current'],

      [:grandchild, "/",                        ''],
      [:grandchild, "/parent",                  ''],
      [:grandchild, "/parent/child",            'current'],
      [:grandchild, "/parent/child/grandchild", 'current'],

      [:home,       "/parent/child",            ''],

      [:news,       "/parent",                  ''],
      [:article_2,  "/parent/child/grandchild", '']
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

      [:news,       "/parent",                  ''],
      [:article_2,  "/parent/child/grandchild", '']    
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
      [:home,       "/news",                      "News",             '<a href="/news">News</a>'],    

      [:news,       "/parent",                    "Parent",           '<a href="/parent">Parent</a>'],
      [:article_2,  "/parent/child/grandchild",   "GrandChild",       '<a href="/parent/child/grandchild">GrandChild</a>']        
    ]
    fixture.each do |page, path, link_text, expectation|
      it "should render a simple link and add class='current' if it's a link to the current page (from #{page})" do
        page(page).should render("<r:link_with_current href='#{path}'>#{link_text}</r:link_with_current>").as(expectation)
      end    
   end 
  end  



  describe "<r:next>" do
  
    fixture = [
    #  From page     Order by                   Expectation
      [:another,    "title",                    "Assorted"],
      [:article,    "title",                    "Article 2"],
      [:article_4,  "title",                    ""], #confirm on "". no published page after article 4
      [:radius,     "title",                    ""], #confirm on virtual page   
      [:first,      "title",                    "Hidden"],#confirm whether we should get hidden page

      [:home,       "published_at",             ""],
      [:article_2,  "published_at",             "Article 3"],
      [:article,    "published_at",             "Article 2"],
      [:article_4,  "published_at",             "Draft Article"], #confirm as above. no published page after article 4
      [:virtual,    "published_at",             ""] #which is correct "" or "Virtual"   
    ]
    fixture.each do |page, order_by, expectation|
      it "should set the page context to the next page sibling." do
        page(page).should render("<r:next by='#{order_by}'><r:title /></r:next>").as(expectation) 
      end
    end
    
    fixture = [
    #  From page                   Expectation
      [:home,                      ""],
      [:another,                   "Assorted"],
      [:article,                   "Article 2"], 
      [:hidden,                    "News"]
    ]
    fixture.each do |page,  expectation|
      it "should set the page context to the next page sibling." do
        page(page).should render("<r:next><r:title /></r:next>").as(expectation) 
      end
    end
  end 



 describe "<r:previous>" do
   
    fixture = [
    #  From page     Order by                   Expectation
      [:home,       "title",                    ""],
      [:another,    "title",                    ""],
      [:article,    "title",                    ""],  
      [:a,          "title",                    ""],

      [:article_3,  "published_at",             "Article 2"],
      [:article_2,  "published_at",             "Article"], 
      [:article,    "published_at",             ""]
    ]
    fixture.each do |page, order_by, expectation|
      it "should set the page context to the next page sibling." do
        page(page).should render("<r:previous by='#{order_by}'><r:title /></r:previous>").as(expectation) 
      end
    end
    
    fixture = [
    #  From page                   Expectation
      [:first,                     "Draft"], #confirm weather it should be "Devtags" as Draft is not yet in published state
      [:article,                   ""],      #confirm on "".
      [:hidden,                    "First"],
      [:virtual,                   ""]
    ]
    fixture.each do |page,  expectation|
      it "should set the page context to the next page sibling." do
        page(page).should render("<r:previous><r:title /></r:previous>").as(expectation) 
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
