<link type="text/css" href="themes/softed/CustomEchartsStyle.css" rel="stylesheet">
<link type="text/css" href="themes/softed/common-23.css" rel="stylesheet">
<div>
    <span>{'WHETHERTOENABLE'|@getFixedLabel}</span>{*是否启用*}
</div>
<div class="marT5 marB15">
    <input id="isenable" type="checkbox" class="second_switch" value="">
</div>
<div class="FieldBlock">
    <div class="marT20 FieldLabel Mandatory justifynormal">
        <font color="red">*</font><span>{'ZHPARENTMENUNMAE'|@getFixedLabel}</span>{*中文*}
    </div>
    <div class="marT5 marB15 FieldCon"><input type="text" id="ZHNAME" class="detailedViewTextBox" style="width: 100%; background:#F5F8FC; "></div>
</div>
<div class="FieldBlock">
    <div class="marT20 FieldLabel Mandatory justifynormal">
        <font color="red">*</font><span>{'ENPARENTMENUNMAE'|@getFixedLabel}</span>{*英文*}
    </div>
    <div class="marT5 marB15 FieldCon">
    <input type="text" id="ENNAME" class="detailedViewTextBox" style="width: 100%;background:#F5F8FC;">
</div>
</div>
<div class="FieldBlock">
    <div class="marT20 FieldLabel Mandatory justifynormal">
        <span>{'SHOWDRAGONTIGERLIST'|@getFixedLabel}</span>{*显示龙虎榜排名*}
    </div>
    <div class="marT10 marB10 FieldCon changesearch" style="height: 25px">
    <select id="topnumber" class="detailedViewTextBox" style="height: 25px;width: 100%;background:#F5F8FC;" name="topnumber">
        <option value="3">{'FIRSTTHREE'|@getFixedLabel}</option>
        <option value="5">{'FIRSTFIVE'|@getFixedLabel}</option>
        <option value="10">{'FIRSTTEN'|@getFixedLabel}</option>
        <option value="20">{'FIRSTTWENTY'|@getFixedLabel}</option>
        <option value="50">{'FIRSTFIFTY'|@getFixedLabel}</option>
    </select>
    </div>
</div>
<div class="FieldBlock">
    <div class="marT20 FieldLabel Mandatory justifynormal">
        <span>{'showZero'|@getFixedLabel}</span>{*显示数据为0的成员*}
    </div>
    <div class="marT10 marB10 FieldCon changesearch" style="height: 25px">
        <input id="showZero" type="checkbox" class="second_switch" >
    </div>
</div>
<div class="FieldBlock">
    <div class="marT20 FieldLabel Mandatory justifynormal">
        <span>{'Permissiblepenetration'|@getFixedLabel}</span>{*是否允许穿透*}
    </div>
    <div class="marT10 marB10 FieldCon changesearch" style="height: 25px">
        <input id="can_penetrate" type="checkbox" class="second_switch" >
    </div>
