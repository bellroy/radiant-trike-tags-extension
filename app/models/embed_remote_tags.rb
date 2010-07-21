Page.class_eval do
  attr_accessor :cacheable

  def cacheable
    @cacheable.nil? ? true : @cacheable
  end

  def cache_with_preference_check?
    cache_without_preference_check? && cacheable
  end
  alias_method_chain :cache?, :preference_check
end

module EmbedRemoteTags
  include Radiant::Taggable
  desc %{
    renders the content of a remote URI to the page
    *Usage:*
     <pre><code>&lt;r:embed_remote uri="http://google.com/embed" /></code></pre>
  }
  tag 'embed_remote' do |tag|
    options = tag.attr.dup
    unless options && options.keys && options.include?("uri")
      raise StandardTags::TagError.new("`embed' tag must contain a `uri' attribute.")
    end

    begin
      response = Net::HTTP.get_response(URI.parse(options['uri']))
      code = response && response.code
      raise unless code == '200'
      return response.body
    rescue Exception
      page = tag.context.page
      page.cacheable = false
      page.response.headers['Status'] = '503'

      return "This information is temporarily unavailable."
    end
  end
end
