{% include 'header.tpl' %}
{% set BaseQuery = classes.get('BaseQuery') %}
{{ Query.printNamespace() }}

use Query\Query;
{{ Metadata.printUse() }}
{{ Bean.printUse() }}

{% if parent %}
{% set parentQuery = classes.get(parent.getObject()~'Query') %}
{% else %}
{{ BaseQuery.printUse() }}
{% endif %}

/**
 * {{ Query.getFullname() }}
 *
 * @method \{{ Query.getFullname() }} pk() pk(int $primaryKey)
 * @method \{{ Query.getFullname() }} useMemoryCache()
 * @method \{{ Query.getFullname() }} useFileCache()
 * @method \{{ Collection.getFullName() }} find()
 * @method \{{ Bean.getFullName() }} findOne()
 * @method \{{ Bean.getFullName() }} findOneOrElse() findOneOrElse({{ Bean }} $alternative)
 * @method \{{ Bean.getFullName() }} findOneOrThrow() findOneOrThrow($message)
 * @method \{{ Bean.getFullName() }} findByPK() findByPK($pk)
 * @method \{{ Bean.getFullName() }} findByPKOrElse() findByPKOrElse($pk, {{ Bean }} $alternative)
 * @method \{{ Bean.getFullName() }} findByPKOrThrow() findByPKOrThrow($pk, $message)
 * @method \{{ Query.getFullname() }} create() create(QuoteStrategy $quoteStrategy = null)
 * @method \Query\Criteria joinOn() joinOn($table, $type = null, $alias = null)
 * @method \{{ Query.getFullname() }} joinUsing() joinUsing($table, $usingColumn, $type = null, $alias = null)
 * @method \Query\Criteria innerJoinOn() innerJoinOn($table, $alias = null)
 * @method \{{ Query.getFullname() }} innerJoinUsing() innerJoinUsing($table, $usingColumn, $alias = null)
 * @method \Query\Criteria leftJoinOn() leftJoinOn($table, $alias = null)
 * @method \{{ Query.getFullname() }} leftJoinUsing() leftJoinUsing($table, $usingColumn, $alias = null)
 * @method \Query\Criteria rigthJoinOn() rigthJoinOn($table, $alias = null)
 * @method \{{ Query.getFullname() }} rigthJoinUsing() rigthJoinUsing($table, $usingColumn, $alias = null)
 * @method \{{ Query.getFullname() }} removeJoins()
 * @method \{{ Query.getFullname() }} removeJoin() removeJoin($table)
 * @method \{{ Query.getFullname() }} from() from($table, $alias = null)
 * @method \{{ Query.getFullname() }} removeFrom() removeFrom($from = null)
 * @method \Query\Criteria where()
 * @method \Query\Criteria having()
 * @method \{{ Query.getFullname() }} whereAdd() whereAdd($column, $value, $comparison = null, $mutatorColumn = null, $mutatorValue = null)
 * @method \{{ Query.getFullname() }} bind() bind($parameters)
 * @method \{{ Query.getFullname() }} setQuoteStrategy() setQuoteStrategy(QuoteStrategy $quoteStrategy)
 * @method \{{ Query.getFullname() }} page() page($page, $itemsPerPage)
 * @method \{{ Query.getFullname() }} setLimit() setLimit($limit)
 * @method \{{ Query.getFullname() }} setOffset() setOffset($offset)
 * @method \{{ Query.getFullname() }} removeColumn() removeColumn($column = null)
 * @method \{{ Query.getFullname() }} distinct()
 * @method \{{ Query.getFullname() }} select()
 * @method \{{ Query.getFullname() }} pk() pk($id)
 * @method \{{ Query.getFullname() }} filter() filter($fields, $prefix = null)
 * @method \{{ Query.getFullname() }} addColumns() addColumns($columns)
 * @method \{{ Query.getFullname() }} addColumn() addColumn($column, $alias = null, $mutator = null)
 * @method \{{ Query.getFullname() }} addGroupBy() addGroupBy($groupBy)
 * @method \{{ Query.getFullname() }} orderBy() orderBy($name, $type = null)
 * @method \{{ Query.getFullname() }} intoOutfile() intoOutfile($filename, $terminated = ',', $enclosed = '"', $escaped = '\\\\', $linesTerminated ='\r\n')
 * @method \{{ Query.getFullname() }} addAscendingOrderBy() addAscendingOrderBy($name)
 * @method \{{ Query.getFullname() }} addDescendingOrderBy() addDescendingOrderBy($name)
 * @method \{{ Query.getFullname() }} setDefaultColumn() setDefaultColumn($defaultColumn)
 */
class {{ Query }} extends{% if parentQuery %} {{ parentQuery}}{% else %} {{ BaseQuery }}{% endif %}
{

    /**
     * @return \{{ Metadata.getFullname() }}
     */
    protected static function getMetadata(){
        return {{ Metadata }}::getInstance();
    }

{% if table.isInheritance %}
    /**
     * initialization
     */
    protected function init()
    {
{% if table.getOptions().has('isCatalog') %}
        $this->useMemoryCache();
{% endif %}
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
{% endif %}

{% if table.isInheritance %}
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

        foreach(self::getMetadata()->getFields() as $field){
            if( isset($fields[$field]) && !empty($fields[$field]) ){
                $criteria->add($field, $fields[$field]);
            }
        }

        $criteria->endPrefix();
    }
{% endif %}
{% if table.getOptions.has('crud') and fields.hasColumnName('/status/i') %}
{% set statusField = fields.getByColumnName('/status/i') %}

    /**
     * @return \{{ Query.getFullname() }}
     */
    public function actives(){
        return $this->filter(array(
            {{ Bean }}::{{ statusField.getName().toUpperCase() }} => {{ Bean }}::$Status['Active'],
        ));
    }
    
    /**
     * @return \{{ Query.getFullname() }}
     */
    public function inactives(){
        return $this->filter(array(
            {{ Bean }}::{{ statusField.getName().toUpperCase() }} => {{ Bean }}::$Status['Inactive'],
        ));
    }
{% endif %}

{% for foreignKey in foreignKeys %}
{% set classForeign = classes.get(foreignKey.getForeignTable().getObject().toUpperCamelCase()) %}
    /**
     * @param string $alias
     * @param string aliasForeignTable
     * @return {{ Query.getFullname() }}
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
     * @return {{ Query.getFullname() }}
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