<?php
//zkt 20231009 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$_REQUEST['diony'] = 'diony';

require_once('include/Stock/CommonStock.php');
global $adb;
global $current_user;
crm_load_class_file('DateTimeField', 'include/fields');
$cvid = (int)vtlib_purify($_REQUEST["record"]);
$cvmodule = vtlib_purify($_REQUEST["cvmodule"]);
if ($cvmodule == 'Calendar')
    $cvmodule = 'Events';
$parenttab = getParentTab();
$return_action = vtlib_purify($_REQUEST["return_action"]);
$focus = CRMEntity::getInstance($cvmodule);
$pool_id=0;
$accounttype='';

if ($cvmodule != "") {
    $cv_tabid = getTabid($cvmodule);
    $viewname = vtlib_purify($_REQUEST["viewName"]);  
    if ($_REQUEST['refreshpage'] == 'no') {
        $ssql = "SELECT ld_customview.cvid,ld_customview.viewname,ld_customview.status, ld_users.first_name,ld_users.last_name FROM ld_customview INNER JOIN ld_tab ON ld_tab.name = ld_customview.entitytype
					LEFT JOIN ld_users ON ld_customview.userid = ld_users.id ";
        $ssql .= " where ld_tab.tabid=?";
        $sparams = array($cv_tabid);
        $is_admin = is_admin($current_user);
        //or ld_customview.userid in(select ld_user2role.userid from ld_user2role inner join ld_users on ld_users.id=ld_user2role.userid inner join ld_role on ld_role.roleid=ld_user2role.roleid where ld_role.parentrole like '" . $current_user_parent_role_seq . "::%')
        if ($is_admin == false) {
            $ssql .= " and (ld_customview.status=0 or ld_customview.userid = ? or ld_customview.status = 3)";
            array_push($sparams, $current_user->id);
        }else{ //wyt 221222 BUG0060092 (通用问题) 单据的非公开查询分类，用户删除后，其他成员依旧不能创建同名称的分类
            $ssql .= " and  ld_customview.userid = ? ";
            array_push($sparams, $current_user->id);
        }
        $ssql .= ' and viewname=? and cvid!=? and entitytype =?';
        $accounttype='';
        if ($cvmodule == 'Accounts'||$cvmodule=='Leads') {
            //BUG0063586 20230328 客戶线索模块也不允许再次新建全部分类(预置的全部pool_id为0,导致通过判断可以新建成功"全部"分类,潘璐璐说所有用户都不能再次新建"全部"分类(系统已预置))
            if (!$cvid && ($viewname == '全部' || strtolower($viewname) == 'all')){
                ConvertTojsonString("-1", array(), "error");
            }

            if (isset($_SESSION['lvsAccount'][$cvmodule]['pagepublicaccounttype']) && $_SESSION['lvsAccount'][$cvmodule]['pagepublicaccounttype'] != '') {
               
               $accounttype=$_SESSION['lvsAccount'][$cvmodule]['pagepublicaccounttype'];
                    
            } 
            //edit:zkt 20210603 0046191: （81mis.com/kfbcrm）客户管理-客户，点击管理分类，系统默认有一个“全部”分类，可以再建一个同样名字的，没有提示重复

            if($accounttype!='ALLACCOUNT'&&$accounttype!='DEFAULTALLACCOUNT'&&$accounttype!='COMMONACCOUNT')
            {
                $viewname=$_REQUEST['viewName'];
                
            }
            else{
                $accounttype='ALLACCOUNT';
            }
             $ssql .= " and customcategory = '" . $accounttype . "'";
			 if(!empty($_SESSION['lvsAccount']["Accounts"]['pool_id'])){
				  $ssql .= " and pool_id = " . $_SESSION['lvsAccount']["Accounts"]['pool_id'];
                  $pool_id=$_SESSION['lvsAccount']["Accounts"]['pool_id'];
			}
            if(!empty($_SESSION['lvsAccount']["Leads"]['pool_id'])){
                //（亿海蓝）http://124.70.16.104:85/crm，销售线索模块中公海未分配、公海已分配页签，无法修改分类中列表的显示字段。手机号隐藏不掉 
                
				  $ssql .= " and pool_id = " . $_SESSION['lvsAccount']["Leads"]['pool_id'];
                  $pool_id=$_SESSION['lvsAccount']["Leads"]['pool_id'];
			}
            
        }
        elseif ($cvmodule == 'WorkReportList') {
            if (isset($_SESSION['lvs'][$cvmodule]['workreport_logtype']) && $_SESSION['lvs'][$cvmodule]['workreport_logtype'] != '') {
                $accounttype=$_SESSION['lvs'][$cvmodule]['workreport_logtype'];
            }else{
                $accounttype = '0';//全部
            }
            $ssql .= " and customcategory = '" . $accounttype . "'";
        }
        elseif ($cvmodule == 'Reminds') {
            $ssql .= " and customcategory = 'RemindsCategory' ";
        }
		//chj 2021/6/16 46392: （81mis.com/kfbcrm）客户管理-销售线索，南海池，数据分类“全部”；编辑该分类，名称无法编辑操作，保存提示重复
        //客户模块 分类编辑全部。
        if($viewname == '全部')
        {
            $viewname = 'All';
        }
        array_push($sparams, $viewname);
        array_push($sparams, $cvid);
        array_push($sparams, $cvmodule);

        $result = $adb->pquery($ssql, $sparams);
        if ($adb->num_rows($result) > 0) {
            ConvertTojsonString("-1", array(), "error");
        }


    }
    if (strtolower($default_charset) != 'utf-8')
        $viewname = htmlentities($viewname);

    //setStatus=0(Default);1(Private);2(Pending);3(Public).
    //If status is Private ie. 1, only the user created the customview can see it
    //If status is Pending ie. 2, on approval by the admin, the status will become Public ie. 3 and a user can see the customviews created by him and his sub-ordinates.
    if (isset($_REQUEST['setStatus']) && $_REQUEST['setStatus'] != '' && $_REQUEST['setStatus'] != '1')
        $status = $_REQUEST['setStatus'];
    elseif (isset($_REQUEST['setStatus']) && $_REQUEST['setStatus'] != '' && $_REQUEST['setStatus'] == '1')
        //edti by ld tifa 20130306
        // $status = CV_STATUS_PENDING;
        $status = CV_STATUS_PUBLIC;
    else
        $status = CV_STATUS_PRIVATE;

    //2024-09-20 xxy 消息中心，新建的分类目前都是公开
    if($cvmodule == "Reminds" && !isset($_REQUEST['setStatus'])){
        $status = CV_STATUS_PUBLIC;
    }

    $userid = $current_user->id;

    if (isset($_REQUEST["setDefault"])) {

        $setdefault = 1;
    } else {
        $setdefault = 0;
    }

    if (isset($_REQUEST["setMetrics"])) {
        $setmetrics = 1;
    } else {
        $setmetrics = 0;
    }
    //@edit:zsk @date:2024/06/11 @reason:XUQIU20240516-01 查询分类功能优化 增加分组以及常用分类
    if(isset($_REQUEST["customViewGroup"])) {
        $customViewGroup = $_REQUEST["customViewGroup"];
    } else {
        $customViewGroup = null;
    }

    if (isset($_REQUEST["setAsMyCommon"])) {
        $setAsMyCommon = $_REQUEST["setAsMyCommon"];
    } else {
        $setAsMyCommon ='no';
    }
    //$allKeys = array_keys($HTTP_POST_VARS);
    //this is  will cause only the chosen fields to be added to the ld_cvcolumnlist table
    $allKeys = array_keys($_REQUEST);
    /**
     * 每次保存，都会从全部数据分类中取一次数据，再插入一次数据库，
     * 再加上客户自己选择的字段，所以就重复了，现在把两个模块的特别
     * 判断代码注释掉，客户选择什么字段就保存什么字段
     * @reason 14170 库存流水账、即时库存查询数据分类出现重复
     * @author Tujt 2015-04-01
     */

    //<<<<<<<columns>>>>>>>>>>
    $columnslist = [];
    for ($i = 0; $i < count($allKeys); $i++) {
        $string = substr($allKeys[$i], 0, 6);
        if ($string == "column") {
            //the contusion, will cause only the chosen fields to be added to the ld_cvcolumnlist table
            if ($_REQUEST[$allKeys[$i]] != "")
                $columnslist[] = $_REQUEST[$allKeys[$i]];
        }
    }

    $std_filter_list = array();
    $stdfiltercolumn = $_REQUEST["stdDateFilterField"];
    $std_filter_list["columnname"] = $stdfiltercolumn;
    $stdcriteria = $_REQUEST["stdDateFilter"];
    $std_filter_list["stdfilter"] = $stdcriteria;
    $startdate = $_REQUEST["startdate"];
    $enddate = $_REQUEST["enddate"];

    if (empty($startdate) && empty($enddate)) {
        unset($std_filter_list);
    } else {
        $dbCurrentDateTime = date('H:i:s');//edit:can reason:16213: 销售机会>列表：创建数据分类，基本查询，选择时间段：自定义。选择开始日期、结束日期保存。编辑该数据分类，结果：开始日期、结束日期显示空白。
        $startDateTime = $startdate . ' ' . $dbCurrentDateTime;
        $endDateTime = $enddate . ' ' . $dbCurrentDateTime;
        $std_filter_list["startdate"] = $startDateTime;
        $std_filter_list["enddate"] = $endDateTime;
    }


    $advft_criteria = $_REQUEST['advft_criteria'];

    $advft_criteria = Zend_Json::decode($advft_criteria);

    $advft_criteria_groups = $_REQUEST['advft_criteria_groups'];

    $advft_criteria_groups = Zend_Json::decode($advft_criteria_groups);

    $fieldObj = Field::getInstance($cvmodule, $adb);
    $moduleFields = $fieldObj->getModuleFields();
    if (!$cvid) {
        $genCVid = $adb->getUniqueID("ld_customview");
        if ($genCVid != "") {
            $seq_sql = 'SELECT max(sequence) FROM ld_customview WHERE entitytype=?';
            $seq_result = $adb->pquery($seq_sql, array($cvmodule));
            $seq_no = $adb->query_result($seq_result, 0);
            $seq_no += 1;
            //@edit:zsk @date:2024/06/11 @reason:XUQIU20240516-01 查询分类功能优化 增加分组以及常用分类
            $customviewsql = "INSERT INTO ld_customview(cvid, viewname, setdefault, setmetrics, entitytype, status, userid,sequence,groupid)
				VALUES (?,?,?,?,?,?,?,?,?)";
            $customviewparams = array($genCVid, $viewname, $setdefault, $setmetrics, $cvmodule, $status, $userid, $seq_no,$customViewGroup);
            $customviewresult = $adb->pquery($customviewsql, $customviewparams);
            if($setAsMyCommon=='yes') {
                $commonCustomViewByUser=getUsersettingByLabel($cvmodule,$current_user->id,'CommonGroupForCategory');
                if(!empty($commonCustomViewByUser)){
                    $commonCustomViewByUser.=",".$genCVid;
                }
                else
                    $commonCustomViewByUser.=$genCVid;
                setUsersettingByLabel($cvmodule,$current_user->id,'CommonGroupForCategory',$commonCustomViewByUser);
            }
            if ($cvmodule == 'Accounts'||$cvmodule == 'Leads') {
                //edit:can 20210927 048103: （http://4s377767g8.qicp.vip/crm [^]）（客户问题-今策教育）学员管理》学员信息》在“全部（不含公海）”下无法新增数据分类，或新增的分类不显示
                if (!empty($_SESSION['lvsAccount'][$cvmodule]['pagepublicaccounttype']) 
                    && $_SESSION['lvsAccount'][$cvmodule]['pagepublicaccounttype'] != 'DEFAULTALLACCOUNT'
                    && $_SESSION['lvsAccount'][$cvmodule]['pagepublicaccounttype'] != 'COMMONACCOUNT') {
                    $adb->pquery("update ld_customview set customcategory = '" . $_SESSION['lvsAccount'][$cvmodule]['pagepublicaccounttype'] . "' where cvid = $genCVid");
                
                } else {
                    $adb->pquery("update ld_customview set customcategory = 'ALLACCOUNT' where cvid = $genCVid");
                }
				if (isset($_SESSION['lvsAccount'][$cvmodule]['pool_id']) &&  !empty($_SESSION['lvsAccount'][$cvmodule]['pool_id'])) {
                    $adb->pquery("update ld_customview set pool_id = '" . $_SESSION['lvsAccount'][$cvmodule]['pool_id'] . "' where cvid = $genCVid");
                }
            }
            elseif ($cvmodule == 'WorkReportList') {
                if (isset($_SESSION['lvs'][$cvmodule]['workreport_logtype']) && $_SESSION['lvs'][$cvmodule]['workreport_logtype'] != '') {
                    $adb->pquery("update ld_customview set customcategory = '" . $_SESSION['lvs'][$cvmodule]['workreport_logtype'] . "' where cvid = $genCVid");
                } else {
                    $adb->pquery("update ld_customview set customcategory = '0' where cvid = $genCVid");
                }
            }
            elseif ($cvmodule == 'Reminds') {
                $adb->pquery("update ld_customview set customcategory = 'RemindsCategory' where cvid = $genCVid");
            }


            /**显示列设置**/
            if (isset($_REQUEST['ProductListView']) && $_REQUEST['ProductListView'] != "") {
                $listview = explode(',', rtrim($_REQUEST['ProductListView'], ","));
                $j = 0;
                $Detail_table = $focus->Detail_table;

                for ($i = 0; $i < count($listview); $i++) {
                    $column = explode(':', $listview[$i]);
                    $sModule = explode('_', $column[3]);
                    if ($column[0] == $Detail_table && $column[2] == 'remark') {
                        $column[2] = 'products_remark';
                    }
                    $listview[$i] = $column[0] . ":" . $column[1] . ":" . $column[2] . ":" . $sModule[0] . "_" . getTranslatedString($sModule[1]) . ":" . $column[4];
                    //str_replace("$sModule[1]", getTranslatedString($sModule[1],$sModule[0]), "$listview[$i]");
                    //getTranslatedString($moduleName[1],$moduleName[0])
                    $isModule = $cvmodule;
                    if ($isModule == 'ServiceCharge') $isModule = 'Accounts';
                    if ($sModule[0] == $isModule)    //主表信息
                    {
                        $zListView[$j] = $listview[$i];
                    } else    //产品明细表信息
                    {
                        $yListView[count($listview) + $j] = $listview[$i];
                    }
                    $j++;
                }
                if ($yListView != null && $zListView != null) {
                    $zListView = array_merge($zListView, $yListView);
                } else if ($yListView != null) {
                    $zListView = $yListView;
                }

                if ($cvmodule == 'Attachment' || $cvmodule == 'Documents') {
                    $tabwithproductView_bol = get_file_address($cvmodule, $cvmodule . 'Details');
                } else {
                    $tabwithproductView_bol = get_file_address($cvmodule, 'ProductDetails');
                }
                if ($tabwithproductView_bol === false) {
                    $tabwithproductView_bol = get_file_address($cvmodule, '' . $cvmodule . 'DetailFieldsHtml');
                }
                $cnt = count($zListView);
                //print_r($zListView);
                foreach ($zListView as $key => $var) {
                    //产品明细保存
                    if ($tabwithproductView_bol) {
                        $adb->pquery("insert into ld_tabwithproductview(tabid,columns,sequence,cvid) values 
                        ($cv_tabid,'" . $var . "',$key,$genCVid);");
                    } else {    //非产品明细保存
                        $adb->pquery('INSERT INTO ld_cvcolumnlist (cvid,columnindex,columnname) VALUES 
                        (?,?,?)', array($genCVid, $key, $var));
                    }
                }
                //复制 - 列宽
                if (!empty($_REQUEST['viewcopy']) && !empty($_REQUEST['viewcopy_cvid'])) {
                    $oCustomView = CustomView::getInstance($cvmodule);
                    $column_width_infos = $oCustomView->getListWidth($_REQUEST['viewcopy_cvid']);
                    updateListWidth($zListView, $column_width_infos, $cvmodule, $genCVid);

                }
            }
            //排序方式设置保存
            if (isset($_REQUEST['SortOrderList']) && $_REQUEST['SortOrderList'] != '') {
                //wym BUG0074171
                $sortorderlist = json_decode($_REQUEST['SortOrderList']);
                for ($i = 0; $i < count($sortorderlist); $i++) {
                    $sortorderinfo = explode('|', $sortorderlist[$i]);
                    $adb->pquery('INSERT INTO ld_cvcolumnlistsort(cvid,columnname,sorttype) VALUES (?,?,?)', array($genCVid, $sortorderinfo[0], $sortorderinfo[1]));
                }
            }
            //设置默认
            if ($setdefault == 1) {
               if(!empty($accounttype))
               {
                    $sql='select customcategory  from ld_customview where cvid=? ';
                    $tmpresult=$adb->pquery($sql,array($genCVid));
                    $accounttype=$adb->query_result($tmpresult,0,'customcategory');
                    $pool_id = $adb->query_result($tmpresult,0,'pool_id');
                    if($accounttype=='ALLACCOUNT')
                    {
                        $pool_id=0;
                    }


               }

               //BUG20241212-02 ls 241216 	admin账号，客户管理，公海：销售二部的分类“客户”，设置了默认和公开。 ceshi账号，分类的默认没有生效(需要根据公海池设置默认，否则所有公海池只有一个默认分类)
                if(!empty($accounttype)&&!empty($pool_id)){
                    if ($status == CV_STATUS_PUBLIC) {
                        $sql = "update ld_customview set setdefault=0 where entitytype=? and customcategory=? and pool_id =? and cvid<>" . $genCVid;
                    }else{
                        $sql = "update ld_customview set setdefault=0 where entitytype=? and customcategory=? and pool_id =? and userid = $current_user->id and cvid<>" . $genCVid;//普通成员设置的默认数据分类不能顶掉其他人的默认分类
                    }
                    $adb->pquery($sql, array($cvmodule,$accounttype,$pool_id));
                }else{
                    if ($status == CV_STATUS_PUBLIC) {
                        $sql = "update ld_customview set setdefault=0 where entitytype=? and cvid<>" . $genCVid;
                    }else{
                        $sql = "update ld_customview set setdefault=0 where entitytype=? and userid = $current_user->id and cvid<>" . $genCVid;//普通成员设置的默认数据分类不能顶掉其他人的默认分类
                    }
                    $adb->pquery($sql, array($cvmodule));
                }
               
                if(!empty($accounttype)&&!empty($pool_id))
                {
                    //edit:can  20220808  54439：查询分类：每个用户登陆系统时显示自己设置“自定义显示默认分类”
                    $sql_result = $adb->pquery("SELECT * FROM ld_user_module_preferences WHERE userid = ? AND tabid = ? and pool_id=? and customcategory=?",
                             array($current_user->id, $cv_tabid,$pool_id,$accounttype));
                }
                else if(!empty($accounttype))
                {
                    //edit:can  20220808  54439：查询分类：每个用户登陆系统时显示自己设置“自定义显示默认分类”
                    $sql_result = $adb->pquery("SELECT * FROM ld_user_module_preferences WHERE userid = ? AND tabid = ? and  customcategory=?",
                             array($current_user->id, $cv_tabid,$accounttype));
                }
                else
                    $sql_result = $adb->pquery("SELECT * FROM ld_user_module_preferences WHERE userid = ? AND tabid = ?", array($current_user->id, $cv_tabid));
                
                if ($adb->num_rows($sql_result) > 0) {
                    $preferencesid=$adb->query_result($sql_result,0,'preferencesid');
                    $updatedefaultsql = "UPDATE ld_user_module_preferences SET default_cvid = ?,pool_id=? ,customcategory=? WHERE preferencesid=?";
                    $updatedefaultresult = $adb->pquery($updatedefaultsql, array($genCVid,$pool_id,$accounttype, $preferencesid));
                } else {
                    $insertdefaultsql = "INSERT INTO ld_user_module_preferences(userid, tabid, default_cvid,pool_id,customcategory) 
                        VALUES (?,?,?,?,?)";
                    $insertdefaultresult = $adb->pquery($insertdefaultsql, array($userid, $cv_tabid, $genCVid,$pool_id,$accounttype));
                }
            } else {
                /*
               edit:Can
               date:20130605
               reason:4100: 视图方案问题，设置默认视图时产生的问题
               */
                $sql_result = $adb->pquery("SELECT 1 FROM ld_user_module_preferences WHERE userid = ? AND tabid = ? AND default_cvid=?", array($current_user->id, $cv_tabid, $genCVid));
                //echo "1dd$genCVid";
                //exit();
                if ($adb->num_rows($sql_result) > 0) {
                    $deletedefaultsql = "DELETE FROM ld_user_module_preferences WHERE userid = ? AND tabid = ? AND default_cvid=?";
                    $deletedefaultresult = $adb->pquery($deletedefaultsql, array($current_user->id, $cv_tabid, $genCVid));
                }
            }


            if (isset($_REQUEST['group']) && $_REQUEST['group'] != '') ;
            else {
                for ($i = 0; $i < count($columnslist); $i++) {
                    $columnsql = "INSERT INTO ld_cvcolumnlist (cvid, columnindex, columnname) VALUES (?,?,?)";
                    $columnparams = array($genCVid, $i, $columnslist[$i]);
                    $columnresult = $adb->pquery($columnsql, $columnparams);
                }
            }


            if ($std_filter_list["columnname"] != "") {
                $stdfiltersql = "INSERT INTO ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate) VALUES (?,?,?,?,?)";
                $stdfilterparams = array($genCVid, $std_filter_list["columnname"], $std_filter_list["stdfilter"], $adb->formatDate($std_filter_list["startdate"], true), $adb->formatDate($std_filter_list["enddate"], true));
                $stdfilterresult = $adb->pquery($stdfiltersql, $stdfilterparams);
            }
            if (!empty($advft_criteria)) {

                foreach ($advft_criteria as $column_index => $column_condition) {

                    if (empty($column_condition)) continue;

                    $adv_filter_column = $column_condition["columnname"];
                    $adv_filter_comparator = $column_condition["comparator"];
                    $adv_filter_value = $column_condition["value"];
                    $adv_filter_column_condition = $column_condition["columncondition"];
                    $adv_filter_groupid = $column_condition["groupid"];

                    $column_info = explode(":", $adv_filter_column);

                    $fieldName = $column_info[2];
                    $fieldObj = $moduleFields[$fieldName];
                    $newModule = explode('_', $column_info[3]);
                    $fieldType = '';
                    if ($newModule[0] == $cvmodule) {
                        $fieldType = $fieldObj->getFieldDataType();
                    } else {
                        if ($column_info[4] == 'D') {
                            $fieldType == 'date';
                        }
                    }
                    $temp_val = explode(",", $adv_filter_value);
                    if (($fieldType == 'date' || ($fieldType == 'time' && $fieldName != 'time_start' && $fieldName != 'time_end') || ($fieldType == 'datetime')) && ($fieldType != '' && $adv_filter_value != '')) {
                        $val = array();
                        for ($x = 0; $x < count($temp_val); $x++) {

                            if (trim($temp_val[$x]) != '') {
                                $date = new DateTimeField(trim($temp_val[$x]));
                                if ($fieldType == 'date') {
                                    $val[$x] = DateTimeField::convertToDBFormat(
                                        trim($temp_val[$x]));
                                } elseif ($fieldType == 'datetime') {
                                    $val[$x] = $date->getDBInsertDateTimeValue();
                                } else {
                                    $val[$x] = $date->getDBInsertTimeValue();
                                }
                            }
                        }
                        $adv_filter_value = implode(",", $val);
                    }
                    $irelcriteriasql = "INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) VALUES (?,?,?,?,?,?,?)";
                    $irelcriteriaresult = $adb->pquery($irelcriteriasql, array($genCVid, $column_index, $adv_filter_column, $adv_filter_comparator, $adv_filter_value, $adv_filter_groupid, $adv_filter_column_condition));
                    // Update the condition expression for the group to which the condition column belongs
                    $groupConditionExpression = '';
                    if (!empty($advft_criteria_groups[$adv_filter_groupid]["conditionexpression"])) {
                        $groupConditionExpression = $advft_criteria_groups[$adv_filter_groupid]["conditionexpression"];
                    }
                    $groupConditionExpression = $groupConditionExpression . ' ' . $column_index . ' ' . $adv_filter_column_condition;
                    $advft_criteria_groups[$adv_filter_groupid]["conditionexpression"] = $groupConditionExpression;
                }
            }
            if (!empty($advft_criteria_groups)) {
                foreach ($advft_criteria_groups as $group_index => $group_condition_info) {

                    if (empty($group_condition_info)) continue;
                    if (empty($group_condition_info["conditionexpression"])) continue; // Case when the group doesn't have any column criteria

                    $irelcriteriagroupsql = "INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression) VALUES (?,?,?,?)";
                    $irelcriteriagroupresult = $adb->pquery($irelcriteriagroupsql, array($group_index, $genCVid, $group_condition_info["groupcondition"], $group_condition_info["conditionexpression"]));
                }
            }/* else {
                $irelcriteriagroupsql = "INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression) VALUES (?,?,?,?)";
                $irelcriteriagroupresult = $adb->pquery($irelcriteriagroupsql, array($group_index, $genCVid, 0, ''));
            }*/

            $cvid = $genCVid;
        }
    } else {

        /**页面百分比**/
        //  $adb->pquery("update ld_customview set pagewidthpercent = '".$_REQUEST['PageWidthPercent']."' where cvid = $cvid");
        /**显示列设置**/

        if (isset($_REQUEST['ProductListView']) && $_REQUEST['ProductListView'] != "") {
            if ($cvmodule == 'Attachment' || $cvmodule == 'Documents') {
                $tabwithproductView_bol = get_file_address($cvmodule, $cvmodule . 'Details');
            } else {
                $tabwithproductView_bol = get_file_address($cvmodule, 'ProductDetails');
            }


            if ($tabwithproductView_bol === false) {
                $tabwithproductView_bol = get_file_address($cvmodule, '' . $cvmodule . 'DetailFieldsHtml');
            }
            //分类编辑  删除之前的分类数据
            if ($tabwithproductView_bol)
                $adb->pquery("delete from ld_tabwithproductview where tabid = $cv_tabid and cvid = $cvid");
            else
                $adb->pquery("delete from ld_cvcolumnlist where cvid = $cvid");
            //删除之前的分类排序设置
            $adb->pquery('DELETE FROM ld_cvcolumnlistsort WHERE cvid =?', array($cvid));
            $listview = explode(',', rtrim($_REQUEST['ProductListView'], ","));

            $j = 0;
            $Detail_table = $focus->Detail_table;

            for ($i = 0; $i < count($listview); $i++) {
                $column = explode(':', $listview[$i]);
                $sModule = explode('_', $column[3]);

                if ($column[0] == $Detail_table && $column[2] == 'remark' && get_file_address($cvmodule, "ProductDetails")) {
                    //36423: （1.6）佣金单列表界面>管理分类>编辑分类>显示列设置：将“佣金单明细-备注”字段设置为已选字段，保存后没有生效。（需要补丁）
                    $column[2] = 'products_remark';
                }
                $listview[$i] = $column[0] . ":" . $column[1] . ":" . $column[2] . ":" . $sModule[0] . "_" . $sModule[1] . ":" . $column[4];
                //str_replace("$sModule[1]", getTranslatedString($sModule[1],$sModule[0]), "$listview[$i]");
                $isModule = $cvmodule;
                $isModule = $cvmodule;
                if ($isModule == 'Attachments' || $isModule == 'Documents') {
                    if ($column[0] == 'ld_attachmentsforbillsdetails') {
                        $sModule[0] = 'ld_attachmentsforbillsdetails';
                    }
                    if ($column[0] == 'ld_attachments') {
                        $sModule[0] = 'ld_attachments';
                    }
                }

                if ($isModule == 'ServiceCharge') $isModule = 'Accounts';

                if ($sModule[0] == $isModule)    //主表信息
                {
                    $zListView[$j] = $listview[$i];
                } else //产品明细表信息
                {
                    $yListView[count($listview) + $j] = $listview[$i];
                }
                $j++;
            }

            if ($yListView != null && $zListView != null) {
                $zListView = array_merge($zListView, $yListView);

            } else if ($yListView != null) {
                $zListView = $yListView;
            }
            $cnt = count($zListView);


            foreach ($zListView as $key => $var) {
                //产品明细保存
                if ($tabwithproductView_bol) {
                    $adb->pquery("insert into ld_tabwithproductview(tabid,columns,sequence,cvid) values 
                    ($cv_tabid,'" . $var . "',$key,$cvid);");


                } else//非产品明细保存
                {
                    $adb->pquery('INSERT INTO ld_cvcolumnlist (cvid,columnindex,columnname) VALUES 
                    (?,?,?)', array($cvid, $key, $var));
                }
            }

        }

        //排序方式设置保存
        if (isset($_REQUEST['SortOrderList']) && $_REQUEST['SortOrderList'] != '' && $cvmodule != 'InventoryAccount' && $cvmodule != 'InventoryQuery') {
            //wym BUG0074171
            $sortorderlist = json_decode($_REQUEST['SortOrderList']);
            for ($i = 0; $i < count($sortorderlist); $i++) {
                $sortorderinfo = explode('|', $sortorderlist[$i]);
                $adb->pquery('INSERT INTO ld_cvcolumnlistsort(cvid,columnname,sorttype) VALUES (?,?,?)', array($cvid, $sortorderinfo[0], $sortorderinfo[1]));
            }
        }
        if ($tabwithproductView_bol) {
            $sql = 'select columns from  ld_tabwithproductview where tabid=\'' . $cv_tabid . '\' and  cvid=? order by sequence';

        } else {
            $sql = 'SELECT columnname AS columns FROM  ld_cvcolumnlist WHERE cvid=? ORDER BY columnindex';
        }

        //编辑 - 列宽
        if (!empty($zListView)) {
            $oCustomView = CustomView::getInstance($cvmodule);
            $column_width_infos = $oCustomView->getListWidth($cvid);

            $sql = 'DELETE FROM ld_list_headerwidth  WHERE module=? AND userid=? AND type=? AND relateid=? ';
            $adb->pquery($sql, array($cvmodule, $current_user->id, 'customview', $cvid));
            $adb->pquery($sql, array($cvmodule, $current_user->id, 'popup_customview', $cvid));
            updateListWidth($zListView, $column_width_infos, $cvmodule, $cvid);
        }

        if ($is_admin == true || $current_user->id) {
            $sql = 'SELECT viewname FROM ld_customview WHERE cvid=?';
            $result = $adb->pquery($sql, array($cvid));
            $prevviewname = $adb->query_result($result, 0, 0);
            if (strtolower($prevviewname) == 'all') {
                //32463: 单据序时簿界面：编辑“全部”分类，结果分类名称是显示的“ALL”
                $updatecvsql = "UPDATE ld_customview
					SET  setmetrics = ?, status = ?, setdefault=? WHERE cvid = ?";
                $updatecvparams = array($setmetrics, $status, $setdefault, $cvid);
                $updatecvresult = $adb->pquery($updatecvsql, $updatecvparams);
                updateApproveListWidth($zListView, $cvmodule);
            } else {
                $updatecvsql = "UPDATE ld_customview
					SET viewname = ?, setmetrics = ?, status = ?, setdefault=? WHERE cvid = ?";
                $updatecvparams = array($viewname, $setmetrics, $status, $setdefault, $cvid);
                $updatecvresult = $adb->pquery($updatecvsql, $updatecvparams);


            }
            //@edit:zsk @date:2024/06/11 @reason:XUQIU20240516-01 查询分类功能优化 增加分组以及常用分类
            $customViewGroupsql = "update ld_customview set groupid=? where cvid=?";
            $customViewGroupparams = array($customViewGroup,$cvid);
            $customviewresult = $adb->pquery($customViewGroupsql, $customViewGroupparams);
            if($setAsMyCommon=='yes') {
                //获取当前用户的常用查询分类列表
                $customView = CustomView::getInstance($cvmodule);
                $commonCustomViewByUser=getUsersettingByLabel($cvmodule,$current_user->id,'CommonGroupForCategory');
                $commonCustomViewByUserArray = explode(",", $commonCustomViewByUser);
                //如果分类不在常用分类中
                if (!(in_array($cvid, $commonCustomViewByUserArray))) {
                    if(!empty($commonCustomViewByUser)){
                        $commonCustomViewByUser.=",".$cvid;
                    }
                    else
                        $commonCustomViewByUser.=$cvid;
                    setUsersettingByLabel($cvmodule,$current_user->id,'CommonGroupForCategory',$commonCustomViewByUser);
                }
            }
            else{
                //获取当前用户的常用查询分类列表
                $customView = CustomView::getInstance($cvmodule);
                $commonCustomViewByUser=getUsersettingByLabel($cvmodule,$current_user->id,'CommonGroupForCategory');
                $commonCustomViewByUserArray = explode(",", $commonCustomViewByUser);
                if (in_array($cvid, $commonCustomViewByUserArray)) {
                    // 找到并移除指定的groupid
                    $commonCustomViewByUserArray = array_diff($commonCustomViewByUserArray, array($cvid));
                }
                // 将数组重新转换为逗号分隔的字符串
                $newCommonCustomViewByUser = implode(",", $commonCustomViewByUserArray);
                setUsersettingByLabel($cvmodule,$current_user->id,'CommonGroupForCategory',$newCommonCustomViewByUser);
            }

            if ($setdefault == 1) {
                //客户模块 分类编辑全部。
                if ($cvmodule == 'Accounts'||$cvmodule == 'Leads') {
                    if (isset($_SESSION['lvsAccount'][$cvmodule]['pagepublicaccounttype']) && $_SESSION['lvsAccount'][$cvmodule]['pagepublicaccounttype'] != '') {
                       
                        $accounttype=$_SESSION['lvsAccount'][$cvmodule]['pagepublicaccounttype'];
                    } else {
                        $accounttype='ALLACCOUNT';
                    }
                    if($accounttype=='ALLACCOUNT')
                    {
                        $pool_id=0;
                    }
                }
                elseif ($cvmodule == 'WorkReportList') {
                    if (isset($_SESSION['lvs'][$cvmodule]['workreport_logtype']) && $_SESSION['lvs'][$cvmodule]['workreport_logtype'] != '') {
                        $accounttype=$_SESSION['lvs'][$cvmodule]['workreport_logtype'];
                    } else {
                        $accounttype='0';
                    }
                }
                
                if(!empty($accounttype))
                {
                    $tmpsql='select customcategory  from ld_customview where cvid=? ';
                    $tmpresult=$adb->pquery($tmpsql,array($cvid));
                    $accounttype=$adb->query_result($tmpresult,0,'customcategory');
                    $pool_id = $adb->query_result($tmpresult,0,'pool_id');
                }


                if(!empty($accounttype)&&!empty($pool_id)){
                    if ($status == CV_STATUS_PUBLIC) {
                        $sql = "update ld_customview set setdefault=0 where entitytype=? and customcategory=? and pool_id =? and cvid<>" . $cvid;
                    }else{
                        $sql = "update ld_customview set setdefault=0 where entitytype=? and customcategory=? and pool_id =? and userid = $current_user->id and cvid<>" . $cvid;
                    }
                    $adb->pquery($sql, array($cvmodule,$accounttype,$pool_id));
                }else{
                    if ($status == CV_STATUS_PUBLIC) { //设为默认分类且公开，只能有一个默认分类，设为默认且不为公开，应该根据成员分类为条件，每个成员都有自己的一个分类
                        $sql = "update ld_customview set setdefault=0 where entitytype=? and cvid<>" . $cvid;
                    }else{
                        $sql = "update ld_customview set setdefault=0 where entitytype=? and userid = $current_user->id and cvid<>" . $cvid;
                    }
                    $adb->pquery($sql, array($cvmodule));
                }

                 if(!empty($accounttype)&&!empty($pool_id))
                {
                    //edit:can  20220808  54439：查询分类：每个用户登陆系统时显示自己设置“自定义显示默认分类”
                    $sql_result = $adb->pquery("SELECT * FROM ld_user_module_preferences WHERE userid = ? AND tabid = ? and pool_id=? and customcategory=?",
                             array($current_user->id, $cv_tabid,$pool_id,$accounttype));
                }
                else if(!empty($accounttype))
                {
                    //edit:can  20220808  54439：查询分类：每个用户登陆系统时显示自己设置“自定义显示默认分类”
                    $sql_result = $adb->pquery("SELECT * FROM ld_user_module_preferences WHERE userid = ? AND tabid = ? and  customcategory=?",
                             array($current_user->id, $cv_tabid,$accounttype));
                }
                else
                    $sql_result = $adb->pquery("SELECT * FROM ld_user_module_preferences WHERE userid = ? AND tabid = ?", array($current_user->id, $cv_tabid));
              
                if ($adb->num_rows($sql_result) > 0) {
                    $preferencesid=$adb->query_result($sql_result,0,'preferencesid');
                    $updatedefaultsql = "UPDATE ld_user_module_preferences SET default_cvid = ?,pool_id=?,customcategory=? WHERE preferencesid = ?";
                    $updatedefaultresult = $adb->pquery($updatedefaultsql, array($cvid,$pool_id,$accounttype, $preferencesid));
                } else {
                    $insertdefaultsql = "INSERT INTO ld_user_module_preferences(userid, tabid, default_cvid,pool_id,customcategory) 
                        VALUES (?,?,?,?,?)";
                    $insertdefaultresult = $adb->pquery($insertdefaultsql, array($userid, $cv_tabid, $cvid,$pool_id,$accounttype));
                }
            } else {
                /*
                edit:Can
                date:20130605
                reason:4100: 视图方案问题，设置默认视图时产生的问题
                */
                $sql_result = $adb->pquery("SELECT * FROM ld_user_module_preferences WHERE userid = ? AND tabid = ? AND default_cvid= ?", array($current_user->id, $cv_tabid, $cvid));

                if ($adb->num_rows($sql_result) > 0) {
                    $deletedefaultsql = "DELETE FROM ld_user_module_preferences WHERE userid = ? AND tabid = ? AND default_cvid=?";
                    $deletedefaultresult = $adb->pquery($deletedefaultsql, array($current_user->id, $cv_tabid, $cvid));
                }
            }

            $deletesql = "DELETE FROM ld_cvstdfilter WHERE cvid = ?";
            $deleteresult = $adb->pquery($deletesql, array($cvid));

            $deletesql = "DELETE FROM ld_cvadvfilter WHERE cvid = ?";
            $deleteresult = $adb->pquery($deletesql, array($cvid));

            $deletesql = "DELETE FROM ld_cvadvfilter_grouping WHERE cvid = ?";
            $deleteresult = $adb->pquery($deletesql, array($cvid));
            $genCVid = $cvid;

            if ($std_filter_list["columnname"] != "") {
                $stdfiltersql = "INSERT INTO ld_cvstdfilter (cvid,columnname,stdfilter,startdate,enddate) VALUES (?,?,?,?,?)";
                $stdfilterparams = array($genCVid, $std_filter_list["columnname"], $std_filter_list["stdfilter"], $adb->formatDate($std_filter_list["startdate"], true), $adb->formatDate($std_filter_list["enddate"], true));
                $stdfilterresult = $adb->pquery($stdfiltersql, $stdfilterparams);

            }
            if (!empty($advft_criteria)) {
                foreach ($advft_criteria as $column_index => $column_condition) {

                    if (empty($column_condition)) continue;

                    $adv_filter_column = $column_condition["columnname"];
                    $adv_filter_comparator = $column_condition["comparator"];
                    $adv_filter_value = $column_condition["value"];
                    $adv_filter_column_condition = $column_condition["columncondition"];
                    $adv_filter_groupid = $column_condition["groupid"];

                    $column_info = explode(":", $adv_filter_column);

                    $fieldName = $column_info[2];
                    $fieldObj = $moduleFields[$fieldName];
                    $newModule = explode('_', $column_info[3]);
                    $fieldType = '';
                    if ($newModule[0] == $cvmodule) {
                        $fieldType = $fieldObj->getFieldDataType();

                    } else {
                        if ($column_info[4] == 'D') {
                            $fieldType == 'date';
                        }
                    }
                    $temp_val = explode(",", $adv_filter_value);
                    if (($fieldType == 'date' || ($fieldType == 'time' && $fieldName != 'time_start' && $fieldName != 'time_end') || ($fieldType == 'datetime')) && ($fieldType != '' && $adv_filter_value != '')) {
                        $val = array();
                        for ($x = 0; $x < count($temp_val); $x++) {
                            if (trim($temp_val[$x]) != '') {
                                $date = new DateTimeField(trim($temp_val[$x]));
                                if ($fieldType == 'date') {
                                    $val[$x] = DateTimeField::convertToDBFormat(
                                        trim($temp_val[$x]));
                                } elseif ($fieldType == 'datetime') {
                                    $val[$x] = $date->getDBInsertDateTimeValue();
                                } else {
                                    $val[$x] = $date->getDBInsertTimeValue();
                                }
                            }
                        }
                        $adv_filter_value = implode(",", $val);
                    }

                    $irelcriteriasql = "INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) VALUES (?,?,?,?,?,?,?)";
                    $irelcriteriaresult = $adb->pquery($irelcriteriasql, array($genCVid, $column_index, $adv_filter_column, $adv_filter_comparator, $adv_filter_value, $adv_filter_groupid, $adv_filter_column_condition));

                    // Update the condition expression for the group to which the condition column belongs
                    $groupConditionExpression = '';
                    if (!empty($advft_criteria_groups[$adv_filter_groupid]["conditionexpression"])) {
                        $groupConditionExpression = $advft_criteria_groups[$adv_filter_groupid]["conditionexpression"];
                    }
                    $groupConditionExpression = $groupConditionExpression . ' ' . $column_index . ' ' . $adv_filter_column_condition;
                    $advft_criteria_groups[$adv_filter_groupid]["conditionexpression"] = $groupConditionExpression;
                }
            }

            if (!empty($advft_criteria_groups)) {
                foreach ($advft_criteria_groups as $group_index => $group_condition_info) {

                    if (empty($group_condition_info)) continue;
                    if (empty($group_condition_info["conditionexpression"])) continue; // Case when the group doesn't have any column criteria

                    $irelcriteriagroupsql = "INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression) VALUES (?,?,?,?)";
                    $irelcriteriagroupresult = $adb->pquery($irelcriteriagroupsql, array($group_index, $genCVid, $group_condition_info["groupcondition"], $group_condition_info["conditionexpression"]));
                }
            } /*else {
                $irelcriteriagroupsql = "INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression) VALUES (?,?,?,?)";
                $irelcriteriagroupresult = $adb->pquery($irelcriteriagroupsql, array($group_index, $genCVid, 0, ''));
            }*/
        }
    }

    // @edit:dong @date:2020/10/28 @reason: 数据分类变为模块 设为链接模块 编辑的时候
    if (isset($_REQUEST['setaslinkmodule']) && $_REQUEST['setaslinkmodule'] != '') {
        $setaslinkmodule = $_REQUEST['setaslinkmodule'];
        //查看是否存在ld_linkmodulecustom表中
        if($cvmodule=='Events')
        {
            $cvmodule='Calendar';
        }
        $sql = 'SELECT id,scope FROM ld_linkmodulecustom WHERE linkmodule =? AND entitytype=\'category\'  AND  linkcvid =?';
        $result = $adb->pquery($sql, array($cvmodule, $cvid));
        $num_row = $adb->num_rows($result);

        if ($num_row > 0 && $setaslinkmodule == 0) {
            //取消设置为链接模块执行以下步骤
            $scope = $adb->query_result($result, 0, 1);
            $id = $adb->query_result($result, 0, 0);
//            删除权限表数据
            if ($scope != 'all') {
                $sql = 'DELETE FROM ld_linkmodulecustom2user WHERE linkmodulecustomid =?';
                $adb->pquery($sql, array($id));
            }
            //删除自定义模块数据
            $sql = 'DELETE FROM ld_linkmodulecustom WHERE linkmodule =? AND entitytype=\'category\'  AND  linkcvid =?';
            $adb->pquery($sql, array($cvmodule, $cvid));
            // @edit:dong @date:2020/10/29 @reason: bug0043060
            //清除缓存
            unsetCache('cache_getparenttabrelinfo');

        } elseif ($setaslinkmodule == 1) {
            //新增自定义链接模块
            $oCustomView = CustomView::getInstance($cvmodule);
            //获取全部数据分类
            $customviewlist = $oCustomView->getCvListByModule();
            $zh_label = getTranstab($cvmodule) . '_'; //添加模块名在设置里面容易区分
            $zh_label .= $customviewlist[$cvid]['viewname'] == 'All' ? getFixedLabel('ALL') : $customviewlist[$cvid]['viewname'];//数据分类名称
            //获取客户、销售线索页签分类
            if( $_SESSION['lvsAccount'][$cvmodule]['pagepublicaccounttype']){
                $pagepublicaccounttype=$_SESSION['lvsAccount'][$cvmodule]['pagepublicaccounttype'];
            }else if(isset($_REQUEST['accounttype'])){
                $pagepublicaccounttype = $_REQUEST['accounttype'];
            }

            $pool_id = $customviewlist[$cvid]['pool_id'];
            $url = 'index.php?module=' . $cvmodule . '&file=index&action=' . $cvmodule . 'Ajax&start=1&viewname=' . $cvid . '&switchview=' . $cvid . '&query_session=0&parenttab=&SearchScope=SmOwner_Search_All&pagepublicaccounttype='.$pagepublicaccounttype.'&waretype=0&wareid=0&ajaxtype=ld_linkmodulecustom&pool_id='.$pool_id;
            if($cvmodule == 'WorkSheet'){
                $worksheet_status = $_SESSION['lvs'][$cvmodule]['worksheet_status'];
                if($worksheet_status != ""){
                    $url .= '&worksheet_status='.$worksheet_status;
                }
            }
            
            if($num_row>0){ //更新历史数据
                $id = $adb->query_result($result, 0, 'id');
                $adb->pquery("UPDATE ld_linkmodulecustom SET url=? WHERE id=?", array($url, $id));
            }else if($num_row==0){
                $status = 'yes';
                $scope = 'all';
                $entitytype = 'category';
                $sql = "insert into ld_linkmodulecustom (zh_label,en_label,url,status,scope,entitytype,linkmodule,linkcvid) SELECT '$zh_label','$zh_label','$url','$status','$scope','$entitytype','$cvmodule','$cvid' FROM  dual WHERE  not   exists( SELECT  1 from ld_linkmodulecustom where linkmodule ='.$cvmodule.' and entitytype='category'  and  linkcvid ='.$cvid.' )";
                $adb->pquery($sql);
                $id = $adb->getLastInsertID();
                $adb->pquery("UPDATE ld_linkmodulecustom SET name=? WHERE id=?", array("CRMLinkModuleCustom" . $id, $id));
            }
        }
    }

}
//
function updateApproveListWidth($zListView, $cvmodule)
{

    global $adb, $current_user;
    $sql = 'SELECT * FROM ld_list_headerwidth WHERE   type=?  AND module=? ORDER BY id ASC ';
    $result = $adb->pquery($sql, array('approve', $cvmodule));
    $rows = $adb->num_rows($result);
    $sql = 'DELETE  FROM ld_list_headerwidth WHERE   type=?  AND module=?';
    $adb->pquery($sql, array('approve', $cvmodule));
    if ($rows > 0) {
        for ($i = 0; $i <= 2; $i++) {
            //审批中心固定列头
            $columns = $adb->query_result($result, $i, 'columns');
            if (stripos($columns, "tmp_approve:") !== false) {
                $td_width = $adb->query_result($result, $i, 'header_width');
            }
            $SQL = 'INSERT INTO ld_list_headerwidth(module,type,userid,header_width,columns,relateid)VALUE(?,?,?,?,?,?)';
            $adb->pquery($SQL, array($cvmodule, 'Approve', $current_user->id, $td_width, $columns, 0));
        }

        foreach ($zListView as $content) {
            $td_width = 65;
            for ($i = 2; $i < $rows; $i++) {
                $columns = $adb->query_result($result, $i, 'columns');
                if (stripos($content, $columns) !== false) {
                    $td_width = $adb->query_result($result, $i, 'header_width');
                    break;
                }
            }


            $SQL = 'INSERT INTO ld_list_headerwidth(module,type,userid,header_width,columns,relateid)VALUE(?,?,?,?,?,?)';
            $adb->pquery($SQL, array($cvmodule, 'Approve', $current_user->id, $td_width, $content, 0));

        }
    }

}

function updateListWidth($zListView, $column_width_infos, $cvmodule, $genCVid)
{
    global $adb, $current_user;

    if (!empty($zListView) && !empty($column_width_infos)) {
        if (strstr(current(array_keys($column_width_infos)), ":chkbox:")) {
            $column_width[current(array_keys($column_width_infos))] = $column_width_infos[current(array_keys($column_width_infos))];
        }
        foreach ($zListView as $columns) {
            $columns_arr = explode(':', $columns);
            $colun_fieldlabel = explode('_', $columns_arr[3]);
            $columns_str = $columns_arr[0] . ':' . $columns_arr[1] . ':' . $columns_arr[2] . ':' . $colun_fieldlabel[0];
            if (isset($column_width_infos[$columns_str])) {
                $column_width[$columns_str] = $column_width_infos[$columns_str];
            } else {
                $column_width[$columns_str] = 65;
            }
        }
        if (!empty($column_width)) {
            foreach ($column_width as $columns => $td_width) {
                $SQL = 'INSERT INTO ld_list_headerwidth(module,type,userid,header_width,columns,relateid)VALUE(?,?,?,?,?,?)';
                $adb->pquery($SQL, array($cvmodule, 'customview', $current_user->id, $td_width, $columns, $genCVid));
            }
        }
    }
}

unsetCacheDirectory('customview');

$SearchScope = "";
if (isset($_REQUEST['SearchScope'])) {
    $SearchScope = $_REQUEST['SearchScope'];
}
if ($cvmodule == 'Events')
    $cvmodule = 'Calendar';
if ($_REQUEST['refreshpage'] == 'no') {
    $tmprecord = $_REQUEST["record"];
    if (strtolower($viewname) == 'all') {
        $viewname = getFixedLabel('ALL');
    }
    $arr = array('viewname' => $viewname, "cvid" => $cvid, 'isadmin' => $current_user->is_admin
                 , 'copytext' => getFixedLabel("COPY")
                 , 'uptext' => getFixedLabel('MOVEUP')
                 , 'downtext' => getFixedLabel('MOVEDOWN')
                 , 'deletetext' => getFixedLabel('DELETE')
                 , 'edittext' => getFixedLabel('EDIT'));
    if (empty($tmprecord)) {
        $customview = CustomView::getInstance($_REQUEST['cvmodule']);
        $smarty = new lingdangCRM_Smarty();
        $viewid = $customview->getViewId($_REQUEST['cvmodule']);
        $smarty->assign("MODULE", $_REQUEST['cvmodule']);
        $smarty->assign("fldname", "SelectCustomView");
        $smarty->assign("VIEWID", $viewid);
        $smarty->assign("CUSTOMVIEW_OPTION", $customview->getCustomViewAll($viewid, $_REQUEST['cvmodule']));

        $content = $smarty->fetch("SelectCustomView.tpl");
        $arr['datacategorycontent'] = $content;
    }
    if($cvmodule == 'Reminds'){
        crm_load_class_file("RemindsCustomView",'modules/Reminds');
        $cvmodule_customView = new RemindsCustomView();
        $customview_html = $cvmodule_customView->getCustomView_RemindsCategory();
    }else{
        $cvmodule_customView =CustomView::getInstance($cvmodule);
        $customview_html = $cvmodule_customView->getCustomViewAll('',$cvmodule,'');
    }
    $groupList=$cvmodule_customView->getCustomViewGroupList($customview_html);
    $arr['groupList'] = $groupList;
    ConvertTojsonString(1, $arr, 'success');
} else
    header("Location: index.php?action=$return_action&parenttab=$parenttab&module=$cvmodule&viewname=$cvid&switchview=$cvid&SearchScope=$SearchScope");
?>