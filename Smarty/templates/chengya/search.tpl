<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/resizetable.js"></script>
<link type="text/css" rel="stylesheet" href="themes/softed/leftmenu.css">
<link type="text/css" rel="stylesheet" href="themes/softed/common.css">
<link type="text/css" rel="stylesheet" href="themes/softed/Control.css">
<style type="text/css">@import url("themes/softed/style.css");</style>
<link rel="stylesheet" href="themes/softed/viewer.min.css" type="text/css" /><!--多选框-->
<link rel="stylesheet" href="themes/softed/select2.css" type="text/css" /><!--多选框-->
<link rel="stylesheet" href="themes/softed/select2-bootstrap.css" type="text/css" />
<link rel="stylesheet" type="text/css" href="crmcommon/css/treeview/jquery.treeview.css" /><!--选部门选用户-->
<link rel="stylesheet" href="crmcommon/css/webuploader/webuploader.css" type="text/css" /><!--附件上传-->
<link rel="stylesheet" href="crmcommon/css/webuploader/bootstrap.min.css" type="text/css" /><!--附件上传-->
<link rel="stylesheet" href="dataCache/tabdatas/skinset.css" type="text/css" /><!--菜单背景色自定义-->
<style>
	.chengya-table-content{
		table-layout: fixed;
		background-color: #ddd;
		overflow-x: auto;
	}
	.chengya-table-content td{
		word-wrap:break-word !important;word-break:break-all !important;font-size: 12px;padding: 0 5px;height:42px;
	}
	.chengya-table-content tr th {
		background-color: #F0F2F5;
		text-align: left;
		color: #545861;
		height: 50px;
		padding: 0px 3px;

		box-sizing: border-box;
		vertical-align: middle;
		font-size: 14px;
		font-weight: normal;
	}
