{% include 'header.tpl' %}
{% set MetadataInterface = classes.get('Metadata') %}
{% set CrudMetadataInterface = classes.get('CrudMetadata') %}
{{ CrudMetadataInterface.printNamespace() }}

{% include "header_class.tpl" with {'infoClass': CrudMetadataInterface} %}
interface {{ CrudMetadataInterface }} extends {{ MetadataInterface }}
{

    public static function newForm($bean);
    
    public static function newValidator();
    
    public static function newFilter();
    
}
