# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class TrikeTagsExtension < Radiant::Extension
  version "2.1"
  description "A handfull of Radiant tags that we've found generally useful."
  
  url "https://svn.trike.com.au/source/radiant/extensions/trike_tags"
  
  def activate
    Page.class_eval do
      include SiteAreaTags
      include SiblingTags
      include UrlTags
      include ChangedStandardTags
    end
  end
  
end
