# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class TrikeTagsExtension < Radiant::Extension
  version "2.1"
  description "A handfull of Radiant tags that we've found generally useful."
  
  url "http://github.com/tricycle/radiant-trike-tags-extension"
  
  def activate
    Page.class_eval do
      include SiteAreaTags
      include SiblingTags
      include UrlTags
      include EmbedRemoteTags
      include EnvironmentTags
      include ChangedStandardTags
    end
  end
  
end
