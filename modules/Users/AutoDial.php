<?php
//@edit:liushuai,2021-07-05,reason:【ID1001745】灵当语音盒，增加“自动拨号”功能
global $adb,$current_user;
$smarty = new lingdangCRM_Smarty;
$_REQUEST['diony'] = 'yes';
$arr = [];
$mode = vtlib_purify($_REQUEST['mode']);
switch($mode)
{
    case 'autodiallist';
        $frommodule = vtlib_purify($_REQUEST['frommodule']);
        $idstring = vtlib_purify($_REQUEST['idstring']);
        $excludedRecords = vtlib_purify($_REQUEST['excludedRecords']);
        //选择单据的集合
        $recordid_arr = getSelectIds($frommodule, $idstring, $excludedRecords);
        //列头翻译
        $autoDialListHeader = autoDialListHeader($frommodule);
        //列表数据
        $autoDialList = autoDialList($frommodule, $recordid_arr);

        $smarty->assign("autoDialListHeader", $autoDialListHeader);//拨号列表展示页面
        $smarty->assign("allids", implode(',',$recordid_arr));
        $smarty->assign("selectcount", $_REQUEST['selectcount']);//选择总数
        $smarty->assign("selectvalidcount", count($recordid_arr));//实际有效的选择总数
        $smarty->assign("autoDialList", $autoDialList);//拨号列表展示页面
        $smarty->assign("module", $frommodule);

        $languageType = getLanguageType($current_user);//中英文包
        $smarty->assign("LANUGAGETYPE",$languageType);

        $smarty->display("AutoDialList.tpl");
        exit();
    break;
    /*case 'getselectids':
        $frommodule = vtlib_purify($_REQUEST['frommodule']);
        $idstring = vtlib_purify($_REQUEST['idstring']);
        $excludedRecords = vtlib_purify($_REQUEST['excludedRecords']);
        $recordid_arr = getSelectIds($frommodule, $idstring, $excludedRecords);
        $arr['recordid_arr'] = $recordid_arr;//所有选择的record集合
//        $arr['count'] = count($recordid_arr);//有效的record总数
        $arr['REQUEST'] = $_REQUEST;

        break;
    case 'getmobile':
        $frommodule = vtlib_purify($_REQUEST['frommodule']);
        $record = $_REQUEST['record'];
        $arr = getMobileInfo($frommodule, $record);
        break;*/
    default:
        break;

}


ConvertTojsonString(1,$arr,'');

//拨号列表
function autoDialList($frommodule, $recordid_arr){
    //获取客户的编号、客户名称。联系人的编号、姓名、客户名称
    global $adb;
    $autoDialList = array();
    foreach ($recordid_arr as $record) {
        $mobileInfo = getMobileInfo($frommodule, $record);
        $mobile = checkCall($mobileInfo["mobile"]);//正则过滤号码
        if ($frommodule == 'Accounts') {
            $sql = "select account_no,accountname from ld_account where accountid = ? and deleted = 0";
            $result = $adb->pquery($sql,array($record));
            $billno = $adb->query_result($result, 0, 'account_no');
            $accountname = $adb->query_result($result, 0, 'accountname');
            $autoDialList[] = ["record"=>$record, "billno"=>$billno, "accountname"=>$accountname, "lastname"=>$mobileInfo["lastname"], "mobile"=>$mobile, "contactid"=>$mobileInfo["contactid"],"accountid"=>$mobileInfo["accountid"]];//为客户模块时：$record 就是 $mobileInfo["accountid"]
        } elseif ($frommodule == 'Contacts') {
            $sql = "SELECT ld_contactdetails.contact_no,ld_contactdetails.lastname,ld_account.accountname FROM ld_contactdetails
LEFT JOIN ld_account ON ld_account.accountid = ld_contactdetails.accountid
WHERE ld_contactdetails.contactid = ? AND ld_contactdetails.deleted = 0";
            $result = $adb->pquery($sql,array($record));
            $billno = $adb->query_result($result, 0, 'contact_no');
//            $lastname = $adb->query_result($result, 0, 'lastname');
            $accountname = $adb->query_result($result, 0, 'accountname');
            $autoDialList[] = ["record"=>$record, "billno"=>$billno, "lastname"=>$mobileInfo["lastname"], "accountname"=>$accountname, "mobile"=>$mobile, "contactid"=>$mobileInfo["contactid"],"accountid"=>$mobileInfo["accountid"]]; //为联系人模块时：$record 就是 $mobileInfo["contactid"]，目前联系人模块去电通话记录是不反写客户id的，这里返回过去以备以后使用
        }
    }
    return $autoDialList;
}

