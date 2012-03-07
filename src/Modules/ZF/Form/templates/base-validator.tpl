{% include 'header.tpl' %}
{% set BaseValidator = classes.get('BaseValidator') %}
{{ BaseValidator.printNamespace() }}

/**
 *
 * {{ BaseValidator }}
 * @author chente
 *
 */
class {{ BaseValidator }}
{

    /**
     *
     * @var array
     */
    private $messages = array();

    /**
     *
     * @var array
     */
    protected $elements = array();

    /**
     * @var \Zend_Validate_Interface
     */
    private static $alnumSpaces;

    /**
     * @var \Zend_Validate_Interface
     */
    private static $notEmpty;

    /**
     * @var \Zend_Validate_Digits
     */
    private static $digits;

    /**
     * @var \Zend_Validate_Float
     */
    private static $float; 

    /**
     * @var \Zend_Validate_Date
     */
    private static $dateMysql;

    /**
     * @var \Zend_Validate_Date
     */
    private static $datetimeMysql;

    /**
     * @var \Zend_Validate_Date
     */
    private static $timeMysql;   

    /**
     *
     */
    public function __construct(){}

    /**
     * isValid
     * @param array $array
     * @return boolean
     */
    public function isValid(array $array)
    {
        $isValid = true;
        $this->messages = array();

        foreach( $this->toArray() as $field  => $validate ){
            if( !$validate->isValid($array[$field]) ){
                $isValid = false;
                $this->addMessage($field, $validate->getMessages());
            }
        }
        return $isValid;
    }

    /**
     * @param string $fieldName
{%if isZF2 %}
     * @return \Zend\Validator\ValidatorChain
{% else %}
     * @return \Zend_Validate
{% endif %}
     */
    public function getFor($fieldName){
         if( !isset($this->elements[$fieldName]) ){
             throw new \InvalidArgumentException("No existe el validator ". $fieldName);
         }
         return $this->elements[$fieldName];
    }

    /**
     *
     * @param string $field
     * @param array $messages
     */
    protected function addMessage($field, $messages){
        $this->messages[$field] = $messages;
    }

    /**
     * @return array
     */
    public function getMessages(){
        return $this->messages;
    }

    /**
     * @return array
     */
    public function toArray(){
        return $this->elements;
    }
    
    /**
     * @return \Zend_Validate_Alnum
     */
    public static function getAlnumSpaces(){
        if( null == self::$alnumSpaces ){
            self::$alnumSpaces = new \Zend_Validate_Alnum(array('allowWhiteSpace' => true));
        }
        return self::$alnumSpaces;
    }

    /**
     * @return \Zend_Validate_NotEmpty
     */
    public static function getNotEmpty(){
        if( null == self::$notEmpty ){
            self::$notEmpty = new \Zend_Validate_NotEmpty();
        }
        return self::$notEmpty;
    }

    /**
     * @return \Zend_Validate_Digits
     */
    public static function getDigits(){
        if( null == self::$digits ){
            self::$digits = new \Zend_Validate_Digits();
        }
        return self::$digits;
    }

    /**
     * @return \Zend_Validate_Float
     */
    public static function getFloat(){
        if( null == self::$float ){
            self::$float = new \Zend_Validate_Float();
        }
        return self::$float;
    }
    
    /**
     * @return \Zend_Validate_Date
     */
    public static function getDateMysql(){
        if( null == self::$dateMysql ){
            self::$dateMysql = new \Zend_Validate_Date(array('format' => 'yyyy-MM-dd'));
        }
        return self::$dateMysql;
    }
    
    /**
     * @return \Zend_Validate_Date
     */
    public static function getDatetimeMysql(){
        if( null == self::$datetimeMysql ){
            self::$datetimeMysql = new \Zend_Validate_Date(array('format' => 'yyyy-MM-dd HH:mm:ss'));
        }
        return self::$datetimeMysql;
    }
    
    /**
     * @return \Zend_Validate_Date
     */
    public static function getTimeMysql(){
        if( null == self::$timeMysql ){
            self::$timeMysql = new \Zend_Validate_Date(array('format' => 'HH:mm:ss'));
        }
        return self::$timeMysql;
    }

}
