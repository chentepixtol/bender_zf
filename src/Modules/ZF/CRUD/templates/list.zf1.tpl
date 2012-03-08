{% set slug = Controller.getName().toSlug('newString').replace('-controller','') %}
{% set statusField = fields.getByColumnName('/status/i') %}
    {$form->render()}

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
