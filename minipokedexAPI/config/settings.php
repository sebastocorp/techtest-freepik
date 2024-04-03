<?php

declare(strict_types=1);

use GR\DevEnvBoilerplate\Infrastructure\Slim\Setting\Settings;
use GR\DevEnvBoilerplate\Infrastructure\Slim\Setting\SettingsInterface;
use DI\ContainerBuilder;
use Monolog\Logger;

return static function (ContainerBuilder $containerBuilder)
{
    // Global Settings Object
    $containerBuilder->addDefinitions([
        SettingsInterface::class => function () {
            return new Settings([
                'displayErrorDetails' => true, // Should be set to false in production
                'logError'            => false,
                'logErrorDetails'     => false,
                'logger' => [
                    'name' => 'slim-app',
                    'path' => isset($_ENV['docker']) ? 'php://stdout' : __DIR__ . '/../logs/app.log',
                    'level' => Logger::DEBUG,
                ],
                'database' => [
                    'host' => getenv('DB_HOST'),
                    'port' => getenv('DB_PORT'),
                    'name' => getenv('DB_NAME'),
                    'user' => getenv('DB_USER'),
                    'password' => getenv('DB_PASS'),
                    'charset' => getenv('DB_CHARSET'),
                ],
                'redis' => [
                    'schema' => getenv('REDIS_SCHEMA'),
                    'host' => getenv('REDIS_HOST'),
                    'port' => getenv('REDIS_PORT'),
                ],
                'memcached' => [
                    'host' => getenv('MEMCACHED_HOST'),
                    'port' => getenv('MEMCACHED_PORT'),
                ],
            ]);
        }
    ]);
};
