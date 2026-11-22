<?php
/*
审批结束后操作单据
*/
class ApproveFinished
{

    public $crmid ;
    public $module;
    public $editallfield;
    public $allowedit_finished_arr;
    public static function getInstance($module,$crmid)
    {
        static  $static_approvefinished_arrobj;
        if(is_array($static_approvefinished_arrobj)&&array_key_exists($crmid,$static_approvefinished_arrobj))
        {
            return $static_approvefinished_arrobj[$crmid];
        }
        $static_approvefinished_arrobj=[];
        $static_approvefinished_arrobj[$crmid]=new ApproveFinished($module,$crmid);
        return $static_approvefinished_arrobj[$crmid];

    }
    public function  __construct($module,$crmid)
    {
        $this->module=$module;
        $this->crmid=$crmid;
    }
    //duan 20230907 判断当前单据审批结束后能否编辑所有字段
    public function isEditAllFiled(){
        if(!isset($this->editallfield)){
            $this->getAllowEditField();
        }
        return $this->editallfield;
    }
    public function getAllowEditField()
    {
        global $adb;
        if(is_array($this->allowedit_finished_arr))
        {
            return $this->allowedit_finished_arr;
        }
        $sql='select ld_approve_finishededitfield.* from ld_approve_finishededitfield
             inner join  (select approveid from ld_approvelog where crmid=? order by id desc limit 1 ) 
              as tmp on tmp.approveid=ld_approve_finishededitfield.approveid ';
        $result=$adb->pquery($sql,array($this->crmid));
        $rows=$adb->num_rows($result);
        $arr=[];
        for($i=0;$i<$rows;$i++)
        {
            $columns=$adb->query_result($result,$i,'columns');
            $arr[$columns]='';

        }
        $this->editallfield = 'no';
        if($rows<=0)
        {
            $this->editallfield = 'yes';
            $focus=CRMEntity::getInstance($this->module);

            $main_allFields=$focus->fieldobj->getModuleFields();
            foreach($main_allFields as $fieldname=>$fieldinfo)
            {
                if($fieldinfo->getSaveDataBase()=='no')
                    continue;
                if($fieldinfo->get_allowedit()=='no')
                    continue;

                $tablename=$fieldinfo->getTableName();
                $columnname=$fieldinfo->getColumnName();
                $columns="$tablename:$columnname:$this->module";

                $arr[$columns]='';


            }
            if(get_file_address($this->module,'ProductDetails')&&$this->module!='ServiceCharge')
            {
                $detail_allFields=$focus->detailfieldobj->getModuleFields();

                foreach($detail_allFields as $fieldname=>$fieldinfo)
                {
                    if($fieldinfo->getSaveDataBase()=='no')
                        continue;
                    if($fieldinfo->getedit_permission()=='1')
                        continue;
                    $fieldid=$fieldinfo->getFieldid();
                    $tablename = $fieldinfo->getTableName();

                    if($fieldname=='productname')
                        $fieldid=0;
                    if($tablename == 'ld_products' && $fieldid>0)
                        continue;
                    $tablename=$fieldinfo->getTableName();
                    $columnname=$fieldinfo->getColumnName();
                    $columns="$tablename:$columnname:$this->module";

                    $arr[$columns]='';


                }
            }
            else if(get_file_address($this->module,$this->module.'DetailFieldsHtml'))
            {
                $detail_allFields=$focus->detailfieldobj->getModuleFields();
                foreach($detail_allFields as $fieldname=>$fieldinfo)
                {
                    if($fieldinfo->getSaveDataBase()=='no')
                        continue;
                    if($fieldinfo->getedit_permission()=='1')
                        continue;

                    $tablename=$fieldinfo->getTableName();
                    $columnname=$fieldinfo->getColumnName();
                    $columns="$tablename:$columnname:$this->module";

                    $arr[$columns]='';


                }
            }

        }
        $this->allowedit_finished_arr=$arr;
        return $arr;

    }
}


?>