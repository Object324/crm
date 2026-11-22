<?php
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once globalStatic::$root_directory.'modules/ReportAnalysis/ReportAnalysisActions.php';
$function = $_REQUEST['function_name'];
$function = empty($function)?'index':$function;
$_REQUEST['diony'] = 'yes';
 SqlSearchFilter($_REQUEST);
  
$obj = new ReportAnalysisListView();
$obj->$function();
class ReportAnalysisListView
{
    public $adb,$language;
    public $smarty;
    public $current_user;
    public $ReportAnalysisActionsObj;

    public function __construct()
    {
        global $adb, $languageType,$current_user;
        $this->adb = $adb;
        $this->language = $languageType;
        $this->current_user = $current_user;
        $this->smarty = new lingdangCRM_Smarty();
        $this->ReportAnalysisActionsObj = new ReportAnalysisActions();
    }
    //列表页面
    public function index()
    {
        //'Create','EditView','Delete','Allocate','Print','Export'
        $permit_arr = ['Create','EditView','Delete','Allocate','Print','Export'];
        $permit_info = [];
        foreach($permit_arr as $value){
            $permit_info['permit_'.$value] = isPermitted('ReportAnalysis',$value);
        }
        $list = $this->ReportAnalysisActionsObj->getReportListByParentId(-1,'RecentView');
        $nums=count($list);


        $this->smarty->assign("listtype",$this->ReportAnalysisActionsObj->listType);//js使用
        $this->smarty->assign("permit_info",json_encode($permit_info));//js使用
        $this->smarty->assign("permit_info_arr",$permit_info);//tpl使用
        $this->smarty->assign("LastReviewRecord",$nums);//tpl使用
        $this->smarty->display("ReportAnalysis/ListView.tpl");
    }
    public function setShowType(){
        //保存视图类型--列表视图list  分屏试图screen
        crm_load_class_file("cls_SaveUserChoosen",'modules/lingdang');
        $module = 'ReportAnalysis';
        $saveObj = new cls_SaveUserChoosen($module);
        $saveObj -> saveValue();
    }
    //获取列表数据
    public function getReportList()
    {
        $parent_id = $_REQUEST['parent_id'];
        $keyWords = $_REQUEST['keyWords'];
        $type='all';
        if(!empty($keyWords)){
            $type='report';
        }
        $list = $this->ReportAnalysisActionsObj->getReportListByParentId($parent_id,$type);
        $msg = getFixedLabel('SUCCESS');
        if(empty($list)){
            $msg = getFixedLabel('NOTFOUNDANYRECORD');
        }
        ConvertTojsonString(1, ['list' => $list], $msg);
    }
    /**
     * @return void
     * @throws Exception
     * 获取报表移动文件夹的文件夹列表数据
     */
    public function getAllFolder(){
        $analysisfolder_id = $_REQUEST['analysisfolder_id'];
        $options = $this->ReportAnalysisActionsObj->getAllFolderOptions($analysisfolder_id);
        ConvertTojsonString(1, ['options' => $options], 'success');
    }

