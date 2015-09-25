# XXX Move defaults to real/up-to-date params.pp-like class
class backupninja::client::defaults (
  $cfg_override = '',
  $backupkeytype = '',
  $backupkeytype = '',
  $keydestination = '',
  $keyowner = '',
  $keygroup = '',
  $keymanage = '',
  $ssh_dir_manage = '',
  $backupninja_ensure_version = '',
){
  $configdir = $cfg_override ? {
    ''      => '/etc/backup.d',
    default => $cfg_override,
  }
  $real_keystore = $backupkeystore ? {
    ''      => "{$fileserver}/keys/backupkeys",
    default => $backupkeystore,
  }
  $real_keytype = $backupkeytype ? {
    ''      => 'rsa',
    false   => 'rsa',
    default => $backupkeytype,
  }
  $real_keydestination = $keydestination ? {
    ''      => '/root/.ssh',
    kdefault => $keydestination,
  }
  $real_keyowner = $keyowner ? {
    ''      => 0,
    default => $keyowner,
  }
  $real_keygroup = $keygroup ? {
    ''      => 0,
    default => $keygroup,
  }
  $real_keymanage = $keymanage ? {
    ''      => true,
    default => $keymanage
  }
  $real_ssh_dir_manage = $ssh_dir_manage ? {
    ''      => true,
    default => $ssh_dir_manage
  }
  if !defined(Package['backupninja']) {
    $real_backupninja_ensure_version = $backupninja_ensure_version ? {
      ''      => 'installed',
      default => $backupninja_ensure_version,
    }
    package { 'backupninja':
      ensure => $real_backupninja_ensure_version
    }
  }
  file { $configdir:
    ensure => directory,
    mode   => 750,
    owner  => 0,
    group  => 0,
  }
}
