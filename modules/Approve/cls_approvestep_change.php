<?php
/*
 * edit:duan
 * date:20240923
 * reason:审批步骤动态变化操作类
 *
 * */

class cls_approvestep_change
{
    public $module = '';
    public $pagemode = 'edit';//edit、approve 分别代表新建编辑和审批必填界面,默认为新建编辑界面
    public $approve_fieldname_arr = [];//审批条件判断需要用到的字段
    public $record = 0;
    public $db;//数据库对象
    public $user;
    public $focus;
    public $column_value; //表头字段值
    public $approveobj;
    public $detailrowcnt;

    public function __construct($module)
    {
        global $adb,$current_user;
        $this->module = $module;
        $this->db = $adb;
        $this->user = $current_user;
    }

    public function set_pagemode($pagemode)
    {
        $this->pagemode = $pagemode;
    }

    public function set_focus($focus)
    {
        $this->focus = $focus;
    }

    public function set_column_value($column_value){
        $this->column_value = $column_value;
    }

    public function setdetailrowcnt($detailrowcnt)
    {
        $this->detailrowcnt=$detailrowcnt;
    }

    //获取当前用户适用的审批流程
    public function getAllApprovesByUserid(){
        //检查模块是否开启审批
        $module = $this->module;
        crm_load_class_file('cls_ApproveCache','modules/Approve');
        $approvemod = cls_ApproveCache::getApproveModuleInfo();
        if ($module == 'Events') {
            $approve_module = 'Calendar';
        }else
            $approve_module = $module;
        if (!isset($approvemod[$approve_module]) )
            return ;
        if(!$this->approveobj->Blocksquicksubmit($approve_module)){//如果不启用快速提交则返回空数组
            return array();
        }
        $tabid = getTabid($this->module);
        $cur_userid = $this->user->id;
        crm_load_class_file('cls_ApproveInfo','modules/Approve');
        $ApproveInfoObj=new cls_ApproveInfo($this);
        $all_approveinfo = $ApproveInfoObj->getAllApprovesByUserid($tabid,$cur_userid);
        return $all_approveinfo;
    }

    public function set_approveobj($approveobj){
        if(!empty($approveobj)){
            $this->approveobj = $approveobj;
        }else{
            $this->approveobj = Approve::getInstance($this->module);
        }
    }

    //获取审批流程判断需要用到的字段，$approve_arr：当前用户适用的审批流程
    public function get_approve_fieldname($approveid_arr = []){
        $this->set_approveobj('');
        $approve_fieldname_arr = ['main_fieldname'=>[],'entry_fieldname'=>[]];
        if($this->pagemode == 'edit'){
            $approve_arr = $this->getAllApprovesByUserid();
            if(empty($approve_arr) || count($approve_arr) == 0){
                return $approve_fieldname_arr;
            }
            $approveid_arr = [];
            foreach ($approve_arr as $tmp_info){
                if($tmp_info['isnewapprove'] == 'yes'){
                    $approveid_arr[] = $tmp_info['approveid'];
                }
            }
        }else{
            $approveid_arr = $approveid_arr;
        }

        if(count($approveid_arr) == 0)return $approve_fieldname_arr;

        //获取审批流程的条件
        $i = 0;
        $adb = $this->db;
        $approveid_str = implode(',',$approveid_arr);
        $approve_sql = 'SELECT id,dataadv,dataadvgroup from ld_approve where id in ('.$approveid_str.') and dataadv <> "" ';
        $result = $adb->pquery($approve_sql,[]);
        $num_rows = $adb->num_rows($result);
        $adv_column_arr = [];
        if($num_rows > 0){
            for ($i = 0;$i < $num_rows ;$i++){
                $id = $adb->query_result($result,$i,'id');
                $dataadv = $adb->query_result($result,$i,'dataadv');
                $dataadvgroup = $adb->query_result($result,$i,'dataadvgroup');
                $dataadv_arr = ldcrm_json_decode($dataadv);
                foreach ($dataadv_arr as $tmp_arr){
                    if(!empty($tmp_arr['columnname'])){
                        $adv_column_arr[] = $tmp_arr['columnname'];
                    }
                }
            }
        }
        //获取审批步骤的条件
        $approvestep_sql = 'SELECT ld_approvestepadvfilter.columnname from ld_approvestepadvfilter 
            INNER JOIN ld_approvestep on ld_approvestep.id = ld_approvestepadvfilter.stepid
            where ld_approvestep.approveid in ('.$approveid_str.') and ld_approvestepadvfilter.columnname <> "" ';
        $result = $adb->pquery($approvestep_sql,[]);
        $num_rows = $adb->num_rows($result);
        if($num_rows > 0){
            for ($i = 0;$i < $num_rows ;$i++){
                $columnname = $adb->query_result($result,$i,'columnname');
                if(!empty($columnname)){
                    $adv_column_arr[] = $columnname;
                }
            }
        }

        //分别筛选出表头和分录相关的字段
        $focus = CRMEntity::getInstance($this->module);
        $main_fieldname_arr = [];
        $entry_fieldname_arr = [];
        $is_productdetail = get_file_address($this->module,'ProductDetails');
        if($is_productdetail){
            $product_focus = CRMEntity::getInstance('Products');
        }


        foreach ($adv_column_arr as $tmp_column){
            $tmp_column_arr = explode(':',$tmp_column);
            $tablename = $tmp_column_arr[0];
            $fieldname = $tmp_column_arr[2];
            if(in_array($tablename,[$focus->table_name,$focus->customFieldTable[0]])){
                if(!in_array($fieldname,$main_fieldname_arr)){
                    $main_fieldname_arr[] = $fieldname;
                }
            }else if(in_array($tablename,[$focus->Detail_table,$focus->Detail_table_scf])){
                if(!in_array($fieldname,$entry_fieldname_arr)){
                    $entry_fieldname_arr[] = $fieldname;
                }
            }else if($is_productdetail && in_array($tablename,[$product_focus->table_name,$product_focus->customFieldTable[0]])){
                //产品分录的产品属性字段也需要获取
                if(!in_array($fieldname,$entry_fieldname_arr)){
                    $entry_fieldname_arr[] = $fieldname;
                }
            }
        }

        $this->approve_fieldname_arr = ['main_fieldname'=>$main_fieldname_arr,'entry_fieldname'=>$entry_fieldname_arr];
        return $this->approve_fieldname_arr;
    }

