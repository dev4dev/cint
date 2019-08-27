require "xcodeproj"
require "cint/version"
require "cint/project"
require "cint/carthage_files"
require "cint/cleanup"
require "cint/xcodeproj_extensions"

Xcodeproj::Project.include ::XcodeprojExtensions::Project
Xcodeproj::Project::Object::PBXNativeTarget.include ::XcodeprojExtensions::Project::Object::PBXNativeTarget
Xcodeproj::Project::Object::PBXShellScriptBuildPhase.include ::XcodeprojExtensions::Project::Object::PBXShellScriptBuildPhase
