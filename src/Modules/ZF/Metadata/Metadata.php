<?php
namespace Modules\ZF\Metadata;

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
class Metadata extends BaseModule
{

    /**
     * (non-PHPdoc)
     * @see Application\Generator\Module.Module::getName()
     */
    public function getName(){
        return 'Metadata';
    }

    /**
     * (non-PHPdoc)
     * @see Application\Generator\Module.AbstractModule::init()
     */
    public function init()
    {
        $classes = $this->getBender()->getClasses();
        $classes->add('Metadata', new PhpClass($this->getApplicationNamespace()."Model/Metadata/Metadata.php"))
                ->add('AbstractMetadata', new PhpClass($this->getApplicationNamespace()."Model/Metadata/AbstractMetadata.php"))
                ->add('CrudMetadata', new PhpClass($this->getApplicationNamespace()."Model/Metadata/CrudMetadata.php"))
                ->add('AbstractCrudMetadata', new PhpClass($this->getApplicationNamespace()."Model/Metadata/AbstractCrudMetadata.php"));


        $self = $this;
        $this->getBender()->getDatabase()->getTables()->inSchema()->each(function (Table $table) use($classes, $self){
            $object = $table->getObject().'Metadata';
            $classes->add($object, new PhpClass($self->getApplicationNamespace()."Model/Metadata/{$object}.php"));
        });
    }

    /**
     * (non-PHPdoc)
     * @see Application\Generator\Module.Module::getFiles()
     */
    public function getFiles()
    {
        $classes = $this->getBender()->getClasses();
        $tables = $this->getBender()->getDatabase()->getTables()->inSchema();

        $files = new FileCollection();
        $files->append(new File($classes->get('Metadata')->getRoute(), $this->getView()->fetch('metadata-interface.tpl')));
        $files->append(new File($classes->get('AbstractMetadata')->getRoute(), $this->getView()->fetch('abstract-metadata.tpl')));
        $files->append(new File($classes->get('CrudMetadata')->getRoute(), $this->getView()->fetch('metadata-crud-interface.tpl')));
        $files->append(new File($classes->get('AbstractCrudMetadata')->getRoute(), $this->getView()->fetch('abstract-crud-metadata.tpl')));

        while ( $tables->valid() )
        {
            $table = $tables->read();
            $this->shortcuts($table);
            $content = $this->getView()->fetch('metadata.tpl');
            $files->append(
                new File($classes->get($table->getObject().'Metadata')->getRoute(), $content)
            );
        }

        return $files;
    }

}
