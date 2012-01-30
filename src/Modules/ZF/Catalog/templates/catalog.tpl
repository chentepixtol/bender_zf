{% include 'header.tpl' %}
{% set AbstractCatalog = classes.get('AbstractCatalog') %}
{% set primaryKey = table.getPrimaryKey().getName().toCamelCase() %}
{% set BaseBean = classes.get('Bean') %}
{{ Catalog.printNamespace() }}

{{ AbstractCatalog.printUse() }}
{{ Bean.printUse() }}
{{ Factory.printUse() }}
{{ Collection.printUse() }}
{{ Exception.printUse() }}
{{ BaseBean.printUse() }}
{{ Query.printUse() }}
use Query\Query;

/**
 *
 * {{ Catalog }}
 *
 * @package {{ Catalog.getNamespace() }}
 * @author {{ meta.get('author') }}
 * @method PersonCatalog getInstance
 * @method {{ Bean }} getOneByQuery
 * @method {{ Collection }} getByQuery
 */
class {{ Catalog }} extends {% if parent %}{{ classes.get(parent.getObject() ~ 'Catalog') }}{% else %}{{ AbstractCatalog }} {% endif %} 
{

    /**
     * Metodo para agregar un {{ Bean }} a la base de datos
     * @param {{ Bean }} ${{ bean }} Objeto {{ Bean }}
     */
    public function create(${{ bean }})
    {
        $this->validateBean(${{ bean }});
        try
        {
{% if parent %}
            if( !${{ bean }}->{{ parent.getPrimaryKey().getter() }}() ){
              parent::create(${{ bean }});
            }

{% endif %}
            $data = ${{ bean}}->toArrayFor(
                array({% for field in fields.nonPrimaryKeys %}'{{ field.getName() }}', {% endfor %})
            );
            $data = array_filter($data, array($this, 'isNotNull'));
            $this->getDb()->insert({{ Bean }}::TABLENAME, $data);
{% if table.hasPrimaryKey() %}
            ${{ bean }}->{{ table.getPrimaryKey().setter() }}($this->getDb()->lastInsertId());
{% endif %}
        }
        catch(\Exception $e)
        {
            $this->throwException("The {{ Bean }} can't be saved \n", $e);
        }
    }

    /**
     * Metodo para actualizar un {{ Bean }} en la base de datos
     * @param {{ Bean }} ${{ bean }} Objeto {{ Bean }}
     */
    public function update(${{ bean }})
    {
        $this->validateBean(${{ bean }});
        try
        {
            $data = ${{ bean}}->toArrayFor(
                array({% for field in fields.nonPrimaryKeys %}'{{ field.getName() }}',{% endfor %})
            );
            $data = array_filter($data, array($this, 'isNotNull'));
            $this->getDb()->update({{ Bean }}::TABLENAME, $data, "{{ table.getPrimaryKey() }} = '{${{ bean }}->{{ table.getPrimaryKey().getter() }}()}'");
{% if parent %}
            parent::update(${{ bean }});
{% endif %}
        }
        catch(\Exception $e)
        {
            $this->throwException("The {{ Bean }} can't be saved \n", $e);
        }
    }

    /**
     * Metodo para eliminar un {{ Bean }} a partir de su Id
     * @param int ${{ primaryKey }}
     */
    public function deleteById(${{ primaryKey }})
    {
        try
        {
            $where = array($this->getDb()->quoteInto('{{ table.getPrimaryKey() }} = ?', ${{ primaryKey }}));
            $this->getDb()->delete({{ Bean }}::TABLENAME, $where);
        }
        catch(\Exception $e)
        {
            $this->throwException("The {{ Bean }} can't be deleted\n", $e);
        }
    }
    
{% for manyToMany in table.getManyToManyCollection %}
{% set relationColumn = manyToMany.getRelationColumn() %}
{% set foreignObject = classes.get(manyToMany.getForeignTable().getObject().toString()) %}
{% set relationForeignColumn = manyToMany.getRelationForeignColumn() %}
{% set pk1 = relationColumn.getName() %}
{% set pk2 = relationForeignColumn.getName() %}

