{% include 'header.tpl' %}
{% set BaseTest = classes.get('BaseTest') %}

namespace Test\Unit;

{{ Factory.printUse() }}

class {{ Factory }}Test extends {{ BaseTest }}
{

    /**
     * @test
     */
    public function populate(){
        try {
            {{ Factory }}::populate(new \stdClass(), array());
            $this->fail("Debio de mandar una exception");
        } catch ( \{{ Exception.getFullName() }} $e) {
            $this->assertTrue(true);
        }
    }
{% if parent %}
{% set parentClass = classes.get(parent.getObject().toString()) %}
	/**
     * @test
     */
    public function populate{{ parentClass }}(){
        try {
            {{ Factory }}::populate(new \{{ parentClass.getFullname() }}(), array());
            $this->fail("Debio de mandar una exception");
        } catch ( \{{ Exception.getFullName() }} $e) {
            $this->assertTrue(true);
        }
    }
{% endif %}

    /**
     * @test
     */
    public function createFromArray()
    {
        $anValue = 'An value to the Factory';
        $array = array(
{%for field in fields %}
            '{{ field }}' => $anValue,
{% endfor %}
        );

        ${{ bean }} = {{ Factory }}::createFromArray($array);
        $this->assertTrue(${{ bean }} instanceof \{{ Bean.getFullname() }});

        ${{ bean }}Copy = {{ Factory }}::createFromArray(${{ bean }}->toArray());
        $this->assertTrue( ${{ bean }} == ${{ bean }}Copy );

{%for field in fields %}
        $this->assertEquals($array['{{ field }}'], ${{ bean }}->{{ field.getter }}());
{% endfor %}
    }

}
