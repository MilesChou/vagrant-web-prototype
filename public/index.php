<?php
use \Psr\Http\Message\ServerRequestInterface as Request;
use \Psr\Http\Message\ResponseInterface as Response;

require __DIR__ . '/../vendor/autoload.php';

$app = new Slim\App();

$app->get('/', function (Request $request, Response $response) {
	return 'Work';
});

$app->run();
