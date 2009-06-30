# Install hook code here

require 'rubygems'
require 'rake'
require 'rake/rdoctask'
require 'rake/testtask'
require 'tasks/rails'

Rake.application['wal:copy_resources_to_public'].invoke
