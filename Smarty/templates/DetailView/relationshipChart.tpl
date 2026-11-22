<link type="text/css" href="{$CSSURL}themes/softed/ModuleMapView.css?v={$GLOBALMINVERSION}" rel="stylesheet"/>
<script type="text/javascript" src="{$JSURL}include/js/moduledata_tag.js?v={$GLOBALMINVERSION}"></script>

<div class="relationshipChartPopupDiv" id="relationshipChartPopupDiv" data-frommodule="{$FROMMODULE}" data-module="{$CHARTMODULE}" date-fromrecordid="{$FROMRECORDID}">
    {if $showtype eq 'edit' || $showtype eq 'fullscreen'}
        {*  左侧列表  *}
        <div id="relationshipChartLeftDiv" class="relationshipChartLeftDiv">
            {*  按钮  *}
            {if $showtype eq 'edit'}
            <div id="relationshipChartLeftHeadDiv" class="relationshipChartLeftHeadDiv">
                {*  客户图谱  *}
                {if $FROMMODULE eq 'Accounts' && $CHARTMODULE eq 'Accounts'}
                    {*  根据上级单位字段生成图谱  *}
                    {if $haveParentid eq 'yes'}
                        <div class="relationshipChartLeftHeadSelectDiv">
                            <p class="text-overflow ChartToolTip" style="width: 75%" data-tip='{'getrelationshipChartByParenid'|@getVarFixedLabel:$parentidLabel}' data-direction="top" data-type="position">{'getrelationshipChartByParenid'|@getVarFixedLabel:$parentidLabel}</p>
                            <div class="HeadDivBtn">
                                <a href="javascript:void(0);" id="generate" >{'GenerateImmediately'|@getFixedLabel}</a>
                            </div>
                        </div>
                    {/if}
                    <div class="relationshipChartLeftHeadSelectDiv">
                        <p>{$MODULELABEL}</p>
                        <div id="selectRelatedRecord" class="HeadDivBtn">
                            <b class="icon-homeimg icon-plus"></b>
                            <span style="color:#666;">{'SelectRelevantCustomers'|@getVarFixedLabel:$MODULELABEL}</span>
                        </div>
                    </div>
                {else}


                {/if}

            </div>
            {/if}
            {*  列表  *}
            <div id="relationshipChartLeftListDiv" style="width: 100%;list-style:none;{if $showtype eq 'fullscreen'}padding-top:10px;{/if}">
                <p class="LeftListTip" id="LeftListTip">{'DRAGCONTACTTOCHART'|@getVarFixedLabel:$MODULELABEL}</p>
                <div id="LeftListDiv" style="overflow-y: auto">

                </div>
            </div>

        </div>
    {/if}
    {*  右侧图谱  *}
    <div id="relationshipChartRightDiv" class="relationshipChartRightDiv"  style="{if $showtype eq 'edit'}width:calc(100% - 300px);{else}width:100%{/if}">
        {*  按钮  *}
        <div id="relationshipChartRightBtnDiv" class="relationshipChartRightBtnDiv">
            {*  左侧按钮  *}
            <div id="relationshipChartBtnLeftDiv" class="relationshipChartBtnLeftDiv">
                {if $showtype eq 'view'}
                    {*  编辑  *}
                    {if $editPermit eq 'yes'}
                    <div class="createauto editBtn {if $lockstatus eq 'yes'}editBtnDisabled editBtnToolTip{/if}" id="editBtn" lockstatus="{$lockstatus}"
                         data-tip="{'UNLOCKHINTSBYCLICK'|@getFixedLabel}" data-direction="bottom" data-type="position">{'EDIT'|@getFixedLabel}</div>
                    {/if}
                    {*  放大  *}
                    <div id="FullScreenBtn" class="FullScreenBtn ChartToolTip" data-tip="{'FULLSCREEN'|@getFixedLabel}" data-direction="bottom" data-type="position">
                        <img src="themes/softed/images/fullscreen.png">
                    </div>
                    {*  锁定  *}
                    {if $editPermit eq 'yes'}
                    <div id="lockBtn" class="LockDiv {if $lockstatus eq 'yes'}chart-lock{elseif $lockstatus eq 'no'}chart-unlock{/if}"  style="{if $lockstatus eq '-1'}display:none;{/if}">
                        <b></b>
                    </div>
                    {/if}
                {elseif $showtype eq 'edit'}
                    {if $FROMMODULE eq 'Accounts' && $CHARTMODULE eq 'Accounts'}
                        {*  重复节点定位  *}
                        <div name="repeatBtn" id="repeatBtn" class="repeatBtn" style="display: none;">
{*                            <img src="themes/icon2024/careful-circular.svg">*}
                            <div class="ld-commonImg ld-commonImg-BoxAlert ld-msgDlg-top-icon ChartToolTip" style="width: 26px;margin-bottom: unset" data-tip="{$parentidTip2}"  data-direction="right" data-type="position"></div>
                        </div>
                    {/if}

                {/if}
            </div>

            {*  右侧按钮  *}
            <div id="relationshipChartBtnRightDiv" class="relationshipChartBtnRightDiv">
                <div id="DragBtn" class="DragBtn ChartToolTip" tag="changeRelationshipChart" data-changetype="drag" data-tip="{'DRAGMAP'|@getFixedLabel}" data-direction="bottom" data-type="position">
                    <img src="themes/softed/images/Icon_grab.png" style="padding: 1px;">
                </div>
                <div class="RatioBtn">
                    <div id="ChangeValue" class="ChangeValue" data-value="100">100%</div>
                    <div id="ChangeIn" class="ChangeIn ChartToolTip" tag="changeRelationshipChart" data-tip="{'AMPLIFIEDMAP'|@getFixedLabel}" data-direction="bottom" data-type="position" data-changetype="in">
                        <img src="themes/softed/images/zoom-in.png">
                    </div>
                    <div id="ChangeOut" class="ChangeOut ChartToolTip" tag="changeRelationshipChart" data-tip="{'TEDUCETHEMAP'|@getFixedLabel}" data-direction="bottom" data-type="position" data-changetype="out">
                        <img src="themes/softed/images/zoom-out.png">
                    </div>
                </div>
                <div id="RestoreBtn" class="RestoreBtn ChartToolTip" tag="changeRelationshipChart" data-changetype="restore" data-tip="{'RESTOREMAPSIZE'|@getFixedLabel}" data-direction="bottom" data-type="position">
                    <img src="themes/softed/images/collapse.png">
                </div>
            </div>
        </div>
        {if $showtype eq 'view'}
            <div id="relationshipChartTip" class="relationshipChartTip" {if $showTipStatus eq 'no'}style="display: none" {/if}>
                {$showTipContent}
            </div>
        {/if}

        {*  图谱  *}
        <div id="relationshipChartDiv" class="modulemapview-design" style="overflow: auto">
            <div id="relationshipChartView" class="modulemapview" style="transform:translate(0px,0px) scale(1); transform-origin: 50% 0px 0px;">
                <div class="node-wrap" id="node_wrap_div">

                </div>
            </div>
        </div>
    </div>

</div>

