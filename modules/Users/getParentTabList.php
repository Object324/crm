<?php
global $current_user,$adb;
require(globalStatic::$root_directory.'dataCache/tabdatas/parent_language.php');
$languageType=getLanguageType($current_user);
crm_load_class_file("LoginHistory",'modules/Users');
$loginhistoryobj=new LoginHistory();
$loginhistoryobj->checkLogin('ajax');
crm_load_class_file('MenuUtils','modules/Users');
$MenuUtilsObj = new MenuUtils();
if(isset($_REQUEST['user_type']) && $_REQUEST['user_type'] == 'prm'){
    $parenttablist= $MenuUtilsObj->getPrmmenurelInfo();
}else{
    $parenttablist= $MenuUtilsObj->getAllParenttabmoduleslist();
}

$settingmenulist = [];
//用户和权限管理--成员管理
if(isPermitted('Users','index')=='yes' && vtlib_isModuleActive('Users')){
	$settingmenulist['Settingup'][] = Array('modulename'=>getTransTab('Users'),'tablabel'=>"Users",'tab_tablename'=>'ld_tab','id'=>'-1');
}
//部门、权限、系统设置
if(is_admin($current_user)){
	$settingmenulist['Settingup'][] = Array('modulename'=>getFixedLabel('profileauthority'), 'tablabel'=>"listroles",'tab_tablename'=>'ld_tab','id'=>'-3');
    $settingmenulist['Settingup'][] = Array('modulename'=>getFixedLabel('LOGINPOLICY'),'tablabel'=>'LoginPolicy','tab_tablename'=>'ld_tab','id'=>'-2'); //2023-7-10 xxy 登陆策略
}

if(!checkParentTabExists($category)&&$category!="Setup"&&$category!="Settings")
{
    //edit:can reason:11624: 控制面板->菜单定制，设置【工作台】不显示，然后点击导航栏【首页】，如图所示，下面显示的是空白。
    $parenttabkey=array_keys($parenttablist);
    $category=$parenttabkey[0];//只取第一个，因为目前也就是首页有两个地方可以点击
}

if($category=="Settings")
{
    $category="Setup";
}
$showpubliclabel_module_arr = [];
//duan 20240815 根据公海参数添加公海模块
foreach ($parenttablist as $menu_key => $menu_list){
    $new_arr = [];
    foreach ($menu_list as $tmp_index => $modinfo)
    {
        $module = $modinfo['tablabel'];
        $tab_tablename = $modinfo['tab_tablename'];

        if($tab_tablename == 'ld_tab' && ($module == 'Accounts' || $module == 'Leads')){
            if($module == 'Accounts'){
                crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
                $cls_PublicPoolobj = cls_PublicAccounts::getInstance($module);
            }else{
                crm_load_class_file('cls_PublicLeads', 'modules/Leads');
                $cls_PublicPoolobj = cls_PublicLeads::getInstance($module);
            }
            $public_account = $cls_PublicPoolobj->getPublicAccountConfig();

            //如果判断显示公海模块,则动态添加公海客户和公海线索模块
            if($public_account['status'] == 'yes' && $public_account['showpublicmodule'] == 'yes'){
                $new_modinfo =  $modinfo;
                $new_modinfo['modulename'] = getFixedLabel('HIGHSEAS').$new_modinfo['modulename'];
                $new_modinfo['id'] = -1*$new_modinfo['id'];
                $new_modinfo['linkurl'] = 'index.php?pageto_module='.$module.'&pageto_action=index&page_addurl=%26publicmoduletype%3Dpublic';
                $new_modinfo['page_addurl'] = '&publicmoduletype=public';
                $new_modinfo['uselinkurl'] = 'yes';

                $modinfo['linkurl'] = 'index.php?pageto_module='.$module.'&pageto_action=index&page_addurl=%26publicmoduletype%3Dnormal';
                $modinfo['page_addurl'] = '&publicmoduletype=normal';
                $modinfo['uselinkurl'] = 'yes';

                if(isset($_REQUEST['page_addurl']) && strpos($_REQUEST['page_addurl'],'publicmoduletype=public')){
                    $showpubliclabel_module_arr[] = $module;
                }

                $new_arr[] = $modinfo;
                $new_arr[] = $new_modinfo;
                continue;
            }
        }
        $new_arr[] = $modinfo;
    }
    $parenttablist[$menu_key] = $new_arr;
}

