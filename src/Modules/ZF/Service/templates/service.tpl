{% include 'header.tpl' %}
{% set AbstractService = classes.get('AbstractService') %}
namespace {{ Service.getNamespace() }};

{{ Catalog.printUse() }}

{% include "header_class.tpl" with {'infoClass': Service} %}
class {{ Service }} extends {{ AbstractService }} 
{

    /**
     * @var \{{ Catalog.getFullname() }}
     */
    protected ${{ catalog }};
    
    /**
     * @param {{ Catalog }} ${{ catalog }}
     */
    public function set{{ Catalog }}({{ Catalog }} ${{ catalog }}){
        $this->{{ catalog }} = ${{ catalog }};
    }
    
    /**
     * @return \{{ Catalog.getFullname() }}
     */
    public function get{{ Catalog }}(){
        return $this->{{ catalog }};
    }
    
}