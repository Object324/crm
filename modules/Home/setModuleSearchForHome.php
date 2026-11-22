<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
//require_once('include/utils/utils.php');
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$advft_criteria = array();
$versioninfo = getVersionInfo();
// 誉帆 易冲 reportlabel才有值 项目报告穿透
if(!empty($_REQUEST['reportlabel'])) {
    $search_module = $_REQUEST['searchmodule'];
    $advft_criteria_groups = '';
    //誉帆
    if ($versioninfo['account'] == "yufan") {
        include(globalStatic::$root_directory.'modules/Home/CustomMade/YufanUtils.php');
        $YufanUtilsObj = new YufanUtils();
        $advft_criterias = $YufanUtilsObj->setMarketingReportSession($_REQUEST['search_date_custom_value'], $_REQUEST['reportlabel']);
    } else if ($versioninfo['account'] == "yichong") {
        //易冲
        include(globalStatic::$root_directory.'modules/Home/CustomMade/YichongUtils.php');
        $YichongUtilsObj = new YichongUtils();
        $advft_criterias = $YichongUtilsObj->setMarketingReportSession($_REQUEST['search_date_custom_value'], $_REQUEST['reportlabel']);
    }else if($versioninfo['trade'] == "construction"){
        include(globalStatic::$root_directory.'modules/Home/CustomMade/ConstructionUtils.php');
        $ConstructionObj = new ConstructionUtils();
        $advft_criterias = $ConstructionObj->setMarketingReportSession($_REQUEST['search_date_custom_value'], $_REQUEST['reportlabel']);
    }
    if(isset($advft_criterias['advft_criteria_groups'])){
        $advft_criteria_groups_value = $advft_criterias['advft_criteria_groups'];
    }
    $advft_criterias = $advft_criterias[$_REQUEST['reportlabel']];
    $modules = explode(",",$search_module);
    $new_advft_criterias = [];
    foreach($modules as $tmp_module)
    {
        if (!isset($advft_criterias[$tmp_module])) {
            continue;
        }
//        $advft_criterias[$tmp_module][sizeof($advft_criterias[$tmp_module])-1]['columncondition']='';

        /*$input['advft_criteria'] = json_encode($advft_criterias[$tmp_module]);
        $input['advft_criteria_groups'] = $advft_criteria_groups;*/

//        @edit:liushuai,2021-02-24,reason:【ID1001362】首页-审批状态可多选查看（四方光电）
        $sys_approve = getSys_Approvedeploy($tmp_module);
        $tmp_focus = CRMEntity::getInstance($tmp_module);
        //开启审批参数  并且该模块有启用 审批状态 字段(启用后可以作为查询条件)  并且查询条件除了时间还有审批状态不为全部。
//        if($sys_approve['deploy_value'] == 0 && sizeof($advft_criterias[$tmp_module]) > 1){
        if($sys_approve['deploy_value'] == 0 && isset($tmp_focus->column_fields['approvestatus']) && sizeof($advft_criterias[$tmp_module]) > 1){
            //首页 第一个时间条件需要和审批的几个状态  依次做组合条件，故：循环将审批状态依次和时间等条件做组合
            //将审批状态取出来，
            $advft_criterias_approvestatus_arr = [];
            foreach ($advft_criterias[$tmp_module] as $key=>$val){
                if (stripos($val['columnname'], 'approvestatus') !== false) {
                    $advft_criterias_approvestatus_arr[] = $advft_criterias[$tmp_module][$key];
                    unset($advft_criterias[$tmp_module][$key]);
                }
            }

            //取时间字段查询条件，并将其置于数组开头
            $advft_criterias_datetype_key = '';
            $advft_criterias_datetype_arr = [];
            foreach ($advft_criterias[$tmp_module] as $key=>$val){
                //判断是日期类型，组合处理
                $columnname_arr = explode(":", $val['columnname']);//ld_servicecontracts:due_date:due_date:ServiceContracts_服务收费合同
                $columnname = $columnname_arr[1];
                $tmp_fieldinfo = $tmp_focus->fieldobj->getFieldInfoobjBykey('columnname', $columnname);

                if ($tmp_fieldinfo && ($tmp_fieldinfo->getFieldDataType()=='datetime' || $tmp_fieldinfo->getFieldDataType()=='time' || $tmp_fieldinfo->getFieldDataType()=='date')) {
                    $advft_criterias_datetype_key = $key; //0 3
                    $advft_criterias_datetype_arr = $advft_criterias[$tmp_module][$key];
                    unset($advft_criterias[$tmp_module][$key]);
                    break;
                }
            }

            if (!empty($advft_criterias_datetype_arr))
                array_unshift($advft_criterias[$tmp_module], $advft_criterias_datetype_arr);

            if (!empty($advft_criterias_approvestatus_arr)) {
                for($i=1; $i <= sizeof($advft_criterias_approvestatus_arr); $i++) {//将审批状态的条件依次和原先的条件做拼接
                    foreach ($advft_criterias[$tmp_module] as $k=>$v){  //原先的查询条件
                        $advft_criterias[$tmp_module][$k]['groupid'] = $i;
                        $new_advft_criterias[] = $advft_criterias[$tmp_module][$k];
                    }

                    $advft_criterias_approvestatus_arr[$i - 1]['groupid'] = $i; //现在的审批状态的条件做拼接
                    $new_advft_criterias[] = $advft_criterias_approvestatus_arr[$i - 1];

                    $new_advft_criterias[sizeof($new_advft_criterias)-1]['columncondition']='';
                }
            }

            $input['advft_criteria'] = json_encode($new_advft_criterias);

            if (empty($_REQUEST['approve_value'])) {
                $input['advft_criteria_groups'] = json_encode(array(null, '1' => array('groupcondition' => '')));
            }else{
                $groupid_num = sizeof($advft_criterias_approvestatus_arr);//计算组合条件个数
                $advft_criteria_groups=array();
                $advft_criteria_groups[]='null';
                for($i=1; $i<$groupid_num; $i++){
                    $advft_criteria_groups[]= array(
                        'groupcondition'=>'or'    //需求是或
                    );
                }
                $advft_criteria_groups[]= array(
                    'groupcondition'=>''
                );
//                $input['advft_criteria_groups'] = '[null,{"groupcondition":"and"},{"groupcondition":""}]';
                $input['advft_criteria_groups'] = json_encode($advft_criteria_groups);
            }

        }else{
            $advft_criterias[$tmp_module][sizeof($advft_criterias[$tmp_module])-1]['columncondition']='';
            $input['advft_criteria'] = json_encode($advft_criterias[$tmp_module]);

            if(empty($advft_criteria_groups_value)){
                $input['advft_criteria_groups'] = json_encode(array(null, '1' => array('groupcondition' => '')));
            }else{
                $input['advft_criteria_groups'] = $advft_criteria_groups_value;
            }
        }

        $input['searchtype'] = 'advance';
        $_SESSION['LiveViewSearch'][$tmp_module]['input'] = $input;
        $_SESSION['lvs'][$tmp_module]['SearchScope'] = 'smowner_search_senior';
        $_SESSION['lvs'][$tmp_module]['senioruserid'] = $_REQUEST['selectuserid'];
    }
    $_REQUEST['diony']='yes';
    ConvertTojsonString(1,array(),'');
    exit;
}
// 产品总览的穿透产品总览 【上海鑫选-产品总览报表开发，已和刘总确认（徐昱轩）】
if(!empty($_REQUEST['productOverview'])&&$_REQUEST['productOverview']=="yes"){
    $searchmodule = $_REQUEST['searchmodule'];
    $product_no = $_REQUEST['product_no'];
    $today = date('Y-m-d');
    $advft_criterias = [
        "OutboundOrder" => Array
        (
            Array
            (
                "groupid" => 1,
                "columnname" => "ld_outboundorder:outdate:outdate:OutboundOrder_出库日期:D",
                "comparator" => "e",
                "value" => $today,
                "columncondition" => "and",
            ),
            Array
            (
                "groupid" => 1,
                "columnname" => "ld_products:product_no:product_no:products_产品编号:V",
                "comparator" => "e",
                "value" => $product_no,
                "columncondition" => " ",
            )
        ),
        "Stock" => Array
        (
            Array
            (
                "groupid" => 1,
                "columnname" => "ld_stock:createdate:createdate:Stock_入库日期:D",
                "comparator" => "e",
                "value" => $today,
                "columncondition" => "and",
            ),
            Array
            (
                "groupid" => 1,
                "columnname" => "ld_products:product_no:product_no:products_产品编号:V",
                "comparator" => "e",
                "value" => $product_no,
                "columncondition" => " ",
            )
        ),
        "SalesOrder" => Array
        (
            Array
            (
                "groupid" => 1,
                "columnname" => "ld_salesorder:duedate:duedate:SalesOrder_提货日期:D",
                "comparator" => "e",
                "value" => $today,
                "columncondition" => "and",
            ),
            Array
            (
                "groupid" => 1,
                "columnname" => "ld_products:product_no:product_no:products_产品编号:V",
                "comparator" => "e",
                "value" => $product_no,
                "columncondition" => " ",
            )
        )
    ];
    $input['advft_criteria'] = json_encode($advft_criterias[$searchmodule]);
    $input['searchtype'] = 'advance';
    $input['advft_criteria_groups'] = json_encode(array(null, '1' => array('groupcondition' => '')));
    $_SESSION['LiveViewSearch'][$searchmodule]['input'] = $input;

    $userids = $_REQUEST['selectuserid'];
    global $current_user;
    $scope = $_REQUEST['SmOwnerSearchScope'];
    if (!$scope) {
        $scope = 'SmOwner_Search_All';
    }
    switch ($scope) {
        case 'SmOwner_Search_All':
            $Smownerids = getCurSmOwnerSearchScope('OftenUseReport');
            foreach ($Smownerids['UserCombo'] as $userid => $userinfo) {
                if ($userids == "") {
                    $userids .= $userid;
                } else {
                    $userids .= "," . $userid;
                }
            }
            $userids .= "," . $current_user->id;
            break;
        case 'SmOwner_Search_Me':
        case 'SmOwner_Search_Create':
            $userids =  $current_user->id;
            break;
        case 'smowner_search_senior':

            break;
        case 'SmOwner_Search_Group':
            $query = 'select userid from ld_users2group where groupid in (' . $_REQUEST['receiverid'] . ') group by userid';
            $result = $this->adb->pquery($query, array());
            $num_rows = $this->adb->num_rows($result);
            for ($i = 0; $i < $num_rows; $i++) {
                $userid_array[] = $this->adb->query_result($result, $i, 'userid');
            }
            $ScopOfAuthority = ScopOfAuthority::getInstance($this->adb, 'OftenUseReport');
            $CurUserScopeId = $ScopOfAuthority->getCurUserScopeId();
            if ($CurUserScopeId == 'All') {
                $intersection = $userid_array;
            } else {
                $intersection = array_intersect($userid_array, $ScopOfAuthority->getUserModuleScopeHigher());
            }
            $userids = implode(',', $intersection);
            break;
        default:
            $userids =  $scope;
    }
    $_SESSION['lvs'][$searchmodule]['SearchScope'] = $scope;
    $_SESSION['lvs'][$searchmodule]['senioruserid'] = $userids;
}
if(!isset($_REQUEST['danding_login']))
{
    $_REQUEST['diony']='yes';
    crm_load_class_file('AuthApi','Register');
    $authapiobj=new AuthApi();
    $authapiobj->ResetExp(strtotime(DateOperation::addSeconds(date("Y-m-d H:i:s"),5)));
    $arr['stufflabel']=$_REQUEST['stufflabel'];
    $arr['reportlabel']=$_REQUEST['reportlabel'];
    $arr['searchmodule']=$_REQUEST['searchmodule'];
    $arr['search_date_custom_value']=$_REQUEST['search_date_custom_value'];
    $arr['approve_value']=$_REQUEST['approve_value'];
    $arr['selectuserid']=$_REQUEST['selectuserid'];
    $arr['searchtype']=$_REQUEST['searchtype'];
    $arr['pageurl']=$_REQUEST['pageurl'];
    $arr['addurl']=$_REQUEST['addurl'];
    $arr['password']=$current_user->user_password;
    ConvertTojsonString(1,array("encode"=>$authapiobj->encode($arr)),'');
}
?>