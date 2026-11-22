<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class BankAccountSetLogic extends BaseLogic {
	/**
	 * 初始化模块基础按钮
	 * @author Tujt 2015-05-28
	 */
	public function getListBasicBtn() {
		parent::getListBasicBtn();//调用父类方法
		//unset($this->list_buttons['Allocate']);//删除分配按钮
		unset($this->list_buttons['Share']);//删除共享按钮
		unset($this->list_buttons['Settings']);
	}
    /**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-05-28
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();//调用父类方法
        
        //将“禁用”按钮插入到银行账户模块下"更多"按钮中的"恢复预设列宽"的上方
        $tmp_list_buttons=array();
        foreach($this->list_buttons['More']['list'] as $btnname=>$content)
        {
            $tmp_list_buttons[$btnname]=$content;
        }
        //BUG0074295 20231024 kfbcrm-成员“hxg （密码123）”没有“禁用”的权限，但是还是显示禁用按钮
        $tmp_list_buttons['Inactivating']['label'] = getFixedLabel('INACTIVATING');
        $tmp_list_buttons['Inactivating']['permit'] = isPermitted(self::$module,'UserStop','');
        $tmp_list_buttons['Inactivating']['btnkey'] = 'INACTIVATING';

        $this->list_buttons['More']['list']=$tmp_list_buttons;
        unset($this->list_buttons['More']['list']['Share']);//删除共享按钮
		unset($this->list_buttons['More']['list']['Import']);//删除导入按钮
	}
	/**
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-04
	 */
	public function getDetailBasicBtn() {
        global $weixin_user;
	    parent::getDetailBasicBtn();//调用父类方法
		//unset($this->detail_buttons['Allocate']);//删除分配按钮
        //将“账户权限”按钮插入到银行账户模块下的单据详情页按钮列表中的第三个位置
        $btn_arr = array();
        $btn_arr['PotentialsShare']['label'] = getFixedLabel('Account_Permissions');
        $btn_arr['PotentialsShare']['permit'] = 'yes';
        $btn_arr['PotentialsShare']['icon'] = 'icon-user';
        $this->detail_buttons = f_array_insert($this->detail_buttons,$btn_arr,3);
		unset($this->detail_buttons['Settings']);
        //移动端去掉复制按钮
        if(!empty($weixin_user)){
            unset($this->detail_buttons['Copy']);
        }
	}
    public function getDetailBasicSet(){
        //parent::getDetailBasicBtn();
        //问卷调查模块没有页面设置  0045853
        unset($this->detail_settings['Settings']);
        unset($this->detail_settings['DetailsSettings']);
        unset($this->detail_settings['RelevantSettings']);
    }
    public function getDeleteBtn(){
        
        $module=self::$module;
        $record=$this->controller->id;
        $buttons=parent::getDeleteBtn();
        
			$confirmed = $this->getTableFldInfo(self::$module,$this->controller->id,'confirmed');
			if(1 == $confirmed){//已确定
				$is_check = getFixedLabel('BANKNOTTODELETE');//银行账户已经初始化，不允许删除!
                $buttons['permit']='no';
		   }
		return $buttons;
        
    }
	/**
	 * 获取详情页更多按钮下拉列表对象
	 * @author Tujt 2015-06-04
	 */
	public function getDetailMoreBtn() {
	    parent::getDetailMoreBtn();//调用父类方法
		unset($this->detail_buttons['More']['list']['Share']);//删除共享按钮
		unset($this->detail_buttons['More']['list']['Copy']);//删除复制按钮
		if('yes' == $this->detail_buttons['Edit']['permit']){//拥有编辑权限
			$confirmed = $this->getTableFldInfo(self::$module,$this->controller->id,'confirmed');
			$btn = array();
        
			if(0 == $confirmed){//确认
				$btn['set_bank_checks']['label'] = getFixedLabel('Save_and_confirm');
				$btn['set_bank_checks']['permit'] = 'yes';
			}else{
				$this->detail_buttons['More']['permit']='yes';
				$this->detail_buttons['More']['list']['Delete']['permit'] = 'no';
                //bug:24194 edit:cyb date:2016-08-29 银行账户模块单据明细界面应该有编辑按钮
                //$this->detail_buttons['Edit']['permit']='no';
			}
			$this->detail_buttons['More']['list'] = f_array_insert($this->detail_buttons['More']['list'],$btn,1);
		}
        
	}
    public function getallListViewLink() {
        $btn =array();
        $btn['BankConfirmed']['label'] = getFixedLabel('Save_and_confirm');//确认
        $btn = f_array_insert($btn,parent::getallListViewLink(),-1);
        return $btn;
    }
	/**
	 * 初始化列表按钮结果集
	 * @author Tujt 2015-06-29
	 */
	public function setListViewLink($result,$record,$start,$idx) {
		parent::setListViewLink($result,$record,$start,$idx);
		unset($this->listview_link['BankConfirmed']);
		if(isPermitted(self::$module,'Edit',$record) == 'yes'){
			$confirmed = $this->getTableFldInfo(self::$module,$record,'confirmed');
			if(0 == $confirmed){//确认
				$btn = array();
				$btn['BankConfirmed']['label'] = getFixedLabel('Save_and_confirm');//确认
				$btn['BankConfirmed']['permit'] = 'yes';
				$btn['BankConfirmed']['click'] = 'set_bank_checks_presence(\''.$record.'\',1);';
				$this->listview_link = f_array_insert($this->listview_link,$btn);
			}
		}
	}
	/**
	 * 判断删除，已经初始化的单据不允许删除
	 * @author Tujt 2015-07-20
	 */
	public function checkDelInfo($module,$record) {
	   // $is_check = parent::checkDelInfo($module,$record);
       // dump($is_check);
		//if('SUCCESS' == $is_check){
			$confirmed = $this->getTableFldInfo(self::$module,$this->controller->id,'confirmed');
           $is_check='SUCCESS';
       
           
			if(1 == $confirmed){//已确定
				$is_check = getFixedLabel('BANKNOTTODELETE');//银行账户已经初始化，不允许删除!
			}
            else{
                /* global $adb;
                 $sql='select tabid,columnname,tablename from ld_field where (uitype=251 or uitype=252) and presence in(0,2)';
                 $result=$adb->pquery($sql,array());
                 $rows=$adb->num_rows($result);
                 $arr=[];
               
                 for($i=0;$i<$rows;$i++)
                 {
                    $tablename=$adb->query_result($result,$i,'tablename');
                    $columnname=$adb->query_result($result,$i,'columnname');
                    $tabid=$adb->query_result($result,$i,'tabid');
                    
                    $sql="select $columnname from $tablename where $columnname= ?  limit 1 ";
                  
                    $tmpresult=$adb->pquery($sql,array($this->controller->id));
                    if($adb->num_rows($tmpresult)>0)
                    {
                        $tabname=getTabname($tabid);
                       $arr[]=getTransTab($tabname);
                        
                    }
                 }*/
                 
            }
          
		//}
		return $is_check;
	}
     public function getEditViewBtn(){
        global $weixin_user;
        //移动端不可编辑银行账户
        if(!empty($weixin_user)){
            return array();
        }

        return parent::getEditViewBtn();
    }
}
?>