<a style="width:156px;height: 30px;"id="TargetListlabel" class="chzn-single" allowtrigger="yes" tabindex="-1" onclick="TargetListShow()">
    {*wym BUG0071046 kfbcrm-目标管理-当指标名称过长时，下拉框内显示字段和箭头重叠*}
    <div id="ChooseSalesGoal" targetid="{$default_arr.targetid}" targetname="{$default_arr.targetname}" displayinactiv="{$default_arr.displayinactiv}"  class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 130px;border-style:none;margin-right: 18px;overflow: hidden;white-space: nowrap;text-overflow: ellipsis;" >{$default_arr.label}</div>
    <div style="height: 30px;">
        <b></b>
    </div>
</a>
<div tabindex="2" style="outline: 0px; left: 0px;top: 30px;width: 100%;display: none;" class="ld_homeboard_head_select" id="TargetList">
    <ul style="max-height: 300px;overflow-y: auto;">
        {foreach from=$PermitSalesgoalInfo item=tmp_info }
            <li style="position: relative"><div targetname="{$tmp_info.targetname}" targetid="{$tmp_info.targetid}" displayinactiv="{$tmp_info.displayinactiv}" onclick="ChangeSalesGoalFun(this)" style="overflow: hidden;white-space: nowrap;text-overflow: ellipsis;margin-right: 30px;" ><span style="color: #333;">{$tmp_info.label}</span>
                </div>
                {if $PERMITARR.EditView eq 'yes' }
                    <a class="icon-layout2 icon-layout2-edit" href="javascript:;" title="编辑属性" style="position: absolute;right: 6px;top: 9px;" onclick="SalesGoalEditPopup({$tmp_info.targetid})"></a>
                {/if}
            </li>
        {/foreach}
    </ul>
    <ul style="margin: 0 8px;border-top: 1px solid #eeeeee;">
        {if $PERMITARR.Create eq 'yes'}
            <li onclick="SalesGoalEditPopup(0)" style="padding: 0;">
                <b class="icon-homeimg icon-select" style="margin: 0;"></b>
                <span style="color: #333;">{'CREATEINDICATORS'|@getFixedLabel}</span></li>
        {/if}
        {if $PERMITARR.EditView eq 'yes' || $PERMITARR.Delete eq 'yes'}
            <li onclick="SalesGoalList()" style="padding: 0;">
                <b class="icon-homeimg icon-setgrey" style="margin: 0;"></b>
                <span style="color: #333;">{'MANAGEINDICATORS'|@getFixedLabel}</span></li>
        {/if}
    </ul>
</div>