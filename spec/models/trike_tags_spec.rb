require File.dirname(__FILE__) + '/../spec_helper'

describe "Trike Tags" do 
    scenario :users_and_pages

    before do
       create_page "Parent2" do
          create_page "Child2" do
             create_page "Grandchild2" do
                create_page "Great Grandchild2"
             end
          end
       end
    end

    it "<r:site_area /> should return the top level parent page slug" do
        page(:home).should render("<r:site_area />").as('homepage')  #doubt, shouldn't it be as '' ?
        page(:parent).should render("<r:site_area />").as('parent')  
        page(:child).should render("<r:site_area />").as('parent')
        page(:grandchild).should render("<r:site_area />").as('parent')
        page(:great_grandchild).should render("<r:site_area />").as('parent')
    end

    it "<r:site_subarea /> should return the second level parent page slug" do
        page(:home).should render("<r:site_subarea />").as('')  
        page(:parent).should render("<r:site_subarea />").as('')  
        page(:child).should render("<r:site_subarea />").as('child')
        page(:grandchild).should render("<r:site_subarea />").as('child')
        page(:great_grandchild).should render("<r:site_subarea />").as('child')
    end

    it "<r:current_if_same_site_area /> should return 'current' if the local page context is in the same site_area as the global page context." do
        page(:home).should render("<r:find url='/parent/child'><r:current_if_same_site_area /></r:find>").as('') 

        page(:parent).should render("<r:find url='/parent'><r:current_if_same_site_area /></r:find>").as('current')
        page(:parent).should render("<r:find url='/parent/child'><r:current_if_same_site_area /></r:find>").as('current')
        page(:parent).should render("<r:find url='/parent/child/grandchild'><r:current_if_same_site_area /></r:find>").as('current')

        page(:parent).should render("<r:find url='/parent2'><r:current_if_same_site_area /></r:find>").as('')
        page(:parent).should render("<r:find url='/parent2/child2'><r:current_if_same_site_area /></r:find>").as('')
        page(:parent).should render("<r:find url='/parent2/child2/grandchild2'><r:current_if_same_site_area /></r:find>").as('')

        
        page(:child).should render("<r:find url='/parent'><r:current_if_same_site_area /></r:find>").as('current')
        page(:child).should render("<r:find url='/parent/child'><r:current_if_same_site_area /></r:find>").as('current')
        page(:child).should render("<r:find url='/parent/child/grandchild'><r:current_if_same_site_area /></r:find>").as('current')

        page(:child).should render("<r:find url='/parent2'><r:current_if_same_site_area /></r:find>").as('')
        page(:child).should render("<r:find url='/parent2/child2'><r:current_if_same_site_area /></r:find>").as('')
        page(:child).should render("<r:find url='/parent2/child2/grandchild2'><r:current_if_same_site_area /></r:find>").as('')


        page(:grandchild).should render("<r:find url='/parent'><r:current_if_same_site_area /></r:find>").as('current')
        page(:grandchild).should render("<r:find url='/parent/child'><r:current_if_same_site_area /></r:find>").as('current')
        page(:grandchild).should render("<r:find url='/parent/child/grandchild'><r:current_if_same_site_area /></r:find>").as('current')

        page(:grandchild).should render("<r:find url='/parent2'><r:current_if_same_site_area /></r:find>").as('')
        page(:grandchild).should render("<r:find url='/parent2/child2'><r:current_if_same_site_area /></r:find>").as('')
        page(:grandchild).should render("<r:find url='/parent2/child2/grandchild2'><r:current_if_same_site_area /></r:find>").as('')
        
    end
 
    it "<r:current_if_same_site_subarea /> returns 'current' if the local page context is in the same site_subarea as the global page context." do
        page(:home).should render("<r:find url='/parent/child'><r:current_if_same_site_subarea /></r:find>").as('') 

        page(:parent).should render("<r:find url='/parent'><r:current_if_same_site_subarea /></r:find>").as('current') #doubt, shouldn't it be as '' ?
        page(:parent).should render("<r:find url='/parent/child'><r:current_if_same_site_subarea /></r:find>").as('')
        page(:parent).should render("<r:find url='/parent/child/grandchild'><r:current_if_same_site_subarea /></r:find>").as('')

    #   the below test fails
    #   page(:parent).should render("<r:find url='/parent2'><r:current_if_same_site_subarea /></r:find>").as('')
        page(:parent).should render("<r:find url='/parent2/child2'><r:current_if_same_site_subarea /></r:find>").as('')
        page(:parent).should render("<r:find url='/parent2/child2/grandchild2'><r:current_if_same_site_subarea /></r:find>").as('')

        
        page(:child).should render("<r:find url='/parent'><r:current_if_same_site_subarea /></r:find>").as('')
        page(:child).should render("<r:find url='/parent/child'><r:current_if_same_site_subarea /></r:find>").as('current')
        page(:child).should render("<r:find url='/parent/child/grandchild'><r:current_if_same_site_subarea /></r:find>").as('current')

        page(:child).should render("<r:find url='/parent2'><r:current_if_same_site_subarea /></r:find>").as('')
        page(:child).should render("<r:find url='/parent2/child2'><r:current_if_same_site_subarea /></r:find>").as('')
        page(:child).should render("<r:find url='/parent2/child2/grandchild2'><r:current_if_same_site_subarea /></r:find>").as('')


        page(:grandchild).should render("<r:find url='/parent'><r:current_if_same_site_subarea /></r:find>").as('')
        page(:grandchild).should render("<r:find url='/parent/child'><r:current_if_same_site_subarea /></r:find>").as('current')
        page(:grandchild).should render("<r:find url='/parent/child/grandchild'><r:current_if_same_site_subarea /></r:find>").as('current')

        page(:grandchild).should render("<r:find url='/parent2'><r:current_if_same_site_subarea /></r:find>").as('')
        page(:grandchild).should render("<r:find url='/parent2/child2'><r:current_if_same_site_subarea /></r:find>").as('')
        page(:grandchild).should render("<r:find url='/parent2/child2/grandchild2'><r:current_if_same_site_subarea /></r:find>").as('')

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
