{% include 'header.tpl' %}
{% set AbstractBean = classes.get('AbstractBean') %}
namespace {{ Bean.getNamespace() }};

{% if parent %}{{ classes.get(parent.getObject()).printRequire() }}{% else %}
{% if AbstractBean.getNamespace() != Bean.getNamespace() %}{{ AbstractBean.printUse() }}{% endif %}
{% endif %}
{% include "header_class.tpl" with {'infoClass': Bean} %}
class {{ Bean }} extends {% if parent %}{{ parent.getObject() }}{% else %}{{ AbstractBean }}{% endif %}
{

    /**
     * TABLENAME
     */
    const TABLENAME = '{{ table.getName() }}';

    /**
     * Constants Fields
     */
{% for field in fields %}
    const {{ field.getName().toUpperCase() }} = '{{ field.getName() }}';
{% endfor %}
{% for field in fields %}

    /**
     * @var {{ field.cast('php') }}
     */
    private ${{ field.getName().toCamelCase() }};

{% if field.isDatetime or field.isDate  %}
    /**
     * @var \Zend_Date
     */
    private ${{ field.getName().toCamelCase() }}AsZendDate;

{% endif %}
{% endfor %}

    /**
     *
     * @return int
     */
    public function getIndex(){
        return $this->{{ table.getPrimaryKey().getter }}();
    }

{% for field in fields %}

    /**
     * @return {{ field.cast('php') }}
     */
    public function {{ field.getter }}(){
        return $this->{{ field.getName().toCamelCase() }};
    }

    /**
     * @param {{ field.cast('php') }} ${{ field.getName().toCamelCase()}}
     * @return {{ Bean }}
     */
    public function {{ field.setter }}(${{ field.getName().toCamelCase()}}){
        $this->{{ field.getName().toCamelCase() }} = ${{ field.getName().toCamelCase()}};
        return $this;
    }

{% if field.isDatetime or field.isDate  %}
    /**
     * @return \Zend_Date
     */
    public function {{ field.getter }}AsZendDate(){
        if( null == $this->{{ field.getName().toCamelCase() }}AsZendDate ){
            $this->{{ field.getName().toCamelCase() }}AsZendDate = new \Zend_Date($this->{{ field.getName().toCamelCase() }}, 'yyyy-MM-dd{% if field.isDatetime %} HH:mm:ss{% endif %}');
        }
        return $this->{{ field.getName().toCamelCase() }}AsZendDate;
    }

{% endif %}
{% endfor %}

    /**
     * Convert to array
     * @return array
     */
    public function toArray()
    {
        $array = array(
{% for field in fields %}
            '{{ field.getName()}}' => $this->{{ field.getter }}(),
{% endfor %}
        );
{%if parent %}
        return array_merge(parent::toArray(), $array);
{% else %}
        return $array;
{% endif %}
    }
{% if table.getOptions.has('crud') and fields.hasColumnName('/status/i') %}

{% set statusField = fields.getByColumnName('/status/i') %}
    /**
     * @staticvar array
     */
    public static ${{ statusField.getName().toUpperCamelCase() }} = array(
        'Active' => 1,
        'Inactive' => 2,
    );
{% endif %}

}