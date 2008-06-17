module TrikeTags
  include Radiant::Taggable

  desc %{
    Returns the top level parent page slug (which functions nicely as a site area name)

    *Usage:*
    <pre><code><r:site_area /></code></pre>
  }
  tag "site_area" do |tag|
    site_area(tag)
  end

  desc %{
    Returns the second level parent page slug (which functions nicely as a site sub-area name)

    *Usage:*
    <pre><code><r:site_subarea /></code></pre>
  }
  tag "site_subarea" do |tag|
    site_subarea(tag)
  end

  desc %{
    Returns "current" if the local page context is in the same site_area as the global page context.

    *Usage:*
    <pre><code><r:current_if_same_site_area /></code></pre>
  }
  tag "current_if_same_site_area" do |tag|
    local_page = tag.locals.page
    local_site_area = site_area(tag)
    tag.locals.page = tag.globals.page
    global_site_area = site_area(tag)
    tag.locals.page = local_page

    local_site_area == global_site_area ? "current" : ""
  end

  desc %{
    Returns "current" if the local page context is in the same site_subarea as the global page context.

    *Usage:*
    <pre><code><r:current_if_same_site_subarea /></code></pre>
  }
  tag "current_if_same_site_subarea" do |tag|
    local_page = tag.locals.page
    local_site_subarea = site_subarea(tag)
    tag.locals.page = tag.globals.page
    global_site_subarea = site_subarea(tag)
    tag.locals.page = local_page

    ((local_site_subarea == global_site_subarea) and (local_site_subarea != "" or global_site_subarea != "")) ? "current" : ""
  end

  desc %{
    Returns "current" if the local page context is the same as the global page context.

    *Usage:*
    <pre><code><r:current_if_same_page /></code></pre>
  }
  tag "current_if_same_page" do |tag|
    tag.locals.page == tag.globals.page ? "current" : ""
  end

  desc %{
    Renders a simple link and adds class="current" if it's a link to the current page

    *Usage:*
    <pre><code><r:link_with_current href="href">…</link_with_current></code></pre>
  }
  tag "link_with_current" do |tag|
    options = tag.attr.dup

    anchor = options['anchor'] ? "##{options.delete('anchor')}" : ''
    current = nil
    if options['href']
      href = options.delete('href')
      current = tag.locals.page.url.match("^#{href}/?$")
    else
      href = tag.render('url')
      current = tag.locals.page == tag.globals.page
    end
    options['class'] = "#{options['class']} current".strip if current
    attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
    attributes = " #{attributes}" unless attributes.empty?
    text = tag.double? ? tag.expand : tag.render('title')
    %{<a href="#{href}#{anchor}"#{attributes}>#{text}</a>}
  end
  
  desc %{
    Sets page context to next page sibling.
    Useful, say, for doing getting a link like this: 
    
    <pre><code><r:next by="title"><r:link/></r:next></code></pre>
    
    *Usage:*
    <pre><code><r:next [by="sort_order"]>...</r:next></code></pre>
  }
  tag "next" do |tag|
    sibling_page(:next, tag)
  end

  desc %{
    Sets page context to previous page sibling.
    Useful, say, for doing getting a link like this: 
    <pre><code><r:previous by="title"><r:link/></r:previous></code></pre>
    
    *Usage:*
    <pre><code><r:previous [by="sort_order"]>...</r:previous></code></pre>
  }
  tag "previous" do |tag|
    sibling_page(:previous, tag)
  end

  desc %{
    Renders full url, including the http://
    
    *Usage:*
    <pre><code><r:full_url /></code></pre>
  }
  tag "full_url" do |tag|
    url  = tag.locals.page.url
    "http://#{host(tag)}#{url}"
  end

  desc %{ 
    Renders the site host.
    To do that it tries (in order):
    # page.site.base_domain from multi_site extension
    # request.host
    # root page "host" page part
    # raises an error complaining about lack of a root page 'host' part

    *Usage:*
    <pre><code><r:host /></code></pre>
  }
  tag 'host' do |tag|
    host(tag)
  end
  tag 'bare_host' do |tag|
    bare_host(tag)
  end


  desc %{
    Renders the site's base domain (host, less any subdomains).
    
    *Examples:*
      "a.b.com"      => "b.com",
      "a.b.c.com"    => "b.c.com",
      "a.b.c.com.au" => "b.c.com.au",
      "a.b.aero"     => "b.aero"
    
    *Usage:*
    <pre><code><r:base_domain /></r:base_domain></code></pre>
  }
  tag 'base_domain' do |tag|
    begin
      host = bare_host(tag)
      host.match(/[^\.]+\.(.*)$/)
      $1 || "."
    rescue StandardTags::TagError => e
      e.message.sub!(/`host' tag/, "`img_host' tag")
      raise e
    end
  end
  
  desc %{ 
    images.{{bare_host}}

    *Usage:*
    <pre><code><r:img_host /></code></pre>
  }
  tag 'img_host' do |tag|
    img_host(tag)
  end

  desc %{ 
    Injects "http://{{img_host}}{{src}}" into a normal img tag.

    *Usage:*
    <pre><code><r:img src="image_source" [other attributes...] /></code></pre>
  }
  tag 'img' do |tag|
    unless tag.attributes && tag.attributes.keys && tag.attributes.include?("src")
      raise StandardTags::TagError.new("`img' tag must contain a `src' attribute.")
    end
    options = tag.attr.dup
    src = options['src'] ? "#{options.delete('src')}" : ''
    src.sub!(/^\/?/,'/')
    attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
    attributes = " #{attributes}" unless attributes.empty?
    begin
      %{<img src="http://#{img_host(tag)}#{src}"#{attributes} />}
    rescue StandardTags::TagError => e
      e.message.sub!(/`img_host' tag/, "`img' tag")
      raise e
    end
  end
  
  desc %{
    Renders a link to an asset relative to <code><r:img_host /></code>
    
    *Usage:*
    <pre><code><r:asset_link href="asset_path"></code></pre>
  }
  tag "asset_link" do |tag|
    options = tag.attr.dup
    href = options['href'] ? "#{options.delete('href')}" : ''
    begin
      %Q{<a href="http://#{img_host(tag)}/#{href}">#{tag.expand}</a>}
    rescue StandardTags::TagError => e
      e.message.sub!(/`img_host' tag/, "`asset_link' tag")
      raise e
    end
  end
  

  desc %{
    Renders the date the page was last modified
    
    *Usage:*
    <pre><code><r:modification_date /></code></pre>
  }
  tag "updated_at" do |tag|
    tag.locals.page.updated_at.xmlschema
  end

  desc %{
    Page attribute tags inside this tag refer to the current page's ancestor who is a child of the site root.
    
    *Usage:*
    <pre><code><r:section_root>...</r:section_root></code></pre>
  }
  tag "section_root" do |tag|
    ancestors = tag.locals.page.ancestors
    section_root = if ancestors.size == 1
                     tag.locals.page
                   elsif ancestors.size > 1
                     ancestors[-2]
                   else
                     nil
                   end
    tag.locals.page = section_root
    tag.expand if section_root
  end
  
  desc %{
    Renders the containing elements only if the page's referer matches the regular expression
    given in the @matches@ attribute. If the @ignore_case@ attribute is set to false, the
    match is case sensitive. By default, @ignore_case@ is set to true.
    
    Doesnt work with page caching! So for pages that use this, caching has to be turned off.
    
    *Usage:*
    <pre><code><r:if_referer matches="regexp" [ignore_case="true|false"]>...</if_url></code></pre>
  }
  tag 'if_referer' do |tag|
    unless tag.attr.has_key?('matches')
      raise StandardTags::TagError.new("`if_referer' tag must contain a `matches' attribute.")
    end
    regexp = build_regexp_for(tag, 'matches')
    if (referer = tag.globals.page.request.env['HTTP_REFERER'] && referer.match(regexp))
       tag.expand 
    end
  end
  
  desc %{
    The opposite of the @if_referer@ tag.
    
    *Usage:*
    <pre><code><r:unless_referer matches="regexp" [ignore_case="true|false"]>...</unless_referer></code></pre>
  }  
  tag 'unless_referer' do |tag|
    unless tag.attr.has_key?('matches')
      raise StandardTags::TagError.new("`unless_referer' tag must contain a `matches' attribute.")
    end
    regexp = build_regexp_for(tag, 'matches')
    referer = tag.globals.page.request.env['HTTP_REFERER']
    unless referer && referer.match(regexp)
       tag.expand
    end
  end


  private

  # kudos to http://seansantry.com/projects/blogtags/ for the inspiration
  def sibling_page(flag, tag)
    page_index = case flag
                 when :next
                   1
                 when :previous
                   -1
                 else
                   raise ArgumentError, "flag must be :next or :previous"
                 end
    current = tag.locals.page
    order_by = Page.column_names.include?('position') ? 'position' : 'title'
    by = (tag.attr['by'] || order_by).strip

    unless current.attributes.keys.include?(by)
      raise StandardTags::TagError.new("`by' attribute of `#{flag}' tag must be set to a valid page attribute name.")
    end
    # get the page's siblings, exclude any that have nil for the sorting
    # attribute, exclude virtual pages, and sort by the chosen attribute
    siblings = current.self_and_siblings.delete_if { |s| s.send(by).nil? || s.virtual? }.sort_by { |page| page.attributes[by] }
    if index = siblings.index(current)
      new_page_index = index + page_index
      new_page = new_page_index >= 0 ? siblings[new_page_index] : nil

      if new_page
        tag.locals.page = new_page
        tag.expand
      end
    end
  end

  def host(tag)
    host = nil
    page = tag.locals.page
    root = page.root
    if (host_part = root.part('host'))
      host = host_part.content.sub(%r{/?$},'').sub(%r{^https?://},'').strip # strip trailing slash or leading protocol
    elsif root.respond_to?(:site) && root.site
      # multi_site extension is running
      host = root.site.base_domain
    elsif (request = tag.globals.page.request) && request.host
      host = request.host
      if host.nil? || host.empty? || host.match(/^\s*$/)
        raise(StandardTags::TagError.new("request.host is returning something very unexpected (#{request.host.inspect}). You could override this behaviour by providing a 'host' page part on the site root page that contains the hostname."))
      end
    end
    if host.nil? || host.empty? || host.match(/^\s*$/)
      raise(StandardTags::TagError.new("`host' tag requires the root page to have a `host' page part that contains the hostname."))
    else
      host
    end
  end

  def bare_host(tag)
    host(tag).sub(/^www\./,'')
  end

  def img_host(tag)
    begin
      %{images.#{bare_host(tag)}}
    rescue StandardTags::TagError => e
      e.message.sub!(/`host' tag/, "`img_host' tag")
      raise e
    end
  end

  def site_area(tag)
    page = tag.locals.page
    unless page.part("site_area").nil?
      page.part("site_area").content
    else
      case slug = page.url[1..-1].split(/\//).first
      when nil
        "homepage"
      when /^\d/
        "n#{slug}"
      else
        slug
      end
    end
  end

  def site_subarea(tag)
    page = tag.locals.page
    unless page.part("site_subarea").nil?
      page.part("site_subarea").content
    else
      case slug = page.url[1..-1].split(/\//)[1]
      when nil
        ""
      when /^\d/
        "n#{uri}"
      else
        slug
      end
    end
  end
end
