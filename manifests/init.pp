# ## Class: syslogng ##
#
# Module to manage syslog-ng. Handles both local and remote logging.
#
# Inspired by [ghoneycutt/rsyslog](https://github.com/ghoneycutt/puppet-module-rsyslog/)
#
class syslogng (
  $package                  = 'syslog-ng',
  $package_ensure           = 'present',
  $package_provider         = undef,
  $logrotate_present        = 'USE_DEFAULTS',
  $logrotate_d_config_path  = 'USE_DEFAULTS',
  $logrotate_d_config_owner = 'root',
  $logrotate_d_config_group = 'root',
  $logrotate_d_config_mode  = '0644',
  $logrotate_d_config_file  = 'USE_DEFAULTS',
  $config_path              = 'USE_DEFAULTS',
  $config_owner             = 'root',
  $config_group             = 'root',
  $config_mode              = '0644',
  $config_file_erb          = 'USE_DEFAULTS',
  $sysconfig_path           = 'USE_DEFAULTS',
  $sysconfig_owner          = 'root',
  $sysconfig_group          = 'root',
  $sysconfig_mode           = '0644',
  $service_name             = 'USE_DEFAULTS',
  $service_ensure           = 'running',
  $service_enable           = true,
  $remote_logging           = false,
  $log_servers              = undef,
) {

  validate_re($package_ensure, '^(present)|(installed)|(absent)$',
    'syslogng::package_ensure is invalid and does not match the regex.')

  validate_string($config_owner)
  validate_string($config_group)
  validate_re($config_mode, '^(\d){4}$',
    "syslogng::config_mode is <${config_mode}>. Must be in four digit octal notation.")

  validate_string($sysconfig_owner)
  validate_string($sysconfig_group)
  validate_re($sysconfig_mode, '^(\d){4}$',
    "syslogng::sysconfig_mode is <${sysconfig_mode}>. Must be in four digit octal notation.")

  validate_string($service_name)
  validate_re($service_ensure, '^(present)|(running)|(absent)|(stopped)$',
    'syslogng::service_ensure is invalid and does not match the regex.')
  $service_enable_type = type($service_enable)
  case $service_enable_type {
    'string': {
      $service_enable_real = str2bool($service_enable)
    }
    'boolean': {
      $service_enable_real = $service_enable
    }
    default: {
      fail("syslogng::service_enable must be of type boolean or string. Detected type is <${service_enable_type}>.")
    }
  }

  $remote_logging_type = type($remote_logging)
  case $remote_logging_type {
    'string': {
      $remote_logging_real = str2bool($remote_logging)
    }
    'boolean': {
      $remote_logging_real = $remote_logging
    }
    default: {
      fail("syslogng::remote_logging must be of type boolean or string. Detected type is <${remote_logging_type}>.")
    }
  }

  if $remote_logging_real {
    validate_hash($log_servers)
  }

  case $::osfamily {
    'Suse': {
      case $::lsbmajdistrelease {
        '10': {
          $default_logrotate_present       = true
          $default_logrotate_d_config_path = '/etc/logrotate.d/syslog'
          $defaultlogrotate_d_config_file  = 'logrotate.suse10'
          $default_config_path             = '/etc/syslog-ng/syslog-ng.conf'
          $default_config_file_erb         = 'syslog-ng.conf.suse10.erb'
          $default_sysconfig_path          = '/etc/sysconfig/syslog'
          $sysconfig_erb                   = 'sysconfig.suse10.erb'
          $default_service_name            = 'syslog'
        }
        default: {
          fail("syslog-ng supports Suse like systems with major release 10, and you have ${::lsbmajdistrelease}")
        }
      }
    }
    default: {
      fail("syslog-ng supports osfamilies Suse. Detected osfamily is ${::osfamily}")
    }
  }

  $logrotate_present_test = $logrotate_present ? {
    'USE_DEFAULTS' => $default_logrotate_present,
    default        => $logrotate_present
  }

  $logrotate_present_test_type = type($logrotate_present_test)
  case $logrotate_present_test_type {
    'string': {
      $logrotate_present_real = str2bool($logrotate_present_test)
    }
    'boolean': {
      $logrotate_present_real = $logrotate_present_test
    }
    default: {
      fail("syslogng::logrotate_present must be of type boolean or string. Detected type is <${logrotate_present_test_type}>.")
    }
  }

  if $logrotate_present_real {
    $logrotate_d_config_path_real = $logrotate_d_config_path ? {
      'USE_DEFAULTS' => $default_logrotate_d_config_path,
      default        => $logrotate_d_config_path
    }
    validate_string($logrotate_d_config_path_real)
  }

  $logrotate_d_config_file_erb_real = $logrotate_d_config_file ? {
    'USE_DEFAULTS' => $default_logrotate_d_config_file,
    default        => $logrotate_d_config_file
  }

  $config_path_real = $config_path ? {
    'USE_DEFAULTS' => $default_config_path,
    default        => $config_path
  }

  $config_file_erb_real = $config_file_erb ? {
    'USE_DEFAULTS' => $default_config_file_erb,
    default        => $config_file_erb
  }

  $sysconfig_path_real = $sysconfig_path ? {
    'USE_DEFAULTS' => $default_sysconfig_path,
    default        => $sysconfig_path
  }

  $service_name_real = $service_name ? {
    'USE_DEFAULTS' => $default_service_name,
    default        => $service_name
  }

  package { 'syslogng_package':
    ensure   => $package_ensure,
    name     => $package,
    provider => $package_provider,
  }

  if $::kernel == 'Linux' {
    file { 'syslogng_sysconfig':
      ensure  => file,
      content => template("syslogng/${syslogng::sysconfig_erb}"),
      path    => $sysconfig_path_real,
      owner   => $sysconfig_owner,
      group   => $sysconfig_group,
      mode    => $sysconfig_mode,
      require => Package[$package],
      notify  => Service['syslogng_service'],
    }
  }

  file { 'syslogng_logrotate_d_config':
    ensure  => file,
    path    => $logrotate_d_config_path,
    owner   => $logrotate_d_config_owner,
    group   => $logrotate_d_config_group,
    mode    => $logrotate_d_config_mode,
    source  => "puppet:///syslogng/${logrotate_d_config_file_real}",
    require => Package[$package],
  }

  file { 'syslogng_config':
    ensure  => file,
    path    => $config_path_real,
    owner   => $config_owner,
    group   => $config_group,
    mode    => $config_mode,
    content => template("syslogng/${config_file_erb_real}"),
    require => Package[$package],
    notify  => Service['syslogng_service'],
  }

  service { 'syslogng_service':
    ensure => $daemon_ensure,
    name   => $service_name_real,
    enable => $service_enable_real,
  }
}
