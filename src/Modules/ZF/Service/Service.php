<?php
namespace Modules\ZF\Service;


use Modules\ZF\PhpClass;
use Application\Generator\BaseClass;
use Application\Generator\Classes;
use Application\Generator\File\FileCollection;
use Application\Generator\File\File;
use Application\Database\Table;
use Modules\ZF\BaseModule;

/**
 *
 * @author chente
 *
 */
class Service extends BaseModule
{

    /**
     * (non-PHPdoc)
     * @see Application\Generator\Module.Module::getName()
     */
    public function getName(){
        return 'Service';
    }

    /**
     * (non-PHPdoc)
     * @see Application\Generator\Module.AbstractModule::init()
     */
    public function init()
    {
        $classes = $this->getBender()->getClasses();
        $classes->add('AbstractService', new PhpClass($this->getApplicationNamespace()."Service/AbstractService.php"));

        $self = $this;
        $this->getBender()->getDatabase()->getTables()->filterUseService()
        ->each(function (Table $table) use($classes, $self){
            $object = $table->getObject().'Service';
            $classes->add($object, new PhpClass($self->getApplicationNamespace()."Service/{$object}.php"));
        });
    }

    /**
     * (non-PHPdoc)
     * @see Application\Generator\Module.Module::getFiles()
     */
    public function getFiles()
    {
        $classes = $this->getBender()->getClasses();
        $tables = $this->getBender()->getDatabase()->getTables()->filterUseService();

        $files = new FileCollection();
        if( !$tables->isEmpty() ){

            $files->append(new File($classes->get('AbstractService')->getRoute(), $this->getView()->fetch('abstract-service.tpl')));

            while ( $tables->valid() )
            {
                $table = $tables->read();
                $this->shortcuts($table);
                $content = $this->getView()->fetch('service.tpl');
                $files->append(
                    new File($classes->get($table->getObject().'Service')->getRoute(), $content)
                );
            }
        }

        return $files;
    }

}
