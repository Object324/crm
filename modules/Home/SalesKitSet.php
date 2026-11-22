<?php

global $adb,$current_user,$languageType;
if(!is_admin($current_user)){
    exit('error');
}
$stuffid = $_REQUEST['stuffid'];
$boardid = $_REQUEST['boardid'];
if($_REQUEST['type']=='save'){
    
    $selectvalues=$_REQUEST['selectvalues'];//选中的值
    $arr_selectvalues=explode(",",$selectvalues);
    
    $unselectvalues=$_REQUEST['unselect'];//未选中的值
    //zxm 20230804 先将所有的简报都设为不可见
    $sql='update ld_homestuffdetail  set presence=? where stuffid=?';
    $adb->pquery($sql,array('no',$stuffid));

    if($selectvalues!=''){
        $index=1;
        foreach($arr_selectvalues as $stufflabel){
            $sql='update ld_homestuffdetail  set presence=?,sequence=? where stufflabel=? and stuffid=?';
            $adb->pquery($sql,array('yes',$index,$stufflabel,$stuffid));
            $index++;
        }
    }
    crm_load_class_file('HomeBoardNew_35','modules/Home/HomeBoardNew');
    $SalesKitEditObj=new HomeBoardNew_35($boardid);
    $allheight = $SalesKitEditObj->getSalesKitHeight($boardid);
    $_REQUEST['diony']='diony';
    ConvertTojsonString(1,array('allheight'=>$allheight),"success");
}
$smarty=new lingdangCRM_Smarty();

