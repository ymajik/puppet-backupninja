# == Class: backupninja::server
#
# Backupninja server configuration.
#
# === Parameters
#
# [*backupdir*]
#   Directory where backup will be stored.
#   Default: /backup
#
# [*backupserver_tag*]
#   Backup server tag.
#   Default: ::fqdn
#
# [*nagios_server*]
#   Name of the nagios server
#   Default: undef
#
# === Examples
#
#  include '::backupninja::server'
#
# Configuration is done using Hiera.
class backupninja::server (
  $backupdir = '/backup',
  $backupserver_tag = $::fqdn,
  $nagios_server = undef,
) {
  group { 'backupninjas':
    ensure => 'present',
    gid    => 700
  }

  file { $backupdir:
    ensure => 'directory',
    mode   => '0710',
    owner  => root,
    group  => 'backupninjas',
  }

  if $nagios_server and $nagios_server != '' {
    if !defined(Package['nsca']) {
      package { 'nsca':
        ensure => installed;
      }
    }

    file { '/usr/local/bin/checkbackups':
      ensure => 'present',
      source => "puppet://${servername}/backupninja/checkbackups.pl",
      mode   => '0755',
      owner  => root,
      group  => root,
    }

    cron { 'checkbackups':
      command => "/usr/local/bin/checkbackups -d ${backupdir} | /usr/sbin/send_nsca -H ${nagios_server} -c /etc/send_nsca.cfg | grep -v 'sent to host successfully'",
      user    => 'root',
      hour    => '8-23',
      minute  => 59,
      require => [
        File['/usr/local/bin/checkbackups'],
        Package['nsca'],
      ],
    }
  }

  User <<| tag == "backupninja-${backupserver_tag}" |>>
  File <<| tag == "backupninja-${backupserver_tag}" |>>
  Ssh_authorized_key <<| tag == "backupninja-${backupserver_tag}" |>>

  if !defined(Package['rsync']) {
    if $rsync_ensure_version == '' {
      $rsync_ensure_version = 'installed'
    }
    package { 'rsync':
      ensure => $rsync_ensure_version,
    }
  }
}

# vim: set et sta sw=2 ts=2 sts=2 noci noai:
