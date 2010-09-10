require File.dirname(__FILE__) + '/../spec_helper'

describe ": escape tags :" do
  
  dataset :users, :home_page

  before do
    @hostname = "testhost.tld"

    @page = pages(:home)
    @context = PageContext.new(@page)
    @parser = Radius::Parser.new(@context, :tag_prefix => 'r')
  end

  describe "<r:escape:uri />" do
    it "should replace ' ' with %20" do
      @page.should render("<r:escape:uri>this thing</r:escape:uri>").as("this%20thing")
    end
  end

  describe "<r:escape:csv />" do
    fixture = {
      'content' => '"content"',
      'with "quotes"' => '"with ""quotes"""',
      'with, comma' => '"with, comma"',
    }
    fixture.each do |input, output|
      it "should properly escape #{input} to #{output}" do
        @page.should render("<r:escape:csv>#{input}</r:escape:csv>").as(output)
      end
    end
  end
end

