<script language="javascript" type="text/javascript" src="{$JSURL}include/js/special_webuploader.js"></script>

<script type="text/javascript">
var current_language = "{$current_language}";
</script>
<script language="javascript" type="text/javascript" src="include/js/modules/Home/Coordination.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/search.js?v={$GLOBALMINVERSION}"></script>
<!-- <script language="javascript" type="text/javascript" src="modules/Home/swfobject.js"></script> -->
<script language="javascript" type="text/javascript" src="uploaddify/jquery.uploadify.min.js"></script>
{if $DELETE eq 'true' && $ISADMIN neq 1}
	<div class='noResultBG' style="margin: 190px auto;">
		<div class='noResultContent'>
			<div class="divNoRecord">{'YOUARENOTALLOWEDTOOTHEROTHERUSERSDATE'|@getFixedLabel}！</div>
			<div class="divNoPermission">
				<a href='javascript:window.history.back();'>{'RETURN'|@getFixedLabel}</a>
			</div>
		</div>
	</div>
{else}
	<div class="main_grid">
		<div class="main_grid_box">
		    <div class="grid-analysis-box">
		        <div class="grid-analysis-header">
		        </div>
		        <div class="cont_wrap clear_float">
					<div class="Cbox">
						<div class="middle">
							<input type="hidden" id="current_userid" value="{$CURRENT_USERID}"/>
							<input type="hidden" id="cur_releasetext" value="{$cur_releasetext}"/>
							<input type="hidden" id="cur_panel_tag" value="{$cur_panel_tag}"/>
							<input type="hidden" id="languageType" value="{$LANGEUAGETYPE}"/>
							<input type="hidden" id="saleskit_showtype" name="saleskit_showtype" value=""/>
							<input type="hidden" id="saleskit_listinfo" name="saleskit_listinfo" value=""/>
{*							<input type="hidden" id="deploy_value" value="{$DEPLOY}" />*}
							<table cellspacing="0" cellpadding="0" border="0" width="100%">
								<input type="hidden" id="roleid" value="{$ROLEID}"/>
								<input type="hidden" id="report_user_id" name="report_user_id" value="{$REPORT_USER_ID}" />
								<tr>
									{if $WORKREPORTTYPE neq 'RELATE'}
								      	<td style=" width: 220px; vertical-align: top;">
												<div class="Cbox_L" id="stream">
													<div class="head">
														<a onclick="ListReferenceLinkClick(ld(this),event)" referencerecord="{$CURRENT_USERID}" referencemodule="Users" href="javascript:void" {if $ISDELETE eq 'no'} style="display: inline-block;"{/if}>
															<img src="{$USERINFO.image}"/>
															<span class="head_span">{$USERINFO.name}</span>
														</a>
														{if $ISDELETE eq 'yes'}
															<span><input class="createauto" onclick="delete_log()" style="display:none" name="New" value="{'DELETELOG'|@getFixedLabel}" type="button"></span>
														{/if}
													</div>
													{if {'COOPERATIVEWORKTITLE'|@getFixedLabel} neq '' }
														<div name="stream_group_list" class="group-list linefeed">
													{else}
														<div name="stream_group_list" class="group-list linefeed ui-hide">
													{/if}
															<p name="stream_text">{'COOPERATIVEWORKTITLE'|@getFixedLabel}</p>
															{if $ISADMIN  eq 'on'}
																<a name="stream_text_set" onclick="setWorkReportText('edit')" style="float:right;display: none;" href="javascript:void(0);">{'EDIT'|@getFixedLabel}</a>
																<a name="stream_text_cancel" onclick="setWorkReportText('cancel')" style="float:right;display: none;padding-right: 5px" href="javascript:void(0);">{'CANCEL'|@getFixedLabel}</a>
																<a name="stream_text_save" onclick="setWorkReportText('save')" style="float:right;display: none;padding-right: 5px" href="javascript:void(0);">{'SAVE'|@getFixedLabel}</a>
															{/if}
														</div>
													<div class="work-nav-inner">
														<ul>
															<li class="task-item left-icon icon-work cur-icon" title="{'ALL'|@getFixedLabel}">
																<a href="javascript:void(0);" class="link" tag="all">
																	<span class="content">{'ALL'|@getFixedLabel}</span><span class="num-icon"></span>
																</a>
															</li>
														</ul>
														<ul>
															<li class="task-item left-icon icon-desk expand" title="{'MYWORKBENCH'|@getFixedLabel}">
																<a href="javascript:void(0);" class="link more-nav-icon" tag="myself">
																	<span class="content">{'MYWORKBENCH'|@getFixedLabel}</span><span class="num-icon"></span>
																</a>
															</li>
															<li class="sub-ul-wrapper" style="display: list-item;">
																<ul class="sub-ul">
																	{foreach from=$WORKREPORTSHOW item=showcontent key=itemindex}
														              	{if $showcontent.type eq 'weibo' }
														                	<li class="task-item j-can-refresh" title="{'BLOG'|@getFixedLabel}">
																				<a href="javascript:void(0);" class="link" tag="weibo">
																					<span class="content">{'BLOG'|@getFixedLabel}</span><!--<span class="num-icon" style="display: inline-block;">716</span>-->
																				</a>
																			</li>
														              	{else if $showcontent.type eq 'dayreport'}
														                	<li class="task-item j-can-refresh" title="{'JOURNAL'|@getFixedLabel}">
																				<a href="javascript:void(0);" class="link" tag="logday">
																					<span class="content">{'JOURNAL'|@getFixedLabel}</span><span class="num-icon" style="display: none;"> </span>
																				</a>
																			</li>
														              	{else if $showcontent.type eq 'weekreport'}
														                	<li class="task-item j-can-refresh" title="{'WEEKPLAN'|@getFixedLabel}">
																				<a href="javascript:void(0);" class="link" tag="logweek">
																					<span class="content">{'WEEKPLAN'|@getFixedLabel}</span><span class="num-icon" style="display: none;"> </span>
																				</a>
																			</li>
														              	{else if $showcontent.type eq 'monthreport'}
														                	<li class="task-item j-can-refresh" title="{'MONTHPLAN'|@getFixedLabel}">
																				<a href="javascript:void(0);" class="link" tag="logmonth">
																					<span class="content">{'MONTHPLAN'|@getFixedLabel}</span><span class="num-icon" style="display: none;"> </span>
																				</a>
																			</li>
														              	{else if $showcontent.type eq 'cocmd'}
															           		<li class="task-item j-can-refresh" title="{'TASK'|@getFixedLabel}">
																				<a href="javascript:void(0);" class="link" tag="cocmd">
																					<span class="content">{'TASK'|@getFixedLabel}</span><span class="num-icon" style="display: none;"> </span>
																				</a>
																			</li>
														              	{/if}
											    					{/foreach}
																</ul>
															</li>
														</ul>
														<ul>
															<li class="task-item left-icon icon-session expand" title="{'MYNEWS'|@getFixedLabel}">
																<a href="javascript:void(0);" class="link more-nav-icon" tag="mymsg">
																	<span class="content">{'MYNEWS'|@getFixedLabel}</span><span class="num-icon"></span>
																</a>
															</li>
															<li class="sub-ul-wrapper" style="display: list-item;">
																<ul class="sub-ul">
																	<li class="task-item j-can-refresh" title="{'@MY'|@getFixedLabel}">
																		<a href="javascript:void(0);" class="link" tag="@me">
																			<span class="content">{'@MY'|@getFixedLabel}</span><span class="num-icon" style="display: none;"> </span>
																		</a>
																	</li>
																	<li class="task-item j-can-refresh" title="{'MYREPLY'|@getFixedLabel}">
																		<a href="javascript:void(0);" class="link" tag="myreply">
																			<span class="content">{'MYREPLY'|@getFixedLabel}</span><span class="num-icon" style="display: none;"> </span>
																		</a>
																	</li>
																	<li class="task-item j-can-refresh" title="{'MYPRAISE'|@getFixedLabel}">
																		<a href="javascript:void(0);" class="link" tag="mypraise">
																			<span class="content">{'MYPRAISE'|@getFixedLabel}</span><span class="num-icon" style="display: none;"> </span>
																		</a>
																	</li>
																</ul>
															</li>
														</ul>
													</div>
												</div>
									  	</td>
									{/if}
								  	<td style=" width: 630px; vertical-align: top;">
								  		<!--编辑框-->
									 	<div class="{if $WORKREPORTTYPE neq 'RELATE'}Cbox_C{else}Cbox_G{/if}">
										  <form name="sendLog" method="POST" action="index.php" ENCTYPE="multipart/form-data" onsubmit="puyoungJS_DialogBox.block();">
										  	<div class="pubclear Edit_box" style="{if $REPORT_USER_ID neq '' || $MASSDELETE eq 'true' ||$SEARCHSCOPE eq 'all'}display:none;{/if}" >
													<div class="Top_menu">
													  <ul class="menuUl" id='stream-hsent-title'>
														  {foreach from=$WORKREPORTSHOW item=showcontent key=itemindex}
									              {if $showcontent.type eq 'weibo' }
									                <li><a href="javascript:void(0);" tag='weibo' cont='sendWeibo' {if $itemindex eq 0} class="curr"{/if}>{'BLOG'|@getFixedLabel}</a></li>
									              {else if $showcontent.type eq 'dayreport'}
									                <li><a href="javascript:void(0);" tag='day' cont='sendLog' {if $itemindex eq 0} class="curr" {/if}>{'JOURNAL'|@getFixedLabel}</a></li>
									              {else if $showcontent.type eq 'weekreport'}
									                <li><a href="javascript:void(0);" tag='week' cont='sendLog' {if $itemindex eq 0} class="curr" {/if}>{'WEEKPLAN'|@getFixedLabel}</a></li>
									              {else if $showcontent.type eq 'monthreport'}
									                <li><a href="javascript:void(0);" tag='month' cont='sendLog' {if $itemindex eq 0} class="curr" {/if}>{'MONTHPLAN'|@getFixedLabel}</a></li>
									              {else if $showcontent.type eq 'cocmd'}
										           		<li><a href="javascript:void(0);" tag='cocmd' cont='cocmd' {if $itemindex eq 0} class="curr" {/if}>{'TASK'|@getFixedLabel}</a></li>
									              {/if}
									    				{/foreach}
													  </ul>
													  <div class="trigger_bg"><span class="icon-homeimg icon-worka ui-hide"></span></div>
													</div>
													<div class="pubclear writeContent ui-hide" id="sendLog">
														<span class="panel-visible-h">×</span>
														<div id="sendTxt">
															<div tag="workfield">
																<div entitytype='sendWeibo' {if $WORKREPORTSHOW[0].type eq 'weibo'} {else} class='ui-hide'{/if}><!-- 发微博的界面 -->
																	<div type="worktype_1">
																		<fieldset name="editfieldset">
																			<textarea area="edittextarea" class="sendLog" name='workexperience' style="height:{$weibo_cocmd_info.weibo.defaultheight}px" is_mandatory='0'>{$weibo_cocmd_info.weibo.defaultvalue}</textarea>
																			<a name="workreporteditcopy" class="workreporteditcopy marT-20" href="javascript:void(0);">{'COPY'|@getFixedLabel}</a>
																		</fieldset>
																	</div>
																</div>
																<div entitytype='sendLog' class='ui-hide'><!-- 发日志的界面 -->
																{foreach key=worktype item=workfld from=$WORKFIELDARRAY name=workfldforeach}
					                        {if $smarty.foreach.workfldforeach.first&&($WORKREPORTSHOW[0].type eq 'dayreport'||$WORKREPORTSHOW[0].type eq 'weekreport'||$WORKREPORTSHOW[0].type eq 'monthreport')}
					                          <div type="worktype_{$worktype}" >
					                        {else}
																	<div type="worktype_{$worktype}" class='ui-hide'>
									                {/if}
																		{foreach key=key item=item from=$workfld}
																			{if $key eq 'saleskit_day' || $key eq 'saleskit_week' || $key eq 'saleskit_month'}
																				<fieldset name="editfieldset" id="fieldset_{$key}" style="display:none;">
																			{else}
																				<fieldset name="editfieldset" >
																			{/if}
																				<label style="font-weight: normal;">{if $item.is_mandatory eq '0'}<font color="red">*</font>{/if}{$item.label}</label>
																				<textarea class="sendLog" area="edittextarea" name='{$key}' style='height:{$item.defaultheight}px' is_mandatory='{$item.is_mandatory}' defaultvalue='{$item.defaultvalue}'>{$item.defaultvalue}</textarea>
																				<a name="workreporteditcopy" class="workreporteditcopy marT-20" href="javascript:void(0);">{'COPY'|@getFixedLabel}</a>
																				</fieldset>
																		{/foreach}
																	</div>
																{/foreach}
																</div>
																<div entitytype='cocmd' {if $WORKREPORTSHOW[0].type eq 'cocmd'} {else} class='ui-hide'{/if}><!-- 发任务的界面 -->
																	<div type="worktype_1">
																		<fieldset name="editfieldset">
																			<textarea class="sendLog" area="edittextarea" name='workexperience' is_mandatory='0' style="height:{$weibo_cocmd_info.cocmd.defaultheight}px">{$weibo_cocmd_info.cocmd.defaultvalue}</textarea>
																			<a name="workreporteditcopy" class="workreporteditcopy marT-20" href="javascript:void(0);">{'COPY'|@getFixedLabel}</a>
																		</fieldset>
																	</div>
																</div>
																{if $smarty.foreach.workfldforeach.first&&($WORKREPORTSHOW[0].type eq 'dayreport'||$WORKREPORTSHOW[0].type eq 'weekreport'||$WORKREPORTSHOW[0].type eq 'monthreport')}
									                <div entitytype='saleskit'>
									              {else}
																	<div entitytype='saleskit' class='ui-hide'>
									              {/if}
									              		<fieldset>
									                    	<label class="ld-tab-work-data">
																{'DATE'|@getFixedLabel}：
																<a href="javascript:void(0)" id="saleskit_this_week" title="{'thisweek'|@getFixedLabel}" class="curr_data">{'thisweek'|@getFixedLabel}</a>
																<a href="javascript:void(0)" id="saleskit_last_week" title="{'lastweek'|@getFixedLabel}">{'lastweek'|@getFixedLabel}</a>
																<a href="javascript:void(0)" id="saleskit_lastlast_week" title="{'beflastweek'|@getFixedLabel}">{'beflastweek'|@getFixedLabel}</a>
																<a href="javascript:void(0)" id="saleskit_this_month" title="{'thismonth'|@getFixedLabel}" class="curr_data">{'thismonth'|@getFixedLabel}</a>
																<a href="javascript:void(0)" id="saleskit_last_month" title="{'lastmonth'|@getFixedLabel}">{'lastmonth'|@getFixedLabel}</a>
																<a href="javascript:void(0)" id="saleskit_lastlast_month" title="{'beflastmonth'|@getFixedLabel}">{'beflastmonth'|@getFixedLabel}</a>
																<span id="kuohao_left">(</span><span tag="saleskit_date" id="span_saleskit_date"></span><span id="kuohao_right">)</span>
															</label>
									              		</fieldset>
																		<fieldset>
																			<label style="font-weight: normal;line-height: 24px">{'Jobbriefing'|@getFixedLabel}</label>
																			<a href="javascript:void(0)" title="{'Generatebrief'|@getFixedLabel}" id="saleskit_select_day" style="display:none;" tag="">{'Generatebrief'|@getFixedLabel}</a>
																			<a href="javascript:void(0)" title="{'Generatebrief'|@getFixedLabel}" id="saleskit_select_week" style="display:none;" tag="">{'Generatebrief'|@getFixedLabel}</a>
																			<a href="javascript:void(0)" title="{'Generatebrief'|@getFixedLabel}" id="saleskit_select_month" style="display:none;" tag="">{'Generatebrief'|@getFixedLabel}</a>
                                                                            {if $ISADMIN  eq 'on'}
                                                                                <i class="ld-fonticon ld-fonticon-set" style="float:right" href="javascript:void(0);" onclick="setbriefcomponent(this);" title="{'SETTINGS'|@getFixedLabel}" id="saleskit_select_day" tag=""></i>
                                                                            {/if}
																			<div name="Salesbriefing">
																				{include file="Home/Briefcomponent.tpl"}
																			</div>
																		</fieldset>
																</div>
															</div>
															<fieldset id="sendLogAcctlist" style='display:none;'>
																<div>
																	<label>{'Accounts'|@getTransTab}</label>
																	<ul class="reader-bar-list"></ul>
																</div>
															</fieldset>
															<fieldset id="sendLogContlist" style='display:none;'>
																<div>
																	<label>{'Contacts'|@getTransTab}</label>
																	<ul class="reader-bar-list"></ul>
																</div>
															</fieldset>
															<fieldset id="sendLogProlist" style='display:none;'>
																<div>
																	<label>{'Products'|@getTransTab}</label>
																	<ul class="reader-bar-list"></ul>
																</div>
															</fieldset>
															<fieldset id="sendLogUploadImg" style='display:none;'>
																<div>
																	<label>{'PICTURE'|@getFixedLabel}</label>
																	<ul class="upload-img pubclear uploader-list" style="width: 100%"></ul>
																</div>
															</fieldset>
															<fieldset id="sendLogUploadAtt" style='display:none;'>
																<div>
																	<label>{'Attachment'|@getFixedLabel}</label>
																	<ul class="upload-att pubclear uploader-list" style="width: 100%"></ul>
																</div>
															</fieldset>
														</div>

														<input type="hidden" name="sendLog_at_user" />
														<input type="hidden" name="sendLog_at_group" />
														<input type="hidden" name="savetype" value='day'/>
														<input type="hidden" name="download_permit" id="download_permit" value="{$download_permit}">
														<input type="hidden" name="preview_permit" id="preview_permit" value="{$preview_permit}">
														<!-- <div id="dropbox"></div> -->
														<div id="queue"></div>
														<div class="btns" style="position:relative">
															<a class="addimg" href="javascript:void(0);" title="{'ADDPICTURES'|@getFixedLabel}">
																<div name="multiple" id="multiple" class="homeAddfu"></div>
															</a>
															<a class="addfu" href="javascript:void(0);" title="{'ADDATTACHMENTS'|@getFixedLabel}">
																<div name="multiple_att" id="multiple_att" class="wu-example homeAddfu"></div>
															</a>
															<a class="addtouch" href="javascript:void(0);" title="{'ADDCOLLEAGUES'|@getFixedLabel}"></a>
															<a class="addemojicookie" href="javascript:void(0);" title="{'ADDEXPRESSION'|@getFixedLabel}"></a>
															<a class="addcustomer" href="javascript:void(0);" title="{'Accounts'|@getTransTab}"></a>
															<a class="addcontact" href="javascript:void(0);" title="{'Contacts'|@getTransTab}"></a>
															<a class="addproducts" href="javascript:void(0);" title="{'Products'|@getTransTab}"></a>
															{if $ISADMIN eq 1}
																<a class="settingfield ui-hide" href="index.php?module=Settings&action=WorkTemplate&blockidsetting=3&fieldidsetting=61" title="定制日志模板" target="_blank">{'LBL_CUSTOMLOGTEMPLATE'|@getFixedLabel}</a>
															{/if}
														</div>
														<div id="homeprogressbar" class="progress height10 marB0" style="display: none;">
															<div class="progress-bar" id="progressbar" role="progressbar" aria-valuenow="60"
															aria-valuemin="0" aria-valuemax="100">
																<span class="sr-only"></span>
															</div>
														</div>
													<div class="pubclear pubEnd" id='sendLogFoot'>
														<div class="panel sendLog" tag='reader'>
															<input type="hidden" name="reuserid" value="{$USERINFO.readerid}">
															<input type="hidden" name="reusername" value='{$USERINFO.readername}'>
														  <span class="pep-label"><font class="redFont">*</font>{'REVIEWER'|@getFixedLabel}</span>
														  <div class="selectbar">
																<ul class="reader-bar-list" name="reuser_bar_list">
																	{if $USERINFO|@is_array && count($USERINFO) gt 0}
																	<li emptype="p" userid="{$USERINFO.readerid}">
																		<span class="item-name">{$USERINFO.readername}</span><span class="remove-h">×</span>
																  	</li>
																  	{/if}
																</ul>
															  <div name="reuser_bar_button">
																  <span class="input-tip"><i class="prefix">+</i>{'SELECTREVIEWERS'|@getFixedLabel}</span>
																  <input class="input-field ui-hide" type="text" autocomplete="off" value=''>
																  <span class="show-select-panel"><span class="icon-homeimg icon-workp"></span></span>
															  </div>
														  </div>
														</div>
														<div class="panel cocmd" tag='cmduser'>
															<span class="pep-label"><font class="redFont">*</font>{'EXECUTORS'|@getFixedLabel}</span>
														  	<div class="selectbar">
																<ul class="reader-bar-list">
																<li emptype="p" userid="{$USERINFO.readerid}">
																		<span class="item-name">{$USERINFO.readername}</span><span class="remove-h">×</span>
																 </li>
																</ul>
															   <span class="input-tip"><i class="prefix">+</i>{'SELECTEXECUTOR'|@getFixedLabel}</span>
															   <input class="input-field ui-hide" type="text" autocomplete="off" value=''>
															   <span class="show-select-panel"><span class="icon-homeimg icon-workp"></span></span>
														  	</div>
														  	<div style="vertical-align: middle; line-height: 30px;">
																<span class="pep-label"><font class="redFont">*</font>{'Completiontime'|@getFixedLabel}</span>
																<input type="text" id="d241" onclick="WdatePicker({ldelim}dateFmt:'yyyy年MM月dd日'{rdelim})" class="Wdate-noimg" placeholder="{'pleaseselectdate'|@getFixedLabel}"/><input type="text" id="d242" onclick="WdatePicker({ldelim}dateFmt:'HH:mm'{rdelim})" class="Wdate-noimg marL10" placeholder="{'Pleaseselecttime'|@getFixedLabel}"/>
														  	</div>
														</div>
														<div class="CCrange selectbar" tag='ccrange'>
															<ul class="reader-bar-list">
															</ul>
															<span class="input-tip"><i class="prefix">+</i>{'SELECTCCRANGE'|@getFixedLabel}</span>
															<input class="input-field ui-hide" type="text" autocomplete="off" value=''>
															<span class="show-select-panel"><span class="icon-homeimg icon-workp"></span></span>
														</div>
													</div>
												</div>
												<div class="pubclear pub_btn rfloat" style="display:none;">
													<input class="ld-button ld-button-primary" id='ReleaseBtn' type="button" value="{'RELEASENEW'|@getFixedLabel}"/>
												</div>
											</form>
											<div class="pubclear form-thumb" style="display: block;">
								        <div class="input-empty-text fn-left">{$cur_releasetext}</div>
													</div>
									  </div>
										<!--分类-->
										<div class="pubclear ConSwitch" {if $WORKREPORTTYPE eq 'RELATE' || $REPORT_USER_ID neq '' || $MASSDELETE eq 'true'||$SEARCHSCOPE eq 'all'}style='display:none'{/if}>
										  <ul class="menuUl">
												<li tag="all"><a href="javascript:void(0);" tag='1'>{'ALL'|@getFixedLabel}</a></li>
												<li class="linebg" tag="related"><a class="curr" href="javascript:void(0);" tag='10'>{'IRELATED'|@getFixedLabel}</a>
												<li tag="Untreated"><a href="javascript:void(0);" tag='2'>{'Pending'|@getFixedLabel}</a><span class='num ui-hide'>17</span></li>
												<li tag="Processed"><a href="javascript:void(0);" tag='3'>{'Processed'|@getFixedLabel}</a></li>
												<li tag="mine"><a href="javascript:void(0);" tag='4'>{'IINITIATED'|@getFixedLabel}</a></li>
												{foreach key=key item=item name=nav from=$WORKRANGEARR}
													{*ls 2021-10-20 【1002089】工作汇报，工作类别增加编辑功能(类别设置长度过长需截取)*}
{*													<li tag="{$key}"><a href="javascript:void(0);" tag="5">{$item}</a></li>*}
													<li tag="{$key}">
														<a href="javascript:void(0);" tag="5">
															{if $current_language eq 'zh'}
																{if is_string($item) && $item|mb_strlen:'utf-8' gt 4}{$item|mb_substr:0:4:'utf-8'}...{else}{$item}{/if}
															{else}
																{if is_string($item) && $item|strlen gt 20}{$item|substr:0:20:'utf-8'}...{else}{$item}{/if}
															{/if}
														</a>
													</li>
												{/foreach}
										  </ul>
										  <a class="screen" href="javascript:;" id="advSearch_div">{'screen'|@getFixedLabel}
										  	<b id="search_arrow_down" class="jiantou jiantou_down" style="margin-top: 19px;"></b>
										  	<b id="search_arrow_up" class="jiantou jiantou_up" style="margin-top: 23px;display:none;"></b>
										  </a>
										</div>
										<!--筛选-->
										<div class="pubclear filter-box" {if $WORKREPORTTYPE eq 'RELATE'}style='display:none'{/if} {if $REPORT_USER_ID neq '' || $MASSDELETE eq 'true'} style="border-top: 1px solid #d8d8d8;"{/if}>
										  <div class="pubclear filter-conten" style="display:none;">
												<div class="w-filter-select date-select">
													<a class="value j-date-value" href="javascript:;" data-value="all">{'ALLTIME'|@getFixedLabel}<span class="title-icon"> </span></a>
												</div>
												{if $INFO eq ''}
												<div id="_select_sponsor_div" class="CCrange selectbar">
													<ul class="reader-bar-list"></ul>
													<span id="select_sponsor" class="input-tip"><i class="prefix">+</i>{'Sponsor'|@getFixedLabel}</span>
													<input type="hidden" name="sponsor_value" id="sponsor_value" value="" />
												</div>
												{/if}
												<div class="w-filter-wrapper marL12">
													<input class="filter-keyword j-keywords" placeholder="{'INPUTAKEYWORDSQUERY'|@getFixedLabel}" value="" type="text">	<a id="basicsearch_submit" href="javascript:;" class="btn-search" title="{'SEARCHNEW'|@getFixedLabel}"></a>
												</div>
											</div>
										</div>
										<div class="clear"></div>
										<!--加载begin  0052396	zxm注释 20230601 点击OA表单的工作汇报，页面会有两个加载齿轮(BUG0054890 )-->
{*										<div id="coordinationStatus" class="list-loading" style="">*}
{*											<span class="loading-icon"><img src="themes/icon/loading22.gif"></span>*}
{*											<span class="loading-text">{'LOADING'|@getFixedLabel}</span>*}
{*										</div>*}
										<div class="clear"></div>
										<!--加载end-->
										<div class="pubDetialC" style="celar:both;">
											<!--用户发布消息详情-->
											<div id="worklist_page_1">
											</div>
										</div>
									</td>
									{if $WORKREPORTTYPE neq 'RELATE'}
										{if $HasCalendar eq 'yes'}
											<td valign="top">
												<div class="Cbox_R" style="position: relative;">
													<div class="work-calendar">
														<div class="calendar-header">
															<h3 class="calendar-header-title">{'Calendar'|@getTransTab}</h3>
															{if $HasCalendarCreate eq 'yes'}
																<span class="add-new">{'CREATE'|@getFixedLabel}</span>
															{else}
																<div style="height: 33px;"></div>
															{/if}
															<p class="line"></p>
														</div>
														<div class="calendar-content">
															<div class="wh_container">
												        <div class="wh_content_all">
												          <div class="wh_top_changge">
												            <li>
												              <div class="wh_jiantou1"></div>
												            </li>
												            <li class="wh_content_li"></li>
												            <li>
												              <div class="wh_jiantou2"></div>
												            </li>
												          </div>
												          <div class="wh_content wh_content_weeks">
												          </div>
												          <div class="wh_content wh_content_days">
												          </div>
												        </div>
												      </div>
														</div>
														<div class="calendar-content-list">

														</div>
													</div>
												</div>
										  	</td>
									  	{/if}
								  	{/if}
								</tr>
							</table>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
{/if}
<!-- <textarea cols="" rows=""  style="width:640px; height:210px;font-size:12px" class="appoint_content" id="appoint_content1">在这里，您只需要输入预约内容、预约时间，专属您的服务人员就会联系您！</textarea> -->
<!--遮罩层-->
<div class="ui-mask" style=""></div>
<!-- 负责人 -->
<div id="sendLogsmownerDiv" class="ui-popup ui-popup-small" style="width:255px;display:none;">
	<div id="sendLogsmowner">
		<div class="ui-popup-head">
	        <div class="ui-popup-cursor" style="float:left;">&nbsp;</div>
			<ul class='usercontrol'>
				<li tag='Recently'>最近</li>
				<li tag='Colleague'>同事</li><!-- class='On' -->
				<li tag='Department'>部门</li>
			</ul>
			<input class="searchText" type='text' name='searchColleagueText' id='searchColleagueText' value='' placeholder='' tag='' workreport='' replyid='' onkeyup="clickSelectControl(this,event)" />
			<div class='ui-popup-close' style="float: right;">
				<b>×</b>
			</div>
		</div>
		<div class="ui-popup-centent">
			<div class='usercontent' id="RecentlyDiv" style='display:none;'></div>
			<div class='usercontent' id="ColleagueDiv" style='display:none;'></div>
			<div class='usercontent' id="DepartmentDiv" style='display:none;'></div>
		</div>
		<!-- <div class="ui-popup-foot"></div> -->
	</div>
	<script>
		WinPopup("sendLogsmownerDiv");
	</script>
