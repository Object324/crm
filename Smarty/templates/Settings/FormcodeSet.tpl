<div style="height:300px;overflow:auto;margin-bottom:10px;" >
    <table name="formcode_fieldinfo" width="100%" border="0" cellspacing="0" cellpadding="0" class="settingadvaceTable">
        <tr style="position: sticky;top:0px;">
            <th>CRM {'LISTFIELDS'|@getFixedLabel}</th>
            {foreach key=tag item = th_label from =$TRANSLABEL}
            <th style="width:60px;">{if $tag eq 'label'}<font  color="red">*</font>{/if}{$th_label}</th>
            {/foreach}
        </tr>
        <tr name="allselect">
            <td>{'ALLSELECT'|@getFixedLabel}</td>
            {foreach key=tag item = th_label from =$TRANSLABEL}
                <td style="text-align:center">
                {if $tag eq 'label'}
                    <a href="javascript:;" fromspan="fieldlabel_" toinput="fieldlabel_label_" onclick="qrcodeTemplate.fieldllabel_turnback(this)">{'REDUCTION'|@getFixedLabel}{'LISTFIELDS'|@getFixedLabel}</a>
                {else}
                    <input type="checkbox"  name="checkbox_{$tag}" id="checkbox_{$tag}"
                    {if $QRCODEFIELDS.$fieldid.$tag eq 'yes' && $DETAILQRCODEFIELDS.$fieldid.$tag eq 'yes'}checked{/if} onclick="qrcodeTemplate.allfield_checkbox(this)" />
                {/if}</td>
            {/foreach}
            
        </tr>
    {foreach key=fieldid item=fieldinfo from=$ALLFIELDS}
        <tr name="fieldinfo">
            <td><span name="fieldlabel_{$fieldid}" name="fieldlabel_{$fieldid}" >{$fieldinfo.fieldlabel}</span>
                <input name="fieldid" type="hidden" value="{$fieldid}"/>
            </td>
            {foreach key=tag item=th_label  from =$TRANSLABEL}
            <td style="text-align:center">
                {if $tag eq 'label'}
                    <input style="width:100%;padding-left:5px;" class="detailedViewTextBox" name="fieldlabel_{$tag}_{$fieldid}" 
                    tag="fieldlabel_{$tag}" id="fieldlabel_{$tag}_{$fieldid}" 
                    value="{if $QRCODEFIELDS.$fieldid.$tag eq ''}{$fieldinfo.fieldlabel}{else}{$QRCODEFIELDS.$fieldid.$tag}{/if}" />
                {elseif $tag eq 'view'}
                    <input type="checkbox" name="checkbox_{$tag}_{$fieldid}" fieldid="{$fieldid}" id="checkbox_{$tag}_{$fieldid}" tag="checkbox_{$tag}"
                    {if $QRCODEFIELDS.$fieldid.$tag eq 'yes'}checked{/if} onclick="qrcodeTemplate.field_checkbox(this)" />
                {else}
                    {if $fieldinfo.allowedit eq 'yes'}
                        <input type="checkbox" name="checkbox_{$tag}_{$fieldid}" fieldid="{$fieldid}" id="checkbox_{$tag}_{$fieldid}" tag="checkbox_{$tag}"
                        {if $QRCODEFIELDS.$fieldid.$tag eq 'yes'}checked{/if} onclick="qrcodeTemplate.field_checkbox(this)" />
                    {else}
                        <input type="checkbox" disabled>
                    {/if}
                {/if} 
            </td>
            {/foreach}
        </tr>
    
    {/foreach}
        {if $DETAILARRAY|@count > 0}
        <tr style="position: sticky;top:0px;">
            <th>CRM {'DOCUMENTENTRY'|@getFixedLabel}{'LISTFIELDS'|@getFixedLabel}</th>
            <th style="width:60px;"></th><th style="width:60px;"></th><th style="width:60px;"></th>
            <th style="width:60px;"></th><th style="width:60px;"></th><th style="width:60px;"></th>        
        </tr>
        {/if}
        
    {foreach key=fieldid item=fieldinfo from=$DETAILARRAY}
        <tr name="detail_fieldinfo">
            <td><span name="detail_fieldlabel_{$fieldid}" name="detail_fieldlabel_{$fieldid}" >{$fieldinfo.fieldlabel}</span>
                <input name="detail_fieldid" type="hidden" value="{$fieldid}"/>
            </td>
            {foreach key=tag item=th_label  from =$TRANSLABEL}
            <td style="text-align:center">
                {if $tag eq 'label'}
                    <input style="width:100%;padding-left:5px;" class="detailedViewTextBox" name="fieldlabel_{$tag}_{$fieldid}" 
                    tag="fieldlabel_{$tag}" id="fieldlabel_{$tag}_{$fieldid}" 
                    value="{if $DETAILQRCODEFIELDS.$fieldid.$tag eq ''}{$fieldinfo.fieldlabel}{else}{$DETAILQRCODEFIELDS.$fieldid.$tag}{/if}" />
                {elseif $tag eq 'view'}
                    <input type="checkbox" name="checkbox_{$tag}_{$fieldid}" fieldid="{$fieldid}" id="checkbox_{$tag}_{$fieldid}" tag="checkbox_{$tag}"
                           {if $DETAILQRCODEFIELDS.$fieldid.$tag eq 'yes'}checked{/if} onclick="qrcodeTemplate.field_checkbox(this)" />
                {else}
                    {*ls 20221231  XUQIU1000922������-��¼�ɱ༭(������ѡ�񵥾ݣ���ѡ�����ֶΣ�����ѡ��Ʒ�ֶΣ������˿��Բ鿴�������ɹ�ѡ)*}
                    {if $fieldinfo.allowedit eq 'yes'}
                        <input type="checkbox" name="checkbox_{$tag}_{$fieldid}" fieldid="{$fieldid}" id="checkbox_{$tag}_{$fieldid}" tag="checkbox_{$tag}"
                               {if $DETAILQRCODEFIELDS.$fieldid.$tag eq 'yes'}checked{/if} onclick="qrcodeTemplate.field_checkbox(this)" />
                    {else}
                        <input type="checkbox" disabled>
                    {/if}
                {/if}
            </td>
            {/foreach}
        </tr>
    
    {/foreach}
    
    
    </table> 
