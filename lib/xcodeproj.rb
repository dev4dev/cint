
module Xcodeproj
  class Project
    def add_frameworks_search_path(path)
      build_configuration_list.build_configurations.each do |cfg|
        if cfg.build_settings['FRAMEWORK_SEARCH_PATHS'] && !cfg.build_settings['FRAMEWORK_SEARCH_PATHS'].include?(path)
          if cfg.build_settings['FRAMEWORK_SEARCH_PATHS'].instance_of?(String)
            cfg.build_settings['FRAMEWORK_SEARCH_PATHS'].concat(" #{path}")
          else
            cfg.build_settings['FRAMEWORK_SEARCH_PATHS'].push(path)
          end
        else
          cfg.build_settings['FRAMEWORK_SEARCH_PATHS'] = ['$(inherited)', path]
        end
      end # end each
    end

    module Object
      # Extends Target
      class PBXNativeTarget
        def carthage_build_phase
          cart_phase = build_phases.find do |phase|
            phase.is_a?(Xcodeproj::Project::Object::PBXShellScriptBuildPhase) && phase.name == BUILD_PHASE_NAME
          end
          cart_phase || new_shell_script_build_phase(BUILD_PHASE_NAME)
        end
      end

      # Extends Build Phase
      class PBXShellScriptBuildPhase
        def setup_with_frameworks(frameworks)
          self.shell_script = '/usr/local/bin/carthage copy-frameworks'
          self.shell_path = '/bin/sh'
          self.input_paths = frameworks
        end
      end
    end
  end
end
