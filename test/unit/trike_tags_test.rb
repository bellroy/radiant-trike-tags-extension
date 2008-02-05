require File.dirname(__FILE__) + '/../test_helper'

class TrikeTagsTest < Test::Unit::TestCase

  def setup
    setup_page(make_page!("Root"))
    @page.slug, @page.breadcrumb = "/", "/"
    @page.save!
  end

  # site_area
  def test_that_site_area_returns_the_right_thing_on_the_root_page
    assert_parse_output("homepage", "<r:site_area />")
  end
  def test_that_site_area_returns_the_right_thing_on_level_one_child_pages
    setup_page(make_kid!(@page, "Kid1"))

    assert_parse_output("kid1", "<r:site_area />")
  end
  def test_that_site_area_returns_the_right_thing_on_level_two_child_pages
    setup_page(make_kid!(make_kid!(@page, "Kid1"), "Kid1.1"))

    assert_parse_output("kid1", "<r:site_area />")
  end

  # link_with_current
  def test_that_link_with_current_returns_a_normal_link_when_not_linking_to_self
    assert_parse_output("<a href=\"/other_page\">Other Page</a>",
      "<r:link_with_current href=\"/other_page\">Other Page</r:link_with_current>")
  end
  def test_that_link_with_current_returns_a_class_current_link_when_linking_to_self_at_root_page
    assert_parse_output("<a href=\"/\" class=\"current\">Tester</a>",
      "<r:link_with_current href=\"/\">Tester</r:link_with_current>")
  end
  def test_that_link_with_current_returns_a_class_current_link_when_linking_to_self
    setup_page(make_page!("Kid1"))
    debugger

    assert_parse_output("<a href=\"/kid1\" class=\"current\">Tester</a>",
      "<r:link_with_current href=\"/kid1\">Tester</r:link_with_current>")
  end
  def test_that_link_with_current_returns_a_class_current_link_when_linking_with_trailing_slash_to_self
    setup_page(make_page!("Kid1"))

    assert_parse_output("<a href=\"/kid1/\" class=\"current\">Tester</a>",
      "<r:link_with_current href=\"/kid1/\">Tester</r:link_with_current>")
  end

  # next
  # def test_that_next_returns_next_sibling_when_one_exists
  #   kid1, kid2 = make_kids!(@page, "Kid1", "Kid2")
  #   setup_page(kid1)
  #   @page.stubs(:self_and_siblings).returns([kid1, kid2])

  #   assert_parse_output("/Kid2/", "<r:next><r:url /></r:next>")
  # end
  def test_that_next_returns_nil_when_no_next_sibling_exists
    kid1, kid2 = make_kids!(@page, "Kid1", "Kid2")
    setup_page(kid2)
    @page.stubs(:self_and_siblings).returns([kid1, kid2])

    assert_parse_output("", "<r:next><r:url /></r:next>")
  end

  # previous
  def test_that_previous_returns_nil_when_no_previous_sibling_exists
    kid1, kid2 = make_kids!(@page, "Kid1", "Kid2")
    setup_page(kid1)
    @page.stubs(:self_and_siblings).returns([kid1, kid2])

    assert_parse_output("", "<r:previous><r:url /></r:previous>")
  end
  # def test_that_previous_returns_previous_sibling_when_one_exists
  #   kid1, kid2 = make_kids!(@page, "Kid1", "Kid2")
  #   setup_page(kid2)
  #   @page.stubs(:self_and_siblings).returns([kid1, kid2])

  #   assert_parse_output("/Kid1/", "<r:previous><r:url /></r:previous>")
  # end

  # host
