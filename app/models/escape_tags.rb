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

  desc %{
    CSV escapes its contents.
    By default, <code>swallow_newlines</code> is set to false.
    
    *Usage:*
    <pre><code><r:escape:csv [swallow_newlines="true|false"]>some, "content" that, might<br />
otherwise, cause trouble</r:escape:csv></code></pre>
    <pre><code> => some, """content"" that", "might<br />otherwise", cause trouble</code></pre>
  }
  tag "escape:csv" do |tag|
    options = tag.attr.dup
    ret = tag.expand.gsub(/"/,'""')
    ret.gsub!(/[\n\r]/,'') if options["swallow_newlines"] && options["swallow_newlines"] == "true"
    "\"#{ret}\""
  end

end
