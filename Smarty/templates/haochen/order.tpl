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
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CreatePagePopup.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupUserGroup.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/SaveDataRecord.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/selectSearchField.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/ProgressPopup.js?v={$GLOBALMINVERSION}"></script>


<script type="text/javascript">
var CURRENT_USER_ID = {$CURRENT_USER_ID};
var iskehu001 = 'no';

{literal}
	
	function callSearchNew(searchtype){
		var zhuangtai = ld("#zhuangtai").val();
		var voucher_startdate = ld("#voucher_startdate").val();
		var voucher_enddate = ld("#voucher_enddate").val();
		var chaifen = ld("#chaifen").val();
		var userid = ld("#userid").val();
		var order_no = ld("#order_no").val();
	
		
		if(voucher_startdate == '' || voucher_enddate == ''){
			RemindsMsg("","LdPopWidth400px",'',"yes","",'开始日期或结束日期不能为空！');
			return false;
		}
		if(voucher_startdate != '' && voucher_enddate != ''){
			if(voucher_startdate > voucher_enddate){
				RemindsMsg("","LdPopWidth400px",'',"yes","",'开始日期不能大于结束日期！');
				return false;
			}
		}
		
		var urlstring = 'module=Customreport&action=CustomreportAjax&is_ajax=yes&file=haochen_order';
		urlstring += '&zhuangtai='+zhuangtai;
		urlstring += '&voucher_startdate='+voucher_startdate;
		urlstring += '&voucher_enddate='+voucher_enddate;
		urlstring += '&chaifen='+chaifen;
		urlstring += '&userid='+userid;
		urlstring += '&order_no='+order_no;	
		urlstring += '&page='+ld('#curPage').val();
		//alert(urlstring);
		if('export' == searchtype){
			var list_num = ld("#list_num").val();
			
		}else{
			ld('#rptContentLoading').show();
			//alert(urlstring);
			new Ajax.Request(
				'index.php',
				{queue:{position:"end", scope:"command"},
					method:"post",
					postBody:urlstring,
					onComplete:function (response) {
						ld('#rptContentLoading').hide();
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
		//alert(ld('#resize_content_table_divid'));
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
	
	function order_con(record,id,order_no){
		var msgConfirm = arrJsPopLabel['Confirmtovoidthecontract'];
		msgConfirm = msgConfirm.replace("{Var}",order_no);
		//alert(order_no);
		RemindsMsg("","LdPopWidth400px","","yes","yes",msgConfirm+'？');
		//点击确认
		ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
			var surl = 'index.php?module=Customreport&action=CustomreportAjax&file=haochen_order&zuofei=yes&record=' + record+'&id='+id;
			//alert(surl);
			ldAjax(surl, "", function (data) {
				if (data.code == 1) {
					DelProgressObjs();
					callSearchNew('search');
				}
			})
		});
	}


	function fninvshnew(idname){
		document.getElementById("layer").remove();
		if(document.getElementById(idname) != undefined){
			var newbox=document.getElementById(idname);
			newbox.style.display="none";
		}
	}

	function clear_AllocateTrackGroup(){
		ld('#groupids').val(0);
		ld('#groupname_text').val('');
	}

	function href_listview(smownerid,year){
		var start_date = ld("#start_date").val();
		var end_date = ld("#end_date").val();
		ld.ajax("index.php?module=Customreport&action=CustomreportAjax&file=mengdie&smownerid="+encodeURIComponent(smownerid)+"&start_date="+encodeURIComponent(start_date)+"&end_date="+encodeURIComponent(end_date)+"&is_href=yes")
		.done(function(){
            var addurl=encodeURIComponent("&query_session=1");
			url = 'index.php?pageto_module=Potentials&pageto_action=index&page_addurl='+addurl;
			window.open(url); 
            
		})
	}

	function lastPage(){
		var curPage = ld('#curPage').val();
		if(parseInt(curPage)<=1){
			return false;
		}else{
			curPage -= 1;
			ld('#curPage').val(curPage);
			callSearchNew("");
		}
	}

	function nextPage(){
		var curPage = ld('#curPage').val();
		var totalPages = ld('#total_pages').text();
		if(parseInt(curPage)>=parseInt(totalPages)){
			return false;
		}else{
			curPage = parseInt(curPage) + 1;
			ld('#curPage').val(curPage);
			callSearchNew("");
		}
	}
	
{/literal}
</script>

<body  class="small" marginwidth="0" marginheight="0" leftmargin=0 topmargin=0 bottommargin=0 rightmargin=0>
<div class="mailClientBg D_pop_content bgwhite">

	<!--{*
		选择产品弹出框添加套餐、产品标签
		@project PROT127 爱哆哆需求1：产品套餐
		@author tujt 2014-11-26
	*}-->
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
                <table  align="center" width="100%"  cellpadding="0" cellspacing="0">
				<tr  class="basicsearchfield">
                    <td class="height25 padT10">
                        <div class="DivSearch">
                        <ul>
							<li class="padL8" style="float: left;height: 34px;padding-right:0px;">
								<label>开始日期：
									<input maxlength="25" size="15" name="voucher_startdate" value="{$STARTDATE}"  id="voucher_startdate" style="border:1px solid #bababa;width:100px;" onClick="WdatePicker({ldelim}dateFmt:'yyyy-MM-dd'{rdelim})" class="Wdate"/>
								</label>
							</li>
							<li class="padL8" style="float: left;height: 34px;padding-right:0px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</li>
							<li class="padL8" style="float: left;height: 34px;padding-right:0px;">
								<label>结束日期：<input maxlength="25" size="15" name="voucher_enddate" value="{$ENDDATE}"  id="voucher_enddate" style="border:1px solid #bababa;width:100px;" onClick="WdatePicker({ldelim}dateFmt:'yyyy-MM-dd'{rdelim})" class="Wdate"/></label>
							</li>
							<li class="padL8" style="float: left;height: 34px;padding-right:0px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</li>
                            <li class="padL8" style="float: left;height: 34px;padding-right:0px;">合同状态：
							<select name="zhuangtai" id="zhuangtai" class="detailedViewSelect bgwhite" style="width: 100px;">
								<option value="">全部</option>
								<option value="zhengchang">正常</option>
								<option value="zuofei">作废</option>
							</select>
							</li>
							<li class="padL8" style="float: left;height: 34px;padding-right:0px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</li>
							<li class="padL8" style="float: left;height: 34px;padding-right:0px;"> 拆分状态：
							<select name="chaifen" id="chaifen" class="detailedViewSelect bgwhite" style="width: 100px;">
								<option value="">全部</option>
								<option value="weichaifen">未拆分</option>
								<option value="yichaifen">已拆分</option>
							</select>
							</li>
							<li class="padL8" style="float: left;height: 34px;padding-right:0px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</li>
							<li class="padL8" style="float: left;height: 34px;padding-right:0px;"> 销售负责人：
							<select name="userid" id="userid" class="detailedViewSelect bgwhite" style="width: 100px;">
								<option value="">全部</option>
								{foreach key=userid item=last_name from=$USERS}
									<option value="{$userid}">{$last_name}</option>
								{/foreach}
							</select>
							</li>
							
							<li>
                              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" name="search" onClick="callSearchNew('search');" class="saveauto" value="&nbsp;&nbsp;筛选&nbsp;&nbsp;" />
                            </li>
                        </ul>
                        </div>
                        
					</td>
                </tr>
                </tr> 
				</table>
				<table  align="center" width="100%"  cellpadding="0" cellspacing="0">
				<tr  class="basicsearchfield">
                    <td class="height25 padT10">
                        <div class="DivSearch">
                        <ul>
                            <li class="padL8" style="float: left;height: 34px;padding-right:0px;">查找关键字：<input placeholder="请输入存档号或合同编号" type="text" value="" name="order_no" id="order_no" class="btn-radius-system" style="width:180px;"/></li>
							
							<li>
                              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" name="search" onClick="callSearchNew('search');" class="saveauto" value="立即查找" />
                            </li>
                        </ul>
                        </div>
                        
					</td>
                </tr>
                </tr> 
				</table>
				</form>
			</td>
		</tr>
	</table>

	<div id="meiante_ListViewContents" name="meiante_ListViewContents" >
        
       {include file="haochen/order_detail.tpl"}
      
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