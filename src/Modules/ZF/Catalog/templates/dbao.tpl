{% include 'header.tpl' %}
{% set DBAO = classes.get('DBAO') %}
{{ DBAO.printNamespace() }}

{% include "header_class.tpl" with {'infoClass': DBAO} %}
interface {{ DBAO }}
{

    /**
     *
     * @return \Zend_Db_Adapter_Abstract
     */
    public function getDbAdapter();

}