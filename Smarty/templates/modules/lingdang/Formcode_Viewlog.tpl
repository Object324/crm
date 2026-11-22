<input name="detaillog" type="hidden" value="{$LOGTYPE}"/>
<input name="qrcodebasicid" type="hidden" value="{$qrcodebasicid}"/>

{if $LOGTYPE eq 'no'}
	<div class="Top">
		<table style="100%" width="100%" cellspacing="0" cellpadding="0" border="0">
			<tbody>
			<tr>
				<td class="DivCL b" style="width: 70%;">
					<ul class="D_btn_box b">
						{*//ls 20221231  XUQIU1000922：表单码-分录可编辑（分录日志弹窗）*}
						<li class="D_anu_a" style="width: 80px;{if $LOGTYPE neq 'yes'}border-bottom: 2px solid #6166D3; {/if}">
							<div class="SelectCustomViewlabel" >
								<a name="documentheader" {if $LOGTYPE neq 'yes'}style="color:#6166D3" {/if} type="header" onclick="FormQrCode_ViewlogDetail(ld(this))" relatetag="{$RELATED_MODULE}" title="{'DOCUMENTHEADER'|@getFixedLabel}" fieldid="{$fieldid}" relatedid="{$RECORDID}" detaillog="no">
									<span>{'DOCUMENTHEADER'|@getFixedLabel}</span>
								</a>
							</div>

						</li>
						{if $SHOWDETAILLOG eq 'yes'}
						<li class="D_anu_a" style="width: 80px;{if $LOGTYPE eq 'yes'}border-bottom: 2px solid #6166D3; {/if}">
							<div class="SelectCustomViewlabel" >
								<a name="documententry" {if $LOGTYPE eq 'yes'}style="color:#6166D3"{/if}  type="entry" onclick="FormQrCode_ViewlogDetail(ld(this))" relatetag="{$RELATED_MODULE}" title="{'DOCUMENTENTRY'|@getFixedLabel}" fieldid="{$fieldid}" relatedid="{$RECORDID}" detaillog="yes">
									<span>{'DOCUMENTENTRY'|@getFixedLabel}</span>
								</a>
							</div>
						</li>
						{/if}
					</ul>
				</td>
				<td class="DivCR" valign="middle">
					{*							<input name="qrcodebasicid" type="hidden" value="{$qrcodebasicid}"/>*}
					<div class="PageDiv0 marB10">
						<div class="ld-flex-start">
							<div class="ld-pagenum-div">{$navigationOutput[0]}</div>
							{$navigationOutput[1]}
						</div>
					</div>
					{*	<div class="PageDiv0" style="margin-top: 4px;margin-bottom:4px;">
                            <ul>
                                <li> 共{$FILTER.noofrows}条记录</li>
                                <li><span {if $FILTER.start eq 1}class="no-icon-prevpage" {else}class="icon-prevpage"
                                          onclick="FormQrCode_Viewlog_page(this);"{/if}  pagetype="prev"
                                          start="{$FILTER.start}"></span></li>
                                <li>{$FILTER.start}/{$FILTER.end}</li>
                                <li><span {if $FILTER.start eq $FILTER.end}class="no-icon-nextpage"
                                          {else}class="icon-nextpage" onclick="FormQrCode_Viewlog_page(this);"{/if} pagetype="next"
                                          start="{$FILTER.start}"></span></li>
                                <li class="Input"><input name="pagenum" class="txtBox btn-radius-system pagenum_system"
                                                         start="0" type="text" value="{$FILTER.start}"
                                                         style="width: 3em;margin-right: 0.7em;"></li>
                                <li style="float:right;padding-left:5px;"><span title="GO"><a href="javascript:void(0);"
                                                                                              pagetype="pagenum"
                                                                                              onclick="FormQrCode_Viewlog_page(this);"
                                                                                              start="0">GO</a></span>
                                </li>
                            </ul>
                        </div>*}
				</td>
			</tr>
			</tbody>
		</table>
	</div>

	<div id="hdScrolllistentries_yy_{$RELATED_MODULE}" name="hdScrolllistentries_yy_{$RELATED_MODULE}" style="position: relative;">
		<div style="overflow:auto;max-height:500px;" id="resize_content_table_divid_{$RELATED_MODULE}" name="resize_content_table_divid_{$RELATED_MODULE}">
			<div style="float:left;">
				<table id="resize_content_tableid_{$RELATED_MODULE}" name="resize_content_tableid_{$RELATED_MODULE}"
					   class="listEntries" style="width:{if $TOTAL_WIDTH >0}{$TOTAL_WIDTH}px {else}100%{/if}" border=0
					   cellspacing=1 cellpadding="0">
					<tr>
						{foreach key=index item=_HEADER_FIELD from=$HEADER name=relheadforeach}
							<th style="width:{$TMPWIDTH[$index]}px" tag="{$index+1}">{$_HEADER_FIELD}</th>
						{/foreach}
					</tr>
					{assign var="i" value=0}
					{foreach key=_RECORD_ID name=entriesList item=_RECORD from=$ENTITY}
						{assign var="j" value=$i++}
						{if $smarty.foreach.entriesList.iteration mod 2 eq '1'}
							<tr id="relation_{$RELATED_MODULE}_{$j}" class="lvtColData"
								onmouseout="relationListOnMouseOut('{$RELATED_MODULE}_{$j}','on');"
								onmouseover="relationListOnMouseOver('{$RELATED_MODULE}_{$j}');">
								{else}
							<tr id="relation_{$RELATED_MODULE}_{$j}" class="lvtColDataBj" onmouseout="relationListOnMouseOut('{$RELATED_MODULE}_{$j}','On');" onmouseover="relationListOnMouseOver('{$RELATED_MODULE}_{$j}');">
						{/if}
						{foreach key=index item=_RECORD_DATA from=$_RECORD}
							{* vtlib customization: Trigger events on listview cell onmouseover="vtlib_listview.trigger('cell.onmouseover', $(this))" onmouseout="vtlib_listview.trigger('cell.onmouseout', $(this))"*}
							{if $index|@istdRight:$RELATED_MODULE==true}
								{assign var="tdalign" value='right'}
							{else}
								{assign var="tdalign" value='left'}
							{/if}
							{if $_RECORD_DATA|count_characters:true gt 800}
								<td width="40%" align="{$tdalign}">{$_RECORD_DATA}</td>
							{else}
								<td viewuserid='{$_RECORD_ID}' columnname='{$index}'
									onmouseover="showShareUserEdit(ld(this))"
									onmouseout="HideShareUseEdit(ld(this))" title="{$_RECORD_DATA}" align="{$tdalign}">
									{$_RECORD_DATA}
								</td>
							{/if}
						{/foreach}
						</tr>
						{foreachelse}
						<tr style="height: 25px;" bgcolor="white">
							<td colspan='{$smarty.foreach.relheadforeach.iteration}' align='center'><i
										style="display:inline-block;width:100%;text-align:center;">{'NONE'|@getFixedLabel}</i>
							</td>
						</tr>
					{/foreach}
				</table>
			</div>
		</div>
	</div>
{else}
{*分录*}

		{*zkt 20220920 BUG0056731签到日志，当没有按钮的时候，不要有这个间隙*}
		<div class="Top" {if $RELATEDLISTDATA.entries|@count <= 0 && $MODULE eq 'WeChatUser'} style="display:none"{/if}>
			<table class="bgwhite" width="100%" border="0" cellspacing="0" cellpadding="0" style="100%">
				<tr>
					<td class="DivCL b" style="width: 70%;">
						<ul class="D_btn_box b">
							{*wyt 220926 BUG0056901 图中“单据表头”，“单据分录”选项增加边框，或者鼠标悬浮的背景色*}
							<li class="D_anu_a" style="width: 80px;{if $LOGTYPE neq 'yes'}border-bottom: 2px solid #6166D3; {/if}">
								<div class="SelectCustomViewlabel" >
									<a name="documentheader"  id="documentheader" {if $LOGTYPE neq 'yes'}style="color:#6166D3" {/if}  onclick="FormQrCode_ViewlogDetail(this)" relatetag="{$RELATED_MODULE}" title="{'DOCUMENTHEADER'|@getFixedLabel}" fieldid="{$fieldid}" relatedid="{$RECORDID}" detaillog="no">
										<span>{'DOCUMENTHEADER'|@getFixedLabel}</span>
									</a>
								</div>

							</li>
							{if $SHOWDETAILLOG eq 'yes'}
								<li class="D_anu_a" style="width: 80px;{if $LOGTYPE eq 'yes'}border-bottom: 2px solid #6166D3; {/if}">
									<div class="SelectCustomViewlabel" >
										<a name="documententry" id="documententry" {if $LOGTYPE eq 'yes'}style="color:#6166D3"{/if}   onclick="FormQrCode_ViewlogDetail(this)" relatetag="{$RELATED_MODULE}" title="{'DOCUMENTHEADER'|@getFixedLabel}" fieldid="{$fieldid}" relatedid="{$RECORDID}" detaillog="yes">
											<span>{'DOCUMENTENTRY'|@getFixedLabel}</span>
										</a>
									</div>
								</li>
							{/if}

						</ul>
					</td>
					<td class="DivCR" valign="middle">
						<div class="PageDiv0"  style="margin-top: 4px;margin-bottom:4px;">
							<div class="ld-flex-start">
								<div class="ld-pagenum-div">{$RELATEDLISTDATA.navigation.0}</div>
								{$RELATEDLISTDATA.navigation.1}
							</div>

						</div>
					</td>
				</tr>
			</table>
		</div>
	
		<div id="hdScrolllistentries_yy_{$RELATED_MODULE}" name="hdScrolllistentries_yy_{$RELATED_MODULE}" style="position: relative;">
			<div style=" visibility: visible; top: 194px;overflow:hidden;" id="resize_header_table_divid_{$RELATED_MODULE}">
				<div  style="float:left; padding-right:20px">
					{if $RELATED_MODULE eq 'Digiwinorders' || $RELATED_MODULE eq 'Digiwintickets' || $RELATED_MODULE eq 'Kingdeeorders' || $RELATED_MODULE eq 'Kingdeequotes'}
					<table id="resize_header_tableid_{$RELATED_MODULE}" name="resize_header_tableid_{$RELATED_MODULE}" class="listEntries" style="table-layout:auto;" border=0 cellspacing=1 cellpadding="0" style="width:{if $RELATEDLISTDATA.total_width >0}{$RELATEDLISTDATA.total_width}px;{else}100%{/if}">
						{else}
						{if $MODULE eq 'Campaigns' && ($RELATED_MODULE eq 'Contacts' || $RELATED_MODULE eq 'Leads' || $RELATED_MODULE eq 'Accounts')
						&& $RELATEDLISTDATA.entries|@count > 0}
						<table id="resize_header_tableid_{$RELATED_MODULE}" name="resize_header_tableid_{$RELATED_MODULE}" class="listEntries fir-center" style="width:{if $RELATEDLISTDATA.total_width >0}{$RELATEDLISTDATA.total_width}px {else}100%{/if}" border=0 cellspacing=1 cellpadding="0" >
							{else}
							<table id="resize_header_tableid_{$RELATED_MODULE}" name="resize_header_tableid_{$RELATED_MODULE}" class="listEntries" border=0 cellspacing=1 cellpadding="0" style="width:{if $RELATEDLISTDATA.total_width >0}{$RELATEDLISTDATA.total_width}px {else}100%{/if}" >
								{/if}
								{/if}
								<tr>
									{if $MODULE eq 'Campaigns' && ($RELATED_MODULE eq 'Contacts' || $RELATED_MODULE eq 'Leads' || $RELATED_MODULE eq 'Accounts')
									&& $RELATEDLISTDATA.entries|@count > 0}
										<th style="text-align:center;">
											<input name ="{$RELATED_MODULE}_selectall" class="checkbox-item j-all-checkbox" id="{$MODULE}_{$RELATED_MODULE}_selectCurrentPageRec" onclick="rel_toggleSelect(this.checked,'{$MODULE}_{$RELATED_MODULE}_selected_id','{$RELATED_MODULE}');"  type="checkbox">
										</th>
									{/if}
									{foreach key=index item=_HEADER_FIELD from=$RELATEDLISTDATA.header name=relheadforeach}
										{if $_HEADER_FIELD eq 'OPERATING'|@getFixedLabel}

											<th width="{$RELATEDTABLEWIDTH}" tag="{$index+1}" >{$_HEADER_FIELD}</th>

										{else}
											<th style="width:{$RELATEDLISTDATA.fieldwidth[$index]}px;{if $LOGTYPE eq 'yes'}text-align:center;{/if}" tag="{$index}" headermodule="{$RELATEDLISTDATA.headername.module[$index]}" headername="{$RELATEDLISTDATA.headername.fieldname[$index]}" >{$_HEADER_FIELD}</th>
										{/if}
									{/foreach}
								</tr>
							</table>
				</div>
			</div>



			<div style="overflow:auto;" id="resize_content_table_divid_{$RELATED_MODULE}" name="resize_content_table_divid_{$RELATED_MODULE}">
				{*zkt 20220920 BUG0056732签到日志中，不应该有有横向滑动条*}
				<div  style="float:left; {if $RELATEDLISTDATA.total_width <= 0 && $RELATED_MODULE neq 'signlog' && $RELATED_MODULE neq 'Singin'}padding-right:20px{/if}">
					{if $RELATED_MODULE eq 'Digiwinorders' || $RELATED_MODULE eq 'Digiwintickets' || $RELATED_MODULE eq 'Kingdeeorders' || $RELATED_MODULE eq 'Kingdeequotes'}
					<table class="listEntries marT-53" style="table-layout:auto;" id="resize_content_tableid_{$RELATED_MODULE}" name="resize_content_tableid_{$RELATED_MODULE}" border=0 cellspacing=1 cellpadding="0" style="width:{if $RELATEDLISTDATA.total_width >0}{$RELATEDLISTDATA.total_width}px {else}100%{/if}" cellspacing=1 cellpadding="0">
						{else}
						{if $MODULE eq 'Campaigns' && ($RELATED_MODULE eq 'Contacts' || $RELATED_MODULE eq 'Leads' || $RELATED_MODULE eq 'Accounts')
						&& $RELATEDLISTDATA.entries|@count > 0}
						<table class="listEntries fir-center marT-53" id="resize_content_tableid_{$RELATED_MODULE}" name="resize_content_tableid_{$RELATED_MODULE}"border=0 style="width:{if $RELATEDLISTDATA.total_width >0}{$RELATEDLISTDATA.total_width}px {else}100%{/if}" cellspacing=1 cellpadding="0" >
							{else}
							<table id="resize_content_tableid_{$RELATED_MODULE}" name="resize_content_tableid_{$RELATED_MODULE}" class="listEntries marT-53" style="width:{if $RELATEDLISTDATA.total_width >0}{$RELATEDLISTDATA.total_width}px {else}100%{/if}" border=0 cellspacing=1 cellpadding="0" >
								{/if}
								{/if}
								<tr>
									{if $MODULE eq 'Campaigns' && ($RELATED_MODULE eq 'Contacts' || $RELATED_MODULE eq 'Leads' || $RELATED_MODULE eq 'Accounts')
									&& $RELATEDLISTDATA.entries|@count > 0}
										<th style="text-align:center;">
											<input name ="{$RELATED_MODULE}_selectall" class="checkbox-item j-all-checkbox" id="{$MODULE}_{$RELATED_MODULE}_selectCurrentPageRec" onclick="rel_toggleSelect(this.checked,'{$MODULE}_{$RELATED_MODULE}_selected_id','{$RELATED_MODULE}');"  type="checkbox">
										</th>
									{/if}
									{foreach key=index item=_HEADER_FIELD from=$RELATEDLISTDATA.header name=relheadforeach}
										{if $_HEADER_FIELD eq 'OPERATING'|@getFixedLabel}

											<th width="{$RELATEDTABLEWIDTH}" tag="{$index+1}">{$_HEADER_FIELD}</th>

										{else}
											<th style="width:{$RELATEDLISTDATA.fieldwidth[$index]}px" tag="{$index}" headermodule="{$RELATEDLISTDATA.headername.module[$index]}" headername="{$RELATEDLISTDATA.headername.fieldname[$index]}"  >{$_HEADER_FIELD}</th>
										{/if}

									{/foreach}
								</tr>

								{assign var="i" value=0}
								{foreach key=_RECORD_ID name=entriesList item=_RECORD from=$RELATEDLISTDATA.entries}
									{assign var="j" value=$i++}
									{if $smarty.foreach.entriesList.iteration mod 2 eq '1'}
										<tr id="relation_{$RELATED_MODULE}_{$j}" class="lvtColData" onmouseout="relationListOnMouseOut('{$RELATED_MODULE}_{$j}','on');" onmouseover="relationListOnMouseOver('{$RELATED_MODULE}_{$j}');">
											{else}
										<tr id="relation_{$RELATED_MODULE}_{$j}" class="lvtColDataBj" onmouseout="relationListOnMouseOut('{$RELATED_MODULE}_{$j}','On');" onmouseover="relationListOnMouseOver('{$RELATED_MODULE}_{$j}');">
									{/if}
									{if $MODULE eq 'Campaigns' && ($RELATED_MODULE eq 'Contacts' || $RELATED_MODULE eq 'Leads' || $RELATED_MODULE eq 'Accounts')}
										<td style="text-align:center;" onclick="rel_check_object_parent_td(this)"><input class="checkbox-item j-all-checkbox" name="{$MODULE}_{$RELATED_MODULE}_selected_id" id="{$_RECORD_ID}" value="{$_RECORD_ID}" onclick="rel_check_object(this,'{$RELATED_MODULE}');" type="checkbox"  {$RELATEDLISTDATA.checked.$_RECORD_ID}></td>
									{/if}
									{foreach key=index item=_RECORD_DATA from=$_RECORD}
										{* vtlib customization: Trigger events on listview cell onmouseover="vtlib_listview.trigger('cell.onmouseover', $(this))" onmouseout="vtlib_listview.trigger('cell.onmouseout', $(this))"*}
										{if $index|@istdRight:$RELATED_MODULE==true}
											{assign var="tdalign" value='right'}
										{else}
											{assign var="tdalign" value='left'}
										{/if}
										{if $_RECORD_DATA|count_characters:true gt 800}
											<td width="40%" align="{$tdalign}">{$_RECORD_DATA}</td>
										{elseif $index eq 'detail' && $LOGTYPE eq 'yes'}
											{assign var=row value=0}
											{foreach key=lineitem_id item=detailinfo from=$_RECORD_DATA}
												{assign var=row value=$row+1}
												{foreach key=columnname item=value from=$detailinfo}
													<td align="{$RELATEDLISTDATA.tdalign.$columnname}">
														<span {if $RELATEDLISTDATA.changedcolumn.$_RECORD_ID.$lineitem_id.$columnname eq 'yes'}style="color:red;"{/if}>{$value}</span></td>
												{/foreach}
												</tr>
												{if $row neq sizeof($_RECORD_DATA)}
													<tr id="relation_{$RELATED_MODULE}_{$j}"  class="lvtColData" onmouseout="relationListOnMouseOut('{$RELATED_MODULE}_{$j}','On');" onmouseover="relationListOnMouseOver('{$RELATED_MODULE}_{$j}');">
												{/if}
											{/foreach}
											</tr>
										{else}
											<td   {if $RELATED_MODULE eq 'SharedUsers' &&($index eq 'viewuserduty' || $index eq 'viewuserremark')} viewuserid='{$_RECORD_ID}' columnname='{$index}' onmouseover="showShareUserEdit(ld(this))"
												onmouseout="HideShareUseEdit(ld(this))" {/if}
													{if $LOGTYPE eq 'yes'}rowspan="{$RELATEDLISTDATA.rowspan.$_RECORD_ID}" align="{$RELATEDLISTDATA.tdalign.$index}"{else}align="{$tdalign}"{/if}
											>
												{if $RELATED_MODULE eq 'SharedUsers'}
													<span name='td_content'> {"\n"|str_replace:"<br>":$_RECORD_DATA}</span>
												{else}
													{$_RECORD_DATA}
												{/if}
												{if $RELATED_MODULE eq 'SharedUsers' }
													{if $index eq 'viewuserduty'}
														<a tag="edit"   style="float:right ;display:none">{'EDIT'|getFixedLabel}</a>
														<input  type="text" showtype="editshow"  class="detailedViewTextBox" name="{$index}"
																style="width:100%;display:none" value="{$_RECORD_DATA}" />


														<div  showtype='editshow' style="display:none">
															<a    name='save' style="float:left;">{'SAVE'|getFixedLabel}</a>
															<span   style="float:left;">{'OR'|getFixedLabel}</span>
															<a    name='cancel'   style="float:left;">{'CANCEL'|getFixedLabel}</a>
														</div>
													{elseif $index eq 'viewuserremark'}

														<a tag="edit"  style="float:right;display:none" columnname="{$index}">{'EDIT'|getFixedLabel}</a>
														<textarea rows="8"  cols="10"
																  showtype='editshow' style="width:98%;display:none;height:52px" class="detailedViewTextBox" name="{$index}" >
                                              {$_RECORD_DATA}
                                              </textarea>
														<div  showtype='editshow' style="display:none">

															<a style="float:left;" name='save'  >{'SAVE'|getFixedLabel}</a>
															<span style="float:left;"  >{'OR'|getFixedLabel}</span>
															<a style="float:left;" name='cancel'  >{'CANCEL'|getFixedLabel}</a>
														</div>
													{/if}

												{/if}
											</td>
										{/if}
										{* END *}
									{/foreach}
									</tr>
									{foreachelse}
									<tr style="height: 25px;" bgcolor="white">
										<td colspan='{$smarty.foreach.relheadforeach.iteration}' align='center'><i style="display:inline-block;width:100%;text-align:center;">{'NONE'|@getFixedLabel}</i></td>
									</tr>
								{/foreach}
{*								{if $RELATEDLISTDATA.totalfldhtml !=''}*}
{*									{$RELATEDLISTDATA.totalfldhtml}*}
{*								{/if}*}
							</table>
				</div>

			</div>
		</div>

{/if}