//获取模块
include_once globalStatic::$root_directory.'modules/Home/HomeBoardNew/SalesKitEditSetting.php';
$SalesKitEditObj=new SalesKitEditSetting($boardid);
if($_REQUEST['mode']=='getSalesKitByStuffLabel'){
    //获取简报数据--单个简报数据 根据stufflabel--不要控制参数boardid 主要是为了简报编辑界面 实时获取简报数据
    require_once globalStatic::$root_directory.'modules/Home/HomeStuffDetailUtils.php';
    $HomeStuffDetailUtilsObj = new HomeStuffDetailUtils($boardid);
    $stufflabel = $_REQUEST['stufflabel'];
    $stuffdetailInfo = $_REQUEST['stuffdetailInfo'];
    $stuffdetailInfo = Zend_Json::decode($stuffdetailInfo);

    $isshowprevious = $_REQUEST['isshowprevious'];
    $saleskitCount = $_REQUEST['saleskitCount'];
    $ShowPercent = $_REQUEST['ShowPercent'];
    $params = array(
        'scopeType'=>$_REQUEST['scopeType'],
        'senioruserid'=>$_REQUEST['selectuserid'],
        'search_date'=>$_REQUEST['search_date_custom_value'],
        'approve_value'=>$_REQUEST['approve_value'],
        'stufflabel'=>$stufflabel,
    );
    $HomeStuffDetailUtilsObj->initParam($params);
    $HomeStuffDetailUtilsObj->setStuffid(35,0);
    $home_values = $HomeStuffDetailUtilsObj->getSalesKitCreate($stuffdetailInfo);

    $boardstuffid = $HomeStuffDetailUtilsObj->boardstuffid;

    $smarty->assign('saleskitinfo',$home_values[$stufflabel]);
    $smarty->assign('stufflabel',$stufflabel);
    $smarty->assign('stuffid',$_REQUEST['stuffid']);
    $smarty->assign('saleskit_isshowpredata',$isshowprevious);
    $smarty->assign('ShowPercent',$ShowPercent);
    //布局设置查找
    $saleskit_layout = $SalesKitEditObj->getSaleskitLayout($saleskitCount);
    //boardtype==MobileReport 移动段 一行显示2个
    $boardtype = $saleskit_layout['boardtype'];
    if($boardtype=="MobileReport"||$boardtype=="prmMobileHome"){
        $saleskit_layout['colcount'] = 2;
    }
    $smarty->assign('SALESKITLAYOUT', $saleskit_layout);
    $arr['content'] = $smarty->fetch('Home/SalesKitSetEditView_center.tpl');
    $arr['isshowprevious'] =$isshowprevious;

    ConvertTojsonString(1, $arr, "success");die;
}
if($_REQUEST['mode']=='getSalesKitListByStuffLabel'){
    //获取简报数据--单个简报数据 根据stufflabel--不要控制参数boardid 主要是为了简报编辑界面 实时获取简报数据
    require_once globalStatic::$root_directory.'modules/Home/HomeStuffDetailUtils.php';
    $HomeStuffDetailUtilsObj = new HomeStuffDetailUtils($boardid);

    $params = array(
        'scopeType'=>$_REQUEST['scopeType'],
        'senioruserid'=>$_REQUEST['selectuserid'],
        'search_date'=>$_REQUEST['search_date_custom_value'],
        'approve_value'=>$_REQUEST['approve_value'],
        'stufflabel'=>$stufflabel,
    );
    $HomeStuffDetailUtilsObj->initParam($params);
    $HomeStuffDetailUtilsObj->setStuffid(35,0);

    $selected_saleskit_list = $_REQUEST['selected_saleskit_list'];
    $selected_saleskit_list_arr = Zend_Json::decode($selected_saleskit_list);

    $saleskit_layout = $_REQUEST['saleskit_layout'];
    $saleskit_layout_arr = Zend_Json::decode($saleskit_layout);

    $home_values = [];
    foreach($selected_saleskit_list_arr as $stufflabel=>$stuffdetailInfo){
        $tmphome_values = $HomeStuffDetailUtilsObj->getSalesKitCreate($stuffdetailInfo);
        $home_values[$stufflabel] = $tmphome_values[$stufflabel];
    }
    $isshowprevious = $saleskit_layout_arr['isshowprevious'];
    $saleskitCount = is_array($selected_saleskit_list_arr)?count($selected_saleskit_list_arr):0;
    $ShowPercent = $saleskit_layout_arr['ShowPercent'];



    $boardstuffid = $HomeStuffDetailUtilsObj->boardstuffid;

    $smarty->assign('HOME_STUFF',$home_values);
    $smarty->assign('stuffid',$_REQUEST['stuffid']);
    $smarty->assign('saleskit_isshowpredata',$isshowprevious);
    $smarty->assign('ShowPercent',$ShowPercent);
    //布局设置查找
    $smarty->assign('SALESKITLAYOUT', $saleskit_layout);
    $arr['content'] = $smarty->fetch('Home/HomeTable4_NEW.tpl');
    $arr['isshowprevious'] =$isshowprevious;

    ConvertTojsonString(1, $arr, "success");die;
}
if($_REQUEST['mode']=='NewSalesKitSet' && $stuffid==35) {//编辑销售简报
    $SalesKitEditObj->getSelectedSalesKitList($stuffid);
    $SalesKitEditObj->getAllSalesKitList($stuffid);
    $detault_saleskit_list = $SalesKitEditObj->saleskitlist;//所有的简报信息
    $selected_saleskit_list = $SalesKitEditObj->selected_saleskit_list;//被选中的简报信息
    $havesaleskit_stufflabelarr = $SalesKitEditObj->havesaleskit_stufflabelarr;//被选中的简报信息的stufflabel

    $count = sizeof($selected_saleskit_list);//选中的销售简报的数量
    //简报数据--真实数据
    $saleskit_values = array();
    if($count>0) {
        require_once globalStatic::$root_directory . 'modules/Home/HomeStuffDetailUtils.php';
        $HomeStuffDetailUtilsObj = new HomeStuffDetailUtils($boardid);
        $params = array(
            'scopeType' => $_REQUEST['scopeType'],
            'senioruserid' => $_REQUEST['selectuserid'],
            'search_date' => $_REQUEST['search_date_custom_value'],
            'approve_value' => $_REQUEST['approve_value'],
        );
        $HomeStuffDetailUtilsObj->initParam($params);
        $HomeStuffDetailUtilsObj->setStuffid(35, 0);
        $saleskit_values = $HomeStuffDetailUtilsObj->getSalesKit();
    }

    //布局设置查找
    $saleskit_layout = $SalesKitEditObj->getSaleskitLayout($count);
    //boardtype==MobileReport 移动段 一行显示2个
    $boardtype = $saleskit_layout['boardtype'];
    if($boardtype=="MobileReport"||$boardtype=="prmMobileHome"){
        $saleskit_layout['colcount'] = 2;
    }
    $smarty->assign('SALESKITLAYOUT', $saleskit_layout);
    $smarty->assign('saleskit_isshowpredata', $saleskit_layout['isshowprevious']);


    $smarty->assign('detault_saleskit_list', $detault_saleskit_list);
    $smarty->assign('selected_saleskit_list', array_chunk($selected_saleskit_list,$saleskit_layout['colcount']));
    $smarty->assign('StuffLabelList', $SalesKitEditObj->StuffLabelList);

    $smarty->assign("HOME_STUFF", $saleskit_values);

    $ModuleArr=$SalesKitEditObj->getModuleArr();//获取可以设置简报的模块
    $smarty->assign('MODULEARR', $ModuleArr);
    $smarty->assign('boardtype', $saleskit_layout['boardtype']);//看板模块--首页看板，可视化分析看板,移动端看板
    $arr['title'] = getFixedLabel('SALESKITCUSTOMIZATION');
    $OperationTip = '1. ' . getFixedLabel('SaleskitTip') . '<br>' . '2. ' . getFixedLabel('SaleskitTip2') ;
    $smarty -> assign('OperationTip',$OperationTip);
    $saleskit_values_tmp = array_values($saleskit_values);
    $arr['isshowprev'] = ($saleskit_values_tmp[0]&&$saleskit_values_tmp[0]['beforelabel']!=''&&$saleskit_values_tmp[0]['search_date']!='all')?'yes':'no';//是否显示上期   全部时间和自定义时间直接不显示上期
    $smarty -> assign('isshowprev',$arr['isshowprev']);
    $str = $smarty->fetch('Home/SalesKitSetEditView.tpl');
    $arr['saleskit_layout'] = $saleskit_layout;

    $arr['detault_saleskit_list'] = $detault_saleskit_list;//所有的简报数据
    $arr['selected_saleskit_list'] = $selected_saleskit_list;//被选中的简报数据
    $arr['havesaleskit_stufflabelarr'] = $havesaleskit_stufflabelarr;//被选中的简报信息的stufflabel
    $arr['NewStuffInfoArr'] = $SalesKitEditObj->getNewStuffInfoArr();//新建简报的默认数组格式
    $arr['JspopLabelarr'] = $SalesKitEditObj->getJspopLabel();//翻译
    $arr['ModuleArr'] =$ModuleArr;//模块
    $arr['boardid'] =$boardid;//看板ID
    $arr['content'] = $str;

    ConvertTojsonString(1, $arr, "success");
}



