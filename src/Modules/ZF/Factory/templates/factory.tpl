{% include 'header.tpl' %}
{{ Factory.printNamespace() }}

{{ classes.get(Bean).printUse() }}
{% if classes.get('Factory').getNamespace() != Factory.getNamespace() %}{{ classes.get('Factory').printUse() }}{% endif %}

{% include "header_class.tpl" with {'infoClass': Factory} %}
class {{ Factory }}{% if parent %} extends {{ classes.get(parent.getObject()~'Factory') }}{% endif %} implements {{ classes.get('Factory') }}
{

    /**
     *
     * @static
     * @param array $fields
     * @return \{{ Bean.getFullName() }}
     */
    public static function createFromArray($fields)
    {
        ${{ bean }} = new {{ Bean }}();
        self::populate(${{ bean }}, $fields);

        return ${{ bean }};
    }

    /**
     *
     * @static
     * @param {{ Bean }} {{ bean }}
     * @param array $fields
     */
    public static function populate(${{ bean }}, $fields)
    {
{% if parent %}
        parent::populate(${{ bean }}, $fields);
{% endif %}
        if( !(${{ bean }} instanceof {{ Bean }}) ){
            static::throwException("El objecto no es un {{ Bean }}");
        }
{% for field in fields %}

        if( isset($fields['{{ field }}']) ){
            ${{ bean }}->{{ field.setter }}($fields['{{ field }}']);
        }
{% endfor %}
    }

    /**
     * @throws {{ Exception }}
     */
    protected static function throwException($message){
        throw new \{{ Exception.getFullName() }}($message);
    }

}