<?php
global $root_directory,$current_user;
global $languageType;
global $adb;

//zkt 20220610 BUG0052709（http://1.116.35.23:85/crm/index.php）项目甘特图，管理员点击甘特图，提示没有项目实施模块的权限
$userobj = CRMEntity::getInstance('Users');
$current_user = $userobj->retrieveCurrentUserInfoFromFile($current_user->id);
require_once( $root_directory.'Smarty_setup.php');
//zkt 20220330 0050600: （https://61mis.com/WX/kh40903 [^]）客户问题（刘家云），客户001账套，去掉“项目甘特图”模块
if(isPermitted('Project')!='yes')
{
    echo '你没有'.getTranstab('Project').'模块的权限';
    
    exit();
}
//获取项目列表
$adb=PearDatabase::getInstance();
if(isset($_REQUEST['mode'])&&$_REQUEST['mode'] == 'getaccountinfo')
{
    $sql = "select ld_account.accountid as accountid,ld_account.accountname as accountname,ld_users.last_name as xm_owner from ld_account
            LEFT JOIN ld_project on ld_project.accountid=ld_account.accountid
            LEFT JOIN ld_users  on ld_project.smownerid = ld_users.id
            where ld_project.projectid=?";
    $result = $adb->pquery($sql,array($_REQUEST['projectid']));
    $rows = $adb->num_rows($result);
    if($rows>0){
        $accountid = $adb->query_result($result,0,'accountid');
        $accountname = $adb->query_result($result,0,'accountname');
        $xm_owner = $adb->query_result($result,0,'xm_owner');
    }
    $_REQUEST['diony'] = 'diony';
    ConvertTojsonString(1,array('accountid'=>$accountid,'accountname'=>$accountname,'xm_owner'=>$xm_owner),'success');
    
}
//项目立项详细信息跳转
$ischoseproject = 'yes';
if(isset($_REQUEST['record'])){
    $_REQUEST['projectid'] = $_REQUEST['record'];
    $ischoseproject = 'no';
}

if(isset($_REQUEST['projectid']))
{
    $selectedprojectid = $_REQUEST['projectid'];
}
else{
    $selectedprojectid = 0;
}
$fieldobj = Field::getInstance('ProjectTask',$adb);
$fieldinfo= $fieldobj->getFieldInfoobjBykey("columnname",'projecttasknameseq');
$hasprojecttasknameseq = false;
if(!empty($fieldinfo))
{
    $hasprojecttasknameseq = true;
    $selectfield = "a.projecttasknameseq as projecttasknameseq,SUBSTRING_INDEX(projecttasknameseq,'.','1')+0 AS projecttasknameseqint,
	SUBSTRING_INDEX(SUBSTRING_INDEX(projecttasknameseq,'.',-(length(projecttasknameseq)-length(replace(projecttasknameseq,'.','')))),'.','1')+0 AS projecttasknameseqint2,
	SUBSTRING_INDEX(SUBSTRING_INDEX(projecttasknameseq,'.',-(length(projecttasknameseq)-length(replace(projecttasknameseq,'.',''))-1)),'.','1')+0 AS projecttasknameseqint3,";
    $ordersql = 'projecttasknameseqint,projecttasknameseqint2,projecttasknameseqint3,CONVERT(a.projecttasknameseq  USING GBK),';
}


$versiontrade=getVersionTradeInfo();
$thisaccount = $versiontrade['account'];

