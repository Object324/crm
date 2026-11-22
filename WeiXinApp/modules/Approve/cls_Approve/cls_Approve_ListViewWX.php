<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Chj
 */
crm_load_class_file('cls_ListViewWX', 'WeiXinApp/list');
class cls_Approve_ListViewWX extends cls_ListViewWX{
    protected $page_list_query;//分页查询语句gyqCom0306
    public  $queryGenerator;
    //data:20170503 reason:审批中心序时簿还在插入审批状态
	protected function set_detail_value(&$detail_value,$approvestatus,$value,$real_i)
	{
		if(!empty($approvestatus)){
			$detail_value[$real_i]['approvestatus'] = $approvestatus[$value];
		}
	}
    //date:2017-11-22 获取模块对应的审批中心sql    
    public function getModuleApproveQuery($module, $current_user,$customview){
        parent::setFilterRequest();
        crm_load_class_file('cls_Approve_QueryGeneratorWX','WeiXinApp/modules/Approve/cls_Approve');
		$approveobj= new cls_Approve_QueryGeneratorWX($module, $current_user,$customview);
        $queryGenerator = $approveobj->queryobj;
        
		if (!empty($_REQUEST['searchcontent'])||$_REQUEST['SearchScope']!='SmOwner_Search_All') {
            $queryFun = crm_load_class_obj('QueryGenerator_FunctionsMC','appCommon/include/QueryGenerator');
            $queryFun->addsearchContent($queryGenerator,'weixin');
        }
        return $approveobj->getListQuery();
    }
	function getquery($module, $current_user,$customview){
		global $mobileversion;
		$viewid = $customview->getViewId($module);
		if(get_file_address($module,'ProductDetails')||get_file_address($module,'ContactsDetails')||get_file_address($module,'VendorsDetails')){
            crm_load_class_file('ProductDetailsWX', 'WeiXinApp/WeiXin_CustomView');
            //gyq_22
            $productdetailsobj = new ProductDetailsWX($module);
			if(get_file_address($module,'ContactsDetails')){
				crm_load_class_file('cls_Approve_AccountsQueryGenerator','modules/Approve/ListView');
				$this->queryGenerator= new cls_Approve_AccountsQueryGenerator($module, $current_user,$customview,$productdetailsobj);	
			}else if(get_file_address($module,'VendorsDetails')){
				crm_load_class_file('cls_Approve_VendorsQueryGenerator','modules/Approve/ListView');
				$this->queryGenerator= new cls_Approve_VendorsQueryGenerator($module, $current_user,$customview,$productdetailsobj);	
			}else{
				crm_load_class_file('cls_Approve_ProductQueryGenerator','modules/Approve/ListView');
				$this->queryGenerator= new cls_Approve_ProductQueryGenerator($module, $current_user,$customview,$productdetailsobj);
			}
		}else if(get_file_address($module,$module.'DetailFieldsHtml')){//gyqCom
			crm_load_class_file('TabDetailsWX','WeiXinApp/WeiXin_CustomView');
			$productdetailsobj = new TabDetailsWX($module);
			crm_load_class_file('cls_Approve_TabDetailQueryGenerator','modules/Approve/ListView');
			$this->queryGenerator= new cls_Approve_TabDetailQueryGenerator($module, $current_user,$customview,$productdetailsobj);
		}else{
			crm_load_class_file('cls_Approve_QueryGeneratorWX','WeiXinApp/modules/Approve/cls_Approve');
			$this->queryGenerator= new cls_Approve_QueryGeneratorWX($module, $current_user,$customview);
		}

		if ($viewid != "0") 
        {
            $this->queryGenerator->initForCustomViewById($viewid);
        } 
        else 
        {
            $this->queryGenerator->initForDefaultCustomView();
        }

		if($_REQUEST['query'] == 'true')
         {
                       
            $this->queryGenerator->addUserSearchConditions($_REQUEST);
           	//$ustring = getSearchURL($_REQUEST);
           	//$url_string .= "&query=true$ustring";
                    	
        }
         
        $this->page_list_query = $this->queryGenerator->getQuery('',1);


        $list_query = $this->queryGenerator->getQuery('',2);
        return $list_query;
	}

	function getPageListQuery()
    {
        return $this->page_list_query;
    }
}

?>