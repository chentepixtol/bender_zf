{% include 'header.tpl' %}
{{ Collection.printNamespace() }}

{% if Collection.getNamespace != classes.get('Collection').getNamespace() %}{{ classes.get('Collection').printUse() }}{% endif %}
{{ Bean.printUse() }}

/**
 *
 * {{ Collection }}
 *
 * @author {{ meta.get('author') }}
 * @method \{{ Bean.getFullName() }} current()
 * @method \{{ Bean.getFullName() }} read()
 * @method \{{ Bean.getFullName() }} getOne()
 * @method \{{ Bean.getFullName() }} getByPK() getByPK($primaryKey)
 * @method \{{ Collection.getFullName() }} intersect() intersect(\{{ Collection.getFullName() }} $collection)
 * @method \{{ Collection.getFullName() }} filter() filter(callable $function)
 * @method \{{ Collection.getFullName() }} merge() merge(\{{ Collection.getFullName() }} $collection)
 * @method \{{ Collection.getFullName() }} diff() diff(\{{ Collection.getFullName() }} $collection)
 * @method \{{ Collection.getFullName() }} copy()
 */
class {{ Collection }} extends {% if parent %}{{ classes.get(parent.getObject()~'Collection') }}{% else %}{{ classes.get('Collection') }}{% endif %}
{

    /**
     *
     * @param {{ Bean }} $collectable
     */
    protected function validate($collectable)
    {
        if( !($collectable instanceof {{ Bean }}) ){
            throw new \InvalidArgumentException("Debe de ser un objecto {{ Bean }}");
        }
    }

{% if fields.hasColumnName('/name/i') %}
    /**
     * @return array
     */
{% set fieldName = fields.getByColumnName('/name/i') %}
    public function toCombo(){
        return $this->map(function({{ Bean }} ${{ bean }}){
            return array( ${{ bean }}->{{ primaryKey.getter }}() => ${{ bean }}->{{ fieldName.getter }}() );
        });
    }
{% endif %}

}