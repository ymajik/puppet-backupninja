# this define allows nodes to declare a remote backup sandbox, that have to
# get created on the server
define backupninja::server::sandbox (
  $user = false,
  $host = false,
  $installuser = true,
  $dir = false,
  $manage_ssh_dir = true,
  $ssh_dir = false,
  $authorized_keys_file = false,
  $key = false,
  $keytype = 'dss',
  $backupkeys = false,
  $uid = false,
  $gid = 'backupninjas',
  $backuptag = false,
  $nagios2_description = 'backups',
  $nagios_server = undef,
) {
  include backupninja::server

  $real_user = $user ? {
    false   => $name,
    default => $user,
    ''      => $name,
  }
  $real_host = $host ? {
    false   => $::fqdn,
    default => $host,
  }
  $real_backupkeys = $backupkeys ? {
    false   => "${::fileserver}/keys/backupkeys",
    default => $backupkeys,
  }
  $real_dir = $dir ? {
    false   => "${backupninja::server::backupdir}/${::fqdn}",
    default => $dir,
  }
  $real_ssh_dir = $ssh_dir ? {
    false   => "${real_dir}/.ssh",
    default => $ssh_dir,
  }
  $real_authorized_keys_file = $authorized_keys_file ? {
    false   => 'authorized_keys',
    default => $authorized_keys_file,
  }
  $real_backuptag = $backuptag ? {
    false   => "backupninja-${real_host}",
    default => $backuptag,
  }

  $real_nagios2_description = $nagios2_description ? {
    false   => 'backups',
    default => $nagios2_description,
  }

  if $nagios_server {
    # configure a passive service check for backups
    nagios2::passive_service { "backups-${name}":
      nagios2_host_name   => $real_host,
      nagios2_description => $real_nagios2_description,
      servicegroups       => 'backups',
    }
  }

  if !defined(File[$real_dir]) {
    @@file { $real_dir:
      ensure => directory,
      mode   => '0750',
      owner  => $real_user,
      group  => 0,
      tag    => $real_backuptag,
    }
  }
  case $installuser {
    true: {
      if $manage_ssh_dir {
        if !defined(File[$real_ssh_dir]) {
          @@file { $real_ssh_dir:
            ensure  => directory,
            mode    => '0700',
            owner   => $real_user,
            group   => 0,
            tag     => $real_backuptag,
            require => [
              User[$real_user],
              File[$real_dir],
              ],
          }
        }
      }
      case $key {
        false: {
          if !defined(File["${real_ssh_dir}/${real_authorized_keys_file}"]) {
            @@file { "${real_ssh_dir}/${real_authorized_keys_file}":
              ensure  => present,
              mode    => '0644',
              owner   => 0,
              group   => 0,
              source  => "${real_backupkeys}/${real_user}_id_${keytype}.pub",
              require => File[$real_ssh_dir],
              tag     => $real_backuptag,
            }
          }
        }
        default: {
          @@ssh_authorized_key{ $real_user:
            type    => $keytype,
            key     => $key,
            user    => $real_user,
            target  => "${real_ssh_dir}/${real_authorized_keys_file}",
            tag     => $real_backuptag,
            require => User[$real_user],
          }
        }
      }
      case $uid {
        false: {
          if !defined(User[$real_user]) {
            @@user { $real_user:
              ensure     => 'present',
              gid        => $gid,
              comment    => "${name} backup sandbox",
              home       => $real_dir,
              managehome => true,
              shell      => '/bin/sh',
              password   => '*',
              require    => Group['backupninjas'],
              tag        => $real_backuptag,
            }
          }
        }
        default: {
          if !defined(User[$real_user]) {
            @@user { $real_user:
              ensure     => 'present',
              uid        => $uid,
              gid        => $gid,
              comment    => "${name} backup sandbox",
              home       => $real_dir,
              managehome => true,
              shell      => '/bin/sh',
              password   => '*',
              require    => Group['backupninjas'],
              tag        => $real_backuptag,
            }
          }
        }
      }
    }
  }
}
