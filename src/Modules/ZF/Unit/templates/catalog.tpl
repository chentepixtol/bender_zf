{% include 'header.tpl' %}
{% set BaseTest = classes.get('BaseTest') %}

namespace Test\Unit;

{{ Catalog.printUse() }}

class {{ Catalog }}Test extends {{ BaseTest }}
{

    /**
     * @test
     */
    public function main()
    {
        $this->assertTrue(true);
    }

}
