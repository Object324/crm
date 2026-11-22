<?php
/**
 * 关联创建
 * @author xiaoshun 2016-04-06
 */
 
class QuotesLogic extends BaseLogic {
	
	public function getActionUserd() {
		parent::getActionUserd();//调用父级方法
		//创建服务合同
       
		$tabid = getTabid('ServiceContracts');
         
		if(isset($this->quickactionLink[$tabid])){
            $tag = $this->quickactionLink[$tabid]['tag'];
            $tag = str_replace('quoteid','quote_id',$tag);
           
            $tag .= '&vendor_id='.$this->controller->column_fields['vendor_id'].'&vendorcontacts_id='.$this->controller->column_fields['vendorcontacts_id'];

            $this->quickactionLink[$tabid]['tag'] = $tag;
		}		
      
		return $this->quickactionLink;
	}
     public function getDetailMoreBtn()
     {
        
        parent::getDetailMoreBtn();
        
        $VersionInfo = getVersionInfo();
        if($VersionInfo['account']=='haige'){
            //海格
            global $adb;
            $sql='select isclose,allowcopy,current_approvestatus,quotetype from ld_quotes where quoteid=?';
            $result=$adb->pquery($sql,array($this->controller->id));
            $isclose=$adb->query_result($result,0,'isclose');
            $allowcopy=$adb->query_result($result,0,'allowcopy');
            $approvestatus=$adb->query_result($result,0,'current_approvestatus');
            $quotetype=$adb->query_result($result,0,'quotetype');
            crm_load_class_file("cls_HaigeConst",'modules/Quotes');
            if($allowcopy=='yes'&&$approvestatus==D_A_S_APPROVED&&($quotetype==cls_HaigeConst::$QuoteType_Specical||$quotetype==cls_HaigeConst::$QuoteType_BackUp))
            {
                
            }
            else
            {
                unset( $this->detail_buttons['Copy']);
            }
        }
     }
    public function getDetailBasicBtn() {
		parent::getDetailBasicBtn();
		$module = self::$module;
		global $current_user,$adb;
		$version_info = getVersionInfo();
		//浩辰特殊开发  chj  20220530 合同生成 模块详情页面增加作废按钮
		if($version_info['account'] == 'haochen'){
			$btn['Haochen_VoidOrder']['label'] = getFixedLabel('Void');//作废
			$btn['Haochen_VoidOrder']['permit'] = isPermitted($module, 'Delete', '');
			$btn['Haochen_VoidOrder']['icon'] = 'icon-return';
			$this->detail_buttons = f_array_insert($this->detail_buttons,$btn,-4);//页面设置按钮之前
		}
	}
    /**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-05-28
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();
		$module = self::$module;
		$btn = array();
        //var_dump(isPermitted(self::$module,'MergeCreate'));
        
		if(isPermitted('SalesOrder','Create','') == 'yes'){
			$btn['MergeCreate']['label'] = getFixedLabel('MERGECREATE');
			$btn['MergeCreate']['permit'] = 'yes';
			$this->list_buttons['More']['permit']='yes';
            $keys=array_keys($this->list_buttons['More']['list']);
            $index=sizeof($keys);
            
			$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,$index);
	   }
	}
    public function getallListViewLink() {
        $btn =array();
        $version_info = getVersionInfo();
        //浩辰特殊开发  chj  20220530 合同申请单列表操作列增加关联创建合同拆分按钮
        if($version_info['account'] == 'haochen'){
            $btn['haochen_chaifen']['label'] = getFixedLabel('split');//拆分
        }
        $btn = f_array_insert($btn,parent::getallListViewLink(),-1);
        return $btn;
    }
	/**
	 * 初始化列表按钮结果集
	 */
	public function setListViewLink($result,$record,$start,$idx) {
		parent::setListViewLink($result,$record,$start,$idx);
		$module = self::$module;
		$version_info = getVersionInfo();
		//浩辰特殊开发  chj  20220530 合同申请单列表操作列增加关联创建合同拆分按钮
		if($version_info['account'] == 'haochen'){
			$query = 'select approvestatus from ld_quotes where quoteid = ? and deleted = 0 limit 1';
			$result = $this->db->pquery($query,array($record));
			$approvestatus = $this->db->query_result($result,0,0);
			unset($this->listview_link['haochen_chaifen']);
			if($approvestatus == constant('D_A_S_APPROVED')){	//已批准
				$btn['haochen_chaifen']['label'] = getFixedLabel('split');//拆分
				$btn['haochen_chaifen']['click'] = "related_add_url('index.php?module=CustomForm16&action=EditView&return_module=CustomForm16&return_action=DetailView&relatedcreate=yes&Create=true&frommodule=Quotes&fromid=$record&parent_id=$record&quote_id=$record','Quotes','CustomForm16','$record');";
				$btn['haochen_chaifen']['permit'] = isPermitted($module, 'Delete', '');
				$this->listview_link = f_array_insert($this->listview_link,$btn);
			}
		}
	}
	public function getListBasicBtn() {
		global $current_user;
		parent::getListBasicBtn();//调用父类方法
		$version_info = getVersionInfo();
		//浩辰特殊开发  chj 合同申请隐藏新增按钮
		if($version_info['account'] == 'haochen'){
			$this->list_buttons['Create']['permit'] = 'no';
		}

	}
}

?>