</div>
<!-- 表情 -->
<div id="sendemojicookieDiv" class="ui-popup ui-popup-small" style="width:255px;display:none;">
	<div id="sendemojicookie">
		<div class="ui-popup-head">
            <div class="ui-popup-cursor" style="width: 20%;float:left;">&nbsp;</div>
    			<ul class='usercontrol'>
    			</ul>
    			<div class='ui-popup-close' style="float: right;">
    				<b>×</b>
    			</div>
    		</div>
		<div class="ui-popup-centent">
	       {foreach key=key item=item name=nav from=$FILESNAMELIST}
               {if $smarty.foreach.countRow.iteration % 11 == 1}
			        <a  data-name="{$key}" onclick="return false;" href="#">
                        <img width="18" height="18" alt="{$key}" title='{$key}' src="themes/softed/emojicookie/cookie_{$item}.png">
                    </a><br>
               {else}
			        <a class="item" data-name="{$key}" onclick="return false;" href="#">
                        <img width="18" height="18" alt="{$key}"  title='{$key}' src="themes/softed/emojicookie/cookie_{$item}.png">
                    </a>
               {/if}
			{/foreach}
		</div>
		<!-- <div class="ui-popup-foot"></div> -->
	</div>
	<script>
		WinPopup("sendemojicookieDiv");
	</script>
