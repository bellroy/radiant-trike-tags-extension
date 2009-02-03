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

    unless Page.column_names.include?("position")
      
      describe 'without re-order extension installed' do
        before(:each) do
          create_page "c"
          create_page "a"
          create_page "b"
        end

        describe "<r:previous>" do
          fixtures = [
              [:a, ""],
              [:b, "a"],
              [:c, "b"],
          ]
          fixtures.each do |page,  expectation_with_position, expectation_without_position|
            it "should set the page context to the previous page sibling ordered by title." do
              page(page).should render("<r:previous><r:title /></r:previous>").as(expectation_without_position) 
            end
          end
        end 
        
        describe "<r:next>" do
          fixtures = [
              [:a, "b"],
              [:b, "c"],
              [:c, ""],
          ]
          fixtures.each do |page,  expectation|
            it "should set the page context to the next sibling ordered by title." do
              page(page).should render("<r:next><r:title /></r:next>").as(expectation) 
            end
          end

          it 'should not return child page as sibling page' do
            create_page 'page' do
              create_page 'child'
            end
            create_page 'sibling'

            page(:page).should render("<r:next><r:title /></r:next>").as('sibling') 
          end
        end
      end
      
    else
      
      describe 'with re-order extension installed' do
        before(:each) do
          create_page "a_pos_2", :position => 2
          create_page "b_pos_1", :position => 1
          create_page "c_pos_0", :position => 0
        end
        
        describe "<r:previous>" do
          fixtures = [
            [:c_pos_0,  ""],
            [:b_pos_1,   "c_pos_0"],
            [:a_pos_2,  "b_pos_1"],
          ]
          fixtures.each do |page,  expectation|
            it "should set the page context to the previous sibling ordered by position." do
              page(page).should render("<r:previous><r:title /></r:previous>").as(expectation)
            end
          end
        end
        
        describe '<r:next>' do
          [
              [:c_pos_0,  "b_pos_1"],
              [:b_pos_1,   "a_pos_2"],
              [:a_pos_2,  ""],
          ].each do |page_title,  expectation|
            it "should set the page context to the next sibling ordered by position." do
              page(page_title).should render("<r:next><r:title /></r:next>").as(expectation) 
            end
          end

          it 'should not return child page as sibling page' do
            create_page 'page' do
              create_page 'child'
            end
            create_page 'sibling'

            page(:page).should render("<r:next><r:title /></r:next>").as('sibling') 
          end
        end
        
      end
      
    end

  end
end
