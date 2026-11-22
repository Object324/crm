<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div class="cont_wrap clear_float">
            <!--切换导航-->
            <div class="ld-ui-tabs clear_float">
                <ul class="ld-ui-tabs-nav">
                    <li {if $TABTYPE eq 0}class="ld-ui-tabs-active"{/if}>
                        <a onclick="ApproveCenterTabClick(0,event)" href="javascript:;">{'Pending'|@getFixedLabel}</a>
                    </li>
                    <li {if $TABTYPE eq 1}class="ld-ui-tabs-active"{/if}>
                        <a onclick="ApproveCenterTabClick(1,event)" href="javascript:;">{'Processed'|@getFixedLabel}</a>
                    </li>
                    <li {if $TABTYPE eq 3}class="ld-ui-tabs-active"{/if}>
                        <a onclick="ApproveCenterTabClick(3,event)" href="javascript:;">{'isubmitted'|@getFixedLabel}</a>
                    </li>
                    <li {if $TABTYPE eq 4}class="ld-ui-tabs-active"{/if}>
                        <a onclick="ApproveCenterTabClick(4,event)" href="javascript:;">{'ApproveRejected'|@getFixedLabel}</a>
                    </li>
                </ul>
            </div>
            <div>
                {if $APPROVEARR|@count eq 0}
                    <table class="listEntries" border="0" cellspacing="1" cellpadding="0" width="100%"> 
                        <tr bgcolor="#fafafa">
                            <td align="center" style="height:0px;padding: 0;">
                                {* <div class="warningTableContent" style="z-index:600;">
                                    <div class="wtc_img"><img src="themes/icon2023/ld-no-records.png"/></div>
                                    <div class="wtc_content">{'NOTFOUNDANYRECORD'|@getFixedLabel}</div>
                                    <div class="wtc_btn"></div>
                                    <div></div>
                                </div> *}
                                {include file="NoRecords.tpl"}
                            </td>
                        </tr>
                    </table>
                {else}
                    <table class="listEntries tdpadding012" border="0" cellspacing="1" cellpadding="0" width="35%">
                        <tr>
                            <th>
                                <span title="{'BillType'|@getFixedLabel}">{'BillType'|@getFixedLabel}</span>
                            </th>
                            <th>
                                <span title="{'BILLNUM'|@getFixedLabel}">{'BILLNUM'|@getFixedLabel}</span>
                            </th>
                            <th>
                                <span title="{'BILLNUM'|@getFixedLabel}">{'Documenthandling'|@getFixedLabel}</span>
                            </th>
                        </tr>
                        {foreach item=listentity name=entitylist from=$APPROVEARR}
                        {assign var="entitylistnum" value=$smarty.foreach.entitylist.iteration}
                            {if $entitylistnum mod 2 eq '1'}
                            <tr class="lvtColData">
                            {else}
                            <tr class="lvtColDataBj">
                            {/if}
                                <td>
                                    <span>{$listentity.module|getTranstab}</span>
                                </td>
                                <td align="center">
                                    {$listentity.num}
                                </td>
                                 <td align="left">
{*                                     //@edit:liushuai,2020-8-7,reason:1000950/审批中心增加已驳回页签*}
                                    {if $TABTYPE eq 1 || $TABTYPE eq 3 || $TABTYPE eq 4}
                                        <a href="javascript:;" onclick="ApproveHrefListView('{$listentity.module}','{$TABTYPE}', true)">{'selectdetails'|@getFixedLabel}</a>
                                    {else}
                                        <a href="javascript:;" onclick="ApproveHrefListView('{$listentity.module}','{$TABTYPE}', true)">{'Startprocessing'|@getFixedLabel}</a>
                                    {/if}
                                </td>
                            </tr>
                        {/foreach}
                        <tr class="lvtColData" style="">
                            <td>∑ {'ALL'|@getFixedLabel}</td>
                            <td align="center">{$TOTAL}</td>
                            <td align="center"></td>
                        </tr>
                    </table>
                {/if}
            </div>
        </div>
    </div>
</div>
<script type="text/javascript">
    initRightContentHeight();
    {literal}
    function ApproveCenterTabClick(tabindex,event)
    {
        //tabindex:0:待处理,1:已处理,3:我提交的
        ApproveCenterClick(tabindex,event);
    }
    {/literal}
</script>