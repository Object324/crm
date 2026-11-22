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
    <li><a id="select_smslist" href="javascript:;" tag="tab_CommunicationLog" tabtype="smslist">{'SMSLISTQUERY'|@getFixedLabel}</a></li>
    <li class="ld-ui-tabs-active"><a id="select_smswork" href="javascript:;" tag="tab_CommunicationLog" tabtype="smswork">{'SMSJOBINQUIRIES'|@getFixedLabel}</a></li>
  </ul>
  {if 'oem_crm'|@getCommonVersion eq 'no'}
    <a class="rfloat" href="javascript:;" style="margin-right: 15px;margin-top: 15px;" onclick="getLinksUrl('{$TABID}','Module','ListView');" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>
  {/if}
</div>
<body>
<form id="smsworkLog" name="smsworkLog" method="post" onsubmit="puyoungJS_DialogBox.block()" ENCTYPE="multipart/form-data" action="index.php">
<input type='hidden' name="module" value="CommunicationLog"/>
<input type='hidden' name="action" value="index"/>
<input type='hidden' name="prioritysms" value="0"/>
<input type='hidden' name="type" value="smswork"/>
<input type="hidden" name="BatchIdAll" id="BatchIdAll" value=""/>
<table id="CL_Detial" class="searchTable" width="100%" cellspacing="0" cellpadding="0" border="0">
    <tbody>
        <tr>
          <td>
            <span>{'Delivery_time'|@getFixedLabel}</span>
            <span>
                <input id="begin_createdate" maxlength="25" name="begin_createdate" value="{$begin_createdate}" onClick="WdatePicker()" class="Wdate padL8" />
                <input id="b_begin_createdate" type="hidden" name="b_begin_createdate"/>
                
            </span>
            <span>{'TO'|@getFixedLabel}</span>
            <span>
                <input id="end_createdate" maxlength="25" name="end_createdate" value="{$end_createdate}" onClick="WdatePicker()" class="Wdate padL8" />
                <input id="bd_end_createdate" type="hidden" name="bd_end_createdate"/>
                
				<input type="hidden" name="typename" id="typename" value="0" />
            </span>
          </td>
		  <td>
            <span style="float: left;line-height: 30px;">{'Sender'|@getFixedLabel}</span>
            <span style="float: left;">
                <!-- <input class="input_text btn-radius-system" id="operator" name="operator" style="width:322px;" value="{$operator}" type="text" onclick="CommunicationLog_selectuser();" /> -->
                <div class="btn-radius-system lfloat overflow-space" id="operator" name="operator" style="width:322px;line-height: 30px;padding-left: 8px;background: #fff;margin-left: 3px;" onclick="CommunicationLog_selectuser();">{$operator}</div>
                <input id="recieverid" name="recieverid" type="hidden" value="{$recieverid}">
                <a class="icon-homeimg icon-select lfloat marT6" href="javascript:void(0);" title="{'SELECT'|@getFixedLabel}" onclick="CommunicationLog_selectuser();"></a>
            </span> 
            
            </td> 
            <td>
                <input class="ld-button ld-button-primary" id="btnOK_E" onclick="return formSmsworkLog();" type="submit" value="{'SEARCH'|@getFixedLabel}" />
            </td>
        </tr>
    </tbody>
</table>
</form>	

	
<div id="communcationlog_checksms">
{include file="modules/CommunicationLog/smsworkpaging.tpl"}

</div>

<div id="communicationdetial" class="layerPopup" id="CommunicationCheckDetail" style="display:none;width:65%;position:absolute;right:100px;z-index:9999999;">
    <table width="100%" border="0" cellpadding="3" cellspacing="0" class="layerHeadingULine">
    <tr>
    	<td class="layerPopupHeading" align="left" width="60%">{'View_Job_Details'|@getFixedLabel}</td>
    	<td>&nbsp;</td>
    	<td align="right" width="40%"><a class="icon-homeimg icon-close" href="javascript:;" title="{$APP.LBL_CLOSE}" onclick="$('communicationdetial').style.display ='none';"></a></td>
    </tr>
    </table>
