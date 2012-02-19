{% include 'header.tpl' %}
{% set BaseQuery = classes.get('BaseQuery') %}
{{ Query.printNamespace() }}

use Query\Query;
{{ Catalog.printUse() }}
{{ Bean.printUse() }}

{% if parent %}
{% set parentQuery = classes.get(parent.getObject()~'Query') %}
{% else %}
{{ BaseQuery.printUse() }}
{% endif %}

/**
 * {{ Query }}
 *
 * @method {{ Query }} pk() pk(int $primaryKey)
 * @method {{ Query }} useMemoryCache()
 * @method {{ Query }} useFileCache()
 * @method \{{ Collection.getFullName() }} find()
 * @method \{{ Bean.getFullName() }} findOne()
 * @method \{{ Bean.getFullName() }} findOneOrElse() findOneOrElse({{ Bean }} $alternative)
 * @method \{{ Bean.getFullName() }} findOneOrThrow() findOneOrThrow($message)
 * @method \{{ Bean.getFullName() }} findByPK() findByPK($pk)
 * @method \{{ Bean.getFullName() }} findByPKOrElse() findByPKOrElse($pk, {{ Bean }} $alternative)
 * @method \{{ Bean.getFullName() }} findByPKOrThrow() findByPKOrThrow($pk, $message)  
 * @method {{ Query }} create() create(QuoteStrategy $quoteStrategy = null)
 * @method \Query\Criteria joinOn() joinOn($table, $type = null, $alias = null)
 * @method {{ Query }} joinUsing() joinUsing($table, $usingColumn, $type = null, $alias = null)
 * @method \Query\Criteria innerJoinOn() innerJoinOn($table, $alias = null)
 * @method {{ Query }} innerJoinUsing() innerJoinUsing($table, $usingColumn, $alias = null)
 * @method \Query\Criteria leftJoinOn() leftJoinOn($table, $alias = null)
 * @method {{ Query }} leftJoinUsing() leftJoinUsing($table, $usingColumn, $alias = null)
 * @method \Query\Criteria rigthJoinOn() rigthJoinOn($table, $alias = null)
 * @method {{ Query }} rigthJoinUsing() rigthJoinUsing($table, $usingColumn, $alias = null)
 * @method {{ Query }} removeJoins()
 * @method {{ Query }} removeJoin() removeJoin($table)
 * @method {{ Query }} from() from($table, $alias = null)
 * @method {{ Query }} removeFrom() removeFrom($from = null)
 * @method \Query\Criteria where()
 * @method \Query\Criteria having()
 * @method {{ Query }} whereAdd() $column, $value, $comparison = null, $mutatorColumn = null, $mutatorValue = null)
 * @method {{ Query }} bind() bind($parameters) 
 * @method {{ Query }} setQuoteStrategy() setQuoteStrategy(QuoteStrategy $quoteStrategy)
 * @method {{ Query }} page() page($page, $itemsPerPage)
 * @method {{ Query }} setLimit() setLimit($limit)
 * @method {{ Query }} setOffset() setOffset($offset)
 * @method {{ Query }} removeColumn() removeColumn($column = null)
 * @method {{ Query }} distinct() 
 * @method {{ Query }} select()
 * @method {{ Query }} addColumns() addColumns($columns)
 * @method {{ Query }} addColumn() addColumn($column, $alias = null, $mutator = null)
 * @method {{ Query }} addGroupBy() addGroupBy($groupBy)
 * @method {{ Query }} orderBy() orderBy($name, $type = null)
 * @method {{ Query }} intoOutfile() intoOutfile($filename, $terminated = ',', $enclosed = '"', $escaped = '\\\\', $linesTerminated ='\r\n')
 * @method {{ Query }} addAscendingOrderBy() addAscendingOrderBy($name)
 * @method {{ Query }} addDescendingOrderBy() addDescendingOrderBy($name)
 * @method {{ Query }} setDefaultColumn() setDefaultColumn($defaultColumn)
 */
class {{ Query }} extends{% if parentQuery %} {{ parentQuery}}{% else %} {{ BaseQuery }}{% endif %}
{

