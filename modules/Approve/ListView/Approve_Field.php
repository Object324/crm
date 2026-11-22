<?php
class Approve_Field extends Field
{
    public $field_module;
    public $moduleFieldObjs;
    public function __construct($field_module,$adb)
    {
        parent::__construct($field_module,$adb);
        $this->field_module = $field_module;
    }
    //2024-4-2 xxy 获取审批字段列头
    public static function getApproveColumns($approvestatus){
        $Status_toColumns = [
            0 => array('approvesubmitter','approvesubmittedtime','currentapprovestepid'),
            1 => array('approvesubmitter','approvesubmittedtime','approvetime','currentapprovestepid'),
            3 => array('approvesubmittedtime','currentapprovestepid'),
            4 => array('approvesubmitter','approvesubmittedtime','approvetime','currentapprovestepid'),
        ];
        return empty($approvestatus)?$Status_toColumns[0]:$Status_toColumns[$approvestatus];
    }
    //2024-4-2 xxy 获取审批字段列头 - 非产品分录用
    public static function getTabDetailsApproveColumns($approvestatus){
        $Status_toColumns = [
            0 => array('approvesubmitter','approvesubmittedtime','currentapprovestepid'),
            1 => array('approvetime','approve_step'),
            3 => array('approvetime','approve_step'),
            4 => array('approvesubmitter','approvesubmittedtime','approvetime','currentapprovestepid'),
        ];
        return empty($approvestatus)?$Status_toColumns[0]:$Status_toColumns[$approvestatus];
    }
    //2024-4-2 xxy 获取审批字段列头属性
    public static function getAllApproveColumnsInfo($approvestatus){

        $Approve_Columns = [
            'approvesubmitter' => [//发起人
                'label' => getFixedLabel('Sponsor'),
                'type' => 'V',
                'uitype' => 153,
                'tablename' => '',
            ],
            'approvesubmittedtime' => [//发起时间
                'label' => getFixedLabel('Launch_time'),
                'type' => 'DT',
                'uitype' => 70,
                'tablename' => '',
            ],
            'approvetime' => [//最新审批时间
                'label' => getFixedLabel('LATEST') . getFixedLabel('Approval_time'),
                'type' => 'DT',
                'uitype' => 70,
                'tablename' => '',
            ],
            'currentapprovestepid' => [//最新审批步骤
                'label' => getFixedLabel('LATEST') . getFixedLabel('APPROVALSTEP'),
                'type' => 'V',
                'uitype' => 'stepname',
                'tablename' => '',
            ],
            'approve_step' => [//cls_Approve_TabDetails中最新审批步骤
                'label' => getFixedLabel('LATEST') . getFixedLabel('APPROVALSTEP'),
                'type' => 'V',
                'uitype' => 1,
                'tablename' => 'tmp_approve',
            ],
        ];
        if(empty($approvestatus)){
            $Approve_Columns['currentapprovestepid']['label'] = getFixedLabel('APPROVALSTEP');
        }
        return $Approve_Columns;
    }
    //2024-4-7 xxy 获取审批字段列头对象
    public function getApproveColumnsObj($approvestatus,$fieldtype){
        $module = $this->field_module;
        $focus = CRMEntity::getInstance($module);
        $table_name = $focus->table_name;
        $allapprovecolumns = self::getAllApproveColumnsInfo($approvestatus);
        if($fieldtype == 'tabdetailsfield'){
            $approvecolumns = self::getTabDetailsApproveColumns($approvestatus);
        }else{
            $approvecolumns = self::getApproveColumns($approvestatus);
        }
        foreach ($approvecolumns as $index => $approvecolumn) {

            if($fieldtype == 'field'){
                $approvefield = new fieldInfo();

                $approvefield->setTableName($table_name);
                $modulefieldObj[$approvecolumn]=$approvefield;

            }else if($fieldtype == 'productfield'){
                $approvefield = new ProductFields();

                if($approvestatus == 1 && $approvecolumn == "approvesubmitter"){
                    $approvefield->setTableName('ld_accounts');
                }else{
                    $approvefield->setTableName($table_name);
                }
                $approvefield->setinput_type($allapprovecolumns[$approvecolumn]['uitype']);
                $approvefield->setTranslatedModule('Approve');
                $approvefield->setPresence(0);

            }else if($fieldtype == 'tabdetailsfield'){
                $approvefield = new TabDetailToolFields();

                if($approvecolumn == "approvesubmittedtime"){
                    $approvefield->setTableName('tmp_approve');
                }else if($approvecolumn == "approvetime"){
                    $approvefield->setTableName($table_name);
                }else{
                    $approvefield->setTableName(!empty($allapprovecolumns[$approvecolumn]['tablename'])?:$table_name);
                }
                $approvefield->setinput_type($allapprovecolumns[$approvecolumn]['uitype']);
                if($approvecolumn == "approvetime"){
                    $approvefield->setTranslatedModule($module);
                }else{
                    $approvefield->setTranslatedModule('Approve');
                }
                $approvefield->setPresence(0);

            }
            $approvefield->setcolumnName($approvecolumn);
            $approvefield->setFieldName($approvecolumn);
            $approvefield->setfieldLabel($allapprovecolumns[$approvecolumn]['label']);
            $approvefield->settypeOfData($allapprovecolumns[$approvecolumn]['type']."~O");
            $approvefield->setuitType($allapprovecolumns[$approvecolumn]['uitype']);

            if($fieldtype == 'productfield' && $approvestatus == 3 && $approvecolumn == "approvesubmittedtime"){
                $modulefieldObj['approveby_datetime']=$approvefield;
            }else{
                $modulefieldObj[$approvecolumn]=$approvefield;
            }
        }
        // dump($modulefieldObj);

        return $modulefieldObj;
    }
    public function getModuleFields()
    {
		global $approvestatus;
        $modulefieldObj=parent::getModuleFields();
        //@edit:liushuai @date:2020-07-13 @reason: 审批中心查询优化：发起人（提交人）、发起时间（提交时间）、审批步骤（当前审批步骤）， 放在单据表里面（审批中心列头）
        $focus = CRMEntity::getInstance($this->field_module);
        $table_name = $focus->table_name;

        ////ls 20220825 BUG0055553 审批任务-已处理-设置列宽之后，重新设置查看范围，列宽就恢复默认了，没有记住设置
        if(empty($approvestatus)){
            $approvestatus = $_REQUEST['approvestatus'];
        }
        
        $approve_modulefields = $this->getApproveColumnsObj($approvestatus,'field');
		$modulefieldObj = array_merge($modulefieldObj,$approve_modulefields);
		$this->moduleFieldObjs = array_merge((array)$this->moduleFieldObjs,$approve_modulefields);

        return $modulefieldObj;
    }
//@edit:liushuai @date:2020-07-13 @reason: 1000895：审批中心查询优化：（审批中心基本查找对象里没有Approve_Field.php定义的字段对象，需要重载方法$this->fieldobj->getModuleAllPreseneceFields()）
    public function getModuleAllPreseneceFields()
    {
      return $this->getModuleFields();
    }
    public function getFieldInfoobjBykey($key,$value)
    {
        $modulefields=$this->getModuleFields();
        if($key=='fieldname')
        {
            return $modulefields[$value];
            
        }
       
    }
    public function getShowFieldLables()
    {
        $modulefields=$this->getModuleFields();
         foreach($modulefields as $fieldname=>$fieldinfo)
        {  
                if($fieldinfo->getPresence()==0 ||$fieldinfo->getPresence()==2)
                    $fieldlabels[$fieldname]=$fieldinfo->getFieldLabel();
            
             
        }
        return $fieldlabels;
    }
}

?>