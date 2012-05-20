{% include 'header.tpl' %}
{% set AbstractMetadata = classes.get('AbstractMetadata') %}
{% set AbstractBean = classes.get('AbstractBean') %}
namespace {{ Metadata.getNamespace() }};

{{ AbstractBean.printUse() }}
{{ Bean.printUse() }}
{{ Catalog.printUse() }}
{{ Factory.printUse() }}
{{ Collection.printUse() }}
{{ Exception.printUse() }}
{{ Query.printUse() }}

{% include "header_class.tpl" with {'infoClass': Metadata} %}
class {{ Metadata }} extends {{ AbstractMetadata }}
{

    /**
     * @return \{{ Bean.getFullname }}
     */
    public static function newBean(array $fields){
        return {{ Factory }}::createFromArray($fields);
    }
    
    /**
     * @return \{{ Query.getFullname }}
     */
    public static function newQuery(){
        return {{ Query }}::create();
    }
    
    /**
     * @return \{{ Collection.getFullname }}
     */
    public static function newCollection(){
        return new {{ Collection }}();
    }
    
    /**
     * @throws \{{ Exception.getFullname }}
     */
    public static function throwException($message, $previous){
        throw new {{ Exception }}($message);
    }
    
    /**
     * @return string
     */
    public static function getTablename(){
        return {{ Bean }}::TABLENAME;
    }
    
    /**
     * @return array
     */
    public static function getFields(){
        return array({% for field in fields %}'{{ field.getName() }}', {% endfor %});    
    }
    
    /**
     * @return string
     */
    public static function getPrimaryKey(){
        return '{{ primaryKey }}';
    }
    
    /**
     * @return boolean
     */
    public static function isBean($bean){
        return $bean instanceOf {{ Bean }};
    }
    
    /**
     * @return array
     */
    public static function toUpdateArray({{ AbstractBean }} $bean){
        return $bean->toArrayFor(
            array({% for field in fields.nonPrimaryKeys %}'{{ field.getName() }}', {% endfor %})
        );
    }
    
    /**
     * @return array
     */
    public static function toCreateArray({{ AbstractBean }} $bean){
        return $bean->toArrayFor(
            array({% for field in fields.nonPrimaryKeys %}'{{ field.getName() }}', {% endfor %})
        );
    }
    
    /**
     * @return \{{ Catalog.getFullname }}
     */
    public static function getCatalog(){
        return static::getContainer()->get('{{ Catalog }}');
    }
    
    /**
     * @return \{{ Factory.getFullname }}
     */
    public static function getFactory(){
        return new {{ Factory }}();
    }

}