<div id="Communication_form_div" >
    <table class="small" width="100%" cellspacing="0" cellpadding="0" border="0">
        <tbody>
            <tr style="height:25px">
                <td class="dvtCellLabel" width="25%" align="right" style="border-top-style: solid;
                border-top-width: 2px;border-top-color: #DEDEDE;">
                {'Theme'|@getFixedLabel}
                </td>
                <td id="Subject" class="dvtCellInfo" width="25%" align="left" width="25%" align="right" style="border-top-style: solid;
                border-top-width: 2px;border-top-color: #DEDEDE;">
                </td>
                <td class="dvtCellLabel" width="25%" align="right" width="25%" align="right" style="border-top-style: solid;
                border-top-width: 2px;border-top-color: #DEDEDE;">
                {'Job_number'|@getFixedLabel}
                </td>
                <td id="BatchNo" class="dvtCellInfo" width="25%" align="left" width="25%" align="right" style="border-top-style: solid;
                border-top-width: 2px;border-top-color: #DEDEDE;">
                </td>
            </tr>
            <tr style="height:25px">
                <td class="dvtCellLabel" width="25%" align="right">
                {'Sender'|@getFixedLabel}
                </td>
                <td id="Operator" class="dvtCellInfo" width="25%" align="left" >
                </td>
                <td class="dvtCellLabel" width="25%" align="right">
                {'Delivery_time'|@getFixedLabel}
                </td>
                <td id="Createtime" class="dvtCellInfo" width="25%" align="left" >
                </td>
            </tr>
            <tr style="height:25px">
                <td class="dvtCellLabel" width="25%" align="right">
                {'total_number'|@getFixedLabel}
                </td>
                <td id="AllCount" class="dvtCellInfo" width="25%" align="left" >
                </td>
                <td class="dvtCellLabel" width="25%" align="right">
                {'Copies_success'|@getFixedLabel}
                </td>
                <td id="SuccessCount" class="dvtCellInfo" width="25%" align="left" >
                </td>
            </tr>
    </tbody>
</table>
<table class="small" width="100%" cellspacing="0" cellpadding="0" border="0">
    <tbody>
     <tr style="height:45px">
         <td class="dvtCellLabel" width="25%"  align="right">
            {'SMS_content'|@getFixedLabel}
         </td>
         <td id="SmsContent" class="dvtCellInfo" width="75%" align="left" >  
         </td>
     </tr>
    </tbody>
</table>
<table class="small" width="100%" cellspacing="0" cellpadding="0" border="0">
    <tbody>
        <tr style="height:150px">
         <td class="dvtCellLabel" width="25%" align="right">
            {'Recipient_List'|@getFixedLabel}
         </td>
         <td id="Receive" class="dvtCellInfo" width="75%" align="left" >
             <span id="Receive"></span> 1121231           
         </td>
     </tr>
    </tbody>
</table></div>
</div>
<div id="tempdiv" style="display:block;position:absolute;left:350px;top:200px;"></div>
</body>


{literal}
<script>
 ld(function(){
       
      communcationtabClick();
    })
function getListViewEntries_js(module,url)
{   
    var startTime = document.getElementById('begin_createdate').value; 
    var endTime = document.getElementById('end_createdate').value;
    var operator=document.getElementById('operator').value;
    operator=encodeURIComponent(operator);  
    $("status").style.display="inline";
    new Ajax.Request(
            'index.php',
            {queue: {position: 'end', scope: 'command'},
                    method: 'post',
                    postBody: 'module=CommunicationLog&action=LogAjax&file=smswork&type=smswork&paging=1&'+url+'&pagechange=true&begin_createdate='+startTime+'&end_createdate='+endTime+"&operator="+operator,
                    onComplete: function(response) {
                            $("status").style.display="none";
                            $("communcationlog_checksms").innerHTML= response.responseText.split("#########:#")[1];
                    }
            }
    );
}
</script>
{/literal}
