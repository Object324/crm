<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <title>对账单报表</title>
    <meta http-equiv = "X-UA-Compatible" content = "IE=edge,chrome=1"/>
	<style type="text/css">@import url("themes/softed/style.css");</style>
    <style type="text/css">@import url("themes/softed/selfstyle.css");</style>
    <style type="text/css">@import url("themes/softed/common.css");</style>
	<link rel="stylesheet" href="themes/softed/leftmenu.css" type="text/css" />
</head>
<script type="text/javascript" src="crmcommon/js/jquery/jquery.min.js"></script>
<script type="text/javascript" src="crmcommon/js/jquery/jquery-ui.min.js"></script>
<script type="text/javascript" language="JavaScript">
	var global_js_url = '';
	var language='zh';
	var ld = $;
</script>
<script language="JavaScript" type="text/javascript" src="include/language/zh.js"></script>
<script language="javascript" type="text/javascript" src="crmcommon/js/My97DatePicker/WdatePicker.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/general.js?v={$GLOBALMINVERSION}"></script><!--公共-->
<script language="JavaScript" type="text/javascript" src="include/js/ldAjax.js?v={$GLOBALMINVERSION}"></script><!--公共-->
<script language="JavaScript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/scriptaculous/prototype.js"></script>
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
<script type="text/javascript" src="{$JSURL}include/js/MsgPopup.js?v={$GLOBALMINVERSION}"></script><!--弹出层提示-->
{literal}
<style type="text/css">
.ContentLoadingDiv {
	display: none;
	position: fixed;
	top: 50%;
	left: calc(50%);
	/*background-color: #333;
	border-radius: 6px;
	opacity: 0.3;
	padding: 10px;*/
	transform: translate(-50%,-50%);
	-ms-transform: translate(-50%,-50%);
	-moz-transform: translate(-50%,-50%);
	-webkit-transform: translate(-50%,-50%);
	-o-transform: translate(-50%,-50%);
	z-index: 2147483588;
}
</style>
{/literal}
<table class="reportPopTable padLR10 padT5" border="0" cellpadding="0" cellspacing="0" width="100%">
	<tbody>
		<tr>
			<td class="C" valign="middle" width="40%" colspan="2">
				<span>&nbsp;&nbsp;&nbsp;对账类型：</span>
				<select name="baoguan_leixing" id="baoguan_leixing" class="btn-radius-system" style="width:100px;" onchange="submitResult(event,'')">
					<option value="account" >客户</option>
					<option value="vendor" >供应商</option>
				</select>
				<input id="search_name" class="btn-radius-system" style="width:120px;margin-top: -5px;" value="" name="search_name"  type="text">
			</td>
			<td class="C" valign="middle" width="40%" colspan="2">
				<span>业务日期：</span>
				<input id="job_starttime" class="Wdate" type="text" style="border:1px solid #dbdbdb;width:100px;box-sizing: border-box;" size="15" value="{$DATA.bus_date}" onClick="WdatePicker()">&nbsp;~&nbsp;<input id="job_endtime" class="Wdate" type="text"  style="border:1px solid #dbdbdb;width:100px;box-sizing: border-box;" size="15" value="{$DATA.bus_date}" onClick="WdatePicker()">
			</td>
		</tr>
		<tr>
			<td class="C" valign="middle" width="10%">
				<span >&nbsp;&nbsp;&nbsp;JOB NO：</span>
				<textarea class="btn-radius-system" id="job_no" name="job_no" rows="1" style="width:100px;"></textarea>
			</td>
			<td class="C" valign="middle" width="10%">
				<span>&nbsp;&nbsp;&nbsp;对账状态：</span>
				<select name="duizhang" id="duizhang" class="btn-radius-system" style="width:100px;">
					<option value="">全部</option>
					<option value="已对账" >已对账</option>
					<option value="未对账" >未对账</option>
				</select>
			</td>
			<td class="C" valign="middle" width="10%">
				<span>&nbsp;&nbsp;&nbsp;JOB NO创建人：</span>
				<select name="creator" id="creator" class="btn-radius-system" style="width:100px;">
					<option value="">全部</option>
					{foreach key=userid item=last_name from=$USERS}
						<option value="{$last_name}" >{$last_name}</option>
					{/foreach}
				</select>
			</td>
			<td class="C" valign="middle" width="10%">
				<span>&nbsp;&nbsp;&nbsp;业务分类：</span>
				<select name="yewu_leixing" id="yewu_leixing" class="btn-radius-system" style="width:100px;">
					<option value="ALL">全部</option>
					<option value="报关" >报关</option>
					<option value="运输" >运输</option>
					<option value="出入库" >出入库</option>
					<option value="空运" >空运</option>
					<option value="海运" >海运</option>
					<option value="Local配送" >Local配送</option>
				</select>
			</td>
		</tr>
		<tr>
			<td class="C" valign="middle" width="10%">
				<span>&nbsp;&nbsp;&nbsp;对接状态：</span>
				<select name="duijie" id="duijie" class="btn-radius-system" style="width:100px;">
					<option value="">全部</option>
					<option value="已对接" >已对接</option>
					<option value="未对接" >未对接</option>
				</select>
			</td>
			<td class="C" valign="middle" width="10%">
				<span>对账日期：</span>
				<input id="duizhang_startdate" class="Wdate" type="text" style="border:1px solid #dbdbdb;width:100px;box-sizing: border-box;" size="15" value="{$DATA.bus_date}" onClick="WdatePicker()">&nbsp;~&nbsp;<input id="duizhang_enddate" class="Wdate" type="text"  style="border:1px solid #dbdbdb;width:100px;box-sizing: border-box;" size="15" value="{$DATA.bus_date}" onClick="WdatePicker()">
			</td>
			<td class="C" valign="middle" width="10%">
				<span>&nbsp;&nbsp;&nbsp;对接金蝶：</span>
				<input type="checkbox" id="istoerp" class="btn-radius-system" />
			</td>
			<td class="C" valign="middle" width="10%">
				<input id="BasicSearchreput" class="createauto" name="submit" onclick="submitResult(event,'')" value="查询" type="button">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input id="BasicSearchreput" class="createauto" name="submit" onclick="submitResult(event,'export')" value="导出All" type="button">
			</td>
		</tr>
	</tbody>
