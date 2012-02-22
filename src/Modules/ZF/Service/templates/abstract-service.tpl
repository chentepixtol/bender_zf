{% include 'header.tpl' %}

{% set AbstractService = classes.get('AbstractService') %}
{{ AbstractService.printNamespace() }}

use Symfony\Component\EventDispatcher\EventDispatcherInterface;

{% include "header_class.tpl" with {'infoClass': AbstractService} %}
abstract class {{ AbstractService }} 
{
 
    /**
     * @var \Symfony\Component\EventDispatcher\EventDispatcherInterface
     */
    protected $eventDispatcher;
    
    /**
     * @param EventDispatcherInterface $eventDispatcher
     */
    public function setEventDispatcher(EventDispatcherInterface $eventDispatcher){
        $this->eventDispatcher = $eventDispatcher;
    }
    
    /**
     * @return \Symfony\Component\EventDispatcher\EventDispatcherInterface
     */
    public function getEventDispatcher(){
        return $this->eventDispatcher;
    }
    
}