    // 获取当前用户适用的审批流程,并根据条件筛选
    public function getApplicableApproveInfo(){
        $all_approveinfo = $this->getAllApprovesByUserid();
        if(!is_array($all_approveinfo) || count($all_approveinfo) == 0)return $all_approveinfo;

        $approveid_arr = [];
        foreach ($all_approveinfo as $tmp_info){
            if($tmp_info['isnewapprove'] == 'yes'){
                $approveid_arr[] = $tmp_info['approveid'];
            }
        }

        if(count($approveid_arr) > 0){
            //获取审批流程的条件
            $i = 0;
            $adb = $this->db;
            $module = $this->module;
            $approveid_str = implode(',',$approveid_arr);
            $approve_sql = 'SELECT id,dataadv,dataadvgroup from ld_approve where id in ('.$approveid_str.') and dataadv <> "" ';
            $result = $adb->pquery($approve_sql,[]);
            $num_rows = $adb->num_rows($result);

            $focus = $this->focus;
            crm_load_class_file('cls_fieldsearchcondition','include/utils/');
            $cls_fieldsearchconditionobj = cls_fieldsearchcondition::getInstance($this->module);
            $cls_fieldsearchconditionobj->setRecord($focus->id);
            $cls_fieldsearchconditionobj->setColumnValues($this->column_value);
            if($this->detailrowcnt > 0){
                $cls_fieldsearchconditionobj->setdetailrowcnt($this->detailrowcnt);
            }else{
                $cls_fieldsearchconditionobj->getDetailRowcnt();
            }

            $nopermit_idarr = [];
            if($num_rows > 0){
                for ($i = 0;$i < $num_rows ;$i++){
                    $id = $adb->query_result($result,$i,'id');
                    $dataadv = $adb->query_result($result,$i,'dataadv');
                    $dataadvgroup = $adb->query_result($result,$i,'dataadvgroup');
                    if(empty($dataadv)){
                        continue;
                    }

                    $tmpinput = [
                        'advft_criteria' =>  html_entity_decode($dataadv),
                        'advft_criteria_groups' =>   html_entity_decode($dataadvgroup),
                        'searchtype' =>  'advance',
                    ];
                    $tmp_value = $cls_fieldsearchconditionobj->getresultbyAdvancecondition($tmpinput);

                    if(!$tmp_value){
                        $nopermit_idarr[] = $id;
                    }
                }
            }
            $new_approveinfo = [];
            if(count($nopermit_idarr)>0){
                foreach ($all_approveinfo as $tmp_info){
                    if($tmp_info['isnewapprove'] == 'yes' && in_array($tmp_info['approveid'],$nopermit_idarr)){
                        continue;
                    }
                    $new_approveinfo[] = $tmp_info;
                }
            }else{
                $new_approveinfo = $all_approveinfo;
            }
        }else{
            $new_approveinfo = $all_approveinfo;
        }
        if(count($new_approveinfo) == 0)return $new_approveinfo;

        if ($focus->mode == 'edit') {
            $status = $this->approveobj->getApproveStatus($focus->column_fields['approvestatus']);
            // ls 2021-11-17 【1002212】审批流程定制增加允许重复提交审批（徐昱轩）
            //已批准/已拒绝的单据允许再次提交审批，且有审批流程“审批结束编辑单据保存，自动提交审批时默认审批流程”为是，则编辑界面显示“保存并提交”按钮
            if (($status == 2 || $status == 3) && $this->approveobj->recordAgainSubmit($module)) {
                foreach ($new_approveinfo as &$tmpapprove) {
                    if($tmpapprove['finishedallowedit']=='yes' && $tmpapprove['allowagainsubmit']=='yes') {
                        $tmpapprove['selected'] = 'selected';
                        break;
                    }
                }
            }
        }
        $new_approveinfo = $this->approveobj->NoDefaultAddEmptyApproval($new_approveinfo);

        return $new_approveinfo;
    }


}



?>