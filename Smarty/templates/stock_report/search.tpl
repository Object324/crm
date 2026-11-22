<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/resizetable.js"></script>
<link type="text/css" rel="stylesheet" href="themes/softed/leftmenu.css">
<link type="text/css" rel="stylesheet" href="themes/softed/common.css">
<link type="text/css" rel="stylesheet" href="themes/softed/Control.css">
<link rel="stylesheet" href="themes/softed/style.css" type="text/css" />
<link rel="stylesheet" href="themes/softed/common-23.css" type="text/css" />
<link rel="stylesheet" href="themes/softed/viewer.min.css" type="text/css" /><!--多选框-->
<link rel="stylesheet" href="themes/softed/select2.css" type="text/css" /><!--多选框-->
<link rel="stylesheet" href="themes/softed/select2-bootstrap.css" type="text/css" />
<link rel="stylesheet" type="text/css" href="crmcommon/css/treeview/jquery.treeview.css" /><!--选部门选用户-->
<link rel="stylesheet" href="crmcommon/css/webuploader/webuploader.css" type="text/css" /><!--附件上传-->
<link rel="stylesheet" href="crmcommon/css/webuploader/bootstrap.min.css" type="text/css" /><!--附件上传-->
<link rel="stylesheet" href="dataCache/tabdatas/skinset.css" type="text/css" /><!--菜单背景色自定义-->

<script type="text/javascript" src="include/jquery/jquery.min.js"></script>
<script type="text/javascript" language="JavaScript">
	var ld = $;
	var global_js_url = '';
	var language='zh';
	if(language=='zh'){
		language='zh-cn';
	}
	var topheight=55;
</script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}crmcommon/js/My97DatePicker/WdatePicker.js"></script><!--时间选择器-->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/Inventory.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/json.js"></script>
<script language="JavaScript" type="text/javascript" src="include/language/zh.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/multipingyin.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/picklist.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/FieldDependencies.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/SystemPopup/ComboxPopup.js"></script>
<!-- vtlib customization: Javascript hook -->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/vtlib.js"></script>
<!-- END -->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/MassSMS.js"></script>
<script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/scriptaculous/prototype.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/QuickCreate.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/EditView.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ldAjax.js"></script>
<script language="javascript" type="text/javascript" src="include/js/general.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/MsgPopup.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CommonPagePopup.js?v={$GLOBALMINVERSION}"></script><!--拖拽效果-->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupDrag.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CrmPopup.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/QcPopup.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/selectSearchPopup.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PageRecordPopup.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupLayer.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/MassEditPopup.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CreatePagePopup.js?v={$GLOBALMINVERSION}"></script>

<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupUserGroup.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/SaveDataRecord.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/selectSearchField.js?v={$GLOBALMINVERSION}"></script>

<script type="text/javascript">
	var CURRENT_USER_ID = {$CURRENT_USER_ID};
	var iskehu001 = 'no';

	{literal}


	{/literal}
</script>

