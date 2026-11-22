<?php
/**
 * Created by PhpStorm.
 * User: gyq_20
 * Date: 2016/12/7 0007
 * Time: 下午 2:25
 */

header("Content-type: text/html; charset=utf-8");
if(isset($_REQUEST['purpose'])){
    global $current_user;
    require_once(globalStatic::$root_directory.'expansion/camcard/cls_camcard.php');
    
    $purpose = $_REQUEST['purpose'];
    $camobj = new cls_camcard();

    switch($purpose){
        case 'DetailView':  // 显示日程模板列表
            $modulelist = $camobj->getDefaultModuleList('detail');
            //$modulefieldlist = $camobj->getModuleSettedField();
            $smarty=new lingdangCRM_Smarty;
            foreach($modulelist as $val){
                $modulelistNew[] = $val['fieldlabel'];
            }
            if(sizeof($modulelist)>0){$isshow=1;}//判断名片全能王所有模块是否开启
            $OPTIONLIST = $camobj->initEditViewDetail(null,2);
            $smarty->assign('MODULELIST',implode(',',$modulelistNew));
            //$smarty->assign('FieldLIST',$modulefieldlist);
            // require_once('SetmenuControl.php');
            $smarty->assign("BLOCKS",getSettingsBlocks());
            $smarty->assign("ISSHOW",$isshow);
            $smarty->assign('CAMCARDMODULELIST',$modulelist);
            $smarty->assign('OPTIONLIST',$OPTIONLIST);
            $smarty->assign('EDITURL',$camobj->getEditButtonUrl($_REQUEST['blockidsetting'],$_REQUEST['fieldidsetting']));
            $_REQUEST['diony']='yes';
            $arr['content']= $smarty->fetch('camcard/DetailView.tpl');
            ConvertTojsonString(1,$arr,"success");
            break;
        case 'EditView':  //显示日程模板详情页
            $smarty=new lingdangCRM_Smarty;
            $modulelist = $camobj->getDefaultModuleList($_REQUEST['detailcomparid']);
            $OPTIONLIST = $camobj->initEditViewDetail($_REQUEST['detailcomparid'],0);
            require_once('SetmenuControl.php');
            $smarty->assign("BLOCKS",getSettingsBlocks());
            $smarty->assign('MODULELIST',$modulelist);//getModuleFieldNames
            $smarty->assign('MODULELIST_FIRSY',$camobj->modulelist_primary);//getModuleFieldNames
            $smarty->assign('OPTIONLIST',$OPTIONLIST);
            $smarty->assign('FIELDIDSETTING',$_REQUEST['fieldidsetting']);
			$_REQUEST['diony']='yes';
			$arr['title'] = getFixedLabel('LBL_EXPANSION_CAMCARD');
			$arr['oktext']=getFixedLabel("SAVE");
			$arr['canceltext']=getFixedLabel("CANCEL");
			$arr['content']= $smarty->fetch('camcard/EditView.tpl');
            ConvertTojsonString(1,$arr,"success");
            break;
        case 'SaveSettings':    //保存日程模板
            $camobj->SaveSettings();
			$_REQUEST['diony']='yes';
            ConvertTojsonString(1,array(),"success");
			break;
        case 'switchTemplate':  //列表分配保存
            $smarty=new lingdangCRM_Smarty;
            $modulelist = $camobj->getDefaultModuleList();
            $OPTIONLIST = $camobj->initEditViewDetail($_REQUEST['comparid'],0);
            
            require_once('SetmenuControl.php');
            
            $smarty->assign("BLOCKS",getSettingsBlocks());
            $smarty->assign('OPTIONLIST',$OPTIONLIST);
            $smarty->assign('FIELDIDSETTING',$_REQUEST['fieldidsetting']);
            $smarty->display('camcard/EditViewDetail.tpl');
            break;
        case 'CamCardDetailView'://名片全能王列表选择模块后查看    
            $smarty=new lingdangCRM_Smarty;
            $modulelist = $camobj->getDefaultModuleList();
            $OPTIONLISTS = $camobj->initEditViewDetail($_REQUEST['comparid'],2);

            require_once('SetmenuControl.php');
            $smarty->assign("BLOCKS",getSettingsBlocks());
            $smarty->assign('OPTIONLIST',$OPTIONLISTS);
            $smarty->assign('FIELDIDSETTING',$_REQUEST['fieldidsetting']);
            $smarty->display('camcard/DisplayViewDetail.tpl');
            break;
    }
}
?>