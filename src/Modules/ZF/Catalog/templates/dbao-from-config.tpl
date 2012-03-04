{% include 'header.tpl' %}
{% set DBAO = classes.get('DBAO') %}
{{ DBAO.printNamespace() }}

{%if isZF2 %}
use Zend\Db\Db as ZendDb;
{% else %}
use Zend_Db as ZendDb;
{% endif %}

{% include "header_class.tpl" with {'infoClass': DBAO} %}
class DBAOFromConfig implements {{ DBAO }}
{

    /**
{%if isZF2 %}
     * @var \Zend\Db\Adapter\AbstractAdapter
{% else %}
     * @var \Zend_Db_Adapter_Abstract
{% endif %}
     */
    protected $dbAdapter  = null;

    /**
     * @param Config
     */
    public function __construct($dbConfig){
        $this->dbAdapter = ZendDb::factory($dbConfig->database);
    }

    /**
     * Metodo para obtener la Connection
     * @return \Zend_Db_Adapter_Abstract
     */
    public function getDbAdapter(){
        return $this->dbAdapter;
    }

}