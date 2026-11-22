<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>{$BROWSETITLE}</title>
    <meta name="keywords" content="" />
    <meta name="description" content="" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
    <link type="text/css" rel="stylesheet" href="{$CSSURL}themes/{$THEME}/leftmenu.css?v={$GLOBALMINVERSION}">
    <link type="text/css" rel="stylesheet" href="{$CSSURL}themes/{$THEME}/common.css?v={$GLOBALMINVERSION}">
    <link type="text/css" rel="stylesheet" href="{$CSSURL}themes/{$THEME}/Control.css?v={$GLOBALMINVERSION}">
    <style type="text/css">@import url("{$CSSURL}themes/{$THEME}/style.css?v={$GLOBALMINVERSION}");</style>
    <link type="text/css" rel="stylesheet" href="{$CSSURL}themes/{$THEME}/common-23.css?v={$GLOBALMINVERSION}">
    <link rel="stylesheet" href="{$CSSURL}themes/softed/viewer.min.css?v={$GLOBALMINVERSION}" type="text/css" /><!--多选框-->
    <link rel="stylesheet" href="{$CSSURL}themes/softed/select2.css?v={$GLOBALMINVERSION}" type="text/css" /><!--多选框-->
    <link rel="stylesheet" href="{$CSSURL}themes/softed/select2-bootstrap.css?v={$GLOBALMINVERSION}" type="text/css" />
    <link rel="stylesheet" type="text/css" href="{$CRMCOMMONURL}crmcommon/css/treeview/jquery.treeview.css?v={$GLOBALMINVERSION}" /><!--选部门选用户-->
    <link rel="stylesheet" href="{$CRMCOMMONURL}crmcommon/css/webuploader/webuploader.css?v={$GLOBALMINVERSION}" type="text/css" /><!--附件上传-->
    <link rel="stylesheet" href="{$CRMCOMMONURL}crmcommon/css/webuploader/bootstrap.min.css?v={$GLOBALMINVERSION}" type="text/css" /><!--附件上传-->
    <link rel="stylesheet" href="{$CSSURL}themes/softed/elementui-min.css?v={$GLOBALMINVERSION}" type="text/css" /><!--新效果-->
{*    <link rel="stylesheet" href="dataCache/tabdatas/skinset.css?v={$smarty.now}" type="text/css" />*}
    <link rel="stylesheet" type="text/css" href="{$CSSURL}themes/softed/SocialPromotion.css?v={$GLOBALMINVERSION}">
    <link rel="stylesheet" type="text/css" href="{$CSSURL}themes/softed/Homeboard.css?v={$GLOBALMINVERSION}">
    <link rel="stylesheet" type="text/css" href="{$CSSURL}themes/softed/component.css?v={$GLOBALMINVERSION}">
    <link rel="stylesheet" type="text/css" href="{$CSSURL}themes/softed/HorizontalProcess.css?v={$GLOBALMINVERSION}" type="text/css">
    <link rel="stylesheet" type="text/css" href="{$CSSURL}themes/softed/AdvanceProcess.css?v={$GLOBALMINVERSION}" type="text/css">
    <!--菜单背景色自定义-->
    <script>
        var global_js_url='{$JSURL}';
        var global_image_url='{$IMAGEURL}';//zxm @date:2024/11/5 @reason: 系统图片（非用户上传图片访问cdn地址）imageurl
        var global_commonurl='{$CRMCOMMONURL}';
        var global_js_version='{$GLOBALMINVERSION}';
        var pageto_module='{$PageTo_Module}';
        var pageto_action='{$PageTo_Action}';
        var pageto_record='{$PageTo_Record}';
        var cur_menuid='{$cur_menuid}';
        var pageto_menufile='{$PageTo_MenuFile}';
        var pageto_create="{$Pageto_create}"
        var page_addurl='{$page_addurl}';
        var trade_version='{$trade_version}';
        var account_version='{$account_version}';
        var global_hideleftmenu='{$global_hideleftmenu}'
        var from_login_type='{$from_login_type}';
        var view_type = '{$view_type}';
        // page_addurl=page_addurl.replace(/\\/g,"\\\\");
        var cosDirName='{$cosDirName}';
        //立即查找按钮标签
        var btn_findnow_label='{"FINDNOW"|@getFixedLabel}';
        var basicfind_label='{"BASICFIND"|@getFixedLabel}';
        var hiddenlabel="{'HIDDEN'|@getFixedLabel}";
        var showLabel="{'DISPLAY'|@getFixedLabel}";
        var CURRENT_USER_ID = '{$CURRENT_USER_ID}';
        var isCallErrorRemind = 'no';
        var watermark_txt='{$watermark_txt}';
    </script>
    {if $trade_version eq 'jijin'}
	<script language="javascript" type="text/javascript" src="include/js/trade/Jijin/Accured.js?v={$GLOBALMINVERSION}"></script><!--基金行业-->
    {/if}
    {if $HEADERCSS}
    	{foreach item=HDRCSS from=$HEADERCSS}
    	<link rel="stylesheet" type="text/css" href="{$CSSURL}{$HDRCSS->linkurl}" />
    	{/foreach}
    {/if}
    <style type="text/css">{literal}div.fixedLay1 {position:fixed;}{/literal}</style>
    {if $iskehu001 eq 'yes' || $useWxOpendata eq 'yes'}
    <script src="https://res.wx.qq.com/open/js/jweixin-1.2.0.js"></script>
    <script src="https://open.work.weixin.qq.com/wwopen/js/jwxwork-1.0.0.js"></script>
    <script type="text/javascript" language="javascript" src="{$JSURL}include/js/cls_wxOpenData.js?v={$GLOBALMINVERSION}"></script>
    {/if}
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/advancefilter.js?v={$GLOBALMINVERSION}"></script>

    {* @edit:dong @date:2020/08/19 @reason: 平铺查找*}
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/tiledsearch.js?v={$GLOBALMINVERSION}"></script>
    <!-- <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery-3.5.1.min.js"></script> -->
    <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.min.js"></script>
    <script type="text/javascript" src="{$JSURL}include/jquery/jquery-migrate.min.js"></script>
	<script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery-ui.min.js"></script>
    <script type="text/javascript" language="JavaScript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.nicescroll.js"></script>
    <script src="{$JSURL}include/js/ajax.js?v={$GLOBALMINVERSION}"></script>
    <script src="{$JSURL}include/js/base64.min.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/resizetable.js?v={$GLOBALMINVERSION}"></script>
    <script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.autosize.min.js"></script><!--文本区域自动增高-->
 	<script type="text/javascript" src="crmcommon/js/ueditor/ueditor.config.js?v={$GLOBALMINVERSION}"></script><!--编辑器-->
    <script type="text/javascript" src="crmcommon/js/ueditor/ueditor.all.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/ldcrm.edit.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/select2.min.js?v={$GLOBALMINVERSION}"></script><!--多选框-->
    <script type="text/javascript" src="{$JSURL}include/js/SystemPopup/ListHigherSearchPopup.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/MsgPopup.js?v={$GLOBALMINVERSION}"></script><!--弹出层提示-->
    <script type="text/javascript" src="{$JSURL}include/js/picklist.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/cls_fieldrule.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/cls_fieldSensitiverule.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/cls_AESencryptionbykey.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/modules/PickList/DependencyPicklist.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/producttool/PriceStrategy.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/cls_resetComboxHtml.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/producttool/toolField.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/producttool/fieldFormula.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/producttool/selectProduct.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/SystemPopup/cls_common_field_event.js?v={$GLOBALMINVERSION}"></script>
    {*editor:gyq_162 reason:海格产品分录导入   2019/12/5 11:33 *}
    <script type="text/javascript" src="{$JSURL}include/js/modules/XlsImportNew/XlsImportDocumentEntry.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/ScopePopup/ScopePopup.js?v={$GLOBALMINVERSION}"></script>
    <script type='text/javascript' src='{$JSURL}include/js/Mail.js?v={$GLOBALMINVERSION}'></script>
    <script type='text/javascript' src='{$JSURL}include/js/Sortable.min.js?v={$GLOBALMINVERSION}'></script>
    <script type='text/javascript' src='{$JSURL}include/js/cls_mainfieldformula.js?v={$GLOBALMINVERSION}'></script>
    <script type='text/javascript' src='{$JSURL}include/js/cls_detail2mainformula.js?v={$GLOBALMINVERSION}'></script>
    <script type='text/javascript' src='{$JSURL}include/js/cls_encryptyurl.js?v={$GLOBALMINVERSION}'></script>
    <script type='text/javascript' src='{$JSURL}include/js/SystemPopup/ProgressPopup.js?v={$GLOBALMINVERSION}'></script>
    <script type='text/javascript' src='{$JSURL}include/js/localStorage.js?v={$GLOBALMINVERSION}'></script>
    <script type='text/javascript' src='{$JSURL}include/js/crypto-js.min.js?v={$GLOBALMINVERSION}'></script>
    <script type='text/javascript' src='include/js/socket.io.min.js'></script>
	<script type="text/javascript" language="JavaScript">
        var typeofdata = new Array();
        typeofdata['E'] = ['c','e','n','s','ew','k','isnull','isnotnull'];
        typeofdata['V'] = ['c','e','n','s','ew','k','isnull','isnotnull'];
        typeofdata['N'] = ['e','n','l','g','m','h','isnull','isnotnull'];
        typeofdata['NN'] = ['e','n','l','g','m','h','isnull','isnotnull'];
        typeofdata['T'] = ['e','n','l','g','m','h','isnull','isnotnull'];
        typeofdata['I'] = ['e','n','l','g','m','h','isnull','isnotnull'];
        typeofdata['C'] = ['e','n','isnull','isnotnull'];
        typeofdata['DT'] = ['bw','e','n','l','g','m','h','isnull','isnotnull'];
        typeofdata['D'] = ['bw','e','n','l','g','m','h','isnull','isnotnull'];
        typeofdata['M'] = ['c','e','n','s','ew','k','isnull','isnotnull'];
        var fLabels = new Array();
        fLabels['bw'] = '{'Interval'|@getFixedLabel}';
        fLabels['c'] = '{'IN'|@getFixedLabel}';
        fLabels['e'] = '{'EQ'|@getFixedLabel}';
        fLabels['n'] = '{'NEQ'|@getFixedLabel}';
        fLabels['k'] = '{'NOT_IN'|@getFixedLabel}';
        fLabels['l'] = '{'LT'|@getFixedLabel}';
        fLabels['g'] = '{'GT'|@getFixedLabel}';
        fLabels['m'] = '{'LE'|@getFixedLabel}';;
        fLabels['h'] = '{'GE'|@getFixedLabel}';
        fLabels['b'] = '{'Before'|@getFixedLabel}';
        fLabels['a'] = '{'After'|@getFixedLabel}';
        fLabels['isnull'] = '{'ISNULL'|@getFixedLabel}';
        fLabels['isnotnull'] = '{'ISNOTNULL'|@getFixedLabel}';
        fLabels['curuser'] = '{'CURUSER'|@getFixedLabel}';
        fLabels['includeuser'] = '{'INCULDECURUSER'|@getFixedLabel}';
        //zkt 增加全局变量，用户字段
        var user_uityp_obj = JSON.stringify({$user_uitype_arr});
        var global_user_uitype_arr=JSON.parse(user_uityp_obj);
        var global_multiuser_uitype_arr=[154,132,603];
        var wx_timestamp='{$timestamp}';
        var wx_corpid='{$wx_corpid}';//'wxa246741d62d718f0';
        var wx_agentid='{$wx_agentid}';//'1000345';
        var wx_nonceStr='{$nonceStr}';
        var wx_agent_signature='{$agentsignature}';
        var wx_signature='{$signature}';
        var iskehu001='{$iskehu001}';

        //ls 20221216  XUQIU1000403   单据新建界面增加暂存功能
        var create_storage_timer = null;//新建页面定时器id
        var isOpenlocalStorage = '{$isOpenlocalStorage}';//是否开启浏览器缓存
        var localStorageTime = '{$localStorageTime}';//开启浏览器缓存间隔
        localStorageTime = parseInt(localStorageTime);
        var isAvailablelocalStorage = false;//浏览器缓存是否可用
        if (isOpenlocalStorage=='yes' && storageAvailable('localStorage') && localStorageTime>0) {
            isAvailablelocalStorage = true;
        }
        // zxm echarts主题变量   等下次主题色配好直接用这个变量
        var echartTheme = 'default';

		var ld = $;
        //33942: 合同订单新增和编辑界面附件左边？对应提示信息附件大小没有根据配置显示
        var global_uploadfile_maxsize_mb=parseInt('{$UPLOADFILEMAXSIZE}')/1000/1000;
        var fromcalendar='no';
        var imagecompress='{$IMAGECOMPRESS}';////设置网页端上传图片时是否压缩,0:压缩
        var language='{$LANUGAGETYPE}';
        var commonLabels={ldelim}'AddRows':"{'AddRows'|@getFixedLabel}",'DeleteRows':"{'DeleteRows'|@getFixedLabel}"
                ,'DragRows':"{'DragRows'|@getFixedLabel}",'CtrlEnterComBox':"{'CtrlEnterComBox'|@getFixedLabel}"
                ,'CopyRows':"{'CopyRows'|@getFixedLabel}"
                {rdelim};
        
        if(language=='zh'){ldelim}
            language='zh-cn';
        {rdelim}
        {literal}
        var languagecolon= {"zh-cn":"：","en":":"};
        {/literal}
	</script>
	{if $account_version eq 'saic'}
		<script language="javascript" type="text/javascript" src="crmcommon/js/My97DatePicker/WdatePicker.js?v={$GLOBALMINVERSION}"></script>
	{/if}
    <link type="text/css" href="{$CSSURL}themes/softed/coordination.css?v={$GLOBALMINVERSION}" rel="stylesheet" /><!--工作汇报-->
    <script type="text/javascript" language="javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/echarts.min.js?v={$GLOBALMINVERSION}"></script><!--报表-->
    <script language="JavaScript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/echartTheme/default.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/echartTheme/westeros.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/jquery.slimscroll.min.js"></script>

    {* 后台设置 *}
    {if $CURRENT_USER->user_type == 'prm'}
        <script type="text/javascript" src="{$JSURL}include/js/PrmMenu.js?v={$GLOBALMINVERSION}"></script>
    {else}
        {if $BACKENDSETTINGS && $BACKENDSETTINGS == 'yes'}
            <script type="text/javascript" src="{$JSURL}include/js/CrmMenu.js?v={$GLOBALMINVERSION}"></script>
            <script language="JavaScript" type="text/javascript" src="include/js/modules/Settings/Settings.js?v={$GLOBALMINVERSION}"></script>
        {else}
            <script type="text/javascript" src="{$JSURL}include/js/leftmenu.js?v={$GLOBALMINVERSION}"></script>
        {/if}
    {/if}
    <script type="text/javascript" src="{$JSURL}include/js/menucommon.js?v={$GLOBALMINVERSION}"></script>


    <script language="JavaScript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/My97DatePicker/WdatePicker.js?v={$GLOBALMINVERSION}"></script><!--时间选择器-->
	<script language="JavaScript" type="text/javascript" src="include/language/{$LANUGAGETYPE}.js?v={$GLOBALMINVERSION}"></script>
	<script language="JavaScript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/scriptaculous/prototype.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/FieldDependencies.js?v={$GLOBALMINVERSION}"></script><!--自动带出-->
	<script language="JavaScript" type='text/javascript' src='{$JSURL}include/js/modules/Reminds/Reminds.js?v={$GLOBALMINVERSION}'></script><!--提醒-->
	<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/general.js?v={$GLOBALMINVERSION}"></script><!--公共-->
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ldAjax.js?v={$GLOBALMINVERSION}"></script><!--公共-->
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CommonPagePopup.js?v={$GLOBALMINVERSION}"></script><!--拖拽效果-->
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupDrag.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CrmPopup.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/QcPopup.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/selectSearchPopup.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PageRecordPopup.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupLayer.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/MassEditPopup.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CreatePagePopup.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/ListEditPagePopup.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupUserGroup.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/SaveDataRecord.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/selectSearchField.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/SystemPopup/DetailViewPage.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/webuploader/webuploader.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/webuploader.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/validatasave.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/DateTime.js?v={$GLOBALMINVERSION}"></script>
    {*editor:gyq_169 reason:腾讯云COS文件上传预览   2020/2/20 15:00*}
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/WebUploadFile.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/EditView.js?v={$GLOBALMINVERSION}"></script><!--编辑-->
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/ComboxPopup.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/cls_picklist.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/viewer.min.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/CustomView/CustomView.js?v={$GLOBALMINVERSION}"></script>
	<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/cls_input_select.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/laydate.js?v={$GLOBALMINVERSION}"></script><!--日期控件2022-->
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/DataHtmlBind.js?v={$GLOBALMINVERSION}"></script><!--日期控件2022-->
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/DragTransfer.js?v={$GLOBALMINVERSION}"></script><!--穿梭框，排序框，显示隐藏调用2023-->
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SeniorAllocateShare.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/CustomViewGroupRightSetting.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/cls_advanceFilter.js?v={$GLOBALMINVERSION}"></script>
    <script>
        dynamicJsScript['FieldDependencies']=1;
        var currentuser_name='{$CURRENT_NAME}';
		var menustyle = '{$MENUSTYLE}';	//菜单类型
        var global_js_sync_id=[];
        var global_ispopup_page='no';//是否为弹出页签也买你
        dynamicJsScript['include/js/popupselectfield.js']=1;
        dynamicJsScript['include/js/fieldinfo.js']=1;
        dynamicJsScript['include/js/ldcrm.edit.js']=1;
        var tmp_deploy_arr='{"205"|getSys_deploy}';
        if (tmp_deploy_arr.deploy_value==1)
             var potentials_ShowProductDetail='no';
        else
             var potentials_ShowProductDetail='yes';
        var global_var={};
        var global_bodywidth='{$BodyWidth}';
        var cls_wxOpenDataobj;

        if(iskehu001 =='yes'){
            cls_wxOpenDataobj=new cls_wxOpenData();
            cls_wxOpenDataobj.init();
        }
        //hzx 20240726 crm和prm全局变量
        var crmorprmtype = '{$CURRENT_USER->user_type}';
    </script>
    <script language="javascript" type="text/javascript" src="{$JSURL}include/js/modules/Products/multifile.js?v={$GLOBALMINVERSION}"></script>
    <script language="javascript" type="text/javascript" src="{$JSURL}include/js/Inventory.js?v={$GLOBALMINVERSION}"></script>
    <script language="javascript" type="text/javascript" src="{$JSURL}include/js/popupselectfield.js?v={$GLOBALMINVERSION}"></script>
    <script language="javascript" type="text/javascript" src="{$JSURL}include/js/fieldinfo.js?v={$GLOBALMINVERSION}"></script>
	<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Accounts/publicAccounts.js?v={$GLOBALMINVERSION}"></script>
    {*代码编辑器插件 BUG20241226-09 系统录入SQL的地方，能否不要去掉SQL中的缩进格式：现在是把缩进的格式全部去掉了，导致可读性变差*}
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ace-src-min/ace.js?v={$GLOBALMINVERSION}"></script>

    {if $isOpenYiwei eq 'yes'}
        <script language="javascript" type="text/javascript" src="{$JSURL}include/js/yiwei.js?v={$GLOBALMINVERSION}"></script>
    {/if}
