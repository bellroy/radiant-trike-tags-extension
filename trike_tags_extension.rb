# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class TrikeTagsExtension < Radiant::Extension
  version "2.0"
  description "A handfull of Radiant tags that we've found generally useful."
  
  url "https://svn.trike.com.au/source/radiant/extensions/trike_tags"
  
  # define_routes do |map|
  #   map.connect 'admin/trike_tags/:action', :controller => 'admin/trike_tags'
  # end
  
  def activate
    # admin.tabs.add "Trike Tags", "/admin/trike_tags", :after => "Layouts", :visibility => [:all]
    Page.send :include, TrikeTags
  end
  
  def deactivate
    # admin.tabs.remove "Trike Tags"
  end
  
end
