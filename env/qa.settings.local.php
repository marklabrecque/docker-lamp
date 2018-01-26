<?php

$databases['default']['default'] = array (
  'database' => 'corp_d8_qa',
  'username' => 'corp_d8_qa',
  'password' => 'XZLDbWzrTK8BQEyK',
  'prefix' => '',
  'host' => 'CA1FT1CTCQADB02',
  'port' => '3306',
  'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
  'driver' => 'mysql',
);
$settings['install_profile'] = 'fcv_common';
$settings['trusted_host_patterns'] = array(
  '^destinationcanada-d8\.fcvhost\.com$',
);
$config_directories['sync'] = '../config/sync';

# staging
$settings['simple_environment_indicator'] = '#1D8348 STG';