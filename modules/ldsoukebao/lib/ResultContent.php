<?php
global $current_user,$currentModule;
crm_load_class_file("cls_soukebao","modules/ldsoukebao/lib");
$soukebaoobj = cls_soukebao::getInstance();
$soukebaoobj->setoperationtype("searchcondition");

$currentpage = $_REQUEST['currentPage'];
$pagesize = $_REQUEST['pagesize'];
$searchcolumn = $_REQUEST['searchcolumn'];
$searchtext = $_REQUEST['searchtext'];
$jsonsearchadvance = '{}';
$jsonmapinfo = '';
$soukebaoobj->setsearchtext($searchtext);
$soukebaoobj->setsearchcolumn($searchcolumn);
$soukebaoobj->setcurrentpage($currentpage);
$soukebaoobj->setpagesize($pagesize);
$search_advance_arr = [];
if(isset($_REQUEST['BaseData'])&&!empty($_REQUEST['BaseData']))
{
    $BaseData = $_REQUEST['BaseData'];
    foreach ($BaseData['filtergroup'] as $tmpindex=>$tmpcolumninfo)
    {
        $tmpcolumnname = $tmpcolumninfo['value'];
        $tmppicklistarr = $tmpcolumninfo['checklist'];
        $tmpdependencyfield = $tmpcolumninfo['dependencyfield'];
        if($tmpdependencyfield == 'yes'){
            //如果椒级联字段,获取级联对应搜索条件
            $tmpdependencycondendition = $soukebaoobj->getDependencySearchCondition($tmpcolumnname,$tmppicklistarr);
            if(!empty($tmpdependencycondendition)){
                $search_advance_arr['dependency'] = [$tmpcolumnname=>$tmpdependencycondendition];
            }
        }
        else{
            foreach ($tmppicklistarr as $tmppicklistindex=>$tmppicklistinfo)
            {
                $tmpselected = $tmppicklistinfo['selected'];
                $tmppicklistid = $tmppicklistinfo['value'];
                if($tmpselected == true)
                {
                    if(!array_key_exists($tmpcolumnname,$search_advance_arr))
                    {
                        $search_advance_arr[$tmpcolumnname] = [];
                    }
                    $search_advance_arr[$tmpcolumnname][] = $tmppicklistid;
                }
            }
        }
    }
}
if(isset($_REQUEST['AdvanceData'])&&!empty($_REQUEST['AdvanceData']))
{
    $AdvanceData = $_REQUEST['AdvanceData'];
    foreach ($AdvanceData['filtergroup'] as $tmpindex=>$tmpcolumninfo)
    {
        $tmpcolumnname = $tmpcolumninfo['value'];
        $tmppicklistarr = $tmpcolumninfo['checklist'];
        foreach ($tmppicklistarr as $tmppicklistindex=>$tmppicklistinfo)
        {
            $tmpselected = $tmppicklistinfo['selected'];
            $tmppicklistid = $tmppicklistinfo['value'];
            if($tmpselected == true)
            {
                if(!array_key_exists($tmpcolumnname,$search_advance_arr))
                {
                    $search_advance_arr[$tmpcolumnname] = [];
                }
                if(!in_array($tmppicklistid,$search_advance_arr[$tmpcolumnname])){
                    $search_advance_arr[$tmpcolumnname][] = $tmppicklistid;
                }

            }
        }
    }
}

if(!empty($search_advance_arr)){
    $jsonsearchadvance = json_encode($search_advance_arr);
    $soukebaoobj->setsearchadvance($jsonsearchadvance);
}
//地图获客条件
if($currentModule == 'ldsoukebaomap' && isset($_REQUEST['mapCenter'])&&!empty($_REQUEST['mapCenter'])){
    $mapCenter = $_REQUEST['mapCenter'];
    $mapRadius = $_REQUEST['mapRadius'];
    $lat = $mapCenter['lat'];
    $lng = $mapCenter['lng'];
    $mapRadius = $mapRadius/1000;//单位为1000;
    $mapinfoarr = array('jingdu'=>$lng,'weidu'=>$lat,'radius'=>$mapRadius);
    $jsonmapinfo = json_encode($mapinfoarr);
    $soukebaoobj->setmapinfo($jsonmapinfo);
}
if($currentModule == 'ldsoukebao'){
    setUsersettingByLabel($currentModule,$current_user->id,'soukebaocondition', $jsonsearchadvance);
}


$data = $soukebaoobj->getlistByoperationtype();
$data['isadmin'] = is_admin($current_user);
$data['importModuleList'] = [array('label'=>'所选企业导入到线索模块','value'=>'Leads'),array('label'=>'所选企业导入到客户模块','value'=>'Accounts')];
$data['importmodule'] = getUsersettingByLabel('ldsoukebao','1','soukebaoimportmodule')?:'Accounts';
ConvertTojsonString(1,$data,'sussess');
?>
