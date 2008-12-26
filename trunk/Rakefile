# -*- ruby -*-

$: << 'lib'
require 'rgdata'
require 'rubygems'
require 'hoe'

Hoe.new('rgdata', RGData::VERSION) do |p|
  # p.rubyforge_name = 'rgdatax' # if different than lowercase project name
  p.developer('ANDO Yasushi', 'andyjpn@gmail.com')
end

desc 'Run rspec'
task 'spec' do
  FileList['test/*_spec.rb'].each do |spec|
    `spec -c -fs #{spec}`
  end
end

# vim: syntax=Ruby
