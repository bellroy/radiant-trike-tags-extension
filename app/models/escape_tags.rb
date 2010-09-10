module EscapeTags
  include Radiant::Taggable
  
  tag "escape" do |tag|
    tag.expand
  end

  desc %{
    URI escapes its contents.
    
    *Usage:*
    <pre><code><r:escape:uri>some content</r:escape:uri></code></pre>
    <pre><code> => some%20content</code></pre>
  }
  tag "escape:uri" do |tag|
    URI.escape tag.expand
  end
end
