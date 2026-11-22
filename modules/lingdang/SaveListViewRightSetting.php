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
$_REQUEST['diony']='yes';
global $adb,$current_user;
$cvid = (int)vtlib_purify($_REQUEST["record"]);
$cvmodule = vtlib_purify($_REQUEST["cvmodule"]);
$listpagecount = $_REQUEST['listpagecount'];
$listpageheight = $_REQUEST['listpageheight'];
if ($cvmodule == 'Calendar')
    $cvmodule = 'Events';
$focus = CRMEntity::getInstance($cvmodule);

//@edit:ljj,2023-08-09,reason: XUQIU1001644 单据序时簿列表界面，快速设置弹出层中增加“设置模块超链接字段”区块
$entity_fieldname = $_REQUEST['entity_fieldname'];
$entity_tablename = $_REQUEST['entity_tablename'];
//ljj 当在“模块超链接字段设置”中设置为空值时，不允许保存。
if($cvmodule!='' && $entity_fieldname!='' && $entity_tablename!='') {
    //edit: xll 2023/09/12 BUG0072452 更改产品的超链接字段时需要先更新所有产品字段的showhyperlinks属性
    if($cvmodule == 'Products'){
        $update_sql = "UPDATE ld_producttoolfield 
            INNER JOIN (
                SELECT tabid,tablename,showhyperlinks from ld_producttoolfield where columnname = (
                    select fieldname from ld_entityname where modulename = 'Products'
                )
            ) tmp_fieldinfo ON tmp_fieldinfo.tabid = ld_producttoolfield.tabid 
            set ld_producttoolfield.showhyperlinks = tmp_fieldinfo.showhyperlinks
            WHERE ld_producttoolfield.tablename = 'ld_products' OR ld_producttoolfield.tablename = 'ld_productcf';";
        $adb->pquery($update_sql, array());
        unsetCacheDirectory('productfields');
    }
    if($currentModule == 'Calendar'){
        $modulename = 'Calendar';
    }else{
        $modulename = $cvmodule;
    }

    $sql = 'update ld_entityname set fieldname=?,tablename=? where modulename=?';
    $result = $adb->pquery($sql, array($entity_fieldname, $entity_tablename, $modulename));
    $key = 'cache_getentitynameinfo';
    unsetCache($key);
}
if ($cvmodule != '') {
    $cv_tabid = getTabid($cvmodule);
    if($cvid > 0) {
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

        if(is_admin($current_user)){
            if(isset($listpagecount) && $listpagecount!='') {
                setUsersettingByLabel($currentModule, 1, 'MaxEntriesPerPage', $listpagecount);
            }
            //lmq 230614 存储表格行高设置内容
            if(isset($listpageheight) && $listpageheight!='') {
                setUsersettingByLabel($currentModule, 1, 'TableLineHightSet', $listpageheight);
            }
        }
    }
}