</div>
{foreach key=keyid item=computeinfo from=$COMPUTEINFOARR}
    {assign var="computemodule" value=$computeinfo.computemodule}
    {assign var="computetype" value=$computeinfo.computetype}
    <div class="filtersetcard filtersetcarddash">
        <div class="FieldBlock">
            <div class="marT20 FieldLabel Mandatory">
                <span>{'StatisticsModule'|@getFixedLabel}</span>{*统计模块*}
            </div>
            <div class="marT10 marB10 FieldCon changesearch"  style="height: 25px">
            <select  fieldtype="selecttype" name="mainmodule_{$keyid}" id="mainmodule_{$keyid}" rowindex="{$keyid}"
                     class="detailedViewTextBox input-width-70 custom-select js-example-basic-single ld-stuffdetail-select">
                {foreach item=module key=modulekeyid from=$MODULEARR}
                    <option value="{$module['modulename']}">{$module['name']}</option>
                {/foreach}
            </select>
        </div>
        </div>
        <div class="FieldBlock">
            <div class="marT20 FieldLabel Mandatory">
                <span>{'COMPUTINGMETHOD'|@getFixedLabel}</span>{*计算方法*}
            </div>
            <div class="marT10 marB10 FieldCon changesearch"  style="height: 25px">
            <select  fieldtype="selecttype" name="computetype_{$keyid}" id="computetype_{$keyid}" rowindex="{$keyid}"
                     class="detailedViewTextBox custom-select js-example-basic-single ld-stuffdetail-select">
                {foreach item=COMPUTELABEL key=COMPUTETYPE from=$COMPUTETYPEARR}
                    <option value="{$COMPUTETYPE}" >{$COMPUTELABEL}</option>
                {/foreach}
            </select>
        </div>
        </div>
        <div class="FieldBlock">
            <div class="marT20 FieldLabel Mandatory">
                <span>{'STATISTICALFIELD'|@getFixedLabel}</span>{*统计字段*}
            </div>
            <div class="marT10 marB10 FieldCon changesearch"  style="height: 25px">
            {foreach item=COMPUTELABEL key=COMPUTETYPE from=$COMPUTETYPEARR}
                {assign var="ModuleFieldsKey" value=$COMPUTETYPE|cat:'FieldOption'}
                <select fieldtype="selecttype" name="computecolumns_{$COMPUTETYPE}_{$keyid}" id="computecolumns_{$COMPUTETYPE}_{$keyid}" rowindex="{$keyid}"
                        class="detailedViewTextBox custom-select js-example-basic-single ld-stuffdetail-select"
                        {if $computetype neq $COMPUTETYPE}style="display: none"{/if}>
                    {$SELECTMODULEFIELDSLIST[$computemodule][$ModuleFieldsKey]}
                </select>
            {/foreach}
            </div>
        </div>
        <div class="FieldBlock">
            <div class="marT20 FieldLabel Mandatory justifynormal">
                <span>{'StatisticalDimension'|@getFixedLabel}</span>{*统计维度*}
            </div>
            <div class="marT10 marB10 FieldCon changesearch"  style="height: 25px">
                  <select fieldtype="selecttype" id="groupby_{$keyid}" class="detailedViewTextBox ld-stuffdetail-select" rowindex="{$keyid}"
                            name="groupby_{$keyid}" >
                    {$SELECTMODULEFIELDSLIST[$computemodule]['smowneridFieldOption']}
                </select>
            </div>
        </div>
        <div class="FieldBlock">
            <div class="marT20 FieldLabel Mandatory justifynormal">
                <input type="checkbox" name="viewrange_isrelated_{$keyid}" id="viewrange_isrelated_{$keyid}" class="second_switch marR5">
                <span>{'FILTERSVIEWSCOPEMAPPINGFIELDS'|@getFixedLabel}</span>{*筛选器查看范围映射字段*}
            </div>
            <div data-control="viewrange_isrelated_{$keyid}" class="marT10 marB10 FieldCon changesearch"  style="height: 25px;{if $computeinfo.viewrange_isrelated neq 'yes'}display:none;{/if}">
            <select id="viewrange_{$keyid}" class="detailedViewTextBox ld-stuffdetail-select" rowindex="{$keyid}"
                    name="viewrange_{$keyid}" >
                {$SELECTMODULEFIELDSLIST[$computemodule]['smowneridFieldOption']}
            </select>
            </div>
        </div>
        <div class="FieldBlock">
            <div  class="marT20 FieldLabel Mandatory justifynormal">
                <input type="checkbox" name="daterange_isrelated_{$keyid}" id="daterange_isrelated_{$keyid}" class="second_switch marR5">
                <span>{'FILTERTIMERANGEMAPPINGFIELD'|@getFixedLabel}</span>{*筛选器时间范围映射字段*}
            </div>
            <div data-control="daterange_isrelated_{$keyid}" class="marT10 marB10 FieldCon changesearch"  style="height: 25px;{if $computeinfo.daterange_isrelated neq 'yes'}display:none;{/if}">
            <select id="daterange_{$keyid}" class="detailedViewTextBox ld-stuffdetail-select" rowindex="{$keyid}"
                    name="daterange_{$keyid}" >
                {$SELECTMODULEFIELDSLIST[$computemodule]['timeFieldOption']}
            </select>
        </div>
        </div>
        <div id="otherconditions_{$keyid}" class="ld_saleskitset_detail marB10" rowindex="{$keyid}">
        <span class="cursorPointer blueFont">{'SETSEARCHCONDITIONS'|@getFixedLabel}</span>{*设置查询条件*}
    </div>
    </div>
{/foreach}

<script>
    {literal}
    ld('#'+popupobj.divid).find('.filtersetcard').unbind('click').bind('click',function (){
        ld('#'+popupobj.divid).find('.filtersetcard').addClass('filtersetcarddash');
        ld(this).removeClass('filtersetcarddash');
    })
    {/literal}
</script>