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
                    'host' => isset($_ENV['DDBB_HOST']) ? $_ENV['DDBB_HOST'] : "placeholder",
                    'port' => isset($_ENV['DDBB_PORT']) ? intval($_ENV['DDBB_PORT']) : "placeholder",
                    'name' => isset($_ENV['DDBB_NAME']) ? $_ENV['DDBB_NAME'] : "placeholder",
                    'user' => isset($_ENV['DDBB_USER']) ? $_ENV['DDBB_USER'] : "placeholder",
                    'password' => isset($_ENV['DDBB_PASS']) ? $_ENV['DDBB_PASS'] : "placeholder",
                    'charset'  => isset($_ENV['DDBB_CHARSET']) ? $_ENV['DDBB_CHARSET'] : "placeholder",
                ],
                'redis' => [
                    'schema' => isset($_ENV['REDIS_SCHEMA']) ? $_ENV['REDIS_SCHEMA'] : "placeholder",
                    'host' =>   isset($_ENV['REDIS_HOST']) ? $_ENV['REDIS_HOST'] : "placeholder",
                    'port' =>   isset($_ENV['REDIS_PORT']) ? intval($_ENV['REDIS_PORT']) : "placeholder",
                ],
                'memcached' => [
                    'host' => isset($_ENV['MEMCACHED_HOST']) ? $_ENV['MEMCACHED_HOST'] : "placeholder",
                    'port' => isset($_ENV['MEMCACHED_PORT']) ? intval($_ENV['MEMCACHED_PORT']) : "placeholder",
                ],
            ]);
        }
    ]);
};
