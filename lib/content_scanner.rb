module ContentScanner
  def self.find(find)
    self.find_replace(find)
  end
  def self.replace(find, replace)
    self.find_replace(find, replace)
  end

  def self.find_replace(find, replace=nil)
    pages = []
    match_count = 0
    PagePart.find(:all).each do |part|
      next unless part.content && part.content.include?(find)
      page = part.page
      pages << page
      if replace
        part.content.gsub!(find, replace)
        puts "Replaced match on Page #{page.url} (id:#{page.id}/#{part.name})"
        match_count += 1 if part.save
      else
        puts "Found match on Page #{page.url} (id:#{page.id}/#{part.name})"
        match_count += 1
      end
    end
    puts "#{ replace ? "Replaced" : "Found" } on #{match_count} pages."
    pages
  end
end
