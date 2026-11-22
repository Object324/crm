<?php
/* createdby:can editor:gyq_12 reason:查重显示列序时簿 date:20160601 */
crm_load_class_file('AccountsQueryGenerator','include/QueryGenerator');
class DupSearch_queryGenerator_account extends AccountsQueryGenerator
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

    public function getWhereClause()
    {
        $versioninfo = getVersionInfo();
        if($versioninfo['account']=='shenglawei'){
            $sql=' WHERE 
			(LEFT(ld_accountscf.cf_7533, 3) = LEFT ("'.$_REQUEST['search_content'].'", 3) and RIGHT (ld_accountscf.cf_7533, 4) = RIGHT ("'.$_REQUEST['search_content'].'", 4)) OR
            (LEFT(ld_accountscf.cf_7537, 3) = LEFT ("'.$_REQUEST['search_content'].'", 3) and RIGHT (ld_accountscf.cf_7537, 4) = RIGHT ("'.$_REQUEST['search_content'].'", 4)) OR
            (LEFT(ld_accountscf.cf_7541, 3) = LEFT ("'.$_REQUEST['search_content'].'", 3) and RIGHT (ld_accountscf.cf_7541, 4) = RIGHT ("'.$_REQUEST['search_content'].'", 4)) OR
            (LEFT(ld_accountscf.cf_7545, 3) = LEFT ("'.$_REQUEST['search_content'].'", 3) and RIGHT (ld_accountscf.cf_7545, 4) = RIGHT ("'.$_REQUEST['search_content'].'", 4)) OR
            (LEFT(ld_accountscf.cf_7554, 3) = LEFT ("'.$_REQUEST['search_content'].'", 3) and RIGHT (ld_accountscf.cf_7554, 4) = RIGHT ("'.$_REQUEST['search_content'].'", 4)) ';

        }
        else{
            $sql = parent::getWhereClause();
        }
        return $sql;
    }
   
}


?>