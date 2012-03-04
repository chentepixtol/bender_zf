{% set slug = Controller.getName().toSlug('newString').replace('-controller','') %}

    {$form->render()}
    
    <table class="zebra-striped bordered-table">
        <caption><h3>{$i18n->_('{{ Bean }}')}</h3></caption>
        <thead>
            <tr>
{% for field in fullFields %}
                <th>{$i18n->_('{{ field.getName().toUpperCamelCase() }}')}</th>
{% endfor %}
                <th>{$i18n->_('Actions')}</th>
            </tr>
        </thead>
        <tbody>
            {foreach ${{ collection }} as ${{ bean }}}
                <tr>
{% set inForeignKeys = fullFields.inForeignKeys %}
{% for field in fullFields %}
{% if inForeignKeys.containsIndex(field.getName().toString()) %}
{% set foreignClass = classes.get(foreignKeys.getByColumnName(field.getName().toString()).getForeignTable().getObject()) %}
                    <td>{${{ foreignClass.getName().pluralize() }}[${{ bean}}->{{ field.getter() }}()]}</td>
{% else %}
                    <td>{${{ bean}}->{{ field.getter() }}()}</td>
{% endif %}
{% endfor %}
                    <td><a href="{$baseUrl}/{{slug}}/edit/id/{${{ bean }}->{{table.getPrimaryKey().getter()}}()}" class="btn">{$i18n->_('Editar')}</a></td>
                </tr>
            {/foreach}
        </tbody>
    </table>
    
    
{include file='layout/Pager.tpl' paginator=$paginator}
    