<?php

$databases['default']['default'] = array (
  'database' => 'corp_d8_dev',
  'username' => 'root',
  'password' => '123456',
  'prefix' => '',
  'host' => 'mysql',
  'port' => '3306',
  'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
  'driver' => 'mysql',
);
$settings['install_profile'] = 'fcv_common';
$settings['trusted_host_patterns'] = array(
  '^destinationcanada-d8\.test$',
  '^destinationcanada-d8\.fcv$',
);
$config_directories['sync'] = '../config/sync';

// Development options

assert_options(ASSERT_ACTIVE, TRUE);
\Drupal\Component\Assertion\Handle::register();

$settings['cache']['bins']['render'] = 'cache.backend.null';
$settings['cache']['bins']['dynamic_page_cache'] = 'cache.backend.null';
/**
 * Enable local development services.
 */
//$settings['container_yamls'][] = DRUPAL_ROOT . '/sites/development.services.yml';
$settings['container_yamls'][] = DRUPAL_ROOT . '/sites/default/development.services.yml';

/**
 * Show all error messages, with backtrace information.
 *
 * In case the error level could not be fetched from the database, as for
 * example the database connection failed, we rely only on this value.
 */
$config['system.logging']['error_level'] = 'verbose';

/**
 * Disable CSS and JS aggregation.
 */
$config['system.performance']['css']['preprocess'] = FALSE;
$config['system.performance']['js']['preprocess'] = FALSE;

$config['system.performance']['cache']['page']['max_age'] = 0;

#local development
$settings['simple_environment_indicator'] = '#0077C0 DEV';

error_reporting(E_ALL);
ini_set('display_errors', TRUE);
ini_set('display_startup_errors', TRUE);

