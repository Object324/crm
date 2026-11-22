<!--修改编码格式:统一编码：UTF-8-->
<form name="frmsendInfo" method="post" action="index.php">
<input type="hidden"  name="module"  value="MassSMS"/>
<input type="hidden" name="action" value="SaveSendMessage"/>
<input type="hidden" name="parenttab" value="Marketing">
<input type="hidden" id="sendaccount" name="sendaccount" value="{$SENDACCOUNTTYPE}">
<input type="hidden" id="accountname" name="accountname" value="{$ACCOUNTNAME}">
<input type="hidden" id="frommodule" name="frommodule" value="{$FROMMODULE}">
<input type="hidden" id="ticketid" name="ticketid" value="{$TICKETID}">
<input type="hidden" id="fromview" name="fromview" value="{$FROMVIEW}">
<input type="hidden" id="listurl" name="listurl" value="{$LISTURL}"/>

	<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">
      <tr>
        <td class="Note">
    		<div style="padding-top: 8px;">
                {'Recipient'|@getFixedLabel}
                <select onchange="range_select(this)" id="sel_sms_range" >
                    <option value="all" {if $RANGETYPE eq 'all'}selected=""{/if}>{$ALLTRAN}</option>
                    <option value="cas" {if $RANGETYPE eq 'cas'}selected=""{/if}>{$CASTRAN}</option>
                    <option value="con" {if $RANGETYPE eq 'con'}selected=""{/if}>{$CONTRAN}</option>
                    <option value="ser" {if $RANGETYPE eq 'ser'}selected=""{/if}>{$SERTRAN}</option>
                </select>
                <a style="float:right" href="###" id="divSendInform_content_id" onclick="CreateSendInformContent('{$FROMMODULE}',document.getElementById('divSendInform_content_id'),'divSendInform_content','divSendInform','{$TICKETID}',{$TABID});">
                    {'SETHEMESSAGEFORMAT'|@getFixedLabel}
                </a>
            </div>
            <div style="height:240px;overflow:auto;padding-top: 8px;">
            <table class="listEntries fir-center" id="contenttable" style="width:100%">
                <tr>
                    <th><input type="checkbox" id="selectallboxes" onclick="toggleallbox(this.checked)" checked /></th>
                    <th style="width:120px">{'MOBILEPHONE'|@getFixedLabel}</th>
                    <th>{'SMS_content'|@getFixedLabel}</th>
                </tr>
                    {if $CONTENTARR|@count eq 0}
                        <tr>
                            <td><input onclick="select_one(this)" name="box_0" value="1" type="checkbox" checked /></td>
                            <td><input style="width:100px" type="text" name="text_0" value=""/></td>
                            <td><textarea name="area_0" style="width:675px;height:30px;overflow: hidden; overflow-wrap: break-word; resize: horizontal;"></textarea></td>           
                        </tr>
                        <input type="hidden" id="count_con" name="count_con" value="1"/>
                    {else}
                    {assign var=i value=0}
                    {foreach item=recordarr key=record from=$CONTENTARR}
                        {foreach item=conlabel from=$recordarr}
                        <tr>
                            <td><input onclick="select_one(this)" name="box_{$i}" value="1" type="checkbox" checked /></td>
                            <td><input style="width:100px" type="text" name="text_{$i}" value="{$conlabel.phone}"/></td>
                            <td><textarea name="area_{$i}" style="width:675px;height: 30px;overflow: hidden; overflow-wrap: break-word; resize: horizontal;">{$conlabel.content}</textarea></td>
                            <input type="hidden" name="type_{$i}" value="{$conlabel.type}"/>
                            <input type="hidden" name="user_{$i}" value="{$conlabel.username}"/>
                            <input type="hidden" name="record_{$i}" value="{$record}"/>
                        </tr>
                        {assign var=i value=$i+1}
                        {/foreach}
                    {/foreach}
                    <input type="hidden" id="count_con" name="count_con" value="{$i}"/>
                    {/if}
            </table>
            </div>
        </td>
      </tr>
    </table>
 

</form>