<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    {if $name eq 'GroupEmail'}
    <title>{$CURRENT_NAME} - {'BULKMAIL'|@getFixedLabel}{$BROWSETITLE}</title>
    {elseif $name eq 'CallButler'}	
    <title>{$CURRENT_NAME} - {'CallButler'|@getTranstab}{$BROWSETITLE}</title>
    {elseif $ACTION eq 'PickListDependencySetup'}
    <title>{$CURRENT_NAME} - {'Settings'|@getTranstab}{$BROWSETITLE}</title>
    {else}
    <title>{$CURRENT_NAME} - {$MODULE_NAME|@getTranstab}{$BROWSETITLE}</title>
    {/if}
    <meta http-equiv = "X-UA-Compatible" content = "IE=edge,chrome=1"/>
	<style type="text/css">@import url("{$CSSURL}themes/{$THEME}/style.css?v={$GLOBALMINVERSION}");</style>
    <!--<style type="text/css">@import url("themes/{$THEME}/selfstyle.css");</style>
    <style type="text/css">@import url("themes/{$THEME}/global.css");</style>
    <link rel="stylesheet" href="themes/softed/popup.css" type="text/css" />
    <link rel="stylesheet" href="themes/softed/liststyle.css" type="text/css" />
    <link rel="stylesheet" href="themes/softed/PickList.css" type="text/css" />-->
    <link rel="stylesheet" href="{$CSSURL}themes/softed/viewer.min.css?v={$GLOBALMINVERSION}" type="text/css" /><!--多选框-->
    <link rel="stylesheet" href="{$CSSURL}themes/softed/select2.css?v={$GLOBALMINVERSION}" type="text/css" /><!--多选框-->
    <link rel="stylesheet" href="{$CSSURL}themes/softed/select2-bootstrap.css?v={$GLOBALMINVERSION}" type="text/css" />
    <link rel="stylesheet" type="text/css" href="{$CRMCOMMONURL}crmcommon/css/treeview/jquery.treeview.css?v={$GLOBALMINVERSION}" /><!--选部门选用户-->
    <link rel="stylesheet" href="{$CRMCOMMONURL}crmcommon/css/webuploader/webuploader.css?v={$GLOBALMINVERSION}" type="text/css" /><!--附件上传-->
    <link rel="stylesheet" href="{$CRMCOMMONURL}crmcommon/css/webuploader/bootstrap.min.css?v={$GLOBALMINVERSION}" type="text/css" /><!--附件上传-->
    <link rel="stylesheet" href="dataCache/tabdatas/skinset.css?v={$GLOBALMINVERSION}" type="text/css" /><!--菜单背景色自定义-->
    <script>
     var global_js_url='{$JSURL}';
    
    </script>
    {if $trade_version eq 'jijin'}
	<script language="javascript" type="text/javascript" src="include/trade/Jijin/Accured.js?v={$GLOBALMINVERSION}"></script><!--基金行业-->
    {/if}
    {if $HEADERCSS}
    	{foreach item=HDRCSS from=$HEADERCSS}
    	<link rel="stylesheet" type="text/css" href="{$CSSURL}{$HDRCSS->linkurl}" />
    	{/foreach}
    {/if}
    <style type="text/css">{literal}div.fixedLay1 {position:fixed;}{/literal}</style>
