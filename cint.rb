#!/usr/bin/env ruby
# encoding: UTF-8

require 'xcodeproj'
require 'colored'
require 'commander/import'

program :name, 'integrator'
program :version, '0.0.1'
program :description, 'Integrates Carthage Frameworks'
program :author, 'Alex antonyuk'

def error(message)
  puts "\nError: #{message}".red
  exit
end

def warning(message)
  puts "\nWarning: #{message}".yellow
  exit
end

def info(message)
  puts message.green
end

SDK_TO_PLATFORM = {
  "iphoneos" => "iOS",
  "macosx" => "Mac",
  "appletvos" => "tvOS",
  "watchos" => "watchOS"
}

PLATFORMS = %w(iOS Mac watchOS tvOS)

# Carthage
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

# Project
class Project
  def initialize(project_name)
    begin
      @project = Xcodeproj::Project.open(project_name)
    rescue
      error "Project #{project_name} not found"
    end
  end
  
  def get_targets
    @project.targets
  end
  
  def target_by_name(name)
    @project.targets.select {|t| t.name == name}.first
  end
  
  def add_missing_frameworks_to_target(target, frameworks)
    fs = frameworks.map do |f|
      f[2..-1]
    end
    @project.frameworks_group.files.each do |f|
      fs.delete(f.path)
    end
    
    files = fs.map do |f|
      @project.frameworks_group.new_file(f)
    end
    
    files.each do |f|
      target.frameworks_build_phase.add_file_reference(f)
    end
  end
  
  def save
    @project.save
  end
end

class Xcodeproj::Project::Object::PBXNativeTarget
  def carthage_build_phase
    phase = build_phases.select do |phase|
      phase.is_a?(Xcodeproj::Project::Object::PBXShellScriptBuildPhase) && phase.name == "Carthage"
    end.first
    phase || new_shell_script_build_phase("Carthage")
  end
end

class Xcodeproj::Project::Object::PBXShellScriptBuildPhase
  def setup_with_frameworks(frameworks)
    self.shell_script = "/usr/local/bin/carthage copy-frameworks"
    self.shell_path = "/bin/sh"
    self.input_paths = frameworks
  end
end

def prepare_frameworks(frameworks)
  frameworks.map do |f|
    "$(SRCROOT)#{f[1..-1]}"
  end
end

def print_report(frameworks)
  info 'Integrated:'
  puts frameworks.map{|f| File.basename(f)}.join("\n").yellow
end

def find_project
  pattern = Dir.pwd + "/*.xcodeproj"
  Dir.glob(pattern)
end

def get_project_name(args)
  if args.count == 0
    projects = find_project
    error "There are more than one project in the directory, pass project's name explicitly" if projects.count > 1
    error "There are no projects in the directory, pass project's name explicitly" if projects.count == 0
    project_name = projects.first
  else
    project_name = args[0]
  end
  project_name = "#{project_name}.xcodeproj" unless project_name.end_with? ".xcodeproj"
  project_name
end

# Commands
command :install do |c|
  c.syntax = 'cint install <project_name>'
  c.description = 'Adds frameworks built by Carthage into a project'
  c.action do |args, options|
    error 'Carthage build folder does not exists' unless CarthageFiles.exists
    
    # Choose Project
    project_name = get_project_name(args)
    info "Working with #{File.basename(project_name)}\n"
    
    project = Project.new(project_name)

    # choose target
    choice = choose("Choose target:\n", *project.get_targets.map(&:name))
    target = project.target_by_name(choice)
    platform = SDK_TO_PLATFORM[target.sdk]
    frameworks = CarthageFiles.frameworks(platform)

    warning 'No frameworks found' if frameworks.empty?

    # Add Framework Files
    project.add_missing_frameworks_to_target(target, frameworks)

    # Integrate Shell Script
    target.carthage_build_phase.setup_with_frameworks(prepare_frameworks(frameworks)) unless target.sdk == 'macosx'

    # Save Project
    project.save

    # footer
    say "\n"
    print_report(frameworks)
    say "\n"
    info 'Done. Re-open Project'
  end
end
