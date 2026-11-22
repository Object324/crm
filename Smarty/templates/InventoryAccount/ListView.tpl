<script language="JavaScript" type="text/javascript" src="modules/Prdtnums/Prdtnums.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
{literal}
<style>
.tab-chan-link {
    background: none repeat scroll 0 0 #F0F0F0;
    border-left: 1px solid #DEDEDE;
    border-right: 1px solid #E0DDDD;
    border-top: 1px solid #E0DDDD;
    color: #444444;
    cursor: pointer;
    padding: 3px 15px 2px;
    position: relative;
    font-size:12px;
}
.tab-chan-link:hover {
    background: none repeat scroll 0 0 #ffffff;
    color: #444444;
}
.tab-chan-link-on {
    background: none repeat scroll 0 0 #ffffff;
    color: #444444;
}
.tab-chan-link-on:hover {
    background: none repeat scroll 0 0 #ffffff;
}
</style>
{/literal}
{*{include file='Buttons_List1.tpl'}*}
<table cellpadding="0" cellspacing="0" class="small">
<tr>
<td width="65px" valign="top">
<!--
edit:cdw;
date:20130626
reason:0004209: 建议：对所有页面的视图布局进行调整,将"视图"名称改为"数据分类",并且字体加粗
-->
<div style=" width:90px;color:#cc0066;"><img src="themes/images/filter.png"/>&nbsp;<font size=2>{'DATACATEGORY'|@getFixedLabel}</font></div>
</td>
<td>
{$CUSTOMVIEW_OPTION}   
{*
edit:cdw
date:20130806
reason:0004618: 将所有界面上 数据分类后面的 创建分类|编辑|删除等操作放在 查看范围这一行，不要跟在创建的分类后面
*}                                              
<div class="divView">
<a id="viewoperate" onclick="return false;" onmouseout="fnHideDrop('selectviewoperate');" onmouseover="ViewfnDropDown(this,'selectviewoperate');" target="main" href="javascript:void(0);">
{'CREATECATEGORY'|@getFixedLabel}
<span class="icon-bluetriangle"></span>
</a>                                             

<div onmouseover="fnShowDrop('selectviewoperate')" onmouseout="fnHideDrop('selectviewoperate')"  id="selectviewoperate" class="drop_mnu" style="left: 329px; top: 100px; display:none;">                                           
<table width="100%" cellspacing="0" cellpadding="0" border="0"> 
<tr>
<td>
<a class="drop_down" href="index.php?module={$MODULE}&action=CustomView&parenttab={$CATEGORY}&SearchScope={$SelectedOwner2}">{'CREATECATEGORY'|@getFixedLabel }</a>		
</td>
</tr>
{if $CV_EDIT_PERMIT eq 'yes'}
<tr>
<td>
<a class="drop_down" href="index.php?module={$MODULE}&action=CustomView&record={$VIEWID}&parenttab={$CATEGORY}&SearchScope={$SelectedOwner2}">{'EDIT'|@getFixedLabel}</a>
</td>
</tr>
{/if}
{if $ALL neq 'All'}
    {if $CV_DELETE_PERMIT eq 'yes'}
    <tr>
        <td>
            <a class="drop_down" href="javascript:confirmdelete('module=CustomView&action=Delete&dmodule={$MODULE}&record={$VIEWID}&parenttab={$CATEGORY}&SearchScope={$SelectedOwner2}','CustomView')">{'DELETE'|@getFixedLabel}</a>
        </td>
    </tr> 
    {/if}
{/if}
<!--copy view-->
<!--bug:3577 by kara -->
{*if $CV_EDIT_PERMIT eq 'yes'*}  
<tr>
<td>
<a class="drop_down" href="index.php?module={$MODULE}&action=CustomView&record={$VIEWID}&parenttab={$CATEGORY}&viewcopy=true&SearchScope={$SelectedOwner2}" >{'COPY'|@getFixedLabel}</a>                       
</td>
</tr>
{*/if*}
<!--sort view-->
{if $IS_ADMIN}
<tr>
<td>
<a class="drop_down" href="javascript:void(0);"  onClick="ShowSortView(this,'sortview','{$MODULE}')">{'SORT'|@getFixedLabel}</a>