</head>
<body ondrop="event.preventDefault();event.stopPropagation();">

<script>
DocmentWriteJs("include/js/modules/XlsImportNew/XlsImportNew.js","XlsImportNew_js");
{*赛克：edit:chj,edit:2020-07-22,reason:登录成功后，显示呼叫中心工具条*}
if(account_version != undefined && account_version == 'saic'){
	ld('[name=iframe_callcenter]',parent.document).show();
	setInterval(call_createdmodule,3000);
}
function call_createdmodule(){
	ld.ajax({
		url: 'index.php?module=Accounts&action=AccountsAjax&file=saic_getCallData',
		type: 'POST',
		data:'',
		dataType:'json',
		async: true,//
		timeout: 5000,
		success: function(data)
		{
			if(data.code==1 && data.mobile != '')
			{
				var  popupobj = CrmPopup.getPopupObj("last");
				var  objparams = new CreatePagePopup.params();
				objparams.params['isduplicate'] = 'no';
				objparams.params['createdtype'] = 'create';
				 CreatePagePopup.showpage('Accounts', "&saic_mobile="+data.mobile+"&saic_ivrnode="+encodeURIComponent(data.ivrnode)+"&saic_agentid="+data.agentid+"&saic_userkeydown="+data.userkeydown+"&saic_linetype="+encodeURIComponent(data.linetype), objparams);
			}
		}
	})
}
</script>
<div class="fixedLay1" id="ActivityRemindercallback" style="border:0;right:7px;bottom:0px;display:none;padding:0px;z-index:1000;" align="left"></div>
<div class="fixedLay1 WarmRemindDiv" onmouseover="fnShowDrop('selectviewremind')" onmouseout="fnHideDrop('selectviewremind')"  id="selectviewremind">
    <table cellspacing="1" cellpadding="0" border="0">
        <tr><td><a onclick="return updateRemindtime('5');"  style="cursor:pointer;">5 {'MINUTE'|@getFixedLabel}</a></td></tr>
        <tr><td><a onclick="return updateRemindtime('10');" style="cursor:pointer;">10 {'MINUTE'|@getFixedLabel}</a></td></tr>
        <tr><td><a onclick="return updateRemindtime('15');" style="cursor:pointer;">15 {'MINUTE'|@getFixedLabel}</a></td></tr>
        <tr><td><a onclick="return updateRemindtime('1H');" style="cursor:pointer;">1  {'HOUR'|@getFixedLabel}</a></td></tr>
        <tr><td><a onclick="return updateRemindtime('2H');" style="cursor:pointer;">2  {'HOUR'|@getFixedLabel}</a></td></tr>
        <tr><td><a onclick="return updateRemindtime('4H');" style="cursor:pointer;">4  {'HOUR'|@getFixedLabel}</a></td></tr>
        <tr><td><a onclick="return updateRemindtime('8H');" style="cursor:pointer;">8  {'HOUR'|@getFixedLabel}</a></td></tr>
        <tr><td><a onclick="return updateRemindtime('1D');" style="cursor:pointer;">1  {'Days'|@getFixedLabel}</a></td></tr>
        <tr><td><a onclick="return updateRemindtime('2D');" style="cursor:pointer;">2  {'Days'|@getFixedLabel}</a></td></tr>
        <tr><td><a onclick="return updateRemindtime('3D');" style="cursor:pointer;">3  {'Days'|@getFixedLabel}</a></td></tr>
        <tr><td><a onclick="return updateRemindtime('5D');" style="cursor:pointer;">5  {'Days'|@getFixedLabel}</a></td></tr>
    </table>
