<div style="width: 100%;" showboardnum="{$ShowBoardNum}">
    {*wym 240111 BUG20240110-29 目标管理--指标管理，操作列位置不够，应该拉长，新增应该放到右上角做按钮*}
    {if $PERMITARR.Create eq 'yes'}
    <div class="ListViewNavBarAndBtn" id="ListViewNavBarAndBtn">
        <div class="ld_listviewnavbar" style="">{include file='ListViewNavBar.tpl'}</div>
        <div class="listview_toprightbox">
            <div class="E_pop_tit_Second_Right ld-listview-btnscontent" style="margin: 0px 15px 0px 0;">
                <div class="E_pop_tit_Second_Right ld-listview-btnscontent">
                    <div style="margin: 5px 0;">
                        <div class="ld-button" href="javascript:void(0);" onclick="SalesGoalEditPopup(0)">{'CREATEINDICATORS'|@getFixedLabel}</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    {/if}
<table class="settingTable fir-center" id="approvelisttable" border=0 cellspacing=0 cellpadding=0 width="99%" style="margin: 0 5px;">
    <tr>
        <th width="1%">#</th>
        <th width="8%" title="{'INDICATORSNAME'|@getFixedLabel}">{'INDICATORSNAME'|@getFixedLabel}</th>
        <th width="9%" title="{'INDICATORSOBJECT'|@getFixedLabel}">{'INDICATORSOBJECT'|@getFixedLabel}</th>
        <th width="6%" title="{'ASSIGNEDTO'|@getFixedLabel}">{'ASSIGNEDTO'|@getFixedLabel}</th>
        <th width="6%" title="{'Person_in_charge'|@getFixedLabel}">{'Person_in_charge'|@getFixedLabel}</th>
        <th width="10%" title="{'Createtime1'|@getFixedLabel}">{'Createtime1'|@getFixedLabel}</th>
        <th width="10%" title="{'OPERATTIME'|@getFixedLabel}">{'OPERATTIME'|@getFixedLabel}</th>
        <th width="8%" title="{'WHETHERTOENABLE'|@getFixedLabel}">{'WHETHERTOENABLE'|@getFixedLabel}</th>
        <th width="8%" >
            {'ISSHOWBOARD'|@getFixedLabel}
            <b tag="isShowBoardHelp" class="icon-homeimg icon-askgrey-help tip-items-list" style="height: 18px;"
               data-tip="{'ISSHOWBOARDHELP'|@getFixedLabel}" data-direction="top" data-type="position"></b>
        </th>
        {if $LANGUAGETYPE eq 'en'}
            <th style="width: 200px">{'OPERATING'|@getFixedLabel}</th>
        {else}
            <th style="width: 200px">{'OPERATING'|@getFixedLabel}</th>
        {/if}
    </tr>
    {assign var="j" value=0}
    {foreach item=salesinfo from=$SalesGoalList }
        {assign var="j" value=$j+1}
        <tr id="Goalinfo" rowindex="{$j}" targetid="{$salesinfo.targetid}" class="dragtrrow ">
        <td id="lineid">{$j}</td>
        <td>{$salesinfo.label}</td>
        <td>{$salesinfo.modulelabel}</td>
        <td>{$salesinfo.smowneridlabel}</td>
        <td>{$salesinfo.smcreatoridlabel}</td>
        <td>{$salesinfo.createdtime}</td>
        <td>{$salesinfo.modifiedtime}</td>
        <td><input type="checkbox" columnname="status" {if $PERMITARR.EditView neq 'yes'}disabled="disabled"{/if} onclick="cls_salesgoal_operation.ChangeSalesGoalStatus(this)" targetid="{$salesinfo.targetid}" class="second_switch" {if $salesinfo.status eq 'yes'}checked=""{/if} ></td>
        <td>
            <input type="checkbox" columnname="showtype" {if $PERMITARR.EditView neq 'yes' or $salesinfo.status neq 'yes'}disabled="disabled"{/if}
                   onclick="cls_salesgoal_operation.ChangeSalesGoalStatus(this)" targetid="{$salesinfo.targetid}"
                   tag="showboard"
                   class="second_switch" {if $salesinfo.showtype eq 'board'}checked=""{/if} >
        </td>
        <td>
            {if $PERMITARR.EditView eq 'yes'}
            <a class="Anu3_a" href="javascript:void(0);" targetid="{$salesinfo.targetid}" onclick="SalesGoalEditPopup({$salesinfo.targetid})">{'EDIT'|@getFixedLabel}</a>
            {/if}
            {if $PERMITARR.Allocate eq 'yes'}
            <a class="Anu3_a" href="javascript:void(0);" targetid="{$salesinfo.targetid}" onclick="cls_salesgoal_operation.Allocate(this)">{'ALLOCATE'|@getFixedLabel}</a>
            {/if}
            {if $PERMITARR.Share eq 'yes'}
            <a class="Anu3_a" href="javascript:void(0);" targetid="{$salesinfo.targetid}" shareduserid="{$salesinfo.shareduserid}" onclick="cls_salesgoal_operation.Share(this)">{'SHARE'|@getFixedLabel}</a>
            {/if}
            {if $PERMITARR.Delete eq 'yes'}
            <a class="Anu3_a redFont" href="javascript:void(0);" targetid="{$salesinfo.targetid}" onclick="cls_salesgoal_operation.Delete(this)">{'DELETE'|@getFixedLabel}</a>
            {/if}
            {if $isadmin eq 'yes'}
                <a class="drag-handle ld-category-icon ld-category-drag" title="{'DRAGTOSORT'|@getFixedLabel}" style="cursor:move;"></a>
            {/if}
        </td>
        </tr>
    {/foreach}
</table>
</div>