    /**
     * 
     * @return \{{ Catalog.getFullName() }}
     */
    protected function getCatalog(){
        return \Zend_Registry::getInstance()->get('container')->get('{{ Catalog }}');
    }

    /**
     * initialization
     */
    protected function init()
    {
        $this->from({{ Bean }}::TABLENAME, "{{ Bean }}");
{% set auxTable = table %}
{% for i in 1..5 %}
{% if auxTable.hasParent() %}
{% set auxTable = auxTable.getParent() %}
        $this->innerJoin{{ auxTable.getObject().toUpperCamelCase() }}();
{% endif%}
{% endfor %}

        $defaultColumn = array("{{ Bean }}.*");
{% set auxTable = table %}
{% for i in 1..5 %}
{% if auxTable.hasParent() %}
{% set auxTable = auxTable.getParent() %}
        $defaultColumn[] = "{{ auxTable.getObject().toUpperCamelCase() }}.*";
{% endif%}
{% endfor %}
        $this->setDefaultColumn($defaultColumn);
    }
    
    /**
     * @param mixed $value 
     * @return {{ Query }}
     */
    public function pk($value){
        $this->filter(array(
            {{ Bean }}::{{ table.getPrimaryKey().getName().toUpperCase() }} => $value,
        ));
        return $this;
    }
    
    /**
     * @return array
     */
    public function fetchIds(){
       $this->removeColumn()->addColumn({{ Bean }}::{{ table.getPrimaryKey().getName().toUpperCase() }}, 'ids');
       return $this->fetchCol();
    }
    
    /**
     * build fromArray
     * @param array $fields
     * @param string $prefix
     * @return {{ Query }}
     */
    public function filter($fields, $prefix = '{{ Bean }}'){
        $this->build($this, $fields, $prefix);
        return $this;
    }
    
    /**
     * build fromArray
     * @param Query $query
     * @param array $fields
     * @param string $prefix
     */
    public static function build(Query $query, $fields, $prefix = '{{ Bean }}')
    {
{% if parent %}
        parent::build($query, $fields);    
{% endif %}

        $criteria = $query->where();
        $criteria->prefix($prefix);
        
{% for field in fields %}
        if( isset($fields['{{ field }}']) && !empty($fields['{{ field }}']) ){
            $criteria->add({{ Bean }}::{{ field.getName().toUpperCase() }}, $fields['{{ field }}']);
        }
{% endfor %}

        $criteria->endPrefix();
    }

{% for foreignKey in foreignKeys %}
{% set classForeign = classes.get(foreignKey.getForeignTable().getObject().toUpperCamelCase()) %}
    /**
     * @param string $alias
     * @param string aliasForeignTable
     * @return {{ Query }}
     */
    public function innerJoin{{ classForeign }}($alias = '{{ Bean }}', $aliasForeignTable = '{{ classForeign }}')
    {
        $this->innerJoinOn(\{{ classForeign.getFullName() }}::TABLENAME, $aliasForeignTable)
            ->equalFields(array($alias, '{{ foreignKey.getLocal() }}'), array($aliasForeignTable, '{{ foreignKey.getForeign() }}'));

        return $this;
    }

{% endfor %}
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
     * @param string $alias
     * @param string aliasForeignTable
     * @return {{ Query }}
     */
    public function innerJoin{{ classForeign }}($alias = '{{ Bean }}', $aliasForeignTable = '{{ classForeign }}')
    {
        $this->innerJoinOn('{{ relationTable.getName().toString() }}', '{{ Bean }}2{{ classForeign }}')
            ->equalFields(array($alias, '{{ localColumn.getName().toString() }}'), array('{{ Bean }}2{{ classForeign }}', '{{ relationColumn.getName().toString() }}'));
            
        $this->innerJoinOn(\{{ classForeign.getFullName() }}::TABLENAME, $aliasForeignTable)
            ->equalFields(array('{{ Bean }}2{{ classForeign }}', '{{ relationForeignColumn.getName().toString() }}'), array($aliasForeignTable, '{{ foreignTable.getPrimaryKey().getName().toString() }}'));

        return $this;
    }

{% endfor %}

}