</div>
<!-- 小编辑div 开始-->
<div id="listeditpagepopup" style="display:none;" class="first-listlittle-edit-pop">
    <!-- <div class="first-listlittle-edit-pop-header">
        <button class="ld-button ld-button-cancel" name="listeditpagepopupcancel" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"></button>
        <button class="ld-button ld-button-primary" name="listeditpagepopupsave" value="√" title="{'SAVE'|@getFixedLabel}"></button>
	</div> -->
    <div id="listeditpagetablecontent" name="listeditpagetablecontent" style="display:none;"></div>
    <div id="listeditpagepopupcontent" class="first-listlittle-edit-pop-content">
        <div class="first-listlittle-edit-pop-lable" name="listeidtpagecontentlabel"></div>
        <div class="first-listlittle-edit-pop-input ld-form-item-content" name="listeidtpagecontentinput"></div>
    </div>
    <div class="first-listlittle-edit-pop-footer">
    {* zkt 20220524 52110(https://81mis.com/kfbcrm/index.php)(序时簿小编辑)客户管理》客户》客户名称，点击小编辑按钮，需求上显示的是“取消”和“确认*}
        <input name="listeditpagepopupsave" class="E_pbtnok ld-button ld-button-primary" value="{'CONFIRMED'|@getFixedLabel}" type="button">

        <input name="listeditpagepopupcancel" class="E_pbtncancel ld-button ld-button-cancel" value="{'CANCEL'|@getFixedLabel}" type="button">
    </div>
</div>
{if $CURRENT_USER->user_type == 'prm'}
    {include file="prmcontainer.tpl"}
{else}
    {if $BACKENDSETTINGS && $BACKENDSETTINGS == 'yes'}
        {include file="SettingsLeftMenu.tpl"}
    {else}
        {include file="crmcontainer.tpl"}
    {/if}
{/if}

<div id="status" style="position:absolute;display:none;left:950px;top:85px;height:27px;white-space:nowrap;">
</div>
    <!-- Frank的消息强提醒测试 Start -->
    <div id="alert-popup" class="ld-alert-popup">
        <div class="ld-alert-popup-head">
            <div class="ld-alert-popup-title">消息提醒</div>
            <div id="progress-ring" class="ld-progress-ring" style="display: none;">
                <svg class="ld-progress-ring__svg" width="40" height="40">
                    <circle class="ld-progress-ring__circle" stroke="blue" stroke-width="4" fill="transparent" r="18" cx="20" cy="20"/>
                </svg>
            </div>
            <div class="ld-alert-close-btn" id="close-btn" onmousedown="down()" onmouseup="up()" onclick="cli()" onmouseleave="up()" onmouseenter="tooltip.bind(this)" data-tip="长按关闭可以清空消息队列" data-direction="left" data-type="position">&times;</div>
        </div>
        <div class="ld-alert-content">
            <p class="ld-alert-content-item"><strong>发送人:</strong> <span id="sender"></span></p>
            <p class="ld-alert-content-item"><strong>消息内容:</strong> <span id="message-content"></span></p>
            <p class="ld-alert-content-item" style="display: none;" id="link-html"><strong id="link-label"></strong><span id="link-content"></span></p>
        </div>
    </div>
    <script type="text/javascript">
        const alertQueue = JSON.parse(localStorage.getItem('alertQueue')) || [];
        let isAlertVisible = false;
        let titleInterval;
        let originalTitle;
        let holdTimeout;
        let progressInterval;
        const holdDuration = 2000; // 2 seconds
        let key = 'ld_message';
        // document.addEventListener("DOMContentLoaded", function () {
        //     return ;
        //     var serverIp = window.location.hostname; // 获取当前访问的服务器 IP 地址
        //     var pathname = window.location.pathname;
        //     var protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'; // 根据页面协议选择 WebSocket 协议
        //     var socket = io(protocol + "//" + serverIp + ":5000", {
        //         transports: ['websocket'],
        //         secure: true,
        //         reconnectionAttempts: 1,
        //         timeout: 20000
        //     });
        //
        //     socket.on('connect', function() {
        //         console.log('Connected to server');
        //         socket.emit('join', { user_id: ld_js_secret(CURRENT_USER_ID, key), account: ld_js_secret(pathname, key) });
        //         processQueue();
        //     });
        //
        //     socket.on('message', function(data) {
        //         // 添加消息到队列
        //         let flag = true;
        //
        //         let decrypted_message = data.data.map(value=>ld_js_secret(value, key, flag));
        //         if(CURRENT_USER_ID == decrypted_message[0]){
        //             addAlertToQueue(decrypted_message[2], decrypted_message[1], decrypted_message[7], decrypted_message[8], decrypted_message[9]);
        //             processQueue();
        //             startTitleBlink("您有新消息!");
        //         }
        //     });
        //
        //     socket.on('error', function(data) {
        //         console.error('Error from server:', data.data);
        //         alert('Error: ' + data.data); // 显示错误信息给用户
        //     });
        //
        //     socket.on('disconnect', function() {
        //         console.log('Disconnected from server');
        //         socket.emit('leave', { user_id: ld_js_secret(CURRENT_USER_ID, key), account: ld_js_secret(pathname, key) });
        //     });
        //
        //     // document.getElementById('close-btn').addEventListener('click', function() {
        //     //     closeAlert();
        //     // });
        //
        //     window.addEventListener('beforeunload', function () {
        //         localStorage.setItem('alertQueue', JSON.stringify(alertQueue));
        //     });
        //
        //     processQueue(); // 页面加载时处理队列中的消息
        // });
        function addAlertToQueue(sender, message, label, link, flag) {
            alertQueue.push({ sender, message, label, link, flag });
            localStorage.setItem('alertQueue', JSON.stringify(alertQueue));
        }

        function processQueue() {
            if (!isAlertVisible && alertQueue.length > 0) {
                const alert = alertQueue.shift();
                localStorage.setItem('alertQueue', JSON.stringify(alertQueue));
                showAlert(alert.sender, alert.message, alert.label, alert.link, alert.flag);
            }
        }

        function showAlert(sender, message, label, link, flag) {
            isAlertVisible = true;
            const alertPopup = document.getElementById('alert-popup');
            document.getElementById('sender').textContent = sender;
            document.getElementById('message-content').innerHTML = message;
            if(flag==1){
                var new_mes = document.getElementById('link-html');
                new_mes.style.display = 'block';
                document.getElementById('link-label').textContent = label+": ";
                document.getElementById('link-content').innerHTML = link;
            }
            if(alertPopup.classList.contains('slide-out'))
                alertPopup.classList.remove('slide-out');

            alertPopup.classList.add('visible');
        }

        function closeAlert() {
            const alertPopup = document.getElementById('alert-popup');
            var new_mes = document.getElementById('link-html');
            new_mes.style.display = 'none';
            alertPopup.classList.remove('visible');
            alertPopup.classList.add('slide-out');
            setTimeout(() => {
                isAlertVisible = false;
                processQueue();
            }, 500); // 动画持续时间应与CSS中的transition一致
        }

        function startTitleBlink(message) {
            if (!document.hasFocus()) {
                originalTitle = document.querySelectorAll(" .detail_path li")[0].textContent;
                if(!empty(originalTitle)){
                    titleInterval = setInterval(() => {
                        document.title = document.title === originalTitle ? message : originalTitle;
                    }, 1000);
                }

            }
        }

        function stopTitleBlink() {
            if(!titleInterval){
                originalTitle = document.querySelectorAll(" .detail_path li")[0].textContent;
            }
            clearInterval(titleInterval);
            if(!empty(originalTitle)){
                document.title = originalTitle;
            }
        }

        window.onfocus = stopTitleBlink;
        // function showNotification(title, message) {
        //     if (Notification.permission === "granted") {
        //         new Notification(title, { body: message });
        //     } else if (Notification.permission !== "denied") {
        //         Notification.requestPermission().then(permission => {
        //             if (permission === "granted") {
        //                 new Notification(title, { body: message });
        //             }
        //         });
        //     }
        // }

        const closeBtn = document.getElementById('close-btn');
        let lock=true;
        function down(){
            holdTimeout = setTimeout(() => {
                lock=false;
                clearQueue();
            }, holdDuration);
            startProgressRing();
            closeBtn.style.cursor = 'pointer'; // 确保鼠标指针样式
        }
        function up(){
            clearTimeout(holdTimeout);
            stopProgressRing();
            setTimeout(()=>{
               lock=true;
           })
        }
        function cli(){
            if(lock){
                closeAlert();
            }
        }




        function clearQueue() {
            // 清空消息队列
            alertQueue.length = 0;
            localStorage.setItem('alertQueue', JSON.stringify(alertQueue));
            closeAlert();
            stopProgressRing();
        }

        function startProgressRing() {
            const progressRing = document.getElementById('progress-ring');
            const closeBtnRect = closeBtn.getBoundingClientRect();
            progressRing.style.display = 'block';

            const circle = document.querySelector('.ld-progress-ring__circle');
            const radius = circle.r.baseVal.value;
            const circumference = 2 * Math.PI * radius;
            circle.style.strokeDasharray = circumference + ' ' + circumference;
            circle.style.strokeDashoffset = circumference;

            let progress = 0;
            progressInterval = setInterval(() => {
                progress += 113 / (holdDuration / 100);
                if (progress >= 100) {
                    clearInterval(progressInterval);
                }
                const offset = circumference - (progress / 100) * circumference;
                circle.style.strokeDashoffset = offset;
            }, 100);
        }

        function stopProgressRing() {
            clearInterval(progressInterval);
            const progressRing = document.getElementById('progress-ring');
            progressRing.style.display = 'none';
        }
    </script>

<!-- Frank的消息强提醒测试 End -->
<!--整体内容加载动画-->
<div id="rptContentLoading" class="el-loading-mask ld-loading-mask">
    <div class="el-loading-spinner">
        <svg viewBox="25 25 50 50" class="circular"><circle cx="50" cy="50" r="20" fill="none" class="path"></circle></svg>
    </div>
</div>
<div id="ShowSetUeryScopdiv" class="D_pop_box" style="display:none;position:absolute;left:33%;top:35%;" ></div>
<script>
var searchstring=getSearchString("global_hideleftmenu",window.location.href);
var search_stock_view = '{$search_stock_view}';
{literal}
    if(searchstring=='yes'||global_hideleftmenu=='yes')
    {
        ld("#pageleft_unfold").css("display",'none');
        pageleft_unfold=0;
        pageleft_fold=0;
        main_left_width=0;
    }
    var hantianlogin = ld('#hantianlogin').val();
    var iframeswitch = ld('#JWtitle',window.parent.document).val();

    if(hantianlogin == 'yes'){
        window.parent.document.getElementById('toolbar').contentWindow.HantianTools.getInstance().loginfromcrm();
    }
	function keyupUnifiedSearchClick(event){
		var e = event || window.event;
		if(e.keyCode == 13){// Enter 回车键
			UnifiedSearchClick(this);
		}
	}
    function loginout(){
        if(iframeswitch == 4){
            window.parent.document.getElementById('toolbar').contentWindow.HantianTools.getInstance().loginoutfromcrm();
        }
		//赛克：edit:chj,edit:2020-07-22,reason:登录成功后，显示呼叫中心工具条
		if(account_version != undefined && account_version == 'saic'){
			ld('[name=iframe_callcenter]',parent.document).hide();
		}
        EmptyProgressObjs();

        if(account_version != undefined && account_version == 'baxter'){
            var baxter_login_type = localStorage.getItem('baxter_login_type');
            if (baxter_login_type == 'okta') {
                var logout_url = '';
                ldAjaxNoProgress("baxter/index.php?operatetype=crmlogout",{},function(data) {
                    //因为不想动CrmExit公共文件，注销接口需要session里的id token，而CrmExit会将session销毁，故需要先拿到注销okta的接口地址，等crm退出之后，再注销okta
                    logout_url = data.result.url;

                    ld.ajax({
                        url:"index.php?module=Users&action=UsersAjax&file=CrmExit",
                        type:"post",
                        dataType:"json",
                        success:function(data){
                            if (logout_url.length>0) {
                                window.location.href = logout_url;//通过注销接口重定向地址跳转Web登录页
                            }
                        }
                    })

                });
                return;
            }

        }

        ld.ajax({
            url:"index.php?module=Users&action=UsersAjax&file=CrmExit",
            type:"post",
            dataType:"json",
            success:function(data){
                var href_url = '';
                if(data.result.LOGIN_SECURITY_CODE==0){
                    href_url = "index.php?action=Login&module=Users&login_method=true";
                }
                else if(data.result.login_method==1){
                    href_url = "index.php?action=Login&module=Users&login_method=true";
                }
                else{
                    href_url = "index.php?action=LoginCheck&module=Users";
                }
                if(data.result.languageType == 'en'){//xxy 2023-12-12 BUG0077075 英文版，点击退出，登录界面默认显示中文版，应该也是英文版才对
                    href_url += "&languageType=en"
                }
                window.location.href = href_url;
            }
        })



    }
    //editor:gyq_83 reason:微信小程序账号绑定及扫码 2018/10/15 15:49
    function wechat_applet(){
        getJsScript('include/js/modules/Settings/wechat_miniprogram/wechat_miniprogram.js',function() {
            show_wechat_applet();
        });
    }

	function searchSubmit(event,searchtype){
        var prevpopupobj=CrmPopup.getPopupObj('lastprev');
        var e = event || window.event;


		if( e.keyCode == 13){// Enter 回车键
            // @edit:dong @date:2020/08/19 @reason: 平铺查找 prevpopupobj 为undefined
            if(searchtype =='Tiled'){
                callSearch('Tiled');
                return false;
            }
            if(searchtype == 'quickSearch'){
				//快速查询
				UnifiedSearchClick();
                return false;
			}
            // edit: xll 2024/11/22 XUQIU1001599 单据序时簿列表界面，高级查找增加“平铺”和“清除筛选值”功能
            if(searchtype === 'AdvanceTiled') {
                callSearch('AdvanceTiled');
                return false;
            }
            if(prevpopupobj.type==ListPagePopup.type){
    			if(searchtype == 'Basic'){
    				callSearch('Basic');//基本
    			}
                else{
    				callSearch('Advanced');
    			}
                return false;
			}
            else if(prevpopupobj.type==RelateListPage.type){
                //相关信息查询
                DetailViewRelation.callSearch();
            }
		}

	}

	//消息提醒
	function getRemindpages(obj,event){
		var tag = ld(obj).attr('tag');
		var remindsid = ld(obj).attr('remindsid');
		var pagenum = ld(obj).attr('page');
		var surl = "index.php?module=Reminds&action=RemindsAjax&file=SetRemindReaden&getRemindsContent=yes&page_tag="+tag+"&remindsid="+remindsid+"&pagenum="+pagenum;
        surl= cls_encryptyurl.Puyoung_Encryptyurlhavephp(surl,'');
        ld.ajax({
            url: surl,
            type: 'POST',
            data:'',
            dataType:'json',
            async: true,
            timeout: 5000,
            success:function(data){
                if(data.code == 1){
                    ld('#noticeHeader .noticeHeaderContent').html(data.result.content);
                }
            }
        })
	}
    //消息已读
    //BUG0054421 wyt 220802 首页-右上角-消息，点击已读，有时需要点两次才会已读一条消息（多次点击才会复现）
    function setRemindReadenHeader(remindsid, pagenum){
        var surl = "index.php?module=Reminds&ReportHeader=DHeader&action=RemindsAjax&getRemindsContent=yes&types=update_state&file=SetRemindReaden&remindsid="+remindsid;
        ldAjaxNoProgress(surl,{},function(data){
            //BUG0055015 wyt 首页，右上角消息，先切换到下一条单据，再点击已读无效（成功了，但是页面没有刷新）
            getJsScript('include/js/ListViewButton.js', function () {
                //edit:xll 2023/05/04 BUG0065801 kfbcrm-右上角消息，点击推迟后消息回到第一页，应留在当页
                var current_page = ld("#remind_page_next").attr('page');
                var is_last = (current_page < pagenum) ? 0 : 1;
                current_page = (current_page < pagenum) ? current_page : current_page - 1;
                setRemindReadenHeaderSecond(remindsid, pagenum, current_page, is_last);
                //setRemindReadenHeaderSecond(remindsid, pagenum);
                setRemindReaden(remindsid,'',current_page, is_last);
            });
                getRemindsCount();
        })
    }
    // 更新该提醒的“提醒时间”
    function updateRemindtimeHeader(remindtime, remindsid, pagenum){
        var surl = "index.php?module=Reminds&ReportHeader=DHeader&action=SetRemindReaden&remindtime="+remindtime+"&remindsid="+remindsid;
        //edit:xll 2023/05/04 BUG0065801 kfbcrm-右上角消息，点击推迟后消息回到第一页，应留在当页
        var current_page = ld("#remind_page_next").attr('page');
        var is_last = (current_page < pagenum) ? 0 : 1;
        current_page = (current_page < pagenum) ? current_page : current_page - 1;
        surl += "&current_page="+current_page + "&is_last="+is_last;
        surl= cls_encryptyurl.Puyoung_Encryptyurlhavephp(surl,'');
        ld.ajax({
            url: surl,
            type: 'POST',
            data:'',
            dataType:'json',
            async: true,
            timeout: 5000,
            success:function(data){

            }
        });
        setRemindReadenHeaderSecond(remindsid, pagenum, current_page, is_last);
        //wyt 220921 BUG0056582 首页-消息，消息选择推迟的时候，数量不同步
        getRemindsCount();
    }

    /**
     * ajax 取回值之后，把值放入全局变量中，二次打开时覆盖原来的div层
     * @reason 0009812 搜索弹出层第二次打开保留了上一次操作的结果
     * @author Tujt 2014-07-16
     */
    var UnifidSearch_module_rest = '';
    var isgetmodule = 1;
    function UnifiedSearch_SelectModuleForm(obj) {
        // ld('#rptContentLoading').show();
        var Popupobj=CrmPopup.load("","","","LdPopWidth600px","undefinedSearch","","","","");
        Popupobj.prevshow();
        var url ="index.php?module=Users&action=UsersAjax&file=UnifiedSearchModules&ajax=true"
        ldAjax(url,{"namename": "uname", "namenameage": 18},function (data) {
            if(data.code==1){
                Popupobj.createHeadHtml=function(){
                    Popupobj.popupheadhtml='<div class="E_pop_tit" id="'+Popupobj.divid+'_head" style="cursor:move">';
                    Popupobj.popupheadhtml+='<strong class="E_ptita">'+Popupobj.headtitle+'</strong>';

                    Popupobj.popupheadhtml+='<button class="ld-fonticon ld-fonticon-close" value="关闭" id="'+Popupobj.divid+'_imgclose" style="cursor:pointer" ></button>';

                    // Popupobj.popupheadhtml+=' <strong class="E_ptita" style="float:right;padding:0 30px;cursor:pointer;" >';
                    // Popupobj.popupheadhtml+=' <a href="javascript:;" onclick="UnifiedSearch_SelectModuleToggle(true);" style="cursor:pointer">'+data.result.allselect+'</a>';
                    //
                    // Popupobj.popupheadhtml+='  &nbsp; <a href="javascript:;" onclick="UnifiedSearch_SelectModuleToggle(false);" style="cursor:pointer">'+data.result.selectcancel+'</a>';

                    Popupobj.popupheadhtml+=' </div>';
                }
                Popupobj.setParams(data.result.title,UnifiedSearch_SelectModuleSave,"","LdPopWidth600px","undefiendsearch","",data.result.oktext,"",data.result.canceltext);
                Popupobj.show(data.result.content);
                ld('#'+Popupobj.divid+' #query_string').unbind('focus').bind('focus',function (){
                    ld(this).parent().addClass('bgwhite').addClass('ld-border-color-3b7cff');
                    ld(this).parent().find('#query_string').addClass('bgwhite');
                });
                ld('#'+Popupobj.divid+' #query_string').unbind('blur').bind('blur',function (){
                    ld(this).parent().removeClass('bgwhite').removeClass('ld-border-color-3b7cff');;
                    ld(this).parent().find('#query_string').removeClass('bgwhite');
                });
                ld('#'+Popupobj.divid+' #query_string').bind("input propertychange", function() {
                    var query_string = ld(this).val();
                    if(query_string != ''){
                        ld(this).parent().find('span.search-clear-btn').addClass('show');
                    }
                    else{
                        ld(this).parent().find('span.search-clear-btn').removeClass('show');
                    }
                });
                ld('#'+Popupobj.divid+' .page-topsec-inputbox .search-clear-btn').click(function(){
                    ld(this).parent().find('#query_string').val('');
                    ld(this).parent().find('#query_string').focus();
                    ld(this).parent().find('span.search-clear-btn').removeClass('show');
                });

                if(unifiedSearch_modules!=""){
                    var selectmodules=unifiedSearch_modules.split(",");
                    var UnifiedSearch_form = document.forms.UnifiedSearch;
                    var serarchchek='';
                    var formobj = document.UnifiedSearch_moduleform;
                    var inputs = formobj.getElementsByTagName('input');
                    var inputlen = inputs.length;
                    if(inputlen > 0){
                        for(var i=0; i<inputlen; i++){
                            if(ld.inArray(inputs[i].value,selectmodules)>=0){
                                inputs[i].checked =true;
                            }
                            else{
                                inputs[i].checked =false;
                            }
                        }
                    }
                }
            }
        });
    }
    function CloseSearchModule(){
        isgetmodule = 1;
        fninvshnew('UnifiedSearch_moduleformwrapper');
    }
    function UnifiedSearch_SelectModuleFormCallback(obj) {
        fnvshobj(obj, 'UnifiedSearch_moduleformwrapper');
    }
    /**
     * $ 符号在常用报表模块，是Jquery框架对象，在其他地方则是prototype框架对象
     * 所以用js重写全选、全清方法，防止因为JS框架问题报错
     * @reason 0012946: 常用报表界面：快速查找-选择模块弹出层，点击“全选”“全清”按钮没有反应
     * @author Tujt 2014-12-12
     */
    function UnifiedSearch_SelectModuleToggle(flag) {
        var formobj = document.UnifiedSearch_moduleform;
        if(formobj.length > 0){
            var inputs = formobj.getElementsByTagName('input');
            var inputlen = inputs.length;
            if(inputlen > 0){
                for(var i=0; i<inputlen; i++){
                    if(inputs[i].type == 'checkbox'){
                        inputs[i].checked = flag;
                    }
                }
            }
        }
    }
    function UnifiedSearch_SelectModuleToggle_Allcheck(obj) {
        UnifiedSearch_SelectModuleToggle(ld(obj).prop('checked'));
    }
    function UnifiedSearch_SelectModuleToggle_Inputcheck(){
        var formobj = document.UnifiedSearch_moduleform;
        var tmp_input_len = ld(formobj).find('input[type=checkbox]').length;
        var tmp_input_lenche = ld(formobj).find('input[type=checkbox]:checked').length;
        if(tmp_input_len == tmp_input_lenche){
            ld('#search_onlyin_all').prop('checked',true);
        }else{
            ld('#search_onlyin_all').prop('checked',false);
        }
    }
    /*
    andrew
    报表页面快速查找无法保存
    */
    function UnifiedSearch_SelectModuleCancel() {
        var vhide=document.getElementById('UnifiedSearch_moduleformwrapper').style;
        if (vhide.display=="block"){
            vhide.display="none"
        }
        puyoungJS_DialogBox.unblock();
    }
    var unifiedSearch_modules="";
    function UnifiedSearch_SelectModuleSave() {
        var UnifiedSearch_form = document.forms.UnifiedSearch;
        var serarchchek='';
        var formobj = document.UnifiedSearch_moduleform;
        if(formobj.length > 0){
            var inputs = formobj.getElementsByTagName('input');
            var inputlen = inputs.length;
            if(inputlen > 0){
                for(var i=0; i<inputlen; i++){
                    if(inputs[i].type == 'checkbox'&&inputs[i].checked==true){
                        serarchchek+=inputs[i].value+',';
                    }
                }
            }
        }
        UnifiedSearch_form.search_onlyin.value=serarchchek.substring(0,serarchchek.length-1);
        unifiedSearch_modules=UnifiedSearch_form.search_onlyin.value;
        var curmodule=ld("#UnifiedSearch [name=module]").val();
        var url="index.php?module=Users&action=UsersAjax&file=UnifiedSearch&quick_query_session=save&search_onlyin="+unifiedSearch_modules;
        isgetmodule = 2;
        ldAjax(url,{},function(data){
            if(data.code==1){
                CrmPopup.getPopupObj("last").CancelEvent();
				DelProgressObjs();
            }
        })
    }
    UnifiedSearch_SelectModuleSave.funname="UnifiedSearch_SelectModuleSave";
    var isunifiedsearchsubmit=1;
    function UnifiedSearchClick(obj){
  		if(ld('#query_string').length>0){
      		if(ld('#query_string').val() == ''){
                var confirm_str = arrJsPopLabel['PLEASEENTERKEYWORDTOSEARCH'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
    			return false;
      		}
       	}
       	if(isunifiedsearchsubmit == 1){
      		isunifiedsearchsubmit = 2;
            puyoungJS_DialogBox.block();
       	}else{
      		return false;
       	}
        ld(" .detail_path li").html(arrJsPopLabel['QUICKFIND']);
        ld("title").text(arrJsPopLabel['QUICKFIND']);
        //edit:can 2020-12-29 43979: (61mis.com/kfbcrm)首页-快速查找；先在客户模块，进行基本查找；然后点击页面上方的快速查找，输入关键字查找时，查找过程灰色界面中没有显示转圈
        EmptyProgressObjs();
        ldAjax("index.php?module=Users&action=UsersAjax&file=UnifiedSearch&query_string="+encodeURIComponent(ld('#query_string').val()),{},function(data){
            var searchonlyin = data.result.search_onlyin;
            setUnifiedSearchModuleInfo(searchonlyin);
            isunifiedsearchsubmit=1;
            puyoungJS_DialogBox.unblock();
            puyoungJS_DialogBox.unblock();
            CrmPopup.global_listPopupObj=[];
            var obj=new Object();
            obj.divid=ld(listcontentobj).attr("id");
            obj.type='quicksearch';
            obj.CancelEvent=function(){
                CrmPopup.global_listPopupObj.pop();
            }
            obj.allfields=data.result.allfields;
            listcontentobj.html(data.result.content);
            if(data.result.rows != 0){
                ld(" .quicksearch_dv").css("width",CrmPopup.getClientWidth()-getLeftMenuWidth()-17);
            }
            ld(" .quicksearch_dv").css("max-height",CrmPopup.getClientHeight()-topheight-10);
            ld(" .quicksearch_dv").css("overflow","auto");
            document.getElementById("global_search_total_count").innerHTML = data.result.rows_description+"<strong style='color:#555;' id=\"search_total_count\">"+ data.result.rows+"</strong>";
            document.getElementById("hidden_total_count").value= data.result.rows;


            obj.pop_type = 'UnifiedSearch';
            var moduledata = data.result.moduledata;
            obj.moduledata = moduledata;
            obj.modulelistresizeobj = {};
            ld.each(moduledata,function (index,module) {
                var tmpobj = obj;
                tmpobj.module = module;
                var listresizeobj=new List_ResizeTable(tmpobj);
                obj.modulelistresizeobj[module] = listresizeobj;
                listresizeobj.setReiszeTable_Init(module, '');
            });
            CrmPopup.global_listPopupObj.push(obj);
            setUnifiedSearchListViewHeight('');
            /*ld(window).resize(function () {
                ld(" .quicksearch_dv").css("max-height",CrmPopup.getClientHeight()-topheight-10);
                setUnifiedSearchListViewHeight('');
            });*/

            //wym 全局搜索双击显示详情浮窗
            if (typeof listdoubleclickobj == "undefined" || listdoubleclickobj == undefined) {
                getJsScript('include/js/ListDoubleClick.js', function () {
                    var listdoubleclickobj = new ListDoubleClick(obj);
                    listdoubleclickobj.setDoubleClickEvent();
                })
            }else {
                listdoubleclickobj.resetPopupobj(obj);
            }

            if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined"){
                //通讯录(pc端企业微信)
                cls_wxOpenDataobj.bindAllOpenData();
            }

            //edit: xll 2023/03/21 BUG0062578全局查找下拉框
            var selectobj=ld("#pagecontent1 .global_search_total").find("#global_search_module");
            if(selectobj.length>0&&selectobj!=undefined){
                var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectobj.attr("name"));
                cls_resetComboxHtmlobj.setPopupObj(obj);
                cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj,210);
                ld(' .chzn-container').css({'top':'7px','float':'none'});
            }
            tooltip('.tip-items-list', {transition: true, time: 200});

            DelProgressObjs();
        });
    }

    //设置全局查找列表宽度
    function setUnifiedSearchListViewHeight(module){
        var popupobj = CrmPopup.getPopupObj('last');
        var divobj = ld('#'+popupobj.divid);
        var moduledata = popupobj.moduledata;
        var window_height = CrmPopup.getClientHeight();
        var topheight = ld('#pagehead').get(0).offsetHeight;
        var global_search_total_height= divobj.find('#global_search_total').get(0).offsetHeight;
        var height = window_height - topheight - global_search_total_height - 10 - 10;
        var firstmodule = moduledata[0];
        var list_header_height = 0
        if(divobj.find('#list_header_'+firstmodule).length > 0){
            list_header_height = divobj.find('#list_header_'+firstmodule).get(0).offsetHeight;
        }
        var resize_header_height = 0;
        if(divobj.find('#resize_header_table_divid_'+firstmodule).length > 0){
            resize_header_height = divobj.find('#resize_header_table_divid_'+firstmodule).get(0).offsetHeight;
        }
        height = height - resize_header_height - list_header_height;
        if(module == ''){
            ld.each(moduledata,function (index,module) {
                divobj.find('#'+ListView_Page.content_table_divid+"_"+module).css('max-height',height);
            });
        }else {
            divobj.find('#'+ListView_Page.content_table_divid+"_"+module).css('max-height',height);
        }
    }

    //设置全局查找列表切换下拉框change事件
    function displayModuleList(obj){
        var selected_value = ld(obj).val();
        var popupobj = CrmPopup.getPopupObj('last');
        var moduledata = popupobj.moduledata;
        var divobj = ld('#'+popupobj.divid);
        var count = 0;
        if(selected_value == 'All'){
            ld.each(moduledata,function (index,module) {
                var listview_divid = 'global_list_'+module;
                divobj.find('#'+listview_divid).css('display','');
                var recordcunt = divobj.find('[name='+module+'RecordCount]').val();
                count += parseInt(recordcunt);
            });
        }else {
            ld.each(moduledata,function (index,module) {
                var listview_divid = 'global_list_'+module;
                if (module != selected_value){
                    divobj.find('#'+listview_divid).css('display','none');
                }else {
                    divobj.find('#'+listview_divid).css('display','');
                    var recordcunt = divobj.find('[name='+module+'RecordCount]').val();
                    count += parseInt(recordcunt);
                }
            });
        }
        divobj.find('#search_total_count').html(count);
        //宽度调整
        var bodywidth = CrmPopup.getClientWidth();
        bodywidth = bodywidth - parseInt(getLeftMenuWidth());
        var scrollwidth = ld('#'+popupobj.divid).find('#UnifiedSearch').outerWidth(true);
        var clientwidth = ld('#'+popupobj.divid).find('#global_search_total').outerWidth(true);
        var min_scroll_width = 17 + 20;
        if (scrollwidth > clientwidth){
            min_scroll_width = min_scroll_width + (scrollwidth - clientwidth);
        }
        var table_width = bodywidth - min_scroll_width;
        if (selected_value == 'All'){
            ld.each(moduledata,function (index,module) {
                divobj.find('#'+ListView_Page.fullwidth_divid+'_'+module).css('width',table_width);
                divobj.find('#'+ListView_Page.header_table_divid+'_'+module).css('width',table_width);
                divobj.find('#'+ListView_Page.content_table_divid+'_'+module).css('width',table_width);
                divobj.find('#'+ListView_Page.header_tableid+'_'+module).css('width',table_width);
                divobj.find('#'+ListView_Page.content_tableid+'_'+module).css('width',table_width);
            });
        }else {
            divobj.find('#'+ListView_Page.fullwidth_divid+'_'+selected_value).css('width',table_width);
            divobj.find('#'+ListView_Page.header_table_divid+'_'+selected_value).css('width',table_width);
            divobj.find('#'+ListView_Page.content_table_divid+'_'+selected_value).css('width',table_width);
            divobj.find('#'+ListView_Page.header_tableid+'_'+selected_value).css('width',table_width);
            divobj.find('#'+ListView_Page.content_tableid+'_'+selected_value).css('width',table_width);
        }
    }
    /**
     * 搜索后，默认执行此方法，保留提交前保存的模块选择
     * @reason 0011669 快速查找：搜索后无法记住上次选择的模块
     * @author Tujt 2014-09-28
     */
    function setUnifiedSearchModuleInfo(search_onlyin){
        var UnifiedSearch_form = document.forms.UnifiedSearch;
        UnifiedSearch_form.search_onlyin.value = search_onlyin;
    }
    //审批
    function ApproveCenterClick(tabtype,event){
        event=event||window.event;
        if(event.preventDefault){
            event.preventDefault();
        }
        else{
            window.event.returnValue == false;
        }
        ld('#rptContentLoading').show();
        var approve_title = arrJsPopLabel['MYAPPROVALCENTER'];
        ld.ajax({
            url:"index.php?module=Approve&action=ApproveAjax&file=ApproveListViewCount&tabtype="+tabtype,
            type:"post",
            success:function(data){
                ld('#rptContentLoading').hide();

                //edit: xll 2023/03/31 BUG0063716 审批中心页面标签，点击“已处理”，页面标签变成“审批”
                ld(" .detail_path li").html(approve_title);

                var stateObject = {};
                var newUrl='index.php?pageto_module=Approve&pageto_action=ApproveListViewCount';
                //var newUrl = "index.php";//修改从项目名后开始
                history.pushState(stateObject,"",newUrl);
                ld("#pagecontent .wrapper-panel-inner").html(data);
            }
        });
    }
    function ApproveCenterClickDrawer(tabtype,event){
        if (tabtype == 'flag'){
            tabtype = ld('[name="approve_href"]').first().attr('data-tabtype');
        }
        if (empty(tabtype)){
            tabtype = 0;
        }
        //抽屉设置事件
        initDrawer();
        initDrawerApprovepage(tabtype);
        initDrawerApprovepageClick(tabtype);
    }
	//审批列表处理、查看明细
	function ApproveHrefListView(module,tabtype,flag){
	    //edit:xll 2023/05/15 BUG0066065 审批中心->待处理/已处理/我提交的，查看明细列表界面，左上角的“审批”标签修改为“审批中心”
		var approve_title = arrJsPopLabel['MYAPPROVALCENTER'];
		ld('#rptContentLoading').show();
        CrmPopup.global_listPopupObj=[];
        //zkt 20231013 XUQIU1001341 SQL注入
        ldAjaxHtmlNoProgress("index.php?module=Approve&action=ApproveAjax&file=HrefListView&approvestatus="+tabtype+'&fromapprovemodule='+module,'',function(data){
            ld('#rptContentLoading').hide();
            ld(".first-modal").remove();//删除抽屉遮罩层
            ld(".first-drawer-wrapper").remove();//关闭抽屉
            ld(document).unbind();
            var page_addurl=encodeURIComponent("&approvestatus="+tabtype+'&fromapprovemodule='+module);
            ChangeWebUrl("index.php?pageto_module=Approve&pageto_action=HrefListView&page_addurl="+page_addurl);
            if (flag === true){
                // ApproveCenterClickDrawer(tabtype);//230417 wyt BUG0064899 审批中心，点击模块后，进入模块列表界面，再点击“待审批”页签时，进入待处理界面时应该同时打开右侧的待审批弹窗
            }
            ld(".first-modal").remove();//删除抽屉遮罩层
            ld(" .detail_path li").html(approve_title);
            ld("title").text(approve_title);
            ld("#pagecontent .wrapper-panel-inner").html(data);
            var popupobj=CrmPopup.getPopupObj('last');
            popupobj.module=module;
        });
	}
    //消息
    function NewsClick(jqueryobj,event){

        var clsreminds_obj = new cls_Reminds();
        clsreminds_obj.initFirstPopup();

		/* var news_title = ld(".function-btn [name=news_href]").attr('title');
        ldAjaxHtml("index.php?module=Reminds&action=RemindsAjax&file=index",{},function(ajaxdata){
            ld(" .detail_path li").html(news_title);
            ld("title").text(news_title);//修改title值
            ChangeWebUrl("index.php?pageto_module=Reminds&pageto_action=index");
            ld("#pagecontent .wrapper-panel-inner").html(ajaxdata);
            if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined"){
                //通讯录(pc端企业微信)
                cls_wxOpenDataobj.bindAllOpenData();
            }
            DelProgressObjs();
        }) */

    }
    // 设置菜单点击事件
    function SetmenuClick(event,jqueryobj){
        var tmpobj={};
        var event=event||window.event;
        StopEvent(event);
        tmpobj['module']=ld(jqueryobj).attr("module");
        tmpobj['label']=ld(jqueryobj).attr("label");
        tmpobj['file']=ld(jqueryobj).attr("file");
        LeftMenu_functionobj.settingmenuclick(tmpobj);
    }
    //选择原单的高级查询
    function showPopupHighSearch(){
        global_showPopupHighSearch(fun_setCrmPopupWindow.callSearch);
    }
    function global_showPopupHighSearch(OkFun){
        var popupobj=CrmPopup.getPopupObj("last");
        var prevpopupobj=CrmPopup.getPopupObj("lastprev"); //需要放在prevshow方法之前取值
        var module=popupobj.module;
        getJsScript('include/js/cls_advanceFilter.js',function () {
            var cls_advanceFilterObj = new cls_advanceFilter();
            cls_advanceFilterObj.setPrevPopupobj(popupobj);
            cls_advanceFilterObj.setColumnOptionHtml(popupobj.advancefieldnames);
            // @edit:ls @date:2020-7-8 @reason: 义文机电一键检测需求 general.js
            if(prevpopupobj!=undefined && popupobj.advft_criteria == ''){
                cls_advanceFilterObj.setFilterValue(prevpopupobj.advft_criteria,prevpopupobj.advft_criteria_groups);
            }else{
                cls_advanceFilterObj.setFilterValue(popupobj.advft_criteria,popupobj.advft_criteria_groups);
            }
            cls_advanceFilterObj.showAdvanceFilterPopup('yes',function () {
                OkFun('Advanced');
            });
            var Popupobj = cls_advanceFilterObj.popupobj;
            Popupobj.advanceSearchDivid = Popupobj.divid;
            if (!empty(popupobj.isMultiple) && popupobj.isMultiple == 'yes'){
                Popupobj.isMultiple=popupobj.isMultiple;
            }

        });

    }

    // @edit:liushuai,2020-12-29,reason:【ID1001225】快速创建增加设置按钮，可设置快速创建显示的模块(含有quickcreate的方法名都为新增加的)
    function UnifiedQuickcreate_SelectModuleForm(obj) {
        var Popupobj=CrmPopup.load("","","","LdPopWidth800px","undefinedQuickcreate","","","","");
        Popupobj.prevshow();
        var url ="index.php?module=Users&action=UsersAjax&file=UnifiedQuickcreateModules&ajax=true"
        ldAjax(url,{"namename": "uname", "namenameage": 18},function (data) {
            if(data.code==1){
                Popupobj.createHeadHtml=function(){
                    Popupobj.popupheadhtml='<div class="E_pop_tit" id="'+Popupobj.divid+'_head" style="cursor:move">';
                    Popupobj.popupheadhtml+='<strong class="E_ptita">'+Popupobj.headtitle+'</strong>';

                    Popupobj.popupheadhtml+='<button class="ld-fonticon ld-fonticon-close" value="关闭" id="'+Popupobj.divid+'_imgclose" style="cursor:pointer" ></button>';

                    // Popupobj.popupheadhtml+=' <strong class="E_ptita" style="float:right;padding:0 30px;cursor:pointer;" >';
                    // Popupobj.popupheadhtml+=' <a href="javascript:;" onclick="UnifiedQuickcreate_SelectModuleToggle(true);" style="cursor:pointer">'+data.result.allselect+'</a>';
                    //
                    // Popupobj.popupheadhtml+='  &nbsp; <a href="javascript:;" onclick="UnifiedQuickcreate_SelectModuleToggle(false);" style="cursor:pointer">'+data.result.selectcancel+'</a>';

                    Popupobj.popupheadhtml+=' </div>';
                }
                Popupobj.setParams(data.result.title,UnifiedQuickcreate_SelectModuleSave,"","LdPopWidth500px","undefiendsearch","",data.result.oktext,"",data.result.canceltext);
                Popupobj.show(data.result.content);
                getJsScript('include/js/DragTransfer.js',function(){
                    var tableobj = ld('#'+Popupobj.divid).find(" .commonMultipleSelect").parents("table");
                    var LeftObj = tableobj.find(" .commonMultipleSelect:first");
                    var RightObj = tableobj.find(" .commonMultipleSelect:last");
                    //传入翻译参数
                    var Drag_Transfer = new DragTransfer();
                    var translabel = {
                        available: arrJsPopLabel['OptionModules'],
                        selected: arrJsPopLabel['Selectedmodule'],
                        placeholder: arrJsPopLabel['PleaseEnterModuleSearchFor'],
                    };
                    Drag_Transfer.SetTranslabel(translabel);
                    Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'reset','310');
                    Popupobj.center();

                });
                ld('#'+Popupobj.divid+' #query_string').unbind('focus').bind('focus',function (){
                    ld(this).parent().addClass('bgwhite').addClass('ld-border-color-3b7cff');
                    ld(this).parent().find('#query_string').addClass('bgwhite');
                });
                ld('#'+Popupobj.divid+' #query_string').unbind('blur').bind('blur',function (){
                    ld(this).parent().removeClass('bgwhite').removeClass('ld-border-color-3b7cff');;
                    ld(this).parent().find('#query_string').removeClass('bgwhite');
                });
                ld('#'+Popupobj.divid+' #query_string').bind("input propertychange", function() {
                    var query_string = ld(this).val();
                    if(query_string != ''){
                        ld(this).parent().find('span.search-clear-btn').addClass('show');
                    }
                    else{
                        ld(this).parent().find('span.search-clear-btn').removeClass('show');
                    }
                });
                ld('#'+Popupobj.divid+' .page-topsec-inputbox .search-clear-btn').click(function(){
                    ld(this).parent().find('#query_string').val('');
                    ld(this).parent().find('#query_string').focus();
                    ld(this).parent().find('span.search-clear-btn').removeClass('show');
                });
                if(unifiedQuickcreate_modules!=""){
                    var selectmodules=unifiedQuickcreate_modules.split(",");
                    var UnifiedSearch_form = document.forms.UnifiedSearch;
                    var serarchchek='';
                    var formobj = document.UnifiedQuickcreate_moduleform;
                    var inputs = formobj.getElementsByTagName('input');
                    var inputlen = inputs.length;
                    if(selectmodules.length == inputlen){
                        ld('#quickcreate_onlyin_all').prop('checked',true);
                    }else{
                        ld('#quickcreate_onlyin_all').prop('checked',false);
                    }
                    if(inputlen > 0){
                        for(var i=0; i<inputlen; i++){
                            if(ld.inArray(inputs[i].value,selectmodules)>=0){
                                inputs[i].checked =true;
                            }
                            else{
                                inputs[i].checked =false;
                            }
                        }
                    }
                }
                DelProgressObjs();
            }
        });
    }

    var unifiedQuickcreate_modules="";
    function UnifiedQuickcreate_SelectModuleSave() {
        var select_modules = ld(".settingPopTable").find("#selectedColumns").get(0);
        var selectModuleStr='';
        if(select_modules.options.length>0){
            for(var i=0;i<select_modules.options.length;i++){
                    selectModuleStr += select_modules.options[i].value+",";
            }
        }
        var url="index.php?module=Users&action=UsersAjax&file=UnifiedQuickcreate&quickcreate_onlyin="+selectModuleStr.slice(0,-1);
        ldAjax(url,{},function(data){
            if(data.code==1){
                CrmPopup.getPopupObj("last").CancelEvent();
                // 更新快速创建内容
                ld('#quickcreate [name=quickcreate_list]').html(data.result.content);
                if(data.result.quickcreate_onlyin){
                    if(data.result.quickcreate_onlyin.length > 24){
                        ld('#quickcreate span.quicklyset-btn').css('display','none');
                        ld('#quickcreate .quickcreate-search-area').css('display','');
                    }else{
                        ld('#quickcreate span.quicklyset-btn').css('display','');
                        ld('#quickcreate .quickcreate-search-area').css('display','none');
                    }
                }
                //快速创建事件绑定
                ld('.quickly .list .quicklymodule').on('click',function(event){
                    var quick_module = ld(this).attr('tag');
                    var _edit = ld(this).attr('edit');
                    if(!empty(quick_module)){
                        ld('#quickcreate').hide();
                        var url="";
                        //edit:can 2020-11-12 报价单快速创建
                        AjaxJSPage(quick_module + "_js", 'include/js/modules/' + quick_module + '/' + quick_module + '.js');
                        if(_edit == 2){
                            var popupobj=CrmPopup.getPopupObj("last");
                            var objparams=new CreatePagePopup.params();
                            objparams.params['createdtype'] = 'quickcreate';
                            if( quick_module == 'Accounts'){
                                url += '&quickcreate_publicaccount=yes';	//公海参数设置创建的客户类型 快速创建默认，公海参数默认客户类型
                            }
                            CreatePagePopup.showpage(quick_module,url,objparams,event);
                        }
                        else{
                            listviewbutton_click(this,quick_module,'Create');
                        }
                    }
                });
                DelProgressObjs();
            }
        })
    }
    UnifiedQuickcreate_SelectModuleSave.funname = "UnifiedQuickcreate_SelectModuleSave";
    function UnifiedQuickcreate_SelectModuleToggle(flag) {
        var formobj = document.UnifiedQuickcreate_moduleform;
        if(formobj.length > 0){
            var inputs = formobj.getElementsByTagName('input');
            var inputlen = inputs.length;
            if(inputlen > 0){
                for(var i=0; i<inputlen; i++){
                    if(inputs[i].type == 'checkbox'){
                        inputs[i].checked = flag;
                    }
                }
            }
        }
    }
    function UnifiedQuickcreate_SelectModuleToggle_Allchange(obj) {
        UnifiedQuickcreate_SelectModuleToggle(ld(obj).prop('checked'));
    }
    function UnifiedQuickcreate_SelectModuleToggle_Inputchange(){
        var formobj = document.UnifiedQuickcreate_moduleform;
        var tmp_input_len = ld(formobj).find('input[type=checkbox]').length;
        var tmp_input_lenche = ld(formobj).find('input[type=checkbox]:checked').length;
        if(tmp_input_len == tmp_input_lenche){
            ld('#quickcreate_onlyin_all').prop('checked',true);
        }else{
            ld('#quickcreate_onlyin_all').prop('checked',false);
        }
    }
{/literal}
</script>

