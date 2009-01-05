require File.dirname(__FILE__) + '/../spec_helper'

describe ": sibling tags :" do
  scenario :users, :home_page

  describe "<r:next> and <r:previous>", "with 'by' property supplied" do
    class VirtualPage < Page
      def virtual?
        true
      end
    end
    
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