if(is_admin($current_user)){
    //zl 230704 XUQIU1000536 获取js传递的操作按钮设置-高级查找按钮label和status,使用setUsersettingByLabel()存到数据库中
    $Highersearch = $_REQUEST['higsearchbtnlabel'];
    $Highersearch_status=$_REQUEST['highersearch'];
    if(isset($Highersearch) && $Highersearch!='') {
        if($currentModule == 'Calendar'){
            setUsersettingByLabel($currentModule, 1, $Highersearch, $Highersearch_status);
        }else{
            setUsersettingByLabel($cvmodule, 1, $Highersearch, $Highersearch_status);
        }
    }
    //@edit:ljj,2023-08-11,reason:XUQIU1001663 单据序时簿列表界面，“操作按钮设置”区块，高级查找下方增加“平铺查找”开启、关闭参数
    $tiledsearch = $_REQUEST['tiledsearchbtnlabel'];
    $tiledsearch_status=$_REQUEST['tiledsearch'];
    if(isset($tiledsearch) && $tiledsearch!='') {
        if($currentModule == 'Calendar'){
            setUsersettingByLabel($currentModule, 1, $tiledsearch, $tiledsearch_status);
        }else{
            setUsersettingByLabel($cvmodule, 1, $tiledsearch, $tiledsearch_status);
        }
    }
    //wym BUG0076164 客户管理--将标签查找也纳入可设置隐藏
    $tagsearch = $_REQUEST['tagsearchbtnlabel'];
    $tagsearch_status=$_REQUEST['tagsearch'];
    if(isset($tagsearch) && $tagsearch!='') {
        if($currentModule == 'Calendar'){
            setUsersettingByLabel($currentModule, 1, $tagsearch, $tagsearch_status);
        }else{
            setUsersettingByLabel($cvmodule, 1, $tagsearch, $tagsearch_status);
        }
    }
    //wym BUG0076167 客户管理--地图和漏斗加入设置，可设置显示或隐藏
    $mapsearch = $_REQUEST['mapsearchbtnlabel'];
    $mapsearch_status=$_REQUEST['mapsearch'];
    if(isset($mapsearch) && $mapsearch!='') {
        if($currentModule == 'Calendar'){
            setUsersettingByLabel($currentModule, 1, $mapsearch, $mapsearch_status);
        }else{
            setUsersettingByLabel($cvmodule, 1, $mapsearch, $mapsearch_status);
        }
    }
    $chartsearch = $_REQUEST['chartsearchbtnlabel'];
    $chartsearch_status=$_REQUEST['chartsearch'];
    if(isset($chartsearch) && $chartsearch!='') {
        if($currentModule == 'Calendar'){
            setUsersettingByLabel($currentModule, 1, $chartsearch, $chartsearch_status);
        }else{
            setUsersettingByLabel($cvmodule, 1, $chartsearch, $chartsearch_status);
        }
    }
    if(isset($_REQUEST['shownum'])&&isset($_REQUEST['Listbuttonselfarr'])&&isset($_REQUEST['Listbuttonrelyarr'])&&isset($_REQUEST['actionlink'])){
        //zl 230704 XUQIU1000536 获取排序后的列表按钮($Listbuttonarr为按钮label名,数组键值为新的sequence)
        $Listbuttonselfarr = explode(',', rtrim($_REQUEST['Listbuttonselfarr'],','));
        $shownum =$_REQUEST['shownum'];
        $delsql = 'delete from ld_btnset where tabid = ? and btn_type <> "detailbtn";';
        $adb->pquery($delsql,array($cv_tabid));
        foreach ($Listbuttonselfarr as $key =>$arr)
        {
            $arr=explode(':',$arr);
            $inssql = 'insert into ld_btnset(tabid,buttonlabel,btn_type,sequence,btnkey,shownum) values (?,?,?,?,?,?);';
            $adb->pquery($inssql,array($cv_tabid,$arr[0],'listbasicbtn',$key,$arr[1],$shownum));
        }

        $Listbuttontrelyarr = explode(',', rtrim($_REQUEST['Listbuttonrelyarr'],','));
        foreach ($Listbuttontrelyarr as $key =>$arr)
        {
            $arr=explode(':',$arr);
            $inssql = 'insert into ld_btnset(tabid,buttonlabel,btn_type,sequence,btnkey,shownum) values (?,?,?,?,?,?);';
            $adb->pquery($inssql,array($cv_tabid,$arr[0],'listbasicbtn',$key,$arr[1],''));
        }
        $actionlinkarr = explode(',', rtrim($_REQUEST['actionlink'],','));
        $custom_btnkey_arr = [];// 自定义按钮
        $custombutton_actionlink_arr = [];
        foreach ($actionlinkarr as $key =>$arr)
        {
            $arr=explode(':',$arr);
            $is_active = $arr[2]=='true'?"yes":"no";
            $tmp_btnkey = $arr[1];
            $inssql = 'insert into ld_btnset(tabid,buttonlabel,btn_type,sequence,btnkey,is_active) values (?,?,?,?,?,?);';
            $adb->pquery($inssql,array($cv_tabid,$arr[0],'actionlink',$key,$tmp_btnkey,$is_active));
            if(strpos(strtolower($tmp_btnkey), 'custombutton') !== false){
                $custombutton_actionlink_arr[$tmp_btnkey]['is_active'] = $is_active;
                $custom_btnkey_arr[] = $tmp_btnkey;
            }
        }
        // 更新自定义按钮表中的显示位置
        if(!empty($custom_btnkey_arr)){
            $select_sql = "SELECT btnkey,btnposition from ld_buttonscustomization WHERE deleted = 0 AND btnkey in (".generateQuestionMarks($custom_btnkey_arr).")";
            $select_result = $adb->pquery($select_sql, $custom_btnkey_arr);
            $num_rows = $adb->num_rows($select_result);
            if($num_rows > 0) {
                for($i = 0; $i<$num_rows; $i++){
                    $btnkey = $adb->query_result($select_result,$i,'btnkey');
                    $btnposition = $adb->query_result($select_result,$i,'btnposition');
                    $custombutton_actionlink_arr[$btnkey]['btnposition'] = $btnposition;
                }
            }
        }
        foreach ($custombutton_actionlink_arr as $tmpkey => $btninfo)
        {
            $btnposition_arr = [];
            $btnposition_arr = explode(',',$btninfo['btnposition']);
            if($btninfo['is_active'] == 'yes'){
                if(!in_array('pc_listlink',$btnposition_arr)){
                    $btnposition_arr[] = 'pc_listlink';
                }else{
                    continue;
                }
            }else if($btninfo['is_active'] == 'no'){
                if(in_array('pc_listlink',$btnposition_arr)){
                    $indexkey = array_search('pc_listlink', $btnposition_arr);
                    if ($indexkey !== false) {
                        unset($btnposition_arr[$indexkey]);
                    }
                }else{
                    continue;
                }
            }
            $btnposition_str = implode(',',$btnposition_arr);
            $update_sql = "UPDATE ld_buttonscustomization set btnposition = ? where btnkey = ?";
            $adb->pquery($update_sql,array($btnposition_str,$tmpkey));
            // 清除自定义按钮缓存
            $cachekey = 'cache_custom_activebuttons_'.$currentModule;
			unsetCache($cachekey);
        }
    }
}

unsetCacheDirectory('customview');
ConvertTojsonString(1,'','success');


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
?>