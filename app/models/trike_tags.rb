module TrikeTags
  include Radiant::Taggable

  desc %{
    Returns the top level parent page slug (which functions nicely as a site area name)

    *Usage:*
    <pre><code><r:site_area /></code></pre>
  }
  tag "site_area" do |tag|
    unless tag.locals.page.part("site_area").nil?
      tag.locals.page.part("site_area").content
    else
      case uri = tag.locals.page.url[1..-1].split(/\//).first
      when nil
        "homepage"
      else
        uri
      end
    end
  end

  # <r:link_with_current href="href">...</link_with_current>
  #
  # Renders a simple link and adds class="current" if it's a link to the current page
  tag "link_with_current" do |tag|
    raise TagError.new("`link_with_current' tag must contain a `href' attribute.") unless tag.attr.has_key?('href')
    current = ( tag.locals.page.url.match("^#{tag.attr['href']}/?$").nil? ) ?
      nil :
                    ' class="current"'
                    href = tag.attr['href']
      "<a href=\"#{href}\"#{current}>#{tag.expand}</a>"
  end

  # <r:next [by="sort_order"]>...</r:next>
  #
  # Sets page context to next page sibling.
  # Useful, say, for doing getting a link like this: <r:next by="title"><r:link/></r:next>
  tag "next" do |tag|
    sibling_page(:next, tag)
  end

  # <r:previous [by="sort_order"]>...</r:previous>
  #
  # Sets page context to previous page sibling.
  # Useful, say, for doing getting a link like this: <r:previous by="title"><r:link/></r:previous>
  tag "previous" do |tag|
    sibling_page(:previous, tag)
  end

  # <r:full_url />
  #
  # Full url, including the http://
  tag "full_url" do |tag|
    host = tag.render("host")
    "http://#{host}#{tag.render("url")}"
  end

  desc %{ 
    Renders the site host.

    *Usage:*
    <pre><code><r:host /></code></pre>
  }
  tag 'host' do |tag|
    host_part = Page.root.part('host')
    if host_part
      host_part.content.sub(/\/?$/,'').sub(/^https?:\/\//,'')
    else  # attempt to get it from the request, which is flakey
      (a = env_table(tag)['REQUEST_URI']) && a.sub(/http:\/\//,'') || raise(StandardTags::TagError.new(
        "`host' tag requires the root page to have a `host' page part that contains the hostname."))
    end
  end

  desc %{ 
    Injects "http://images.{{host}}" into a normal img tag.

    *Usage:*
    <pre><code><r:img src="image_source" [other attributes...] /></code></pre>
  }
  tag 'img' do |tag|
    # unless tag.attributes && tag.attributes.keys && tag.attributes.include?("src")
    #   raise StandardTags::TagError.new("`img' tag must contain a `src' attribute.")
    # end
    options = tag.attr.dup
    src = options['src'] ? "#{options.delete('src')}" : ''
    src.sub!(/^\/?/,'/')
    attributes = options.inject('') { |s, (k, v)| s << %{#{k.downcase}="#{v}" } }.strip
    attributes = " #{attributes}" unless attributes.empty?
    begin
      %{<img src="http://images.#{tag.render('host')}#{src}"#{attributes} />}
    rescue StandardTags::TagError => e
      e.message.sub!(/`host' tag/, "`img' tag")
      raise e
    end
  end

  # <r:modification_date />
  #
  # Page#updated_at#to_formatted_s(:db)
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
    by = (tag.attr['by'] || 'published_at').strip

    unless current.attributes.keys.include?(by)
      raise StandardTags::TagError.new("`by' attribute of `#{flag}' tag must be set to a valid page attribute name.")
    end
    # get the page's siblings, exclude any that have nil 
    # for the sorting attribute, exclude virtual pages,
    # and sort by the chosen attribute
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

  def env_table(tag)
    (a = tag.locals.page.instance_values["behavior"]) && (b = a.instance_values['request']) && (c = b.instance_values['cgi']) && c.instance_values['env_table'] || {}
  end
end
