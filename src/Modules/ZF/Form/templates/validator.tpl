{% include 'header.tpl' %}
{% set BaseValidator = classes.get('BaseValidator') %}
{{ Validator.printNamespace() }}


{%if isZF2 %}
use Zend\Validator\ValidatorChain as ZendValidator;
{% else %}
use Zend_Validate as ZendValidator;
{% endif %}

/**
 *
 * {{ Validator }}
 * @author chente
 *
 */
class {{ Validator }} extends {% if parent %}{{ classes.get(parent.getObject()~'Validator') }}{% else %}{{ BaseValidator }}{% endif %}
{

    /**
     * Construct
     */
    public function __construct()
    {
        parent::__construct();
{% for field in fields %}
        $this->init{{ field.getName().toUpperCamelCase }}Validator();
{% endfor %}
    }
{% for field in fields %}

    /**
     *
     */
    protected function init{{ field.getName().toUpperCamelCase }}Validator()
    {
        $validator = new ZendValidator();
{% if field.isRequired() %}
        $validator->addValidator($this->getNotEmpty());
{% endif %}
{% if field.isBigint() or field.isInteger() or field.isSmallint() %}
        $validator->addValidator($this->getDigits());
{% endif %}
{% if  field.isFloat() or field.isDecimal() %}
        $validator->addValidator($this->getFloat());
{% endif %}
{% if field.isDate() %}
        $validator->addValidator($this->getDateMysql());
{% endif %}
{% if field.isDatetime() %}
        $validator->addValidator($this->getDatetimeMysql());
{% endif %}
{% if field.isTime() %}
        $validator->addValidator($this->getTimeMysql());
{% endif %}
{% if field.isString() or field.isText() %}
        $validator->addValidator($this->getAlnumSpaces());
{% endif %}
        $this->elements['{{ field.getName() }}'] = $validator;
    }
{% endfor %}

 }
