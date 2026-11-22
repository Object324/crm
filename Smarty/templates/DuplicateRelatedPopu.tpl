<div name="div_check_repeat">
	{if $MODULE eq 'Accounts' || $MODULE eq 'Leads' || $MODULE eq 'Vendors'}
		<div class="ld-description">
			<b class="info-icon"></b>
			<div class="ld-description-content">
				{'EXPLAIN'|@getFixedLabel}：{'DUPLICATETIPS2'|@getFixedLabel}<span style="color:red">{'DUPLICATETIPS3'|@getFixedLabel}</span>
			</div>
		</div>
	{/if}
	<div class="ld-pop-container overflowauto">
		{if $ISADMIN eq 1}
			<div class="padB16">
				{*@edit:liushuai,2021-03-22,reason:【ID1001458】查重弹出层中增加参数“查重字段显示超链接”*}
				{if $LANGUAGETYPE eq 'zh'}
					<span>
						<input type="checkbox" name="hyperlink" value="" onclick="search_accounts(this,'{$MODULE}','settings');" {if $hyperlink eq '0'}checked{/if} id="hyperlink_zh" class="second_switch"  style="margin-bottom:3px;">
						<label for="hyperlink_zh">{'DuplicateCheckShowsHyperlink'|@getFixedLabel}</label>
					</span>
				{elseif $LANGUAGETYPE eq 'en'}
					<span>
						<input type="checkbox" name="hyperlink" value="" onclick="search_accounts(this,'{$MODULE}','settings');" {if $hyperlink eq '0'}checked{/if} id="hyperlink_en" class="second_switch"  style="margin-bottom:3px;">
						<label  for="hyperlink_en">{'DuplicateCheckShowsHyperlink'|@getFixedLabel}</label>
					</span>
				{/if}
				{if ($MODULE eq 'Accounts' || $MODULE eq 'Leads' || $MODULE eq 'ServiceCharge') && $DisplayjoinCheckDup}
					<span class="marL12">
						<input type="checkbox" name="joinCheckDuplicate" id="joinCheckDuplicate"  value="" onclick="search_accounts(this,'{$MODULE}','settings');" {if !empty($joinCheckDup) && $joinCheckDup neq 'no'}checked{/if} class="second_switch"  style="margin-bottom:3px;">
						<label for="joinCheckDuplicate">{'ENABLEJOINTCHECKDUPLICATE'|@getFixedLabel}</label>
						{if !empty($joinCheckDup) && $joinCheckDup neq 'no'}
							（{'CHECKDUPNUMBER'|@getVarFixedLabel:$LIMITCOUNT}。）
						{else}
							（{'NOTECHECKMODULES'|@getmodulefixedlabel:$LIMITCOUNT}）
						{/if}
					</span>
				{/if}
			</div>
		{/if}

		<div class="padB16">
			{'KEYWORDS'|@getFixedLabel}<input class="ld-input-inner marL12" type="text" {if $ACCOUNTNAMECHECK neq ''}value="{$ACCOUNTNAMECHECK}" {elseif $SEARCH_CONTENT neq ''} value="{$SEARCH_CONTENT|escape:'html'}"{/if} placeholder="{$SEARCHLABEL}" name="cheack_repeat_columnname" id="cheack_repeat_columnname" onfocus="cleanall()" style="width:350px;box-sizing: border-box;"/><input type="button" name="search" value="{'FINDDUPLICATES'|@getFixedLabel}" onclick="search_accounts(this,'{$MODULE}');" class="ld-button ld-button-primary marL12">{if $ISADMIN eq 1}<input type="button" name="search" value="{'SETTINGS'|@getFixedLabel}" onclick="button_setDuplicateColumnDisplay(this,'{$MODULE}','','');" class="ld-button">{/if}
		</div>

		{if !empty($joinCheckDup) && $joinCheckDup neq 'no'}
			<div style="font-size: 14px;padding:0 0 12px 0;">{$MODULELABEL} -（{$TABLE_DUPLICATE_NUM}）</div>
		{/if}
		<div id="accounts_table_all">
			<div id="hdScrolllistentries_yy_{$MODULE}" name="hdScrolllistentries_yy_{$MODULE}" style="position: relative;">
				<div id="resize_header_table_divid_{$MODULE}" name="resize_header_table_divid_{$MODULE}" style="visibility: visible; top: 194px; overflow: hidden;">
					<div style="float:left;padding-right: 20px">
						<table id="resize_header_tableid_{$MODULE}" name="resize_header_tableid_{$MODULE}" class="listEntries" border="0" cellspacing="1" cellpadding="0" >
							<tbody>
								<tr>
									{foreach item=fieldlabel key=key from=$TABLEHEADER}
										<th style="width: {$listHeaderWidth[$key]}px;" headermodule="{$listHeaderFieldName[$key].module}" headername="{$listHeaderFieldName[$key].fieldname}" tag="{$key}"><span title="{$fieldlabel}">{$fieldlabel}</span></th>
									{/foreach}
								</tr>
							</tbody>
						</table>
					</div>
				</div>
				<div id="resize_content_table_divid_{$MODULE}" name="resize_content_table_divid_{$MODULE}" style="overflow: auto;max-height: 250px" >
					<table border="0" cellspacing="1" cellpadding="0" id="resize_content_tableid_{$MODULE}" name="resize_content_tableid_{$MODULE}"  class="listEntries marT-53">
						<tbody>
							<tr>
								{foreach item=fieldlabel key=key from=$TABLEHEADER}
									<th style="width: {$listHeaderWidth[$key]}px;" headermodule="{$listHeaderFieldName[$key].module}" headername="{$listHeaderFieldName[$key].fieldname}" tag="{$key}"><span title="{$fieldlabel}">{$fieldlabel}</span></th>
								{/foreach}
							</tr>
							{if $TABLE_DUPLICATE_VALUE eq ''}
								<tr>
									<td class="tdcenter tdborderright" style="background: #fff;" colspan="{$DISPLAYCOLUMNNUMBER}">{'NOTFOUNDANYRECORD'|@getFixedLabel}</td>
								</tr>
							{else}
								{assign var="i" value=0}
								{assign var="k" value=0}
								{assign var="saverecord" value='no'}
								{foreach item=table_value key=col from=$TABLE_DUPLICATE_VALUE}
									{assign var="j" value=$i++}
									{*zkt 20231101 BUG0072940  	kfbcrm-客户-查重-弹出层中单据有多行时，背景色显示不完全 *}
									{if $table_value[0].value eq '#&&&&&#'}
										{assign var="saverecord" value='yes'}
									{/if}
									{if $table_value[0].value neq '#&&&&&#' && $saverecord neq 'yes'}
										{$k = $k+1}
										{assign var="saverecord" value='no'}
									{/if}
									{if $j mod 2 eq '0'}
										<tr id="poprow_{$j}" tmpid="{$k}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on','tmpid');" onmouseover="listOnMouseOver(ld(this),'tmpid');">
											{else}
										<tr id="poprow_{$j}" tmpid="{$k}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On','tmpid');" onmouseover="listOnMouseOver(ld(this),'tmpid');">
									{/if}
									{foreach item=fieldvalue key=columnname from=$table_value}
										{if $fieldvalue.value neq '#&&&&&#'}
											{if $fieldvalue.uitype eq 15}
												<td rowspan="{$fieldvalue.rowspan}">{$fieldvalue.value}</td>
											{else}
												<td rowspan="{$fieldvalue.rowspan}"><span title="">{$fieldvalue.value}</span></td>
											{/if}
										{/if}
									{/foreach}
									</tr>
								{/foreach}
							{/if}

						</tbody>
					</table>
				</div>
			</div>



		</div>

		{if !empty($joinCheckDup) && $joinCheckDup neq 'no'}
			<div style="font-size: 14px;padding:28px 0 12px 0;">{$CHECKMODULELABEL} -（{$JOIN_TABLE_DUPLICATE_NUM}）</div>
			<div id="accounts_table_join">

				<div id="hdScrolllistentries_yy_{$JOINMODULE}" name="hdScrolllistentries_yy_{$JOINMODULE}" style="position: relative;">
					<div id="resize_header_table_divid_{$JOINMODULE}" name="resize_header_table_divid_{$JOINMODULE}" style="visibility: visible; top: 194px; overflow: hidden;">
						<div style="float:left;padding-right: 20px">
							<table id="resize_header_tableid_{$JOINMODULE}" name="resize_header_tableid_{$JOINMODULE}" class="listEntries" border="0" cellspacing="1" cellpadding="0" >
								<tbody>
								<tr>
									{foreach item=fieldlabel key=key from=$JOIN_TABLEHEADER}
										<th style="width: {$join_listHeaderWidth[$key]}px;" headermodule="{$join_listHeaderFieldName[$key].module}" headername="{$join_listHeaderFieldName[$key].fieldname}" tag="{$key}"><span title="{$fieldlabel}">{$fieldlabel}</span></th>
									{/foreach}
								</tr>
								</tbody>
							</table>
						</div>
					</div>
					<div id="resize_content_table_divid_{$JOINMODULE}" name="resize_content_table_divid_{$JOINMODULE}" style="overflow: auto;max-height: 250px" >
						<table border="0" cellspacing="1" cellpadding="0" id="resize_content_tableid_{$JOINMODULE}" name="resize_content_tableid_{$JOINMODULE}"  class="listEntries marT-53">
							<tbody>
							<tr>
								{foreach item=fieldlabel key=key from=$JOIN_TABLEHEADER}
									<th style="width: {$join_listHeaderWidth[$key]}px;" headermodule="{$join_listHeaderFieldName[$key].module}" headername="{$join_listHeaderFieldName[$key].fieldname}" tag="{$key}"><span title="{$fieldlabel}">{$fieldlabel}</span></th>
								{/foreach}
							</tr>
							{if $JOIN_TABLE_DUPLICATE_VALUE eq ''}
								<tr>
									<td class="tdcenter tdborderright" style="background: #fff;" colspan="{$JOIN_DISPLAYCOLUMNNUMBER}">{'NOTFOUNDANYRECORD'|@getFixedLabel}</td>
								</tr>
							{else}
								{assign var="i" value=0}
								{assign var="k" value=0}
								{assign var="saverecord" value='no'}
								{foreach item=table_value key=col from=$JOIN_TABLE_DUPLICATE_VALUE}
									{assign var="j" value=$i++}
									{*zkt 20231101 BUG0072940  	kfbcrm-客户-查重-弹出层中单据有多行时，背景色显示不完全 *}
									{if $table_value[0].value eq '#&&&&&#'}
										{assign var="saverecord" value='yes'}
									{/if}
									{if $table_value[0].value neq '#&&&&&#' && $saverecord neq 'yes'}
										{$k = $k+1}
										{assign var="saverecord" value='no'}
									{/if}
									{if $j mod 2 eq '0'}
										<tr id="poprow_{$j}" tmpid="{$k}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on','tmpid');" onmouseover="listOnMouseOver(ld(this),'tmpid');">
											{else}
										<tr id="poprow_{$j}" tmpid="{$k}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On','tmpid');" onmouseover="listOnMouseOver(ld(this),'tmpid');">
									{/if}

									{foreach item=fieldvalue key=columnname from=$table_value}
										{if $fieldvalue.value neq '#&&&&&#'}
											<td rowspan="{$fieldvalue.rowspan}"><span title="">{$fieldvalue.value}</span></td>
										{/if}
									{/foreach}
									</tr>
								{/foreach}
							{/if}

							</tbody>
						</table>
					</div>
				</div>
			</div>
		{/if}
	</div>
</div>