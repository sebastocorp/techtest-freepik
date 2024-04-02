<?php

declare(strict_types=1);

namespace GR\DevEnvBoilerplate\Tests\Infrastructure\Slim\Action\Hello;

use GR\DevEnvBoilerplate\Infrastructure\Slim\Action\ActionPayload;
use GR\DevEnvBoilerplate\Tests\Infrastructure\Slim\Action\ActionTestCase;

class ViewActionTest extends ActionTestCase
{
    public function testAction()
    {
        $app = $this->getAppInstance();

        $request = $this->createRequest('GET', '/bulbasaur');
        $response = $app->handle($request);

        $payload = (string) $response->getBody();

        $data = json_decode($payload, true)['data'];
        $this->assertArrayHasKey('name', $data);
        $this->assertArrayHasKey('type', $data);
        $this->assertArrayHasKey('count', $data);
        $this->assertEquals('bulbasaur', $data['name']);
        $this->assertEquals('planta', $data['type']);
        $this->assertGreaterThan(0, $data['count']);
    }
}
