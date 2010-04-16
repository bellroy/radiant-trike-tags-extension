module ContentScanner
  def self.find(find)
    self.find_replace(find)
  end
  def self.replace(find, replace)
    self.find_replace(find, replace)
  end

  def self.find_replace(find, replace=nil)
    matches = []
    match_count = 0
    PagePart.find(:all).each do |part|
      next unless part.content && part.content.match(find)
      matches << part
      page = part.page
      if page && replace
        part.update_attribute(:content, part.content.gsub(find, replace))
        puts "Replaced match on Page #{page.url} (id:#{page.id}/#{part.name})"
        match_count += 1
      elsif page
        puts "Found match on Page #{page.url} (id:#{page.id}/#{part.name})"
        match_count += 1
      else
        puts "Found match in orphan PagePart (page_part_id:#{part.id}/#{part.name}) (you really should clean that up)"
      end
    end
    [Snippet, Layout].each do |klass|
      klass.find(:all).each do |instance|
        next unless instance.content && instance.content.match(find)
        matches << instance
        if replace
          instance.update_attribute(:content, instance.content.gsub(find, replace))
          puts "Replaced match on #{klass} #{instance.name} (id:#{instance.id})"
          match_count += 1
        else
          puts "Found match on #{klass} #{instance.name} (id:#{instance.id})"
          match_count += 1
        end
      end
    end
    puts "#{ replace ? "Replaced" : "Found" } #{match_count} matches."
    matches
  end
end
