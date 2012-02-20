{% include 'header.tpl' %}

error_reporting(E_ERROR | E_WARNING | E_PARSE | E_STRICT);

$loader = require 'autoload.php';

$loader->registerNamespaces(array(
    'Test' => '.',
));
$loader->register();