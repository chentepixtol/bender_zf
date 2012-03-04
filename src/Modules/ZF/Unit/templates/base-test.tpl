{% include 'header.tpl' %}
{% set BaseTest = classes.get('BaseTest') %}
{% set DBAO = classes.get('DBAO') %}

{{ BaseTest.printNamespace() }}

class DBAOWrapper implements \{{ DBAO.getFullname() }}{
    private $dbAdapter;
    public function __construct($dbAdapter){
        $this->dbAdapter = $dbAdapter;
    }
    public function getDbAdapter(){
        return $this->dbAdapter;
    }
}

/**
 *
 * @author chente
 *
 */
abstract class {{ BaseTest }} extends \PHPUnit_Framework_TestCase
{

    /**
     *
     * @param \Zend_Db_Adapter_Abstract $dbAdapter
     * @return \{{ DBAO.getFullname() }}
     */
    public function getDBAOMockup($dbAdapter){
        $dbao = new DBAOWrapper($dbAdapter);
        return $dbao;
    }

}

