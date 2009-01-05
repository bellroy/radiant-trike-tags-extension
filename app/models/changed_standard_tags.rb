module ChangedStandardTags
  include Radiant::Taggable

  desc %{
    Renders the @url@ attribute of the current page. Respects trailingslash attribute or Radiant::Config['defaults.trailingslash'].
    
    *Usage:*
    <pre><code><r:url [trailingslash="true|false"] /></code></pre>
  }
  tag 'url' do |tag|
    url = relative_url_for(tag.locals.page.url, tag.globals.page.request)
    unless default_slash?(tag)
      url.sub(%r'(.)/$','\1')
    else
      url
    end
  end

  desc %{ 
    Renders a link to the page. When used as a single tag it uses the page's title
    for the link name. When used as a double tag the part in between both tags will
    be used as the link text. The link tag passes all attributes over to the HTML
    @a@ tag. This is very useful for passing attributes like the @class@ attribute
    or @id@ attribute. If the @anchor@ attribute is passed to the tag it will
    append a pound sign (<code>#</code>) followed by the value of the attribute to
    the @href@ attribute of the HTML @a@ tag--effectively making an HTML anchor.
    Respects trailingslash attribute or Radiant::Config['defaults.trailingslash'].
    
    *Usage:*
    <pre><code><r:link [anchor="name"] [trailingslash="true|false"] [other attributes...] /></code></pre>
    or
    <pre><code><r:link [anchor="name"] [trailingslash="true|false"] [other attributes...]>link text here</r:link></code></pre>
  }
  tag 'link' do |tag|
    options = tag.attr.dup
    anchor = options['anchor'] ? "##{options.delete('anchor')}" : ''
    options.delete('trailingslash') # we look in tag.attr, but don't want this getting through to the <a> tag
    attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
    attributes = " #{attributes}" unless attributes.empty?
    text = tag.double? ? tag.expand : tag.render('title')
    %{<a href="#{tag.render('url', tag.attr.dup)}#{anchor}"#{attributes}>#{text}</a>}
  end

private
  def booleanize(a_string)
    case a_string.downcase.strip
    when 'true', 'yes', 'on', 't', '1', 'y'
      return true
    else
      return false
    end
  end

  def default_slash?(tag)
    if tag.attr['trailingslash']
      booleanize(tag.attr['trailingslash'])
    elsif Radiant::Config['defaults.trailingslash']
      booleanize(Radiant::Config['defaults.trailingslash'])
    else
      true
    end
  end
  
end