if($thisaccount == 'DingXiangKeJi')
{
	$sql = "
	SELECT 
		a.projecttaskid as projecttaskid,$selectfield
		a.projecttaskname as projecttaskname,
		a.projecttaskprogress as projecttaskprogress,
		v.last_name as xm_owner,
		u.last_name as taskowner,
		a.startdate as jh_startdate,
		a.enddate as jh_enddate,
		f.cf_5060 as sj_startdate,
		a.actualenddate as sj_enddate
	FROM ld_projecttask a
	LEFT JOIN ld_projecttaskcf f ON f.projecttaskid=a.projecttaskid
	LEFT JOIN ld_project b ON b.projectid=a.projectid
	LEFT JOIN ld_users u ON u.id=a.smownerid
	LEFT JOIN ld_users v ON v.id=b.smownerid
	LEFT JOIN (
		SELECT
			a.projecttaskid,
			MIN(a.startdate) AS startdate,
			MAX(a.enddate) AS enddate
		FROM ld_projectprogress a
		WHERE a.deleted=0
			AND a.approvestatus<>'已拒绝'
			AND a.projecttaskid>0
		GROUP BY a.projecttaskid
	) c ON c.projecttaskid=a.projecttaskid
	WHERE a.deleted=0
		AND a.approvestatus<>'已拒绝'
		AND a.projecttaskid>0
		AND a.projectid = $selectedprojectid
	ORDER BY $ordersql a.createdtime,CONVERT(b.projectname USING GBK);
	";
}
else{
	$sql = "
	SELECT 
		a.projecttaskid as projecttaskid,$selectfield
		a.projecttaskname as projecttaskname,
		a.projecttaskprogress as projecttaskprogress,
		v.last_name as xm_owner,
		u.last_name as taskowner,
		a.startdate as jh_startdate,
		a.enddate as jh_enddate,
		c.startdate as sj_startdate,
		c.enddate as sj_enddate
	FROM ld_projecttask as a
	LEFT JOIN ld_project b ON b.projectid=a.projectid
	LEFT JOIN ld_users u ON u.id=a.smownerid
	LEFT JOIN ld_users v ON v.id=b.smownerid
	LEFT JOIN (
		SELECT
			a.projecttaskid,
			MIN(a.startdate) AS startdate,
			MAX(a.enddate) AS enddate
		FROM ld_projectprogress a
		WHERE a.deleted=0
			AND a.approvestatus<>'已拒绝'
			AND a.projecttaskid>0
		GROUP BY a.projecttaskid
	) c ON c.projecttaskid=a.projecttaskid
	WHERE a.deleted=0
		AND a.approvestatus<>'已拒绝'
		AND a.projecttaskid>0
		AND a.projectid = $selectedprojectid
	ORDER BY $ordersql a.createdtime,CONVERT(b.projectname USING GBK);
	";
}



