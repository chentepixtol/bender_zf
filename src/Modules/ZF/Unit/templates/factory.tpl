{% include 'header.tpl' %}
{% set BaseTest = classes.get('BaseTest') %}

namespace Test\Unit;
{{ BaseTest.printRequire(true) }}

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
