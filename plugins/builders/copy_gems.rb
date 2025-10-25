require "digest/sha2"

class Builders::CopyGems < SiteBuilder
  # @!method site
  #   @return [Bridgetown::Site]

  def cache
    @@cache ||= Bridgetown::Cache.new("BuildingGemIndex")
  end

  def build
    index_folder = site.in_source_dir("_gem_index")
    
    hook :site, :post_read do
      cache_key = Digest::SHA256.file(site.in_source_dir("_data/load_gems.yml")).hexdigest
      gem_checksums = cache.getset(cache_key) do
        load_gems_folders = site.data.load_gems.map { File.expand_path _1, "~"}
        gems_folder = site.in_source_dir("_gem_index/gems")

        if Bridgetown.env.development? # production site deploy uses already locally-built index
          FileUtils.mkdir_p gems_folder
          load_gems_folders.each do |folder|
            Bridgetown.logger.info("Gems:", "Copying pkg/*.gem from #{folder}...")
            Dir.chdir(folder) do
              Dir["pkg/*.gem"].each do |path|
                FileUtils.cp path, gems_folder
              end
            end
          end

          Bridgetown.logger.info("Gems:", "Generating index...")

          `gem generate_index --directory #{index_folder}`
        end

        Bridgetown.logger.info("Gems:", "Loading checksums")
        gem_files = Dir["#{gems_folder}/*.gem"]
        gem_files.to_h do |path|
          [path, Digest::SHA256.file(path).hexdigest]
        end
      end

      site.data.gem_checksums = gem_checksums
      Bridgetown.logger.info("Gems:", "Complete.")
    end

    hook :site, :post_write do
      Dir["#{index_folder}/*"].each do |path|
        if File.directory?(path)
          FileUtils.mkdir_p File.join(site.destination, File.basename(path))
        end

        FileUtils.cp_r path, site.destination
      end
    end
  end
end