</style>
<script type="text/javascript" src="include/jquery/jquery.min.js"></script>
<script type="text/javascript" language="JavaScript">
	var ld = $;
	var global_js_url = '';
	var language='zh';
	if(language=='zh'){
		language='zh-cn';
	}
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

	function callSearchNew(searchtype){
		var search_zuzhi = ld("#search_zuzhi").val();
		var search_stockname = ld("#search_stockname").val();
		var search_productname = ld("#search_productname").val();
		var search_productno = ld("#search_productno").val();
		var search_productsheet = ld("#search_productsheet").val();
		var urlstring = 'module=ReportAnalysis&action=ReportAnalysisAjax&is_ajax=yes&file=chengya_search_kucun'+'&search_zuzhi='+encodeURIComponent(search_zuzhi);
		urlstring += '&search_stockname='+encodeURIComponent(search_stockname);
		urlstring += '&search_productname='+encodeURIComponent(search_productname);
		urlstring += '&search_productno='+encodeURIComponent(search_productno);
		urlstring += '&search_productsheet='+encodeURIComponent(search_productsheet);
		if('export' == searchtype){
			ld('#rptContentLoading').show();
			urlstring += '&is_export=yes';
			ldAjax('index.php?'+urlstring,"",function(data){
				if(data.code==2){
					ld('#toExport').text('导出');
					//2的时候是导出数据
					window.open(data.result.filepath);
				}
				DelProgressObjs();
			})
		}else{
			ld('#rptContentLoading').show();
			ld('#search_dd').html('数据正在查询中.....');
			new Ajax.Request(
					'index.php',
					{queue:{position:"end", scope:"command"},
						method:"post",
						postBody:urlstring,
						onComplete:function (response) {
							ld('#search_dd').html('');
							ld('#rptContentLoading').hide();
							ld("div[name=meiante_ListViewContents]").html(response.responseText);
						}
					}
			);
		}
		return false;
	}
	function setContentHeight(){
		var a = ld(' .Header').outerHeight(true),//头部高度
				b = ld(' .ld-ui-tabs').outerHeight(true),//标签高度
				c = ld(' .Category').outerHeight(true),//数据分类标题高度
				c1 = ld(' .Category-list').outerHeight(true),//数据分类高度
				d = ld(' .D_btn_box').outerHeight(true),//按钮高度
				e = ld('#resize_header_table_divid').outerHeight(true),//内容头部高度
				tag = ld('#listtag_div').outerHeight(true),//标签高度
				rp = ld(' .Statistics').outerHeight(true),//本次查询图表高度
				orgInfo =  40,//用户管理显示的公司信息
				h_height = 0,
				s_height = ld(window).height();

		if(ld('#listtag_div').is(":hidden")){
			tag = 0;
		}
		if(a==null) a=0;
		if(b==null) b=0;//客户关闭公海参数
		if(c==null) c=0;
		if(c1==null) c1=0;
		if(d==null) d=0;
		if(e==null) e=0;
		if(rp==null) rp=0;
		if(tag==null) tag=0;
		if(orgInfo == null) orgInfo=0;
		h_height = Tools.Number.toInt(a);

		h_height = Tools.Number.toInt(h_height)+Tools.Number.toInt(c)+Tools.Number.toInt(c1)+Tools.Number.toInt(d)+Tools.Number.toInt(e)+Tools.Number.toInt(rp)+Tools.Number.toInt(tag);
		ld('#resize_content_table_divid').css('height',s_height-h_height-100);
	}

	function BindingAccounts(openid){
		var surl = 'index.php?module=Accounts&action=AccountsAjax&file=member_accounts&openid='+openid;
		var crmPopupobj=CrmPopup.load("","","","LdPopWidth1100px",'Settings',"","","","");
		crmPopupobj.prevshow();
		ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1){
				crmPopupobj.setParams(data.result.title,"","","LdPopWidth800px",'Settings',"","","","","");
				crmPopupobj.show(data.result.content);
				//ld("#mul_moduledata_tag").select2({closeOnSelect: false});

				crmPopupobj.setScrollDivMaxHeight();
				crmPopupobj.center();

			}
		})
		return false;
	}

	function fninvshnew(idname){
		document.getElementById("layer").remove();
		if(document.getElementById(idname) != undefined){
			var newbox=document.getElementById(idname);
			newbox.style.display="none";
		}
	}

	function AllocateTrackGroup()
	{
		var scopepopupobj;
		var user_value = ld('#userids').val();
		var popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_module=CustomForm11&popup_inputtype=checkbox&popup_selecttype=user&popup_scopetype=private';
		getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
			var methodObj = {'popup_check_inactiveuser':'no'};
			scopepopupobj =  new ScopePopupObj(methodObj);
			scopepopupobj.popup_caption_value = arrJsPopLabel['DISTRIBUT'];//标题title
			getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
				cls_ScopePopup.prop.popup_url = popup_url;//popup_url
				cls_ScopePopup.prop.popup_module = 'CustomForm11';//模块
				cls_ScopePopup.prop.popup_value = user_value;
				var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
				//重写确认按钮事件
				scopepopupobj.setEventBtnOk=function(){
					ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
						//没有选择任何用户，则给出提示
						ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
						if(empty(cls_ScopePopup.return_obj.return_id)){
							ld('#userids').val(0);
							ld('#lastname_text').val('');
						}else{
							var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
							var selected_user_name = cls_ScopePopup.return_obj.return_name;//选中的用户
							ld('#userids').val(selected_user);
							ld('#lastname_text').val(selected_user_name);
						}
					});
				}
			});
		});
	}

	{/literal}
</script>

