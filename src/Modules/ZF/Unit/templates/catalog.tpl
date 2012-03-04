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
    public function getOneByQuery()
    {
        ${{ catalog }} = new {{ Catalog }}();

        $dbAdapter = new \Zend_Test_DbAdapter();
        ${{ catalog }}->setDBAO($this->getDBAOMockup($dbAdapter));

        $row = array_merge(array('{{ primaryKey }}' => 999), $this->getColumns());
        $stmt1 = \Zend_Test_DbStatement::createSelectStatement(array($row));
        $dbAdapter->appendStatementToStack($stmt1);

        ${{ bean }} = ${{ catalog }}->getOneByQuery($this->getEmptyQuery());
        $this->assertTrue(${{ bean }} instanceOf \{{ Bean.getFullname() }} );
        $this->assertEquals($row, ${{ bean }}->toArrayFor(array_keys($row)) );
    }

    /**
     * @test
     */
    public function getByQuery()
    {
        ${{ catalog }} = $this->getCatalogWithMultipleRows($this->getRows());

        ${{ collection }} = ${{ catalog }}->getByQuery($this->getEmptyQuery());
        $this->assertTrue(${{ collection }} instanceOf \{{ Collection.getFullname() }} );
        $this->assertEquals(2, ${{ collection }}->count());
        $this->assertEquals(array(999, 555), ${{ collection }}->getPrimaryKeys());
    }

    /**
     * @test
     */
    public function fetchAll()
    {
        ${{ catalog }} = $this->getCatalogWithMultipleRows($this->getRows());

        $resultSet = ${{ catalog }}->fetchAll($this->getEmptyQuery());
        $this->assertTrue(is_array($resultSet));
        $this->assertEquals(2 , count($resultSet));
        $this->assertEquals($this->getRows(), $resultSet);
    }

    /**
     * @test
     */
    public function fetchCol()
    {
        ${{ catalog }} = $this->getCatalogWithMultipleRows( array(999, 555) );

        $resultSet = ${{ catalog }}->fetchCol($this->getEmptyQuery());
        $this->assertTrue(is_array($resultSet));
        $this->assertEquals(2 , count($resultSet));
        $this->assertEquals(array(999, 555), $resultSet);
    }

    /**
     * @test
     */
    public function fetchOne()
    {
        ${{ catalog }} = $this->getCatalogWithMultipleRows( array(array(999)) );

        $resultSet = ${{ catalog }}->fetchOne($this->getEmptyQuery());
        $this->assertEquals(999, $resultSet);
    }

    /**
     * @test
     */
    public function fetchPairs()
    {
        ${{ catalog }} = $this->getCatalogWithMultipleRows( array(array(999, 'value'), array(555, 'value') ));

        $resultSet = ${{ catalog }}->fetchPairs($this->getEmptyQuery());
        $this->assertTrue(is_array($resultSet));
        $this->assertEquals(2 , count($resultSet));
        $this->assertEquals(array(999 => 'value', 555 => 'value'), $resultSet);
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

        try{
            ${{ catalog }}->update(new \stdClass());
            $this->fail("Se deberia de lanzar una exception");
        }catch(\{{ Exception.getFullname() }} $e){
            $this->assertTrue(true);
        }
    }

    /**
     * @return {{ Catalog }}
     */
    private function getCatalogWithMultipleRows($rows){
        ${{ catalog }} = new {{ Catalog }}();

        $dbAdapter = new \Zend_Test_DbAdapter();
        ${{ catalog }}->setDBAO($this->getDBAOMockup($dbAdapter));

        $stmt1 = \Zend_Test_DbStatement::createSelectStatement($rows);
        $dbAdapter->appendStatementToStack($stmt1);

        return ${{ catalog }};
    }

    /**
     * @return array
     */
    private function getRows(){
        $row999 = array_merge(array('{{ primaryKey }}' => 999), $this->getColumns());
        $row555 = array_merge(array('{{ primaryKey }}' => 555), $this->getColumns());
        $rows = array($row999, $row555);

        return $rows;
    }

    /**
     * @return {{ Query.getFullname() }}
     */
    private function getEmptyQuery(){
        return \{{ Query.getFullname() }}::create();
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
