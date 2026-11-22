{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
   * 更新操作
   * edit:diony
   * date:2013-11-14
   * reason:数据备份
  *
 ********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/backup.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/modules/Settings/Mask.js?v={$GLOBALMINVERSION}"></script>
{if $MODE neq 'edit'}
	<form action="index.php" method="post" name="Backup" onsubmit="puyoungJS_DialogBox.block();">
{else}
	{literal}
		<form action="index.php" method="post" name="Backup" onsubmit="if(validate(Backup)){ puyoungJS_DialogBox.block(); return true; } else { return false; }">
	{/literal}
{/if}
<input type="hidden" name='mode'/>
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="action" value="BackupSettings"/>
<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_BACKUP_SET'|@getFixedLabel}{if $HelpHtml.BackupSettings neq '' }{$HelpHtml.BackupSettings}{/if}<font>（{'MANUALBACKUP'|@getFixedLabel}）</font>
        </span>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            {if $MODE neq 'edit'}
	            <a href="javascript:;" class="ld-button ld-button-primary" onclick="BackupDataBase('newDiv');" title="{'BACKUPNOW'|@getFixedLabel}">{'BACKUPNOW'|@getFixedLabel}</a>
	            <a href="javascript:;" class="ld-button" onclick="showdownloadfilelist()" title="{'DOWNLOADBACKUPFILE'|@getFixedLabel}">{'DOWNLOADBACKUPFILE'|@getFixedLabel}</a>
			{else}
				<input type="hidden" name="savehand" value="savehand"/>
				<a href="javascript:;" class="ld-button ld-button-primary" onclick="SaveBackupSettings()" type="submit" title="{'SAVE'|@getFixedLabel}">{'SAVE'|@getFixedLabel}</a>
				<a href="javascript:;" class="ld-button ld-button-cancel" onclick="CancelBackupSettings()" title="{'CANCEL'|@getFixedLabel}">{'CANCEL'|@getFixedLabel}</a>
			{/if}
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div class="cont_wrap clear_float">
      		{if $MODE neq 'edit'}
  	    		<table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <th colspan="2">{'MANUALBACKUP'|@getFixedLabel}</th>
              </tr>
              <tr>
                <td width="20%">{'BACKUPFILEPATH'|@getFixedLabel}</td>
                <td width="80%">{$ROOTDIR}</td>                 
              </tr>
            </table>
      		{else}
            <table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <th colspan="2">{'MANUALBACKUP'|@getFixedLabel}</th>
              </tr>
              <tr>
                <td width="20%"><font color="red">*</font>&nbsp; {'BACKUPFILEPATH'|@getFixedLabel} </td>
                <td width="80%">
                  {*<input type="text" name="handbackup_path"  id="handbackup_path" readOnly value="{$ROOTDIR}" size="60"/>*}
                  {$ROOTDIR}
                  <input type="hidden" name="handbackup_path"  id="handbackup_path" value="{$ROOTDIR}" />
                </td>
              </tr>
            </table>
    			{/if}
          <div style="line-height:24px;color:#666;padding-left: 20px;" id="downloadfilehtml"></div>
          <div class="listRloesHelp">
            <font color="red">{'TIP'|@getFixedLabel}：</font>
            <ul>
                <li>{'NEWMANUALBACKUPMESSAGE'|@getFixedLabel}</li>
            </ul>
          </div>
        </div>
    </div>
</div>
</form>

<div id="divDownloadFileList" class="D_pop_box LdPopWidth600px" style="display:none;">
    <div id="divDownloadFileList_div" ></div>
</div>
<!--中间 end-->
<input type="hidden" id="os" value='{$OS}'/>
<script type="text/javascript">
var focusfld = "{$FOCUSFLD}";
{literal}
/*function editBackupSettings(){
  //  this.form.action.value='BackupSettings';
//    this.form.mode.value='edit';
    ldAjax("index.php?module=Settings&action=SettingsAjax&file=BackupSettings&mode=edit",{},function(data){
            var popupobj=CrmPopup.load(data.result.title,"","","LdPopWidth650px","Settings","",data.result.oktext,"",data.result.canceltext);
            CrmPopup.setPopupobjHtmlContent_scroll(popupobj,data.result.content);
    });
    
}*/

function BackupDataBase(newdiv){
    var popupobj = CrmPopup.load(arrJsPopLabel['REMINDER'],'','','LdPopWidth600px','Settings','','','','');
    var html = "<div style='text-align: center;padding: 20px 24px;'>"+arrJsPopLabel['BACKINGUPDATABASE']+"......</div>";
    popupobj.show(html);
    ldAjaxNoProgress("index.php?module=Settings&action=SettingsAjax&file=BackupSettings&mode=backup",{},function(data){
        popupobj.CancelEvent();
        ld('#downloadfilehtml').html(data.result.content);
    })
}
/**
 * 判断自动备份路径、手动备份路径不存在的话，返回编辑页面，并回传对应的文本框，默认光标在文本框中
 * @reason 0012419 数据备份编辑界面：当输入一个不存在的备份文件路径，保存后弹出提示信息中点击确定按钮后，应该返回数据备份编辑界面，光标定位在备份文件路径文本框
 * @author Tujt 2014-11-12
 */
if(focusfld != ''){
	document.Backup[focusfld].focus();
}

{/literal}
</script>