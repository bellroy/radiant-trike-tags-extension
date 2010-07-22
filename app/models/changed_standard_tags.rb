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

  desc %{
    Cycles through each of the children. Inside this tag all page attribute tags
    are mapped to the current child page.

    *Usage:*

    <pre><code><r:children:each [offset="number"] [limit="number"] [by="attribute"] [order="asc|desc"]
     [status="draft|reviewed|published|hidden|all"]>
     ...
    </r:children:each>
    </code></pre>
  }
  tag 'children:each' do |tag|
    options = children_find_options(tag)
    result = []
    children = tag.locals.children
    tag.locals.previous_headers = {}
    tag.locals.header_counts = { :all => 0 }
    kids = children.find(:all, options)
    kids.each_with_index do |item, i|
      tag.locals.child = item
      tag.locals.page = item
      tag.locals.first_child = i == 0
      tag.locals.last_child = i == kids.length - 1
      result << tag.expand
    end
    result
  end

  desc %{
    Renders the tag contents only if the contents do not match the previous header. This
    is extremely useful for rendering date headers for a list of child pages.

    If you would like to use several header blocks you may use the @name@ attribute to
    name the header. When a header is named it will not restart until another header of
    the same name is different.

    Using the @restart@ attribute you can cause other named headers to restart when the
    present header changes. Simply specify the names of the other headers in a semicolon
    separated list.

    Using the @limit@ attribute you can cause header to stop emitting headers after a
    specified number of distinct headers have been output.

    *Usage:*

    <pre><code><r:children:each>
      <r:header [name="header_name"] [restart="name1[;name2;...]"] [limit="number"]>
        ...
      </r:header>
    </r:children:each>
    </code></pre>
  }
  tag 'children:each:header' do |tag|
    previous_headers = tag.locals.previous_headers
    name = tag.attr['name'] || :unnamed
    restart = (tag.attr['restart'] || '').split(';')
    limit = tag.attr['limit'].try(:to_i)
    header = tag.expand
    over_limit = limit && tag.locals.header_counts[:all] >= limit
    if header != previous_headers[name] && !over_limit
      previous_headers[name] = header
      unless restart.empty?
        restart.each do |n|
          previous_headers[n] = nil
        end
      end
      tag.locals.header_counts[:all] += 1
      header
    end
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
