<?php
/**
 * edit：hzx 202107
 * 异地登录
 * 

crm_load_class_file('LoginHistory','modules/Users');

$loginhistoryobj=new LoginHistory();
$loginhistoryobj->checkLogin('ajax');
*/
/**
 * 权限，模块是否激活判断
 * 跳过头部php文件判断
 * */

if($_REQUEST['module'] == 'Documents' && $action == 'DownloadFile')
{
	include('modules/Documents/DownloadFile.php');
	exit;
}


/**
 * edit:can
 * date:20131217
 * reason:所有ajax都不用条用header.php页面
 * */
if((isset($_REQUEST['ReportHeader'])&&strtolower($_REQUEST['ReportHeader'])=='dheader')||$action=='HomeAjax'||$skipHeaders==true||$action=='SaveCallButler'||$action=='getTimeAndUserID')
{
    
    include('Smarty_setup.php');
    $skipHeaders=true;
}
/*
$data = htmlentities(file_get_contents('dataCache/tabdatas/tabdata.php'));
if(stripos($data,'$action_label_array=;')!=false)
{
        include(globalStatic::$root_directory."modules/Users/CreateUserPrivilegeFile.php");
        create_tab_data_file();
        create_parenttab_data_file();
}
*/



if(!$skipHeaders) {
  
	if($use_current_login)
	{
		if(isset($_REQUEST['category']) && $_REQUEST['category'] !='')
		{
			$category = ($_REQUEST['category']);
		}
        elseif($action=='TemplatePrintHtml')
        {
            include('modules/Settings/TemplatePrintHtml.php');
            exit();
        }
        elseif($module=='OftenUseReport'&&isset($_REQUEST['Print'])&&$_REQUEST['Print']==true)
        {
            include($root_directory.'modules/OftenUseReport/ListView.php');
            exit();
        }
		else
		{
	
         
		 // $category = getParentTabFromModules($currentModule);
		}
      /* if($_REQUEST['module']!='')
         {
                $_SESSION['prevmenu_module']=$_REQUEST['module'];
         }*/
		include($root_directory.'modules/lingdang/header.php');
      
	}
	

	echo "<!-- startscrmprint -->";
}

$theme = $default_theme;

if($currentModule=='Users'&&($action=='index'||$action=="ListView"))
{
    //30972: 普通用户没有用户管理权限，点击右上方用户名，进入用户管理后，点击【返回用户管理列表】，结果：跳转到了用户管理列表界面
    $skipSecurityCheck=false;
    $action="index";
}

