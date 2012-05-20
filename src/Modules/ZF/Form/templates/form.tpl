{% include 'header.tpl' %}
{% set BaseForm = classes.get('BaseForm') %}{% if parent %}{% set parentPrimaryKey = parent.getPrimaryKey() %}{% endif %}
{{ Form.printNamespace() }}

{{ Validator.printUse() }}
{{ Filter.printUse() }}
{{ Bean.printUse() }}

{% if isZF2 %}
use Zend\Form\Element;
{% set ElementText = 'Element\\Text' %}
{% else %}
use \Zend_Form_Element_Text as ElementText;
{% set ElementText = 'ElementText' %}
{% endif %}

/**
 *
 * {{ Form }}
 * @author chente
 *
 */
class {{ Form }} extends {% if parent %}{{ classes.get(parent.getObject()~'Form') }}{% else %}{{ BaseForm }}{% endif %}
{

    /**
     *
     * @var {{ Bean }}
     */
    private ${{ bean }};

    /**
     *
     * @param {{ Bean }} ${{ bean }}
     */
    public function set{{ Bean }}({{ Bean }} ${{ bean }} = null){
        $this->{{ bean }} = ${{ bean }};
    }

    /**
     *
     * @return {{ Bean }}
     */
    public function get{{ Bean }}(){
        return $this->{{ bean }};
    }

    /**
     * @return boolean
     */
    public function isEdit(){
        return $this->{{ bean }} instanceof {{ Bean }};
    }
    
    /**
     * @return boolean
     */
    public function isNew(){
        return !$this->isEdit();
    }

    /**
     * init
     */
    public function init()
    {
        parent::init();
        $this->validator = new {{ Validator }}();
        $this->filter = new {{ Filter }}();

{% for field in fields.nonPrimaryKeys() %}
{% if field.getName().toString() != parentPrimaryKey.getName().toString() %}
        $this->init{{ field.getName().toUpperCamelCase() }}Element();
{% endif %}
{% endfor %}
    }

{% for field in fields.nonPrimaryKeys() %}{% if field.getName().toString() != parentPrimaryKey.getName().toString() %}

    /**
     *
     */
    protected function init{{ field.getName().toUpperCamelCase() }}Element()
    {
{% if fields.inForeignKeys.containsIndex(field.getName().toString()) %}
{% set foreignKey = foreignKeys.getByColumnName(field.getName().toString()) %}
        $element = new \Zend_Form_Element_Select('{{ field.getName().toUnderscore() }}');
        $options = \{{ classes.get(foreignKey.getForeignTable.getObject() ~ 'Query').getFullname() }}::create()->find()->toCombo();
        $element->addMultiOptions($options);
{% elseif field.isBoolean %}
        $element = new \Zend_Form_Element_Checkbox('{{ field.getName().toUnderscore() }}');
{% else %}
        $element = new {{ ElementText }}('{{ field.getName().toUnderscore() }}');
{% endif %}
{% if field.isDate or field.isDatetime %}
        $element->setAttrib('class', 'datepicker');
{% endif %}
        $element->setLabel($this->getTranslator()->_('{{ field.getName().toUpperCamelCase() }}'));
        $element->addValidator($this->validator->getFor('{{ field.getName() }}'));
        $element->addFilter($this->filter->getFor('{{ field }}'));
{% if field.isRequired %}
        $element->setRequired(true);
{% endif %}
        $this->addElement($element);
        $this->elements['{{ field.getName().toUnderscore() }}'] = $element;
    }
{% endif %}{% endfor %}

}