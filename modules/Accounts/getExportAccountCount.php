<?php

global $current_user;
$accounttype="ALLACCOUNT";
if(isset( $_SESSION['lvsAccount'][$currentModule]['pagepublicaccounttype']))
{
    $accounttype=$_SESSION['lvsAccount'][$currentModule]['pagepublicaccounttype'];
}

$customView = new CustomView($currentModule);
//chj 2021/3/23 45099: （61mis.com/kfbcrm）OA表单-加班单；加班单列表处，点击全部合计时长为120；回到加班单的链接模块“加班单_已批准”后，点击全部合计也显示“120”，实际时长“38”；
if(!empty($_REQUEST['viewname'])){
	$viewid = vtlib_purify($_REQUEST['viewname']);
}else{
	$viewid = $customView->getViewId($currentModule);
}
if(isset($_SESSION['lvs'][$currentModule]['SearchScope'])&&$_SESSION['lvs'][$currentModule]['SearchScope']!=null)
{}
else 
{
    $SearchScope="SmOwner_Search_All";
    $_SESSION['lvs'][$currentModule]['SearchScope']=$SearchScope;
}


$queryGenerator = QueryGenerator::getInstance($currentModule, $current_user,$customView);


if(isset($_SESSION['LiveViewSearch'][$currentModule])&&($_REQUEST['search_type']=='includesearch'||
        $_REQUEST['search_type']=='withoutsearch' || $_REQUEST['search_type']=='selecteddata')){
	$input = $_SESSION['LiveViewSearch'][$currentModule]['input'];
	global $search_session;
	$search_session = 1;
	if($input['searchtype'] == 'BasicSearch'){
		if(!empty($input['search_text'])){
			$_REQUEST['search_field'] = $input['search_field'];
			$_REQUEST['search_text'] = $input['search_text'];
			$_REQUEST['SearchScope'] = $input['SearchScope'];
			$_REQUEST['searchtype'] = $input['searchtype'];
			$_REQUEST['type'] = $input['type'];
		}
	}else if($input['searchtype'] == 'advance'){
		if(!empty($input['advft_criteria']) && $input['advft_criteria'] != '[]'){
			$_REQUEST['advft_criteria'] = $input['advft_criteria'];
			$_REQUEST['advft_criteria_groups'] = $input['advft_criteria_groups'];
			$_REQUEST['SearchScope'] = $input['SearchScope'];
			$_REQUEST['searchtype'] = $input['searchtype'];
			//初始化搜索条件
			$json = new Zend_Json();
			$advft_criteria = $json->decode($input['advft_criteria']);
			$advft_criteria_groups = $json->decode($input['advft_criteria_groups']);
			$advfilterlist = getAdvancedSearchCriteriaList($advft_criteria, $advft_criteria_groups, $currentModule,$queryGenerator);
		}
	}
	if($search_session == 1){
		$_REQUEST['query'] = 'true';
	}
}
///得到对应视图的查询字段
if ($viewid != "0") {
   $queryGenerator->initForCustomViewById($viewid);
} else {
	$queryGenerator->initForDefaultCustomView();
}

// Enabling Module Search
$url_string = '';
if($_REQUEST['query'] == 'true') {
	$_REQUEST['searchtype'] = trim($_REQUEST['searchtype']);
	$queryGenerator->addUserSearchConditions($_REQUEST);

}

$list_query = $queryGenerator->getQuery('',3);

$page_list_query=$queryGenerator->getQuery('',1);
//$status=1;
//$adminaccount="";
//$usersaccount="";
//$dataProfile=1;
//$getProfile=1;

//by andy 公海客户改进
//$wheathershow=1;
//$userid='';
//$status=getAccount_Set('status');
//$adminaccount=getAccount_Set("adminaccount");
//$usersaccount=getAccount_Set('usersaccount');
//$dataProfile=getAccount_Set('dataprofile');
//$getProfile=getAccount_Set('getprofile');
//$wheathershow=getAccount_Set('wheathershow');
//$userid=getAccount_Set('userid');
//$splitadmin=explode(",",$adminaccount);
//$splituser=explode(',',$usersaccount);

$where = $queryGenerator->getConditionalWhere();

//$focus->setaccountstatus($status);
//$focus->setadminaccount($adminaccount);
//$focus->setuseraccount($usersaccount);

/*if($status==0)//启用公海参数
{
   if($accounttype=='PUBLICALLOCATE')
    {
       $ChartWhere=" and ld_account.publicaccount>1 ";
    }
}

if($status==0&&($current_user->is_admin=="on"||in_array($current_user->id,$splitadmin)||in_array($current_user->id,$splituser)))
{
     if($accounttype=='NOALLOCATE')
    {
        $ChartWhere=" and ld_account.publicaccount=1";
    }
}
if($status==0&&($wheathershow == 1 || $wheathershow == 2 || $wheathershow == 3)&&$accounttype=='ALLACCOUNT')
{
	if($wheathershow == 1)
        $ChartWhere .=' and ld_account.publicaccount = 0 ';
	else if($wheathershow == 2)
        $ChartWhere .=' and ld_account.publicaccount > 1 ';
	else if($wheathershow == 3)
        $ChartWhere .=' and ld_account.publicaccount = 1 ';
}

$page_list_query .=$ChartWhere;*/
$wheres = $queryGenerator->getWhereClause();


$list_query=$list_query." inner join ( $page_list_query  ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index";


$list_query=$list_query.$wheres;
?>