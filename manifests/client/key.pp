# Configure key
define backupninja::client::key (
  $user = false,
  $host = false,
  $installkey = false,
  $keyowner = false,
  $keygroup = false,
  $keystore = false,
  $keytype = false
) {
  include backupninja::client::defaults

  $real_user = $user ? {
    false   => $name,
    default => $user
  }
  $real_host = $host ? {
    false   => $user,
    default => $host
  }
  $install_key = $installkey ? {
    false   => $backupninja::client::defaults::real_keymanage,
    default => $installkey,
  }
  $key_owner = $keyowner ? {
    false   => $backupninja::client::defaults::real_keyowner,
    default => $keyowner,
  }
  $key_group = $keygroup ? {
    false   => $backupninja::client::defaults::real_keygroup,
    default => $keygroup,
  }
  $key_store = $keystore ? {
    false   => $backupninja::client::defaults::real_keystore,
    default => $keystore,
  }
  $key_type = $keytype ? {
    ''      => $backupninja::client::defaults::real_keytype,
    false   => $backupninja::client::defaults::real_keytype,
    default => $keytype,
  }

  $key_dest = $backupninja::client::defaults::real_keydestination
  $key_dest_file = "${key_dest}/id_${key_type}"

  if $install_key {
    if !defined(File[$key_dest]) {
      file { $key_dest:
        ensure => directory,
        mode   => '0700',
        owner  => $key_owner,
        group  => $key_group,
      }
    }
    if !defined(File[$key_dest_file]) {
      file { $key_dest_file:
        source  => "${key_store}/${real_user}_id_${key_type}",
        mode    => '0400',
        owner   => $key_owner,
        group   => $key_group,
        require => File[$key_dest],
      }
    }
  }
}
