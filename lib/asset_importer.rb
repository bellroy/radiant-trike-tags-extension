require 'pathname'

module AssetImporter
  # tries to import all files found under +path+ as Paperclipped Asset
  # returns the saved asset records
  def self.import(path)
    import_folder(Pathname.new(path)).flatten
  end

  def self.import_folder(pathname)
    asset_mapping = {}
    pathname.children.collect do |image|
      filename = image.relative_path_from(pathname)
      next if filename.to_s =~ /^\./
      if image.directory?
        puts "Importing directory '#{image}'"
        self.import_folder(image)
      else
        begin
          asset = Asset.create! :asset => image.open
          asset_mapping[image.to_s.sub(/^\//, '')] = asset
        rescue StandardError => e
          puts "Could not create Asset for file #{filename}"
          puts "Reason was: #{e.message}"
        end
      end
    end
    puts "Rewriting URLs in content"
    require 'pp'
    pp asset_mapping
    # rewrite_urls(asset_mapping)
  end
  
  def self.rewrite_urls(asset_mapping)
    @asset_mapping = asset_mapping
    [PagePart, Snippet, Layout].each do |klass|
      klass.find_each do |resource|
        fix resource
        resource.content_will_change! # ActiveRecord::Dirty fails to notice the content change.
        resource.save!
      end
    end
  end

  def self.fix(resource)
    resource.content.gsub!(%r{/?(?:\.\./)*(assets/[^'"\n)]+[^'")\s])}) do |asset_path|
      dir, file = File.split($1)
      asset = @asset_mapping[File.join(dir, URI.decode(file))]
      if asset
        asset.url
      else
        asset_path
      end
    end
  end
  
end
