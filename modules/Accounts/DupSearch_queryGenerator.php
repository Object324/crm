<?php
/* createdby:can editor:gyq_12 reason:查重显示列序时簿 date:20160601 */
crm_load_class_file('AccountsQueryGenerator','include/QueryGenerator');
class DupSearch_queryGenerator extends AccountsQueryGenerator
{
    public function __construct($module, $user,$customerview='',$productDetails='') {
        parent::__construct($module, $user,$customerview,$productDetails);

            $this->productDetails=$productDetails;
           $this->productDetails->querygenerator=$this;

    }
    public function getScopeOfAuthority_obj($db,$module)
    {
        //$this->scopeobj = new ScopOfAuthority($db,$module);
		$this->scopeobj = '';
    }
   
}


?>