$result = $adb->pquery($sql,array());
$rows = $adb->num_rows($result);
//获取当前时间
$datetoday = date('Y-m-d',time());
$ganttData = array();
//所有任务的计划开始时间和计划完成时间是否全部有值的标志
$jhdateshowflag = true;
if($rows>0)
{
    for($i = 0 ; $i<$rows ; $i++)
    {
        $projecttaskid = $adb->query_result($result,$i,'projecttaskid');
        $projecttaskname = $adb->query_result($result,$i,'projecttaskname');
        $projecttaskprogress = $adb->query_result($result,$i,'projecttaskprogress');
        if($hasprojecttasknameseq){
            $projecttasknameseq = $adb->query_result($result,$i,'projecttasknameseq');
            $projecttasknameseq = str_replace(',','.',$projecttasknameseq);
            $projecttasknameseq = str_replace('。','.',$projecttasknameseq);
            if(strpos($projecttasknameseq, '.')!==false){
                $projecttaskname = '&nbsp;&nbsp;&nbsp;&nbsp;'.$projecttasknameseq.'&nbsp;'.$projecttaskname;
            }
            else{
                $projecttaskname = $projecttasknameseq.'&nbsp;'.$projecttaskname;
            }
        }
        $projecttaskname = '&nbsp;'.$projecttaskname;
        
        $taskowner = $adb->query_result($result,$i,'taskowner');
        $jh_startdate = $adb->query_result($result,$i,'jh_startdate');
        $jh_enddate = $adb->query_result($result,$i,'jh_enddate');
        $sj_startdate = $adb->query_result($result,$i,'sj_startdate');
        $sj_enddate = $adb->query_result($result,$i,'sj_enddate');
        if($jh_startdate==''||$jh_enddate==''){
            $jhdateshowflag = false;
        }
        
        $ganttarr = array();
        $ganttarr['id'] = $projecttaskid;
        
        $taskstatus = '';
        $sj_startstr = '';
        $sj_endstr = '';
        $color = '238, 242, 254';  //计划时间颜色
        if(empty($sj_startdate)){
            if(time()<=strtotime($jh_startdate)){//待开始--按期
                $taskstatus = getFixedLabel('SCHEDULED').'--'.getFixedLabel('ONTIME');
                $color = '197, 206, 252';
            }
            else{
                $taskstatus = getFixedLabel('SCHEDULED').'--'.getFixedLabel('OVERDUE');
                $color = '157, 107, 204';
            }
            $sj_startdate = $jh_startdate;
            $sj_enddate = $jh_startdate;
        }
        else if (empty($sj_enddate)){//进行中
            if(time()<=strtotime($jh_enddate)){//进行中--按期
                $taskstatus = getFixedLabel('INPROGRESS').'--'.getFixedLabel('ONTIME');
                $color = '212, 206, 254';
            }
            else{//进行中--超期
                $taskstatus = getFixedLabel('INPROGRESS').'--'.getFixedLabel('OVERDUE');
                $color = '209, 181, 239';
            }
            $sj_startstr = date('Y-m-d',strtotime($sj_startdate));
            $sj_enddate = $datetoday;
        }
        else{
            if(strtotime($sj_enddate)<=strtotime($jh_enddate)){//已完成--按期
                $taskstatus = getFixedLabel('COMPLETED').'--'.getFixedLabel('ONTIME');
                $color = '97, 128, 237';
            }
            else{
                $taskstatus = getFixedLabel('COMPLETED').'--'.getFixedLabel('OVERDUE');
                $color = '245, 109, 121';
            }
            $sj_startstr = date('Y-m-d',strtotime($sj_startdate));
            $sj_endstr = date('Y-m-d',strtotime($sj_enddate));
        }
        $ganttarr['name'] = array('taskname'=>$projecttaskname,'taskowner'=>$taskowner,'taskstatus'=>$taskstatus,'sjprogress'=>$projecttaskprogress);
        $ganttarr['series'][] = array(
                'name'=>array('contrast'=>getFixedLabel('PLANS'),'startstr'=>date('Y-m-d',strtotime($jh_startdate)),'endstr'=>date('Y-m-d',strtotime($jh_enddate))),
                'start'=>$jh_startdate,
                'end'=>$jh_enddate,
                'color'=>'rgb(238, 242, 254)',
        );
        $ganttarr['series'][] = array(
                    'name'=>array('contrast'=>getFixedLabel('CompletionProgress'),'startstr'=>$sj_startstr,'endstr'=>$sj_endstr),
                    'start'=>$sj_startdate,
                    'end'=>$sj_enddate,
                    'color'=>'rgb('.$color.')',
        );
        $ganttData[]=$ganttarr;
    }
}
else{
    $jhdateshowflag = false;
    if($languageType=='zh'){
        $jhdatenoshowstr = '未获取到'.getTranstab('Project').'对应的'.getTranstab('ProjectTask').'信息！';
    }else{
        $jhdatenoshowstr = getFixedLabel('UnableToObtain').' '.getTranstab('ProjectTask').' '.getTranstab('INFORMATION').' '.getFixedLabel('CorrespondingTo').' '.getTranstab('Project').'!';
    }
}


$headerarr = array(
            'spanrow'=>array('taskname','taskowner','taskstatus'),
            'row'=>array('contrast','startstr','endstr'),
            'rowlable'=>array(
                    'taskname'=> getFixedLabel('LBL_AUTOMATICTASK_NAME'),
                    'taskowner'=> getFixedLabel('TASK').getFixedLabel('ASSIGNEDTO'),
                    'taskstatus'=> getFixedLabel('Orderstatus2'),
                    'contrast'=> getFixedLabel('Contrast'),
                    'startstr'=> getFixedLabel('CallStartTime'),
                    'endstr'=> getFixedLabel('EndTime'),
                    )
        );
//任务进度
$prjecttaskfieldobj = Field::getInstance('ProjectTask',$adb);
$prjectfieldinfo= $prjecttaskfieldobj->getFieldInfoobjBykey("columnname",'projecttaskprogress');
if(!empty($prjectfieldinfo)){
    $headerarr['rowlable'] = array(
                    'taskname'=> getFixedLabel('LBL_AUTOMATICTASK_NAME'),
                    'taskowner'=> getFixedLabel('TASK').' '.getFixedLabel('ASSIGNEDTO'),
                    'taskstatus'=> getFixedLabel('Orderstatus2'),
                    'sjprogress'=> getFixedLabel('Actual').' '.getFixedLabel('PROGRESS'),
                    'contrast'=> getFixedLabel('Contrast'),
                    'startstr'=> getFixedLabel('CallStartTime'),
                    'endstr'=> getFixedLabel('EndTime'),
                    );
}


