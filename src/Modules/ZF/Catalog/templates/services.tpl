{% for table in tables %}
{% set Catalog = classes.get(table.getObject().toString() ~ "Catalog") %}
    <service id="{{ Catalog.getName().toString() }}" class="{{ Catalog.getFullName() }}">
        <call method="setDBAO"><argument type="service" id="dbao" /></call>
    </service>
{% endfor %}