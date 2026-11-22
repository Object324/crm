
<div class="">
	<div id="ListViewContents" name="ListViewContents">
	    {if $MODULE|@get_file_address:'ProductDetails' == true || get_file_address($MODULE,$MODULE|cat:'DetailFieldsHtml')}

			<form name="selectall" method="POST">
				<input type="hidden" id="rowcnt" name="rowcnt" value="{$ROWCNT}" />
				<table width="100%" border="0" cellspacing="0" cellpadding="0" class="small">
					<tr>
						{*翻页*}
						{*<td style="padding-right:10px;" align="right">
							<div class="PageDiv0" style="margin-top:5px;">
								<div class="ld-flex-start">
									<div class="ld-pagenum-div" name="choosebilltotal_div" style="padding-right:30px">
										{'choose'|@getFixedLabel} <span id="choosebilltotal">0</span> {'numbill'|@getFixedLabel} ，{'have'|@getFixedLabel} <span id="choosebilldetails">0</span> {'billdetails'|@getFixedLabel}
									</div>
									<div class="ld-pagenum-div">{$recordListRange}</div>
									{$NAVIGATION}
								</div>
							</div>
						</td>*}
					</tr>
				</table>
				<div class="padT8">
					<input name="module" type="hidden" value="{$RETURN_MODULE}"/>
					<input name="action" type="hidden" value="{$RETURN_ACTION}"/>
					<input name="pmodule" type="hidden" value="{$MODULE}"/>
					<input type="hidden" name="curr_row" value="{$CURR_ROW}"/>
					<input name="entityid" type="hidden" value=""/>
					<input name="popuptype" id="popup_type" type="hidden" value="{$POPUPTYPE}"/>
					<input name="idlist" type="hidden" value=""/>
					<input name="contactid" id="contactid" type="hidden" value=""/>
					<input name="accountid" id="accountid" type="hidden" value=""/>
					<input  id="popupfrommodule" type="hidden" value="{$FROMMODULE}"/>
					<input type="hidden" id="fromlink" name="fromlink" value="{$FROMLINK}" />
					<input  type="hidden" id="popup_num_rows" value="{$NUMOFROWS}"/>
					<input  type="hidden" id="popup_rows_selectall" value=""/>
					<input  type="hidden" id="popup_cur_rows_count" value="{$CURPAGECOUNT}"/>
					<input  type="hidden" value="yes" id="haveproductcolumnpop"/>
					<input  type="hidden" value="{$VERSIONACCOUNT}" name="version_account"/>



					<div id="hdScrolllistentries_yy" name="hdScrolllistentries_yy" style="position: relative;">
						<div style=" visibility: visible; top: 194px;overflow-y:auto;overflow-x:hidden;"   id="resize_header_table_divid" name="resize_header_table_divid">
							<div  style="float:left; padding-right:20px">
								<table id="resize_header_tableid" name="resize_header_tableid" class="listEntries" border=0 cellspacing=1 cellpadding="0" style="width:{$LISTVIEWTOTALWIDTH}px" >
									<tbody>
									<tr>
										{foreach item=header key=i from=$LISTHEADER}
											<th style="width:{$LISTHEADERWIDTH[$i]}px" headermodule='{$HEADERMODULE[$i]}' headername='{$HEADERNAME[$i]}' tag="{$i+1}">{$header}</th>
										{/foreach}

									</tr>
									</tbody>
								</table>
							</div>
						</div>
						<div style="overflow:auto;height:400px" id="resize_content_table_divid" name="resize_content_table_divid" style="width:{$LISTVIEWTOTALWIDTH}px">
							<table border="0" cellspacing="1" cellpadding="0" id="resize_content_tableid" name="resize_content_tableid" style="width:{$LISTVIEWTOTALWIDTH}px" class="listEntries marT-53" >
								<tbody>
								<tr>
									{foreach item=header key=i from=$LISTHEADER}
										<th style="width:{$LISTHEADERWIDTH[$i]}px" headermodule='{$HEADERMODULE[$i]}' headername='{$HEADERNAME[$i]}' tag="{$i+1}">{$header}</th>
									{/foreach}

								</tr>

								{$POPHTML}

								</tbody>
							</table>
						</div>
					</div>

			</form>
{*			<div id="basicsearchcolumns" style="display:none;"><select name="search_field" id="bas_searchfield" style="width:150px">{html_options  options=$SEARCHLISTHEADER}</select></div>*}
        {else}
{*            {include file="PopupContentsLayer.tpl"}*}
        {/if}
	</div>
</div>

<script>

var hidedata='{$HIDEDATACATEGORY}';

var tmpstr='{$DATETIMESTR}';

</script>