<body  class="small" marginwidth="0" marginheight="0" leftmargin=0 topmargin=0 bottommargin=0 rightmargin=0>
<div class="mailClientBg D_pop_content bgwhite">
	{if $PRODBOMTAGARR && $PRODBOMTAGARR != ''}
		<div id="probom_div" class="probom_tab">
			<ul class='prodbomtag' style="margin-bottom:1px;">
				{foreach key=key item=item from=$PRODBOMTAGARR}
					<li {if $PRODBOMTAG_D == $key}class='On'{/if} tag='{$key}'>{$item}</li>
				{/foreach}
			</ul>
		</div>
		<script language="JavaScript" type="text/javascript" src="modules/Products/Products.js"></script>
	{/if}
	<table id="popup_width" name="popup_width" width="100%" border="0" cellpadding="0" cellspacing="0"></table>
	<table  align="center" width="100%" cellpadding="0" cellspacing="0" border="0"  class="homePageMatrixHdr" style="display:">
		<tr>
			<td>
				<form name="basicSearch" action="index.php" onSubmit="callSearch('Basic');return false;">
					<table  align="center" width="100%"  cellpadding="0" cellspacing="0">
						<tr  class="basicsearchfield">
							<td class="height25 padT10">
								<div class="DivSearch">
									<ul>
										<li class="padL8" style="float: left;height: 34px;padding-right:0px;">库存组织：
											<select name="search_zuzhi" id="search_zuzhi" class="btn-radius-system">
												<option value="全部">全部</option>
												<option value="诚亚集团">000诚亚集团</option>
												<option value="北京诚亚科技有限责任公司">010北京诚亚科技有限责任公司</option>
												<option value="天津诚亚科技有限责任公司">022天津诚亚科技有限责任公司</option>
												<option value="沈阳诚亚科技有限责任公司">024沈阳诚亚科技有限责任公司</option>
												<option value="河南诚亚智能科技有限责任公司">0371河南诚亚智能科技有限责任公司</option>
												<option value="山东诚亚科技有限责任公司">0531山东诚亚科技有限责任公司</option>
											</select>
										</li>
										<li class="padL8" style="float: left;height: 34px;padding-right:0px;">仓库名称：<input type="text" value="" name="search_stockname" id="search_stockname" class="btn-radius-system" style="width:150px;"/></li>
										<li class="padL8" style="float: left;height: 34px;padding-right:0px;">物料名称：<input type="text" value="" name="search_productname" id="search_productname" class="btn-radius-system" style="width:150px;"/></li>
										<li class="padL8" style="float: left;height: 34px;padding-right:0px;">物料编码：<input type="text" value="" name="search_productno" id="search_productno" class="btn-radius-system" style="width:150px;"/></li>
										<li class="padL8" style="float: left;height: 34px;padding-right:0px;">规格型号：<input type="text" value="" name="search_productsheet" id="search_productsheet" class="btn-radius-system" style="width:150px;"/></li>
										<li>
											&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" name="search" onClick="callSearchNew('search');" class="saveauto" value="{'FINDNOW'|@getFixedLabel}" />
										</li>
									</ul>
								</div>

							</td>
						</tr>
					</table>
				</form>
			</td>
		</tr>
	</table>
	<span id="search_dd" style="color: red;margin-left: 10px;"></span>
	<div id="meiante_ListViewContents" name="meiante_ListViewContents" style="margin-left: 10px;">
		{include file="chengya/search_content.tpl"}
	</div>
</div>
<div id="leads_mappingfields" class="E_pop_box LdPopWidth0px " style="display:none;">
	<div class="E_pop_tit">
		<strong id="titlename" class="E_ptita">{'ADVANCE'|@getFixedLabel}</strong>
		<button class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}" onclick="fninvshnew('leads_mappingfields');return false;"></button>
	</div>
	<div id="leads_mappingfields_div" style="max-height:300px;overflow-y:auto;"></div>
	<div class="E_pbtn">
		<input type="button" value="{'CONFIRMED'|@getFixedLabel}" class="E_pbtnok" onclick="">
		<span>&nbsp;</span>
		<input type="button" onclick="fninvshnew('leads_mappingfields');" value="{'CANCEL'|@getFixedLabel}" class="E_pbtncancel">
	</div>
</div>
<div id="rptContentLoading" class="ContentLoadingDiv">
	<img src="themes/icon/loading.gif">
</div>
</body>