<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/tooltip.js?v={$GLOBALMINVERSION}"></script><!--tip-->
<script>
    //屏幕大小变化时，重新加载页面
    function windowResize2(){ldelim}
        var len=CrmPopup.global_listPopupObj.length;
        for(var i=len-1;i>=0;i--){
            var popupobj=CrmPopup.global_listPopupObj[i];
            if(popupobj.pagetype!=undefined && popupobj.pagetype=='listpage'&&popupobj.listresizeobj!=undefined){
                // console.log('列表');
                popupobj.listresizeobj.setReiszeTable_Init(popupobj.module,'ajax');
                setContentHeight(popupobj.module);//计算内容高度
            }
            if(popupobj.pagetype!=undefined && popupobj.pagetype=='detailview_modulepage'){
                // console.log('详情');
                // console.log('获取当前宽度，找到计算宽度方法，算出最新宽度');
                var tmpwidth=DetailViewPage.getWidth();
                ld("#"+popupobj.divid).css('width',tmpwidth+'px');
                var DivCTable_detailmaxheight = popupobj.getMaxHeight()-61;
                if(ld("#"+popupobj.divid+" #related_keywords_field").length > 0){
                    DivCTable_detailmaxheight = DivCTable_detailmaxheight - ld("#"+popupobj.divid+" #related_keywords_field").get(0).offsetHeight;
                }
                //客户-工作汇报缩放时界面错误
                if(popupobj.related_module == 'Home')
                {
                    ld(".Tdcenter div.DivCTable .main_grid .main_grid_box").css('height', DivCTable_detailmaxheight+'px');
                }
                ld('#'+popupobj.divid+' .Tdcenter div.DivCTable').css('max-height',DivCTable_detailmaxheight+'px');
            }
            if(popupobj.pagetype!=undefined && popupobj.pagetype=='create_edit_modulepage'){
                // console.log('新增编辑');
                // console.log('获取当前宽度，找到计算宽度方法，算出最新宽度');
                if(popupobj.createdtype!=undefined&&popupobj.createdtype=='create'){
                    //新增
                    var tmpwidth=CreatePagePopup.getWidth();
                }
                else{
                    //编辑
                    var tmpwidth=PageRecordPopup.getWidth()
                }
                ld("#"+popupobj.divid).css('width',tmpwidth+'px');
                popupobj.center();
            }
            if(popupobj.type!=undefined && popupobj.type=='relatelistpage'){
                // console.log('详情相关信息列表');
                var tmpwidth=DetailViewPage.getWidth();
                ld("#"+popupobj.divid).css('width',tmpwidth+'px');
                if(popupobj.relatelistsizeobj!=undefined){
                    popupobj.relatelistsizeobj.setRelatedResizeTable_Init(popupobj.module,'');
                    popupobj.reSizePosition();//设置相关信息全屏
                }
            }else if(popupobj.type != undefined && popupobj.type == 'relationshipChartPopup'){
                popupobj.relationshipChartobj.resize();
            }
        }

    {rdelim}
    window.addEventListener('resize', windowResize2, true);

