require File.dirname(__FILE__) + '/../test_helper'

class TrikeTagsExtensionTest < Test::Unit::TestCase
  
  def test_initialization
    assert_equal File.join(File.expand_path(RAILS_ROOT), 'vendor', 'extensions', 'trike_tags'), TrikeTagsExtension.root
    assert_equal 'Trike Tags', TrikeTagsExtension.extension_name
  end
  
end