</div>
<!-- 点评弹出层 -->
<div id="dialogDiv" class="ld-pop-container" style="display:none;overflow: auto">
		<div class="dialog-l-tit">
			<img id="nameImage" src="themes/softed/images/get.jpg" alt="" width="30" height="30" class="name-img"> <span class="name" id="name">王灿</span>的<span id="content_dis" class="content_dis">日志</span>原文(<span class="aj-ctime" id="aj-ctime">2月04日</span>)
		</div>
		<div class="comment-feedcontent" id="comment-feedcontent">
			<p class="work-tit" tag="worksummary">今日工作总结</p>
			<br/>
			<p class="work-tit" tag="workexperience">明日工作计划</p>
			<br/>
			<p class="work-tit" tag="workplan">工作心得体会</p>
			<br/>
		</div>
		<div class="textarea-div">
			<textarea id="input-text" class="ld-textarea-inner input-text " placeholder="添加回复..." style="overflow: hidden;"></textarea>
		</div>
		<div class="CCrange selectbar" style='width:100%;margin-top:10px;margin-bottom:10px;' tag='dialog'>
			<ul class="reader-bar-list">
				<!-- <li itemid="6" emptype="p">
					<span class="item-name">邱小光</span><span class="remove-h">×</span>
				</li> -->
			</ul>
			<span class="input-tip"><i class="prefix">+</i>{'SELECTCCRANGE'|@getFixedLabel}</span>
			<input class="input-field ui-hide" type="text" autocomplete="off" value=''>
			<span class="show-select-panel"><span class="icon-homeimg icon-workp"></span></span>
		</div>
    	<div>
			<span>评分</span>
			<select class="ld-select-inner" id="commenton-select" style="width: 150px">
				<option value="5">五分：非常满意</option>
				<option value="4">四分：超过预期</option>
				<option value="3" selected="selected">三分：符合要求</option>
				<option value="2">二分：不合格</option>
				<option value="1">一分：严重批评</option>
			</select>
		</div>
