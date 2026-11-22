<?php
crm_load_class_file('ProductDetail_ListController','include/ListView/ProductDetail');
class cls_Approve_ProductListViewController  extends ProductDetail_ListController
{
    //重写操作列方法
	public function getListViewOperating($module){
	  
      //已处理，有操作列按钮
	   global $approvestatus;
	   if($approvestatus==1)
       {
        return  parent::getListViewOperating($module);
       }
       else
		return array();
	}
	public function getListViewBtn($focus,$module,$result,$recordId,$start,$i){
		return '';
	}
	public function setListFieldValueObj($focus,$module)
	{
		global $approvestatus;
		crm_load_class_file('ListViewfieldValue','include/ListView');
		$this->listviewFieldValue = new ListViewfieldValue($focus,$module,$this->queryGenerator);

		$this->listviewFieldValue->add_url_get_value='&result_aprove='.($approvestatus+1);

	}
    /**
     * 字段排序是否按照列头点击排序
     * */
    public function HeaderFieldSortIsBy_request($orderBy,$focus,$field)
    {
            if($orderBy=='tmp_approve.approveby_datetime'&&$field->getColumnName()=='approveby_datetime')
            {
                return 'yes';
            }
            else
            return parent::HeaderFieldSortIsBy_request($orderBy,$focus,$field);
    }
    /**
 * 列头字段是否可以排序
 * yes:可以排序
 * */
  public function HeaderFieldIsSorted($focus,$module,$fieldinfo,$fieldmoduleskey)
  {
     if($fieldinfo->getColumnName()=='approveby_datetime')
     {
        return 'yes';
     }
     else
        return parent::HeaderFieldIsSorted($focus,$module,$fieldinfo,$fieldmoduleskey);
       
  }
    	//重写获取模块内容
	function getListViewEntries($focus, $module,$result,$navigationInfo,$skipActions=false,$MoreAction=false,$export='') {
		global $approvestatus;
		$data = parent::getListViewEntries($focus, $module,$result,$navigationInfo,$skipActions,$MoreAction,$export);
        
         
        $approve_focus = Approve::getInstance($module);
        
		if(!empty($approvestatus) && $approvestatus == 1){
			foreach($data as $record => $listinfo){
				$blockbuttons = $approve_focus->blocksButton('',$record);
				$field['approveby'] = $current_user->id;
                //duan 20220923 BUG0056815：审批中心已处理应该显示反审批按钮
                $field['approvestatus'] = $focus->column_fields['approvestatus'];
                
				$iscancel = $approve_focus->getCancelApprovedBtn($module,$record,$field,$blockbuttons);
                
				$list_btn[0] = '';
				if($iscancel == 1){
					$records = explode(',',$record);
					$list_btn[0] = '<a class="Anu3_a" href="javascript:unApprove_click('.$records[0].',\''.$_REQUEST['fromapprovemodule'].'\',this);" title="'.getFixedLabel('APPROVE_ANTIAPPROVAL').'">'.getFixedLabel('APPROVE_ANTIAPPROVAL').'</a>';
				}
				$list[$record] = array_merge($listinfo,$list_btn);
			}
		}else{
			$list = $data;
		} 
		 $this->queryGenerator->productDetails->querygenerator=$this->queryGenerator;
            $list = $this->queryGenerator->productDetails->getListViewEntries($list,1);     
		return $list;
	}
    	//重写列头排序模块设置
	public function getListViewHeaderByModule($module){
		return 'Approve';
	}
    
    	//重写 列表一对多格式设置
	public function setListViewProductDetails($module,$data){
		return $data;
	}
}
?>