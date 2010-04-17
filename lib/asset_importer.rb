require 'pathname'

class AssetImporter
  def initialize
    @asset_mapping = {}
  end

  # tries to import all files found under +path+ as Paperclipped Asset
  # assumes that +path+ is under public/assets
  def import(path)
    @assets_dir = assets_dir_for(Pathname.new(path))
    import_folder(@assets_dir.dup)
    rewrite_urls
  end

  attr_accessor :asset_mapping

  def assets_dir_for(pathname)
   return nil if pathname.to_s.include?("..") || pathname.root? || !pathname.exist?
   return pathname
    
#     if pathname.directory? && pathname.basename.to_s == 'assets'
#       return pathname
#     end
    
#    assets_dir_for(pathname.parent)
  end

  def import_folder(pathname)
    if !@assets_dir
      puts "Directory to import must be under the assets directory"
      return
    end

    pathname.children.collect do |image|
      filename = image.relative_path_from(@assets_dir.parent)
      next if filename.to_s =~ /^\./
      if image.directory?
        puts "Importing directory '#{image}'"
        self.import_folder(image)
      else
        begin
          asset = Asset.create! :asset => image.open
          @asset_mapping[filename.to_s.sub(/^\//, '_')] = asset
        rescue StandardError => e
          puts "Could not create Asset for file #{filename}"
          puts "Reason was: #{e.message}"
        end
      end
    end
  end
  
  def rewrite_urls
    puts "Rewriting URLs in content"
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
      # ContentScanner.find("jpg|gif|png").each {|pp| pp.content = pp.content.gsub(%r[http://images\.<r:(?:bare_)?host ?/>/([\w-]+\.(?:jpg|png|gif))]) {|r| "<r:assets:url id=\"#{`find public/assets -name #$1 -mindepth 2`.chomp[%r[public/assets/(\d*)],1]}\" size=\"original\" />" }; pp.save! }
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
