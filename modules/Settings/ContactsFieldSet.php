<?php

global $adb;

$module = $_REQUEST['frommodule'];
$blockid = $_REQUEST['blockid'];
$tabid = getTabid($module);
$code = 1;
//编辑联系人字段
if($_REQUEST['mode'] == 'edit'){
    $sequence_arr = array();
    $sql="SELECT accountfield.fieldname,accountfield.columnname,accountfield.uitype,
                        contactfield.fieldname as orgin_fieldname,contactfield.columnname as orgin_columnname
                        from ld_field as accountfield 
                        INNER JOIN ld_field as contactfield on (accountfield.columnname = contactfield.columnname and accountfield.columnname != 'filename') 
				            or (accountfield.columnname= 'filename_mapping' and contactfield.columnname= 'filename')
                        where accountfield.tabid = ? and contactfield.tabid = ? 
                        AND accountfield.tablename in(?,?,?,?) and IFNULL(accountfield.isenablepresence,'') <> 'no'";
    $result=$adb->pquery($sql,array($tabid,getTabid('Contacts'),'ld_contactdetails','ld_contactscf','ld_contactaddress','ld_attachments'));

    $num_rows = $adb->num_rows($result);
    for($i=0;$i<$num_rows;$i++)
    {
        $tmp_fieldname = $adb->query_result($result,$i,'fieldname');
        $orgin_fieldname = $adb->query_result($result,$i,'orgin_fieldname');
        $select_fieldname_arr[] = $orgin_fieldname;
    }
    
    $contactsmodule = 'Contacts';
    $focus = CRMEntity::getInstance($contactsmodule);
    //默认不允许添加的字段
    $noshowfield_arr = array('contact_no','account_id','reference','assigned_user_id');
    $fieldobjs=$focus->fieldobj->getModuleFields();
    //获取所有启用的字段
    foreach($fieldobjs as $fieldname=>$fieldinfo)
    {
        $columnname=$fieldinfo->getColumnName();
        $fieldlabel=$fieldinfo->getFieldLabel();
        $fieldname = $fieldinfo->getFieldName();
        $fieldid = $fieldinfo->getFieldid();
        $bigtype = $fieldinfo->getBigType();
        $displaytype = $fieldinfo->getDisplaytype();
        //部分字段不允许选择
        if(in_array($fieldname,$noshowfield_arr)){
            continue;
        }
        //关联选择单据暂时不允许选择,因为会涉及到引用字段，以及一个页面存在同一个模块的两个关联选择单据字段的问题
        if($bigtype == 'reference'){
            continue;
        }
        if($fieldinfo->getSaveDataBase()=='no')
            continue;
        //筛选出不允许编辑的字段
        if($displaytype!=1 || $fieldinfo->get_allowedit()!='yes'){
            continue;
        }
        if(in_array($fieldname,$select_fieldname_arr)){
            $actions_arr_used[$fieldname] = $fieldlabel;
        } else{
            $actions_arr[$fieldname] = $fieldlabel;
        }
    }
    $new_actions_arr_used = array();
    //根据sequence重新排序
    foreach($select_fieldname_arr as $tmp_fieldname){
        if(array_key_exists($tmp_fieldname,$actions_arr_used)){
            $new_actions_arr_used[$tmp_fieldname] = $actions_arr_used[$tmp_fieldname];     
        }
    }
    
    $smarty->assign('actions_arr', $actions_arr);
    $smarty->assign('actions_arr_userd',$new_actions_arr_used);
	$smarty->assign('MODULE',$module);
	$_REQUEST['diony']='diony';
	$arr['title']=getFixedLabel('ACTIVITYADDFIELD');
	$str=$smarty->fetch('Settings/ContactsFieldSetting.tpl');
	$arr['content']=$str;
}else{
    //获取选中和未选中的字段，因为存在未启用的联系人字段，未启用的联系人字段不应该禁用
    $selectedfieldname = $_REQUEST['selectedfieldname'];
    $selectfield_arr = explode('##',trim($selectedfieldname,'#'));

    $noselectedfieldname = $_REQUEST['noselectedfieldname'];
    $noselectfield_arr = explode('##',trim($noselectedfieldname,'#'));
    //获取已经存在数据库中的字段
    $sql="SELECT accountfield.fieldname,accountfield.columnname,accountfield.fieldid,
                        contactfield.fieldname as orgin_fieldname,contactfield.columnname as orgin_columnname
                        from ld_field as accountfield 
                        INNER JOIN ld_field as contactfield on (accountfield.columnname = contactfield.columnname and accountfield.columnname != 'filename') 
				            or (accountfield.columnname= 'filename_mapping' and contactfield.columnname= 'filename')
                        where accountfield.tabid = ? and contactfield.tabid = ? 
                        AND accountfield.tablename in(?,?,?,?) ";
    $result=$adb->pquery($sql,array($tabid,getTabid('Contacts'),'ld_contactdetails','ld_contactscf','ld_contactaddress','ld_attachments'));


    $num_rows = $adb->num_rows($result);
    $saved_fieldname_arr = array();
    for($i=0;$i<$num_rows;$i++)
    {
        $tmp_fieldname = $adb->query_result($result,$i,'fieldname');
        $fieldid = $adb->query_result($result,$i,'fieldid');
        $orgin_fieldname = $adb->query_result($result,$i,'orgin_fieldname');
        $saved_fieldname_arr[] = $orgin_fieldname;
        $saved_fieldid_arr[$orgin_fieldname] = $fieldid;
    }

    $all_fieldname_arr = array_unique(array_merge($selectfield_arr,$noselectfield_arr));
    $all_fieldname_arr = array_unique(array_merge($all_fieldname_arr,$saved_fieldname_arr));
    $sequence = 0;
    
    $sequence_sql = "update ld_field set sequence = if(sequence <100,sequence+100,sequence) where block = ?;";
    $adb->pquery($sequence_sql,array($blockid));
    
    foreach($all_fieldname_arr as $tmp_fieldname){
        if(empty($tmp_fieldname)){
            continue;
        }
        $sequence ++;
        //判断是否选中
        if(in_array($tmp_fieldname,$selectfield_arr)){
            $isselected = true;
        }else{
            $isselected = false;
        }
        //判断是否未选中
        if(in_array($tmp_fieldname,$noselectfield_arr)){
            $noselected = true;
        }else{
            $noselected = false;
        }
        //判断是否已存在数据库中
        if(in_array($tmp_fieldname,$saved_fieldname_arr)){
            $issaved = true;
        }else{
            $issaved = false;
        }
        
        //已保存到数据库的字段,如果选中则更新为启用，否则不启用
        if($issaved){
            $fieldid = $saved_fieldid_arr[$tmp_fieldname];
            if($isselected){
                $presence = 2;
                $isenablepresence = 'yes';
                $sql = "UPDATE ld_field set presence = ?,sequence = ?,isenablepresence = ? where tabid =? and fieldid = ?;";
                $param = array($presence,$sequence,$isenablepresence,$tabid,$fieldid);
            }else if($noselected){
                $presence = 1;
                $isenablepresence = 'no';
                $sql = "UPDATE ld_field set presence = ?,sequence = ?,isenablepresence = ? where tabid =? and fieldid = ?;";
                $param = array($presence,$sequence,$isenablepresence,$tabid,$fieldid);
            }else{
                $presence = 1;
                $sql = "UPDATE ld_field set presence = ?,sequence = ? where tabid =? and fieldid = ?;";
                $param = array($presence,$sequence,$tabid,$fieldid);

            }
            $adb->pquery($sql,$param);

        }else{
            //已选中但未保存到数据库的字段,保存新的字段信息
            if($isselected){
                $max_fieldid = getMaxFieldid();
                $custfld_fieldid = $max_fieldid;
                $ContactsTabid = getTabid('Contacts');
                
                $max_fieldsequence = "select max(sequence) as maxsequence from ld_field where block = ? ";
                $res = $adb->pquery($max_fieldsequence,array($blockid));
                $max_seq = $adb->query_result($res,0,'maxsequence');
                //获取对应联系字段的字段信息
                $orgin_sql = "select fieldid,bigtype,uitype,columnname from ld_field where tabid = ? and fieldname = ?";
                $result = $adb->pquery($orgin_sql,array($ContactsTabid,$tmp_fieldname));
                $orgin_fieldid = $adb->query_result($result,0,'fieldid');
                $orgin_bigtype = $adb->query_result($result,0,'bigtype');
                $orgin_uitype = $adb->query_result($result,0,'uitype');
                $orgin_columnname = $adb->query_result($result,0,'columnname');
                
                $new_fieldname = $tmp_fieldname."_mapping";
                //为了跟客户模块的filename字段区分开，需要修改字段名
                if($orgin_columnname == 'filename'){
                    $new_columnname = $orgin_columnname."_mapping";
                }else{
                    $new_columnname = $orgin_columnname;
                }
                //复制联系人模块的字段信息到客户模块
                $add_query = "insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname
                                                ,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block
                                                ,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable
                                                ,approve_demand,advance_demand,advance_demand_groups,fldallow_rewriting,savedatabase,allowedit,allowdelete
                                                ,bigtype,fieldonly,datarang,maxrowsshow,take_photo_only,uploadwatermark,fieldvaluecolor,fieldplaceholder
                                                ,editpage,input_type,auto_signin,no_signin,allowable_distance,relatedmodulefield) 
                            select ?,?,?,tablename,generatedtype,uitype,?
                                                ,fieldlabel,readonly,presence,defaultvalue,maximumlength,?,?
                                                ,displaytype,typeofdata,1,0,info_type,masseditable
                                                ,approve_demand,advance_demand,advance_demand_groups,fldallow_rewriting,savedatabase,allowedit,allowdelete
                                                ,bigtype,fieldonly,datarang,maxrowsshow,take_photo_only,uploadwatermark,fieldvaluecolor,fieldplaceholder
                                                ,editpage,input_type,auto_signin,no_signin,allowable_distance,relatedmodulefield
                                                from ld_field where tabid = ? and fieldname = ?
                            and not EXISTS(select 1 from ld_field where tabid = ? and fieldname = ?)";
                $adb->pquery($add_query,array($tabid,$custfld_fieldid,$new_columnname,$new_fieldname,$sequence,$blockid,$ContactsTabid,$tmp_fieldname,$tabid,$new_fieldname));
                //添加字段翻译
                $sql = 'delete from ld_tranlabel where trantable=? and tabid=? and relateid=?';
                $adb->pquery($sql, array('ld_field', $tabid, $custfld_fieldid));
                $sqls = "insert into ld_tranlabel (languagetype,trantable,tabid,relateid,fieldlabel) 
                    select languagetype,trantable,?,?,fieldlabel from ld_tranlabel 
                    where trantable=? and tabid=? and relateid=?";
                $qparam = array($tabid,$custfld_fieldid,'ld_field', $ContactsTabid, $orgin_fieldid);
                $adb->pquery($sqls, $qparam);
                //复制下拉框字段时，要把下拉框值一并复制过来
                if($orgin_bigtype == 'picklist' || $orgin_bigtype == 'multipicklist'){
                    $picklist_sql = "SELECT listid,picklist_allowedit,relatetable from ld_picklist_set where listname = ?";
                    $picklist_result = $adb->pquery($picklist_sql,array($tmp_fieldname));
                    if($adb->num_rows($picklist_result)>0){
                        $listid = $adb->query_result($picklist_result,0,'listid');
                        $picklist_allowedit = $adb->query_result($picklist_result,0,'picklist_allowedit');
                        $relatetable = $adb->query_result($picklist_result,0,'relatetable');
                        
                        $select_picklist_sql = 'SELECT listid,picklist_allowedit,relatetable from ld_picklist_set where listname = ?';
                        $select_result = $adb->pquery($select_picklist_sql,array($new_fieldname));
                        if($adb->num_rows($select_result)<=0){
                            $add_picklist_sql = 'insert into ld_picklist_set(listname,picklist_allowedit,relatetable) values(?,?,?)';
                            $adb->pquery($add_picklist_sql,array($new_fieldname,$picklist_allowedit,$relatetable));
                            $newlistid = $adb->getLastInsertID();
                            
                            $add_picklistvalue_sql = 'INSERT into ld_picklist_values(listid,listvalue,sequence) 
                                    SELECT ?,listvalue,sequence from ld_picklist_values where listid = ?;';
                            $adb->pquery($add_picklistvalue_sql,array($newlistid,$listid));
                        }
                    }
                }
            }
        }
    }
    $cachekey = 'cache_getmodfldcolumninfotabid_'.$tabid;
    unsetCache($cachekey);
    $cachekey = 'cache_dbvalidationdatainfozh_'.$tabid;
    unsetCache($cachekey);
    $cachekey = 'cache_dbvalidationdatainfoen_'.$tabid;
    unsetCache($cachekey);
    unsetCacheDirectory('fields');
}

$_REQUEST['diony']='diony';
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
ConvertTojsonString($code,$arr,"success");


function getMaxFieldid(){
    global $adb;
    $query  = 'select max(fieldid) as fieldid from ld_field limit 1';
    $result = $adb->pquery($query,array());
    $fieldid = $adb->query_result($result,0,0);
    $fieldid=$fieldid+1;
    //字段删除有bug,所以此处获取两者的最大值
    $tmpfieldid=$adb->getUniqueID('ld_field');
    $maxfieldid=max($tmpfieldid,$fieldid);
    if($maxfieldid>$tmpfieldid){
        $adb->pquery('update ld_field_seq set id = ?',array($maxfieldid));
    }
    return $maxfieldid;
}
?>