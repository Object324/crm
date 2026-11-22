<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$function = $_REQUEST['function_name'];
$function = empty($function)?'index':$function;
$_REQUEST['diony'] = 'yes';
$obj = new CustomTablesListView();
$is_ajax = $_REQUEST['is_ajax'];
$obj->$function($is_ajax);

class CustomTablesListView
{
    public $CustomTablesActionsObj;
    public function __construct(){
        include globalStatic::$root_directory.'modules/CustomTables/CustomTablesActions.php';
        $this->CustomTablesActionsObj = new CustomTablesActions();
    }
    //列表页面
    public function index(){
        $this->CustomTablesActionsObj->smarty->assign("permit_print",isPermitted('CustomTables','Print'));//打印权限
        $this->CustomTablesActionsObj->smarty->assign("permit_export",isPermitted('CustomTables','Export'));//导出权限
        $this->CustomTablesActionsObj->smarty->assign('permit_create',isPermitted('CustomTables','Create'));//创建权限
        $this->CustomTablesActionsObj->smarty->assign('permit_allocate',isPermitted('CustomTables','Allocate'));//分配权限
        $this->CustomTablesActionsObj->smarty->assign('permit_delete',isPermitted('CustomTables','Delete'));//删除权限
        $this->CustomTablesActionsObj->smarty->display('CustomTables/index.tpl');
    }

    //获取列表数据
    public function getReportList()
    {
        $parent_id = $_REQUEST['parent_id'];
        $list = $this->CustomTablesActionsObj->getReportListByParentId($parent_id);
        ConvertTojsonString(1,['list'=>$list],'success');
    }


    public function getReportType(){
        $report_id = $_REQUEST['report_id'];
        $sql = "select report_type from ld_customtable where report_id=?";
        $res = $this->CustomTablesActionsObj->adb->pquery($sql,array($report_id));
        $nums = $this->CustomTablesActionsObj->adb->num_rows($res);
        if($nums>0){
            $report_type =  $this->CustomTablesActionsObj->adb->query_result($res,0,0);
            ConvertTojsonString(1,['report_type'=>$report_type],'success');die;
        }
        ConvertTojsonString(1,['report_type'=>''],'success');die;
    }
    
    //删除
    public function deleteReport(){
        //判断是否有删除权限
        if(isPermitted('ReportAnalysis','Delete')=='no'){
            $res = ['code'=>0,'msg'=>getFixedLabel('NoPermission')];
        }else{
            $report_id = $_REQUEST['reportid'];
            $res = $this->CustomTablesActionsObj->delete($report_id);

            //ls 2022-02-18 0050029: （https://81mis.com/kfbtest/index.php [^]）自定义报表“ 客户服务 ”已经删除了，但之前设置过得链接模块还在，可以打开
            $url = 'index.php?module=CustomTables&action=CustomTablesAjax&file=DetailView&function_name=index&isAjax=no&report_id='.$report_id;
            //删除菜单设置
            $selectSql = "select * from ld_linkmodulecustom where url =?";
            $selectRes = $this->CustomTablesActionsObj->adb->pquery($selectSql,array($url));
            $selectNums = $this->CustomTablesActionsObj->adb->num_rows($selectRes);
            if($selectNums>0){
                $linkmoduleId = $this->CustomTablesActionsObj->adb->query_result($selectRes,0,'id');
                //ld_parenttabrel
                $sql ='delete from ld_linkmodulecustom where url =?';
                $this->CustomTablesActionsObj->adb->pquery($sql,array($url));
                $sql2 ='delete from ld_parenttabrel where tabid =? and tab_tablename="ld_linkmodulecustom"';
                $this->CustomTablesActionsObj->adb->pquery($sql2,array($linkmoduleId));
                //移动端菜单
                $sqlMobile = "delete from ld_mobile_report_tab_rel where tabid =? and tab_tablename='ld_linkmodulecustom'";
                $this->CustomTablesActionsObj->adb->pquery($sqlMobile,array($linkmoduleId));

            }
        }
        ConvertTojsonString($res['code'],['res'=>$res['msg']],'success');
    }
    //统计图移动文件夹
    public function moveDir()
    {
        $report_id = $_REQUEST['report_id'];
        //编辑ld_customreport
        $sql = "update ld_customtable set parent_id=? where report_id=?";
        $this->CustomTablesActionsObj->adb->pquery($sql,[$_REQUEST['parent_id'],$report_id]);
        ConvertTojsonString(1,['id'=>$report_id],'success');
    }
    //保存文件夹数据
    public function saveFolder(){
        $report_id = $_REQUEST['report_id'];
        //基本信息
        if(empty($report_id)){
            //新增ld_customreport
            $sql = "insert into ld_customtable (report_name,description,parent_id,deleted,createdtime,smcreatorid,isfolder,`level`) values (?,?,?,?,?,?,?,?)";
            $this->CustomTablesActionsObj->adb->pquery($sql,[$_REQUEST['report_name'],$_REQUEST['description'],$_REQUEST['parent_id'],0,date('Y-m-d H:i:s',time()),$this->CustomTablesActionsObj->current_user->id,'yes',1]);
            $_REQUEST['report_id'] = $report_id = $this->CustomTablesActionsObj->adb->getLastInsertID();
        }else{
            //编辑ld_customreport
            $sql = "update ld_customtable set report_name=?,description=?,isfolder='yes',`level`=1 where report_id=?";
            $this->CustomTablesActionsObj->adb->pquery($sql,[$_REQUEST['report_name'],$_REQUEST['description'],$report_id]);
        }
        //默认给所有用户权限
        $permit_sql='insert into ld_custometable2user(report_id,userid)values(?,?)';
        $this->CustomTablesActionsObj->adb->pquery($permit_sql,array($report_id,'-1'));
        ConvertTojsonString(1,['id'=>$_REQUEST['report_id']],'success');
    }

