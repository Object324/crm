<?php

/**
 * Created by PhpStorm.
 * User: gyq
 * Date: 2017/3/8 0008
 * Time: 下午 5:21
 */
crm_load_class_file('cls_Approve_countListView','modules/Approve');//gyqCom0309
class cls_Approve_countListViewMC extends cls_Approve_countListView
{
    public $tabpagetype;//0:待处理 1:已处理 2:近30天
    //editor:gyq reason:下面几个方法移动端最近30天需要 date:20170302
    //获取移动端审批模块
    public function getapprovemodule(){

    }
    //获取审批中心 - 单据总数量
    public function getapprovenum(){
        $approvelist = $this->getapprovelist();
        $count = 0;
        foreach($approvelist as $val){
            $count += $val['num'];
        }
        return $count;
    }
    //获取审批中心 - 审批模块单据数量
    public function getapprovelist(){
       
        if(empty( $this->tabpagetype) || $this->tabpagetype==1 || $this->tabpagetype==3 || $this->tabpagetype==4){
            $approvemodule = implode('\',\'',$this->getapprovemodule());//gyqCom0302
            $this->approvemodule = ' AND setype IN (\''.$approvemodule.'\') ';
            return parent::getapprovelist();
        }else{
            return $this->getList30();
        }
    }
    // 近30天
    protected function getList30(){
        global $adb,$current_user;
        //待处理
        $sql = $this->getapprovalof_sql() . $this->getapprove_where() . $this->getapprove_groupby();
        $result=$adb->pquery($sql,array($current_user->id));
        $num_rows=$adb->num_rows($result);
        for($i=0;$i<$num_rows;$i++){
            $moduleid=$adb->query_result($result,$i,'moduleid');
            $module=$adb->query_result($result,$i,'setype');
            $approveinfo[$module][$moduleid]=$moduleid;
        }
        //已处理
        $sql = $this->getapproved_sql() . $this->getapprove_where() . $this->getapprove_groupby();
        $result=$adb->pquery($sql,array($current_user->id,$current_user->id));
        $num_rows=$adb->num_rows($result);
        for($i=0;$i<$num_rows;$i++){
            $moduleid=$adb->query_result($result,$i,'moduleid');
            $module=$adb->query_result($result,$i,'setype');
            $approveinfo[$module][$moduleid]=$moduleid;
        }
        foreach($approveinfo as $module => $mod_array){
            $submitapproveinfo[$module] = count($mod_array);
        }
        //合并待处理和已处理的数据
        /*foreach($approveinfo as $module => $num){
            if(array_key_exists($module,$submitapproveinfo)){
                $submitapproveinfo[$module] += $num;
            }else{
                $submitapproveinfo[$module] = $num;
            }
        }*/
        //重新排序 高 -> 低
        arsort($submitapproveinfo);

        foreach($submitapproveinfo as $module => $num){
            $data[] = array(
                'module' => $module,
                'num' => $num,
            );
        }
        return $data;
    }

    public function getapprove_where(){
        $startdate = date("Y-m-d",strtotime("$start_date -30 days")).' 00:00:00';
        $enddate = Date('Y',time()).'-'.Date('m',time()).'-'.Date('t',time()).' 23:59:59';
        $range = ' and t1.createdtime between \''. $startdate.'\' and \''.$enddate.'\' ';
        return $range;
    }
    //待处理
    public function getapprovalof_sql(){
        $sql = 'select setype,moduleid from '.$this->getapprovemodule_sql().'
			inner join ld_approvelog t1 on t1.crmid=tmp_module.moduleid
			inner join (select max(id) max_id,crmid from ld_approvelog GROUP BY crmid) as tmp
			on t1.id=tmp.max_id and tmp.crmid=t1.crmid
			where t1.approveresult=1 and find_in_set(?, t1.nextstepapproveby)
			 and tmp_module.deleted=0 ';
        return $sql;
    }

    //已处理
    public function getapproved_sql(){
        $sql = 'select setype,moduleid from '.$this->getapprovemodule_sql().'
			inner join ld_approvelog t1 on t1.crmid=tmp_module.moduleid
			inner join (select max(id) max_id,crmid from ld_approvelog where ld_approvelog.approved_by=? GROUP BY crmid) as tmp
			on t1.id=tmp.max_id and tmp.crmid=t1.crmid
			where t1.approved_by=? and t1.stepid>0
			and tmp_module.deleted=0 ';
        return $sql;
    }

    public function getapprove_groupby(){
        // return 'GROUP BY setype ORDER BY num desc';
        return '';
    }

    public function getapprovemodule_sql(){
        $approvemodules= $this->getapprovemodule();
        foreach($approvemodules as $modulename){
            $focus=CRMEntity::getInstance($modulename);
            if($modulename=='Calendar'||$modulename=='Events')
                $module_sqls[]=" select $focus->table_index as moduleid ,deleted,'$modulename' as setype from $focus->table_name  where  activitytype != 'Emails'    ";
            else
                $module_sqls[]=" select $focus->table_index as moduleid ,deleted,'$modulename' as setype from $focus->table_name   ";
        }
        $module_sql=implode(' union all ',$module_sqls);
        $module_sql=' ('.$module_sql.' ) as tmp_module ' ;

        return $module_sql;
    }
}