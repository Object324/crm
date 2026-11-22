<div id="hdScrolllistentries_yy_{$RELATED_MODULE}" name="hdScrolllistentries_yy_{$RELATED_MODULE}" style="position:relative;overflow: auto">
    <div style=" visibility: visible; top: 194px;overflow:hidden;" id="resize_header_table_divid_{$RELATED_MODULE}">
        <div  style="float:left; padding-right:20px">
            <table id="resize_header_tableid_{$RELATED_MODULE}" name="resize_header_tableid_{$RELATED_MODULE}" class="listEntries ld-table-fixed-column" border=0 cellspacing=1 cellpadding="0" style="width:{if $RELATEDLISTDATA.total_width >0}{$RELATEDLISTDATA.total_width}px {else}100%{/if}" >
                <tr>
                {foreach key=index item=_HEADER_FIELD from=$RELATEDLISTDATA.header name=relheadforeach}
                    {if $_HEADER_FIELD eq 'OPERATING'|@getFixedLabel}
                        <th width="{$RELATEDTABLEWIDTH}" tag="{intval($index)+1}">{$_HEADER_FIELD}</th>
                    {else}
                        <th style="width:{$RELATEDLISTDATA.fieldwidth[$index]}px;{if $LOGTYPE eq 'yes'}text-align:center;{/if}"
                            tag="{intval($index)+1}" headermodule="{$RELATEDLISTDATA.headername.module[$index]}" headername="{$RELATEDLISTDATA.headername.fieldname[$index]}" >{$_HEADER_FIELD}</th>
                    {/if}
                {/foreach}
                </tr>
            </table>
        </div>
    </div>
    <div style="{if $RELATEDLISTDATA.noofrows==0}min-height: 350px;{/if}" id="resize_content_table_divid_{$RELATED_MODULE}" name="resize_content_table_divid_{$RELATED_MODULE}">
        <div style="float:left;">
        <table id="resize_content_tableid_{$RELATED_MODULE}" name="resize_content_tableid_{$RELATED_MODULE}" class="listEntries marT-53 ld-table-fixed-column" style="width:{if $RELATEDLISTDATA.total_width >0}{$RELATEDLISTDATA.total_width}px {else}100%{/if}" border=0 cellspacing=1 cellpadding="0" >
            <tr>
                {foreach key=index item=_HEADER_FIELD from=$RELATEDLISTDATA.header name=relheadforeach}
                    {if $_HEADER_FIELD eq 'OPERATING'|@getFixedLabel}
                        <th width="{$RELATEDTABLEWIDTH}" tag="{intval($index)+1}" class="th-td-fixedColumn th-fixedColumn-color">{$_HEADER_FIELD}</th>
                    {else}
                        <th style="width:{$RELATEDLISTDATA.fieldwidth[$index]}px;"
                            {if intval($index) ge $RELATEDLISTDATA.fiexedIndex}class="th-td-fixedColumn th-fixedColumn-color {if intval($index) eq $RELATEDLISTDATA.fiexedIndex} first-fixed-column{/if}"{/if}
                        tag="{intval($index)+1}" headermodule="{$RELATEDLISTDATA.headername.module[$index]}" headername="{$RELATEDLISTDATA.headername.fieldname[$index]}"  >{$_HEADER_FIELD}</th>
                    {/if}
                {/foreach}
            </tr>
            {assign var="i" value=0}
            {foreach key=_RECORD_ID name=entriesList item=_RECORD from=$RELATEDLISTDATA.entries}
                {assign var="j" value=$i++}
                {if $smarty.foreach.entriesList.iteration mod 2 eq '1'}
                <tr id="relation_{$RELATED_MODULE}_{$j}"  record="{$_RECORD_ID}" class="lvtColData" onmouseover="listOnMouseOver(ld(this), 'record')" onmouseout="listOnMouseOut(ld(this),'on', 'record')">
                    {else}
                <tr id="relation_{$RELATED_MODULE}_{$j}" record="{$_RECORD_ID}" class="lvtColDataBj" onmouseover="listOnMouseOver(ld(this), 'record')" onmouseout="listOnMouseOut(ld(this),'On', 'record')">
                    {/if}
                    {foreach key=index item=_RECORD_DATA from=$_RECORD}
                        {if $index|@istdRight:$RELATED_MODULE==true}
                            {assign var="tdalign" value='right'}
                        {else}
                            {assign var="tdalign" value='left'}
                        {/if}
                        <td width="40%" align="{$tdalign}"
                            {if intval($index) ge $RELATEDLISTDATA.fiexedIndex}class="th-td-fixedColumn{if $smarty.foreach.entriesList.iteration mod 2 eq '1'} td-fixedColumn-color-nt{else} td-fixedColumn-color-2nt {/if}{if intval($index) eq $RELATEDLISTDATA.fiexedIndex} first-fixed-column{/if}"
                            {/if}
                        >{$_RECORD_DATA}</td>
                    {/foreach}
                </tr>
            {foreachelse}
                <tr>{if $GETEDITDETAIL neq 'yes'}{assign var=winheight value="0" }{else} {assign var=winheight value="250" }{/if}
                    <td id="resize_content_tdid"  style="background-color:#FFF;height:{$winheight}px;padding: 0;" align="center" colspan='{$smarty.foreach.relheadforeach.iteration}'>
                        {include file="NoRecords.tpl"}
                    </td>
                </tr>
                {if $RELATEDLISTDATA.totalfldhtml !=''}
                    {$RELATEDLISTDATA.totalfldhtml}
                {/if}
            {/foreach}
        </table>
    </div>
    </div>
</div>
<script>
    var popupobj=CrmPopup.getlastPopupObjByType(RelateListPage.type);
    popupobj.relatelistsizeobj=new List_ResizeTable(popupobj);
    popupobj.relatelistsizeobj.setRelatedResizeTable_Init('{$RELATED_MODULE}','');
    popupobj.reSizePosition();//设置相关信息全屏
    var tmp_related_module = '{$RELATED_MODULE}';
    var tmp_module = '{$MODULE}';
</script>