</div>
<!-- 执行任务弹出层 -->
<div id="cocmdDiv" class="ld-pop-container" style="display:none;overflow: auto">
		<div class="dialog-l-tit">
			<img id="nameImage" src="themes/softed/images/get.jpg" alt="" width="30" height="30" class="name-img"> <span id="name" class="name">王灿</span>的任务原文(<span class="aj-ctime" id="aj-ctime">2月04日</span>)
			<!-- <a href="javascript:;" class="look-history">查看历史日志&gt;&gt;</a> -->
		</div>
		<div class="comment-feedcontent" id="comment-feedcontent" style="height:100px;">

		</div>
		<div class="textarea-div">
			<textarea class="ld-textarea-inner input-text" id="input-text" placeholder="添加回复..." style="overflow: hidden; word-wrap: break-word;"></textarea>
		</div>
</div>
<!-- 筛选时间 -->
<div id="selectbox_datebox" class="select-box date-box fn-hide" style="display: none;">
	<ul class="select-list date-list">
		{foreach key=key item=item name=nav from=$DATESELECT}
			<li class="" data-value="{$key}">
				{$item}
			</li>
		{/foreach}
	</ul>
</div>
<!-- 转发弹出层 -->
<div id="forwardDiv" class="ld-pop-container" style="display:none;background-color:#fff;">
	<div class="forward-help" style="width: 438px;">提示：转发内容将作为原工作信息的回复内容</div>
	<div class="CCrange selectbar" id="forwardCCrange" style='width:100%;margin: 6px 0px;' tag='forward'>
		<ul class="reader-bar-list">
		</ul>
		<span class="input-tip"><i class="prefix">+</i>{'SELECTCCRANGE'|@getFixedLabel}</span>
		<input class="input-field ui-hide" type="text" autocomplete="off" value=''>
		<span class="show-select-panel"><span class="icon-homeimg icon-workp"></span></span>
	</div>
	<textarea id="sendTxtForward" class="ld-textarea-inner input-text" placeholder="添加回复..." style="overflow: hidden; word-wrap: break-word; resize: none; height: 94px;padding: 5px"></textarea>