    //文件夹排序弹框--只排文件夹
    public function sortReport(){
        $parent_id = $_REQUEST['parent_id'];

        $list = $this->ReportAnalysisActionsObj->getReportListByParentId($parent_id,'all');
        $this->smarty->assign('list',$list);
        $arr['title'] = getFixedLabel('SORT');
        $arr['oktext'] = getFixedLabel('SAVE');
        $arr['canceltext'] = getFixedLabel('CANCEL');
        $arr['content'] = $this->smarty->fetch('ReportAnalysis/SortReport.tpl');
        ConvertTojsonString(1,$arr,'success');
    }
    //保存文件夹排序--只排文件夹
    public function saveSortFolder()
    {
        $folderid_str = $_REQUEST['folderid_str'];
        $folderid_arr = explode(';',$folderid_str);

        foreach($folderid_arr as $k=>$v){
            if(!empty($v)){
                $report_info = explode('_',$v);
                $report_id = $report_info[0];
                $modulename = $report_info[1];
                $select_sql = "select 1 from ld_report_analysis2user where report_id=? and modulename=?";
                $select_res = $this->adb->pquery($select_sql,array($report_id,$modulename));
                $select_nums = $this->adb->num_rows($select_res);
                if($select_nums>0){
                    $sql = "update ld_report_analysis2user set `sequence`=$k  where report_id=? and modulename=? ";
                    $res = $this->adb->pquery($sql,array($report_id,$modulename));
                }else{
                    $sql = "insert into ld_report_analysis2user (report_id,modulename,`sequence`) values (?,?,?)  ";
                    $res = $this->adb->pquery($sql,array($report_id,$modulename,$k));
                }
            }
        }
        ConvertTojsonString(1,'','success');
    }
    //保存分配权限数据
    public function saveReportAnalysis2user()
    {
        $owners = $_REQUEST['selectallocateid'];
        //radiotype适用范围  selectallocateid选中的用户id report_id 报表ID
        $report_id = $_REQUEST['report_id'];
        $approveallocatetype = $_REQUEST['radiotype'];
        if($owners == ''&&$approveallocatetype=='1'){ //这边设定为选择到按部门时会提示错误，所以选择到所有用户时就可以执行下面的语句，就可以给id赋值为：‘-1’，默认为所有用户了。
            echo '##WrongGroup##' ;die;
        }
        if($owners == ''&&$approveallocatetype=='2'){ //这边设定为选择到部分用户时会提示错误，所以选择到所有用户时就可以执行下面的语句，就可以给id赋值为：‘-1’，默认为所有用户了。
            echo '##WrongSelectedUser##';die;
        }
        $modulename = $_REQUEST['modulename'];//报表所属来源模块 OftenUseReport常用报表 报表库 综合报表 自定义统计图 自定义统计表
        //$modulename==ReportAnalysis 则批量分配这个文件夹下的所有报表  //文件夹不分配 所有人都可看到所有文件夹
        if($modulename=='ReportAnalysis'){
            $allfolder = $this->ReportAnalysisActionsObj->getChildFolder($report_id,$allfolder);
            $allfolderids = [];
            if(!empty($allfolder)){
                $allfolderids = _array_column($allfolder,'report_id');
            }
            $allfolderids[] = $report_id;
            $allreports = $this->ReportAnalysisActionsObj->getReportListByParentId($allfolderids,'report');
            //文件夹的分配信息也记录一下
            foreach($allfolderids as $tmpreport_id){
                $allreports[] = ['report_id'=>$tmpreport_id,'modulename'=>'ReportAnalysis'];
                /*$updatesql="update ld_report_analysis_folder SET approveallocatetype=? where analysisfolder_id=?";
                $this->adb->pquery($updatesql,array($approveallocatetype,$tmpreport_id));*/
            }
        }else{
            $allreports[] = ['report_id'=>$report_id,'modulename'=>$modulename];
        }
        foreach($allreports as $reportinfo){
            $tablename = '';
            $tableindex = '';
            switch ($reportinfo['modulename']){
                case 'ReportAnalysis':
                    $tablename = 'ld_report_analysis_folder';$tableindex='analysisfolder_id';
                    break;//常用报表
                case 'OftenUseReport':
                    $tablename = 'ld_usereport';$tableindex='usereportid';
                    break;//常用报表
                case 'Customreport':
                    $tablename = 'ld_customreport_info';$tableindex='report_id';
                    break;//报表库
                case 'Comprehensivereport':
                    $tablename = 'ld_comprehensivereport';$tableindex='id';
                    break;//综合报表
                case 'CustomEcharts':
                    $tablename = 'ld_customreport';$tableindex='report_id';
                    break;//自定义统计图
                case 'CustomTables':
                    $tablename = 'ld_customtable';$tableindex='report_id';
                    break;//自定义报表
            }
            $updatesql="update $tablename SET approveallocatetype=? where ".$tableindex."=?";
            $this->adb->pquery($updatesql,array($approveallocatetype,$reportinfo['report_id']));

            $select_sql = "select 1 from ld_report_analysis2user where report_id=? and modulename=?";
            $select_res = $this->adb->pquery($select_sql,array($report_id,$reportinfo['modulename']));
            $select_nums = $this->adb->num_rows($select_res);
            if($select_nums<=0){
                $insertsql = "insert into ld_report_analysis2user (report_id,modulename,`sequence`) values (?,?,?)  ";
                $res = $this->adb->pquery($insertsql,array($reportinfo['report_id'],$reportinfo['modulename'],0));
            }
            if($approveallocatetype=='0'){
                $sql='update ld_report_analysis2user set userid=? where report_id=? and modulename=? ';
                $this->adb->pquery($sql,array('-1',$reportinfo['report_id'],$reportinfo['modulename']));
            }elseif($approveallocatetype=='1'||$approveallocatetype=='2'){
                $sql='update ld_report_analysis2user set userid=? where report_id=? and modulename=? ';
                $this->adb->pquery($sql,array($owners,$reportinfo['report_id'],$reportinfo['modulename']));
            }
        }
        $list = $this->ReportAnalysisActionsObj->getReportInfo($modulename,$_REQUEST['report_id']);
        if(isset($list[0])){
            $reportinfo = $list[0];
            $reportinfo['show'] = 'yes';
        }else{
            $reportinfo = ['report_id'=>$report_id,'modulename'=>$modulename,'show'=>'no'];
        }
        //$reportinfo = isset($list[0])?$list[0]:[];
        $_REQUEST['diony']='yes';
        ConvertTojsonString(1,array('reportinfo'=>$reportinfo),"success");
    }

