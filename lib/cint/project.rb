
module Cint

  # Project
  class Project
    def initialize(project_name)
      @project = Xcodeproj::Project.open(project_name)
    rescue
      error "Project #{project_name} not found"
    end

    def targets
      @project.targets
    end

    def target_by_name(name)
      @project.targets.find { |t| t.name == name }
    end
    
    def add_path(path)
      @project.add_frameworks_search_path(path)
    end

    def add_missing_frameworks_to_target(target, frameworks)
      fs = _fix_frameworks_paths(frameworks)
      fs -= target.frameworks_build_phase.files.map { |f| f.file_ref.path }

      added_frameworks = []
      files = fs.map do |f|
        file = @project.frameworks_group.files.find { |ff| ff.path == f}
        if file.nil?
          file = @project.frameworks_group.new_file(f) if file.nil?
          added_frameworks << f
        end
        
        file
      end

      files.each do |f|
        target.frameworks_build_phase.add_file_reference(f)
      end
      
      return added_frameworks
    end

    def _fix_frameworks_paths(frameworks)
      frameworks.map do |f|
        f[2..-1]
      end
    end

    def save
      @project.save
    end
  end

end
