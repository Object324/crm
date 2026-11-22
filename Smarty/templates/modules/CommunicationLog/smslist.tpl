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
<div class="ld-ui-tabs">
  <ul class="ld-ui-tabs-nav">
    <li class="ld-ui-tabs-active"><a id="select_smslist" href="javascript:;" tag="tab_CommunicationLog" tabtype="smslist">{'SMSLISTQUERY'|@getFixedLabel}</a></li>
    <li><a id="select_smswork" href="javascript:;" tag="tab_CommunicationLog" tabtype="smswork">{'SMSJOBINQUIRIES'|@getFixedLabel}</a></li>
  </ul>
  {if 'oem_crm'|@getCommonVersion eq 'no'}
    <a class="rfloat" href="javascript:;" style="margin-right: 15px;margin-top: 15px;" onclick="getLinksUrl('{$TABID}','Module','ListView');" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>
  {/if}
</div>
<body>
<form id="smslistLog" name="smslistLog" method="post" onsubmit="puyoungJS_DialogBox.block()" ENCTYPE="multipart/form-data" action="index.php">
<input type='hidden' name="module" value="CommunicationLog"/>
<input type='hidden' name="action" value="index"/>
<input type='hidden' name="type" value="smslist"/>
<input type='hidden' name="prioritysms" value="0"/>
<input type="hidden" name="BatchIdAll" id="BatchIdAll" value="" />
<input type="hidden" name="down" id="down" value="down"/>
<table id="CL_Detial" class="searchTable" width="100%" cellspacing="0" cellpadding="0" border="0">
    <tbody>
        <tr>
          <td>
            <span>{'Delivery_time'|@getFixedLabel}</span>
            <span>
                <input id="begin_createdate" maxlength="25" name="begin_createdate" value="{$begin_createdate}" onClick="WdatePicker()" class="Wdate padL8" />
                <input id="c_begin_createdate" type="hidden" name="c_begin_createdate"/>
              
            </span>
            <span>{'TO'|@getFixedLabel}</span>
            <span>
                <input id="end_createdate" maxlength="25" name="end_createdate" value="{$end_createdate}" onClick="WdatePicker()" class="Wdate padL8" />
                <input id="c_end_createdate" type="hidden" name="c_end_createdate"/>
               
            </span>
          </td>
          <td>
            <span style="float: left;line-height: 30px;">{'Sender'|@getFixedLabel}</span>
            <span style="float: left;">
                <!-- <input class="input_text btn-radius-system" id="operator" name="operator" style="width:322px;" value="{$operator}" type="text" onclick="CommunicationLog_selectuser();" /> -->
                <div class="btn-radius-system lfloat overflow-space" id="operator" name="operator" style="width:322px;line-height: 30px;padding-left: 8px;background: #fff;margin-left: 3px;" onclick="CommunicationLog_selectuser();">{$operator}</div>
                <input id="recieverid" name="recieverid" type="hidden" value="{$recieverid}"/>
                <a class="icon-homeimg icon-select lfloat marT6" href="javascript:void(0);" title="{'SELECT'|@getFixedLabel}" onclick="CommunicationLog_selectuser();"></a>
            </span> 
          
          </td>
        </tr>
        <tr>
          <td>
            <span>{'Content'|@getFixedLabel}</span>
            <span>
                <input class="input_text btn-radius-system" id="smsContent" name="smsContent" style="width:322px;" value="{$smsContent}" type="text" />
            </span>
          </td>
          <td>
            <span>{'Recipient'|@getFixedLabel}</span>
            <span>
                <input class="input_text btn-radius-system" id="receiveContacts" name="receiveContacts" style="width:322px;" value="{$receiveContacts}" type="text" />
            </span>
          </td>
        </tr>
        <tr>
          <td>
            <span>{'Number'|@getFixedLabel}</span>
            <span>
                <input class="input_text btn-radius-system" id="calledNumber" name="calledNumber" style="width:322px;" value="{$calledNumber}" type="text" />
            </span>
          </td> 
          <td>
                <span style="padding-right: 13px;">{'STATUS'|@getFixedLabel}</span>
                <span>
                    <!--<input class="input_text" id="smsResultName" name="smsResultName" style="width:82%;" value="{$smsResultName}" type="text" />-->
                    {if $smsResultName eq "1"}
                    <select class="input_text btn-radius-system" id="smsResultName" name="smsResultName">
                        <option value="2">{'ALL'|@getFixedLabel}</option>
                        <option value="-1">{'To_be_submitted'|@getFixedLabel}</option>
                        <option value="1" selected="ture">{'Sent_successfully'|@getFixedLabel}</option>
                        <option value="0">{'Failed_to_send'|@getFixedLabel}</option>
                    </select>
                    {elseif $smsResultName eq "0"}
                    <select class="input_text btn-radius-system" id="smsResultName" name="smsResultName">
                        <option value="2">{'ALL'|@getFixedLabel}</option>
                        <option value="-1">{'To_be_submitted'|@getFixedLabel}</option>
                        <option value="1">{'Sent_successfully'|@getFixedLabel}</option> 
                        <option value="0" selected="ture">{'Failed_to_send'|@getFixedLabel}</option>
                    </select>
                    {elseif $smsResultName eq "-1"}
                    <select class="input_text btn-radius-system" id="smsResultName" name="smsResultName">
                        <option value="2">{'ALL'|@getFixedLabel}</option>
                        <option value="-1" selected="ture">{'To_be_submitted'|@getFixedLabel}</option>
                        <option value="1">{'Sent_successfully'|@getFixedLabel}</option> 
                        <option value="0">{'Failed_to_send'|@getFixedLabel}</option>
                    </select>
                    {elseif $smsResultName eq "2"}
                    <select class="input_text btn-radius-system" id="smsResultName" name="smsResultName" >
                        <option value="2" selected="ture">{'ALL'|@getFixedLabel}</option>
                        <option value="-1">{'To_be_submitted'|@getFixedLabel}</option>
                        <option value="1">{'Sent_successfully'|@getFixedLabel}</option>
                        <option value="0">{'Failed_to_send'|@getFixedLabel}</option>
                    </select>
                    {else}
                    <select class="input_text btn-radius-system" id="smsResultName" name="smsResultName" >
                        <option value="2" selected="ture">{'ALL'|@getFixedLabel}</option>
                        <option value="-1">{'To_be_submitted'|@getFixedLabel}</option>
                        <option value="1">{'Sent_successfully'|@getFixedLabel}</option>
                        <option value="0">{'Failed_to_send'|@getFixedLabel}</option>
                    </select>
                    {/if}
                </span>
				<input type="hidden" name="typename" id="typename" value="0" />
                <input class="ld-button ld-button-primary" id="btnOK_E" onclick="return formSmslistLog();" type="submit" value="{'SEARCH'|@getFixedLabel}"/>
            </td>
        </tr>
    </tbody>