</table>
<div id="div_everymonth" style="float:left; padding-left:10px; padding-top:20px; padding-right:10px;">
	{include file="langjie/duizhang_content.tpl"}            
</div>
</html>
<div id="rptContentLoading" class="ContentLoadingDiv">
    <img src="themes/icon/loading.gif">
</div>
<script>
{literal}
//查询
function submitResult(event,stype)
{
	var surl = "module=Customreport&action=CustomreportAjax&file=duizhang&ajax=yes";
	//对账类型：客户和供应商
	var baoguan_leixing = ld('#baoguan_leixing').val();
	surl += "&baoguan_leixing="+baoguan_leixing;
	if(ld('#search_name') != undefined && ld('#search_name').val() != ''){
		surl += "&search_name="+ ld('#search_name').val();
	}
	//job 开始日期
	if(ld('#job_starttime') != undefined && ld('#job_starttime').val() != ''){
		surl += "&job_starttime="+ ld('#job_starttime').val();
	}
	//job 结束日期
	if(ld('#job_endtime') != undefined && ld('#job_endtime').val() != ''){
		surl += "&job_endtime="+ ld('#job_endtime').val();
	}
	//job no
	if(ld('#job_no') != undefined && ld('#job_no').val() != ''){
		surl += "&job_no="+ ld('#job_no').val();
	}
	//对账
	if(ld('#duizhang') != undefined && ld('#duizhang').val() != ''){
		surl += "&duizhang="+ ld('#duizhang').val();
	}
	//创建人
	if(ld('#creator') != undefined && ld('#creator').val() != ''){
		surl += "&creator="+ ld('#creator').val();
	}
	//业务类型
	if(ld('#yewu_leixing') != undefined && ld('#yewu_leixing').val() != ''){
		surl += "&yewu_leixing="+ ld('#yewu_leixing').val();
	}
	//对账日期 开始日期
	if(ld('#duizhang_startdate') != undefined && ld('#duizhang_startdate').val() != ''){
		surl += "&duizhang_startdate="+ ld('#duizhang_startdate').val();
	}
	//对账日期 结束日期
	if(ld('#duizhang_enddate') != undefined && ld('#duizhang_enddate').val() != ''){
		surl += "&duizhang_enddate="+ ld('#duizhang_enddate').val();
	}
	
	//对接金蝶
	if(ld('#istoerp') != undefined && ld('#istoerp').val() != ''){
		if(ld('#istoerp').is(':checked')){
			surl += "&istoerp=是";
		}else{
			surl += "&istoerp=否";
		}

	}
	//对接状态
	if(ld('#duijie') != undefined && ld('#duijie').val() != ''){
		surl += "&duijie="+ ld('#duijie').val();
	}
	//导出
	if(stype == 'export'){
		surl += "&export=yes";
		var checkedobj=ld(" [name=duizhang_chk]:checked");
		var idstring = '';
		ld.each(checkedobj,function(){
			idstring += ','+ld(this).attr("tag");
		})
		if(idstring != ''){
			surl += "&billids="+idstring;
		}
		document.location.href='index.php?'+surl;
		return false;
	}
	if(stype == 'duizhang'){
		surl += "&update_duizhang=yes";
		var billids = ld('#hidden_billid').val();
		if(billids != ''){
			surl += "&billids="+billids;
			RemindsMsg("", "LdPopWidth400px", '', "yes", "yes", "确定是否更改已选择的单据为已对账？");
			 //确定按钮
			ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
				ld('#rptContentLoading').show();
				new Ajax.Request(
					'index.php',
					{
						queue: {
							position: 'end',
							scope: 'command'
						},
						method: 'post',
						postBody:surl,
						onComplete: function(response) {
							ld('#rptContentLoading').hide();
							ld('#div_everymonth').html(response.responseText);                                  
						}
					}
				);
			});
		}
	}else if(stype == 'kingdee'){
		surl += "&save_kingdee=yes";
		var billids = ld('#hidden_billid').val();
		if(billids != ''){
			surl += "&billids="+billids;
			RemindsMsg("", "LdPopWidth400px", '', "yes", "yes", "确定是否同步单据到金蝶？");
			 //确定按钮
			ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
				ld('#rptContentLoading').show();
				new Ajax.Request(
					'index.php',
					{
						queue: {
							position: 'end',
							scope: 'command'
						},
						method: 'post',
						postBody:surl,
						onComplete: function(response) {
							ld('#rptContentLoading').hide();
							if(response.responseText == 'error'){
								RemindsMsg("", "LdPopWidth400px", '', "yes", "", "同步数据中存在【对接金蝶：否】和【对账状态：未对账】的数据，同步失败！");
								return false;
							}else{
								RemindsMsg("", "LdPopWidth400px", '', "yes", "", "数据同步金蝶成功！");
								return false;
							}
						}
					}
				);
			});
		}
	}else{
		ld('#rptContentLoading').show();
		//alert(surl);
		new Ajax.Request(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody:surl,
				onComplete: function(response) {
					ld('#rptContentLoading').hide();
					ld('#div_everymonth').html(response.responseText);                                  
				}
			}
		);
	}
}
function cancelResult()
{
	ld('#search_accountname').val('');
	ld('#search_status').val('');
	ld('#search_name').val('');
	ld('#search_username').val('');
	ld('#search_createdtime').val('');
	submitResult();
}