if($_REQUEST['mode']=='NewsaleskitSave'){
    $SalesKitInfo=$_REQUEST['SalesKitInfo'];//简报所有的信息
    $SalesKitInfo=json_decode($SalesKitInfo,true);
    $saleskit_layout=$_REQUEST['saleskit_layout'];//简报全局设置
    $saleskit_layout=json_decode($saleskit_layout,true);
    if($saleskit_layout['isshowprevious']) {
        $isshowprevious = 'yes';
    }
    else {
        $isshowprevious = 'no';
        $saleskit_layout['EqualDuration'] = 'no';
        $saleskit_layout['ShowPercent'] = false;
    }
    $sql='update ld_homeboard set saleskit_colcount=?,saleskit_height=?,saleskit_isshowpredata=? where boardid=?';
    $adb->pquery($sql,array($saleskit_layout['colcount'],$saleskit_layout['height'],$isshowprevious,$boardid));
    $stuffid = 35;
    crm_load_class_file('home','include');
    $homeObj = new Homestuff;
    $boardStuffId = $homeObj->getBoardStuffId($boardid,$stuffid);
    $typeArr = ['EqualDuration','ShowPercent'];
    foreach ($typeArr as $type) {
        $setvalue = ($saleskit_layout[$type] === true || $saleskit_layout[$type] === 'yes') ? 'yes' : 'no';
        $sql = "SELECT setvalue FROM ld_homeboard_plate_setting WHERE boardid = ? AND stuffid = ? AND boardstuffid = ? AND type = 'SalesKit_$type'";
        $result = $adb->pquery($sql, [$boardid,$stuffid,$boardStuffId]);
        if($adb->num_rows($result) > 0) {
            $sql = "UPDATE ld_homeboard_plate_setting SET setvalue = ? WHERE boardid = ? AND stuffid = ? AND boardstuffid = ? AND type = 'SalesKit_$type'";
        }
        else if($boardStuffId>0){
            $sql = "INSERT INTO ld_homeboard_plate_setting(setvalue,boardid,stuffid,boardstuffid,type) VALUES(?,?,?,?,'SalesKit_$type') ";
        }
        $adb->pquery($sql, [$setvalue,$boardid,$stuffid,$boardStuffId]);
    }
    $delete_sql='delete from ld_homestuffsaleskit2board where boardid=? and homestuffdetailid in (
                        select id from ld_homestuffdetail where stuffid = ?
                    )';
    $adb->pquery($delete_sql,array($boardid,$stuffid));
    foreach($SalesKitInfo as $stufflabel=>$stuffdetailinfo){
        foreach($stuffdetailinfo['computeinfo'] as $key=>$computeinfo){
            //如果开关是关闭的 那就将数据范围映射字段清空
            $computeinfo['viewrange'] = $computeinfo['viewrange_isrelated']==true?$computeinfo['viewrange']:'';
            $computeinfo['daterange'] = $computeinfo['daterange_isrelated']==true?$computeinfo['daterange']:'';
            if(strpos($stufflabel,'NEW')!==false){//第一次新增自定义简报
                $sql_savesaleskit='insert into ld_homestuffdetail(stufflabel,stuffid,stufflabeltype,stufflabel_zh,stufflabel_en,compute_columns,compute_type,cssname,daterange,viewrange,compute_module,pageurl,advance_demand,advance_demand_groups,is_default) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)';
                $queryrrrr=$adb->pquery($sql_savesaleskit,array($stuffdetailinfo['en'],$stuffid,'fixedstr',$stuffdetailinfo['zh'],$stuffdetailinfo['en'],$computeinfo['computecolumns'],
                    $computeinfo['computetype'],$stuffdetailinfo['css'],$computeinfo['daterange'],$computeinfo['viewrange'],$computeinfo['computemodule'],'',$computeinfo['advance_demand'],
                    $computeinfo['advance_demand_groups'],$stuffdetailinfo['is_default']));

                $id=$adb->getLastInsertID();
                //zxm 20230714 保证stufflabel不重复
                $update_stufflabel_sql = "update ld_homestuffdetail set stufflabel=? where id=?";
                $adb->pquery($update_stufflabel_sql,array('custom_saleskit_'.$id,$id));

            }else{
                $sql_savesaleskit='update ld_homestuffdetail set stufflabel_zh=?,stufflabel_en=?,compute_columns=?,compute_type=?,cssname=?,daterange=?,viewrange=?,compute_module=?,pageurl=?,advance_demand=?,advance_demand_groups=? where id=?';
                $adb->pquery($sql_savesaleskit,array($stuffdetailinfo['zh'],$stuffdetailinfo['en'],$computeinfo['computecolumns'],$computeinfo['computetype'],$stuffdetailinfo['css'],$computeinfo['daterange'],$computeinfo['viewrange'],$computeinfo['computemodule'],$stuffdetailinfo['pageurl'],$computeinfo['advance_demand'],$computeinfo['advance_demand_groups'],$computeinfo['homestuffdetailid']));

                $id=$computeinfo['homestuffdetailid'];
            }
            if($stuffdetailinfo['used'] === 'yes') {
                $sql_layout='insert into ld_homestuffsaleskit2board(boardid,homestuffdetailid,sequence) values(?,?,?)';
                $adb->pquery($sql_layout,array($boardid,$id,$stuffdetailinfo['sequence']));
            }
        }
    }
    ConvertTojsonString(1, '', "success");
    exit();
}

