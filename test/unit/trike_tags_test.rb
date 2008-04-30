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
  def test_that_site_area_appends_an_n_to_numeric_names
    setup_page(make_kid!(@page, "404"))

    assert_parse_output("n404", "<r:site_area />")
  end
  #   and current_if_same_site_area
  def test_that_current_if_same_site_area_returns_current_if_in_the_same_site_area
    a3 = make_kid!(a2 = make_kid!(a1 = make_kid!(@page, "a1"), "a2"), "a3")

    setup_page(a1)
    assert_parse_output("current", %[<r:find url="/a1"><r:current_if_same_site_area /></r:find>])
    assert_parse_output("current", %[<r:find url="/a2"><r:current_if_same_site_area /></r:find>])
    assert_parse_output("current", %[<r:find url="/a3"><r:current_if_same_site_area /></r:find>])
  end
  def test_that_current_if_same_site_area_returns_an_empty_string_if_not_in_the_same_site_area
    a3 = make_kid!(a2 = make_kid!(a1 = make_kid!(@page, "a1"), "a2"), "a3")
    b1 = make_kid!(@page, "b1")

    setup_page(b1)
    assert_parse_output("", %[<r:find url="/a1"><r:current_if_same_site_area /></r:find>])
    assert_parse_output("", %[<r:find url="/a2"><r:current_if_same_site_area /></r:find>])
    assert_parse_output("", %[<r:find url="/a3"><r:current_if_same_site_area /></r:find>])
  end
  # site_subarea
  def test_that_site_subarea_returns_the_right_thing_on_the_root_page
    assert_parse_output("", "<r:site_subarea />")
  end
  def test_that_site_subarea_returns_the_right_thing_on_level_one_child_pages
    setup_page(make_kid!(@page, "Kid1"))

    assert_parse_output("", "<r:site_subarea />")
  end
  def test_that_site_subarea_returns_the_right_thing_on_level_two_child_pages
    setup_page(make_kid!(make_kid!(@page, "Kid1"), "Kid1.1"))

    assert_parse_output("kid1.1", "<r:site_subarea />")
  end
  def test_that_site_subarea_returns_the_right_thing_on_level_three_child_pages
    setup_page(make_kid!(make_kid!(make_kid!(@page, "Kid1"), "Kid1.1"), "Kid1.1.1"))

    assert_parse_output("kid1.1", "<r:site_subarea />")
  end
  #   and current_if_same_site_subarea
  def test_that_current_if_same_site_subarea_returns_current_if_in_the_same_site_subarea
    a3 = make_kid!(a2 = make_kid!(a1 = make_kid!(@page, "a1"), "a2"), "a3")

    setup_page(a2)
    assert_parse_output("", %[<r:find url="/a1"><r:current_if_same_site_area /></r:find>])
    assert_parse_output("current", %[<r:find url="/a2"><r:current_if_same_site_area /></r:find>])
    assert_parse_output("current", %[<r:find url="/a3"><r:current_if_same_site_area /></r:find>])
  end
  def test_that_current_if_same_site_subarea_returns_an_empty_string_if_not_in_the_same_site_subarea
    a3 = make_kid!(a2 = make_kid!(a1 = make_kid!(@page, "a1"), "a2"), "a3")
    b1 = make_kid!(@page, "b1")

    setup_page(b1)
    assert_parse_output("", %[<r:find url="/a1"><r:current_if_same_site_area /></r:find>])
    assert_parse_output("", %[<r:find url="/a2"><r:current_if_same_site_area /></r:find>])
    assert_parse_output("", %[<r:find url="/a3"><r:current_if_same_site_area /></r:find>])
  end

  # current_if_same_page
  def test_that_current_if_same_page_returns_current_if_on_the_same_page
    a1 = make_kid!(@page, "a1")

    setup_page(a1)
    assert_parse_output("current", %[<r:find url="/a1"><r:current_if_same_page /></r:find>])
  end
  def test_that_current_if_same_page_returns_an_empty_string_if_on_the_same_page
    a1 = make_kid!(@page, "a1")

    assert_parse_output("", %[<r:find url="/a1"><r:current_if_same_page /></r:find>])
  end


  # link_with_current
  # TODO: supports two behaviours - 1. tag.locals.page.url matches href attribute; 2. tag.locals.page == tag.globals.page. Only 1. is tested.
  def test_that_link_with_current_returns_a_normal_link_when_not_linking_to_self
    assert_parse_output(%[<a href="/other_page">Other Page</a>],
      %[<r:link_with_current href="/other_page">Other Page</r:link_with_current>])
  end
  def test_that_link_with_current_returns_a_class_current_link_when_linking_to_self_at_root_page
    assert_parse_output(%[<a href="/" class="current">Tester</a>],
      %[<r:link_with_current href="/">Tester</r:link_with_current>])
  end
  def test_that_link_with_current_returns_a_class_current_link_when_linking_to_self
    setup_page(make_kid!(@page, "Kid1"))

    assert_parse_output(%[<a href="/kid1" class="current">Tester</a>],
      %[<r:link_with_current href="/kid1">Tester</r:link_with_current>])
  end
  def test_that_link_with_current_returns_a_class_current_link_when_linking_with_trailing_slash_to_self
    setup_page(make_kid!(@page, "Kid1"))

    assert_parse_output(%[<a href="/kid1/" class="current">Tester</a>],
      %[<r:link_with_current href="/kid1/">Tester</r:link_with_current>])
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
  def test_that_host_renders_the_host_page_part_from_site_root_if_that_exists
    part = stub(:content => "sub.example.com")
    root_page = stub()
    root_page.stubs(:part).with("host").returns(part)
    @page.stubs(:root).returns(root_page)

    assert_parse_output("sub.example.com", "<r:host />")
  end
  def test_that_host_renders_the_host_page_part_from_site_root_if_that_exists_even_if_other_methods_also_exist
    @page.stubs(:site).returns(stub(:base_domain => 'site.example.com'))
    request = stub(:host => "request.example.com")
    page = stub_everything(:request => request)
    globals = stub(:page => page)
    @context.stubs(:globals).returns(globals)
    part = stub(:content => "roothostpart.example.com")
    root_page = stub()
    root_page.expects(:part).with("host").returns(part)
    @page.stubs(:root).returns(root_page)

    assert_parse_output("roothostpart.example.com", "<r:host />")
  end
  def test_that_host_renders_from_page_site_if_that_is_defined_and_root_page_host_part_is_not
    root_page = stub()
    root_page.stubs(:part).with("host").returns(nil)
    @page.stubs(:root).returns(root_page)
    @page.expects(:site).at_least_once.returns(stub(:base_domain => 'sub.example.com'))

    assert_parse_output("sub.example.com", "<r:host />")
  end
  def test_that_host_renders_from_response_if_that_is_defined_and_site_is_not
    @page.stubs(:site).returns(nil)
    request = stub(:host => "sub.example.com")
    page = stub_everything(:request => request)
    globals = stub(:page => page)
    @context.expects(:globals).at_least(1).returns(globals)

    assert_parse_output("sub.example.com", "<r:host />")
  end
  def test_that_host_renders_a_helpful_error_if_root_host_part_not_found_and_other_methods_fail
    @page.stubs(:site).returns(nil)
    root_page = stub()
    root_page.stubs(:part).with("host").returns(nil)
    @page.stubs(:root).returns(root_page)

    begin
      @parser.parse('<r:host />')
    rescue StandardTags::TagError => e
      assert e.message.match(/host.{1,3} tag/), "tag error doesn't mention 'host tag' - #{e.message}"
      assert e.message.match(/root page/), "tag error doesn't mention 'root page' - #{e.message}"
    end
  end

  # img_host
  def test_that_img_host_adds_images_to_host
    @page.stubs(:site).returns(stub(:base_domain => 'example.com'))  # I'd prefer to stub this earlier, but don't know how

    assert_parse_output("images.example.com", "<r:img_host />")
  end
  def test_that_img_host_strips_www_from_host
    @page.stubs(:site).returns(stub(:base_domain => 'www.example.com'))  # I'd prefer to stub this earlier, but don't know how

    assert_parse_output("images.example.com", "<r:img_host />")
  end

  # base_domain
  def test_that_base_domain_strips_subdomains_from_host
    domains = {
      "a.b.com"      => "b.com",
      "a.b.c.com"    => "b.c.com",
      "a.b.c.com.au" => "b.c.com.au",
      "a.b.aero"     => "b.aero",
      "com"          => ".",
    }
    test_stubs = domains.collect {|k,v| stub(:base_domain => k) }

    @page.stubs(:site).returns(*(test_stubs.zip(test_stubs).flatten))  # I'd prefer to stub this earlier, but don't know how

    domains.each do |k,v|
      assert_parse_output(v, "<r:base_domain />", "#{k} => #{v}")
    end
  end

  # full_url
  def test_that_full_url_returns_the_full_url
    part = stub(:content => "example.com")
    root_page = stub()
    root_page.stubs(:part).with("host").returns(part)
    @page.stubs(:root).returns(root_page)

    assert_parse_output("http://example.com/", "<r:full_url />")

    kid = make_kid!(@page, "Kid1")
    kid.stubs(:root).returns(root_page)
    setup_page(kid)
    assert_parse_output("http://example.com/kid1/", "<r:full_url />")
  end

  # img
  def test_that_img_renders_an_image_tag_for_images_host
    part = stub(:content => "example.com")
    root_page = stub()
    root_page.stubs(:part).with("host").returns(part)
    @page.stubs(:root).returns(root_page)

    assert_parse_output(
      '<img src="http://images.example.com/dir/img.jpg" attr="arbitrary" />',
      '<r:img src="/dir/img.jpg" attr="arbitrary" />'
                       )
  end
  def test_that_img_removes_any_www
    part = stub(:content => "www.example.com")
    root_page = stub()
    root_page.stubs(:part).with("host").returns(part)
    @page.stubs(:root).returns(root_page)

    assert_parse_output(
      '<img src="http://images.example.com/dir/img.jpg" attr="arbitrary" />',
      '<r:img src="/dir/img.jpg" attr="arbitrary" />'
                       )
  end
  def test_that_img_renders_a_helpful_error_if_root_host_part_not_found
    root_page = stub()
    root_page.stubs(:part).with("host").returns(nil)
    @page.stubs(:root).returns(root_page)

    begin
      @parser.parse('<r:img src="/dir/img.jpg" attr="arbitrary" />')
    rescue StandardTags::TagError => e
      assert e.message.match(/img.{1,3} tag/), "tag error doesn't mention 'img tag' - #{e.message}"
      assert e.message.match(/root page/), "tag error doesn't mention 'root page' - #{e.message}"
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
