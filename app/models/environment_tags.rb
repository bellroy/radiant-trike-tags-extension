module EnvironmentTags
  include Radiant::Taggable

  desc %{
    Conditional evaluates inside block if rails environment
    matches parameter "name"
    
    #     *Usage:*
    #     <pre><code><r:if_env name="staging" />In staging environment</r:if_env></code></pre>
  }  
  tag 'if_env' do |tag|
    unless tag.attributes && tag.attributes.keys && tag.attributes.include?("name")
      raise StandardTags::TagError.new("`if_env' tag must contain a `name' attribute.")
    end
    if (RAILS_ENV == tag.attributes["name"])
      tag.expand
    end
  end
  

  desc %{
    Conditional evaluates inside block if rails environment
    matches parameter "name"
    
    #     *Usage:*
    #     <pre><code><r:unless_env name="staging" />Not in staging environment</r:unless_env></code></pre>
  }  
  tag 'unless_env' do |tag|
    unless tag.attributes && tag.attributes.keys && tag.attributes.include?("name")
      raise StandardTags::TagError.new("`unless_env' tag must contain a `name' attribute.")
    end
    unless (RAILS_ENV == tag.attributes["name"])
      tag.expand
    end
  end
end