    /**
     * Link a {{ Bean }} to {{ foreignObject }}
     * @param int ${{ pk1.toCamelCase }}
     * @param int ${{ pk2.toCamelCase() }}
{% for field in relationTable.getColumns().nonForeignKeys() %}
     * @param {{ field.cast('php') }} ${{ field.getName().toCamelCase() }}
{% endfor %}
     */ 
    public function linkTo{{ foreignObject }}(${{ pk1.toCamelCase }}, ${{ pk2.toCamelCase() }}{% for field in relationTable.getColumns().nonForeignKeys() %}, ${{ field.getName().toCamelCase() }}{% endfor%})
    {
        try
        {
            $this->unlinkFrom{{ foreignObject }}(${{ pk1.toCamelCase() }}, ${{ pk2.toCamelCase() }});
            $data = array(
                '{{ pk1 }}' => ${{ pk1.toCamelCase() }},
                '{{ pk2 }}' => ${{ pk2.toCamelCase() }},
{% for field in relationTable.getColumns().nonForeignKeys() %}
                '{{ field }}' => ${{ field.getName().toCamelCase() }},
{% endfor%}
            );
            $this->getDb()->insert('{{ relationTable.getName().toString() }}', $data);
        }
        catch(\Exception $e)
        {
            $this->throwException("Can't link {{ Bean }} to {{ foreignObject }}", $e);
        }
    }

    /**
     * Unlink a {{ Bean }} from {{ foreignObject }}
     * @param int ${{ pk1.toCamelCase() }}
     * @param int ${{ pk2.toCamelCase() }}
     */
    public function unlinkFrom{{ foreignObject }}(${{ pk1.toCamelCase() }}, ${{ pk2.toCamelCase() }})
    {
        try
        {
            $where = array(
                $this->getDb()->quoteInto('{{ pk1 }} = ?', ${{ pk1.toCamelCase() }}),
                $this->getDb()->quoteInto('{{ pk2 }} = ?', ${{ pk2.toCamelCase() }}),
            );
            $this->getDb()->delete('{{ relationTable.getName().toString() }}', $where);
        }
        catch(\Exception $e)
        {
            $this->throwException("Can't unlink {{ Bean }} to {{ foreignObject }}", $e);
        }
    }

    /**
     * Unlink all {{ foreignObject }} relations
     * @param int ${{ pk1.toCamelCase() }}
{% for field in source.getNonForeignKeys() %}
     * @param {{ field.cast('php') }} ${{ field.getName().toCamelCase() }}
{% endfor %}
     */
    public function unlinkAll{{ foreignObject }}(${{ pk1.toCamelCase() }}{% for field in relationTable.getColumns().nonForeignKeys() %}, ${{ field.getName().toCamelCase() }} = null{% endfor%})
    {
        try
        {
            $where = array(
                $this->getDb()->quoteInto('{{ pk1 }} = ?', ${{ pk1.toCamelCase() }}),
            );
{% for field in relationTable.getColumns().nonForeignKeys() %}
            if( null != ${{ field.getName().toCamelCase() }} ) $where[] = $this->getDb()->quoteInto('{{ field }} = ?', ${{ field.getName().toCamelCase }});
{% endfor %}
            $this->getDb()->delete('{{ relationTable.getName().toString() }}', $where);
        }
        catch(\Exception $e)
        {
            $this->throwException("Can't unlink {{ Bean }} to {{ foreignObject }}", $e);
        }
    }
{% endfor %}
    
    /**
     *
     * makeCollection
     * @return {{ Collection }}
     */
    protected function makeCollection(){
        return new {{ Collection }}();
    }

    /**
     *
     * makeBean
     * @param array $resultset
     * @return {{ Bean }}
     */
    protected function makeBean($resultset){
        return {{ Factory }}::createFromArray($resultset);
    }

    /**
     *
     * Validate Query
     * @param {{ Query }} $query
     * @throws RoundException
     */
    protected function validateQuery(Query $query)
    {
        if( !($query instanceof {{ Query }}) ){
            $this->throwException("No es un Query valido");
        }
    }
    
    /**
     *
     * Validate {{ Bean }}
     * @param {{ Bean }} ${{ bean }}
     * @throws Exception
     */
    protected function validateBean({{ BaseBean }} ${{ bean }} = null){
        if( !(${{ bean }} instanceof {{ Bean }}) ){
            $this->throwException("passed parameter isn't a {{ Bean }} instance");
        }
    }

    /**
     *
     * throwException
     * @throws Exception
     */
    protected function throwException($message, \Exception $exception = null){
        if( null != $exception){
            throw new {{ Exception }}("$message ". $exception->getMessage(), 500, $exception);
        }else{
            throw new {{ Exception }}($message);
        }
    }

 }