if(!$skipSecurityCheck && $use_current_login)
{
    //require_once('include/utils/UserInfoUtil.php');
	if(preg_match('/Ajax/',$action)) {
		if($_REQUEST['ajxaction'] == 'LOADRELATEDLIST'){
			$now_action = 'DetailView';
		} else {
			$now_action=($_REQUEST['file']);
		}
	} else {
		$now_action=$action;
	}

    if(isset($_REQUEST['isDuplicate'])&&($_REQUEST['isDuplicate']===true||$_REQUEST['isDuplicate']=='true'))
    {
        
        //edit:can 14809: 关于复制功能的问题;
        $display = isPermitted($module,"Copy","");
    }
	else if(isset($_REQUEST['record']) && $_REQUEST['record'] != ''&&$_REQUEST['record'] != '0'&&$_REQUEST['action']!='index')
	{
	    
		 if($module=='PublicAnnouncement'&&$now_action=='DetailView')//公告查看权限
		 {
			$sql='select userid from ld_receipts where id=? and userid=?';
			$announceresult=$adb->pquery($sql,array($_REQUEST['record'],$current_user->id));
			if($adb->num_rows($announceresult)>0)
			{
				$display='yes';
			}
		 }
		 if($display!='yes')
			$display = isPermitted($module,$now_action,$_REQUEST['record']);
		
	}
     else if($_REQUEST['relatedcreate']=='yes')
    {
        global $adb;
        $display = isPermitted($module,"Create");
        $frommodule=$_REQUEST['frommodule'];
        $approve_system_deploys=getSys_Approvedeploy($frommodule);
        if(!empty($approve_system_deploys) && $approve_system_deploys['deploy_value']==1)
        {
            //不启用审批参数
            //22805: 报价单>明细：报价单已经关闭审批功能，关联创建合同订单，弹出提示信息【 该单据未审批，不允许创建相关联的单据!】
        }
        else if($display=='yes')
        {
              $fromid=$_REQUEST['fromid'];
                
                if(empty($frommodule))
                {
                   $frommodule= getSalesEntityType($fromid);
                   
                }
                if(empty($frommodule))
                {
                    $display='yes';
                    
                }
                $from_focus=CRMEntity::getInstance($frommodule);
            
                $approve_demand= $from_focus->get_approve_demand_byModule($module);
           
            if($approve_demand==1)
            {
               
                $approvestatusColumnname=$from_focus->getApproveStatusColumnName();
                $sql='select '.$approvestatusColumnname.' from '.$from_focus->table_name.'  where '.$from_focus->table_index.'=?';
               
                $result=$adb->pquery($sql,array($fromid));
                if($adb->num_rows($result)>0)
                {
                    
                    $approvestatus_label=$adb->query_result($result,0,0);
                    //zkt 20220602 52420(http://erp.zonergy.com:85/crm/)(客户问题-龙卫东）收款单模块-选择源单-销售合同审批要求修改“已审批后”中文环境正常，英文环境在已审批的销售合同详情下推收款单会报错
                    //zkt 20220614 BUG0052800 	http://crm.zonergy.com:85/crm 四川中兴；发货通知单CK74，单据下推收货确认单会报错 
                    if($approvestatus_label==$from_focus->getApproveStatus_label())
                    {
                        
                    }
                    else
                    {
                        $errProfile = getFixedLabel('NOTCREATERELVANTBILL');
                        $display='no';
                        
                    }
                }
            }
            //edit:can 2020-10-19 42930: (61mis.com/kfbcrm)系统设置-页面设置-合同订单-客户名称；在系统设置-页面设置-合同订单-客户名称字段，设置筛选条件后，在合同订单模块，新建订单，不符合条件的客户不显示；但在客户模块，不符合条件的客户却可以新建订单。
           $uitype_arr=cls_module_uitype::getModuleUitype($_REQUEST['module'],$_REQUEST['frommodule']);
           $focus=CRMEntity::getInstance($_REQUEST['module']);
           
            foreach($uitype_arr as $tmpuitype=>$uitype)
            {
                 $_REQUEST['fieldname']=$focus->fieldobj->getFieldInfoBykeyValue('uitype',$uitype,'fieldname');
                 break;
            }
            if($_REQUEST['fieldname']!=''&&$_REQUEST['fromid']>0&&(!isset($_REQUEST['fromcheck']) || $_REQUEST['fromcheck']!='no'))
            {
                if($_REQUEST['frommodule']=='Accounts'||$_REQUEST['frommodule']=='Leads')
                {
                        if(!empty($_SESSION['lvsAccount'][$_REQUEST['frommodule']]['pagepublicaccounttype'])){
                            $before_accounttype = $_SESSION['lvsAccount'][$_REQUEST['frommodule']]['pagepublicaccounttype'];
                        }
                         //edit:can 20210707 046768: （http://akjykj.vicp.cc:85/crm [^]）客户问题（安康金源），登录系统直接进入联系人列表界面，点击【客户名称】，再点击相关信息->联系人下方的【新建】按钮时，一直提示不符合条件
                        setSearchAllAccount();//设置查询所有的客户（包括公海客户）
                            
                }
               
                //edit:can 2020-10-19  v42930: (61mis.com/kfbcrm)系统设置-页面设置-合同订单-客户名称；在系统设置-页面设置-合同订单-客户名称字段，设置筛选条件后，在合同订单模块，新建订单，不符合条件的客户不显示；但在客户模块，不符合条件的客户却可以新建订单。
                
                $_REQUEST['selectmodule']=$_REQUEST['frommodule'];
                $_REQUEST['frommodule']=$_REQUEST['module'];
                crm_load_class_file("SelectRelatedPopu",'include/SelectRelatedPopu');
                //zkt 20220908 BUG0056228合同编号CGHT00668为采购合同，之前付过一次款，但是没有完全付完，再次新增付款单的时候就提示不符合付款条件了。
                // 模块可以选择源单，但关联创建提示 “该单据不符合条件，不允许创建相关联的单据！”
                $requestvalue_arr = [];
                if(!isset($_REQUEST['requestvalues'])){
                    $tmpcurrentfocus = CRMEntity::getInstance($_REQUEST['module']);
                    $currentmodulefields = $tmpcurrentfocus->fieldobj->getModuleFields();
                    foreach($currentmodulefields as $tmpfieldname=>$tmpfieldinfo)
                    {
                        $tmpcolumnname = $tmpfieldinfo->getcolumnname();
                        $defaultvalue = $tmpfieldinfo->getDefaultvalue();
                        $requestvalue_arr[$tmpcolumnname] = $defaultvalue;
                    }
                   
                    $_REQUEST['requestvalues'] = ldcrm_json_encode($requestvalue_arr);
                }
                $SelectRelatedPopuobj=new SelectRelatedPopu($frommodule,$adb);
                $SelectRelatedPopuobj->setRelatedPopopSql();
                if(!empty($requestvalue_arr)){
                    unset($_REQUEST['requestvalues']);
                }
                $fromtablename=$from_focus->table_name;
                $fromtableindex=$from_focus->table_index;
               
                $sql=$SelectRelatedPopuobj->page_list_query." and $fromtablename.$fromtableindex=".$_REQUEST['fromid'];

                $result=$adb->pquery($sql,array());
                
                if($adb->num_rows($result)<=0)
                {
                     $errProfile = getFixedLabel('BillMeetCondition');
                     $display='no';
                }
                $_REQUEST['frommodule']=$frommodule;
                //duan 20230525 判断完关联创建条件后更新为原有的accounttype
                if($frommodule=='Accounts'||$frommodule=='Leads'){
                    if(!empty($before_accounttype)){
                        $_SESSION['lvsAccount'][$frommodule]['pagepublicaccounttype'] = $before_accounttype;
                    }
                }
            }
            
            
        }
      
    }
	else
	{
	   //zkt 20230607 收付款单切换源单类型时需要判断权限。
		 if((isset($_REQUEST['Create']) && $_REQUEST['Create']!='') || (isset($_REQUEST['frompagetype']) && $_REQUEST['frompagetype']=='create'))
		 {
			 $display = isPermitted($module,"Create");
		 }
		 else if(isset($_REQUEST['action']) && ($_REQUEST['action']=='ProductListView' || $_REQUEST['action']=='Printview' || $_REQUEST['action']=='DetailNation' || $now_action=='getFldValueBySqlFormula' || $now_action=='getRelatedPicklistByColumn'))
		 {
			$display = 'yes';
		 }
		 else
		 {
		    if(isset($_REQUEST['frommodule'])){
                $dir = "modules/".$_REQUEST['frommodule']."/ProcessDuplicates.php";
                if(file_exists($dir)||$_REQUEST['frommodule']=='CashBill'||$_REQUEST['frommodule']=='SendCashBill')
                {
        		      $display = 'yes'; 
                }else{
                        $display = isPermitted($module,$now_action);
                }

		    }else{
		     
   			  $display = isPermitted($module,$now_action);
		    }
		 }
		 
	}


}
if(($currentModule=='Users'&&($action=='index'||$action=="ListView"))||$action=='DetailView'||$action=='ListView'||$action=='index')
{
    
}
else if(!$_REQUEST['callfilename']&&!$_REQUEST['calltype']&&$display=='no'&&$module!='Emails'&&
((!get_file_address($module,'ProductDetails')&&!get_file_address($module,$module."DetailFieldsHtml"))
||$module=='ServiceCharge'))
{
    $_REQUEST['diony']='diony';
	if(!empty($errProfile))
		ConvertTojsonString("-1",array(),$errProfile);
	else
		ConvertTojsonString("-1",array(),getFixedLabel('NOPERMITTEDEXECUTE'));
}
if($display == "no")
{   
	global $errProfile;
    $_REQUEST['diony']='yes';
    
    $errorhtml= '<link href="themes/softed/global.css" rel="stylesheet" type="text/css" />';
    $errorhtml.= "<div id='warningTable' class='warningTable'>";
    $errorhtml.= "<div class='warningTableContent'>
            <div class='wtc_img'><img src='themes/images/icon-prohibit.png'></div>
            <div class='wtc_title'>".getFixedLabel('REMINDER')."</div>";
            if(trim($errProfile) != ''){
                $msg=$errProfile;
                $errorhtml.= "<div class='wtc_content'>".$errProfile."</div>";
            }
            else{
                $msg=getFixedLabel('NOPERMITTEDEXECUTE');
                //$errorhtml.= "<div class='wtc_content'>".getFixedLabel('NOPERMITTEDEXECUTE')."!</div>";
            }
            //35188: 温馨提示信息的“返回”按钮，修改为“关闭”，或者去掉【返回】按钮
           /* if($action=="Popup"){
                echo "<div class='wtc_btn'><input value=".getFixedLabel('RETURN')." title=".getFixedLabel('RETURN')." class='createauto' onclick='javascript:window.close();' type='button'></div>";
            }else{          
                echo "<div class='wtc_btn'><input value=".getFixedLabel('RETURN')." title=".getFixedLabel('RETURN')." class='createauto' onclick='javascript:window.history.back();' type='button'></div>";
            }*/

    $errorhtml.= "</div>";
    $errorhtml.= "</div>";
    $errorhtml.= "<script type='text/javascript' language='JavaScript'>
            var a = ld('.Header').outerHeight(),//头部高度
                c_height = 0,
                s_height = ld(window).height();
            if(a==null) a=0;
            c_height = s_height-a;
            ld('#warningTable').css('height',c_height);
            ld('.warningTableContent').css('margin-top',-a/2);
          </script>";
    ConvertTojsonString(-1,array(),$msg);
} 