</div>
<table  width="95%" border="0" cellspacing="0" cellpadding="0" class="settingadvaceTable">
    <th>{'LBL_OTHER_SETTINGS'|@getFixedLabel}</th> 
</table>
<div>
    <div class="main_grid_set select-input" style="padding-left: 20px;box-shadow:none;display: flex;align-items: center;">
        <span>{'VIEWPEOPLENUMBER'|@getFixedLabel}</span>
        <input type='radio' name="nolimit" id="nolimit" typeofradio="humanlimit" style="margin-left: 45px;" onclick="qrcodeTemplate.limit_checkbox(this)" {if $LIMIT eq 'nolimit'}checked{/if} />
        <span>{'NOLIMITS'|@getFixedLabel}</span>
        <input type='radio' name="viewnum" id="viewnum" typeofradio="humanlimit" style="margin-left: 55px;" onclick="qrcodeTemplate.limit_checkbox(this)" {if $LIMIT neq 'nolimit'}checked{/if} /><span>{'custom'|@getFixedLabel}</span>
        <input style="width:50px;" class="detailedViewTextBox" name="humanlimit" id="humanlimit" onchange="qrcodeTemplate.quantity_change(this)" onkeyup="qrcodeTemplate.quantity_onkeyup(this)"
         value="{if $LIMIT neq 'nolimit' && $LIMIT>0}{$LIMIT}{else}10{/if}" />
        <span style="color:#666">({'GREATERTHANONE'|@getFixedLabel})</span>
    </div>
    <div class="main_grid_set select-input" style="padding-left: 20px;margin-bottom:10px;box-shadow:none;display: flex;align-items: center;" >
        <span>{'EFFECTIVETIME'|@getFixedLabel}</span>
        <input type='radio' name="permanently" id="permanently" tag='permanently' typeofradio="duration" style="margin-left: 45px;" onclick="qrcodeTemplate.limit_checkbox(this)" {if $DURATION eq 'permanently'}checked{/if} /><span name="permanently_span">{'PERMANENTLYVALID'|@getFixedLabel}</span>
        <input type='radio' name="duration_1" id="duration_1" tag='1' typeofradio="duration" style="margin-left: 45px;" onclick="qrcodeTemplate.limit_checkbox(this)" {if $DURATION eq '1'}checked{/if} /><span>1{'Days'|@getFixedLabel}</span>
        <input type='radio' name="duration_7" id="duration_7" tag='7' typeofradio="duration" style="margin-left: 45px;" onclick="qrcodeTemplate.limit_checkbox(this)" {if $DURATION eq '7'||$DURATION eq ''}checked{/if} /><span>7{'Days'|@getFixedLabel}</span>
        <input type='radio' name="duration_30" id="duration_30" tag='30' typeofradio="duration" style="margin-left: 45px;" onclick="qrcodeTemplate.limit_checkbox(this)" {if $DURATION eq '30'}checked{/if} /><span>30{'Days'|@getFixedLabel}</span>
        <input type='radio' name="endate" id="endate" tag='endate' typeofradio="duration" style="margin-left: 45px;" onclick="qrcodeTemplate.limit_checkbox(this)" {if $DURATION eq 'endate'}checked{/if} /><span>{'ENDDATE'|@getFixedLabel}</span>
        <input name="endatetime" class="Wdate " type="text" 
        style="border:1px solid #dbdbdb;width:180px;box-sizing: border-box;" 
        size="15" maxlength="25" value="{$ENDDATETIME}" autocomplete="off" 
        onclick="WdatePicker({ldelim}startDate:'%y-%M-%d %H:%M:%S',dateFmt:'yyyy-MM-dd HH:mm:ss',alwaysUseStartDate:true{rdelim});
        ld('.SearchResult').css('display','none')" />
    </div>
</div>