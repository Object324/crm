<!--修改编码格式:统一编码：UTF-8-->
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js"></script>
<link href="themes/softed/Control.css" rel="stylesheet" type="text/css" />
{literal}
<form action="index.php" method="post" name="templatecreate" onsubmit="if(check4null(templatecreate)) { puyoungJS_DialogBox.block(); } else { return false; }">
{/literal}
  <input type="hidden" name="module" value="SmsPhrases"/>
  <input type="hidden" name="action"/>
  <input type="hidden" name="parenttab"/>
  <input type="hidden" name="mode" value="{$MODE}"/>
  <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
  <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
  <input type="hidden" name="templateid" value="{$TEMPLATEID}"/> 
  <table class="ld-public-content-paddingright padTB10" border="0" cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="ld-form-item-label"><font color="red">*</font>{'TEMPLATENAME'|@getFixedLabel}</td>
			<td class="ld-form-item-content"><input name="templatename" type="text" value="{$TEMPLATENAME}" class="ld-input-inner" tabindex="1"></td>
		</tr>
		<tr>
			<td class="ld-form-item-label"><font color="red">*</font>{'MESSCATEGORY'|@getFixedLabel}</td>
			<td class="ld-form-item-content"><input type="radio" value="ordinary" name="template_type" {if $TEMPLATE_TYPE eq 'ordinary' || $TEMPLATE_TYPE eq ''}checked{/if}>&nbsp;{'plainsms'|@getFixedLabel}&nbsp;&nbsp;&nbsp;&nbsp;<input type="radio" value="marketing" name="template_type" {if $TEMPLATE_TYPE eq 'marketing'}checked{/if}>&nbsp;{'SMS_Marketing'|@getFixedLabel}</td>
		</tr>
		<tr>
	    <td class="ld-form-item-label"><font color="red">*</font>{'Content'|@getFixedLabel}</td>
      <td class="ld-form-item-content"><textarea name="body" class="ld-textarea-inner" style="height:200px;" tabindex="5">{$BODY}</textarea></td>
		</tr>
    <tr>
      <td class="ld-form-item-label"></td>
      <td class="ld-form-item-content">
        {'WILDCARDCUSTNAME'|@getFixedLabel}{ldelim}comname{rdelim}；{'CustomerTelephone'|@getFixedLabel}{ldelim}comphone{rdelim}；{'CONTACTNAME'|@getFixedLabel}{ldelim}name{rdelim}；{'CONTACTAPPELLATION'|@getFixedLabel}{ldelim}app{rdelim}；{'SalesManName'|@getFixedLabel}{ldelim}salesman{rdelim}；{'SalesManMobile'|@getFixedLabel}{ldelim}salesmanmobile{rdelim}</td>
    </tr>
  </table>
</form>

{literal}
<script>
function check4null(obj){
  if(obj.templatename.value==""){
    var confirm_str = arrJsPopLabel['TEMPLATENAMECANOTEMPTY'];
    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
    return false;
  }
  return true;
}
</script>
{/literal}