require 'test/unit'
require File.dirname(__FILE__) + '/../../../../test/test_helper'
require 'stubba'

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
  def test_that_link_with_current_returns_a_class_current_link_when_linking_to_self
    assert_parse_output("<a href=\"/\" class=\"current\">Tester</a>",
      "<r:link_with_current href=\"/\">Tester</r:link_with_current>")
  end
  def test_that_link_with_current_returns_a_class_current_link_when_linking_with_trailing_slash_to_self
    setup_page(make_page!("Kid1"))

    assert_parse_output("<a href=\"/kid1/\" class=\"current\">Tester</a>",
      "<r:link_with_current href=\"/kid1/\">Tester</r:link_with_current>")
  end

  # next
  def test_that_next_returns_next_sibling_when_one_exists
    kid1, kid2 = make_kids!(@page, "Kid1", "Kid2")
    setup_page(kid1)
    # this test broken - this should not be necessary
    @page.stubs(:self_and_siblings).returns([kid1, kid2])

    assert_parse_output("/Kid2/", "<r:next><r:url /></r:next>")
  end
  def test_that_next_returns_nil_when_no_next_sibling_exists
    kid1, kid2 = make_kids!(@page, "Kid1", "Kid2")
    setup_page(kid2)
    # this test broken - this should not be necessary
    @page.stubs(:self_and_siblings).returns([kid1, kid2])

    assert_parse_output("", "<r:next><r:url /></r:next>")
  end

  # previous
  def test_that_previous_returns_nil_when_no_previous_sibling_exists
    kid1, kid2 = make_kids!(@page, "Kid1", "Kid2")
    setup_page(kid1)
    # this test broken - this should not be necessary
    @page.stubs(:self_and_siblings).returns([kid1, kid2])

    assert_parse_output("", "<r:previous><r:url /></r:previous>")
  end
  def test_that_previous_returns_previous_sibling_when_one_exists
    kid1, kid2 = make_kids!(@page, "Kid1", "Kid2")
    setup_page(kid2)
    # this test broken - this should not be necessary
    @page.stubs(:self_and_siblings).returns([kid1, kid2])

    assert_parse_output("/Kid1/", "<r:previous><r:url /></r:previous>")
  end

  # full_url
  def test_that_full_url_returns_the_full_url
    # this test broken
    assert_parse_output("http://example.com/", "<r:full_url />")

    setup_page(make_kid!(@page, "Kid1"))
    assert_parse_output("http://example.com/kid1/", "<r:full_url />")
  end

  # updated_at
  def test_that_updated_at_returns_the_modification_date_in_correct_format
    a_time_string = "2007-04-02T05:32:21+10:00"
    @page.stubs(:updated_at).returns(Time.parse(a_time_string))

    assert_parse_output(a_time_string, "<r:updated_at />")
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

  def assert_parse_output(expected, input)
    output = @parser.parse(input)
    assert_equal expected, output
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
