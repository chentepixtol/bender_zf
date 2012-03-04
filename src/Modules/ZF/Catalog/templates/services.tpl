<?xml version="1.0" encoding="UTF-8"?>

<container xmlns="http://symfony.com/schema/dic/services"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://symfony.com/schema/dic/services http://symfony.com/schema/dic/services/services-1.0.xsd">
    
    <services>
{% for table in tables.filterUseService() %}
{% set Service = classes.get(table.getObject().toString() ~ "Service") %}
{% set Catalog = classes.get(table.getObject().toString() ~ "Catalog") %}
        <service id="{{ Service.getName().toString() }}" class="{{ Service.getFullName() }}">
            <call method="setEventDispatcher"><argument type="service" id="event_dispatcher" /></call>
            <call method="set{{ Catalog }}"><argument type="service" id="{{ Catalog }}" /></call>
        </service>
{% endfor %}
    
{% for table in tables %}
{% set Catalog = classes.get(table.getObject().toString() ~ "Catalog") %}
        <service id="{{ Catalog.getName().toString() }}" class="{{ Catalog.getFullName() }}">
            <call method="setDBAO"><argument type="service" id="dbao" /></call>
        </service>
{% endfor %}
    </services>
    
</container>