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
      gem_checksums = cache.getset "built_index" do
        gems_folder = site.in_source_dir("_gem_index/gems")

        if Bridgetown.env.development? # production site deploy uses already locally-built index
          FileUtils.mkdir_p gems_folder

          bridgetown_gems = %w(bridgetown bridgetown-builder bridgetown-core bridgetown-foundation bridgetown-paginate bridgetown-routes)
          bridgetown_gems.map { File.expand_path _1, ".." }.each do |folder|
            Bridgetown.logger.info("Gems:", "Copying from #{folder}...")
            Dir.chdir(folder) do
              Dir["pkg/*.gem"].each do |path|
                next if path.include?("2.0.0.beta") # don't bother with old beta release
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