</head>
    <body style="margin:0 auto;width:100%;" class=small>
	<a name="top"></a>
	<script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.min.js"></script>
	<script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery-ui.min.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/cls_resetComboxHtml.js?v={$GLOBALMINVERSION}"></script>

    <script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.autosize.min.js"></script><!--文本区域自动增高-->
 	<script type="text/javascript" src="crmcommon/js/ueditor/ueditor.config.js?v={$GLOBALMINVERSION}"></script><!--编辑器-->
    <script type="text/javascript" src="crmcommon/js/ueditor/ueditor.all.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/ldcrm.edit.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/RichKinde.js?v={$GLOBALMINVERSION}"></script><!--很早以前的编辑器，这个不需要-->
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
    <script src="{$JSURL}include/js/ajax.js?version={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/producttool/toolField.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/producttool/fieldFormula.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/producttool/selectProduct.js?v={$GLOBALMINVERSION}"></script>
    {*editor:gyq_162 reason:海格产品分录导入   2019/12/5 11:33 *}
    <script type="text/javascript" src="{$JSURL}include/js/modules/XlsImportNew/XlsImportDocumentEntry.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="include/js/ScopePopup/ScopePopup.js?v={$GLOBALMINVERSION}"></script>
     <script type="text/javascript" src="{$JSURL}include/js/SystemPopup/DetailViewPage.js?v={$GLOBALMINVERSION}"></script>
	<script type="text/javascript" language="JavaScript">
         var typeofdata = new Array();
        typeofdata['E'] = ['c','e','n','s','ew','k','isnull','isnotnull'];
        typeofdata['V'] = ['c','e','n','s','ew','k','isnull','isnotnull'];
        typeofdata['N'] = ['e','n','l','g','m','h','isnull','isnotnull'];
        typeofdata['NN'] = ['e','n','l','g','m','h','isnull','isnotnull'];
        typeofdata['T'] = ['e','n','l','g','m','h','isnull','isnotnull'];
        typeofdata['I'] = ['e','n','l','g','m','h','isnull','isnotnull'];
        typeofdata['C'] = ['e','n','isnull','isnotnull'];
        typeofdata['DT'] = ['e','n','l','g','m','h','isnull','isnotnull'];
        typeofdata['D'] = ['e','n','l','g','m','h','isnull','isnotnull'];
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
		var ld = $;
        //33942: 合同订单新增和编辑界面附件左边？对应提示信息附件大小没有根据配置显示
        var global_uploadfile_maxsize_mb=parseInt('{$UPLOADFILEMAXSIZE}')/1000/1000;
       
        
        var fromcalendar='no';
        var imagecompress='{$IMAGECOMPRESS}';////设置网页端上传图片时是否压缩,0:压缩
        var language='{$LANUGAGETYPE}';
        if(language=='zh'){ldelim}
            language='zh-cn';
        {rdelim}
        {literal}
        var languagecolon= {"zh-cn":"：","en":":"};
        {/literal}
	</script>
    <script language="JavaScript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/My97DatePicker/WdatePicker.js?v={$GLOBALMINVERSION}"></script><!--时间选择器-->
	<script language="JavaScript" type="text/javascript" src="include/language/{$LANUGAGETYPE}.js?v={$GLOBALMINVERSION}"></script>
	<script language="JavaScript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/scriptaculous/prototype.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/FieldDependencies.js?v={$GLOBALMINVERSION}"></script><!--自动带出-->
	<script language="JavaScript" type='text/javascript' src='{$JSURL}include/js/modules/Reminds/Reminds.js?v={$GLOBALMINVERSION}'></script><!--提醒-->
	<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/general.js?v={$GLOBALMINVERSION}"></script><!--公共-->
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CommonPagePopup.js?v={$GLOBALMINVERSION}"></script><!--拖拽效果-->
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupDrag.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CrmPopup.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/QcPopup.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/selectSearchPopup.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PageRecordPopup.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupLayer.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/MassEditPopup.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CreatePagePopup.js?v={$GLOBALMINVERSION}"></script>
    
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupUserGroup.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/SaveDataRecord.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/selectSearchField.js?v={$GLOBALMINVERSION}"></script>
     <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/validatasave.js?v={$GLOBALMINVERSION}"></script>
     <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/DateTime.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/webuploader/webuploader.js?v={$GLOBALMINVERSION}"></script><!--附件上传-->
    {*editor:gyq_169 reason:腾讯云COS文件上传预览   2020/2/20 15:00*}
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/WebUploadFile.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/EditView.js?v={$GLOBALMINVERSION}"></script><!--编辑-->
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js?v={$GLOBALMINVERSION}"></script><!--编辑-->
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/ComboxPopup.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/cls_picklist.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/viewer.min.js?v={$GLOBALMINVERSION}"></script>
    <script>
        dynamicJsScript['FieldDependencies']=1;
        var global_ispopup_page='no';//是否为弹出页签也买你
        dynamicJsScript['include/js/popupselectfield.js']=1;
        dynamicJsScript['include/js/fieldinfo.js']=1;
        dynamicJsScript['include/js/ldcrm.edit.js']=1;
    </script>
    <script language="javascript" type="text/javascript" src="{$JSURL}include/js/modules/Products/multifile.js?v={$GLOBALMINVERSION}"></script>
    <script language="javascript" type="text/javascript" src="{$JSURL}include/js/Inventory.js?v={$GLOBALMINVERSION}"></script>
    <script language="javascript" type="text/javascript" src="{$JSURL}include/js/popupselectfield.js?v={$GLOBALMINVERSION}"></script>
    <script language="javascript" type="text/javascript" src="{$JSURL}include/js/fieldinfo.js?v={$GLOBALMINVERSION}"></script>
    {if $MODULE_NAME eq 'Settings'}
        <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Settings/Settings.js?v={$GLOBALMINVERSION}"></script><!--设置-->
    {/if}
    {if $MODULE_NAME eq 'CommunicationLog'}
         <script language="javascript" type="text/javascript" src="{$JSURL}include/js/tooltip.min.js?v={$GLOBALMINVERSION}"></script><!--短信列表状态tips-->
    {/if}
    <div class="Header">
    	<div class="HeaderTop">
        	<img src="dataCache/test/logo/{$LOGO}?a={$RANDNUM}" class="Logo" style="width: 130px;height: 36px;margin-top: 2px;margin-left: 5px;" />
            {if $ANNOUNCEMENT neq ''}
            <div class="Bulletin" style="margin-left: 10px">
                <marquee direction="left" onmouseover="this.stop()" onmouseout="this.start()" scrollamount="3">
                    &nbsp;{$ANNOUNCEMENT}
                </marquee>
            </div>
            {/if}
        	<ul class="rightnav">
                {*editor:gyq_79 reason:系统右上角呼叫中心报表优化 2018/9/5 16:51*}
				{if $CALLLINKDISPLAY eq '电话录音盒'}
                <li>
                    <b class="riconh"></b>
                    <a href="index.php?module=Users&action=CallButler">{'PHONESTEWARD'|@getFixedLabel}</a>
                </li>
               {*{elseif $CALLLINKDISPLAY neq 'no'}
                    <li>
                        <b class="riconh"></b>
                        <a href="index.php?module=Users&action=CallButler_MultiCenter&center_type={$CALLLINKDISPLAY}">{$CALLLINKDISPLAY}{'CALLCENTERREPORT'|@getFixedLabel}</a>
                    </li>*}
                {/if}
                <li {if $RegisterVersionNo eq 58 } style="display:none"{/if}>
                    <b class="riconi"></b>
                    <a href="index.php?module=Approve&action=ApproveListViewCount" >{'APPROVAL'|@getFixedLabel}</a>
					<span id='headerapprovecount'>{if $APPROVECOUNT gt 0}({$APPROVECOUNT}){/if}</span>
                </li>           
                <li>
                    <b class="ricona"></b>
                    <a href="index.php?module=Reminds&action=index">{'News'|@getFixedLabel}</a>
					<span id='headerremindscount'>{if $REMINDSCOUNT gt 0}({$REMINDSCOUNT}){/if}</span>
                </li>
                <li class="drop-down" id="login_out_select">                   
                    <b class="ricond"></b>
                    <a href="index.php?module=Users&action=DetailView&record={$CURRENT_USER_ID}&modechk=prefview">{$CURRENT_NAME}</a>
                    <b id="loginoutimg" class="icon-homeimg icon-down"></b>
                    <div  class="common-use-list">
                   
                        {if $ISADMIN eq 'on'&& 'upgradeexplain'|@array_key_exists:$GLOBAL_LOGININFO}
                            {if $GLOBAL_LOGININFO.upgradeexplain.isshow eq 'yes'}
                                <a href="{$GLOBAL_WELCOME.updateexplain}" target="_blank">{'UPDATENOTES'|@getFixedLabel}</a>
                            {/if}
						{else if $ISADMIN eq 'on'&&$GLOBAL_WELCOME.updateexplain neq 'no'&&$GLOBAL_WELCOME.updateexplain neq ''}
						<a href="{$GLOBAL_WELCOME.updateexplain}" target="_blank">{'UPDATENOTES'|@getFixedLabel}</a>
						{/if}
                        <a href="index.php?module=Users&action=DetailView&record={$CURRENT_USER_ID}&modechk=prefview" style="display: block;height: 27px;">{'EDITPERSONALACCOUNT'|@getFixedLabel}</a>
                        {*{if $SWITCHWXCONFIG eq 'open'}
                            <a onclick="wechat_applet()"  style="display: block;height: 27px;">{'WECHATAPPLETHEADER'|@getFixedLabel}</a>
                        {/if}*}
                        <a onclick="loginout()" class="tpl-nav-l" title="" style="display: block;height: 27px;">{'LOGOUT'|@getFixedLabel}</a>
                    </div>
                </li>
            </ul>
            <!--右上角，产品菜单，CSS3媒体查询-->
            <div class="media_header" onclick="show_nav()"><div style="width:25px;height:25px"></div></div>
        </div>
        {if $MODULE_NAME eq 'Home' || $MODULE_NAME eq 'Users' || $MODULE_NAME eq 'Customreport'}
        <div class="Menu" id="crm_menu">
        {elseif $MODULE_NAME neq 'Reminds' && $MODULE_NAME neq 'Settings' && $MODULE_NAME neq 'Administration' && $MODULE_NAME neq 'PickList'} 
        <div class="Menu" id="crm_menu" style="margin: 0 0 5px;">
        {else}
        <div class="Menu" style="margin: 0 0 5px;" id="crm_menu">
        {/if}
            <ul>
                {foreach key=maintabs item=detail from=$QUICKACCESS}
                    {if $maintabs eq 'Setup'}
						<li {if $CATEGORY eq 'Setup'} class="menu_on" {/if}><a href="index.php?module={$detail[0][1]}&action=index&parenttab={$maintabs}">{'Setup'|@getFixedLabel}<span class="icon-menuarr"></span></a>
					{else}
					
							<li {if $maintabs eq $CATEGORY}class="menu_on"{/if}>
							{if $maintabs neq $CATEGORY}
                            <a href="index.php?module={$detail[0][1]}&action=index&parenttab={$maintabs}" >{$PT[$maintabs]}<span class="icon-menuarr"></span></a>
							{else}
                            <a href="index.php?module={$detail[0][1]}&action=index&parenttab={$maintabs}">{$PT[$maintabs]}<span class="icon-menuarr"></span></a>
							{/if}
					
					{/if}
                   
                        <ul>
                            {foreach name=parenttablist key=parenttab item=details from=$detail}
                                {if $details[2] eq 'ld_linkmodulecustom'}
                                     <li><a target="_blank" href="{$details[1]}">{$details[0]}</a></li>
                                {else}
                                        {if $maintabs eq 'Journal' && $JOURNALPRESENCE eq '0' && $BankJournal eq '1'}
                                            <li><a href="index.php?module=BankCash&action=index&parenttab=Journal">{'BANKSTATEMENTS'|@getFixedLabel}</a>{*银行流水账*}</li>
                                        {/if}
                                        {if $maintabs eq 'Journal' && $JOURNALPRESENCE eq '0' && $CashJournal eq '1'}
                                            <li><a href="index.php?module=BankCash&action=index&parenttab=Journal">{'CASHBLOTTER'|@getFixedLabel}</a>{*现金流水账*}
                                            </li>
                                        {/if}
                                        {if $maintabs eq 'Journal' && $JOURNALPRESENCE eq '0' && $CashbackJournal eq '1'}
                                            <li><a href="index.php?module=OftenUseReport&action=ListView&UseReport=4">{'SHOULDTHESTATISTICSCOLLECTION'|@getFixedLabel}</a>{*应收款统计表*}</li>
                                        {/if}
                                        {if $maintabs eq 'Journal' && $JOURNALPRESENCE eq '0' && $SalesorderJournal eq '1'}
                                            <li><a href="index.php?module=OftenUseReport&action=ListView&UseReport=3">{'CONTRACTORDERTRACKING'|@getFixedLabel}</a>{*合同订单跟踪表*}</li>
                                        {/if}
                                        {if $maintabs eq 'Journal' && $JOURNALPRESENCE eq '0' && $TigertopJournal eq '1'}
                                            <li><a href="index.php?module=OftenUseReport&action=ListView&UseReport=7">{'THESINGNINGAMOUNTOFBILLBOARD'|@getFixedLabel}</a>{*签约金额龙虎榜*}</li>
                                        {/if}
                                		{assign var="modulelabel" value=$details[0]}
                                		{assign var="moduleaction" value="index"}
                                	   	{if isset($details[2])&&$details[2] neq 'ld_tab'&&$details[2] neq 'ld_linkmodulecustom'}
                                	   		{assign var="moduleaction" value=$details[2]}
                                	   	{/if}
                                        {if $details.1 eq 'MassEmails' ||$details.1 eq 'MassFaxs' || $details.1 eq 'MassVoices'}
                                            {if $details.1 eq 'MassEmails'}
                                            <li><a href="index.php?module=Emails&action=GroupEmail&parenttab={$maintabs}">{$modulelabel}</a></li>
                                            {else}
                                            <li><a href="javascript:void(0);">{$modulelabel}</a></li>
                                            {/if}
                                        {elseif $details.1 eq 'ReportLog'}
                                            <li><a href="index.php?module=ReportLog&action=DailyReportLog&reporttype=write&parenttab=My Home Page">{'WRITEREPORTS'|@getFixedLabel}</a></li>
                                            <li><a href="index.php?module=ReportLog&action=DailyReportLog&look=look&parenttab=My Home Page">{'VIEWREPORT'|@getFixedLabel}</a></li> 
                                        {elseif $details.1 eq 'Cache'}    
                                            <li><a href="javascript:void(0);" onclick="clearcaches();">{$modulelabel}</a></li>
                                            {if $trade_version eq 'jinxingzichan' || $account_version eq 'jinxingzichan'}
                                            <li><a href="index.php?module=Comprehensivereport&action=jinxinggongzi">{'jinxingongzi'|@getFixedLabel}</a></li>
                                            {/if}
                                        {elseif $details.1 eq 'SmsPhrases'}
                                            <li><a href="index.php?module=SmsPhrases&action=index&parenttab=Marketing&blockidsetting=3&fieldidsetting=58">{$modulelabel}</a></li>
                                        {elseif $details.1 eq 'EmailListtmp'}
                                            <li><a href="index.php?module=EmailListtmp&action=index&parenttab=Marketing&blockidsetting=3&fieldidsetting=12">{$modulelabel}</a></li>
                                        {elseif $details.1 eq 'SalesOrder' && ($trade_version eq 'jinxingzichan' || $account_version eq 'jinxingzichan')}
                                            <li><a href="index.php?module={$details.1}&action={$moduleaction}&parenttab={$maintabs}">{$modulelabel}</a></li>
                                            <li><a href="index.php?module=Comprehensivereport&action=Dividend">{'Dividend'|@getFixedLabel}</a></li>
                                        {elseif $details.1 eq 'SalesOrder' && ($trade_version eq 'shuowei' || $account_version eq 'shuowei')}
                                            <li><a href="index.php?module={$details.1}&action={$moduleaction}&parenttab={$maintabs}">{$modulelabel}</a></li>
                                            <li><a href="index.php?module=Comprehensivereport&action=shuowei">{'Dividend'|@getFixedLabel}</a></li>
                                        {elseif $details.1 eq 'SalesOrder' && ($trade_version eq 'licaodai' || $account_version eq 'licaodai')}
                                            <li><a href="index.php?module={$details.1}&action={$moduleaction}&parenttab={$maintabs}">{$modulelabel}</a></li>
                                            <li><a href="index.php?module=Comprehensivereport&action=licaodai">{'Dividend'|@getFixedLabel}</a></li>
                                        {elseif $details.1 eq 'SalesOrder' && $trade_version eq 'xiying'}
                                            <li><a href="index.php?module={$details.1}&action={$moduleaction}&parenttab={$maintabs}">{$modulelabel}</a></li>
                                            <li><a href="index.php?module=Comprehensivereport&action=PaymentScheduleReport">付款明细表</a></li>
                                            <li><a href="index.php?module=Comprehensivereport&action=SendPaymentScheduleReport">收款明细表</a></li>
                                            <li><a href="index.php?module=Comprehensivereport&action=PaymentSummaryReport">付款汇总表</a></li>
                                            <li><a href="index.php?module=Comprehensivereport&action=SendPaymentSummaryReport">收款汇总表</a></li>
                                        {elseif $details.1 eq 'SalesOrder' && ($trade_version eq 'chuangcai' || $account_version eq 'chuangcai')}
                                            <li><a href="index.php?module={$details.1}&action={$moduleaction}&parenttab={$maintabs}">{$modulelabel}</a></li>
                                            <li><a href="index.php?module=Comprehensivereport&action=ReceivablesReport">应收账款表</a></li>
                                            <li><a href="index.php?module=Comprehensivereport&action=CostRevenuesReport">收入成本表</a></li>
                                        {elseif $details.1 eq 'Comprehensivereport' && ($trade_version eq 'yixun' || $account_version eq 'yixun')}
                                            <li><a href="index.php?module={$details.1}&action={$moduleaction}&parenttab={$maintabs}">{$modulelabel}</a></li>
                                            <li><a href="index.php?module=Comprehensivereport&action=OperationsReport&ReportHeader=DHeader&year=2015&parenttab=Reports" target="_blank">运营报表</a></li>
                                            <li><a href="index.php?module=Comprehensivereport&action=FinancialReport&ReportHeader=DHeader&year=2015&parenttab=Reports" target="_blank">财务报表</a></li>
                                            <li><a href="index.php?module=Comprehensivereport&action=hetonggangReport&ReportHeader=DHeader&year=2015&parenttab=Reports" target="_blank">合同岗报表</a></li>
        								{elseif $maintabs eq 'Setup' && $details.1 eq 'system_setup'}
        									<li><a href="index.php?module=Settings&action=ModuleManager&parenttab=Settings&blockidsetting={$blockidsetting}&fieldidsetting={$fieldidsetting}">{$modulelabel}</a></li>
        								{elseif $maintabs eq 'Setup' && $details.1 eq 'system_group'}
        									<li><a href="index.php?module=Settings&action=listgroups&parenttab=Setup">{$modulelabel}</a></li>
        								{elseif $maintabs eq 'Setup' && $details.1 eq 'system_profile'}
        									<li><a href="index.php?module=Settings&action=listroles&parenttab=Setup">{$modulelabel}</a></li>
        								{elseif $details.1 eq 'MassSMS'}
        									 <li><a href="javascript:void(0);" onclick="getMassSmsPopup()">{$modulelabel}</a></li>
                                        {else}
                                            <li><a href="index.php?module={$details.1}&action={$moduleaction}&parenttab={$maintabs}">{$modulelabel}</a></li>
                                        {/if}
                                {/if}
                            {/foreach}
                        </ul>
                   
                    </li>
    			{/foreach}
            </ul>
            <ul style="float: right;">
                <div  style="float: right;height:37px;line-height:37px;">
                    <div class="Search" style="float:left;">
                        <form name="UnifiedSearch" id="UnifiedSearch" method="get" action="index.php" style="margin:0px" onsubmit="return UnifiedSearchSubmit();">
                            <input type="hidden" name="action" value="UnifiedSearch" style="margin:0px">
                            <input type="hidden" name="module" value="{$MODULE_NAME}" style="margin:0px">
                            <input type="hidden" name="parenttab" value="{$CATEGORY}" style="margin:0px">
                            <input type="hidden" name="search_onlyin" value="{$SEARCHMODULE}" style="margin:0px">
                            <div class="icon-search3" onclick="UnifiedSearch_SelectModuleForm(this);"></div>
                            {if $QUERY_STRING eq '快速查找' || $QUERY_STRING eq 'Quick Search'} 
                            <input type="text" style="height:20px;" name="query_string" id="query_string" onkeyup="searchSubmit(event,'quickSearch')" placeholder="{$QUERY_STRING}" class="Text" onclick="" value="" />
                            {else}
                            <input type="text" style="height:20px;" name="query_string" id="query_string" onkeyup="searchSubmit(event,'quickSearch')" placeholder="{$QUERY_STRING}" class="Text" onclick="" value="" />
                            {/if}
                            <a id="basicsearch_submit" onclick="UnifiedSearchClick(this);" class="header-btn-search" href="#" title="{'SEARCH'|@getFixedLabel}"></a>
                        </form>
                    </div> 
                    <div class="Qcreate" style="float:right;height:37px;line-height:37px;" onclick="quicklyDIV();">
                        {include file='qcreatePick.tpl'}
                        {assign var="quickly_5_width" value=100*$QUICKMODULECNT}
                        <div class="quickly" {if $QUICKMODULECNT < 5} style="width:{$quickly_5_width}px"{elseif $QUICKMODULECNT < 15}style="width:280px"{/if}>
                            <div class="list crm-clearfix">
            					{foreach item=details from=$QUICKMODULE}
            					<div class="quicklymodule" tag="{$details.module}" edit="{$details.edit}"><div class="quicklyimgdiv"><img {if $details.havacustomform eq 'no'} src="app/quickly_image/crm_{$details.img}.png"{else}src="app/quickly_image/crm_CustomForm.png"{/if}/><div style="text-overflow: ellipsis;overflow: hidden;white-space: nowrap;">{$details.label}</div></div></div>
                                {/foreach}
                            </div>
                        </div>
                    </div>   
                </div>
            </ul>
        </div>
        {if $MODULE_NAME neq 'Reminds' && $MODULE_NAME neq 'Settings' && $MODULE_NAME neq 'Approve' && $MODULE_NAME neq 'Administration' && $MODULE_NAME neq 'PickList' }
			{if $MODULE_NAME eq 'Home' && $name eq 'UnifiedSearch'}
            {elseif $MODULE_NAME eq 'Users' && $blockidsetting neq ''}
			{elseif $MODULE_NAME eq 'Users' && $ACTION_NAME eq 'CallButler'}
			{elseif $MODULE_NAME eq 'Comprehensivereport' && $ACTION_NAME neq 'index'}
				<div class="Link">
                	<ul>
						<li><a {if $ACTION_NAME eq 'PaymentScheduleReport'} class="On" {/if} href="index.php?module=Comprehensivereport&action=PaymentScheduleReport">付款明细表</a></li>
						<li><a {if $ACTION_NAME eq 'SendPaymentScheduleReport'} class="On" {/if} href="index.php?module=Comprehensivereport&action=SendPaymentScheduleReport">收款明细表</a></li>
						<li><a {if $ACTION_NAME eq 'PaymentSummaryReport'} class="On" {/if} href="index.php?module=Comprehensivereport&action=PaymentSummaryReport">付款汇总表</a></li>
						<li><a {if $ACTION_NAME eq 'SendPaymentSummaryReport'} class="On" {/if} href="index.php?module=Comprehensivereport&action=SendPaymentSummaryReport">收款汇总表</a></li>
					</ul>
				</div>
            {else}
                <div class="Link" style="display:none;">
                	<ul>
                        {foreach key=maintabs item=details from=$QUICKACCESS}
            				{if $maintabs eq $CATEGORY}
            					{foreach  key=number item=modules from=$details}
            						{assign var="modulelabel" value=$modules[0]}
            						{assign var="moduleaction" value="index"}
            	   					{if isset($modules[2])}
            	   						{assign var="moduleaction" value=$modules[2]}
            	   					{/if}		
            						{if $modules.1 eq $MODULE_NAME}
                                        {if $modules.1 eq 'ReportLog'}
                                            {if $reporttype eq 'write'}
                                                <li><a class="On" href="index.php?module={$modules.1}&action=DailyReportLog&reporttype=write&parenttab={$maintabs}">{'WRITEREPORTS'|@getFixedLabel}</a></li>
                                                <li><a href="index.php?module={$modules.1}&action=DailyReportLog&reporttype=look&look=look&parenttab={$maintabs}">{'VIEWREPORT'|@getFixedLabel}</a></li>
                                            {elseif $reporttype eq 'look'}
                                                <li><a href="index.php?module={$modules.1}&action=DailyReportLog&reporttype=write&parenttab={$maintabs}">{'WRITEREPORTS'|@getFixedLabel}</a></li>
                                                <li><a class="On" href="index.php?module={$modules.1}&action=DailyReportLog&reporttype=look&look=look&parenttab={$maintabs}">{'VIEWREPORT'|@getFixedLabel}</a></li>
                                            {else}
                                                <li><a href="index.php?module={$modules.1}&action=DailyReportLog&reporttype=write&parenttab={$maintabs}">{'WRITEREPORTS'|@getFixedLabel}</a></li>
                                                <li><a class="On" href="index.php?module={$modules.1}&action=DailyReportLog&reporttype=look&look=look&parenttab={$maintabs}">{'VIEWREPORT'|@getFixedLabel}</a></li>
                                            {/if}
                                        {elseif $modules.1 eq 'Emails'}
                                            {if $name eq 'index'}
                                                <li><a class="On" href="index.php?module={$modules.1}&action={$moduleaction}&parenttab={$maintabs}">{$modulelabel}</a></li>
                                            {else}
                                                <li><a href="index.php?module={$modules.1}&action={$moduleaction}&parenttab={$maintabs}">{$modulelabel}</a></li>
                                            {/if}
                                        {elseif $modules.1 eq 'SmsPhrases'}
                                            <li><a class="On" href="index.php?module={$modules.1}&action={$moduleaction}&parenttab={$maintabs}&blockidsetting=3&fieldidsetting=58">{$modulelabel}</a></li>
                                        {elseif $modules.1 eq 'EmailListtmp'}
                                            <li><a class="On" href="index.php?module={$modules.1}&action={$moduleaction}&parenttab={$maintabs}&blockidsetting=3&fieldidsetting=12">{$modulelabel}</a></li>
                                        {else}  
                                            <li><a class="On" href="index.php?module={$modules.1}&action={$moduleaction}&parenttab={$maintabs}">{$modulelabel}</a></li>
                                        {/if}
            						{else}
                                        {if $modules.1 eq 'MassEmails' || $modules.1 eq 'MassFaxs' || $modules.1 eq 'MassVoices'}
                                            {if $modules.1 eq 'MassEmails'}
                                                {if $modules.1 eq 'MassEmails' && $MODULE_NAME eq 'Emails'}
                                                    {if $name eq 'GroupEmail'}
                                                        <li><a class="On" href="index.php?module=Emails&action=GroupEmail&parenttab={$maintabs}">{$modulelabel}</a></li>
                                                    {else}
                                                        <li><a href="index.php?module=Emails&action=GroupEmail&parenttab={$maintabs}">{$modulelabel}</a></li>
                                                    {/if}
                                                {elseif $groupEmail eq 'Emails'}
                                                    <li><a class="On" href="index.php?module=Emails&action=GroupEmail&parenttab={$maintabs}">{$modulelabel}</a></li>
                                                {else}
                                                    <li><a href="index.php?module=Emails&action=GroupEmail&parenttab={$maintabs}">{$modulelabel}</a></li> 
                                                {/if}
                                            {else}
                                                <li><a href="javascript:void(0);" >{$modulelabel}</a></li>
                                            {/if}                    
                                        {elseif $modules.1 eq 'ReportLog'}
                                            <li><a href="index.php?module={$modules.1}&action=DailyReportLog&reporttype=write&parenttab={$maintabs}">{'WRITEREPORTS'|@getFixedLabel}</a></li>
                                            <li><a href="index.php?module={$modules.1}&action=DailyReportLog&reporttype=look&look=look&parenttab={$maintabs}">{'VIEWREPORT'|@getFixedLabel}</a></li>
                                        {elseif $MODULE_NAME eq 'Emails' && $modules.1 eq 'Webmails'}
                                            <li><a class="On" href="index.php?module={$modules.1}&action={$moduleaction}&parenttab={$maintabs}">{$modulelabel}</a></li>
                                        {elseif $modules.1 eq 'Emails' && $MODULE_NAME eq 'MailManager'}
                                            <li><a class="On" href="index.php?module={$modules.1}&action={$moduleaction}&parenttab={$maintabs}">{$modulelabel}</a></li>
                                        {elseif $modules.1 eq 'Cache'}
                                            <li><a href="javascript:void(0);" onclick="clearcaches();">{$modulelabel}</a></li>
                                        {elseif $modules.1 eq 'MassSMS' && $groupEmail eq 'MassSMS'}  
                                            <li><a class="On" href="index.php?module={$modules.1}&action={$moduleaction}&parenttab={$maintabs}">{$modulelabel}</a></li>
                                        {elseif $modules.1 eq 'SmsPhrases'}
                                            <li><a href="index.php?module={$modules.1}&action={$moduleaction}&parenttab={$maintabs}&blockidsetting=3&fieldidsetting=58">{$modulelabel}</a></li>
                                        {elseif $modules.1 eq 'EmailListtmp'}
                                            <li><a href="index.php?module={$modules.1}&action={$moduleaction}&parenttab={$maintabs}&blockidsetting=3&fieldidsetting=12">{$modulelabel}</a></li>
                                        {elseif $smarty.request.module eq 'XlsImport' && $smarty.request.now_module eq $modules.1}
                                            <li><a class="On" href="index.php?module={$modules.1}&action={$moduleaction}&parenttab={$maintabs}">{$modulelabel}</a></li>
                                        {else}  
                                            <li><a href="index.php?module={$modules.1}&action={$moduleaction}&parenttab={$maintabs}">{$modulelabel}</a></li>
                                        {/if}
            					    {/if}	
            					{/foreach}
            				{/if}
            			{/foreach}
                    </ul>
					{if $MODULE_NAME eq 'PriceBooks'}
						{if 'oem_crm'|@getCommonVersion eq 'no' && ($ACTION_NAME eq 'index' || $ACTION_NAME eq 'ListView')}<a class="icon-mediumimg_1 rfloat" href="javascript:;" style="margin-top: 1px;" onclick="getLinksUrl('{$MODULE_TABID}','listview','listview');"></a>{/if}
					{/if}
                </div>
                <!--界面美化，隐藏该div-->
                <div style="height:5px;background-color: #fff;display:none;"></div>
            {/if}
        {/if}
    </div>
    <div class="clear"></div>

    <div id='miniCal' class="D_pop_box LdPopWidth350px" style='position:absolute; display:none; left:100px; top:100px; z-index:100000'></div>

    <!--by andy 0011670 [销售通] 日程管理—日程管理页签—鼠标放在某个时间框里面，出来“+”，点击“+”做个弹出层效果*日程管理+号弹出层新建单据-->
    <div id='CalendarNewBillDiv' class="D_pop_box LdPopWidth800px" style='position:absolute; display:none; left:100px; top:100px; z-index:100000'>
    <div id="CalendarNewBillDiv_form_div"></div>
    </div>
    {if $MODULE_NAME eq 'Calendar'}
    <div id="CalExport" style="width:300px; position:absolute; display:none; left:500px; top:100px; z-index:100000" class="layerPopup">
    	<table border=0 cellspacing=0 cellpadding=5 width=100% class=layerHeadingULine>
        	<tr>
        		<td class="genHeaderSmall" nowrap align="left" width="30%" >{'EXPORT'|@getFixedLabel}</td>
        		<td align="right"><a class="icon-homeimg icon-close" href='javascript:Alex("CalExport");'></a></td>
        	</tr>
    	</table>
    	<table border=0 cellspacing=0 cellpadding=5 width=95% align=center> 
        	<tr>
        		<td class="small">
        			<table border=0 celspacing=0 cellpadding=5 width=100% align=center bgcolor=white>
            			<tr>
            				<td align="right" nowrap class="cellLabel small">
            					<input class="small" type='radio' name='exportCalendar' value = 'iCal' onclick="$('ics_filename').removeAttribute('disabled');" checked /> csv
                            </td>
            				<td align="left">
            					<input class="small" type='text' name='ics_filename' id='ics_filename' size='25' value='lingdang.calendar'/>
            				</td>
            			</tr>
        			</table> 
        		</td>
        	</tr>
    	</table>
    	<table border=0 cellspacing=0 cellpadding=5 width=100% class="layerPopupTransport">
        	<tr>
        		<td align="center">
                    <input type="button" onclick="return exportCalendar();" value="{'EXPORT'|@getFixedLabel}" class="edit" name="button"/>
        		</td>
        	</tr>
    	</table>
    </div>
    <div id='CalImport' style='width:300px; position:absolute; display:none; left:500px; top:100px; z-index:100000' class="layerPopup">
    	{assign var='label_filename' value='LBL_FILENAME'}
    	<form name='ical_import' id='ical_import' onsubmit="puyoungJS_DialogBox.block();" enctype="multipart/form-data" action="index.php" method="POST">
    	<input type='hidden' name='module' value=''>
    	<input type='hidden' name='action' value=''>
    		<table border=0 cellspacing=0 cellpadding=5 width=100% class=layerHeadingULine>
    			<tr>
    				<td class="genHeaderSmall" nowrap align="left" width="30%" id="editfolder_info">{'IMPORT'|@getFixedLabel}</td>
    				<td align="right"><a class="icon-homeimg icon-close" href='javascript:ghide("CalImport");'></a></td>
    			</tr>
    		</table>
    		<table border=0 cellspacing=0 cellpadding=5 width=95% align=center> 
    			<tr>
    				<td>
    					<table border=0 celspacing=0 cellpadding=5 width=100% align=center bgcolor=white>
    						<tr>
    							<td align="right" nowrap class="cellLabel small"><b>{$label_filename} </b></td>
    							<td align="left">
    								<input type='file' name='ics_file' id='ics_file'/>
    							</td>
    						</tr>
    					</table>
    				</td>
    			</tr>
    		</table>
    		<table border=0 cellspacing=0 cellpadding=5 width=100% class="layerPopupTransport">
    			<tr>
    				<td align="center">
    				    <input type="button" onclick="return importCalendar();" value="{'IMPORT'|@getFixedLabel}" class="edit" name="button"/>
    				</td>
    			</tr>
    		</table>
    	</form>
    </div>
    {/if}
    <input type="hidden" id="oem_crm" name="oem_crm" value="{'oem_crm'|@getCommonVersion}" />
    
    <div id="calculator_cont" style="position:absolute; z-index:10000" ></div>
    
    <div id="UnifiedSearch_moduleformwrapper" class="D_pop_box LdPopWidth500px" style="position:absolute;display:none;"></div>

    <!--客户001 首次登录，显示引导层-->
    <div id="linkpage" class="linkpage" {if $FIRSTLOGIN neq 'yes'}style="display:none;"{/if}>
        <div>
            <table width="100%">
                <tr>
                    <td colspan="6" valign="middle" style="height: 120px;"><span class="linkpage-currentname">{$CURRENT_NAME}</span><span class="greyFontF font20">，开始使用灵当CRM</span></td>
                    <td align="right" valign="middle"><b class="home-closediv"></b></td>
                </tr>
                <tr>
                    <td align="center"><b class="home-num1 home-bg"></b></td>
                    <td align="center"><b class="home-line home-bg"></b></td>
                    <td align="center"><b class="home-num2 home-bg"></b></td>
                    <td align="center"><b class="home-line home-bg"></b></td>
                    <td align="center"><b class="home-num3 home-bg"></b></td>
                    <td align="center"><b class="home-line home-bg"></b></td>
                    <td align="center"><b class="home-num4 home-bg"></b></td>
                </tr>
                <tr>
                    <td align="center" valign="middle" class="greyFontF height70 font16">新增客户</td>
                    <td></td>
                    <td align="center" valign="middle" class="greyFontF height70 font16">跟进拜访</td>
                    <td></td>
                    <td align="center" valign="middle" class="greyFontF height70 font16">签订合同</td>
                    <td></td>
                    <td align="center" valign="middle" class="greyFontF height70 font16">开票和收款</td>
                </tr>
                <tr>
                    <td colspan="7" align="right" valign="middle"><b class="home-next"></td>
                </tr>
            </table>
        </div>
    </div>
            <div id="mini_menu_create_div"></div>
    <input name="hantianlogin" id="hantianlogin" type="hidden" value="{$HANTIANLOGIN}"/>
    <script type='text/javascript'>
        {literal}
             var hantianlogin = ld('#hantianlogin').val();
             var iframeswitch = ld('#JWtitle',window.parent.document).val();
        
             if(hantianlogin == 'yes'){
                window.parent.document.getElementById('toolbar').contentWindow.HantianTools.getInstance().loginfromcrm();
             }
             function loginout(){
                if(iframeswitch == 4){
                    window.parent.document.getElementById('toolbar').contentWindow.HantianTools.getInstance().loginoutfromcrm();
                }
                window.location.href = "index.php?module=Users&action=Logout";
             }
            //editor:gyq_83 reason:微信小程序账号绑定及扫码 2018/10/15 15:49
             function wechat_applet(){
                 getJsScript('include/js/modules/Settings/wechat_miniprogram/wechat_miniprogram.js',function() {
                     show_wechat_applet();
                 });
             }
            function importCalendar(){
            	var file = document.getElementById('ics_file').value;   
            	if (file != ''){
            		if (file.indexOf('.ics') != (file.length - 4)) {
            			alert(alert_arr.PLS_SELECT_VALID_FILE+".ics")
            		}
            		else {
            			document.ical_import.action.value='iCalImport';
            			document.ical_import.module.value='Calendar';
            			document.ical_import.submit();
            		}
            	}
            }
            function ghide(argg2){
            	var z=document.getElementById(argg2).style;
            	if (z.display=="block"){
            		z.display="none"
            	}
            }
            function Alex(obj){
                var z=document.getElementById(obj).style;
            	if (z.display=="block"){
            		z.display="none"
            	}  
            }
            /**
            * @edit:chj
            * @date:2014-9-18
            * @reason:模块序时簿  检索 可以按Enter键进行查询
            * @description:0011443: 模块叙事簿界面：基本查找、高级查找中，刘总建议可以按“ENTER"键查找内容
            */
            function searchSubmit(event,searchtype){
                var e = event || window.event;
                if(e.keyCode == 13){// Enter 回车键
                    if(searchtype == 'Basic'){
                        callSearch('Basic');//基本
                    }
                    else if(searchtype == 'quickSearch'){
                        UnifiedSearchClick();
                    }else{
                        callSearch('Advanced');
                    }
                }
            }
            function exportCalendar(){
            	if(document.getElementsByName('exportCalendar')[0].value == 'iCal'){
            		var filename = $('ics_filename').value;
                    puyoungJS_DialogBox.block();
                  	var url = "index.php?module=Calendar&action=iCalExport&filename="+filename;
            		location.href = url;
                    puyoungJS_DialogBox.unblock();
            		ghide('CalExport')
            	}
            }
            /**
             * 搜索提交方法，多加一步全局参数判断，防止重复点击提交事情发生
             * @reason 0011669 快速查找：搜索后无法记住上次选择的模块
             * @author Tujt 2014-09-28
             */
            var isunifiedsearchsubmit = 1;
            function UnifiedSearchSubmit(){
            	//0027075: 快速查找：点击文本框，点击搜索，界面显示的字体“请至少输入1个字符以上的数据再查找 ...”建议更改样式
            	if(ld('#query_string') != undefined){
            		if(ld('#query_string').val() == ''){
                        var confirm_str = arrJsPopLabel['PLEASEENTERKEYWORDTOSEARCH'];
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            			return false;
            		}
            	}
            	if(isunifiedsearchsubmit == 1){
            		isunifiedsearchsubmit = 2;
                    puyoungJS_DialogBox.block();
            		return true;
            	}else{
            		return false;
            	}
            }

            function UnifiedSearchClick(obj){
            	if(UnifiedSearchSubmit()){
            		document.getElementById("UnifiedSearch").submit();
            	}
            }

            /* 异步获取审批中心数量 tujt 2014-08-29*/
            function getApproveCountInfo(){
                ldAjaxHtml('index.php','module=Approve&action=ApproveAjax&file=getApproveCount&ajax=true',function (response) {
                    var rest = response.responseText;
                    rest = trim(rest);
                    if(rest > 0){
                        document.getElementById('headerapprovecount').innerHTML = '('+trim(rest)+')';
                    }
                })
            };
            getApproveCountInfo();//27215: 审批中心表，订单审核过后审批中心数字不变刷新后改变(看看注释的要求)
            /*右上角，产品菜单，CSS3媒体查询*/
            function show_nav(){
                var aUL=document.getElementsByTagName('ul')[0];
                if(aUL.className=='rightnav'){
                    aUL.className = 'rightnav media_active';
                }else{
                    aUL.className = 'rightnav';
                }
            }
            //选择原单的高级查询
            function showPopupHighSearch()
                {
                     
                     var popupobj=CrmPopup.getPopupObj("last");
                     var module=popupobj.module;
                                
                     var Popupobj=new ListHigherSearchPopup.loaddivid("dv_popup_listhighersearch","",fun_setCrmPopupWindow.callSearch,"","LdPopWidth800px",module,"Advanced","","","");
                     Popupobj.show();
                     Popupobj.advanceSearchDivid="dv_popup_listhighersearch"  ;
                                        
                                
                }
        {/literal}
    </script>

    <script language="JavaScript">
        var gVTModule = '{$smarty.request.module|@vtlib_purify}';
        var $QUICKMODULECNTs =1;
    </script>

    <!--快速创建，弹出框-->
    <div id="qcformDiv" class="D_pop_box LdPopWidth800px" style="position:absolute;display:none;top:50%;left:40%;z-index:999;">
        <div id="qcform"></div>
    </div>
    <div id="Second_qcformDiv" class="D_pop_box LdPopWidth800px" style="position:absolute;display:none;top:50%;left:40%;z-index:2000;">
        <div id="Second_qcform"></div>
    </div>
    <div id="status" style="position:absolute;display:none;left:950px;top:85px;height:27px;white-space:nowrap;">
        <img src="{'status.gif'|@lingdang_imageurl:$THEME}">
    </div>
    <script>
        {literal}
            function setbodywidth(){
                new Ajax.Request('index.php',{
                    queue: {position: 'end', scope: 'command'},
                    method: 'post',
                    postBody: 'module=Users&action=UsersAjax&file=jsphp&bodywidth='+bodywidth,
                    onComplete: function(response) {}
                });
            }
            var _flag = 'yes';
            //document.write('<scri'+'pt src="include/js/picklist.js" type="text/javascript"></s'+'cript>');
            function clearcaches(){
				if(_flag == 'yes'){
					_flag = 'no';
					new Ajax.Request('index.php',{
						queue: {position: 'end', scope: 'command'},
						method: 'post',
						postBody: 'module=Cache&action=index&ajax=true',
						onComplete: function(response) {       
							if(response.responseText.indexOf('SUCCESS')>0){
                                puyoungJS_DialogBox.block();
                                puyoungJS_DialogBox.unblock();
								var confirm_str = arrJsPopLabel['CLEARSUCCESS'];
								_flag = 'yes';
								RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
								return;
							}
						}
					});
				}
            }
            /**客户001首页首次登录遮罩层 关闭事件**/
            ld(".home-closediv").click(function(){
                ld("#linkpage").hide();
            });
            ld(".home-next").click(function(){
                ld("#linkpage").hide();
            });
        {/literal}
    </script>

    <div id="tracker" class="LdPop_box LdPopWidth300px" style="display:none;">
    	<div class="Title"><img src="themes/softed/tier/icon_loto.png" class="Logo" /><span class="Name">{'RECENTLYVIEWED'|@getFixedLabel}</span>
    		<a href="javascript:fninvshnew('tracker');">
    			<img src="themes/softed/tier/icon_close.png" class="Close" />
    		</a>
    	</div>		
        <div class="Content_div">
        	<table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td class="Note">
                		<ul class="LdPop_ul1">
        					{foreach name=trackinfo item=trackelements from=$TRACINFO}
    						<li>  
    							<div class="Character-Names">
    								{$smarty.foreach.trackinfo.iteration}.&nbsp;&nbsp;
    								<a href="index.php?module={$trackelements.module_name}&action=DetailView&record={$trackelements.crmid}&parenttab={$CATEGORY}">{$trackelements.item_summary}</a>
    							</div>
    							<div class="clear"></div>
    						</li>
        					{/foreach}
        				</ul>
                    </td>
                </tr>
            </table>
        </div>
    </div>

    <div id="changeExport" class="layerPopup divPopup-on2" style="width:200px; height:100px; z-index:9999999999; display:none;">
    	<h1><a href="javascript:fninvshnew('changeExport');" onclick="puyoungJS_DialogBox.unblock();"></a>*导出</h1>
        <table border=0 cellspacing=0 cellpadding=5 width=100% class="small" style="padding:0 -5px;">
        	<tr id="numberOfColumns">
        		<td class="dvtCellInfo" align="left">
                    <input type="radio" name="exporttype" value="3" checked="checked" /> .xls 格式
                    <input type="radio" name="exporttype" value="2" /> .csv 格式  
        		</td>
        	</tr>
    	</table>
        <div class="divPopup-Bottom">
       		<a class="Push-button-a" onclick="exportTypeTelect('{$MODULE_NAME}','{$CATEGORY}')" >导出</a>
       </div>
    </div>

    <div class="lvtCol fixedLay1" id="lingdangNewsPopupLay" style="display:none;height:250px;bottom:2px;padding:2px;z-index:12;font-weight:normal;" align="left">
    </div>

    <div class="fixedLay1" id="ActivityRemindercallback" style="border:0;right:7px;bottom:0px;display:none;padding:0px;z-index:10000;" align="left"></div>

    <div id="selectrelateddiv" class="D_pop_box LdPopWidth800px" style="display:none; z-index:10000;"></div>

    <div class="lvtCol fixedLay1" id="notificationDiv" style="float: right;  padding-right: 5px; overflow: hidden; border-style: solid; right: 0px; border-color: rgb(141, 141, 141); bottom: 0px; display: none; padding: 2px; z-index: 10; font-weight: normal;" align="left">
    </div>
    <div id="OutgoingCall" style="display: none;position: absolute;z-index:200;" class="layerPopup">
    	<table  border='0' cellpadding='5' cellspacing='0' width='100%'>
    		<tr style='cursor:move;' ><td class='mailClientBg small' id='outgoing_handle'><b>{$APP.LBL_OUTGOING_CALL}</b></td></tr>
    	</table>
    	<table border='0' cellpadding='0' cellspacing='0' width='100%' class='hdrNameBg'>
    		<tr><td style='padding:10px;' colspan='2'>{$APP.LBL_OUTGOING_CALL_MESSAGE}</td></tr>
    	</table>
    </div>
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
    <div id="watting" style="display:none;"><img src="themes/images/waiting.gif"></div>
    {if $MODULE_NAME eq 'Events'}
    {assign var=MODULE_NAME value='Calendar'}
    {/if}
    {if $MODULE_NAME eq 'Calendar'} 
        <script type="text/javascript" src="modules/Calendar/Calendar.js"></script>
        <script type="text/javascript" src="modules/Calendar/script.js"></script> 
    {elseif $MODULE_NAME neq 'Home' && $MODULE_NAME neq 'PickList' && $MODULE_NAME neq 'ReportLog' 
    && $MODULE_NAME neq 'EmailListtmp' && $MODULE_NAME neq 'CommunicationLog' 
    && $MODULE_NAME neq 'Comprehensivereport' && $MODULE_NAME neq 'Administration' && $MODULE_NAME neq 'MassSMS'}
        <script type="text/javascript" src="{$JSURL}include/js/modules/{$MODULE_NAME}/{$MODULE_NAME}.js"></script>
    {/if}
    {if $BANGWO8_LINEHELPJS eq '1'}
        <script language="javascript" type="text/javascript" charset="gb2312" src="http://chat.bangwo8.com/js/chatInit.js?bangwo8Info=OTgwMTU4Njk3YTY3ZjA5NjgwOTQxNWNhMWM5ZjExMmQ5NmQyNzY4OWI=" async="async" id="bangwo8Info" position="left"></script>
    {/if}