if($_REQUEST['mode']=='delsaleskit'){

    $stufflabel=$_REQUEST['del_stufflabel'];

    $delete_sql="delete from ld_homestuffsaleskit2board where stuffdetailid in(select id from ld_homestuffdetail where stufflabel=?)";
    $adb->pquery($delete_sql,array($stufflabel));

    $sql="delete from ld_homestuffdetail where stufflabel=?";
    $adb->pquery($sql,array($stufflabel));

    ConvertTojsonString(1, '', "success");
    exit();
}

if($_REQUEST['mode']=='getModuleFields'){
    $selectmodule=$_REQUEST['selectmodule'];
    $SalesKitfieldsArr=$SalesKitEditObj->getSalesKitModuleFields($selectmodule);
    //获取字段
    $main_field_arr[$selectmodule] = $SalesKitfieldsArr['main'];
    $detail_field_arr[$selectmodule] = $SalesKitfieldsArr['detail'];

    $arr['main_field_arr'] = $main_field_arr;
    $arr['detail_field_arr'] = $detail_field_arr;
    $arr['SalesKitfieldsArr'] = $SalesKitfieldsArr;
    ConvertTojsonString(1, $arr, "success");
    exit();
}


//60
//zxm 20230804 默认看板显示自定义简报可选
if($stuffid==35){
    $sql=" select * from ld_homestuffdetail
            where stuffid=$stuffid group by  stufflabel
            ORDER BY sequence asc,stufflabel asc;";
}else{
    //64 65 两个组件的 没有存条件 直接写的sql  2021-0713 zxm 工程行业组件64.65
    $sql=" select * from ld_homestuffdetail
            where stuffid=$stuffid
            ORDER BY ld_homestuffdetail.sequence asc,stufflabel asc;";
}

    $result=$adb->pquery($sql,array());
    $rows=$adb->num_rows($result);
    for($i=0;$i<$rows;$i++){
        $stufflabel=$adb->query_result($result,$i,'stufflabel');
        $stufflabeltype=$adb->query_result($result,$i,'stufflabeltype');
        $stufflabel_zh = $adb->query_result($result, $i, 'stufflabel_zh');
        $stufflabel_en = $adb->query_result($result, $i, 'stufflabel_en');
        $compute_module=$adb->query_result($result,$i,'compute_module');
        $compute_columns=$adb->query_result($result,$i,'compute_columns');
        $compute_type=$adb->query_result($result,$i,'compute_type');
        $presence=$adb->query_result($result,$i,'presence');
        $is_default=$adb->query_result($result,$i,'is_default');
        $searchcolumns=array();
        if($stufflabel_zh=='')
        {
            $stufflabel_zh=getFixedLabel($stufflabel);

        }
        if($stufflabel_en=='')
        {
            $stufflabel_en=getFixedLabel($stufflabel);
        }
        if($languageType=='zh'){
            $label=$stufflabel_zh;
        }elseif($languageType=='en'){
            $label=$stufflabel_en;
        }
        if($stuffid==35) {
            $moduleactive = 'no';
            if (vtlib_isModuleActive($compute_module) || $compute_module == 'Singin') {
                $moduleactive = 'yes';
            }
        }else{
            //64 65 两个组件的 没有存条件 直接写的sql  2021-0713 zxm 工程行业组件64.65
            $moduleactive = 'yes';
        }
        //zxm 2021-0128 0044489: （https://61mis.com/WX/kh42300 [^]）客户问题（刘家云），没有服务合同模块，销售简报中应该不显示【服务合同收款额】组件
        if($stufflabel=="NewServiceContractsReceipts"&&!vtlib_isModuleActive('ServiceContracts')){
            $moduleactive='no';
        }
        //duan 2022-0302 客户和销售机会模块都开启后，才会显示‘线索升级到客户和销售机会数’
        if($stufflabel=="LeadUgradeToPotentials"&&(!vtlib_isModuleActive('Accounts')||!vtlib_isModuleActive('Potentials'))){
            $moduleactive='no';
        }
       
        if($moduleactive=='yes'){
            if($presence=='yes'){
                $selectstuffle[]=array('stufflabel'=>$stufflabel,'label'=>$label);
            }
            else{
                $un_selectstuffle[]=array('stufflabel'=>$stufflabel,'label'=>$label);
            }
        }
    }

    $smarty->assign('un_selectstuffle',$un_selectstuffle);
    $smarty->assign('selectstuffle',$selectstuffle);

	$_REQUEST['diony']='diony';
	$arr['oktext']=getFixedLabel("SAVE");
	$arr['canceltext']=getFixedLabel("CANCEL");
	$arr['title']=getFixedLabel('saleskit');
	$str=$smarty->fetch('Home/SalesKitSet.tpl');
	$arr['content']=$str;
	ConvertTojsonString(1,$arr,"success");
	exit();
?>