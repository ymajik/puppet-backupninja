# maildir handler, as part of a backupninja run.
#
# The maildir handler slowly creates a backup of each user's
# maildir to a remote server. It is designed to be run with
# low overhead in terms of CPU and bandwidth, so it runs pretty
# slow. Hardlinking is used to save storage space. The actual
# maildir is stored within each snapshot directory.
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
#
define backupninja::maildir (
  $order = 99,
  $ensure = present,
  $when = 'everyday at 21:00',
  $srcdir = false,
  $destdir = false,
  $desthost = false,
  $destuser = false,
  $destid_file = false,
  $remove = false,
  $multiconnection = yes,
  $keepdaily = '4',
  $keepweekly = '2',
  $keepmonthly = '2',
) {
  include backupninja::client::maildir

  validate_string($srcdir)
  validate_string($destdir)
  validate_string($desthost)
  validate_string($destuser)
  validate_string($destid_file)

  file { "${backupninja::client::defaults::configdir}/${order}_${name}.maildir":
    ensure  => $ensure,
    content => template('backupninja/maildir.conf.erb'),
    owner   => root,
    group   => root,
    mode    => 0600,
    require => File[$backupninja::client::defaults::configdir],
  }
}