else if(!vtlib_isModuleActive($currentModule)) {
 global $current_user;
 if(empty($action))
     $action='';
    if(strtolower($currentModule)=="home"&& isset($action) &&  (strtolower($action))=="index")
    {
       
        /*
        edit:can
        date:20131014
        reason:05297: 若首页模块管理后：则打开软件时，默认显示客户模块
        */
        $currentModule='Accounts';
        $action="index";
       
        if(vtlib_isModuleActive($currentModule))
             echo "<script>window.location='index.php?module=Accounts&action=index'</script>";
        else
        {
            //37108: 如果设置的默认模块没有启用，则进入客户模块，如果客户模块也没有启用则进入个人信息详情界面
            echo "<script>window.location='index.php?module=Users&action=DetailView&record=".$current_user->id."'</script>";
            
        }    
    }
    else if(strtolower($currentModule)=="accounts"&& isset($action)&& (strtolower($action)=="index"||strtolower($action)=="listview"))
    {
        echo "<script>window.location='index.php?module=Users&action=DetailView&record=".$current_user->id."'</script>";
    }
    else
    {
       // if(!$_REQUEST['callfilename']&&!$_REQUEST['calltype']&&
       // ((!get_file_address($module,'ProductDetails')&&!get_file_address($module,$module."DetailFieldsHtml"))
       // ||$module=='ServiceCharge')&&$_REQUEST['action']!='DetailView')
       // {
            $_REQUEST['diony']='diony';
            ConvertTojsonString("-1",array(),getFixedLabel('MODULEISNOTACTIVATED'));
       // }
       // else
       // {
		//	if(!empty($_REQUEST['action']) && strtolower($_REQUEST['action']) == 'popup'){
				// $_REQUEST['diony']='diony';
				//ConvertTojsonString("-1",array(),getFixedLabel('MODULEISNOTACTIVATED'));
		//	}
            //else{
				 //echo "<link rel='stylesheet' type='text/css' href='themes/$theme/style.css'>";	
//				echo "<table border='0' cellpadding='5' cellspacing='0' width='100%' height='400px'><tr><td align='center'>";
//				
//				echo "<div class='warningTableContent' style='z-index:600;'>";
//				echo "<div class='wtc_img'><img src='themes/images/icon-warning.png'></div>";
//				echo "<div class='wtc_title'>".getFixedLabel('MODULEISNOTACTIVATED')."</div>";
//				echo "<div class='wtc_btn'></div>";
//				echo "<div></div>";
//				echo "</div>";
//				echo "</td></tr></table>";
			//}
        //}
        
    }
	
}