</div>
<!--回复信息中如果@的有成员有不在查看范围中时，弹框提醒-->
<div id="remindsDiv" class="ui-popup" style="width:500px;display:none;top:512px;">
	<div class="popup-head">
		<span class="popup-title ui-popup-cursor">
			添加范围提示
		</span>
		<i class='forward-close ui-popup-close'>×</i>
	</div>
	<div class="popup-centent ui-popup-centent">
    	<div class="popup-centent-tpl"></div>
        <p class="commenton-btnwarp" style='margin-bottom:0px;'>
			<span class="button-r">
				<button type="button" class="button-blue marR10">确定</button><button type="button" class="button-cancel button-cancel-radius ui-popup-close">{'CANCEL'|@getFixedLabel}</button>
			</span>
		</p>
	</div>
	<script>
	WinPopup("remindsDiv");
	</script>
</div>

<div id="tplnode" class='ui-hide'>
    <div class="mainuser" workreportid="%s">
    	<div class="userInfo">
    	   <dl class="item-top">
    		 <dt>name-img</dt>
    		 <dd style="width:200px;height:50px;">
    			<p class="employee-name fontblue employee-name-font" style="float:none !important;">%s</p>
				<p>
					<span class="timeurl" style="margin-left: 0px !important;">%s</span>
					<span class="group">
						<a tag="fstip" workreport="%s" href="javascript:void(0);">%s</a>
					</span>
				</p>
    		 </dd>
			 <dd style="height:50px;">
				<div style="float:right;padding-right: 15px;">
					<span class="log"><em class="plan-icon %s"></em>%s</span>
					<span class="con status line %s">-</span>
					<span class="con status %s %s" id="dianping">%s</span>
				</div>
			 </dd>
    	   </dl>
    	   <div class="pubclear plan-leader">%s<a href="javascript:void(0);" class="%s" tag="now_reply" workreport="" id="reply-log-div" style="margin-left: 10px;">{'COMMENTNOW'|@getFixedLabel}</a><a href="javascript:void(0);" class="%s" tag="now_finish" workreport="" id="reply-log-div" style="margin-left: 10px;">{'ReportResults'|@getFixedLabel}</a></div>
    	  <div class="content">
	    		%s <!-- 中间自定义字段显示的的地方 -->
					<p class='%s relation-title' style="padding-top:0px;">{'SIGNIN'|@getFixedLabel}</p>
					<div class='ui-acct-list relation-list %s'>%s</div>
					<p class='%s relation-title' style="padding-top:0px;">{'Accounts'|@getTransTab}</p>
					<div class='ui-acct-list relation-list %s'>%s</div>
					<p class='%s relation-title'>{'Contacts'|@getTransTab}</p>
					<div class='ui-cont-list relation-list %s'>%s</div>
					<p class='%s relation-title'>{'Products'|@getTransTab}</p>
					<div class='ui-cont-list relation-list %s'>%s</div>
					<p class='%s relation-title'>{'PICTURE'|@getFixedLabel}</p>
					<div class='ui-cont-list relation-list %s' style="display: flex;flex-direction: column">%s</div>
					<p class='%s relation-title'>{'Attachment'|@getFixedLabel}: %s{'GECOUNT'|@getFixedLabel}</p>
					<div class='ui-cont-list relation-list %s' style="display: flex;flex-direction: column">%s</div>
    	  </div>
    	  <div class="func">
				<ul {if $MASSDELETE eq 'true'}style='float: left; display:none;'{else}style='float: left;'{/if} >
					<li class='%s'>
						<a href="javascript:void(0);" tag='keyreply' >%s</a>
						<i class="S_txt %s">|</i>
					</li>
					<li class='%s'>
						<a href="javascript:void(0);" tag='loglist'>
							<span class='loglist-title'>{'View History'|@getFixedLabel}</span>
							<span class="edit-num">(<span>%s</span>)</span>
						</a>
					</li>
				</ul>
				<ul>
					<li class="saleskit li ui-hide" ><a href="javascript:void(0);" tag="saleskit_target" workreporttype="%s" userid="%s" workreport="%s">{'Jobbriefing'|@getFixedLabel}</a><i class="S_txt">|</i></li>
{*XUQIU1001397工作汇报，将更多中的“转发”按钮直接显示在“更多”的位置上（去掉“更多”操作按钮）-ccl*}
{*					<li {if $MASSDELETE eq 'true'}style='display:none;'{/if} name="more_operation">
						<span>
							<a tag="more" href="javascript:;" morename="%s-%s">
								{'MORE'|@getFixedLabel}<b class="jiantou jiantou_down"></b>
							</a>
						</span>
						<i class="S_txt">|</i>
						<div tag="%s-%s" class="more-menu ui-hide">
							<a workreport="%s" id="more-forward-%s" tag="more-forward" class="more-menu-forward" href="javascript:;">{'FORWARDING'|@getFixedLabel}</a>
							<a workreport="%s" id="more-cancel-%s" tag="more-cancel" class="more-menu-cancel" href="javascript:;">{'CANCEL'|@getFixedLabel}</a>
						</div>
					</li>*}
{*转发按键*}
					<li>
						<a workreport="%s" id="more-forward-%s" href="javascript:;" class="more-menu-forward" tag="more-forward" >{'FORWARDING'|@getFixedLabel}</a>
						<i class="S_txt">|</i>
					</li>
{*任务中的取消按键*}
					<li class="more-menu-cancel ui-hide">
						<a workreport="%s" id="more-cancel-%s" href="javascript:;" tag="more-cancel" >{'CANCEL'|@getFixedLabel}</a>
						<i class="S_txt">|</i>
					</li>

					<li {if $MASSDELETE eq 'true'}style='display:none;'{/if}>
						<span title="%s" class="%s"  tag="praise" workreport="%s"></span>
						<span class="praise-num">(<span>%s</span>)</span>
					</li>
					<li {if $MASSDELETE eq 'true'}style='display:none;'{/if}>
						<i class="S_txt">|</i>
						<a href="javascript:void(0);" tag="reply" workreport="%s">
						<span class='reply-title' tag='%s'>%s</span>
						<span class="reply-num">(<span>%s</span>)</span>
						<i class="common-up ui-hide" style="height: 9px; width: 14px;"></i></a>
					</li>
					<li id="edit%s" {if $MASSDELETE eq 'true'}tag="%s"{else}edit='%s'{/if}>
						<i class="S_txt">|</i>
						<a href="javascript:void(0);" tag="edit" workreport="%s" >{'EDIT'|@getFixedLabel}</a>
					</li>
					<li id="delete%s" {if $MASSDELETE eq 'true'}tag="%s"{else}delete='%s'{/if}>
						<i class="S_txt">|</i>
						<a class="redFont" href="javascript:void(0);" tag="delete" workreport="%s">{'DELETE'|@getFixedLabel}</a>
					</li>
				</ul>
    	   </div>
    	</div>
        <div class="pubclear reply-list-div ui-hide">
            <div class="swr-action-tbar" style="display:none ;margin-top:16px;">
                <label>回复任务：</label>
                <button style="padding:6px 15px;line-height:16px;" id="button-ordinary" class="marL10 undone-btn button-green topbtn" type="button">
                    普通回复
                </button>
                <button style="padding:6px 15px;line-height:16px;" id="button-finish" class="marL10 done-btn button-green topbtn" type="button">
                    已完成，汇报结果
                </button>
            </div>

            <div class="reply-box-hidden" style="display:none;">添加回复...</div>
    		<div style="margin-top:16px;">
                <div class='reply-list-userimg'>
        			<img alt="" style="border-radius: 100%" src="{$userimage}"/>
        		</div>
        		<div class="reply-wrapper">
        			<div class="input-wrapper" tag='replyarea'>
        				<textarea class="input-text" placeholder="添加回复..." style="overflow: hidden; word-wrap: break-word; resize: none; height: 45px;"></textarea>
        			</div>
                    <div class="btns">
    					<!-- <a class="addimg" href="javascript:void(0);" title="添加图片（多张）">
    						<input class="reply-uploadimg" type="file" style="position:absolute;">
    					</a> -->
    					<a class="addtouch addtouch_reply" tag="addtouch_reply" href="javascript:void(0);" title="添加提到"></a>
                        <a class="addemojicookie addemojicookie_reply" tag="addemojicookie_reply" href="javascript:void(0);" title="添加表情"></a>
    				</div>
    				<div class="reply-btn-r">
        				<button type="button" class="ld-button ld-button-primary button-submit">{'Reply'|@getFixedLabel}</button><button type="button" class="ld-button button-cancel">{'CANCEL'|@getFixedLabel}</button>
        			</div>
        		</div>
            </div>
            {*<div class="pubclear reply-info %s">以下为任务关键节点的回复：</div>*}
            <div class="pubclear reply-info %s">回复内容：</div>
            <div class="pubclear reply-info %s">以下为日志点评人的点评：</div>
    		<div class='pubclear reply-list'>
			</div>

       </div>
   </div>
