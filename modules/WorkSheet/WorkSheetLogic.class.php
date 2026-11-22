<?php

class WorkSheetLogic extends BaseLogic {
    public $smownerid;
    public $worksheet_status;
    public $payment_status;
    public $hdnSubTotal;
    public $solution;
    
    public function __construct(){
        parent::__construct();
    }
    
    
    public function getListBasicBtn(){
        parent::getListBasicBtn();
        $module = self::$module;
        $tmp_list_buttons=array();
        foreach($this->list_buttons as $btnname=>$content)
        {
            $tmp_list_buttons[$btnname]=$content;
            if($btnname=='Create')
            {
                $tmp_list_buttons = $this->getReceiveButton($tmp_list_buttons);
            }
        }
        $this->list_buttons=$tmp_list_buttons;

    }
    
    public function getDetailBasicBtn(){
        global $current_user,$weixin_user,$adb;
        parent::getDetailBasicBtn();
        $this->getWorkSheetinfo();
        $module = self::$module;
        
        $buttons=array();

        foreach($this->detail_buttons as $btnname=>$content)
        {
            $buttons[$btnname]=$content;
            if($btnname=='Allocate')
            {
                //移动端详情页增加领取按钮
                if(!empty($weixin_user)&&$this->smownerid <=0){
                    $buttons = $this->getReceiveButton($buttons);
                }
                
                if($this->worksheet_status !='closed'){
                    $buttons['Urged']['label'] = getFixedLabel('URGE');
                    $buttons['Urged']['permit'] = isPermitted($module, 'Allocate', '');
                    $buttons['Urged']['icon'] = 'icon-urged';
                    $buttons['Urged']['btnkey'] = 'WorkSheetUrged';
                    
                    //只有服务人员和管理员有解决方案和结单的权限
                    if($this->smownerid >0 && ($this->smownerid == $current_user->id || is_admin($current_user))){
                        $edit_button = $this->getEditViewBtn();
                        $buttons['Solution']['label'] = getFixedLabel('SOLUTION');
                        $buttons['Solution']['permit'] = $edit_button['permit'];
                        $buttons['Solution']['icon'] = 'icon-solution';
                        $buttons['Solution']['btnkey'] = 'WorkSheetSolution';
                        
                        //创建解决方案之后可进行结单
                        if($this->solution != ''){
                            $buttons['Ended']['label'] = getFixedLabel('CLOSEBILL');
                            $buttons['Ended']['permit'] = 'yes';
                            $buttons['Ended']['icon'] = 'icon-closed';
                            $buttons['Ended']['btnkey'] = 'WorkSheetEnded';
                        }
                    }
                }
                
                if($this->worksheet_status =='closed'){
                    //当前单据的服务人员或管理员可以重新打开单据（客户可从服务小程序打开）
                    if($this->smownerid !='' && ($this->smownerid == $current_user->id || is_admin($current_user))){
                        $buttons['Reopen']['label'] = getFixedLabel('REOPEN');
                        $buttons['Reopen']['permit'] = 'yes';
                        $buttons['Reopen']['icon'] = 'icon-reopen';
                        $buttons['Reopen']['btnkey'] = 'WorkSheetReopen';
                        //已结单的工单不显示分配按钮
                        unset($buttons['Allocate']);
                    }
                }
            }
        }
        //XUQIU1001280 zxm 20230423 威奥轨道-小程序增加扫码付款功能
        require_once  (globalStatic::$root_directory.'WeiXinApp/weixinPay/cls_getConfig.php');
        $getConfigObj = new cls_getConfig();
        $configArr = $getConfigObj->getNativePaySetting();
        if(!empty($configArr)&&$this->payment_status!='HavePaid'&&$this->hdnSubTotal>0){
            $buttons['GeneratePaymentCode']['label'] = getFixedLabel('GeneratePaymentCode');
            $buttons['GeneratePaymentCode']['permit'] = 'yes';
            $buttons['GeneratePaymentCode']['icon'] = 'icon-reopen';
            $buttons['GeneratePaymentCode']['btnkey'] = 'GeneratePaymentCode';
        }
        //移动端去掉复制按钮
        if(!empty($weixin_user)){
            unset($buttons['Copy']);
        }

        $this->detail_buttons=$buttons;
        
    }
    
