<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class SocialPromotionLogic extends BaseLogic {

    public function getListMoreBtn() {
        parent::getListMoreBtn();//调用父类方法
        unset($this->list_buttons['More']['list']['mass_edit']);
        unset($this->list_buttons['Import']);
        unset($this->list_buttons['More']['list']['Export']);
    }
    /**
     * 获取详情页按钮对象
     * @author Tujt 2015-06-03
     */
    public function getDetailBasicBtn() {
        global $adb,$current_user;
        $module = self::$module;
        //审批
        $approve_focus = Approve::getInstance(self::$module);;
        $startapprovemodule = $approve_focus->startBlocksApprove();
        if(isset($startapprovemodule[self::$module])){//审批模块
            $this->getApproveButton(self::$module,$this->controller,$this->controller->id);
        }
        $fieldObj = Field::getInstance($module,$adb);
        $moduleFields = $fieldObj->getModuleFields();
        $field_creator = $moduleFields['smcreatorid'];

        //返回列表
        //$this->detail_buttons['Back']['label'] = getFixedLabel('BACKTOLIST');
        //$this->detail_buttons['Back']['permit'] = 'yes';//返回列表按钮不需要权限控制(edi;can)
        //$this->detail_buttons['Back']['icon'] = 'icon-return';



        //编辑
        if($module=='LessionPlan')
        {
            $this->detail_buttons['moduledetailEdit']=$this->getEditViewBtn();

        }
        else
        {
            $this->detail_buttons['Edit']=$this->getEditViewBtn();

        }
        //关闭
        if($module=='ProjectTask'){
            $permit ='yes';
            $focus = CRMEntity::getInstance($module);
            $focus->retrieve_entity_info($this->controller->id,$module);
            if($focus->column_fields['projecttaskstatus']=='已完成'){
                $permit = 'no';
            }
            $this->detail_buttons['Close']['label'] = getFixedLabel('CLOSE');
            $this->detail_buttons['Close']['permit'] = $permit;
            $this->detail_buttons['Close']['icon'] = 'icon-del';
        }

        //分配
       /* $Allocate = 'Allocate';
        $Allocatelabel = getFixedLabel('ALLOCATE');
        $Allocatepermit = isPermitted(self::$module,'Allocate');
        if(self::$module == 'Accounts'){
            global $static_publicaccount,$current_user;
            if($static_publicaccount == 1&&isSearchCRMVersion()!='yes'){
                $status=getAccount_Set('status');
                $accounttype = 'ALLACCOUNT';
                if(isset($_REQUEST['pagepublicaccounttype'])){
                    $accounttype = $_REQUEST['pagepublicaccounttype'];
                }elseif(isset($_SESSION['lvsAccount']['Accounts']['pagepublicaccounttype'])){
                    $accounttype = $_SESSION['lvsAccount']['Accounts']['pagepublicaccounttype'];
                }
                $adminaccount=getAccount_Set("adminaccount");
                $splitadmin=explode(",",$adminaccount);
                if($status==0&&($current_user->is_admin=="on"||in_array($current_user->id,$splitadmin))){
                    $Allocate = 'massallocate';
                    $Allocatelabel = getFixedLabel('LBL_DISTRIBUT_HIGHSEAS');
                    $Allocatepermit = 'yes';
                }else{
                    $Allocatepermit = 'no';
                }
            }

        }
        $this->detail_buttons[$Allocate]['label'] = $Allocatelabel;
        $this->detail_buttons[$Allocate]['permit'] = $Allocatepermit;
        $this->detail_buttons[$Allocate]['icon'] = 'icon-user';*/




        if(isset($startapprovemodule[self::$module])){//审批模块

            if(!empty($this->approvebtn['info'])){
                if(1 == $this->approvebtn['submit']){//提交审批
                    $this->detail_buttons['submit']['label'] = getFixedLabel('SUBMITAPPROVAL');
                    $this->detail_buttons['submit']['permit'] = 'yes';
                    $this->detail_buttons['submit']['icon'] = 'icon-check';
                }
                else
                {
                    $lastapproveinfo= $approve_focus->getlastapproveinfo($this->controller->id,$module);


                    if($lastapproveinfo['stepid']=='-1'&&$lastapproveinfo['approved_by']==$current_user->id)
                    {
                        //回撤
                        $this->detail_buttons['approve_retrace']['label'] = getFixedLabel('RETRACEMENT');
                        $this->detail_buttons['approve_retrace']['permit'] = 'yes';
                        $this->detail_buttons['approve_retrace']['icon'] = 'icon-check';
                    }
                }

                if(1!= $this->approvebtn['submit']&&1 == $this->approvebtn['approve']){//审批


                    $this->detail_buttons['approve']['label'] = getFixedLabel('APPROVAL');
                    $this->detail_buttons['approve']['permit'] = 'yes';
                    $this->detail_buttons['approve']['icon'] = 'icon-check';
                }
                if(1 == $this->approvebtn['cancel']){//反审批
                    $this->detail_buttons['cancel']['label'] = getFixedLabel('APPROVE_ANTIAPPROVAL');
                    $this->detail_buttons['cancel']['permit'] = 'yes';
                    $this->detail_buttons['cancel']['icon'] = 'icon-aCheckout';
                }




            }else{//默认有提交审批按钮
                $submit = 1;
                //已批准、审批中、已拒绝状态下，不提交审批
                $statusarray = array(
                    constant('D_A_S_APPROVED')=>'1',//已批准
                    constant('D_A_S_APPROVALOF')=>'1',//审批中
                    constant('D_A_S_REJECTED')=>'1'//已拒绝
                );

                if(isset($this->controller->column_fields['approvestatus']) &&
                    !empty($this->controller->column_fields['approvestatus'])){
                    $approvestatus = $this->controller->column_fields['approvestatus'];
                    if($statusarray[$approvestatus]){
                        $submit = 0;
                    }
                    //没有审批历史，但审批状态为已批准，不允许编辑
                    switch($approvestatus){
                        case constant('D_A_S_APPROVED'):

                        case constant('D_A_S_REJECTED')://已批准，已拒绝，不允许修改
                            $this->detail_buttons['Edit']['permit'] = 'no';
                            $this->detail_buttons['moduledetailEdit']['permit'] = 'no';
                            if(is_admin($current_user))
                            {
                                $this->detail_buttons['cancel']['label'] = getFixedLabel('APPROVE_ANTIAPPROVAL');
                                $this->detail_buttons['cancel']['permit'] = 'yes';
                                $this->detail_buttons['cancel']['icon'] = 'icon-aCheckout';
                            }
                            break;
                        case constant('D_A_S_APPROVALOF'):
                            global $current_user;
                            if(!is_admin($current_user)){//审批中，非管理员不允许编辑
                                $this->detail_buttons['Edit']['permit'] = 'no';
                                $this->detail_buttons['moduledetailEdit']['permit'] = 'no';
                            }
                            else{
                                //40774: （http://kehu001.com/weixin/kh38567/ [^]）合同订单模块：导入模板中“审批状态”列录入“审批中”，导入系统后单据不能反审批也不能回撤（需要补丁）
                                $this->detail_buttons['cancel']['label'] = getFixedLabel('APPROVE_ANTIAPPROVAL');
                                $this->detail_buttons['cancel']['permit'] = 'yes';
                                $this->detail_buttons['cancel']['icon'] = 'icon-aCheckout';
                            }
                            break;
                    }
                }
                if($submit == 1){//非已审批、审批中、已拒绝状态，允许提交审批
                    $this->detail_buttons['submit']['label'] = getFixedLabel('SUBMITAPPROVAL');
                    $this->detail_buttons['submit']['permit'] = 'yes';
                    $this->detail_buttons['submit']['icon'] = 'icon-check';
                }
            }
        }
        $is_set = 'no';
        if(is_admin($current_user)){
            $is_set = 'yes';
        }
        //复制
        $iscopy = 'no';
        if('yes' == isPermitted(self::$module,'Copy')){
            $iscopy = 'yes';$more_idx = 1;
        }
        if((self::$module=='PaymentPlan' || self::$module=='SendPayment')|| (self::$module=='Documents' || self::$module=='Documents')){
            $iscopy = 'no';
        }
        //复制
        if($module!="ServiceCharge"&&( $module=='LessionPlan' ))
        {
            $this->detail_buttons['moduledetailCopy']['label'] = getFixedLabel('COPY');
            $this->detail_buttons['moduledetailCopy']['permit'] = $iscopy;
            $this->detail_buttons['moduledetailCopy']['icon'] = 'icon-copy';
        }
        elseif($module =='SocialPromotion')
        {
            //            社交推广没有页面复制
        }else{
            $this->detail_buttons['Copy']['label'] = getFixedLabel('COPY');
            $this->detail_buttons['Copy']['permit'] = $iscopy;
            $this->detail_buttons['Copy']['icon'] = 'icon-copy';
        }


        //删除
        $this->detail_buttons['Delete']=$this->getDeleteBtn();
        if($this->detail_buttons['Delete']['permit']=='yes')
        {
            $more_idx = 1;//允许删除
        }
        //相关信息设置，只有管理员才会显示页面设置
        /** 
        * @edit:diony 
        * @date:2020-08-31 
        * @reason:【单据查看详情界面增加【相关信息设置】按钮】 https://www.tapd.cn/20699121/prong/stories/view/1120699121001001035
        * @description:添加
        */
        $this->detail_buttons['RelevantSettings']['label'] = getFixedLabel('PROJECTSETTINGS');
        $this->detail_buttons['RelevantSettings']['permit'] = $is_set;
        $this->detail_buttons['RelevantSettings']['icon'] = 'icon-set2';
        //更多按钮
        $this->detail_buttons['More']['label'] = getFixedLabel('MORE');
        $this->detail_buttons['More']['permit'] = 'yes';
        $this->detail_buttons['More']['icon'] = 'icon-more';
    }

    /**
     * 获取详情页更多按钮下拉列表对象
     * @author Tujt 2015-06-03
     */
    public function getDetailMoreBtn() {
        global $current_user,$adb;
        $isshare = 'no';$is_set = 'no';$more_idx = 0;

        if('yes' == isPermitted(self::$module,'Share')){
            $isshare = 'yes';$more_idx = 1;
        }

        if(is_admin($current_user)){
            $is_set = 'yes';$more_idx = 1;
        }



        //共享

        $this->detail_buttons['More']['list']['Share']['label'] = getFixedLabel('SHARE');
        $this->detail_buttons['More']['list']['Share']['permit'] = $isshare;


        //变更创建人

        $tmpfieldobj=$this->controller->fieldobj;
        $createor_field=$tmpfieldobj->getFieldInfoobjBykey('columnname','smcreatorid');
        if(!$createor_field)
        {
            $createor_field=$tmpfieldobj->getFieldInfoobjBykey('columnname','creator');
        }
        if($createor_field)
        {

            if(get_object_vars($createor_field)!=''){
                $ChangeCreatorlabel = getFixedLabel('CHANGE').$createor_field->getfieldLabel();
            }
            $ChangeCreatorpermit = isPermitted(self::$module,'ChangeCreator');
            $this->detail_buttons['More']['list']['ChangeCreator']['label'] = $ChangeCreatorlabel;
            $this->detail_buttons['More']['list']['ChangeCreator']['permit'] = $ChangeCreatorpermit;
            $this->detail_buttons['More']['list']['ChangeCreator']['icon'] = 'icon-user';
        }
        $query  = 'select printtab from ld_tab where `name` = ?';
        $result = $adb->pquery($query,array(self::$module));
        $printtab = $adb->query_result($result,0,0);
        if($printtab == 1){
            $print_permit = 'yes';
        }else{
            $print_permit = 'no';
        }
        if(self::$module == 'SocialPromotion'){
            //社交推广 不要打印按钮
        }else{
            //打印
            $this->detail_buttons['More']['list']['Print']['label'] = getFixedLabel('PRINTTOOL');
            $this->detail_buttons['More']['list']['Print']['permit'] = $print_permit;
            $this->detail_buttons['More']['list']['Print']['icon'] = 'icon-user';
        }
        //32385: 普通用户：进入单据明细界面，没有更多时，就没有“打印工具”按钮
        //if(0 == $more_idx) $this->detail_buttons['More']['permit'] = 'no';
    }

}
?>