#    if tag.locals.page.respond_to?(:site)
#      # multi_site extension is running
#      tag.locals.page.site.base_domain
#    elsif (request = tag.globals.page.request) && request.host
#      request.host
#    else
#      host_part = Page.root.part('host')
#      if host_part
#        host_part.content.sub(%r{/?$},'').sub(%r{^https?://},'') # strip trailing slash or leading protocol
#      else  # attempt to get it from the request, which is flakey
#        (a = env_table(tag)['REQUEST_URI']) && a.sub(/http:\/\//,'') || raise(StandardTags::TagError.new(
#          "`host' tag requires the root page to have a `host' page part that contains the hostname."))
#      end
#    end
  def test_that_host_renders_from_response_if_that_is_defined
    flunk
  end
  def test_that_host_renders_the_host_page_part_from_site_root_if_that_exists
    part = stub(:content => "example.com")
    root_page = stub()
    root_page.stubs(:part).with("host").returns(part)
    Page.stubs(:root).returns(root_page)

    assert_parse_output("example.com", "<r:host />")
  end
  def test_that_host_renders_a_helpful_error_if_root_host_part_not_found
    root_page = stub()
    root_page.stubs(:part).with("host").returns(nil)
    Page.stubs(:root).returns(root_page)

    begin
      @parser.parse('<r:host />')
    rescue StandardTags::TagError => e
      assert e.message.match(/host.{1,3} tag/), "tag error doesn't mention 'host tag'"
      assert e.message.match(/root page/), "tag error doesn't mention 'root page'"
    end
  end

  # full_url
  def test_that_full_url_returns_the_full_url
    part = stub(:content => "example.com")
    root_page = stub()
    root_page.stubs(:part).with("host").returns(part)
    Page.stubs(:root).returns(root_page)

    assert_parse_output("http://example.com/", "<r:full_url />")

    setup_page(make_kid!(@page, "Kid1"))
    assert_parse_output("http://example.com/kid1/", "<r:full_url />")
  end

  # img
  def test_that_img_renders_an_image_tag_for_images_host
    part = stub(:content => "example.com")
    root_page = stub()
    root_page.stubs(:part).with("host").returns(part)
    Page.stubs(:root).returns(root_page)

    assert_parse_output(
      '<img src="http://images.example.com/dir/img.jpg" attr="arbitrary" />',
      '<r:img src="/dir/img.jpg" attr="arbitrary" />'
                       )
  end
  def test_that_img_removes_any_www
    part = stub(:content => "www.example.com")
    root_page = stub()
    root_page.stubs(:part).with("host").returns(part)
    Page.stubs(:root).returns(root_page)

    assert_parse_output(
      '<img src="http://images.example.com/dir/img.jpg" attr="arbitrary" />',
      '<r:img src="/dir/img.jpg" attr="arbitrary" />'
                       )
  end
  def test_that_img_renders_a_helpful_error_if_root_host_part_not_found
    root_page = stub()
    root_page.stubs(:part).with("host").returns(nil)
    Page.stubs(:root).returns(root_page)

    begin
      @parser.parse('<r:img src="/dir/img.jpg" attr="arbitrary" />')
    rescue StandardTags::TagError => e
      assert e.message.match(/img.{1,3} tag/), "tag error doesn't mention 'img tag'"
      assert e.message.match(/root page/), "tag error doesn't mention 'root page'"
    end
  end

  # updated_at
  def test_that_updated_at_returns_the_modification_date_in_correct_format
    a_time_string = "2007-04-02T05:32:21+10:00"
    @page.stubs(:updated_at).returns(Time.parse(a_time_string))

    assert_parse_output(a_time_string, "<r:updated_at />")
  end

  # section_root
  def test_that_section_root_tag_places_you_in_the_context_of_your_ancestral_root_child
    root = @page
    make_kids!(root, *%w[great_uncle great_aunt])
    grandparent = make_kid!(root, "grandparent")
    dad = make_kid!(grandparent, "dad")
    setup_page(make_kid!(dad, "me"))

    assert_parse_output("grandparent", "<r:section_root><r:title /></r:section_root>",
                        "Couldn't find grandparent.")

    setup_page(dad)

    assert_parse_output("grandparent", "<r:section_root><r:title /></r:section_root>",
                        "Couldn't find parent.")
  end
  def test_that_section_root_returns_nothing_if_on_root_page
    assert_parse_output("", "<r:section_root><r:title /></r:section_root>")
  end
  def test_that_section_root_returns_self_if_on_section_page
    root = @page
    make_kids!(root, *%w[bro sis])
    setup_page(make_kid!(root, "me"))

    assert_parse_output("me", "<r:section_root><r:title /></r:section_root>", "Couldn't find self.")
  end

  private

  def with(value)
    yield value
  end

  protected

  def setup_page(page)
    @page = page
    @context = PageContext.new(@page)
    @parser = Radius::Parser.new(@context, :tag_prefix => 'r')
    @page
  end

  def assert_parse_output(expected, input, msg=nil)
    output = @parser.parse(input)
    assert_equal expected, output, msg
  end

  def make_page!(title)
    p = Page.find_or_create_by_title(title)
    p.slug, p.breadcrumb = title.downcase, title
    p.parts.find_or_create_by_name("body")
    p.save!
    p
  end
  def make_kid!(page, title)
    kid = make_page!(title)
    page.children << kid
    page.save!
    kid
  end
  def make_kids!(page, *kids)
    kids.collect {|kid| make_kid!(page, kid) }
  end

end