    public function moveDir()
    {
        $report_id = $_REQUEST['report_id'];
        $analysisfolder_id = $_REQUEST['analysisfolder_id'];
        $modulename = $_REQUEST['modulename'];
        $pidfieldname = 'analysisfolder_id';
        switch ($modulename) {
            case 'ReportAnalysis':
                $tablename = 'ld_report_analysis_folder';
                $tableindex = 'analysisfolder_id';
                $pidfieldname = 'parent_id';
                break;//常用报表
            case 'OftenUseReport':
                $tablename = 'ld_usereport';
                $tableindex = 'usereportid';
                break;//常用报表
            case 'Customreport':
                $tablename = 'ld_customreport_info';
                $tableindex = 'report_id';
                break;//报表库
            case 'Comprehensivereport':
                $tablename = 'ld_comprehensivereport';
                $tableindex = 'id';
                break;//综合报表
            case 'CustomEcharts':
                $tablename = 'ld_customreport';
                $tableindex = 'report_id';
                break;//自定义统计图
            case 'CustomTables':
                $tablename = 'ld_customtable';
                $tableindex = 'report_id';
                break;//自定义报表
        }
        //编辑ld_customreport
        $sql = "update $tablename set $pidfieldname=? where $tableindex=?";
        $this->adb->pquery($sql,[$analysisfolder_id,$report_id]);
        ConvertTojsonString(1,['id'=>$report_id],'success');
    }

    //wyt 221129 XUQIU1000911 报表分析，增加“最近浏览”文件夹
    //浏览历史记录到数据库中
    public function LastViewRecord(){
        global $current_user,$adb;
        $modulename=$_REQUEST['modulename'];
        $reportid=$_REQUEST['reportid'];
        $intime=date("Y-m-d H:i:s");
        $userid=$current_user->id;

        $sql="select browse_id from ld_report_analysis_folder_log where reportid=? and module=? and userid=?";
        $result=$adb->pquery($sql,[$reportid,$modulename,$userid]);
        $nums=$adb->num_rows($result);
        $browse_id=$adb->query_result($result,0,'browse_id');
        if($nums==0){
            $sql="insert into ld_report_analysis_folder_log(reportid,module,userid,view_time) value (?,?,?,?)";
            $adb->pquery($sql,array($reportid,$modulename,$userid,$intime));
        }else{
            $sql="update ld_report_analysis_folder_log set view_time=?,visible='yes' where browse_id=?";
            $adb->pquery($sql,array($intime,$browse_id));
        }
		//zxm 20240523 只显示前10条
        $updatesql = "UPDATE ld_report_analysis_folder_log
            SET visible = 'no'
            WHERE browse_id IN (
                SELECT browse_id
                FROM (
                    SELECT browse_id
                    FROM ld_report_analysis_folder_log where userid=?
                    ORDER BY view_time desc 
                    LIMIT 10, 18446744073709551615
                ) AS subquery
            );";
        $adb->pquery($updatesql,array($userid));
        ConvertTojsonString(1,array(),'success');
    }

    //报表浏览历史记录取消显示
    public function CancelDisplayReport(){
        global $current_user,$adb;
        $modulename=$_REQUEST['modulename'];
        $reportid=$_REQUEST['reportid'];
        $userid=$current_user->id;

        $sql="update ld_report_analysis_folder_log set visible='no' where reportid=$reportid and module='$modulename' and userid=$userid";
        $adb->pquery($sql,array());
        ConvertTojsonString(1,array(),'success');

    }

}