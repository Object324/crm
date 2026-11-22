<?php
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once('Smarty_setup.php');
$smarty=new lingdangCRM_Smarty;
$now = date('Y');
$year  = $now - 8;
$date = array();
$date_change = array();
$year_change = "";
$year_show="";
for($i=0;$i<=8;$i++)
{
    $date[$i]= $year;
    if($now == $date[$i])
    { 
        $year_show .= "<li id=\"year_table\">";
        $year_show .= "<a id='".$year."' href='javascript:void(0);'  onclick='chose_year(this.innerHTML)' class=\"On\">";
        $year_show .= $year;
        $year_show .= "</a>";
        $year_show .= "</li>";
    }
    else
    {
        $year_show .= "<li id=\"year_table\">";
        $year_show .= "<a id='".$year."' href='javascript:void(0);' onclick=\"chose_year(this.innerHTML);change_color('".$year."','".$now."');\" >";
        $year_show .= $year;
        $year_show .= "</a>";
        $year_show .= "</li>";
    }

    $year = $year + 1;   
}
if(isset($_REQUEST['year']) && isset($_REQUEST['now']))
{
    
    $year_change_color = $_REQUEST['now'] - 8;
    for($i = 0;$i<=8;$i++)
    {
        $date_change[$i] = $year_change_color;
        if($_REQUEST['year'] == $date_change[$i])
        {
            $year_change .= "<li id=\"year_table\">";
            $year_change .= "<a id='".$year."' href='javascript:void(0);' onclick=\"chose_year(this.innerHTML);\" class=\"On\">";
            $year_change .= $_REQUEST['year'];
            $year_change .= "</a>";
            $year_change .= "</li>";
        }
        else
        {
            $year_change .= "<li id=\"year_table\">";
            $year_change .= "<a id='".$year."' href='javascript:void(0);' onclick=\"chose_year(this.innerHTML);change_color('".$year_change_color."','".$now."');\" >";
            $year_change .= $year_change_color;
            $year_change .= "</a>";
            $year_change .= "</li>";
        }
        
        
        $year_change_color = $year_change_color + 1;
    }
   echo "#SUCCESS#".$year_change;
        exit();
}

$presence=array();
$presence_sql='SELECT id,name,reportlabel,setype,presence,typename from ld_comprehensivereport where presence=0';
$presence_result=$adb->pquery($presence_sql,array());
$presence_nums=$adb->num_rows($presence_result);
if($presence_nums>0){
    for($i=0;$i<$presence_nums;$i++){
        $typename=$adb->query_result($presence_result,$i,'typename');
        $name=$adb->query_result($presence_result,$i,'name');
        $id=$adb->query_result($presence_result,$i,'id');
        $presence[$typename][$name]['name'] = $adb->query_result($presence_result,$i,'name');
        $presence[$typename][$name]['reportlabel']= $adb->query_result($presence_result,$i,'reportlabel');
        $presence[$typename][$name]['setype']= $adb->query_result($presence_result,$i,'setype');
        $presence[$typename][$name]['presence']= $adb->query_result($presence_result,$i,'presence');
        if($id==$_REQUEST['report_id']){
            $curtypename = $typename;
        }
    }
}

$typeNamePresence=array();//报表文件夹是否显示
$reporttype_sql='SELECT typename,presence,version from ld_comprehensivereport_group where presence=0';
$reporttype_result=$adb->pquery($reporttype_sql,array());
$reporttype_nums=$adb->num_rows($reporttype_result);
if($reporttype_nums > 0){
    for($i=0;$i<$reporttype_nums;$i++){
        $name=$adb->query_result($reporttype_result,$i,'typename');
        if(!in_array($name,$typeNamePresence)){
            $json_typename[] = $name;
            $typeNamePresence[$name]['presence'] = $adb->query_result($reporttype_result,$i,'presence');
            $typeNamePresence[$name]['version'] = $adb->query_result($reporttype_result,$i,'version');
        }  
    }
}

foreach($json_typename as $baobiaoName){
    if(empty($presence[$baobiaoName])){
        unset($typeNamePresence[$baobiaoName]);
        unset($json_typename[array_search($baobiaoName,$json_typename)]);       
    }
}
$json_typename=array_values($json_typename);//数组键值重新从0开始

//进入综合报表，默认显示的报表
$defaultReport = $json_typename[0];

$jsontypename = Zend_Json::encode($json_typename);

if(empty($presence)){
    echo getFixedLabel('NOREPORTEAVAIL');
    exit();
}
$smarty->assign('DEFAULTREPORT',$defaultReport);
$smarty->assign('JSONTYPENAME',$jsontypename);
$smarty->assign('TYPENAMEPRESENCE',$typeNamePresence);
$smarty->assign('PRESENCE',$presence);

$smarty->assign("now",$now);
$smarty->assign("current_year",$now);
$smarty->assign("date",$date);
$smarty->assign("year_show",$year_show);
$smarty->assign('IMAGE_PATH',$image_path);

$listtype = $_REQUEST['listtype'];
$listtype = empty($listtype)?'list':$listtype;
$smarty->assign('listtype',$listtype);//如果是报表分析来的请求 把中间的报表菜单隐藏
if($listtype=='screen'){
    $smarty->assign('curtypename',$curtypename);
    $content = $smarty->fetch("Comprehensivereport/ComprehensivereportAll.tpl");
    ConvertTojsonString(1,['content'=>$content,'curtypename'=>$curtypename],'success');
}else{
    $smarty->display("Comprehensivereport/ComprehensivereportAll.tpl");
}
?>