//左右结构展开和收缩后点击菜单
$_SESSION['bodywidth'] = $_REQUEST['bodywidth'];

//wym XUQIU1002004 皮肤定制可以按用户，不去看paren_language.php里的存值了，直接读数据库的值
$sysdep476 = getSys_deploy(476);
$menutype = $sysdep476['deploy_value'];

//菜单背景色
$menustyleinfo = $MenuUtilsObj->getHeaderMenuColor();

//浅色菜单模式
if($menustyleinfo['Menufont_color'] == '#FFFFFF') {
    $defaultIconPath = 'themes/icon2023/left/dark/';
    if ($menutype == '2') {
        $defaultIconPath = 'themes/icon2024/left/dark/';
    }
}
else {
    $defaultIconPath = 'themes/icon2023/left/light/';
    if ($menutype == '2') {
        $defaultIconPath = 'themes/icon2024/left/light/';
    }
}
//zxm @date:2024/11/5 @reason: XUQIU20241029-07 模块图标没有替换，使用CND链接
$defaultIconPath = getGlobalImageUrl().$defaultIconPath;

$query='select fieldlabel ,ld_parenttab.parenttab_label,languagetype,ld_parenttab.imagename,ld_parenttab.inactive_icon,ld_parenttab.active_icon,ld_parenttab.fonticon,ld_parenttab.fonticon_active from ld_tranlabel left join ld_parenttab on ld_parenttab.parenttabid=ld_tranlabel.relateid
             where (languagetype=? or languagetype=?)  and trantable=? 
              order by ld_parenttab.sequence asc ';
$result=$adb->pquery($query,array('zh','en','ld_parenttab'));
$num_rows=$adb->num_rows($result);

for($i=0;$i<$num_rows;$i++){
    $parentlabel=$adb->query_result($result,$i,'parenttab_label');
    $imagename=$adb->query_result($result,$i,'imagename');
    $inactive_icon=$adb->query_result($result,$i,'inactive_icon');//未选中图标
    $active_icon=$adb->query_result($result,$i,'active_icon');//选中图标
    $fonticon=$adb->query_result($result,$i,'fonticon');//字体图标
    $fonticon_active=$adb->query_result($result,$i,'fonticon_active');//字体图标
    //zxm2021-1206 图标处理
    if(empty($inactive_icon)||!file_exists(globalStatic::$root_directory.$inactive_icon)){
        $inactive_icon_new = $defaultIconPath.$imagename;//图标值为空 或者文件不存在 返回空
        //字体图标
        if($menutype == '2' && !empty($fonticon)){
            $inactive_icon_new = $fonticon;
        }
    }else{
        $inactive_icon_new = $inactive_icon;
    }
    if(empty($active_icon)||!file_exists(globalStatic::$root_directory.$active_icon)){
        if(!empty($inactive_icon)&&!file_exists($inactive_icon)){
            $active_icon_new = $inactive_icon;//如果选中图标不存在 未选中图标存在 则使用未选中图标
        }else{
            //字体图标
            if($menutype == '2' && !empty($fonticon)){
                if(empty($fonticon_active) ){
                    $active_icon_new = $fonticon;
                }else{
                    $active_icon_new = $fonticon_active;
                }
            }else{
                $imagename_new = str_replace('ico.png','ico_hover.png',$imagename);
                if(file_exists(globalStatic::$root_directory.$defaultIconPath.$imagename_new)){
                    $active_icon_new = $defaultIconPath.$imagename_new;
                }else{
                    $active_icon_new = $defaultIconPath.$imagename;
                }
            }
        }
    }else{
        $active_icon_new = $active_icon;
    }
    $tmpimage_string[$parentlabel] = array('inactive'=>$inactive_icon_new,'active'=>$active_icon_new);
}
//zxm @date:2024/11/5 @reason: 用户和权限设置 父级菜单  读的Settings菜单的图片信息
$tmpimage_string["Settingup"] = $tmpimage_string["Settings"];
unset($tmpimage_string["Settings"]);