    //保存分配权限数据
    public function saveCustomTable2user()
    {
        $owners = $_REQUEST['selectallocateid'];
        //radiotype适用范围  selectallocateid选中的用户id report_id 报表ID
        $reportid = $_REQUEST['report_id'];
        $approveallocatetype = $_REQUEST['radiotype'];
        if($owners == ''&&$approveallocatetype=='1'){ //这边设定为选择到按部门时会提示错误，所以选择到所有用户时就可以执行下面的语句，就可以给id赋值为：‘-1’，默认为所有用户了。
            echo '##WrongGroup##' ;die;
        }
        if($owners == ''&&$approveallocatetype=='2'){ //这边设定为选择到部分用户时会提示错误，所以选择到所有用户时就可以执行下面的语句，就可以给id赋值为：‘-1’，默认为所有用户了。
            echo '##WrongSelectedUser##';die;
        }
        //如果parent_id!=0 则批量分配这个文件夹下的所有统计图表
        $report_ids = [];
        $parent_id = $_REQUEST['parent_id'];//报表的parent_id 如是0 则是批量
        if($parent_id==0){
            $reports_sql = " select report_id from ld_customtable where parent_id=?";
            $reports_res = $this->CustomTablesActionsObj->adb->pquery($reports_sql,[$reportid]);
            $reports_nums = $this->CustomTablesActionsObj->adb->num_rows($reports_res);
            for($i=0;$i<$reports_nums;$i++){
                $report_ids[] = $this->CustomTablesActionsObj->adb->query_result($reports_res,$i,'report_id');
            }
        }
        $report_ids[] = $reportid;
        $owners = explode(",",$owners);
        foreach($report_ids as $report_id){
            $delsql = "delete  from  ld_customtable2user where report_id=?";
            $this->CustomTablesActionsObj->adb->pquery($delsql,array($report_id));
            $updatesql="update ld_customtable SET approveallocatetype=? where report_id=?";
            $this->CustomTablesActionsObj->adb->pquery($updatesql,array($approveallocatetype,$report_id));
            if($approveallocatetype=='0'){
                $sql='insert into ld_customtable2user(report_id,userid)values(?,?)';
                $this->CustomTablesActionsObj->adb->pquery($sql,array($report_id,'-1'));
            }elseif($approveallocatetype=='1'||$approveallocatetype=='2'){
                $sql='insert into ld_customtable2user(report_id,userid)values(?,?)';
                foreach($owners as $key=>$arr){
                    $this->CustomTablesActionsObj->adb->pquery($sql,array($report_id,$arr));
                }
            }
        }
        $_REQUEST['diony']='yes';
        ConvertTojsonString(1,array(),"success");
    }

    /**
     * 自定义统计表列表数据 上移下移 的保存
     */
    public function reSequence(){
        $data = $_REQUEST['data'];
        if(!empty($data)){
            foreach($data as $k=>$v){
                $update_sql = "update ld_customtable set `sequence`=? where report_id=?";
                $this->CustomTablesActionsObj->adb->pquery($update_sql,array($v['sequence'],$v['reportid']));
            }
        }
        ConvertTojsonString(1,array(),"success");
    }


}