<body  class="small" marginwidth="0" marginheight="0" leftmargin=0 topmargin=0 bottommargin=0 rightmargin=0>
<div class="mailClientBg D_pop_content bgwhite">
	<table id="popup_width" name="popup_width" width="100%" border="0" cellpadding="0" cellspacing="0"></table>
	<!--
    edit:andrew;
    date:20140214
    reason:添加数据分类
    -->
	<table  align="center" width="100%" cellpadding="0" cellspacing="0" border="0"  class="homePageMatrixHdr" style="display:">
		<tr>
			<td>
				<form name="basicSearch" action="index.php" onSubmit="callSearch('Basic');return false;">
					<input type="hidden" name='page' id="page" value="{$PAGE}" />
					<input type="hidden" name="search_str" id="search_str" value="{$SEARCHCOLNAME}" />
					<table  align="center" width="100%"  cellpadding="0" cellspacing="0">
						<tr  class="basicsearchfield">
							<td class="height25 paddingT10" align="center" style="background: #F3F3FC;">
								<table style="width: 1000px;" class="first_report_table" cellspacing="0" cellpadding="0" border="0">
									<tbody>
									{foreach item=search_info key=rows from=$SEARCHLIST}
										<tr>
											{foreach item=info key=colname from=$search_info}
												<td align="left">{$info.label}</td>
												<td align="left">
													{if $info['type'] eq 'select'}
														<select name="{$colname}" id="{$colname}" class="btn-radius-system" style="width: 190px;height: 22px;">
															{if $info['optionsAllShow'] neq 'no'}
																<option value="">全部</option>
															{/if}
															{foreach item=opts from=$info['options']}
																<option value="{$opts.id}"
																		{if $info.selected.id==$opts.id}selected {/if}>{$opts.name}</option>
															{/foreach}
														</select>
													{else}
														{if $info['type'] eq 'like'}
															<select class="btn-radius-system" name="{$colname}_sel"
																	id="{$colname}_sel"
																	style="width: 55px;height: 22px; vertical-align:middle;">
																<option value="con">包含</option>
																<option value="eq"
{*																		{if $colname eq 'fmaterialId'  or $colname eq 'fnumber' or $colname eq 'cinvcode' or  $colname eq 'inventorycode'}selected{/if}*}
																>等于</option>
																<option value="lcon">左包含</option>
																<option value="rcon">右包含</option>
															</select>
														{/if}

														{if $colname eq 'fmaterialId'  or $colname eq 'fnumber' or $colname eq 'cinvcode' or  $colname eq 'inventorycode'}
															<input type="text" value="{$PRODUCTNO}" name="{$colname}" id="{$colname}" class="btn-radius-system" style="{if $info['type'] eq 'like'}width:130px;{else}width:190px;{/if}height: 22px;"/>
														{else}
															<input type="text" value="" name="{$colname}" id="{$colname}" class="btn-radius-system" style="{if $info['type'] eq 'like'}width:130px;{else}width:190px;{/if}height: 22px;"/>
														{/if}

													{/if}
												</td>
											{/foreach}
										</tr>
									{/foreach}
									<tr><td colspan="{$search_view_rows}" align="center"><input type="button" name="search" onClick="search_pro_stock_btn('search',{$PAGE});" class="saveauto" value="{'FINDNOW'|@getFixedLabel}" /></tr></tr>

						</tbody>
					</table>


					<!--{foreach item=info key=colname from=$SEARCHLIST}
								<li class="padL8" style="float: left;height: 34px;padding-right:0px;">{$info.label}：
									{if $info['type'] eq 'select'}
										<select name="{$colname}" id="{$colname}" class="btn-radius-system" style="width: 150px;">
											<option value="">全部</option>
											{foreach item=opts from=$info['options']}
												<option value="{$opts.id}">{$opts.name}</option>
											{/foreach}
										</select>
									{else}
										{if $colname eq 'FMaterialId'}
											<input type="text" value="{$PRODUCTNO}" name="{$colname}" id="{$colname}" class="btn-radius-system" style="width:120px;"/>
										{else}
											<input type="text" value="" name="{$colname}" id="{$colname}" class="btn-radius-system" style="width:120px;"/>
										{/if}

									{/if}
								</li>
							{/foreach}
							<li>
                                &nbsp;&nbsp;&nbsp;&nbsp;<input type="button" name="search" onClick="search_pro_stock_btn('search',{$PAGE});" class="saveauto" value="{'FINDNOW'|@getFixedLabel}" />
                            </li>
                        </ul>-->


			</td>
		</tr>
		</tr>
	</table>

	</form>
	</td>
	</tr>
	</table>
	<span id="search_dd" style="color: red;margin-left: 10px;"></span>
	<div id="meiante_ListViewContents" name="meiante_ListViewContents" style="margin-left: 10px;">

		{include file="stock_report/search_content.tpl"}

	</div>
</div>
<div id="rptContentLoading" class="ContentLoadingDiv">
	<img src="themes/icon/loading.gif">
</div>
<style>
	.first_report_table {
		font-size: 13px;
		padding: 10px 15px;
	}
	.first_report_table tr td {
		padding: 3px 0;
	}
</style>
</body>