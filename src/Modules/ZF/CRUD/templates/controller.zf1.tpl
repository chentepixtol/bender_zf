{% include 'header.tpl' %}
{% set slug = Controller.getName().toSlug('newString').replace('-controller','') %}
{{ Catalog.printUse() }}
{{ Factory.printUse() }}
{{ Bean.printUse() }}
{{ Query.printUse() }}
{{ Form.printUse() }}
use Application\Controller\CrudController;

/**
 *
 * @author chente
 */
class {{ Controller }} extends CrudController
{

    /**
     *
     * @return array
     */
    public function indexAction(){
        return $this->_forward('list');
    }

    /**
     *
     * @return array
     */
    public function listAction()
    {
        $page = $this->getRequest()->getParam('page', 1);

        $this->view->form = $form = $this->getFilterForm();
        if( $this->getRequest()->isPost() ){
            $form->populate($this->getRequest()->getParams());
        }

        $total = {{ Query }}::create()->filter($form->getValues())->count();
        $this->view->{{ Bean.getName().pluralize() }} = ${{ Bean.getName().pluralize() }} = {{ Query }}::create()
            ->filter($form->getValues())
            ->page($page, $this->getMaxPerPage())
            ->find();

        $this->view->paginator = $this->createPaginator($total, $page);
{% for foreignKey in fullForeignKeys %}
{% set classForeign = classes.get(foreignKey.getForeignTable().getObject().toUpperCamelCase()) %}
{% set queryForeign = classes.get(foreignKey.getForeignTable().getObject().toUpperCamelCase()~'Query') %}
        $this->view->{{ classForeign.getName().pluralize() }} = \{{ queryForeign.getFullName() }}::create()->find()->toCombo();
{% endfor %}
    }

    /**
     *
     * @return array
     */
    public function newAction()
    {
        $url = $this->generateUrl('{{ slug }}', 'create');
        $this->view->form = $this->getForm()->setAction($url);
    }

    /**
     *
     * @return array
     */
    public function editAction()
    {
        $id = $this->getRequest()->getParam('id');
        ${{ bean }} = {{ Query }}::create()->findByPKOrThrow($id, $this->i18n->_("Not exists the {{ Bean }} with id {$id}"));

        $url = $this->generateUrl('{{ slug }}', 'update', compact('id'));
        $form = $this->getForm()
            ->populate(${{ bean }}->toArray())
            ->setAction($url);

        $this->view->form = $form;
        $this->view->setTpl("New");
    }

    /**
     *
     * @return array
     */
    public function createAction()
    {
        $form = $this->getForm();
        if( $this->getRequest()->isPost() ){

           $params = $this->getRequest()->getParams();
           if( !$form->isValid($params) ){
               $this->view->setTpl("New");
               $this->view->form = $form;
               return;
           }

           try
           {
               $this->get{{ Catalog }}()->beginTransaction();

               ${{ bean }} = {{ Factory }}::createFromArray($form->getValues());
               $this->get{{ Catalog }}()->create(${{ bean }});
{% if table.getOptions().has('crud_logger') %}
               $this->newLogForCreate(${{ bean }});
{% endif %}

               $this->get{{ Catalog }}()->commit();
               $this->setFlash('ok', $this->i18n->_("Se ha guardado correctamente el {{ User }}"));
           }
           catch(Exception $e)
           {
               $this->get{{ Catalog }}()->rollBack();
               $this->setFlash('error', $this->i18n->_($e->getMessage()));
           }
        }
        $this->_redirect('{{ slug }}/list');
    }

