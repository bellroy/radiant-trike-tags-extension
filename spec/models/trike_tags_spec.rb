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

      [:news,       "/parent",                  ''],
      [:article_2,  "/parent/child/grandchild", ''],
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
      [:article_2,  "/parent/child/grandchild", ''],
    ]
    fixture.each do |page, path, expectation|
      it "should return 'current' if the local page context is in the same site_subarea as the global page context (from #{page})" do
        page(page).should render("<r:find url='#{path}'><r:current_if_same_site_subarea /></r:find>").as(expectation)
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
