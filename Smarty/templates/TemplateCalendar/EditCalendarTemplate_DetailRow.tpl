{* creator:gyq_13 reason:日程模板明细 date:20160627 *}
{foreach key=orkey item=rowdetails from=$CALENDARTEMPLATEDETAILS }
    {foreach key=crkey item=rowdetail from=$rowdetails }
        {foreach key=label item=subdata from=$rowdetail}
            <tr mark="content_rows">
                {foreach key=mainlabel item=maindata from=$subdata}              
                    {assign var="uitype" value=$maindata[0][0][0]}
                    {assign var="fieldonly" value=$maindata[0][1][0]}
                    {assign var="fldlabel" value=$maindata[1][0]}
                    {assign var="fldlabel_sel" value=$maindata[1][1]}
                    {assign var="fldlabel_combo" value=$maindata[1][2]}
                    {assign var="fldlabel_other" value=$maindata[1][3]}
                    {assign var="fldname" value=$maindata[2][0]}
                    {assign var="orignfldname" value=$maindata[2][1]}
                    {assign var="fldvalue" value=$maindata[3][0]}
                    {assign var="secondvalue" value=$maindata[3][1]}
                    {assign var="thirdvalue" value=$maindata[3][2]}
                    {assign var="typeofdata" value=$maindata[4]}
                    {assign var="vt_tab" value=$maindata[5][0]}

                    {if $uitype eq 2 || $uitype eq 19}
                        <td>
                            <input type="text" fieldonly='{$fieldonly}' name="{$fldname}" tabindex="{$vt_tab}" value="{$fldvalue}" tabindex="{$vt_tab}" class="ld-input-inner"/>
                        </td>
                    {elseif $uitype eq 53 ||$uitype eq 153}
                        {include file='DetailView/Smowner.tpl'}
                    {elseif $uitype eq 86}
                        {if $MODE eq 'pop'}
                        <td >
                            {foreach key=date_format item=date_str from=$secondvalue}
                                {assign var=dateFormat value=$date_format}
                                {assign var=dateStr value=$date_str}
                                {assign var=timeformat value="%H:%M:%S"}
                            {/foreach}
                            {foreach key=date_value item=time_value from=$fldvalue}
                                {assign var=date_val value=$date_value}
                                {assign var=time_val value=$time_value}
                            {/foreach}
                            {if $date_val == '' || $date_val == 0}
                                {assign var=date_val value=null}
                            {/if}
                            <input name="{$fldname}" class="Wdate" id="jscal_field_{$fldname}"  style="border:1px solid #bababa;width:150px;" size="15" maxlength="25" value="{$date_val}" onClick="WdatePicker({ldelim}startDate:'%y-%M-%d %H:%M:%S',dateFmt:'yyyy-MM-dd HH:mm:ss',alwaysUseStartDate:true{rdelim})"/>
                            <input type="hidden" name="time_reminds" id="time_reminds"/>
                        </td>
                        {else}
                            <td>
                                <div class="inputnumbox"  mark="numberbox">
                                    <a href="javascript:;" style="text-decoration:none">-</a>
                                    <input type="text" value="{$fldvalue}" class="ld-input-inner" style="width:60px;"/>
                                    <a href="javascript:;" style="text-decoration:none">+</a>
                                </div>
                            </td>
                        {/if}
                    {elseif $uitype eq 15 }
                        {include file='DetailView/PickList.tpl'}
                    {/if}
                {/foreach}
                <td align="center">
                    <i class="ld-fonticon ld-fonticon-del" {if $MODE == 'create' || ( $MODE == 'edit'&& $orkey === 0)}style="display: none;" {/if} title="{'DELETE'|@getFixedLabel}" border="0" onclick="TemplateCalendar.getInstance().hideDeailRow(this)"></i>
                </td>
            </tr>
        {/foreach}
    {/foreach}
{/foreach}