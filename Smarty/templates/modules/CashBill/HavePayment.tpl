<!--修改编码格式:统一编码：UTF-8-->
<div class="divPopOverflow">
    {include file="modules/CashBill/SalesorderInfo.tpl"}
        <input type="hidden" name="pliststr" id="pliststr" value="{$PLISTSTR}"/>
        <input type="hidden" name="paymentamount" id="paymentamount" value="{$NOPAYMENTAMOUNT}"/>
        <input type="hidden" name="planremarktypeofdata" value="{$PLANREMARKTYPEOFDATA}" id="planremarktypeofdata"/>
        <input type="hidden" name="planremarklabel" value="{$PLANDREMARK}" id="planremarklabel"/>
        <input type="hidden" name="projecttypeofdata" value="{$PROJECTTYPEOFDATA}" id="projecttypeofdata"/>
        <input type="hidden" name="projectlabel" value="{$FIELDLABEL}" id="projectlabel"/>
        </table>
    
    <div class="" style="padding: 8px 24px 20px;">
        <table id="tabpaymentplan" class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <th width="6%"  style="text-align:center;">{'OPERATING'|@getFixedLabel}</th>
                <th>{$PERIODTIMENAME}</th>
                <th>{'RATIO'|@getFixedLabel}</th>
                <th>{'AMOUNT'|@getFixedLabel}</th>
                {if $PAYMENTTYPEVALUE eq '项目状态'}
                    <th id="paymentpan_date_tr" style="display:none;">{$PLANDATENAME}</th><!--计划回款日期-->
                    <th id="projectstatus_tr">{'Paymentwhentheprojectstatus'|@getFixedLabel}</th><!--回款时项目状态-->
                    {if $PROJECTISSHOW eq '1'}
                        {*wym BUG0073109 收款计划“项目立项”设置必填字段后，收款计划新建界面“项目立项”字段也应该显示必填红色星号标识*}
                        {if $PROJECTTYPEOFDATA eq 'm'}
                            <th id="project_tr"><font color='red'>*</font>{$FIELDLABEL}</th><!--关联项目立项-->
                        {else}
                            <th id="project_tr">{$FIELDLABEL}</th><!--关联项目立项-->
                        {/if}
                    {/if}
                {else}
                    <th id="paymentpan_date_tr">{$PLANDATENAME}</th><!--计划回款日期-->
                    <th style="display:none;" id="projectstatus_tr">{'Paymentwhentheprojectstatus'|@getFixedLabel}</th><!--回款时项目状态-->
                    {if $PROJECTISSHOW eq '1'}
                        {if $PROJECTTYPEOFDATA eq 'm'}
                            <th style="display:none;" id="project_tr"><font color='red'>*</font>{$FIELDLABEL}</th><!--关联项目立项-->
                        {else}
                            <th style="display:none;" id="project_tr">{$FIELDLABEL}</th><!--关联项目立项-->
                        {/if}
                    {/if}
                {/if}
                {if $PLANREMARKTYPEOFDATA eq 'm'}
                    <th><font color='red'>*</font>{$PLANDREMARK}</th>
                {else}
                    <th>{$PLANDREMARK}</th>
                {/if}
            </tr>
            <tr id='row1'>
                <td align="center"><i class="ld-fonticon ld-fonticon-del" btnname='deletetr' ></i></td>
                <td><input type="text" name="periodtime1" id="periodtime1" size="10" value="{$PERIODTIME}" class="ld-input-inner"/></td>
                <td><input type="text" name="ratio1" id="ratio1" size="10" value="{if $NOPAYMENTAMOUNT < 0 }0.00{else}100.00{/if}" onchange="changeamountn(this,'amount1','ratio1','{$NOPAYMENTAMOUNT}');" class="ld-input-inner"/></td>
                <td><input type="text" name="amount1" id="amount1" size="10" value="{if $NOPAYMENTAMOUNT < 0 }0.00{else}{$NOPAYMENTAMOUNT}{/if}" onchange="changeratio(this,'ratio1','amount1','{$NOPAYMENTAMOUNT}');" class="ld-input-inner"/></td>
                <td id='paymentpan_date_td_1' class="ld-form-item-content">
                    <input type="text" name="plandate1" size="15" id="plandate1" readonly="true" value="{$PLANDATE}" onClick="WdatePicker()" class="Wdate ld-input-inner"/>
                </td>
                <td id='projectstatus_td_1' style='display:none;'>
                    {$HAVEPAYMENTLIST}
                </td>
                {if $PROJECTISSHOW eq '1'}
                    <td id='project_td_1' style='display:none;overflow: visible'><!--关联项目立项-->
                        <input readonly name="{$FIELDNAME}1_name" type="text" fieldonly='{$FIELDONLY}' value="" class="ld-input-inner gwidth70">
                        <input name="{$FIELDNAME}1" type="hidden" value="">
                        <a index="1" class="icon-homeimg icon-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("PaymentPlan","{$REFERMODULE}","select","","{$FIELDNAME}",this);'></a>
                        <input index="1" class="icon-homeimg icon-clear inpb-reset" type="button" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('PaymentPlan','{$FIELDNAME}','{$FIELDNAME}_name','{$FIELDNAME}','{$REFERMODULE}','popupselectfield',this);return false;"/>
                    </td>
                {/if}
                <td><textarea name="description1" id="description1" value="" cols='100%' class="ld-textarea-inner" style='height: 30px;'></textarea></td>
            </tr>
        </table>
    </div>
</div>
<div style="display: flex;justify-content: space-between;padding: 0 24px">
    <div style="line-height: 44px;">
        <a class="" style="" btnname="addtr" href="javascript:;">{'ADDQICI'|@getFixedLabel}</a>
    </div>
    <ul style="float: right;line-height: 26px;margin: 6px 0px;{if $PAYMENTTYPEVALUE eq '项目状态'}display:none;{/if}" id="paymentplan_times" >
        <li style="float: left;padding-right: 5px;">
            {'PERIODLOAD'|@getFixedLabel}:
            <input type="text" value="" name="OkPeriodTime" id="OkPeriodTime" size="5" class="ld-input-inner width60" />&nbsp;&nbsp;{'PERIOD'|@getFixedLabel},{'FIRSTBACKSECTION'|@getFixedLabel}:&nbsp;&nbsp;<input type="text" name="startplandate" size="15" id="startplandate" readonly="true" value="{$NOWDATE}" onClick="WdatePicker()" class="Wdate ld-input-inner ld-Wdate width100"/>
        </li>
        <li style="float: left;">
            <a class="Anu3_a" style="padding: 0 5px;line-height: 23px;margin:2px 0px;" btnname="LoadPeriodTime" href="javascript:;">{'RECALCULATE'|@getFixedLabel}</a>
        </li>
    </ul>
</div>
</form>