//对账账套
function update_duizhang(){
	var checkedobj=ld(" [name=duizhang_chk]:checked");
	var idstring = '';
	ld.each(checkedobj,function(){
		idstring += ','+ld(this).attr("tag");
	})
	if(idstring == ''){
		RemindsMsg("","LdPopWidth400px","","yes","","请至少选择一条记录！");
		return false;
	}
	var surl = "module=Customreport&action=CustomreportAjax&file=duizhang&ajax=yes&update_duizhang=yes&billids="+idstring;
	//alert(surl);
	RemindsMsg("", "LdPopWidth400px", '', "yes", "yes", "确定是否更改已选择的单据为已对账？");
    //确定按钮
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
		ld('#rptContentLoading').show();
		new Ajax.Request(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody:surl,
				onComplete: function(response) {
					ld('#rptContentLoading').hide();
					var res = response.responseText;
					var res_arr = res.split('---');
					var strArray = res_arr[0].split(',');
					for(var i in strArray){
						//console.log(i);
						//console.log(strArray[i]);
						//console.log("sapn[name="+strArray[i]+"_zhuangtai]");
						ld("span[name='"+strArray[i]+"_zhuangtai']").each(function (){
							ld(this).html('已对账');
						});
						ld("span[name='"+strArray[i]+"_zhuangtai_date']").each(function (){
							ld(this).html(res_arr[1]);
						});
						//ld('#'+strArray[i]+'_zhuangtai').html('已对账');
						//alert(strArray[i]);
					}

					//ld('#div_everymonth').html(response.responseText);                      
				}
			}
		);
	});
}

//同步金蝶
function setKingdee(){
    var checkedobj=ld(" [name=duizhang_chk]:checked");
	var idstring = '';
	
	ld.each(checkedobj,function(){
		idstring += ','+ld(this).attr("tag");
	})
	if(idstring == ''){
		RemindsMsg("","LdPopWidth400px","","yes","","请至少选择一条记录！");
		return false;
	}
	var yewu_leixing = ld('#yewu_leixing').val();
	var baoguan_leixing = ld('#baoguan_leixing').val();
	var surl = "module=Customreport&action=CustomreportAjax&file=duizhang&save_kingdee=yes&idstring="+idstring+"&yewu_leixing="+yewu_leixing+"&baoguan_leixing="+baoguan_leixing;
	if(idstring != ''){
		surl += "&billids="+idstring;
		RemindsMsg("", "LdPopWidth400px", '', "yes", "yes", "确定是否同步单据到金蝶？");
		 //确定按钮
		
		ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
			ld('#rptContentLoading').show();
			new Ajax.Request(
				'index.php',
				{
					queue: {
						position: 'end',
						scope: 'command'
					},
					method: 'post',
					postBody:surl,
					onComplete: function(response) {
						ld('#rptContentLoading').hide();
						if(response.responseText == 'error'){
							RemindsMsg("", "LdPopWidth400px", '', "yes", "", "同步数据中存在【对接金蝶：否】和【对账状态：未对账】【对接账套：已对接】的数据，同步失败！");
							return false;
						}else{
							RemindsMsg("", "LdPopWidth400px", '', "yes", "", "同步金蝶成功！");
							return false;
						}
						
						//ld('#div_everymonth').html(response.responseText);                                  
					}
				}
			);
		});
	}
	return false;
}

function checkAll(obj){
	if(ld("input[name='chkall']").prop('checked'))
		ld("input[name='duizhang_chk']").prop("checked","true"); 
	else
		ld("input[name='duizhang_chk']").removeAttr("checked"); 
	
}
</script>
{/literal}

