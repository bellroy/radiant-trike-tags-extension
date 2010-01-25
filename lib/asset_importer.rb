require 'pathname'

class AssetImporter
  def initialize
    @asset_mapping = {}
  end

  # tries to import all files found under +path+ as Paperclipped Asset
  # assumes that +path+ is under public/assets
  def import(path)
    @asset_mapping = {}
    import_folder(Pathname.new(path))
  end

  attr_accessor :asset_mapping

  def assets_dir_for(pathname)
   return nil if pathname.root? || !pathname.exist?
    
    if pathname.directory? && pathname.basename.to_s == 'assets'
      return pathname
    end
    
   assets_dir_for(pathname.parent)
  end

  def import_folder(pathname)
    assets_dir = assets_dir_for(pathname)
    if !assets_dir
      puts "Directory to import must be under the assets directory"
      return
    end

    pathname.children.collect do |image|
      filename = image.relative_path_from(assets_dir.parent)
      next if filename.to_s =~ /^\./
      if image.directory?
        puts "Importing directory '#{image}'"
        self.import_folder(image)
      else
        begin
          asset = Asset.create! :asset => image.open
          @asset_mapping[filename.to_s.sub(/^\//, '')] = asset
        rescue StandardError => e
          puts "Could not create Asset for file #{filename}"
          puts "Reason was: #{e.message}"
        end
      end
    end
    puts "Rewriting URLs in content"
    rewrite_urls
  end
  
  def rewrite_urls
    [PagePart, Snippet, Layout].each do |klass|
      klass.find_each do |resource|
        fix resource
        resource.content_will_change! # ActiveRecord::Dirty fails to notice the content change.
        resource.save!
      end
    end
  end

protected

  def fix(resource)
    resource.content.gsub!(%r{/?(?:\.\./)*(assets/[^'"\n)]+[^'")\s])}) do |asset_path|
      dir, file = File.split($1)
      old_asset = File.join(dir, URI.decode(file))
      asset = @asset_mapping[old_asset]
      if asset
        puts "#{old_asset} => #{asset.asset.url}"
        asset.asset.url
      else
        asset_path
      end
    end
  end
  
end
