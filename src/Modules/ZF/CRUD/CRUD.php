<?php
namespace Modules\ZF\CRUD;

use Application\Native\String;

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
class CRUD extends BaseModule
{

    /**
     * (non-PHPdoc)
     * @see Application\Generator\Module.Module::getName()
     */
    public function getName(){
        return 'CRUD';
    }

    /**
     * (non-PHPdoc)
     * @see Application\Generator\Module.AbstractModule::init()
     */
    public function init()
    {
        $classes = $this->getBender()->getClasses();
        $self = $this;
        $this->getBender()->getDatabase()->getTables()->filterUseCRUD()->each(function (Table $table) use($classes, $self){
            $object = $table->getObject().'Controller';
            $classes->add($object, new PhpClass($self->getApplicationNamespace()."Controller/{$object}.php"));
        });
    }

    /**
     * (non-PHPdoc)
     * @see Application\Generator\Module.Module::getFiles()
     */
    public function getFiles()
    {
        $tables = $this->getBender()->getDatabase()->getTables()->filterUseCRUD();

        $files = new FileCollection();
        while ( $tables->valid() )
        {
            $table = $tables->read();
            $this->shortcuts($table);

            $files->appendFromArray($this->isZF2() ? $this->getFilesForZF2($table) : $this->getFilesForZF1($table));
        }

        return $files;
    }

    /**
     * @param Table $table
     * @return array()
     */
    protected function getFilesForZF2(Table $table)
    {
        $classes = $this->getBender()->getClasses();
        $controllerClass = $classes->get($table->getObject().'Controller');
        $tplDirectory = 'views/'.str_replace('-controller', '', $controllerClass->getName()->toSlug());

        return array(
            new File($controllerClass->getRoute(), $this->getView()->fetch('controller.zf2.tpl')),
            new File($tplDirectory.'/list.tpl', $this->getView()->fetch('list.zf2.tpl')),
            new File($tplDirectory.'/new.tpl', $this->getView()->fetch('new.zf2.tpl')),
        );
    }

    /**
     * @param Table $table
     * @return array
     */
    protected function getFilesForZF1(Table $table)
    {
        $controllerName = new String($table->getObject().'Controller', String::UPPERCAMELCASE);
        $tplDirectory = 'application/views/'.str_replace('-controller', '', $controllerName->toSlug());
        $controllerFile = 'application/controllers/' . $controllerName->toString() .'.php';

        $files = array(
            new File($controllerFile, $this->getView()->fetch('controller.zf1.tpl')),
            new File($tplDirectory.'/List.tpl', $this->getView()->fetch('list.zf1.tpl')),
            new File($tplDirectory.'/New.tpl', $this->getView()->fetch('new.zf1.tpl')),
        );

        if( $table->getOptions()->has('crud_logger') ){
            $files[] = new File($tplDirectory.'/Tracking.tpl', $this->getView()->fetch('tracking.zf1.tpl'));
        }

        return $files;
    }

}
