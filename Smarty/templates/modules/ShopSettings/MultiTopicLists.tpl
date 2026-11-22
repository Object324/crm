<style>
    .can-sortable{
        cursor: move;
    }
</style>
<table class="settingTable fir-center" name="topicproductlisttable" id="topicproductlisttable" border=0 cellspacing=0 cellpadding=0 width="100%" style="border-top: 1px solid #dedede;">
    <tbody>
    <tr style="position:sticky;top:0px;z-index:1;">
        <th style="text-align: center;"><input type="checkbox" name="selectall" onclick="toggleSelect(this.checked,'selected_id');"></th>
        <th style="width:px" tag="1" headermodule="" headername="">产品名称</th>
        <th style="width:px" tag="2" headermodule="" headername="">图片</th>
        <th style="width:px" tag="3" headermodule="" headername="">规格型号</th>
        <th style="width:px" tag="4" headermodule="" headername="">产品报价（RMB）</th>
        <th style="width:px" tag="5" headermodule="" headername="">单价</th>
        {if $LANGUAGETYPE eq 'en'}
        <th width="120" tag="6">{'OPERATING'|@getFixedLabel}</th>
        {else}
        <th width="100" tag="6">{'OPERATING'|@getFixedLabel}</th>
        {/if}
    </tr>

    {assign var="i" value=1}
    {foreach key=index item=$topicProducts from=$TopicProductsLists}
        {assign var="j" value=$i++}
        {if $index mod 2 eq '1'}
        <tr tag="data" id="relation_Products_{$j}" class="lvtColDataBj" onmouseover="listOnMouseOver(ld(this), 'record')" onmouseout="listOnMouseOut(ld(this),'On', 'record')">
        {else}
        <tr tag="data" id="relation_Products_{$j}" class="lvtColData" onmouseover="listOnMouseOver(ld(this), 'record')" onmouseout="listOnMouseOut(ld(this),'on', 'record')">
        {/if}

        <td align="left" style="text-align: center;">
            <input type="checkbox" name="selected_id" id="{$topicProducts.id}" value="{$topicProducts.id}">
        </td>
        <td class='can-sortable' align="left">
            {$topicProducts.productname}{if $topicProducts.productstatus eq '下架'}<b class="fontsup">已下架</b>{/if}
        </td>

        <td align="left">
            {$topicProducts.imagename}
        </td>


        <td align="left">
            {$topicProducts.productsheet}
        </td>

        <td align="left">
            {$topicProducts.unit_price}
        </td>

        <td align="left">
            {$topicProducts.costprice}
        </td>


        <td align="left">
            <a class="Anu3_a" onclick="ShopSettingsobj.deleteTopicProductRel('{$topicProducts.id}');" alt="取消产品">取消产品</a>
        </td>

        </tr>
    {foreachelse}
        <tr class="lvtColData">
            <td colspan="7" align="center">{'NOTFOUNDANYRECORD'|@getFixedLabel}</td>
        </tr>
    {/foreach}


    </tbody>
</table>
<script>
    ShopSettingsobj.setSortable();//设置行拖动事件
</script>