<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Prdtnums/Prdtnums.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListViewButton.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>

<div class="main_grid lfloat main_grid_list">
    <div class="main_grid_top">
        <!--切换导航-->
        <div class="D_Tab_div_more tabHieght" id="tabWareHouse">
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td valign="top" class="L">
                    <ul class="Tab_div_more_ul">
                        {*<li onclick="window.location.reload();"><a {if $WAREHOUSEID eq 0} class="On on" {else} class="on" {/if} >{'ALLWAREHOUSE'|@getFixedLabel}</a></li>*}
                    {foreach item=value from=$WAREHOUSES} 
                        {if $value.id eq $WAREHOUSEID}
                            <li><a class="On on" onclick="getWarehouse({$value.id},this);return false;" title="{$value.name}">{$value.name}</a></li>
                        {else}
                            <li><a onclick="getWarehouse({$value.id},this);return false;" title="{$value.name}">{$value.name}</a></li>
                        {/if}
                    {/foreach}
                    {if $MOREWAREHOUSES|@count gt 0}
                        {*if $WAREHOUSEID neq ''}
                            {assign var=c value='On'}
                        {else}
                            {assign var=c value='on'}
                        {/if*} 
                        <li> 
                        <a id="morewarehouseid" class="{$c}">
                            {'MORE'|@getFixedLabel}:                
                        </a>
                        </li>   
                    {/if}
                    </ul>
                    {if $MOREWAREHOUSES|@count gt 0}
                        <div id="ware_select_more" class="tab-more">
                            {include file='MoreWareHouseSelect.tpl'}
                        </div>
                    {/if}
                   <div class="icon-homeimg icon-askgrey" style="float:right;margin-right:10px;margin-top: 13px;">
                    <p>
                    {'NOTE'|@getFixedLabel}<br />
                    1. {'NONEEDINITINVENTORY'|@getFixedLabel}<br />
                    2. {'SHOULDINITWAREINVENTORY'|@getFixedLabel}<br />
                    3. {'EACHWAREINVENTORYINIT'|@getFixedLabel}
                    </p>
                   </div> 
                </td>
              </tr>
            </table>
        </div>
        <div class="clear"></div>
        <!--切换导航  end-->
    </div>
    <div class="main_grid_box">
        <div class="grid-analysis-box">
            <div class="grid-analysis-header">
            </div>
            <div class="cont_wrap clear_float">
                <table border=0 cellspacing=0 cellpadding=0 width=100% align=center>
                    <tr>
                        <td valign="top" width=100%>
                        <form name="massdelete" method="POST" id="massdelete" class="ware_form">
                        <input id="excludedRecords" type="hidden" value="" name="excludedRecords" />
                        <input id="allselectedboxes" type="hidden" value="" name="allselectedboxes" />
                        <input id="numOfRows" type="hidden" value="" name="numOfRows" />
                        <input id="warehouseid" type="hidden" value="{$WAREHOUSEID}" name="warehouseid" />
                        <input type="hidden" id="idlist" name="idlist" value="" />
                        <table width="100%" cellspacing="0" cellpadding="0" border="0">
                            <tr>
                                <td width="100%">
                                    <div id="ListViewContents" class="small" style="width:100%;position:relative;">
                                   
                                        {include file="Prdtnums/ListViewEntries.tpl"}
                                    </div>
                                </td>
                            </tr>
                        </table>
                        </form>
                        </td>
                    </tr>
                    </table>
            </div>
        </div>
    </div>
</div>

<script>
var Listpagepopupobj=new CrmPopup();
Listpagepopupobj.type="listpage";
Listpagepopupobj.divid='pagecontent1';
Listpagepopupobj.searchtype="";//基本查询和高级查询，32156: 单据列表：设置高级查询后，切换查看范围时，不清空高级查询条件
Listpagepopupobj.url='{$LISTPAGEURL}';
Listpagepopupobj.module='Prdnums';
        
CrmPopup.global_listPopupObj.push(Listpagepopupobj);

</script>