{% include 'header.tpl' %}
{% set BaseTest = classes.get('BaseTest') %}

namespace Test\Unit;

{{ Query.printUse() }}

class {{ Bean }}QueryTest extends {{ BaseTest }}
{

    /**
     * @test
      */
    public function create(){
        $query = {{ Query }}::create();
        $this->assertTrue($query instanceof {{ Query }});
    }
    
    /**
     * @test
      */
    public function pk(){
        $query = {{ Query }}::create();
        $this->assertEquals("WHERE ( `{{ Bean }}`.`{{ primaryKey.getName() }}` = 1 )", $query->pk(1)->createWhereSql());
    }
    
    /**
     * @test
     */
    public function filter(){
       $query = {{ Query }}::create();
       $params = array();
{% for field in table.getFullColumns %}
       $params['{{ field.getName()}}'] = 1;
{% endfor %}
       $this->assertEquals(count($params), $query->filter($params)->where()->count());
    }

    /**
     * @test
      */
    public function initialization(){
        $query = {{ Query }}::create();
        $defaultColumn = array('{{ Bean }}.*');
        
{% set auxTable = table %}
{% for i in 1..5 %}
{% if auxTable.hasParent() %}
{% set auxTable = auxTable.getParent() %}
        $this->assertTrue($query->hasJoin('{{ auxTable.getObject().toUpperCamelCase() }}'));
        $defaultColumn[] = '{{ auxTable.getObject().toUpperCamelCase() }}.*';
{% endif%}
{% endfor %}
        $this->assertTrue($query->getDefaultColumn() == $defaultColumn);
    }
{% for manyToMany in table.getManyToManyCollection %}
{% set localColumn = manyToMany.getLocalColumn() %}
{% set relationColumn = manyToMany.getRelationColumn() %}
{% set relationTable = manyToMany.getRelationTable() %}
{% set classForeign = classes.get(manyToMany.getForeignTable().getObject().toString()) %}
{% set foreignTable = manyToMany.getForeignTable() %}
{% set relationForeignColumn = manyToMany.getRelationForeignColumn() %}
{% set pk1 = relationColumn.getName() %}
{% set pk2 = relationForeignColumn.getName() %}

    /**
     * @test
     */
    public function innerJoin{{ classForeign }}(){
       $query = {{ Query }}::create();
       $query->removeJoins();
       
       $query->innerJoin{{ classForeign }}();
       $sql = "INNER JOIN `{{ relationTable.getName().toString() }}` as `{{ Bean }}2{{ classForeign }}` ON( `{{ Bean }}`.`{{ localColumn.getName().toString() }}` = `{{ Bean }}2{{ classForeign }}`.`{{ relationColumn.getName().toString() }}` ) INNER JOIN `{{ foreignTable.getName() }}` as `{{ classForeign }}` ON( `{{ Bean }}2{{ classForeign }}`.`{{ relationForeignColumn.getName().toString() }}` = `{{ classForeign }}`.`{{ foreignTable.getPrimaryKey().getName().toString() }}` )";
       $this->assertEquals($sql, $query->createJoinSql());
    }
{% endfor %}

{% for foreignKey in foreignKeys %}
{% set classForeign = classes.get(foreignKey.getForeignTable().getObject().toUpperCamelCase()) %}

    /**
     * @test
     */
    public function innerJoin{{ classForeign }}(){
       $query = {{ Query }}::create();
       $query->removeJoins();
       
       $query->innerJoin{{ classForeign }}();
       $sql = "INNER JOIN `{{ foreignKey.getForeignTable().getName().toString() }}` as `{{ classForeign }}` ON( `{{ Bean }}`.`{{ foreignKey.getLocal() }}` = `{{ classForeign }}`.`{{ foreignKey.getForeign().getName().toString() }}` )";
       $this->assertEquals($sql, $query->createJoinSql());
    }

{% endfor %}

}