$ganttDatatojs = ldcrm_json_encode($ganttData);//甘特图数据
$headerarrtojs = ldcrm_json_encode($headerarr);
//获取rgb对应十六进制颜色
function RGBToHex($rgb){
    $regexp = "/^rgb\(([0-9]{0,3})\,\s*([0-9]{0,3})\,\s*([0-9]{0,3})\)/";
    $re = preg_match($regexp, $rgb, $match);
    $re = array_shift($match);
    $hexColor = "#";
    $hex = array('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
    for ($i = 0; $i < 3; $i++) {
      $r = null;
      $c = $match[$i];
      $hexAr = array();
      while ($c > 16) {
        $r = $c % 16;
        $c = ($c / 16) >> 0;
        array_push($hexAr, $hex[$r]);
      }
      array_push($hexAr, $hex[$c]);
      $ret = array_reverse($hexAr);
      $item = implode('', $ret);
      $item = str_pad($item, 2, '0', STR_PAD_LEFT);
      $hexColor .= $item;
    }
    return $hexColor;
}


$smarty = new lingdangCRM_Smarty;

//获取项目信息
//zkt 20220712 BUG0053826https://www.51mis.com/hy/ty0608/）项目甘特图中-设备安装项目-的实际结束时间不显示
$result = $adb->pquery("select 
	a.projectid,
	a.projectname,
	a.project_no,
	a.projectstatus,
	a.completetask,
    a.accountid,
    b.accountname,
	v.last_name AS xm_owner,
(SELECT DATE_FORMAT(MIN(startdate),'%Y年%m月%d日') FROM ld_projecttask WHERE deleted=0 AND approvestatus<>'已拒绝' AND projectid=a.projectid) AS jh_startdate,
	(SELECT DATE_FORMAT(MAX(enddate),'%Y年%m月%d日') FROM ld_projecttask WHERE deleted=0 AND approvestatus<>'已拒绝' AND projectid=a.projectid) AS jh_endate,
	(SELECT DATE_FORMAT(MIN(startdate),'%Y年%m月%d日') FROM ld_projectprogress WHERE deleted=0 AND approvestatus<>'已拒绝' AND projectid=a.projectid AND projecttaskid>0) AS sj_startdate,
	CASE WHEN a.projectstatus='已完成' or a.projectstatus='项目验收' THEN (SELECT DATE_FORMAT(MAX(enddate),'%Y年%m月%d日') FROM ld_projectprogress WHERE deleted=0 AND approvestatus<>'已拒绝' AND projectid=a.projectid AND projecttaskid>0) ELSE NULL END AS sj_endate
from ld_project a
LEFT JOIN ld_account b ON b.accountid=a.accountid
LEFT JOIN ld_users v ON v.id=a.smownerid
where projectid = ?",array($selectedprojectid));
$rows = $adb->num_rows($result);
$selectedprojectinfo = array();
if($rows>0)
{
    $selectedprojectinfo = array(
                'projectid'=>$adb->query_result($result,0,'projectid'),
                'projectno'=>$adb->query_result($result,0,'project_no'),
                'projectname'=>$adb->query_result($result,0,'projectname'),
                'projectstatus'=>$adb->query_result($result,0,'projectstatus'),
                'completetask'=>$adb->query_result($result,0,'completetask'),
                'accountid'=>$adb->query_result($result,0,'accountid'),
                'accountname'=>$adb->query_result($result,0,'accountname'),
                'xm_owner'=>$adb->query_result($result,0,'xm_owner'),
                'jh_startdate'=>$adb->query_result($result,0,'jh_startdate'),
                'jh_endate'=>$adb->query_result($result,0,'jh_endate'),
                'sj_startdate'=>$adb->query_result($result,0,'sj_startdate'),
                'sj_endate'=>$adb->query_result($result,0,'sj_endate'),
            );
}
$fieldlabels = array();
//客户名称
$prjecttaskfieldobj = Field::getInstance('ProjectTask',$adb);
$prjectfieldinfo= $prjecttaskfieldobj->getFieldInfoobjBykey("columnname",'accountid');
if(!empty($prjectfieldinfo)){
    $fieldlabels['accountid'] = $prjectfieldinfo->getfieldLabel('zh');
}
else{
    $fieldlabels['accountid'] = '客户名称';
}
//项目名称
$prjectfieldinfo= $prjecttaskfieldobj->getFieldInfoobjBykey("columnname",'projectid');
if(!empty($prjectfieldinfo)){
    $fieldlabels['projectid'] = $prjectfieldinfo->getfieldLabel('zh');
}
else{
    $fieldlabels['projectid'] = '项目名称';
}

//项目对应派工单开始日期、截止日期存在空值时无法显示甘特图
//开始日期
$prjectfieldinfo= $prjecttaskfieldobj->getFieldInfoobjBykey("columnname",'startdate');
if(!empty($prjectfieldinfo)){
    $startdatefieldlabel = $prjectfieldinfo->getfieldLabel('zh');
}
else{
    $startdatefieldlabel = '开始日期';
}
//截止日期
$prjectfieldinfo= $prjecttaskfieldobj->getFieldInfoobjBykey("columnname",'enddate');
if(!empty($prjectfieldinfo)){
    $enddatefieldlabel = $prjectfieldinfo->getfieldLabel('zh');
}
else{
    $enddatefieldlabel = '截止日期';
}
if($jhdateshowflag == false && empty($jhdatenoshowstr))
    $jhdatenoshowstr = '该'.getTranstab('Project').'对应'.getTranstab('ProjectTask').'的'.$startdatefieldlabel.'、'.$enddatefieldlabel.'存在空值，不能显示甘特图！';
$smarty->assign('jhdateshowflag',$jhdateshowflag);//
$smarty->assign('jhdatenoshowstr',$jhdatenoshowstr);

$prjectfieldobj = Field::getInstance('Project',$adb);
$projectcolnamearray = array('project_no'=>'项目编号','projectname'=>'项目名称','smownerid'=>'项目负责人','projectstatus'=>'项目状态','progress'=>'已完成进度');
foreach($projectcolnamearray as $columnname => $fieldlabel)
{
    
    $prjectfieldinfo= $prjectfieldobj->getFieldInfoobjBykey("columnname",$columnname);

    if(!empty($prjectfieldinfo)){
        $fieldlabels[$columnname] = $prjectfieldinfo->getfieldLabel('zh');
    }
    else{
        $fieldlabels[$columnname] = $fieldlabel;
    }
}
//
$smarty->assign('fieldlabels',$fieldlabels);
$smarty->assign('selectedprojectid',$selectedprojectid);
$smarty->assign('projectinfo',$selectedprojectinfo);
$smarty->assign('ischoseproject',$ischoseproject);
$smarty->assign('TIMENOW',date('Y年m月d日',time()));
$smarty->assign('LANUGAGETYPE',$languageType);
$bodyhtml = $smarty->fetch("include/ganttView/ganttview.tpl");
if(isset($_REQUEST['ajax'])&&$_REQUEST['ajax']=='true'){
    $_REQUEST['diony']='diony';
    $arr = array();
    $arr["ganttData"] = $ganttData;
    $arr["headerarr"] = $headerarr;
    $arr["content"] = $bodyhtml;
    ConvertTojsonString(1,$arr,'success');
}

?>

<!DOCTYPE html>

<html lang="zh">
<head>
	<meta charset="utf-8">
    <!--<link rel="stylesheet" type="text/css" href="crmcommon/css/webuploader/bootstrap.min.css" />--!>
    <link rel="stylesheet" type="text/css" href="themes/softed/style.css" />
    <!--wym 231229 BUG0078026 如果其他css引用了leftmenu里定义的颜色,leftmenu.css也要引用一下-->
    <link type="text/css" rel="stylesheet" href="themes/softed/leftmenu.css">
    <link type="text/css" rel="stylesheet" href="themes/softed/common.css">
	<link rel="stylesheet" type="text/css" href="include/ganttView/lib/jquery-ui-1.8.4.css" />
	<link rel="stylesheet" type="text/css" href="include/ganttView/jquery.ganttView.css" />
	<style type="text/css">
		body {
			font-family: tahoma, verdana, helvetica;
			font-size: 0.8em;
			padding: 10px;
            line-height: 1;
            color:#444;
		}
	</style>
	<title>甘特图</title>
</head>
<body>
	<div  id="ganttsearchdiv"><?php echo $bodyhtml?></div>
    
	<script type="text/javascript" src="include/ganttView/1.7.1.jquery.min.js"></script>
	<script type="text/javascript" src="include/ganttView/lib/date.js"></script>
	<script type="text/javascript" src="include/ganttView/lib/jquery-ui-1.8.4.js"></script>
	<script type="text/javascript" src="include/ganttView/jquery.ganttView.js"></script>
	<script type="text/javascript">
    var ld=$;
    var global_js_url ='';
    var version_account  = '';
    var account_version ='';
		ld(function () {
            
			getganttChart(<?php echo $ganttDatatojs ?>,<?php echo $headerarrtojs ?>);
		});
        function getganttChart(ganttData,headerarr){
            var vHeaderWidthval = 640;
			ld("#ganttChart").ganttView({ 
				data: ganttData,
                hearderdata:headerarr,
				slideWidth: (document.documentElement.offsetWidth || document.body.offsetWidth)-56-vHeaderWidthval,//vtheaders width:320px
				vHeaderWidth:vHeaderWidthval,
				behavior: {
					onClick: function (data) {
						//var msg = "You clicked on an event : { start: " + data.start.toString("M月d日yyyy年") + ", end: " + data.end.toString("M/d/yyyy") + " }";
						//$("#eventMessage").text(msg);
					},
				}
			});
        }
        function getganttviewByproject(){
            var selectprojectobj= document.getElementById('projectid');
            var value = ld(selectprojectobj).val();
            var url = window.location.href;
            if(url.indexOf('?')<0){
                url+='?';
            }
            var param = 'projectid='+value+"&ajax=true";
            ldAjax(url,param,function(data){
                
                ld("#ganttsearchdiv").html(data.result.content);
                getganttChart(data.result.ganttData,data.result.headerarr);
            })
        }
        function getaccountsByprojectid(obj){
            var value = ld(obj).val();
            if(!empty(value)){
                var url = window.location.href;
                if(url.indexOf('?')<0){
                    url+='?';
                }
                var param = 'projectid='+value+"&mode=getaccountinfo";
                ldAjax(url,param,function(data){
                    if(data.code == 1){
                        ld('#single_accountid').val(data.result.accountname);
                        ld('#account_id').val(data.result.accountid);
                        ld('#xm_owner').html(data.result.xm_owner);
                    }
                    
                })
            }
            else{
                ld('#single_accountid').val('');
                ld('#account_id').val('');
                return false;
            }
            
        }
	</script>
	<script type="text/javascript" src="include/js/general.js"></script>
   <script language="JavaScript" type="text/javascript" src="include/js/SystemPopup/CrmPopup.js?v=2"></script>
     <script language="JavaScript" type="text/javascript" src="include/js/SystemPopup/selectSearchPopup.js"></script>
     <script language="JavaScript" type="text/javascript" src="include/js/SystemPopup/PopupLayer.js?v=2"></script>
     <script language="JavaScript" type="text/javascript" src="include/js/ldAjax.js?v=3"></script><!--公共-->
     <script language="JavaScript" type="text/javascript" src="include/js/cls_encryptyurl.js?v=3"></script><!--公共-->
     <script language="JavaScript" type="text/javascript" src="include/js/crypto-js.min.js?v=3"></script><!--公共-->
     <script language="JavaScript" type="text/javascript" src="include/js/SystemPopup/PopupDrag.js?v=4"></script>
     <script language="JavaScript" type="text/javascript" src="include/js/ListView.js?v=4"></script>
     
    <script>
        var popupobj=new Object();
        popupobj.divid='ganttsearchdiv';
        popupobj.module='ProjectTask';
        popupobj.type = 'ganttReport';
        CrmPopup.global_listPopupObj.push(popupobj);
        
        var CreatePagePopup = new Object();
        CreatePagePopup.pagetype = 'ganttReport';
    </script>
</body>
</html>
