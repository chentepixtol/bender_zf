{% include 'header.tpl' %}
{{ Collection.printNamespace() }}

{% if Collection.getNamespace != classes.get('Collection').getNamespace() %}{{ classes.get('Collection').printUse() }}{% endif %}

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
class {{ Collection }} extends {{ classes.get('Collection') }}
{

}