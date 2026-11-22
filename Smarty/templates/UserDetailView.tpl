{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/menu.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/EditView.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/ColorPicker2.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/dtlviewajax.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<script src="{$CRMCOMMONURL}crmcommon/js/scriptaculous/scriptaculous.js" type="text/javascript"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/smoothscroll.js"></script>
<span id="crmspanid" class="ld-detail-edit-small" style="display:none;" onmouseover="show('crmspanid');">
   <i class="ld-fonticon ld-fonticon-edit" title="{'EDIT'|@getFixedLabel}"></i>
</span>
{if $CATEGORY neq 'Settings'}
<link href="themes/softed/Control.css" rel="stylesheet" type="text/css" />
{/if}
<!--中间-->
<div class="List3Box">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
    
    {if $CATEGORY eq 'Settings' && $BLOCKIDSETTING > 0 && $FIELDIDSETTING > 0}
    <td class="TdLeft" valign="top" style="width:200px;">
	   {include file='SetMenuNew.tpl'}
    </td>
    {/if}
    
    <td class="Tdcenter" valign="top" style="padding: 0 15px;">
    <form name="DetailView" method="POST" action="index.php" ENCTYPE="multipart/form-data" id="form" style="margin:0px" onsubmit="puyoungJS_DialogBox.block();">
		<input type="hidden" name="module" value="Users"/>
		<input type="hidden" name="record" id="userid" value="{$ID}"/>
		<input type="hidden" name="isDuplicate" value="false"/>
		<input type="hidden" name="action" />
		<input type="hidden" name="changepassword" />
		{if $CATEGORY neq 'Settings'}
			<input type="hidden" name="modechk" value="prefview" />
		{/if}
		<input type="hidden" name="old_password" />
		<input type="hidden" name="new_password" />
		<input type="hidden" name="return_module" value="Users" />
		<input type="hidden" name="return_action" value="ListView"  />
		<input type="hidden" name="return_id" />
		<input type="hidden" name="forumDisplay" />
		<input type="hidden" name="hour_format" id="hour_format" value="{$HOUR_FORMAT}" />
		<input type="hidden" name="start_hour" id="start_hour" value="{$START_HOUR}" />
		<input type="hidden" name="form_token" value="{$FORM_TOKEN}">
		{if $CATEGORY eq 'Settings'}
		<input type="hidden" name="parenttab" value="{$PARENTTAB}" />
		{/if}
        <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
        <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
      <div class="DivCR">       
         <div class="ControlDiv1">
            <span class="Url fontbold">
            {if $CATEGORY eq 'Settings'}
			{if $BLOCKIDSETTING > 0 && $FIELDIDSETTING > 0}
				{'CONTROLPANEL'|@getFixedLabel} &gt; 
			{/if}
            <a href="index.php?module=Administration&action=index&parenttab=Settings&blockidsetting={$BLOCKIDSETTING}&fieldidsetting={$FIELDIDSETTING}"> {'LBL_USERS'|@getFixedLabel} </a>&gt;
            "{$USERNAME}" 
            
			{else}
		      {'PERSONALSETTINGS'|@getFixedLabel}
			{/if}
			<span id="vtbusy_info" style="display:none;" valign="bottom"><img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" border="0" /></span>
            </span>
        </div>
        <div class="ControlDiv2">
        	<div class="F_l">{'VIEWINFOABOUTUSERS'|@getFixedLabel}"{$USERNAME}"</div>
         <div class="F_r">   
         <!-- 返回列表传入seeeion=1，从session中读取查询条件 zyh 20150429 -->
              <!--{if $IS_ADMIN eq 'true'}
                 input type="button" onclick="showAuditTrail();" value="{'VIEWAUTIDTRAIL'|@getFixedLabel}" class="editauto b_radius3"/>
                 {/if}-->
          			{if $isPermitted == 'yes'}
          				<input type="button" value="{'BACKTOLIST'|@getFixedLabel}" title="{'BACKTOLIST'|@getFixedLabel}" class="editauto b_radius3" onClick = "window.location.href='index.php?module={$CURRENTMODULE}&action=index&parenttab={$PARENTTAB}&blockidsetting={$BLOCKIDSETTING}&fieldidsetting={$FIELDIDSETTING}&query_session=1';"/>
          			{/if}
          			{$DUPLICATE_BUTTON}
          			{$EDIT_BUTTON}
          			{if $ID neq 1 && $ID neq $CURRENT_USERID}
          				<input type="button" onclick="deleteUser(this,{$ID});" class="deleteauto b_radius3" value="{'DELETE'|@getFixedLabel}"/>
          			{/if}
            </div>
        </div>
        <div class="pad10" >
            <table width="100%" border="0" cellpadding="0" cellspacing="0" >
            	
            	<tr>
            		<td colspan="2" align=left>
            		<!-- User detail blocks -->
            	{assign var=list_numbering value=1}
            			{foreach key=header  item=detail from=$USERBLOCKS}
                      
            			<div class="TitleHeading noborderB" style="margin-top:20px;">
            				{strip}
            				 {$list_numbering++}. {$header}{$header|@getBlockInfoForLinks:'detailview'}
            				{/strip}
            			</div>
                        {if $MODULE eq 'Users' && $header eq '附件'}
                        <table border="0" cellpadding="0" cellspacing="0" width="100%">
                        {else}
                        <table class="DetailContentTable" border="0" cellpadding="0" cellspacing="0" width="100%">
                        {/if}
            			{foreach item=details from=$detail name=blockforeach}
            			<tr >
            				{foreach key=label item=data from=$details}
            				   {assign var=keyid value=$data.ui}
            				   {assign var=keyval value=$data.value}
                               {assign var=rawvalue value=$data.rawvalue}
            				   {assign var=keytblname value=$data.tablename}
            				   {assign var=keyfldname value=$data.fldname}
            				   {assign var=keyfldid value=$data.fldid}
            				   {assign var=keyoptions value=$data.options}
            				   {assign var=keysecid value=$data.secid}
            				   {assign var=keyseclink value=$data.link}
            				   {assign var=keycursymb value=$data.cursymb}
            				   {assign var=keysalut value=$data.salut}
            				   {assign var=keycntimage value=$data.cntimage}
            				   {assign var=keyadmin value=$data.isadmin}
								{*zxm 20211230字段颜色 字段说明样式*}
								{assign var=fieldvaluecolor value=$data.fieldvaluecolor}
								{assign var=fieldplaceholder value=$data.fieldplaceholder}
								{assign var=ShowHyperlinks value=$data.ShowHyperlinks}
								{assign var = BUSINESSQUERY value = $data.businessquery}{* 是否为工商查询字段 *}
								{assign var = ENABLEBUSINESS value = $data.isenablebusiness}{* 是否启用工商查询 *}
								{assign var = BUSINESSFUZZYQUERY value = $data.isenablebusinessfuzzyquery}{* 是否启用工商模糊查询 *}
            				   {if $label neq ''}
            				   {if $label eq 'ddLevel'}
            				   <td class="DetailedTd1Label" align=right width=25%><input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>职位级别</td>
            				   {elseif $label eq '审批人'}
            				   <td class="DetailedTd1Label" align=right width=25%><input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>审批委托人</td>
            				   {elseif $label eq 'Approvestatus'}
            				   <td class="DetailedTd1Label" align=right width=25%><input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>审批委托</td>
            				   <!--附件子菜单不显示 PROT197  20150420 zyh-->
                               {elseif $MODULE eq 'Users' && $label eq '附件'}
            				   <td id="RelatedContent" style="display:none" colspan="2"></td>
            				   {else}
            				   <td class="DetailedTd1Label" align=right width=25%><input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>{$label}</td>
            				   {/if}
            				   {*<!--edit:can reason:5752: 建议：个人设置页面：“职位级别”、“允许查看客户全景”这2个字段应该只有管理员用户能够编辑修改，非管理员用户应该不允许编辑-->*}
            					{if ($alloweditpage eq 'no' || ($keyfldname eq 'accountallview'||$keyfldname eq 'level')&&$IS_ADMIN eq false)}
            						 {if $keyfldname eq 'level'}
            								{if $keyval eq '0'}
            									{assign var='keyval' value='普通用户'}   
            								{elseif $keyval eq '1'}
            								   {assign var='keyval' value='总经理'}   
            								{elseif $keyval eq '2'}
            									{assign var='keyval' value='副总经理'}   
            								{/if}
            						 {/if}
            						{include file="DetailNoEdit.tpl"}
            					  {else}
            						{include file="DetailViewUI.tpl"}
            					{/if}
            				
            				   {else}
            				   
            				   {/if}
            				{/foreach}
            			</tr>
            			{/foreach}
            			</table>
            			
            			{/foreach}
            
            	            
            		<table border="0" cellpadding="5" cellspacing="0" width="100%">
        			<tr><td align="left"><div id="user_group_cont" style="display:none;"></div></td></tr>
        			</table>
        		</td>
        		</tr>
      		  </table>
        </div>         
                 
      </div>
      </form>		
    </td>
  </tr>
</table>
</div>
<!--中间 end-->

{$JAVASCRIPT}

<div id="tempdiv" style="display:block;top:200px;"></div>
<div id="changepw" class="D_pop_box LdPopWidth350px" style="display:none;position:absolute;left:350px;top:200px;z-index:1102;"></div>
<!-- added for validation -->
<script language="javascript">
  var gVTModule = '{$smarty.request.module|@vtlib_purify}';
  var fieldname = new Array({$VALIDATION_DATA_FIELDNAME});
  var fieldlabel = new Array({$VALIDATION_DATA_FIELDLABEL});
  var fielddatatype = new Array({$VALIDATION_DATA_FIELDDATATYPE});
function ShowHidefn(divid)
{ldelim}
	if($(divid).style.display != 'none')
		Effect.Fade(divid);
	else
		Effect.Appear(divid);
{rdelim}
{literal}
function fetchlogin_js(id)
{
	if($('login_history_cont').style.display != 'none')
		Effect.Fade('login_history_cont');
	else
		fetchLoginHistory(id);

}
function fetchLoginHistory(id){
  new Ajax.Request('index.php', {
    queue: {position: 'end', scope: 'command'},
    method: 'post',
    postBody: 'module=Users&action=UsersAjax&file=ShowHistory&ajax=true&record='+id,
    onComplete: function(response) {
      $("login_history_cont").innerHTML= response.responseText;
      Effect.Appear('login_history_cont');
    }
  });
}
function fetchGroups_js(id)
{
	if($('user_group_cont').style.display != 'none')
		Effect.Fade('user_group_cont');
	else
		fetchUserGroups(id);
}
function fetchUserGroups(id){
  new Ajax.Request('index.php',{
    queue: {position: 'end', scope: 'command'},
    method: 'post',
    postBody: 'module=Users&action=UsersAjax&file=UserGroups&ajax=true&record='+id,
    onComplete: function(response) {
      $("user_group_cont").innerHTML= response.responseText;
      Effect.Appear('user_group_cont');
    }
  });
}

function showAuditTrail()
{
	var userid =  document.getElementById('userid').value;
	window.open("index.php?module=Settings&action=SettingsAjax&file=ShowAuditTrail&userid="+userid,"","width=650,height=800,resizable=0,scrollbars=1,left=100");
}

ld(function(){
    var recordid = document.getElementById('userid').value;
    getUserAttachment(recordid,'Attachment',1);
})
{/literal}
</script>
<script>
function getListViewEntries_js(module,url)
{ldelim}
  new Ajax.Request(
  	'index.php',
      {ldelim}queue: {ldelim}position: 'end', scope: 'command'{rdelim},
      	      method: 'post',
              postBody:"module="+module+"&action="+module+"Ajax&file=ShowHistory&record={$ID}&ajax=true&"+url,
              onComplete: function(response) {ldelim}
                      $("login_history_cont").innerHTML= response.responseText;
        	{rdelim}
      {rdelim}
  );
{rdelim}

 function selectdelectid(selectView){ldelim}
    var viewid =  encodeURIComponent(selectView.options[selectView.options.selectedIndex].value);
    document.getElementById("selectuserid").value=viewid;
 {rdelim}
</script>
<script type='text/javascript' language='JavaScript'>
{literal}
function set_password(form) {
/**
 * @by andy
 * @reason 0008213: 非管理员：个人设置界面，修改密码，当用户的旧密码为空时，无法修改密码系统提示：请输入您的旧密码!
 * @date 20140527
 * @others NONE
*/
	//if (form.is_admin.value == 1 && trim(form.old_password.value) == "") {
	//	alert(arrJsPopLabel['ENTEROLDPASSWORD']);
	//	return false;
	//}
	if (trim(form.new_password.value) == "") {
		var confirm_str = arrJsPopLabel['ENTERNEWPASSWORD'];
    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
	if (trim(form.confirm_new_password.value) == "") {
		var confirm_str = arrJsPopLabel['ENTERNEWPASSWORDAGAIN'];
    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
    var formname=document.forms['ChangePassword'];
	if (trim(form.new_password.value) == trim(form.confirm_new_password.value)) {
		if (form.is_admin.value == 1) document.DetailView.old_password.value = encodeURIComponent(form.old_password.value);
		document.DetailView.new_password.value = encodeURIComponent(form.new_password.value);
		document.DetailView.return_module.value = 'Users';
		document.DetailView.return_action.value = 'DetailView';
		document.DetailView.changepassword.value = 'true';
		document.DetailView.return_id.value =document.DetailView.record.value;
		document.DetailView.action.value = 'Save';
		document.DetailView.submit();
		return true;
       
	}
	else {
		var confirm_str = arrJsPopLabel['PASSWORDINCONSISTENT'];
    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
}

IsFrameElement();
{/literal}
</script>