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
{*
/*********************************************************************************
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/ *}
<!--修改编码格式:统一编码：UTF-8-->
{literal}
<script type="text/javascript">
function getModuleEntityNoInfo(form) {
	var module = form.selmodule.value;

	//$("status").style.display="inline";
    document.getElementById("status").style.display="inline"; 
	new Ajax.Request(
    	'index.php',
        {queue: {position: 'end', scope: 'command'},
        	method: 'post',
            postBody: 'module=Settings&action=SettingsAjax&file=CustomModEntityNo&ajax=true&selmodule=' + encodeURIComponent(module),
            onComplete: function(response) {
				//$("status").style.display="none";
                document.getElementById("status").style.display="none";    
				var restext = response.responseText;
				//$('customentity_infodiv').innerHTML = restext;
                document.getElementById('customentity_infodiv').innerHTML = response.responseText;
            }
        }
    );
}
//chj
function Change_CustomMod(obj){
	if(obj.value == 'none'){
		ld('#tr_reset').hide();
		ld('#tr_complement').hide();
		ld('#reset_value').val('no');
		ld('#reset_value').prop("checked",false);
		ld('#complement').val(0);
	}else{
		ld('#tr_reset').show();
		ld('#tr_complement').show();
	}
}
function click_resetvalue(obj)
{
    if(obj.checked)
    {
        obj.value='yes';
    }
    else
    {
        obj.value='no';
    }
}
//andy
function dataProfileChange(obj)
{
    if(obj.checked)
    {
        obj.value=1;
    }
    else
    {
        obj.value=0;
    }
}
//andy
function controllprefixtype(form){
    var prefixtype= form.prefixtype.options;
    for(var i=0;i<prefixtype.length;i++)
    {
        if(prefixtype[i].selected==true  )
        {
            prefixtype[i].selected.value
            if(prefixtype[i].value ==0){
                form.recprefix.style.display='';  
            }  
            else
            {
                form.recprefix.style.display='none';  
            }    
        }
    }
}
/*
change:kara
date:2013-05-31
reason:Not translate in English
Start sequence cannot be empty!
Start sequence should be numeric.
*/
function updateModEntityNoSetting(button, form) {
	var popupobj=CrmPopup.getPopupObj("last");
	var module = ld("#selmodule").val();
	var recprefix = ld("#recprefix").val();
	var recnumber = ld("#recnumber").val();
	var selecteddatetype = ld("#selectdatetype").val();
	var UseUserAccounts = ld("#UseUserAccounts").val();
	var prefixtype = ld("#prefixtype").val();
	var isallow = ld("#isallow").val();
	var reset_value = ld("#reset_value").val();
	var complement = ld("#complement").val();

    
    var mode = 'UPDATESETTINGS';

	if(recnumber == '') {
        var confirm_str = arrJsPopLabel['STARTINGNUMCANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return;
	}


    if(recnumber.match(/[^0-9]+/) != null) {
        var confirm_str = arrJsPopLabel['THEINTIALSEQUENCENUMBERSHOULDBEAPOSSITIVE'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return;
	}
	button.disabled = true;
	
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=CustomModEntityNo&ajax=true' + 
		'&selmodule=' + encodeURIComponent(module) +
		'&recprefix=' + encodeURIComponent(recprefix) +
		'&recnumber=' + encodeURIComponent(recnumber) +
		'&datetype=' + encodeURIComponent(selecteddatetype) +
		'&mode=' + encodeURIComponent(mode)+
		'&prefixtype=' + encodeURIComponent(prefixtype)+
		//'&prefixtype=' + encodeURIComponent(prefixtype),isallow
		'&isallow=' + encodeURIComponent(isallow)+
		'&UseUserAccount=' + encodeURIComponent(UseUserAccounts)+
		'&reset_value=' + encodeURIComponent(reset_value)+
		'&complement=' + encodeURIComponent(complement);
	ldAjax(surl,{},function(data){
		if(data.code==1){
			var confirm_str = data.result.log;
			// RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            MessagePopup.TipOne_success(confirm_str);
			DelProgressObjs();
			return false;
		}
	})
	
}
/*
change:kara
date:2013-05-31
reason:Not translate in English
Start sequence cannot be empty!
Start sequence should be numeric.
*/
function updateModEntityExisting(button, form) {
	var module = form.selmodule.value;
	var recprefix = form.recprefix.value;
    var recnumber = form.recnumber.value;

	var mode = 'UPDATEBULKEXISTING';

	if(recnumber == '') {
        var confirm_str = arrJsPopLabel['STARTINGNUMCANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return;
	}

	if(recnumber.match(/[^0-9]+/) != null) {
        var confirm_str = arrJsPopLabel['STARTINGNUMSHOULDNUMERIC'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return;
	}



    puyoungJS_DialogBox.progress();
	button.disabled = true;

	new Ajax.Request(
    	'index.php',
        {queue: {position: 'end', scope: 'command'},
        	method: 'post',
            postBody: 'module=Settings&action=SettingsAjax&file=CustomModEntityNo&ajax=true' + 
					'&selmodule=' + encodeURIComponent(module) +
					'&mode=' + encodeURIComponent(mode),

            onComplete: function(response) {
                puyoungJS_DialogBox.hideprogress();

				var restext = response.responseText;
				$('customentity_infodiv').innerHTML = restext;
            }
        }
    );
}
</script>
{/literal}

<form method="POST" action="javascript:;" onsubmit="puyoungJS_DialogBox.block();">
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_CUSTOMIZE_MODENT_NUMBER'|@getFixedLabel}
        </span>
        <span class="grid-view-choose dinline-block lfloat">{'SELECTMODULE'|@getFixedLabel}</span>
        <select fieldtype="select"  name="selmodule" id="selmodule" class="small btn-radius-system width150" onChange="getModuleEntityNoInfo(this.form)">
            {foreach key=sel_value item=value from=$MODULES}
                {if $SELMODULE eq $sel_value}
                    {assign var = "selected_val" value="selected"}
                {else}
                    {assign var = "selected_val" value=""}
                {/if}
                {assign var="MODULE_LABEL" value=$value|@getTranstab}
                <option value="{$sel_value}" {$selected_val}>{$MODULE_LABEL}</option>
                {/foreach}
        </select>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a id="mobile_maininfo_create" href="javascript:;" class="ld-button ld-button-primary" onclick="updateModEntityNoSetting(this, this.form);" title="{'SAVE'|@getFixedLabel}">{'SAVE'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div id="customentity_infodiv" class="cont_wrap clear_float">
            {include file="Settings/CustomModEntityNoInfo.tpl"}
        </div>
    </div>
</div>
</form>