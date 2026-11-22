<?php
global $adb,$current_user;
$frommodule = $_REQUEST['frommodule'];
$module = $_REQUEST['module'];
$fromrecordid = $_REQUEST['fromrecordid'];
$mode = $_REQUEST['mode'];
$_REQUEST['diony']='yes';
$relatedid = $_REQUEST['relatedid'];
crm_load_class_file("cls_ModuleMap","modules/Users");
if($mode == 'edit')
{
    $smarty = new lingdangCRM_Smarty;
    $smarty->assign('FROMMODULE',$frommodule);
    $smarty->assign('MODULE',$module);
    $smarty->assign('FROMRECORDID',$fromrecordid);
    $smarty->assign('RELATEDID',$relatedid);
    setGLobalURLSmarty($smarty);
    $focus = CRMEntity::getInstance($module);
    
    $cls_modulemapobj = new cls_ModuleMap($frommodule,$module,$fromrecordid,$relatedid);
    //获取保存的图谱信息
    $modulemapdateinfo = $cls_modulemapobj->getmapdateinfo();
    //获取字段信息
    $modulemapfieldinfo = $cls_modulemapobj->getmodulemapFieldInfo();
    //获取对应的数据信息
    $moduledatainfo = $cls_modulemapobj->getmoduleDatainfo();
    $moduledataindex_arr = array_keys($moduledatainfo);
    
    if(isPermitted($module,'Create')){
        $smarty->assign('ALLOWCREATE','yes');
        $smarty->assign('CREATEHTML',$cls_modulemapobj->getCreatehtml());
    }
    $smarty->assign('MODULELABEL',getTranstab($module));
    $smarty->assign('MODULEDATAINFO',$moduledatainfo);
    
    $hreffieldinfo = $cls_modulemapobj->hreffieldinfo;
    if(!empty($hreffieldinfo)){
        $hreffieldlabel = $hreffieldinfo->getFieldLabel();
        $hreffieldcolumnname = $hreffieldinfo->getColumnName();
    }
    $smarty->assign('SEATCHTEXTPLACEHOLDER',sprintf(getFixedLabel('PRESSENTERTYSEARCH'),$hreffieldlabel));

    $smarty->assign('MODE',$mode);
    $is_admin = is_admin($current_user);
    $smarty->assign('IS_ADMIN',$is_admin);

    
    $strContent= $smarty->fetch("DetailView/editModuleMapView.tpl");
    $arr = array();
    $arr['mapdata_arr']=$modulemapdateinfo;
    $arr['modulemapfieldinfo']=$modulemapfieldinfo;
    $arr['moduledatainfo']=$moduledatainfo;
    $arr['moduledataindex_arr']=$moduledataindex_arr;
    $arr['hreffieldcolumnname']=$hreffieldcolumnname;
    
    $arr['isadmin'] = $current_user->is_admin;
    $arr['content'] = $strContent;
    $arr['title'] = getFixedLabel('ContactsMap');
    $arr['oktext'] = getFixedLabel('SAVE');
    $arr['canceltext'] = getFixedLabel('CANCEL');
    ConvertTojsonString(1,$arr,'success');    
}
else if($mode == 'save')
{
    $lockstate=getLockState($fromrecordid,$module,$frommodule);
    if ($lockstate == 'yes'){//被锁不保存数据，返回提示
        ConvertTojsonString(-1,'',getFixedLabel('UNLOCKHINTS'));
    }
    $relatedid = $_REQUEST['relatedid'];
    $mapdataarr = json_decode($_REQUEST['mapdataarr'],true);
    $cls_modulemapobj = new cls_ModuleMap($frommodule,$module,$fromrecordid,$relatedid);
    $cls_modulemapobj->savemapdatainfo($mapdataarr);
    //保存后获取图谱锁定情况
    $lockstate=getLockState($fromrecordid,$module,$frommodule);
    $arr['lockstate']=$lockstate;
    ConvertTojsonString(1,$arr,'success');
}
else if($mode == 'refreshlist')
{
    
    $cls_modulemapobj = new cls_ModuleMap($frommodule,$module,$fromrecordid,$relatedid);
    //获取对应的数据信息
    $moduledatainfo = $cls_modulemapobj->getmoduleDatainfo();
    $moduledataindex_arr = array_keys($moduledatainfo);
    
    $arr['moduledatainfo']=$moduledatainfo;
    $arr['moduledataindex_arr']=$moduledataindex_arr;
    
    ConvertTojsonString(1,$arr,'success');    
}
else if($mode == 'fullscreen')
{
    $smarty = new lingdangCRM_Smarty;
    $smarty->assign('FROMMODULE',$frommodule);
    $smarty->assign('MODULE',$module);
    $smarty->assign('FROMRECORDID',$fromrecordid);
    setGLobalURLSmarty($smarty);
    $focus = CRMEntity::getInstance($module);
    
    $cls_modulemapobj = new cls_ModuleMap($frommodule,$module,$fromrecordid,$relatedid);
    
    
    $smarty->assign('MODULELABEL',getTranstab($module));
    
    $smarty->assign('SEATCHTEXTPLACEHOLDER',sprintf(getFixedLabel('PRESSENTERTYSEARCH'),$hreffieldlabel));
    
    $strContent= $smarty->fetch("DetailView/editModuleMapView.tpl");
    $arr = array();
    
    $arr['isadmin'] = $current_user->is_admin;
    $arr['content'] = $strContent;
    $arr['title'] = getFixedLabel('ContactsMap');
    $arr['oktext'] = getFixedLabel('SAVE');
    $arr['canceltext'] = getFixedLabel('CANCEL');
    ConvertTojsonString(1,$arr,'success');    
}elseif($mode == 'savelockstate'){//保存lockstate
    $newlockstate=$_REQUEST['newlockstate'];
    $updatesql = "UPDATE ld_moduledatamap SET lockstate = ? WHERE fromrecordid =? and modulename=? and frommodule=?";
    $adb->pquery($updatesql,array($newlockstate,$fromrecordid,$module,$frommodule));
    $lockstate=getLockState($fromrecordid,$module,$frommodule);
    $arr['lockstate']=$lockstate;
    ConvertTojsonString(1,$arr,'success');
}elseif($mode == 'getlockstate'){//查询lockstate
    $arr['lockstate']=getLockState($fromrecordid,$module,$frommodule);
    ConvertTojsonString(1,$arr,'success');
}
// ljj 20231229 XUQIU1002228 联系人图谱增加锁定功能
//获取lockstate
function getLockState($fromrecordid,$module,$frommodule){
    global $adb;
    $sql='select distinct lockstate from ld_moduledatamap where fromrecordid =? and modulename=? and frommodule=? and moduleindexid>0';
    $result=$adb->pquery($sql,array($fromrecordid,$module,$frommodule));
    if ($adb->num_rows($result)>0){
        $lockstate=$adb->query_result($result,0,'lockstate');
    }else{
        $lockstate='-1';
    }
    return $lockstate;
}
    
?>