</script>
<script>
    {literal}
    //加载tip 20200629 diony
    tooltip('.tip-items', {transition: true, time: 200});
    function getApproveCountInfo(){

        if(document.getElementById('headerapprovecount') != null){
            //edit:can 2020-09-01 首页->待审批/审批中心，审批/反审批操作过后，右上角的“审批”和“消息”提醒数量应该同时自动更新
            ldAjaxHtmlNoProgressobj("index.php?","module=Approve&action=ApproveAjax&file=getApproveCount&ajax=true",function(ajaxdata){

                document.getElementById('headerapprovecount').innerHTML = '('+ld.trim(ajaxdata)+')';
                if(ld.trim(ajaxdata) <= 0){
                    ld(' #approvebar ').find('b').css('display', 'none');
                }
            })
        }
    };

    var ModelDataBindobj={approvesavebutton:"",'buttoname':'','remindcount':0};
    Object.defineProperty(ModelDataBindobj,'approvesavebutton',{
        get:function(){
            return ModelDataBindobj.approvesavebutton;
        },
        set:function(newVal){
        
            getRemindsCount();
            getApproveCountInfo();//edit:can 2020-09-01 获取审批数量
        }
    })
    setTimeout(function(){
        getApproveCountInfo();
        getRemindsCount();
    },1000*3)
    
    Object.defineProperty(ModelDataBindobj,'remindcount',{
        get:function(){
            return ModelDataBindobj.remindcount;
        },
        set:function(newVal){
            getRemindsCount();
        }
    })
    Object.defineProperty(ModelDataBindobj,'setpropertyname',{
        set:function(newVal){
            ModelDataBindobj[newVal]='yes';
        }
    })
    Object.defineProperty(ModelDataBindobj,'setButtonName',{
        get:function(){
            return ModelDataBindobj['buttonname'];
        },
        set:function(newVal){
            ModelDataBindobj['buttonname']=newVal;
        }
    })

    //var now = getNow();
    //watermark({"watermark_txt":"A B C X Y Z "+now});
    if(watermark_txt!='') {
        //zxm 20230905 水印改成按需加载
        getJsScript('include/js/shuiyin.js', function () {
            watermark({"watermark_txt": watermark_txt});
        });
    }
    {/literal}
    //txy XUQIU1001546 为搜索框增加聚焦事件 全局查找
    {literal}
    ld('#pagehead #query_string').unbind('focus').bind('focus',function (){
        ld(this).parent().addClass('bgwhite').addClass('ld-border-color-3b7cff');
        ld(this).parent().find('#query_string').addClass('bgwhite');
    });
    ld('#pagehead #query_string').unbind('blur').bind('blur',function (){
        ld(this).parent().removeClass('bgwhite').removeClass('ld-border-color-3b7cff');;
        ld(this).parent().find('#query_string').removeClass('bgwhite');
    });
    {/literal}
    {literal}
        //窗口大小改变函数 整合
        ld(window).resize(function () {
            //crmpopup 的监听事件
            if(CrmPopup.global_listPopupObj.length){
                ld.each(CrmPopup.global_listPopupObj,function (index,crmpopupobj) {
                    if(crmpopupobj.divid != 'pagecontent1'){
                        if(crmpopupobj.reSizePosition && typeof crmpopupobj.reSizePosition == 'function'){
                            crmpopupobj.reSizePosition();
                        }
                    }
                });
            }
            //全局查找 列表高度重新加载
            if(ld(" .quicksearch_dv").length > 0){
                ld(" .quicksearch_dv").css("max-height",CrmPopup.getClientHeight()-topheight-10);
                setUnifiedSearchListViewHeight('');
            }
            //销售机会 列表ld-stagelist看板页面重新加载高度
            if(ld('.ld-kanban').length > 0){
                setKanBanListHeight();
            }
            //首页看板 宽度重新加载
            if(ld('#pagecontent .wrapper-panel-inner .ld_homeboard_index_layout').length > 0){
                setHomeBoardWidth();
            }
            //重现加载左侧菜单的滚动条
            if(ld(' .sub-menu').length > 0){
                initSlimscroll();
            }
            //目标管理 树形图 重新加载高度
            if(ld(" .orgchart").length > 0){
                resize_view();
            }
            //详情页面 相关信息 页签 重现加载高度
            var detailpopupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
            if(detailpopupobj != undefined){
                var tmpobj=CrmPopup.getPopupObj('last');
                tmpobj.reSizePosition();
                detailpopupobj.right();
            }
            //客户相关信息 客户图谱
            if(ld('#relationshipChartPopupDiv').length > 0){
                var popupobj = CrmPopup.getPopupObj('last');
                if (ld('#relationshipChartPopupDiv').length > 0 && !empty(popupobj.relationshipChartobj)){
                    popupobj.relationshipChartobj.resize();
                }
            }
            //历史看板（默认看板） 重现加载长宽
            if(ld('#MainMatrix').length > 0){
                var div_width =CrmPopup.getClientWidth()-getLeftMenuWidth()-20;//区块间隔宽度
                ld('#MainMatrix [tag=1]').css('width', div_width-15+'px');
                if(CrmPopup.getClientWidth() <= 414){
                    ld('#MainMatrix [tag=2]').css('width', div_width-15+'px');
                }
                else{
                    ld('#MainMatrix [tag=2]').css('width', (div_width/2-13)+'px');
                }
            }
        });
    {/literal}
</script>
{include file="ldmenustylecss.tpl"}
