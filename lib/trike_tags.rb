# TrikeTags
require 'page_context'

class PageContext < Radius::Context
  alias_method :old_init, :initialize

  def initialize(page)
    old_init page

    # <r:site_area />
    #
    # Returns the top level parent page slug (which functions nicely as a site area name)
    define_tag "site_area" do |tag|
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
    define_tag "link_with_current" do |tag|
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
    define_tag "next" do |tag|
      sibling_page :next, tag
    end

    # <r:previous [by="sort_order"]>...</r:previous>
    #
    # Sets page context to previous page sibling.
    # Useful, say, for doing getting a link like this: <r:previous by="title"><r:link/></r:previous>
    define_tag "previous" do |tag|
      sibling_page :previous, tag
    end

    # <r:full_url />
    #
    # Full url, including the http://
    define_tag "full_url" do |tag|
      env_table(tag)['REQUEST_URI']
    end

    # <r:modification_date />
    #
    # Page#updated_at#to_formatted_s(:db)
    define_tag "updated_at" do |tag|
      tag.locals.page.updated_at.xmlschema
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
    by = (tag.attr['by'] || 'published_at').strip

    unless current.attributes.keys.include?(by)
      raise TagError.new("`by' attribute of `#{flag}' tag must be set to a valid page attribute name")
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
    tag.locals.page.instance_values["behavior"].instance_values['request'].instance_values['cgi'].instance_values['env_table']
  end
end
