<?php

crm_load_class_file("ApproveCancelView","include/QueryGenerator/ApproveStepQuery");
crm_load_class_file("ApproveProductDetailView","include/QueryGenerator/ApproveStepQuery");
crm_load_class_file("ApproveProductDetailQuery","include/QueryGenerator/ApproveStepQuery");
crm_load_class_file("ApproveTabDetailQuery","include/QueryGenerator/ApproveStepQuery");
crm_load_class_file("ApproveQuery","include/QueryGenerator/ApproveStepQuery");
crm_load_class_file("ApproveTabView","include/QueryGenerator/ApproveStepQuery");
class cls_ApproveCancel
{
     public $approveid;
     public $approvemodule;
     public $approveQueryobjs=array();
     public function __construct($approvemodule,$approveid)
     {
        $this->approveid=$approveid;
        $this->approvemodule=$approvemodule;
     }
     
     public function getQueryobj($approveid)
     {
        global $current_user;
        static $approveQueryobjs;
         if(array_key_exists($approveid,(array)$this->stepidQueryobjs))
         {
            return $approveQueryobjs[$approveid];
         }
         
         $customviewobj=new ApproveCancelView($this->approvemodule);

        if(get_file_address($this->approvemodule,"ProductDetails"))
        {
            
            $productviewobj=new ApproveProductDetailView($this->approvemodule,"");
            
            $queryobj=new ApproveProductDetailQuery($this->approvemodule,$current_user,$customviewobj,$productviewobj);
            
        }
        else if(get_file_address($this->approvemodule,$this->approvemodule.'DetailFieldsHtml'))
        {
            $productviewobj=new ApproveTabView($this->approvemodule,"");
            $queryobj=new ApproveTabDetailQuery($this->approvemodule,$current_user,$customviewobj,$productviewobj);
        }
        else 
        {
            $queryobj=new ApproveQuery($this->approvemodule,$current_user,$customviewobj);
        }
        $approveQueryobjs[$approveid]=$queryobj;
        
        return $queryobj;
     }

     public function get($record)
     {
		global $current_user,$adb;

		
		$queryobj=$this->getQueryobj($this->approveid);
		$queryobj->initForCustomViewById($this->approveid);
		$query=$queryobj->getQuery("",1);
		if(empty($queryobj->conditionals)){
			return 'yes';
		}else{
			$query.=" and ".$queryobj->moduleobj->table_name.'.'.$queryobj->moduleobj->table_index.'='.$record;
			$result=$adb->pquery($query,array());
			if($adb->num_rows($result) >= 1){
				return 'yes';
			}else{
				return 'no';
			}
		}
     }
}

?>