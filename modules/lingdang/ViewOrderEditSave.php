<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
global $currentModule;
global $adb,$rstart;
global $current_user;

////@edit zsk 2024/06/11 XUQIU20240516-01 查询分类功能优化 点击分组后刷新查询分类列表
if(isset($_REQUEST["selectedGroupid"])){
    $customview = CustomView::getInstance($_REQUEST['module']);
    $viewid = $customview->getViewId($_REQUEST['module']);
    $customview_html=$customview->getCustomViewAll($viewid, $_REQUEST['module']);
    //获取查询分类分组列表
    $groupList=$customview->getCustomViewGroupList($customview_html);
    $groupList['selectedGroupid']=$_REQUEST["selectedGroupid"];
    $smarty = new lingdangCRM_Smarty();
    $smarty->assign("CUSTOMVIEWGROUPLIST",$groupList);
    $smarty->assign("MODULE", $_REQUEST['module']);
    $smarty->assign("VIEWID", $viewid);
    $smarty->assign("CUSTOMVIEW_OPTION",$customview_html);
    $content=$smarty->fetch("SelectCustomView_New_Cv.tpl");
    ConvertTojsonString(1,$content,'success');
}
//保存分组后刷新查询分类弹出框
elseif(isset($_REQUEST["reloadCustomViewPopup"])){
    $customview = CustomView::getInstance($_REQUEST['module']);
    $viewid = $customview->getViewId($_REQUEST['module']);
    $customview_html=$customview->getCustomViewAll($viewid, $_REQUEST['module']);
    //获取查询分类分组列表
    $groupList=$customview->getCustomViewGroupList($customview_html);
    $smarty = new lingdangCRM_Smarty();
    $smarty->assign("CUSTOMVIEWGROUPLIST",$groupList);
    $smarty->assign("MODULE", $_REQUEST['module']);
    $smarty->assign("VIEWID", $viewid);
    $smarty->assign("CUSTOMVIEW_OPTION",$customview_html);
    $content=$smarty->fetch("SelectCustomView_Group.tpl");
    ConvertTojsonString(1,$content,'success');
}
//点击收藏刷新左侧弹出框的分组菜单栏
elseif(isset($_REQUEST["reloadCustomViewPopupGroupList"])){
    $customview = CustomView::getInstance($_REQUEST['module']);
    $viewid = $customview->getViewId($_REQUEST['module']);
    $customview_html=$customview->getCustomViewAll($viewid, $_REQUEST['module']);
    //获取查询分类分组列表
    $groupList=$customview->getCustomViewGroupList($customview_html);
    $groupList['selectedGroupid']=$_REQUEST["customviewGroupActiveobj"];
    $smarty = new lingdangCRM_Smarty();
    $smarty->assign("CUSTOMVIEWGROUPLIST",$groupList);
    $smarty->assign("MODULE", $_REQUEST['module']);
    $smarty->assign("VIEWID", $viewid);
    $smarty->assign("CUSTOMVIEW_OPTION",$customview_html);
    $content=$smarty->fetch("SelectCustomView_New_GroupList.tpl");
    ConvertTojsonString(1,$content,'success');
}
//保存分组
elseif(isset($_REQUEST["groupListToSave"])){
    // Custom View
    $customView = CustomView::getInstance($currentModule);
    $groupList = json_decode($_REQUEST["groupListToSave"],true);//解码为关联数组
    $viewid = $customView->getViewId($_REQUEST['module']);
    $customview_html=$customView->getCustomViewAll($viewid, $_REQUEST['module']);
    $sequence=0;
    foreach($groupList as $key=>$group){
        if($group['groupid'] === 'ungrouped'){
            continue;
        }
        $sequence++;
        $group['sequence']=$sequence;
        //编辑分组
        if($group['groupid']>0){

            $sql='update ld_customviewgroup set group_name=?,sequence=?,modified_by=? where groupid=?';
            $params=array($group['groupname'],$sequence,$current_user->id,$group['groupid']);
            $result= $adb->pquery($sql,$params);
        }
        //新建分组
        else{
            $sql='insert into ld_customviewgroup(group_name,entity_type,sequence,created_id)values(?,?,?,?)';
            $params=array($group['groupname'],$currentModule,$sequence,$current_user->id);
            $result= $adb->pquery($sql,$params);
        }
    }
    //获取更新后的分组列表
    $groupList=$customView->getCustomViewGroupList($customview_html);
    ConvertTojsonString(1,$groupList,'success');
}
//删除分组
elseif(isset($_REQUEST["groupToDelete"])){
    $customView = CustomView::getInstance($currentModule);
    $viewid = $customView->getViewId($_REQUEST['module']);
    $customview_html=$customView->getCustomViewAll($viewid, $_REQUEST['module']);
    $groupToDelete = json_decode($_REQUEST["groupToDelete"],true);//解码为关联数组
    $sql='delete from ld_customviewgroup where groupid=?';
    $params=array($groupToDelete['groupid']);
    $result= $adb->pquery($sql,$params);

    $sql='update ld_customview set groupid=0 where groupid=? and entitytype=?';
    $params=array($groupToDelete['groupid'],$currentModule);
    $result= $adb->pquery($sql,$params);

    $groupList=$customView->getCustomViewGroupList($customview_html);
    ConvertTojsonString(1,$groupList,'success');
}
//转移分组
elseif(isset($_REQUEST["groupObjToDelete"])){
    $groupObjToDelete=json_decode($_REQUEST["groupObjToDelete"],true);//解码为关联数组
    //转移到未分组中
    if($_REQUEST["groupidToMove"]=='ungrouped'){
        $sql='update ld_customview set groupid=NULL where groupid=? and entitytype=?';
        $params=array($groupObjToDelete['groupid'],$currentModule);
        $result= $adb->pquery($sql,$params);
    }
    //转移到其他分组
    else{
        $sql='update ld_customview set groupid=? where groupid=? and entitytype=?';
        $params=array($_REQUEST["groupidToMove"],$groupObjToDelete['groupid'],$currentModule);
        $result= $adb->pquery($sql,$params);
    }
    $sql='delete from ld_customviewgroup where groupid=?';
    $params=array($groupObjToDelete['groupid']);
    $result= $adb->pquery($sql,$params);
    $customView = CustomView::getInstance($currentModule);
    $viewid = $customView->getViewId($_REQUEST['module']);
    $customview_html=$customView->getCustomViewAll($viewid, $_REQUEST['module']);
    $groupList=$customView->getCustomViewGroupList($customview_html);
    ConvertTojsonString(1,$groupList,'success');
}
//添加常用查询分类
elseif(isset($_REQUEST["addToCommon"])){
    //获取当前用户的常用查询分类列表
    $customView = CustomView::getInstance($currentModule);
    $commonCustomViewByUser=getUsersettingByLabel($currentModule,$current_user->id,'CommonGroupForCategory');
    if(!empty($commonCustomViewByUser)){
        $commonCustomViewByUser.=",".$_REQUEST["addToCommon"];
    }
    else
        $commonCustomViewByUser.=$_REQUEST["addToCommon"];
    setUsersettingByLabel($currentModule,$current_user->id,'CommonGroupForCategory',$commonCustomViewByUser);
    ConvertTojsonString(1,$commonCustomViewByUser,'success');
}
//移除常用查询分类
elseif(isset($_REQUEST["deleteFromCommon"])){
//获取当前用户的常用查询分类列表
    $customView = CustomView::getInstance($currentModule);
    $commonCustomViewByUser=getUsersettingByLabel($currentModule,$current_user->id,'CommonGroupForCategory');
    $commonCustomViewByUserArray = explode(',',$commonCustomViewByUser);
    if (in_array($_REQUEST["deleteFromCommon"], $commonCustomViewByUserArray)) {
        // 找到并移除指定的groupid
        $commonCustomViewByUserArray = array_diff($commonCustomViewByUserArray, array($_REQUEST["deleteFromCommon"]));
    }
    // 将数组重新转换为逗号分隔的字符串
    $newCommonCustomViewByUser = implode(",", $commonCustomViewByUserArray);
    setUsersettingByLabel($currentModule,$current_user->id,'CommonGroupForCategory',$newCommonCustomViewByUser);

    ConvertTojsonString(1,$newCommonCustomViewByUser,'success');
}
//排序
elseif(isset($_REQUEST["selectedColumnsString"])){
    $selectedcolumnstring = $_REQUEST["selectedColumnsString"];
    $selectedcolumns = explode(";", $selectedcolumnstring);
    $selectedSequence=[];
    if($_REQUEST["isCommon"]=='no'){
        if (!empty($selectedcolumns)) {
            //按照所选的查询分类顺序获取原本的sequence
            for ($i = 0; $i < count($selectedcolumns); $i++) {
                if (!empty($selectedcolumns[$i])) {
                    $getSequencesql = "select sequence from ld_customview where cvid=? ";
                    $getSequencesqlresult = $adb->pquery($getSequencesql, array($selectedcolumns[$i]));
                    $sequence=$adb->query_result($getSequencesqlresult,0,'sequence');
                    array_push($selectedSequence, $sequence);
                    /* $icolumnsql = "update ld_customview set sequence=? where cvid=? ";
                     $icolumnsqlresult = $adb->pquery($icolumnsql, array(($i + 1), $selectedcolumns[$i]));*/
                }
            }
            //将sequence按照从小到大的顺序排序,并按照顺序赋值给查询分类
            sort($selectedSequence);
            for ($i = 0; $i < count($selectedcolumns); $i++) {
                if (!empty($selectedcolumns[$i])) {
                    $icolumnsql = "update ld_customview set sequence=? where cvid=? ";
                    $icolumnsqlresult = $adb->pquery($icolumnsql, array($selectedSequence[$i], $selectedcolumns[$i]));
                }
            }
        }
        unsetCacheDirectory('customview');
    }
    else{
        $CommonCustomViewByUser = implode(",", $selectedcolumns);
        setUsersettingByLabel($currentModule,$current_user->id,'CommonGroupForCategory',$CommonCustomViewByUser);
        unsetCacheDirectory('customview');
    }

}
elseif(isset($_REQUEST["customviewgroupsequence"])){
    global $adb;
    $grouplist = json_decode($_REQUEST["customviewgroupsequence"],true);
    if(count($grouplist) > 0){
        for($i = 0;$i<count($grouplist);$i++){
            $tmp_groupid = $grouplist[$i]['groupid'];
            $tmp_cvlist = $grouplist[$i]['cvlist'];
            $type = $grouplist[$i]['type'];

            $result = '';
            $new_sequencearr = [];
            if($tmp_groupid > 0){
                $sql = 'select cvid,sequence from ld_customview where entitytype = ? and groupid = ? order by sequence asc';
                $result = $adb->pquery($sql,array($_REQUEST['module'],$tmp_groupid));
            }else{
                $sql = 'select cvid,sequence from ld_customview where entitytype = ? and (groupid = 0 or groupid = null) order by sequence asc;';
                $result = $adb->pquery($sql,array($_REQUEST['module']));
            }
            $num = $adb->num_rows($result);
            if($num > 0){
                $old_sequence = [];
                for($j = 0;$j<$num;$j++){
                    $old_sequence[] = $adb->query_result($result,$j,'cvid');
                }

                for($k = 0;$k<count($tmp_cvlist);$k++){
                    if(in_array($tmp_cvlist[$k],$old_sequence)){
                        for($ss = 0;$ss<count($old_sequence);$ss++){
                            if($old_sequence[$ss] == $tmp_cvlist[$k]){
                                break;
                            }
                            if(!in_array($old_sequence[$ss],$new_sequencearr) && !in_array($old_sequence[$ss],$tmp_cvlist)){
                                $new_sequencearr[] = $old_sequence[$ss];
                            }
                        }
                        if(!in_array($tmp_cvlist[$k],$new_sequencearr)){
                            $new_sequencearr[] = $tmp_cvlist[$k];
                        }
                        if($k==count($tmp_cvlist)-1){
                            $key = array_search($tmp_cvlist[$k], $old_sequence);
                            $slice = array_values(array_slice($old_sequence, $key, null, true));
                            for($kk = 0;$kk<count($slice);$kk++){
                                if(!in_array($slice[$kk],$new_sequencearr)){
                                    $new_sequencearr[] = $slice[$kk];
                                }
                            }
                        }
                    }else{
                        if(!in_array($tmp_cvlist[$k],$new_sequencearr)){
                            $new_sequencearr[] = $tmp_cvlist[$k];
                        }
                    }
                }
            }else{
                $new_sequencearr = $tmp_cvlist;
            }

            $updateStatements = [];
            if($tmp_groupid == 'ungrouped'){
                $tmp_groupid = 0;
            }
            foreach ($new_sequencearr as $sequence => $cvid) {
                $sequence++; // sequence从1开始
                $updateStatements[] = "($cvid, $sequence, $tmp_groupid)";
            }

            $updateSql = "INSERT INTO ld_customview (cvid, sequence, groupid) VALUES " . implode(',', $updateStatements) . " ON DUPLICATE KEY UPDATE sequence = VALUES(sequence),groupid = VALUES(groupid)";
            $adb->pquery($updateSql,array());
        }
    }
    ConvertTojsonString(1, array(), 'success');
}
else {
    $selectedcolumnstring = $_REQUEST["selectedColumnsString2"];
    $selectedcolumns = explode(";", $selectedcolumnstring);
    if (!empty($selectedcolumns)) {
        for ($i = 0; $i < count($selectedcolumns); $i++) {
            if (!empty($selectedcolumns[$i])) {
                $icolumnsql = "update ld_customview set sequence=? where cvid=? ";
                $icolumnsqlresult = $adb->pquery($icolumnsql, array(($i + 1), $selectedcolumns[$i]));
            }
        }
    }
    unsetCacheDirectory('customview');
    if ($_REQUEST['popup'] == 'yes') {
        $_REQUEST['diony'] = 'diony';
        $customview = CustomView::getInstance($_REQUEST['module']);
        $smarty = new lingdangCRM_Smarty();
        $viewid = $customview->getViewId($_REQUEST['module']);
        $smarty->assign("MODULE", $_REQUEST['module']);
        $smarty->assign("fldname", "SelectCustomView");
        $smarty->assign("VIEWID", $viewid);
        $customview_html=$customview->getCustomViewAll($viewid, $_REQUEST['module']);
        $groupList=$customview->getCustomViewGroupList($customview_html);
        $smarty->assign("CUSTOMVIEW_OPTION",$customview_html);
        $smarty->assign("CUSTOMVIEWGROUPLIST",$groupList);
        $content = $smarty->fetch("SelectCustomView.tpl");
        $content_new = $smarty->fetch("SelectCustomView_Group.tpl");
        $arr['datacategorycontent'] = $content;
        $arr['datacategorycontent_new'] = $content_new;

        ConvertTojsonString(1, $arr, 'success');
    } else if ($currentModule == 'Emails') {
        if (isset($_REQUEST['refreshpage']) && $_REQUEST['refreshpage'] == 'no') {
            //@edit:liushuai,2020-07-21,reason:0041912/营销>群发邮件（右上角排序） 新版本
            //排序的ajax返回结果等同于创建或者编辑的返回结果，所以返回逻辑一样，参考modules/CustomView/Save.php
            $_REQUEST['diony'] = 'diony';
            $customView = CustomView::getInstance($currentModule);//Emails
            $viewid = '全部';//  viewid为20默认为 viewname（分组名）全部
//            $viewid = $customView->getViewId($viewname);

            $customview_html = $customView->getCustomViewCombo2($viewid, $currentModule, $category);

            $smarty = new lingdangCRM_Smarty();
            $smarty->assign('CUSTOMVIEW_HTML', $customview_html);

            $content = $smarty->fetch("SelectEmailFenzuName.tpl");
            $arr['datafenzucontent'] = $content;

            ConvertTojsonString(1, $arr, 'success');
        } else {
            $parenttab = getParentTab();
            header("Location: index.php?module=$currentModule&action=GroupEmail");
        }

    }
}



//
?>