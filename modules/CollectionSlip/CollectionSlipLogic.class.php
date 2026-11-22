<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class CollectionSlipLogic extends BaseLogic {
	
	public function getListMoreBtn() {
		parent::getListMoreBtn();
	}

    public function getListBasicBtn(){
        parent::getListBasicBtn();
        $module = self::$module;
        $tmp_list_buttons=array();
        foreach($this->list_buttons as $btnname=>$content)
        {
            $tmp_list_buttons[$btnname]=$content;
            if($btnname=='Create') {
                $tmp_list_buttons = $this->getReceiveButton($tmp_list_buttons);
            }
        }
        $this->list_buttons=$tmp_list_buttons;
    }

    //根据页签信息判断是否需要显示领取/释放按钮
    public function getReceiveButton($buttons){
        $module = self::$module;
        global $currentModule;
        if(isset($_REQUEST['collectionslip_status'])&&$_REQUEST['collectionslip_status']!=""){
            $collectionslip_status = $_REQUEST['collectionslip_status'];
        } else if(isset($_SESSION['lvs'][$module]['collectionslip_status']) && $_SESSION['lvs'][$module]['collectionslip_status']!="" ){
            $collectionslip_status = $_SESSION['lvs'][$module]['collectionslip_status'];
        } else {
            $collectionslip_status = 'all';
        }
        if($collectionslip_status=='uncollected'){
            $buttons['receive']['label'] = getFixedLabel('RECEIVE');
            $buttons['receive']['permit'] = 'yes';
            $buttons['receive']['icon'] = 'icon-receive';
            $buttons['receive']['btnkey'] = 'receive';
        }else if($collectionslip_status=='collected'){
            $buttons['massrelease']['label'] = getFixedLabel('BATCHRELEASE');
            $buttons['massrelease']['permit'] = 'yes';
            $buttons['massrelease']['icon'] = 'massrelease.png';
            $buttons['massrelease']['btnkey'] = 'massrelease';
        }
        return $buttons;
    }
    public function getallListViewLink() {
        $btn =array();
        $btn['allocate']['label'] = getFixedLabel('ALLOCATE');//分配
        $btn['receive']['label'] = getFixedLabel('RECEIVE');//领取
        $btn['release']['label'] = getFixedLabel('RELEASE');//释放
        $btn = f_array_insert($btn,parent::getallListViewLink());
        return $btn;
    }
    public function setListViewLink($result,$record,$start,$idx){
        global $adb;
        $module = self::$module;
        parent::setListViewLink($result,$record,$start,$idx);
        $edit_permit = isPermitted(self::$module,'EditView',$record);
        if($record >0){
            $sql = "select collectionslip_status from ld_collectionslip where collectionslip_id = ?";
            $result = $adb->pquery($sql,array($record));
            if($adb->num_rows($result)>0){
                $collectionslip_status = $adb->query_result($result,0,'collectionslip_status');
                if($collectionslip_status == 'havecashbill'){
                    $edit_permit = 'no';
                }
            }
        }
        $this->listview_link['edit']['label'] = getFixedLabel('EDIT');
        $this->listview_link['edit']['permit'] = $edit_permit;

        //根据页签信息判断列表界面是否需要显示领取/释放按钮
        if(isset($_REQUEST['collectionslip_status'])&&$_REQUEST['collectionslip_status']!=""){
            $collectionslip_status = $_REQUEST['collectionslip_status'];
        } else if(isset($_SESSION['lvs'][$module]['collectionslip_status']) && $_SESSION['lvs'][$module]['collectionslip_status']!="" ){
            $collectionslip_status = $_SESSION['lvs'][$module]['collectionslip_status'];
        } else {
            $collectionslip_status = 'all';
        }
        if ((isset($collectionslip_status) && $collectionslip_status == 'uncollected')){
            $btn['allocate']['label'] = getFixedLabel('ALLOCATE');//分配
            $btn['allocate']['click'] = 'ChangeCreators(\'Allocate\', \'CollectionSlip\', \'list\', %d, \'\', 1)';
            $btn['allocate']['permit'] = 'yes';
            $btn['receive']['label'] = getFixedLabel('RECEIVE');//领取
            $btn['receive']['click'] = 'receive_collectionsliplist(%d)';
            $btn['receive']['permit'] = 'yes';
            $this->listview_link = f_array_insert($this->listview_link,$btn,-1);
        }
        if ((isset($collectionslip_status) && $collectionslip_status == 'collected') ){
            $btn['release']['label'] = getFixedLabel('RELEASE');//释放
            $btn['release']['click'] = 'release_collectionsliplist(%d)';
            $btn['release']['permit'] = 'yes';
            $this->listview_link = f_array_insert($this->listview_link,$btn,-1);
        }
    }
}
?>