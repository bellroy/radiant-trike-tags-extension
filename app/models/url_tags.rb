module UrlTags
  include Radiant::Taggable
  
  desc %{
    Renders full url, including the http://
    
    *Usage:*
    <pre><code><r:full_url /></code></pre>
  }
  tag "full_url" do |tag|
    "http://#{host(tag)}#{tag.render("url")}"
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
    images.[bare_host]

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
    Renders the date the page was last modified in xmlschema format (ideal for xml feeds like sitemap.xml)
    
    *Usage:*
    <pre><code><r:updated_at /></code></pre>
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

    if section_root
       found = Page.find_by_url(absolute_path_for(tag.locals.page.url, section_root.url))
 	if page_found?(found) 
	  tag.locals.page = found
	  tag.expand
	end
     end

  end
  
  desc %{
    Renders the containing elements only if the page's referer matches the regular expression
    given in the @matches@ attribute. If the @ignore_case@ attribute is set to false, the
    match is case sensitive. By default, @ignore_case@ is set to true.
    
    Doesnt work with page caching! So for pages that use this, caching has to be turned off.
    
    *Usage:*
    <pre><code><r:if_referer matches="regexp" [ignore_case="true|false"]>...</if_referer></code></pre>
  }
  tag 'if_referer' do |tag|
    unless tag.attr.has_key?('matches')
      raise StandardTags::TagError.new("`if_referer' tag must contain a `matches' attribute.")
    end
    regexp = build_regexp_for(tag, 'matches')
    if ((referer = tag.globals.page.request.env['HTTP_REFERER']) && referer.match(regexp))
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
  
end
