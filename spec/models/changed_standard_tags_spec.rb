require File.dirname(__FILE__) + '/../spec_helper'

describe ": changed standard tags :" do
  dataset :users, :home_page

  describe "<r:url />" do
    before do
      create_page "First"
      Radiant::Config.delete_all(:key => "defaults.trailingslash")
    end

    it "should default to true behaviour when Radiant::Config['defaults.trailingslash'] is absent" do
      Radiant::Config.delete_all(:key => "defaults.trailingslash")
      page(:home).should render("<r:url />").as("/")
      page(:first).should render("<r:url />").as("/first/")
    end
    it "should respect Radiant::Config['defaults.trailingslash'] = true" do
      Radiant::Config['defaults.trailingslash'] = true
      page(:home).should render("<r:url />").as("/")
      page(:first).should render("<r:url />").as("/first/")
    end
    it "should respect Radiant::Config['defaults.trailingslash'] = false" do
      Radiant::Config['defaults.trailingslash'] = false
      page(:home).should render("<r:url />").as("/")
      page(:first).should render("<r:url />").as("/first")
    end
    it 'should respect trailingslash="true"' do
      page(:home).should render("<r:url trailingslash='true' />").as("/")
      page(:first).should render("<r:url trailingslash='true' />").as("/first/")
    end
    it 'should respect trailingslash="false"' do
      page(:home).should render("<r:url trailingslash='false' />").as("/")
      page(:first).should render("<r:url trailingslash='false' />").as("/first")
    end
    it 'should respect trailingslash="true" even when Radiant::Config["defaults.trailingslash"] disagrees' do
      Radiant::Config['defaults.trailingslash'] = false
      page(:home).should render("<r:url trailingslash='true' />").as("/")
      page(:first).should render("<r:url trailingslash='true' />").as("/first/")
    end
    it 'should respect trailingslash="false" even when Radiant::Config["defaults.trailingslash"] disagrees' do
      Radiant::Config['defaults.trailingslash'] = true
      page(:home).should render("<r:url trailingslash='false' />").as("/")
      page(:first).should render("<r:url trailingslash='false' />").as("/first")
    end

  end

  describe "<r:link />" do
    before do
      create_page "First" do
        create_page "Child",   :published_at => DateTime.parse('2000-1-01 08:00:00')
        create_page "Child 2", :published_at => DateTime.parse('2000-1-01 09:00:00')
        create_page "Child 3", :published_at => DateTime.parse('2000-1-01 10:00:00')
      end
      Radiant::Config.delete_all(:key => "defaults.trailingslash")
    end

    describe "(legacy behaviour)" do
      it "should render a link to the current page" do
        page(:first).should render('<r:link />').as('<a href="/first/">First</a>')
      end

      it "should render its contents as the text of the link" do
        page(:first).should render('<r:link>Test</r:link>').as('<a href="/first/">Test</a>')
      end

      it "should pass HTML attributes to the <a> tag" do
        expected = '<a href="/first/" class="test" id="first">First</a>'
        page(:first).should render('<r:link class="test" id="first" />').as(expected)
      end

      it "should add the anchor attribute to the link as a URL anchor" do
        page(:first).should render('<r:link anchor="test">Test</r:link>').as('<a href="/first/#test">Test</a>')
      end

      it "should render a link for the current contextual page" do
        expected = ""
        if Page.column_names.include?("position")
          expected = %{<a href="/first/child-2/">Child 2</a> <a href="/first/child-3/">Child 3</a> <a href="/first/child/">Child</a> }
        else
          expected = %{<a href="/first/child/">Child</a> <a href="/first/child-2/">Child 2</a> <a href="/first/child-3/">Child 3</a> }
        end
        page(:first).should render('<r:children:each><r:link /> </r:children:each>' ).as(expected)
      end

      # NOTE: this is voodoo - I have no idea what this test means, but it's
      # a pretty clean copy of core functionality, and it shows we preserve it
      it "should scope the link within the relative URL root" do
        page(:first).should render('<r:link />').with_relative_root('/foo').as('<a href="/foo/first/">First</a>')
      end
    end

    it "should default to true behaviour when Radiant::Config['defaults.trailingslash'] is absent" do
      Radiant::Config.delete_all(:key => "defaults.trailingslash")
      page(:home).should render("<r:link />").as('<a href="/">Home</a>')
      page(:first).should render("<r:link />").as('<a href="/first/">First</a>')
    end
    it "should respect Radiant::Config['defaults.trailingslash'] = true" do
      Radiant::Config['defaults.trailingslash'] = true
      page(:home).should render("<r:link />").as('<a href="/">Home</a>')
      page(:first).should render("<r:link />").as('<a href="/first/">First</a>')
    end
    it "should respect Radiant::Config['defaults.trailingslash'] = false" do
      Radiant::Config['defaults.trailingslash'] = false
      page(:home).should render("<r:link />").as('<a href="/">Home</a>')
      page(:first).should render("<r:link />").as('<a href="/first">First</a>')
    end
    it 'should respect trailingslash="true"' do
      page(:home).should render("<r:link trailingslash='true' />").as('<a href="/">Home</a>')
      page(:first).should render("<r:link trailingslash='true' />").as('<a href="/first/">First</a>')
    end
    it 'should respect trailingslash="false"' do
      page(:home).should render("<r:link trailingslash='false' />").as('<a href="/">Home</a>')
      page(:first).should render("<r:link trailingslash='false' />").as('<a href="/first">First</a>')
    end
    it 'should respect trailingslash="true" even when Radiant::Config["defaults.trailingslash"] disagrees' do
      Radiant::Config['defaults.trailingslash'] = false
      page(:home).should render("<r:link trailingslash='true' />").as('<a href="/">Home</a>')
      page(:first).should render("<r:link trailingslash='true' />").as('<a href="/first/">First</a>')
    end
    it 'should respect trailingslash="false" even when Radiant::Config["defaults.trailingslash"] disagrees' do
      Radiant::Config['defaults.trailingslash'] = true
      page(:home).should render("<r:link trailingslash='false' />").as('<a href="/">Home</a>')
      page(:first).should render("<r:link trailingslash='false' />").as('<a href="/first">First</a>')
    end

  end
end
