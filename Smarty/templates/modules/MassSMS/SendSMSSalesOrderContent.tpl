<!--修改编码格式:统一编码：UTF-8-->
<form name="sendInfoSMSContentForm" method="post" action="index.php">
    <input type="hidden" name="module" value="MassSMS"/>
    <input type="hidden" name="action" value="SendSMSSalesOrder"/>
    <input type="hidden" name="parenttab" value="Marketing">
    <input type="hidden" name="contenttype" id="contenttype" value="{$SMSTYPE}">
    <input type="hidden" name="salesorderid" id="salesorderid" value="{$SALESORDERID}">

    <div class="D_pop_tit">
    	<strong class="D_ptita">{'SETSMSCONTENT'|@getFixedLabel}</strong>
        <a href="javascript:closeAndOpenDiv('divSendSMSSalesOrder_SMSContent','divSendSMSSalesOrder')" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
	<table class="D_pop_bod_SMSContent" width="100%" align="center" cellspacing="1" cellpadding="2" border="0">
      <tr>
		<td align="center" valign="middle" >{'VARIABLEINFORMATION'|@getFixedLabel}</td>
		<td>
            {'PLEASEPASSTHEFOLLOWINGOPTIONS'|@getFixedLabel}
        	<table border="0" cellspacing=0 cellpadding=0 class="small" >
                <tr>
                    <td style="border: 0px solid #EAEAEA;">
                        <select id="moduleSelID" name="moduleSelID" onchange="moduleSel(this)">
                            <!--<option value="0">请选择相关模块</option>-->
                            {foreach item=tablabel key=tabid from=$PRINTTABS}
                                {if $tabid == '14'}
                                <option value="{$tabid}"  selected="true">{$tablabel}</option>
                                {else}
                                <option value="{$tabid}">{$tablabel}</option>
                                {/if}
                            {/foreach}
                        </select>
                    </td>
                    <td style="border: 0px solid #EAEAEA;">
                        <div id="tabField">
                            <select onchange="fieldSel(this)"><option>{'PLEASESELECTFIELD'|@getFixedLabel}</option></select>
                        </div>
                        
                    </td>
                    <td style="border: 0px solid #EAEAEA;">
                        <input  type="text" name="selField" id="selField" />
                    </td>
                    <td style="border: 0px solid #EAEAEA;">
                        <input  type="button"  class="createauto" value="{'INSERTEDINTOTHECONTENTTEMPLATE'|@getFixedLabel}" onclick="InsertTemplate(this)"/>
                    </td>
                </tr>
            </table>
        </td>
 	  </tr>
      <tr>
    		<td align="center" valign="middle" >{'SPECIALFUNCTIONS'|@getFixedLabel}</td>
    		<td>
                {'SEX'|@getFixedLabel}：IDFUNCTION(cf_1792)，cf_1792：{'IDNUMBERFIELD'|@getFixedLabel}<br/>
                {'WEATHERFORECAST'|@getFixedLabel}：CITYWEATHERFUNCTION(sf23)，sf23：{'CITYNEEDFORECASTWEATHER'|@getFixedLabel}<br/>
                {'WEATHERFORECASTNOTES'|@getFixedLabel}<br/>
            </td>
      </tr>
      <tr>
    		<td align="center" valign="middle" >{'ACONTENTTEMPLATE'|@getFixedLabel}</td>
    		<td class="divRecipientContent">
                <textarea cols="90" rows="8" id="CKcontent" name="CKcontent">{$CONTENT}</textarea></td>
      </tr>
    </table>
    <div class="D_pbtn">
    	<input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="SaveSalesOrderSMSContent(this)"/><span>&nbsp;</span>
        <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="closeAndOpenDiv('divSendSMSSalesOrder_SMSContent','divSendSMSSalesOrder');"/> 
    </div>
</form>

