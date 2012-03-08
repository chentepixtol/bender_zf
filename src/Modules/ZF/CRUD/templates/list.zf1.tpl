{% set slug = Controller.getName().toSlug('newString').replace('-controller','') %}
{% set statusField = fields.getByColumnName('/status/i') %}

<table>
    <tbody>
{% for foreignKey in fullForeignKeys %}
{% set classForeign = classes.get(foreignKey.getForeignTable().getObject().toUpperCamelCase()) %}
{% set field = foreignKey.getLocal %}
   <td>{$i18n->_('{{ field }}')}</td>
   <td>{html_options name={{ field }} id={{ field }} options=${{ classForeign.getName().pluralize() }} selected=$post['{{ field }}']}</td>
{% endfor %}
{% for field in fullFields.nonForeignKeys() %}
{% if field.isBigint or field.isInteger or field.isSmallint %}
   <td>{$i18n->_('{{ field }}')}</td>
   <td><input type="text" name="{{ field }}" id="{{ field }}" value="{$post['{{ field }}']}" class="number{% if field.isRequired() == true %} required{% endif %}" /></td>
{% elseif field.isText %}
    <td>{$i18n->_('{{ field }}')}</td>
    <td><textarea name="{{ field }}" id="{{ field }}" class="{% if field.isRequired() == true %} required{% endif %}">{$post['{{ field }}']}</textarea></td>
{% elseif field.isDate or field.isDatetime %}
    <td>{$i18n->_('{{ field }}')}</td>
    <td><input type="text" name="{{ field }}" id="{{ field }}" value="{$post['{{ field }}']}" class="datePicker dateISO{% if field.isRequired() == true %} required{% endif %}" /></td>
{% elseif field.isBoolean %}
    <td>{$i18n->_('{{ field }}')}</td>
    <td><input type="checkbox" name="{{ field }}" id="{{ field }}" value="1" class="{% if field.isRequired() == true %} required{% endif %}" {if $post['{{ field }}']}checked="checked"{/if} /></td>
{% elseif field.isTime %}
    <td>{$i18n->_('{{ field }}')}</td>
    <td>{html_select_time prefix={{ field }} display_seconds=false display_meridian=false time=$post['{{ field }}']}</td>
{% else %}
    <td>{$i18n->_('{{ field }}')}</td>
    <td><input type="text" name="{{ field }}" id="{{ field }}" value="{$post['{{ field }}']}" class="{% if field.isRequired() == true %} required{% endif %}" /></td>
{% endif %}
{% endfor %}    
    </tbody>
</table>

    <table class="zebra-striped bordered-table">
        <caption><h3>{$i18n->_('{{ Bean }}')}</h3></caption>
        <thead>
            <tr>
{% for field in fullFields %}
                <th>{$i18n->_('{{ field.getName().toUpperCamelCase() }}')}</th>
{% endfor %}
                <th colspan="3">{$i18n->_('Actions')}</th>
            </tr>
        </thead>
        <tbody>
            {foreach ${{ Bean.getName().pluralize() }} as ${{ bean }}}
                <tr>
{% set inForeignKeys = fullFields.inForeignKeys %}
{% for field in fullFields %}
{% if inForeignKeys.containsIndex(field.getName().toString()) %}
{% set foreignClass = classes.get(fullForeignKeys.getByColumnName(field.getName().toString()).getForeignTable().getObject()) %}
                    <td>{${{ foreignClass.getName().pluralize() }}[${{ bean}}->{{ field.getter() }}()]}</td>
{% elseif field == statusField %}
                    <td>{$i18n->_(${{ bean }}->{{ statusField.getter() }}Name())}</td>
{% else %}
                    <td>{${{ bean }}->{{ field.getter() }}()}</td>
{% endif %}
{% endfor %}
                    <td><a href="{$baseUrl}/{{slug}}/edit/id/{${{ bean }}->{{table.getPrimaryKey().getter()}}()}" class="btn">{$i18n->_('Edit')}</a></td>
                    <td><a href="{$baseUrl}/{{slug}}/delete/id/{${{ bean }}->{{table.getPrimaryKey().getter()}}()}" class="btn">{$i18n->_('Delete')}</a></td>
{% if table.getOptions().has('crud_logger') %}
                    <td><a href="{$baseUrl}/{{slug}}/tracking/id/{${{ bean }}->{{table.getPrimaryKey().getter()}}()}" class="btn">{$i18n->_('Tracking')}</a></td>
{% endif %}
                </tr>
            {/foreach}
        </tbody>
    </table>


{include file='layout/Pager.tpl' paginator=$paginator}