if(!is_array($tmpimage_string)||empty($tmpimage_string))
{
    create_parent_language();
}
if(!is_array($parenttablist))
{
    $parenttablist=[];
}
if(array_key_exists("Settingup",$settingmenulist)){
    $parenttablist=array_merge($parenttablist,$settingmenulist);
    $parent_string['Settingup']=getFixedLabel('UserPermissionManagement');
    $enparent_string['Settingup']=getFixedLabel('UserPermissionManagement');
}

$arr['parenttabimagelist']=$tmpimage_string;

$arr['parenttablist']=$parenttablist;
if($languageType == 'en'){
    $arr['parenttabs']=$enparent_string;
}
else{
    $arr['parenttabs']=$parent_string;
}
       

//ls 2021-08-04 【ID1001788】左侧菜单导航中搜索，建议增加拼音搜索
//获取左侧菜单栏所有子菜单tab的拼音集合
//zxm 20230901 做缓存
$pinyinAlllabel = $MenuUtilsObj->getParentTabListPinyin();
$arr['pinyinAlllabel'] = $pinyinAlllabel;

$arr['bodywidth']=$_SESSION['bodywidth'];
$arr['childmenufile']='';

if($_REQUEST['pageto_module']!='')
{
    if($_REQUEST['pageto_module']=='undefined')
    {
      $_REQUEST['pageto_module']=  $default_module;
    }
    $arr['default_module']=$_REQUEST['pageto_module'];
    if($_REQUEST['pageto_action'])
    {
        $arr['default_action']=$_REQUEST['pageto_action'];
    }
    else{
        $arr['default_action']='index';
    }
    if($_REQUEST['pageto_record']>0){
         $arr['record']=$_REQUEST['pageto_record'];
    }
    if($_REQUEST['cur_menuid']>0){
        $arr['cur_menuid']=$_REQUEST['cur_menuid'];
    }
    if($_REQUEST['pageto_menufile']!='')
    {
        $arr['childmenufile']=$_REQUEST['pageto_menufile'];
    }
    if($arr['default_module']=='listroles'||$arr['default_action']=='listroles')
    {
        //edit:can 2021-01-08 43180: （https://61mis.com/kfbcrm [^]）系统设置->角色权限，左侧菜单栏中“角色权限”使用新的页签打开超链接时，页签标题角色权限显示英文
        $default_label=getFixedLabel("ROLES");
    }
    else
        $default_label=getTranstab($arr['default_module']);

    if(in_array($arr['default_module'],$showpubliclabel_module_arr)){
        $default_label = getFixedLabel('HIGHSEAS').$default_label;
    }

    $arr['default_label']=$default_label;
    if($_REQUEST['view_type']!=''){
        $arr['view_type'] = $_REQUEST['view_type'];
    }

	//44911: （https://61mis.com/kfbcrm [^]）链接模块，点击【客户_重点客户】链接模块进入序时簿列表界面，刷新一下链接模块名称变成了原来的【客户】模块
	if($_REQUEST['pageto_action'] == 'LinkModuleCustom' && !empty($_REQUEST['page_addurl'])){
        //zxm 20221229 项目甘特图界面刷新后界面标签显示错误
		//$query = "select zh_label,en_label from ld_linkmodulecustom where url = ?  and `status` = 'yes' limit 1";
		$query = "select b.zh_label,b.en_label from ld_parenttabrel a left join ld_linkmodulecustom b on a.tabid=b.id where a.tab_tablename='ld_linkmodulecustom' and a.id=? limit  1";
        //zkt 0047391: 报表库报表设置为“链接模块”后，在菜单中打开是正常的，打开后刷新界面，模块名称就显示错误了
        $reporturl = explode('&crmreportuuid',urldecode($_REQUEST['page_addurl']));
        //项目甘特图界面刷新后界面标签显示错误
        $reporturl = explode('crmreportuuid',$reporturl[0]);
//		$result = $adb->pquery($query,array(str_replace('&link=','',$reporturl[0])));
		$result = $adb->pquery($query,array($_REQUEST['cur_menuid']));
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			if($languageType == 'zh'){
				$arr['default_label'] = $adb->query_result($result,0,'zh_label');
			}else{
				$arr['default_label'] = $adb->query_result($result,0,'en_label');
			}
		}
	}
    $arr['page_addurl']=$_REQUEST['page_addurl'];
    $arr['pageto_create']='no';
    if(isset($_REQUEST['pageto_create']))
         $arr['pageto_create']=$_REQUEST['pageto_create'];
    
}