</div>

<!--共有几个同事弹出-->
<div class="fs-tip" id="fs-tip" data-widget-cid="widget-110" style="z-index: 1000; display: none; position: absolute; left: 466.5px; top: 1062px;">
	<span class="close">×</span>
	<div class="share-group-tpl">
		<div class="share-group-warp">
		</div>
		<div class="share-group-countman">
			共<span class="num">12</span>人
		</div>
	</div>
	<div class="arrows-wrapper arrows-t">
		<div class="arrows-inner"></div>
	</div>
</div>


<!-- 回复列表模板 -->
<div id="replynode" class='ui-hide'>
	<div class='reply-list-wrapper pubclear' replyid='%s'>
		<div class='avatar-wrapper'>
			<div class='reply-userimg fn-left'>
				name-img
			</div>
			<div class='reply-list-user fn-left'>
                <span replyuserid='%s' ecnryptuserid='%s' class="reply-name">%s</span>
                <span class='reply-list-content'>%s</span>
                <span>（%s）</span>
            </div>
			<div class='reply-list-icon fn-right'>{'Reply'|@getFixedLabel}</div>
		</div>
        <div class='pubclear reply-list-reply ui-hide'>
			<div class="pubclear">
				<div class='reply-userimg'>
					name-img
				</div>
				<div class="reply-wrapper">
					<div class="input-wrapper" tag='replylistarea'>
						<textarea class="input-text" placeholder="添加回复..." style="overflow: hidden; word-wrap: break-word; resize: none; height: 45px;width: 420px;"></textarea>
					</div>
					<div class="btns">
						<a class="addtouch" href="javascript:void(0);" title="添加提到"></a>
                        <a class="addemojicookie" href="javascript:void(0);" title="添加表情"></a>
					</div>
					<div class="reply-btn-r">
						<button type="button" class="ld-button ld-button-primary button-submit">{'Reply'|@getFixedLabel}</button><button type="button" class="ld-button button-cancel">{'CANCEL'|@getFixedLabel}</button>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<!--#######@提到我的，我的赞，我的回复###########-->