</td>
</tr>
{/if}
</table>
</div> 
</td>
</tr>
</table>
<table width="98%" align=center border="0" cellspacing="0" cellpadding="0">
    <tr>
        {foreach item=value from=$WAREHOUSES}        
        <td class="dvtTabCache" nowrap="" style="width:10px;"></td>
        {if $value.id eq $WAREHOUSEID}
        <td align="center" class="tab-chan-link tab-chan-link-on" nowrap="" onclick="getWarehouse({$value.id},this);return false;">
            {$value.name}
        </td>
        {else}
        <td align="center" class="tab-chan-link" nowrap="" onclick="getWarehouse({$value.id},this);return false;">
            {$value.name}
        </td>
        {/if}
        {/foreach}        
        <td class="dvtTabCache" nowrap="" style="width:10px"> </td>
        <td class="dvtTabCache" nowrap="" style="width:50%"> </td>
    </tr>
</table>
<table border=0 cellspacing=0 cellpadding=0 width=98% align=center>
    <tr>
        <td style="border: 1px solid #DEDEDE;" valign="top" width=100%>
        <form name="massdelete" method="POST" id="massdelete">
        <input id="excludedRecords" type="hidden" value="" name="excludedRecords" />
        <input id="allselectedboxes" type="hidden" value="" name="allselectedboxes" />
        <input id="numOfRows" type="hidden" value="" name="numOfRows" />
        <input id="warehouseid" type="hidden" value="{$WAREHOUSEID}" name="warehouseid" />
        <input type="hidden" id="idlist" name="idlist" value="" />
            <table width="100%">
                <tr>
                    <td width="100%">
                    <div id="ListViewContents" class="small" style="width:100%;position:relative;">
                    {if $smarty.request.ajax neq ''}
                    &#&#&#{$ERROR}&#&#&#
                    {/if}
                    <table>
                    <tr>
                    <td width="50%" valign="top">
                    <table width="100%" border="0" cellspacing=0 cellpadding=5>
                    <tr>
                    <td nowrap="" align="right">   
                    <table width="100%" border=0 cellspacing=0 cellpadding=0 class="small">
                    <tr>
                    <td style="padding-right:5px;" align="right" >
                    <table class="small">
                    <tr>
                    <td> {$RECORDLISTRANGMSG}</td>
                    <td>{$NAVIGATION}</td>
                    </tr>
                    </table>
                    </td>                     
                    </tr>
                    </table>
                    </td>
                    </tr>
                    </table>
                    <table border=0 cellspacing=1 cellpadding=5 width=100% style="background-color:#cccccc;" class="lvt small">
                    <tr class="windLayerHead" height="25px" align="left">
                    <td class="lvtCol commonCol">操作类型</td>
                    <td class="lvtCol commonCol" >仓库</td>
                    <td class="lvtCol commonCol">产品名称</td>
                    <td class="lvtCol commonCol">产品编号</td>
                    <td class="lvtCol commonCol">型号</td>
                    <td class="lvtCol commonCol">入库数</td>
                    <td class="lvtCol commonCol">出库数</td>
                    <td class="lvtCol commonCol">操作后数量</td>
                    <td class="lvtCol commonCol">操作时间</td>
                    <td class="lvtCol commonCol">所属模块</td>
                    <td class="lvtCol commonCol">库存单据</td>
                    </tr>
                    {foreach item=value key=ware_id from=$InventoryInfo}
                    <tr align="left"  class="lvtColData" bgcolor="white" onmouseout="this.className='lvtColData'" onmouseover="this.className='lvtColDataHover'">
                    <td>{$value.type}</td>
                    <td>{$value.warehouse}</td>
                    <td><a href="index.php?module=Products&parenttab=Tools&action=DetailView&record={$value.productid}">{$value.productname}</a></td>
                    <td>{$value.product_no}</td>
                    <td>{$value.productcode}</td>
                    <td>{$value.inputqty}</td>
                    <td>{$value.outputqty}</td>
                    <td>{$value.lastqty}</td>
                    <td>{$value.operationtime}</td>
                    <td>{$value.modulename}</td>
                    <td>{$value.entityname}</td>
                    </tr>
                    {/foreach}
                    </table>
                </td>
            </tr>
        </table>
        </div>
    </td>
    </tr>
</table>
</form>
</td>
</tr>
</table>
</td>
</tr>
</table>