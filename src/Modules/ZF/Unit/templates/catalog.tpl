{% include 'header.tpl' %}
{% set BaseTest = classes.get('BaseTest') %}

namespace Test\Unit;

{{ Catalog.printUse() }}

class {{ Catalog }}Test extends {{ BaseTest }}
{

    /**
     * @test
     */
    public function create()
    {
        ${{ catalog }} = new {{ Catalog }}();

        $dbAdapter = new \Zend_Test_DbAdapter();
        $dbAdapter->appendLastInsertIdToStack(999);
        ${{ catalog }}->setDBAO($this->getDBAOMockup($dbAdapter));

        ${{ bean }} = $this->new{{ Bean }}();
        ${{ catalog }}->create(${{ bean }});

        $this->assertEquals(999, ${{ bean }}->{{ primaryKey.getter }}());
        $this->assertEquals("", $dbAdapter->getProfiler()->getLastQueryProfile()->getQuery());
    }
    
    /**
     * @return {{ Bean }}
     */
    private function new{{ Bean }}(){
        $array = array(
{%for field in fields %}
            '{{ field }}' => 'value',
{% endfor %}
        );
        return \{{ Factory.getFullname() }}::createFromArray($array);
    }

}
