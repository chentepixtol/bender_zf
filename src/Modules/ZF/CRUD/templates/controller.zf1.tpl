{% include 'header.tpl' %}
{% set slug = Controller.getName().toSlug('newString').replace('-controller','') %}
{% set logger = classes.get(table.getOptions().get('crud_logger')) %}
{% set loggerFactory = classes.get(table.getOptions().get('crud_logger')~'Factory') %}
{% set loggerCatalog = classes.get(table.getOptions().get('crud_logger')~'Catalog') %}
{% set loggerQuery = classes.get(table.getOptions().get('crud_logger')~'Query') %}
{% set UserQuery = classes.get('UserQuery') %}
{{ Catalog.printUse() }}
{{ Factory.printUse() }}
{{ Bean.printUse() }}
{{ Query.printUse() }}
{{ Form.printUse() }}
{% if table.getOptions().has('crud_logger') %}
{{ logger.printUse }}
{{ loggerFactory.printUse }}
{{ loggerCatalog.printUse }}
{{ loggerQuery.printUse }}
{% if UserQuery != Query %}
{{ UserQuery.printUse }}
{% endif %}
{% endif %}
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

        if( $this->getRequest()->isPost() ){
            $this->view->post = $post = $this->getRequest()->getParams();
        }

        $total = {{ Query }}::create()->filter($post)->count();
        $this->view->{{ Bean.getName().pluralize() }} = ${{ Bean.getName().pluralize() }} = {{ Query }}::create()
            ->filter($post)
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

    /** 
     *
     */
    protected function trackingAction(){
        $id = $this->getRequest()->getParam('id');
        ${{ bean }} = {{ Query }}::create()->findByPKOrThrow($id, $this->i18n->_("Not exists the {{ Bean }} with id {$id}"));
        $this->view->{{ logger.getName().pluralize() }} = {{ loggerQuery }}::create()->whereAdd('{{ primaryKey }}', $id)->find();
        $this->view->users = UserQuery::create()->find()->toCombo();
    }

    /**
     * @param {{ Bean }} ${{ bean }}
     * @return \{{ logger.getFullname() }}
     */
    protected function newLogForCreate({{ Bean }} ${{ bean }}){
        return $this->newLog(${{ bean }}, \{{ logger.getFullname() }}::$EventTypes['Create'] );
    }

    /**
     * @param {{ Bean }} ${{ bean }}
     * @return \{{ logger.getFullname() }}
     */
    protected function newLogForUpdate({{ Bean }} ${{ bean }}){
        return $this->newLog(${{ bean }}, \{{ logger.getFullname() }}::$EventTypes['Update'] );
    }

    /**
     * @param {{ Bean }} ${{ bean }}
     * @return \{{ logger.getFullname() }}
     */
    protected function newLogForDelete({{ Bean }} ${{ bean }}){
        return $this->newLog(${{ bean }}, {{ logger }}::$EventTypes['Delete'] );
    }
    
    /**
     * @return \{{ logger.getFullname() }}
     */
    private function newLog({{ Bean }} ${{ bean }}, $eventType){
        $now = \Zend_Date::now();
        $log = {{ loggerFactory }}::createFromArray(array(
            '{{ primaryKey }}' => ${{ bean }}->{{ primaryKey.getter }}(),
            'id_user' => $this->getUser()->getBean()->getIdUser(),
            'date_log' => $now->get('yyyy-MM-dd HH:mm:ss'),
            'event_type' => $eventType,
            'note' => '',
        ));
        $this->getCatalog('{{ loggerCatalog }}')->create($log);
        return $log;
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

}
