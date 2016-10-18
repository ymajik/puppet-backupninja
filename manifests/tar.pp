# Run tar as part of a backupninja run.
#
# Valid attributes for this type are:
#
#   order: The prefix to give to the handler config filename, to set
#      order in which the actions are executed during the backup run.
#
#   ensure: Allows you to delete an entry if you don't want it any more
#      (but be sure to keep the configdir, name, and order the same, so
#      that we can find the correct file to remove).
#
#   include, exclude, compress, dateformat: As
#      defined in the backupninja documentation.  The options will be placed
#      in the correct sections automatically.  The include and exclude
#      options should be given as arrays if you want to specify multiple
#      directories.
#
define backupninja::tar (
  $order = 90,
  $ensure = present,
  $when = "everyday at 01:00",
  $backupname = "${fqdn}",
  $backupdir = '/var/backups',
  $compress = "bzip",
  $dateformat = "%Y.%m.%d-%H%M",
  $exclude = [
    $backupdir,
    '/home/*/.gnupg',
    '/home/*/.local/share/Trash',
    '/home/*/.Trash',
    '/home/*/.thumbnails',
    '/home/*/.beagle',
    '/home/*/.aMule',
    '/home/*/gtk-gnutella-downloads',
    '/tmp',
    '/proc',
    '/dev',
    '/sys',
    '/net',
    '/misc',
    '/media',
    '/srv',
    '/selinux',
    ],
  $include = [
    '/etc',
    '/home',
    '/usr/local',
    ],

) {
  include ::backupninja::client::tar
  file { "${backupninja::client::defaults::configdir}/${order}_${name}.tar":
    ensure  => $ensure,
    content => template('backupninja/tar.conf.erb'),
    owner   => root,
    group   => root,
    mode    => '0600',
    require => File[$backupninja::client::defaults::configdir],
  }
}