//列头翻译
function autoDialListHeader($frommodule){
    global $adb;
    $fieldobj = Field::getInstance($frommodule,$adb);
    $moduleFields = $fieldobj->getModuleFields();
    $autoDialListHeader = [];
    foreach ($moduleFields as $fieldname=>$fieldinfo) {
        $columnname = $fieldinfo->getColumnName();
        if (in_array($columnname, array('accountname','account_no','lastname','contact_no','accountid','mobile'))) {
            $fieldinfo = $fieldobj->getFieldInfoobjBykey("columnname", $columnname);
            $autoDialListHeader[$columnname] = $fieldinfo->getfieldLabel();
        }
    }
    return $autoDialListHeader;
}
//处理序时簿列表选择的单据id
function getSelectIds($frommodule, $idstring, $excludedRecords){
    $deployarray = getSys_deploy(67);
    $btach_num = $deployarray['deploy_value'];//批量操作不能超过设置的上限
    if ($idstring == 'all') {
        $_REQUEST['mass_batch_num_all'] = $btach_num;
        $recordid_arr = getSelectedRecords($_REQUEST, $frommodule, $idstring, $excludedRecords);
    } else{
        $recordid_arr = array_unique(explode(';', rtrim($idstring, ';')));
        if (count($recordid_arr) > $btach_num) {
            $recordid_arr = array_slice($recordid_arr, 0, $btach_num);
        }
    }
    $recordid_arr = array_filter(array_values($recordid_arr));

    return $recordid_arr;
}

//获取手机号等信息
function getMobileInfo($module, $record){
    global $adb;
//    $focus = CRMEntity::getInstance('Contacts');
//    $fieldobj = Field::getInstance($module,$adb);

    //先查找手机号uitype为1101，再查找电话uitype为11
    $sql = "select fieldid,columnname,tablename,uitype,fieldname,fieldlabel from ld_field where tabid = 4 and uitype in(11,1101) and ld_field.presence<>1 and savedatabase = 'yes' ORDER BY uitype DESC";
    $field_result = $adb->pquery($sql,array());
    if($adb->num_rows($field_result) > 0)
    {
        //拼接要查询的内容
        $select = '';
        $tablename_arr = $columnname_arr = array();
        for ($i = 0; $i < $adb->num_rows($field_result); $i++) {
            $columnname = $adb->query_result($field_result, $i, 'columnname');
            $tablename = $adb->query_result($field_result, $i, 'tablename');
            array_push($tablename_arr, $tablename);
            array_push($columnname_arr, $columnname);
            $select .= $tablename.'.'.$columnname.',';
        }
        $tablename_arr = array_unique($tablename_arr);
        $select = rtrim($select,',');
    }else{
        return array("mobile"=>'',"accountid"=>'',"contactid"=>'',"lastname"=>"");
    }


    if ($module == 'Accounts') {
        //客户界面批量外拨
        $query = 'select ld_contactdetails.contactid,ld_contactdetails.lastname,' . $select .',reference FROM ld_contactdetails ' ;
        if(in_array('ld_contactscf', $tablename_arr))
        {
            //存在自定义表字段
            $query.=' left join ld_contactdetails on ld_contactdetails.contactid=ld_contactscf.contactid ';
        }
        $query.=' inner join ld_account on ld_account.accountid=ld_contactdetails.accountid ';
        $query.=' where ld_account.accountid='.$record.' and ld_contactdetails.deleted=0 ';
//        $query .= ' and ld_contactdetails.reference=1 ';
        $query .= ' order by ld_contactdetails.reference desc,ld_contactdetails.createdtime desc '; //如果有首要联系人，则排在结果集第一个，如果首要联系人没有设置联系方式，则从其他联系人按照创建时间倒序取值。

        $result = $adb->pquery($query,array());
        $mobile = $contactid = $lastname = '';
        if ($adb->num_rows($result) > 0) {
            for ($i = 0; $i < $adb->num_rows($result); $i++) {
                foreach ($columnname_arr as $columnname){
                    $mobile = $adb->query_result($result,$i,$columnname);
                    $contactid = $adb->query_result($result,$i,'contactid');
                    $lastname = $adb->query_result($result,$i,'lastname');
                    if (!empty($mobile)) {
                        break 2;
                    }
                }
            }
        }

        return array("mobile"=>$mobile,"accountid"=>$record,"contactid"=>$contactid,"lastname"=>$lastname);
    } elseif ($module == 'Contacts'){
        //只有一条记录
        $query = 'select ld_contactdetails.contactid,ld_contactdetails.lastname,ld_contactdetails.accountid,' . $select .' FROM ld_contactdetails ' ;
        if(in_array('ld_contactscf', $tablename_arr))
        {
            //存在自定义表字段
            $query.=' left join ld_contactdetails on ld_contactdetails.contactid=ld_contactscf.contactid ';
        }
        $query.=' where ld_contactdetails.contactid='.$record.' and ld_contactdetails.deleted=0 ';

        $result = $adb->pquery($query,array());
        $mobile = $lastname = $accountid = '';
        if ($adb->num_rows($result) > 0) {

                foreach ($columnname_arr as $columnname){
                    $mobile = $adb->query_result($result,0,$columnname);
                    $lastname = $adb->query_result($result,0,'lastname');
                    $accountid = $adb->query_result($result,0,'accountid');
                    if (!empty($mobile)) {
                        break;
                    }
                }

        }

        return array("mobile"=>$mobile,"accountid"=>$accountid,"contactid"=>$record,"lastname"=>$lastname);
    }
}

/* 呼出手动录入号码规范匹配 */
function checkCall($tel)
{
    $isMob = "/^1[3-5,7-8]{1}[0-9]{9}$/";//    /^1[34578]\d{9}$/
    $isTel = "/^([0-9]{3,4})?[0-9]{7,8}$/";

    if (preg_match($isMob, $tel) || preg_match($isTel, $tel)) {
        return $tel;
    }else{
        return '';
    }
}

