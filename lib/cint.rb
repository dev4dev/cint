require "xcodeproj"
require_relative "cint/version"
require_relative "cint/project"
require_relative "cint/carthage_files"
require_relative "cint/cleanup"
require_relative "cint/xcodeproj_extensions"

Xcodeproj::Project.include ::XcodeprojExtensions::Project
Xcodeproj::Project::Object::PBXNativeTarget.include ::XcodeprojExtensions::Project::Object::PBXNativeTarget
Xcodeproj::Project::Object::PBXShellScriptBuildPhase.include ::XcodeprojExtensions::Project::Object::PBXShellScriptBuildPhase
