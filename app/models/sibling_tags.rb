module SiblingTags
  include Radiant::Taggable
  
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
    # attribute, exclude virtual pages and unpublished pages, and sort by the chosen attribute
    siblings = current.self_and_siblings.delete_if { |s| s.send(by).nil? || s.virtual? || !s.published? }.sort_by { |page| page.attributes[by] }
    if index = siblings.index(current)
      new_page_index = index + page_index
      new_page = new_page_index >= 0 ? siblings[new_page_index] : nil

      if new_page
        tag.locals.page = new_page
        tag.expand
      end
    end
  end
  
end