</table>
</form>	
<div id="communcationlog_checksms">

{include file="modules/CommunicationLog/smslistpaging.tpl"}

</div>



<div style="display: none;" class="D_pop_box LdPopWidth400px" id="CL_empty_conf_id">
	<div class="D_pop_tit">
        <strong class="D_ptita">{'CELARALL'|@getFixedLabel}</strong>
        <a class="D_ptitc" href="javascript:fninvshnew('CL_empty_conf_id');">
    		<img src="themes/icon/pop_close.png" class="D_ptitcimg" alt="{'CLOSE'|@getFixedLabel}" />
    	</a>
	</div>
   <table cellspacing="1" cellpadding="1" border="0" class="D_pop_bod">
       <tr style="height:40px;">
        <td>
    		{'ARYSYWTPDDD'|@getFixedLabel}？
        </td>
      </tr>
    </table>
    <div class="D_pbtn">
        <input type="button" class="D_pbtnok" onclick="return emptyAll('smslist');" value="{'CONFIRMED'|@getFixedLabel}"/><span>&nbsp;</span>  
	    <input type="button" class="D_pbtncancel" onclick="fninvshnew('CL_empty_conf_id');" value="{'CANCEL'|@getFixedLabel}"/>   
    </div>	
</div>

<div id="tempdiv" style="display:block;position:absolute;left:350px;top:200px;"></div>
{literal}
<script>
ld(function(){
    communcationtabClick();
})
function getListViewEntries_js(module,url)
{
    var startTime = document.getElementById('begin_createdate').value; 
    var endTime = document.getElementById('end_createdate').value;
    //BUG0063772	zxm20230329 	kfbcrm 短信记录----翻页到最后一页时----会有重复的表头
    ld('#rptContentLoading').hide();
    var surl = "index.php?module=CommunicationLog&action=LogAjax&file=smslist&type=smslist&paging=1&"+url+'&begin_createdate='+startTime+'&end_createdate='+endTime;
    ldAjaxHtml(surl,"",function(data){
        ld('#rptContentLoading').hide();
        ld("#communcationlog_checksms").html(data.split("#########:#")[1]);
        //短信列表错误tips，翻页后这里需要重新加载
        ld('.icon-tipsimg').tooltip({align: 'bottom'});
    });
    /*new Ajax.Request(
            'index.php',
            {queue: {position: 'end', scope: 'command'},
                    method: 'post',
                    postBody: 'module=CommunicationLog&action=LogAjax&file=smslist&type=smslist&paging=1&'+url+'&begin_createdate='+startTime+'&end_createdate='+endTime,
                    onComplete: function(response) {
                        ld('#rptContentLoading').hide();
                        $("communcationlog_checksms").innerHTML= response.responseText.split("#########:#")[1];
                        //短信列表错误tips，翻页后这里需要重新加载
                        ld('.icon-tipsimg').tooltip({align: 'bottom'});
                    }
            }
    );*/
}
//短信列表错误tips
ld('.icon-tipsimg').tooltip({align: 'bottom'});
</script>
{/literal}