else
{
    global $current_user;
   
    if($currentModule=='Home'&& strtolower($action)=="index")
    {
         
            $category=getParentTab($currentModule);
            
            if(!checkParentTabExists($category))
            {
                $category=getParentTab('Accounts');
                 $currentModule='Accounts';
                $action="index";
              //37108: 如果设置的默认模块没有启用，则进入客户模块，如果客户模块也没有启用则进入个人信息详情界面
                if(vtlib_isModuleActive('Accounts'))
                        echo "<script>window.location='index.php?module=Accounts&action=index'</script>";
                else
                        echo "<script>window.location='index.php?module=Users&action=DetailView&record='".$current_user->id."'</script>";;
            }
    }
    /**
     * edit:can
     * reason:10362: 如合同订单录入【客户名称】时，在客户弹出框中点击【快速创建】，结果无法保存，如图。
     * */
   if($action=='Popup')
   {
   
    ?>
    <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
    <html>
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    </head>
         <script type="text/javascript">
			var userDateFormat = "yyyy-mm-dd";
         </script>
     <?php
   }
   if(isset($current_user))
   {
       $sql=' insert into ld_paramlog(req_param,createdtime,userid)value(?,?,?)';
       $adb->pquery($sql,array(json_encode($_REQUEST),date("Y-m-d H:i:s"),$current_user->id));

   }
	include($root_directory.$currentModuleFile);
    unset($adb);
    unset($app_strings);
    unset($mod_strings);
}
if($skipHeaders)
{
    exit();
}


?>