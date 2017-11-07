
module Cint
  class Cleanup
    def self.frameworks
      Dir.glob("*.framework")
    end
    
    def self.bcsymbolmap(framework_path)
      name = File.basename(framework_path, ".framework")
      path = framework_path + "/#{name}"
      uuids = `xcrun dwarfdump --uuid "#{path}" | awk '{print $2}'`.split("\n").map(&:chomp)
      uuids.map { |uuid| "#{uuid}.bcsymbolmap" }
    end
  end
end