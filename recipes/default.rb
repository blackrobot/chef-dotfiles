#
# Cookbook Name:: dotfiles
# Recipe:: default
#

include_recipe "git"

# The packages to install with apt-get
pkgs = ["vim", "mercurial", "subversion", "git-core", "ruby-dev", "rake",
        "exuberant-ctags", "ack-grep", "xclip", "curl"]

# Install the packages
pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

# Backup /etc/skel/
execute "backup" do
  user "root"
  group "root"
  command "cp -Rf /etc/skel /etc/skel.backup"
  creates "/etc/skel"
end

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
end

# Clone the custom dotfiles
git "/etc/skel/dotfiles" do
  repository node['dofiles']['custom']
  reference "master"
  user "root"
  group "root"
  enable_submodules true
  action :sync
end

# Delete the existing .bashrc
file "/etc/skel/.bashrc" do
  action :delete
end

[".bashrc", ".gitconfig", ".janus", ".vimrc.before", ".vimrc.after"].each do |lnk|
  link "/etc/skel/#{lnk}" do
    to "/etc/skel/dotfiles/#{lnk}"
    owner "root"
    group "root"
  end
end
