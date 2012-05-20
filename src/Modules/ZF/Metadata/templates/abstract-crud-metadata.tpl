{% include 'header.tpl' %}
{% set MetadataInterface = classes.get('Metadata') %}
{% set AbstractMetadata = classes.get('AbstractMetadata') %}
{% set CrudMetadataInterface = classes.get('CrudMetadata') %}
{% set AbstractCrudMetadata = classes.get('AbstractCrudMetadata') %}
{{ AbstractCrudMetadata.printNamespace() }}

{% include "header_class.tpl" with {'infoClass': AbstractCrudMetadata} %}
abstract class {{ AbstractCrudMetadata }} extends {{ AbstractMetadata }} implements {{ CrudMetadataInterface }}
{

}
