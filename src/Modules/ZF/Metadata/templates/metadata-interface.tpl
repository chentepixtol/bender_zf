{% include 'header.tpl' %}
{% set MetadataInterface = classes.get('Metadata') %}
{% set AbstractBean = classes.get('AbstractBean') %}
{{ MetadataInterface.printNamespace() }}

{{ AbstractBean.printUse() }}

{% include "header_class.tpl" with {'infoClass': MetadataInterface} %}
interface {{ MetadataInterface }}
{

    public static function newBean(array $fields);
    
    public static function newQuery();
    
    public static function newCollection();
    
    public static function throwException($message, $previous);
    
    public static function getTablename();
    
    public static function getEntityName();
    
    public static function getFields();
    
    public static function getPrimaryKey();
    
    public static function isBean($bean);
    
    public static function checkBean($bean);
    
    public static function toUpdateArray({{ AbstractBean }} $bean);
    
    public static function toCreateArray({{ AbstractBean }} $bean);
    
    public static function getInstance();
    
    public static function getCatalog();
    
    public static function getFactory();

}
