require File.dirname(__FILE__) + '/../spec_helper'

# from http://codesnippets.joyent.com/posts/show/1438
module Kernel
  # Suppresses warnings within a given block.
  def with_warnings_suppressed
    saved_verbosity = $-v
    $-v = nil
    yield
  ensure
    $-v = saved_verbosity
  end
end

describe "environment tags" do
  dataset :home_page

  #HACK: Would be better off with helper
  before(:each) do
    with_warnings_suppressed do
      RAILS_ENV = 'fake_env'
    end
  end
  after(:each) do
    with_warnings_suppressed do
      RAILS_ENV = 'test'
    end
  end

  describe "<r:if_env />" do
    it "should yeild content if env matches 'name' parameter" do
      page(:home).should render("<r:if_env name='fake_env'>foo</r:if_env>").as("foo")
    end
    it "should not yeild content if env matches 'name' parameter" do
      page(:home).should render("<r:if_env name='not_this'>foo</r:if_env>").as("")
    end
  end
  
  describe "<r:unless_env />" do
    it "should yeild content if env matches 'name' parameter" do
      page(:home).should render("<r:unless_env name='not_this'>foo</r:unless_env>").as("foo")
    end
    it "should not yeild content if env matches 'name' parameter" do
      page(:home).should render("<r:unless_env name='fake_env'>foo</r:unless_env>").as("")
    end
  end
end
