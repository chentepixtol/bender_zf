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
        
        $lastQuery = $dbAdapter->getProfiler()->getLastQueryProfile();

        $this->assertEquals(999, ${{ bean }}->{{ primaryKey.getter }}());
        
        $values = implode(array_fill(0, count($this->getColumns()), "?"), ', ');
        $keys = implode(array_keys($this->getColumns()), ', ');
        $this->assertEquals("INSERT INTO {{ table.getName() }} (". $keys .") VALUES (" . $values . ")", $lastQuery->getQuery());
        $this->assertEquals(array_values($this->getColumns()), array_values($lastQuery->getQueryParams()));
    }
    
    /**
     * @test
     */
    public function update()
    {
        ${{ catalog }} = new {{ Catalog }}();

        $dbAdapter = new \Zend_Test_DbAdapter();
        ${{ catalog }}->setDBAO($this->getDBAOMockup($dbAdapter));

        ${{ bean }} = $this->new{{ Bean }}();
        ${{ bean }}->{{ primaryKey.setter }}(999);
        ${{ catalog }}->update(${{ bean }});
        
        $lastQuery = $dbAdapter->getProfiler()->getLastQueryProfile();
        
        $keys = "SET " . implode(array_keys($this->getColumns()), ' = ?, ') . " = ?";
        $this->assertEquals("UPDATE {{ table.getName() }} ". $keys ." WHERE ({{ primaryKey }} = '999')", $lastQuery->getQuery());
        $this->assertEquals(array_values($this->getColumns()), array_values($lastQuery->getQueryParams()));
    }
    
    /**
     * @test
     */
    public function invalidArgument(){
        ${{ catalog }} = new {{ Catalog }}();

        $dbAdapter = new \Zend_Test_DbAdapter();
        ${{ catalog }}->setDBAO($this->getDBAOMockup($dbAdapter));
        
        try{
            ${{ catalog }}->create(new \stdClass());
            $this->fail("Se deberia de lanzar una exception");
        }catch(\{{ Exception.getFullname() }} $e){
            $this->assertTrue(true);
        }
    }
    
    /**
     * @return {{ Bean }}
     */
    private function new{{ Bean }}(){
        return \{{ Factory.getFullname() }}::createFromArray($this->getColumns());
    }
    
    /**
     * @return array
     */
    private function getColumns(){
        $array = array(
{%for field in fields if field != primaryKey %}
            '{{ field }}' => 'value{{ loop.index }}',
{% endfor %}
        );
        return $array;
    }

}
