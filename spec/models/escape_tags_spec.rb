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
      'easy content' => '"easy content"',
      'with "quotes"' => '"with ""quotes"""',
      'with, comma' => '"with, comma"',
      "with,\nnewline" => "\"with,\nnewline\"",
    }
    fixture.each do |input, output|
      it "should properly escape #{input} to #{output}" do
        @page.should render("<r:escape:csv>#{input}</r:escape:csv>").as(output)
      end
    end

    it "should escape newlines when swallow_newlines is true" do
      @page.should render("<r:escape:csv swallow_newlines=\"true\">some\ntext</r:escape:csv>").as('"sometext"')
    end
  end
end

