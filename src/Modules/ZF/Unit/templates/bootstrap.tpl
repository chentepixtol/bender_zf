{% include 'header.tpl' %}

set_error_handler(create_function('$a, $b, $c, $d', 'throw new ErrorException($b, 0, $a, $c, $d);'), E_ALL & ~E_NOTICE);
error_reporting(E_ERROR | E_WARNING | E_PARSE | E_STRICT);

$loader = require 'autoload.php';

$loader->registerNamespaces(array(
    'Test' => '.',
));
$loader->register();