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
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/smoothscroll.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/menu.js"></script>
<script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/ueditor/ueditor.config.js"></script>
<script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/ueditor/ueditor.all.js"></script>

<script language="JavaScript" type="text/javascript">
    var allOptions = null;

    function setAllOptions(inputOptions) 
    {ldelim}
        allOptions = inputOptions;
    {rdelim}

    function modifyMergeFieldSelect(cause, effect) 
    {ldelim}
        var selected = cause.options[cause.selectedIndex].value;  id="mergeFieldValue"
        var s = allOptions[cause.selectedIndex];
        effect.length = s;
        for (var i = 0; i < s; i++) 
	{ldelim}
            effect.options[i] = s[i];
        {rdelim}
        document.getElementById('mergeFieldValue').value = '';
    {rdelim}
{literal}
    function init() 
    {
        var blankOption = new Option('--无--', '--无--');
        var options = null;
{/literal}

		var allOpts = new Object({$ALL_VARIABLES|@count}+1);
		{assign var="alloptioncount" value="0"}
		{foreach key=index item=module from=$ALL_VARIABLES}
	    	options = new Object({$module|@count}+1);
	    	{assign var="optioncount" value="0"}
            options[{$optioncount}] = blankOption;
            {foreach key=header item=detail from=$module}
             {assign var="optioncount" value=$optioncount+1}
				options[{$optioncount}] = new Option('{$detail.0}', '{$detail.1}');
			{/foreach}      
			 {assign var="alloptioncount" value=$alloptioncount+1}     
             allOpts[{$alloptioncount}] = options;
	    {/foreach}
        setAllOptions(allOpts);	    
    }
	
	

	
{literal}
	function cancelForm(frm)
	{
		frm.action.value='detailviewemailtemplate';
		frm.parenttab.value='Marketing';
		frm.submit();
	}
{/literal}
</script>
<link href="themes/softed/Control.css" rel="stylesheet" type="text/css" />

<form action="index.php" method="post" name="templatecreate" class="template_ajaxform">
  <input type="hidden" name="mode" value="{$EMODE}"/>
  <input type="hidden" name="module" value="EmailListtmp"/>
  <input type="hidden" name="templateid" value="{$TEMPLATEID}"/>
  <input type="hidden" name="parenttab" value="{$PARENTTAB}"/> 
  
  <table class="ld-public-content" border="0" cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="ld-form-item-label"><font color="red">*</font>{'TEMPLATENAME'|@getFixedLabel}</td>
			<td class="ld-form-item-content"><input name="templatename" tag="{'TEMPLATENAME'|@getFixedLabel}" type="text" value="{$TEMPLATENAME}" class="ld-input-inner" tabindex="1"></td>
		  </tr>
		<tr>
			<td class="ld-form-item-label">{'DESCRIPTION'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
			  <input name="description" type="text" value="{$DESCRIPTION}" class="ld-input-inner" tabindex="2">
			</td>
		</tr>
	<tr>
		<td class="ld-form-item-label">{'MAILFOLDER'|@getFixedLabel}</td>
		<td class="ld-form-item-content">
  		{if $EMODE eq 'edit'}
        <select name="foldername" tabindex="" class="ld-select-inner" style="width:30%" tabindex="3">
          {foreach item=arr from=$FOLDERNAME}
            <option value="Personal" {if $FOLDERNAME eq 'Personal'}selected{/if}>{'Private'|@getFixedLabel}</option>
            <option value="Public" {if $FOLDERNAME eq 'Public'}selected{/if}>{'BETOVIEWABLE'|@getFixedLabel}</option>
          {/foreach}
        </select>
  		{else}
        <select name="foldername" tabindex="" value="{$FOLDERNAME}" class="ld-select-inner" style="width:30%" tabindex="3">
          <option value="Personal">{'Private'|@getFixedLabel}</option>
          <option value="Public" selected>{'BETOVIEWABLE'|@getFixedLabel}</option>
        </select>
  		{/if}
		</td>
	  </tr>
    <tr>
      <td class="ld-form-item-label">{'Content'|@getFixedLabel}</td>
      <td class="ld-form-item-content" style="max-height: 300px;">
        <script id="emailbody" name="emailbody" type="text/plain" style="height:100px;width:100%;">{$BODY}</script>
      </td>
    </tr>
    <tr>
      <td class="ld-form-item-content gray" colspan="2">{'WILDCARDCUSTNAME'|@getFixedLabel}{ldelim}comname{rdelim};{'CONTACTNAME'|@getFixedLabel}{ldelim}name{rdelim};{'CONTACTAPPELLATION'|@getFixedLabel}{ldelim}app{rdelim}</td>
    </tr>
  </table>
</form>

<script>

function check4null(form)
{ldelim}

        var isError = false;
        var errorMessage = "";
        // Here we decide whether to submit the form.
        if (trim(form.templatename.value) =='') {ldelim}
                isError = true;
                errorMessage += "\n {'TEMPLATENAME'|@getFixedLabel}";
                form.templatename.focus();
        {rdelim}
        if (trim(form.foldername.value) =='') {ldelim}
                isError = true;
                errorMessage += "\n {'MAILFOLDER'|@getFixedLabel}";
                form.foldername.focus();
        {rdelim}
        /*if (trim(form.subject.value) =='') {ldelim}
                isError = true;
                errorMessage += "\n {'MAILTITLE'|@getFixedLabel}";
                form.subject.focus();
        {rdelim}*/

        // Here we decide whether to submit the form.
        if (isError == true) {ldelim}
                var confirm_str = errorMessage + arrJsPopLabel['CANOTEMPTYGTH'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                return false;
        {rdelim}
 return true;

{rdelim}

init();

</script>