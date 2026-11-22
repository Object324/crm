<?php
/**
 * 关联创建
 * @author xiaoshun 2016-04-06
 */
 
class HelpDeskLogic extends BaseLogic {
	
	public function getActionUserd() {
		parent::getActionUserd();//调用父级方法
		//创建服务合同
       
		$tabid = getTabid('ServiceReturn');
         
		if(isset($this->quickactionLink[$tabid])){
            $tag = $this->quickactionLink[$tabid]['tag'];
            

            $this->quickactionLink[$tabid]['tag'] = $tag;
            $this->quickactionLink[$tabid]['click'] = 'check()';         
		}		
      
		return $this->quickactionLink;
	}
	
	public function getListMoreBtn(){
        require_once globalStatic::$root_directory.'weixinmp/include/cls_MP_CommonFun.php';
	    global $current_user;
		parent::getListMoreBtn();//调用父级方法
		$regop=RegOp::getInstance();
        $bwb_interface=$regop->GetbwbInterfaceStatus();
		$query = "select active from ld_settings_field where `name` = 'BANGWO8INTERFACE'";
		$result = $this->db->pquery($query,array());
		$active = $this->db->query_result($result,0,0);
		$query = 'select 1 from ld_bangwo8';
		$result = $this->db->pquery($query,array());
		if($bwb_interface == 1 && $active == 0 && $this->db->num_rows($result) >= 1){
			$this->list_buttons['More']['list']['bw_helpdesk'] = array('label'=>getFixedLabel('BWHELPDESKSYNC'),'permit'=>'yes');
			$this->list_buttons['More']['permit'] = 'yes';
		}
		//editor:gyq_127 reason:需授权服务小程序且是管理员  2019/6/24 16:15
        if(cls_MP_CommonFun::check_self_help_reg('service') && $current_user->is_admin=='on'){
            $this->list_buttons['More']['list']['evaluate'] = array('label'=>getFixedLabel('EVALUATESETTING'),'permit'=>'yes');
            $this->list_buttons['More']['permit'] = 'yes';
        }
	}
}

?>