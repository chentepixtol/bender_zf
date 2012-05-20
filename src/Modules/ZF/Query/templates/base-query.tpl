{% include 'header.tpl' %}

{% set BaseQuery = classes.get('BaseQuery') %}
{% set CatalogInterface = classes.get('Catalog') %}
{% set Storage = classes.get('Storage') %}
{% set FactoryStorage = classes.get('FactoryStorage') %}
{% set Option = classes.get('Option') %}

{{ BaseQuery.printNamespace() }}

use Query\Query;
{{ Storage.printUse() }}
{{ FactoryStorage.printUse() }}
{{ Option.printUse() }}

/**
 *
 *
 * @author chente
 * @abstract
 */
abstract class {{ BaseQuery }} extends Query
{

    /**
     *
     */
    protected $storage = null;

    /**
     *
     * @var \Query\QuoteStrategy
     */
    private static $zendDbStrategy = null;

    /**
     * @abstract
     * @return \{{ classes.get('Metadata').getFullName() }}
     */
    abstract protected function getMetadata();

     /**
     * @param mixed $value
     * @return {{ BaseQuery }}
     */
    public function pk($value){
        $this->filter(array(
            $this->getMetadata()->getPrimaryKey() => $value,
        ));
        return $this;
    }

    /**
     * @return array
     */
    public function fetchIds(){
       $this->removeColumn()->addColumn($this->getMetadata()->getPrimaryKey(), 'ids');
       return $this->fetchCol();
    }

    /**
     *
     * @param \Query\QuoteStrategy $quoteStrategy
     */
    public function __construct(\Query\QuoteStrategy $quoteStrategy = null){
        if( $quoteStrategy == null ){
            $quoteStrategy = self::getZendDbQuoteStrategy();
        }
        parent::__construct($quoteStrategy);
    }

    /**
     * @return \Query\QuoteStrategy
     */
    public static function getZendDbQuoteStrategy(){
        if( null == self::$zendDbStrategy ){
            self::$zendDbStrategy = new \Query\ZendDbQuoteStrategy(self::getDBAdapter());
        }
        return self::$zendDbStrategy;
    }

    /**
     * @return {{ BaseQuery }}
     */
    public function useMemoryCache(){
       $this->setStorage({{ FactoryStorage }}::create('memory'));
       return $this;
    }

    /**
     * @return {{ BaseQuery }}
     */
    public function useFileCache(){
       $this->setStorage({{ FactoryStorage }}::create('file'));
       return $this;
    }

    /**
     * @return {{ BaseQuery }}
     */
    public function notCache(){
       $this->setStorage({{ FactoryStorage }}::create('null'));
       return $this;
    }

    /**
     *
     * @return \{{ classes.get('Collection').getFullName() }}
     */
    public function find(){
        return $this->getCatalog()->getByQuery($this, $this->getStorage());
    }

    /**
     *
     * @return \{{ classes.get('Bean').getFullName() }}
     */
    public function findOne(){
        return $this->getCatalog()->getOneByQuery($this, $this->getStorage());
    }

    /**
     * @param mixed $pk
     * @return \{{ classes.get('Bean').getFullName() }}
     */
    public function findByPK($pk){
        $this->validatePK($pk);
        return $this->pk($pk)->findOne();
    }

    /**
     * @return int
     */
    public function count($field = '*'){
       $this->addColumn($field, 'count', Query::COUNT);
       return (int) $this->fetchOne();
    }

    /**
     * @return \{{ Option.getFullName() }}
     */
    public function findOneOption(){
        return new {{ Option }}($this->findOne());
    }

    /**
     * @param mixed $alternative
     * @return \{{ classes.get('Bean').getFullName() }}
     */
    public function findOneOrElse($alternative){
        return $this->findOneOption()->getOrElse($alternative);
    }

    /**
     * @param mixed $message
     * @return \{{ classes.get('Bean').getFullName() }}
     * @throws \UnexpectedValueException
     */
    public function findOneOrThrow($message){
        return $this->findOneOption()->getOrThrow($message);
    }

    /**
     * @param mixed $pk
     * @return \{{ Option.getFullName() }}
     */
    public function findOptionByPK($pk){
        $this->validatePK($pk);
        return $this->pk($pk)->findOneOption();
    }

    /**
     * @param mixed $pk
     * @param mixed $alternative
     * @return \{{ classes.get('Bean').getFullName() }}
     */
    public function findByPKOrElse($pk, $alternative){
        return $this->findOptionByPK($pk)->getOrElse($alternative);
    }

    /**
     * @param mixed $pk
     * @param mixed $message
     * @return \{{ classes.get('Bean').getFullName() }}
     * @throws \UnexpectedValueException
     */
    public function findByPKOrThrow($pk, $message){
        return $this->findOptionByPK($pk)->getOrThrow($message);
    }

    /**
     *
     * @return array
     */
    public function fetchCol(){
        return $this->getCatalog()->fetchCol($this, $this->getStorage());
    }

    /**
     *
     * @return array
     */
    public function fetchAll(){
        return $this->getCatalog()->fetchAll($this, $this->getStorage());
    }

    /**
     *
     * @return mixed
     */
    public function fetchOne(){
        return $this->getCatalog()->fetchOne($this, $this->getStorage());
    }

    /**
     *
     * @return array
     */
    public function fetchPairs(){
        return $this->getCatalog()->fetchPairs($this, $this->getStorage());
    }

    /**
     * @param {{ Storage }} $storage
     * @return {{ BaseQuery }}
     */
    public function setStorage({{ Storage }} $storage){
        $this->storage = $storage;
        return $this;
    }

    /**
     * @return \{{ Storage.getFullName() }}
     */
    public function getStorage(){
        return $this->storage;
    }

    /**
     * @param mixed $pk
     */
    private function validatePK($pk){
        if( empty($pk) ){
            throw new \Exception("No es proporcionada la llave primaria");
        }
    }
    
    /**
     *
     */
    private static function getDBAdapter(){
        return \Zend_Registry::get('container')->get('dbao')->getDbAdapter();
    }
    
    /**
     *
     * @return \{{ CatalogInterface.getFullname }}
     */
    protected function getCatalog(){
        return $this->getMetadata()->getCatalog();
    }
}