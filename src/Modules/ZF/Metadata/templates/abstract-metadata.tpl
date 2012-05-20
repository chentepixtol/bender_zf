{% include 'header.tpl' %}
{% set MetadataInterface = classes.get('Metadata') %}
{% set AbstractMetadata = classes.get('AbstractMetadata') %}
{{ AbstractMetadata.printNamespace() }}

{% include "header_class.tpl" with {'infoClass': AbstractMetadata} %}
abstract class {{ AbstractMetadata }} implements {{ MetadataInterface }}
{

    /**
     * @var array
     */
    private static $instances = array();
 
    /**
     * @return {{ MetadataInterface }}
     */
    final public static function getInstance(){
        $class = get_called_class();
        if( !isset(self::$instances[$class]) ){
            self::$instances[$class] = new static();
        }
        return self::$instances[$class];
    }
    
    /**
     * @throws {{ Exception }}
     */
    public static function checkBean($bean){
        if( !static::isBean($bean) ){
            static::throwException("The object not is a valid");
        }
    }
    
    /**
     * @return Container
     */
    protected static function getContainer(){
        return \Zend_Registry::getInstance()->get('container');
    }

}
