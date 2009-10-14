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
    Net::HTTP.get(URI.parse(options['uri']))
  end
end