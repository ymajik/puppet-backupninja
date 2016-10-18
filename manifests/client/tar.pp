# == Class: backupninja::client::tar
#
# Manage tar installation
class backupninja::client::tar inherits backupninja::client::defaults {
  if !defined(Package['tar']) {
    if $tar_ensure_version == '' {
      $tar_ensure_version = 'installed'
    }
    package { 'tar':
      ensure => $tar_ensure_version,
    }
  }
}