    public function getWorkSheetinfo(){
        global $currentModule;
        $focus = $this->controller;
        $this->controller->retrieve_entity_info($focus->id,$currentModule);
                            
        $this->smownerid = $this->controller->column_fields['assigned_user_id'];
        $this->worksheet_status = $this->controller->column_fields['worksheet_status'];
        //XUQIU1001280 zxm 20230423 威奥轨道-小程序增加扫码付款功能  获得付款状态值
        $this->payment_status = $this->controller->column_fields['payment_status'];
        $this->hdnSubTotal = $this->controller->column_fields['hdnSubTotal'];
        $this->solution = $this->controller->column_fields['solution'];
    }
    
    public function getEditViewBtn(){
        global $weixin_user;
        //已关闭的工单不可编辑
        $this->getWorkSheetinfo();
        if($this->worksheet_status =='closed'){
            return array();
        }
        //移动端不可编辑工单
        if(!empty($weixin_user)){
            //return array();
        }

        return parent::getEditViewBtn();
    }
    
    //根据页签信息判断是否需要显示领取按钮
    public function getReceiveButton($buttons){
        global $currentModule;
        $module = self::$module;
        if(isset($_REQUEST['worksheet_status'])&&$_REQUEST['worksheet_status']!=""){
            $worksheet_status = $_REQUEST['worksheet_status'];
        }else if(isset($_SESSION['lvs'][$currentModule]['worksheet_status'])&&$_SESSION['lvs'][$currentModule]['worksheet_status']!=""){
            $worksheet_status = $_SESSION['lvs'][$currentModule]['worksheet_status'];
        }else{
            $worksheet_status = 'all';
        }
        $no_permit_status = array('inprocess','closed');
        //处理中页签和已结单页签不显示领取按钮
        
        if(!in_array($worksheet_status,$no_permit_status)&&isPermitted($module, 'Receive')=='yes'){
            $permit = 'yes';
        }else{
            $permit = 'no';
        }

        $buttons['receive']['label'] = getFixedLabel('RECEIVE');
        $buttons['receive']['permit'] = $permit;
        $buttons['receive']['icon'] = 'icon-receive';
        $buttons['receive']['btnkey'] = 'receive';
        
        return $buttons;
    }
    public function getallListViewLink() {
        $btn =array();
        $btn['allocate']['label'] = getFixedLabel('ALLOCATE');//分配
        $btn['receive']['label'] = getFixedLabel('RECEIVE');//领取
        $btn = f_array_insert($btn,parent::getallListViewLink());
        return $btn;
    }

    public function setListViewLink($result,$record,$start,$idx){
        global $adb;
        parent::setListViewLink($result,$record,$start,$idx);
        
        $edit_permit = isPermitted(self::$module,'EditView',$record);
        if($record >0){
            $sql = "select worksheet_status from ld_worksheet where worksheetid = ?";
            $result = $adb->pquery($sql,array($record));
            if($adb->num_rows($result)>0){
                $worksheet_status = $adb->query_result($result,0,'worksheet_status');
                if($worksheet_status == 'closed'){
                    $edit_permit = 'no';
                }
            }
        }
        
        $this->listview_link['edit']['label'] = getFixedLabel('EDIT');
		$this->listview_link['edit']['permit'] = $edit_permit;

        // ljj 20230914 XUQIU1001883 工单管理优化
        if ((isset($_REQUEST['worksheet_status']) && $_REQUEST['worksheet_status'] == 'tobeallocated') || $_SESSION['lvs']['WorkSheet']['worksheet_status'] == 'tobeallocated'){
            $btn['allocate']['label'] = getFixedLabel('ALLOCATE');//分配
            $btn['allocate']['click'] = 'ChangeCreators(\'Allocate\', \'WorkSheet\', \'list\', %d, \'\', 1)';
            $btn['allocate']['permit'] = isPermitted('WorkSheet','Allocate');
            $btn['receive']['label'] = getFixedLabel('RECEIVE');//领取
            $btn['receive']['click'] = 'receive_worksheetlist(%d)';
            $btn['receive']['permit'] = isPermitted('WorkSheet','Receive');
            $this->listview_link = f_array_insert($this->listview_link,$btn,-1);
        }
    }
}
?>