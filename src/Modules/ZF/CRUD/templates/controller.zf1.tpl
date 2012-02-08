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
        ${{ collection }} = {{ Query }}::create()
            ->filter($form->getValues())
            ->page($page, $this->getMaxPerPage())->find();
            
        $this->view->{{ collection }} = ${{ collection }};
        $this->view->paginator = $this->createPaginator($total, $page);
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
        ${{ bean }} = {{ Query }}::create()->findByPKOrThrow($id, "No existe el {{ Bean }} con Id {$id}");

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
                return;
            }

            $id = $this->getRequest()->getParam('id');
            ${{ bean }} = {{ Query }}::create()->findByPKOrThrow($id, "No existe el {{ Bean }} con Id {$id}");

            {{ Factory }}::populate(${{ bean }}, $form->getValues());
            {{ Catalog }}::getInstance()->update(${{ bean }});

            $this->setFlash('ok', "Se actualizo correctamente el {{ Bean}}");
        }
        $this->_redirect('{{ slug }}/list');
    }
    
    /**
     *
     */
    public function deleteAction(){
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
