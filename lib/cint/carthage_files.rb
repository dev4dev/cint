
module Cint
  class CarthageFiles
    def self.exists
      Dir.exist? './Carthage/Build'
    end

    def self.frameworks(platform)
      if platform.empty?
        pattern = "./Carthage/Build/*.{framework,xcframework}"
      else
        return [] unless PLATFORMS.include?(platform)
        pattern = "./Carthage/Build/#{platform}/*.{framework,xcframework}"
      end
      Dir.glob(pattern)
    end
  end
end