<div class="department-wrapper ui-hide">
    <div class="leftLink-top">
       <h2 class="link-title">@提到我的</h2>
       <p class="link-text">这些是正文或回复中包含@您的名字的工作，这些工作可能包含关系到您的内容。</p>
       <ul class="pubclear link-menu">
          <li><a class="curr" href="javascript:;">提到我的工作</a></li>
          <li><a href="javascript:;">提到我的回复</a></li>
       </ul>
    </div>
    <div class="pubclear leftLink-center-list">
        <div class="letfLink-menu">
          <ul class="menuUl">
             <li class="linebg" style="width:26px;"><a href="javascript:void(0);">{'ALL'|@getFixedLabel}</a></li>
             <li style="width:39px;"><a href="javascript:void(0);">{'SHARE'|@getFixedLabel}</a></li>
             <li style="width:39px;"><a href="javascript:void(0);">{'LOG'|@getFixedLabel}</a></li>
          </ul>
          <label class="search-wrap">
            <input type="text" class="search-inp" placeholder="搜索信息" maxlength="100"/><button class="search-btn" type="botton"><span class="icon-homeimg icon-search2"></span></button>
          </label>
        </div>
        <div class="pubclear"></div>
        <div class="list-content">
            <div class="list-detail-top">
                <dl>
                  <dt><img class="list-name-img" alt="" src="themes/images/defaultuser.png"/></dt>
                  <dd>
                    <a href="javascript:void(0);" class="employee-name">系统管理员</a>
        			<span>-</span>
        			<span class="group">
        				<a href="javascript:void(0);" >2个部门</a>
        			</span>
        			<span>-</span>
        			<span class="share">
        				<a href="javascript:;">分享</a>
        			</span>
        			<span>-</span><br />
        			<label class="timeurl"><a style="padding-right:10px;" href="javascript:void(0);">02月09日 10:00</a></label>
                  </dd>
                </dl>
            </div>
            <div class="pubclear list-detail-content">
                <div class="per-text">
                    <a href="#profile/=/empid-18" class="at-link-name">@白昭</a>&nbsp;
                    <a href="#profile/=/empid-18" class="at-link-name">@白昭</a>&nbsp;
                    <a href="#profile/=/empid-18" class="at-link-name">@白昭</a>&nbsp;
                </div>

                <div class="relation-list">
                    <span class="title">{'Accounts'|@getTransTab}</span><br />
                    <div class="list">
                        <a href="javascript:void(0);">上海普永</a>，<a href="javascript:void(0);">上海普永</a>
                    </div>
                </div>
                <div class="func">
                   <ul>
                    <li><a href="javascript:void(0);">更多</a>
                    	<b  class="filter-advSearch_icon filter-advSearch_up"></b>
                    	<!-- <i class="arrow"></i> -->
                    </li>
                    <li><i class="S_txt">|</i><a href="javascript:void(0);">提醒</a>
                    	<b  class="filter-advSearch_icon filter-advSearch_up"></b>
                    	<!-- <i class="arrow"></i> -->
                    </li>
                    <li><i class="S_txt">|</i><a href="javascript:void(0);">待办</a><i class="S_txt">|</i></li>
                    <li><span class="hand"></span></li>
                    <li><i class="S_txt">|</i><a href="javascript:void(0);">{'Reply'|@getFixedLabel}</a></li>
                  </ul>
                </div>
            </div>
        </div>
     </div>
</div>
<input type="hidden" id="homecontrol" value="{$HOMECONTROL}" />
<script>
	var coordination_searchscope='{$SEARCHSCOPE}';
	var ViewallCooperativeWork='yes';//是否为查看全部界面yes:是
	{literal}

	{/literal}
</script>
<script type="text/javascript">
	var onlyjpggifimg = "{'ONLYJPGGIFIMG'|@getFixedLabel}";
	{literal}
		getSendLogCcrange('');

		ld(function(){
	        // pageLeftClose();//收缩
			var DivCTable_detailmaxheight = parseInt(ld(window).height()) - parseInt(topheight) - parseInt(con_mt_height);
			if(ld('#related_keywords_field').length > 0){
				DivCTable_detailmaxheight = DivCTable_detailmaxheight - ld('#related_keywords_field').get(0).offsetHeight - 54;
			}
	        ld(".main_grid .main_grid_box").css('height', DivCTable_detailmaxheight+'px');
	    });
	{/literal}
</script>