    /**
     *
     * @return array
     */
    public function updateAction()
    {
        $form = $this->getForm();
        if( $this->getRequest()->isPost() ){

            $params = $this->getRequest()->getParams();
            if( !$form->isValid($params) ){
                $this->view->setTpl("New");
                $this->view->form = $form;
                return;
            }

            $id = $this->getRequest()->getParam('id');
            ${{ bean }} = {{ Query }}::create()->findByPKOrThrow($id, $this->i18n->_("Not exists the {{ Bean }} with id {$id}"));

            try
            {
                $this->get{{ Catalog }}()->beginTransaction();

                {{ Factory }}::populate(${{ bean }}, $form->getValues());
                $this->get{{ Catalog }}()->update(${{ bean }});
{% if table.getOptions().has('crud_logger') %}
                $this->newLogForUpdate(${{ bean }});
{% endif %}

                $this->get{{ Catalog }}()->commit();
                $this->setFlash('ok', $this->i18n->_("Se actualizo correctamente el {{ Bean}}"));
            }
            catch(Exception $e)
            {
                $this->get{{ Catalog }}()->rollBack();
                $this->setFlash('error', $this->i18n->_($e->getMessage()));
            }
        }
        $this->_redirect('{{ slug }}/list');
    }

    /**
     *
     */
    public function deleteAction(){
        $id = $this->getRequest()->getParam('id');
        ${{ bean }} = {{ Query }}::create()->findByPKOrThrow($id, $this->i18n->_("Not exists the {{ Bean }} with id {$id}"));

        try
        {
            $this->get{{ Catalog }}()->beginTransaction();

{% if fields.hasColumnName('/status/i') %}
{% set statusField = fields.getByColumnName('/status/i') %}
            ${{ bean }}->{{ statusField.setter }}({{ Bean }}::${{ statusField.getName().toUpperCamelCase }}['Inactive']);
{% endif %}
            $this->get{{ Catalog }}()->update(${{ bean }});
{% if table.getOptions().has('crud_logger') %}
            $this->newLogForDelete(${{ bean }});
{% endif %}

            $this->get{{ Catalog }}()->commit();
            $this->setFlash('ok', $this->i18n->_("Se desactivo correctamente el {{ Bean}}"));
        }
        catch(Exception $e)
        {
            $this->get{{ Catalog }}()->rollBack();
            $this->setFlash('error', $this->i18n->_($e->getMessage()));
        }
        $this->_redirect('{{ slug }}/list');
    }
{% if table.getOptions().has('crud_logger') %}
{% set logger = classes.get(table.getOptions().get('crud_logger')) %}
{% set loggerFactory = classes.get(table.getOptions().get('crud_logger')~'Factory') %}
{% set loggerCatalog = classes.get(table.getOptions().get('crud_logger')~'Catalog') %}

    /**
     * @param {{ Bean }} ${{ bean }}
     * @return \{{ logger.getFullname() }}
     */
    protected function newLogForCreate({{ Bean }} ${{ bean }}){
        throw new Exception("No implementado aun");
    }

    /**
     * @param {{ Bean }} ${{ bean }}
     * @return \{{ logger.getFullname() }}
     */
    protected function newLogForUpdate({{ Bean }} ${{ bean }}){
        throw new Exception("No implementado aun");
    }

    /**
     * @param {{ Bean }} ${{ bean }}
     * @return \{{ logger.getFullname() }}
     */
    protected function newLogForDelete({{ Bean }} ${{ bean }}){
        throw new Exception("No implementado aun");
    }
{% endif %}
    /**
     * @return \{{ Catalog.getFullname() }}
     */
    protected function get{{ Catalog }}(){
        return $this->getContainer()->get('{{ Catalog }}');
    }

    /**
     *
     * @return {{ Form.getFullName() }}
     */
    protected function getForm()
    {
        $form = new {{ Form }}();
        $submit = new Zend_Form_Element_Submit("send");
        $submit->setLabel($this->i18n->_("Guardar"));
        $form->addElement($submit)->setMethod('post');
        $form->twitterDecorators();
        return $form;
    }

    /**
     *
     * @return {{ Form.getFullName() }}
     */
    protected function getFilterForm()
    {
        $form = new {{ Form }}();
        $submit = new Zend_Form_Element_Submit("send");
        $submit->setLabel("Buscar");
        $form->addElement($submit)->setMethod('post');
        $form->twitterDecorators();
        return $form;
    }

}
