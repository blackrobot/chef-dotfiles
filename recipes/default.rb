#
# Cookbook Name:: dotfiles
# Recipe:: default
#
# Copyright 2013, Damon Jablons
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "git"

# The packages to install with apt-get
pkgs = %w{ vim mercurial subversion git-core ruby-dev rake
           exuberant-ctags ack-grep xclip curl }

# Install the packages
pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

# Temp file location so this only runs once
tmp_file = ::File.join(Chef::Config['file_cache_path'], '.dotfiles')

# Backup /etc/skel/
execute "backup" do
  user "root"
  group "root"
  command "cp -Rf /etc/skel /etc/skel.backup"
  creates "/etc/skel.backup"
end

unless ::File.exists?(tmp_file)
  # Clone janus
  git "/etc/skel/.vim" do
    repository node['dotfiles']['vim']
    reference "master"
    user "root"
    group "root"
    enable_submodules true
    action :sync
  end

  # Install janus
  execute "rake" do
    cwd "/etc/skel/.vim"
    user "root"
    group "root"
    action :run
    environment({ 'HOME' => "/etc/skel" })
  end

  # Clone the custom dotfiles
  git "/etc/skel/.dotfiles" do
    repository node['dotfiles']['custom']
    reference "master"
    user "root"
    group "root"
    enable_submodules true
    action :sync
  end

  node['dotfiles']['links'].each do |lnk|
    # Delete existing files
    file "/etc/skel/#{lnk}" do
      action :delete
    end

    # Create the symlink
    link "/etc/skel/#{lnk}" do
      to "/etc/skel/.dotfiles/#{lnk}"
      owner "root"
      group "root"
    end
  end
end