else
{
    //刷新菜单
    if(isset($_REQUEST['leftmenu_left']) && $_REQUEST['leftmenu_left'] == 'yes'){
        $smarty = new lingdangCRM_Smarty;
        $smarty->assign("CURRENT_USER_ID", $current_user->id);
        if(isset($global_hideleftmenu)){
            $smarty->assign('global_hideleftmenu',$global_hideleftmenu);
        }
        else{
            $smarty->assign('global_hideleftmenu','');
        }
        $smarty->assign('RANDNUM',strtotime(date("Y-m-d H:i:s")));

        $logoInfo = $MenuUtilsObj->getorganizationdetailslogo();
        $smarty->assign('MENUSTYLE',$logoInfo['MENUSTYLE']);
        $smarty->assign("LOGO",$logoInfo['LOGO']);
        $smarty->assign("cur_menuid",$_REQUEST['cur_menuid']);
        $smarty->assign("SMALLLOGO",$logoInfo['SMALLLOGO']);

        $smarty->assign("MENUSTYLEINFO",$menustyleinfo);

        $smarty->assign("CURRENT_USER",$current_user);

        if(empty($menutype)){
            $arr['menucontent'] = $smarty->fetch('SuspensionMenu.tpl');
        }
        else{
            if($menutype == 1){
                $arr['menucontent'] = $smarty->fetch('SuspensionMenu.tpl');
            }else{
                $arr['menucontent'] = $smarty->fetch('DropdownMenu.tpl');
            }
        }

    }else{
        if(!vtlib_isModuleActive($default_module)){
            //edit:can 20200715 42008: 首页模块关闭后，登录后没有进去客户模块
            $default_module='Accounts';
        }
        $arr['default_module']=$default_module;
        $arr['default_action']=$default_action;
        $arr['default_url']=$default_url;
        $arr['default_label']=getTranstab($default_module);
        $arr['record']=0;
    }
}

$arr['current_user_id']=$current_user->id;
$_REQUEST['diony']='yes';


$arr['menutype']=$menutype;
$arr['menufont']=$menustyleinfo['Menufont_color'];
$arr['selectedparenttab'] = '';
$arr['selectedparenttabrel'] = '';
//记住当前菜单
$common_idstr = getUsersettingByLabel('Users',$current_user->id,'CommonMenu');
if(!empty($common_idstr)){
    $common_idarr = explode(',',$common_idstr);
    if($common_idarr[0] > 0){
        foreach ($parenttablist as $parenttabname => $parenttabrelarr){
            foreach($parenttabrelarr as $index => $parenttabrel){
                if($parenttabrel['id'] == $common_idarr[0] && $parenttabrel['tablabel'] == $_REQUEST['pageto_module']){
                    $arr['selectedparenttab']=$parenttabname;
                    $arr['selectedparenttabrel']=$common_idarr[0];
                    break;
                }
            }
        }
    }
}
if(empty($arr['selectedparenttab']) || empty($arr['selectedparenttabrel'])){
    foreach ($parenttablist as $parenttabname => $parenttabrelarr){
        foreach($parenttabrelarr as $index => $parenttabrel){
            if($parenttabrel['tablabel'] == $_REQUEST['pageto_module'] && !isset($_REQUEST['page_addurl'])){
                $arr['selectedparenttab']=$parenttabname;
                $arr['selectedparenttabrel']=$parenttabrel['id'];
                break;
            }
        }
    }
}

ConvertTojsonString(1,$arr,'success');

?>