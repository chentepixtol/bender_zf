{% include 'header.tpl' %}
{% set slug = Controller.getName().toSlug('newString').replace('-controller','') %}
{{ Catalog.printUse() }}
{{ Factory.printUse() }}
{{ Bean.printUse() }}
{{ Query.printUse() }}
{{ Form.printUse() }}

require_once 'lib/controller/BaseController.php';

/**
 *
 * @author chente
 */
class {{ Controller }} extends BaseController
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
        ${{ collection }} = {{ Query }}::create()->find();
        $this->view->{{ collection }} = ${{ collection }};
    }

    /**
     *
     * @return array
     */
    public function newAction()
    {
        $url = $this->getRequest()->getBaseUrl() . '/{{ slug }}/create'; 
        $this->view->form = $this->getForm()->setAction($url);
    }

    /**
     *
     * @return array
     */
    public function editAction()
    {
        $id = $this->getRequest()->getParam('id');
        ${{ bean }} = {{ Query }}::create()->primaryKey($id)
            ->findOneOrThrow("No existe el {{ Bean }} con Id {$id}");

        $url = $this->getRequest()->getBaseUrl() . '/{{ slug }}/update/id/' . $id;
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
           }

           ${{ bean }} = {{ Factory }}::createFromArray($form->getValues());
           {{ Catalog }}::getInstance()->create(${{ bean }});

           $this->setFlash('ok', "Se ha guardado correctamente el {{ User }}");
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
            }

            $id = $this->getRequest()->getParam('id');
            ${{ bean }} = {{ Query }}::create()->primaryKey($id)
                ->findOneOrThrow("No existe el {{ Bean }} con id {$id}");

            {{ Factory }}::populate(${{ bean }}, $form->getValues());
            {{ Catalog }}::getInstance()->update(${{ bean }});

            $this->setFlash('ok', "Se actualizo correctamente el {{ Bean}}");
        }
        $this->_redirect('{{ slug }}/list');
    }

    /**
     *
     * @return {{ Form.getFullName() }}
     */
    protected function getForm()
    {
        $form = new {{ Form }}();
        $submit = new Zend_Form_Element_Submit("send");
        $submit->setLabel("Guardar");
        $form->addElement($submit)->setMethod('post');
        //$form->twitterDecorators();
        return $form;
    }

}