<!--自助服务平台-->
<div id="selfService" class="D_pop_box LdPopWidth400px" style="display:none;">
    <div class="D_pop_tit">
        <strong class="D_ptita">客户自助服务平台二维码</strong>
        <a href="javascript:fninvshnew('selfService');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>      
    <table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">
      <tr>
        <td class="ctextalign">
            <img src="./dataCache/test/logo/wechat_miniprogram.jpg" style="width: 180px;padding: 10px;">
            <p class="ltextalign">说明：保存图片，使用鼠标右键点击“图片另存为”，可选择图片保存在电脑上的位置</p>
        </td>
      </tr>
    </table>

</div>

<div id="dv_popup_listhighersearch" style="max-height:400px; display:none;" class="LdPopWidth800px">
      <div class="D_pop_tit" id="dv_popup_listhighersearch_head" style="cursor:move">
        <strong class="D_ptita">{'CUSTOMIZESEARCH'|@getFixedLabel}</strong>
        <button class="D_ptitc" value="{'CLOSE'|@getFixedLabel}" id="dv_popup_listhighersearch_imgclose" style="cursor:pointer"/>
        </div>
    <table cellpadding="2" cellspacing="0" width="100%" align="center" border=0 style="background:#F4F4F4;">
		<tr>
			<td align="center" class="small" width='90%' style="vertial-align:bottom">
				{include file='AdvanceFilterNew.tpl' SOURCE='customview' COLUMNS_BLOCK=$FIELDNAMES}
			</td>
		</tr>
	</table>
	<div class="D_pbtn">  
        <input name="button" tag="btnok"  onClick="fun_setCrmPopupWindow.callSearch('Advanced');" class="D_pbtnok" value="{'FINDNOW'|@getFixedLabel}" type="button">
        <span>&nbsp;</span>
        <input class="D_pbtncancel" value='{"CANCEL"|@getFixedLabel}'  type="button" onclick="var popupobj=CrmPopup.getPopupObj('last');popupobj.CancelEvent();">
    </div>	

</div>

<script type="text/javascript" language="JavaScript">
	var menuback = '{$MENUBACK}';
	var menuhover = '{$MENUHOVER}';
	if(menuback != ''){
		ld('#crm_menu').css('background-color',menuback);
		ld('.Menu > ul > li.menu_on').css('background-color',menuhover);
	}
</script>