{% include 'header.tpl' %}
{% set BaseForm = classes.get('BaseForm') %}
{{ BaseForm.printNamespace() }}

{% if isZF2 %}
use ZFriendly\Form\Twitter as TwitterForm;
use Zend\View\PhpRenderer as ZendView;
{% else %}
use Zend_View as ZendView;
{% endif %}

/**
 *
 * {{ BaseForm }}
 * @author chente
 *
 */
class {{ BaseForm }} extends {% if isZF2 %}TwitterForm{% else %}\ZFriendly\Form\Twitter{% endif %}
{

    /**
     * @var \{{ classes.get('BaseValidator').getFullName() }} $validator
     */
    protected $validator;
    
    /**
     * @var \{{ classes.get('BaseFilter').getFullName() }} $filter
     */
    protected $filter;
    
    /**
     * @var array
     */ 
    protected $elements = array();

    /**
     * init
     */
    public function init(){
        parent::init();
        $this->setView(new ZendView());
    }
    
    /**
     * @param string $fieldName
{% if isZF2 %}
     * @return \Zend\Form\Element
{% else %}
     * @return \Zend_Form_Element
{% endif %}
     */
    public function getFor($fieldName){
         if( !isset($this->elements[$fieldName]) ){
             throw new \InvalidArgumentException("No existe el elemento ". $fieldName);
         }
         return $this->elements[$fieldName];
    }
   
}
