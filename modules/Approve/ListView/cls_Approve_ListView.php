<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Chj
 */
class cls_Approve_ListView {
    private $page_list_query;//分页查询语句  
    var  $queryGenerator;

	function getquery($module, $current_user,$customview){
		$viewid = $customview->getViewId($module);
        // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
        $this->getQueryGenerator($module, $current_user,$customview);

		if ($viewid != "0") 
        {
            $this->queryGenerator->initForCustomViewById($viewid);//初始化列头数据by $customview
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
    // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
    function getQueryGenerator($module, $current_user, $customview) {
        if(get_file_address($module,'ProductDetails')||get_file_address($module,'ContactsDetails')||get_file_address($module,'VendorsDetails')){
            crm_load_class_file('cls_Approve_Productdetail','modules/Approve/ListView');
            $productdetailsobj = new cls_Approve_Productdetail($module);
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
        }else if(get_file_address($module,$module.'DetailFieldsHtml')){
            crm_load_class_file('cls_Approve_TabDetails','modules/Approve/ListView');
            $productdetailsobj = new cls_Approve_TabDetails($module);
            crm_load_class_file('cls_Approve_TabDetailQueryGenerator','modules/Approve/ListView');
            $this->queryGenerator= new cls_Approve_TabDetailQueryGenerator($module, $current_user,$customview,$productdetailsobj);
        }
        else if(get_file_address($module,$module.'Details'))
        {
            crm_load_class_file('cls_Approve_Productdetail','modules/Approve/ListView');
            $productdetailsobj = new cls_Approve_Productdetail($module);
            crm_load_class_file('cls_Approve_AttachmentQueryGenerator','modules/Approve/ListView');
            $this->queryGenerator= new cls_Approve_AttachmentQueryGenerator($module, $current_user,$customview,$productdetailsobj);
        }
        else{
            crm_load_class_file('cls_Approve_QueryGenerator','modules/Approve/ListView');
            $this->queryGenerator= new cls_Approve_QueryGenerator($module, $current_user,$customview);
        }
        return $this->queryGenerator;
    }
}

?>