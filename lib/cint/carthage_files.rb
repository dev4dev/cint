module Cint
  class CarthageFiles
    def self.exists
      Dir.exist? './Carthage/Build'
    end

    def self.frameworks(platform)
      return [] unless PLATFORMS.include?(platform)
      pattern = "./Carthage/Build/#{platform}/*.framework"
      Dir.glob(pattern)
    end
  end
end