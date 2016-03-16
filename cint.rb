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
  puts "Error: #{message}".red
  exit
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
    path = "./Carthage/Build/#{platform}/*.framework"
    Dir.glob(path)
  end
end

def check_carthage
  unless CarthageFiles.exists
    error 'Carthage build folder does not exists'
  end
end

# Project

class Project
  attr_reader :project
  
  def initialize(project_name)
    begin
      @project = Xcodeproj::Project.open(project_name)
    rescue
      p "oops"
      exit
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

def carthage_build_phase_from_target(target)
  phase = target.build_phases.select do |phase|
    phase.is_a?(Xcodeproj::Project::Object::PBXShellScriptBuildPhase) && phase.name == "Carthage"
  end.first
  phase || target.new_shell_script_build_phase("Carthage")
end

def setup_phase(phase, frameworks)
  phase.shell_script = "/usr/local/bin/carthage copy-frameworks"
  phase.shell_path = "/bin/sh"
  phase.input_paths = frameworks
end

def prepare_frameworks(frameworks)
  frameworks.map do |f|
    "$(SRCROOT)#{f[1..-1]}"
  end
end

def print_report(frameworks)
  say 'Integrated:'.green
  say frameworks.map{|f| File.basename(f)}.join("\n").yellow
end

command :install do |c|
  c.syntax = 'cint install <project_name>'
  c.description = 'Adds frameworks build by Carthage into a project'
  c.action do |args, options|
    check_carthage
    project = Project.new(args[0])
    
    # choose target
    choice = choose("Choose target:\n", *project.get_targets.map(&:name))
    target = project.target_by_name(choice)
    platform = SDK_TO_PLATFORM[target.sdk]
    frameworks = CarthageFiles.frameworks(platform)
    
    # Add Framework Files
    project.add_missing_frameworks_to_target(target, frameworks)

    # Shell Script
    setup_phase(carthage_build_phase_from_target(target), prepare_frameworks(frameworks))
    project.save

    # footer
    say "\n"
    print_report(frameworks)
    say "\n"
    say 'Done. Re-open Project'.green
  end
end
