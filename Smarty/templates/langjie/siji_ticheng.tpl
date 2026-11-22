<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <title>司机提成表</title>
    <meta http-equiv = "X-UA-Compatible" content = "IE=edge,chrome=1"/>
	<style type="text/css">@import url("themes/softed/style.css");</style>
    <style type="text/css">@import url("themes/softed/selfstyle.css");</style>
    <style type="text/css">@import url("themes/softed/common.css");</style>

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
</head>
<body style="overflow: hidden;">
	<table class="reportPopTable padLR10 padT5" border="0" cellpadding="0" cellspacing="0" width="100%">
		<tbody>
			<tr>
				<td class="C" valign="middle" width="40%" colspan="2">
					<span>派车日期：</span>
					<input id="siji_startdate" class="Wdate" type="text" style="border:1px solid #dbdbdb;width:100px;box-sizing: border-box;" size="15" value="{$SIJI_STARTDATE}" onClick="WdatePicker()">&nbsp;~&nbsp;<input id="siji_enddate" class="Wdate" type="text"  style="border:1px solid #dbdbdb;width:100px;box-sizing: border-box;" size="15" value="{$SIJI_ENDDATE}" onClick="WdatePicker()">
				</td>
				<td class="C" valign="middle" width="40%" colspan="2">
					<span>&nbsp;&nbsp;&nbsp;状态：</span>
					<select name="siji_zhuangtai" id="siji_zhuangtai" class="btn-radius-system width100" onchange="submitResult(event,'')">
						<option value="" >全部</option>
						<option value="yiqueren" >已确认</option>
						<option value="weiqueren" >未确认</option>
					</select>
				</td>
			</tr>
			<tr>
				<td class="C" valign="middle" width="10%">
					<span>&nbsp;&nbsp;&nbsp;司机</span>
					<input type="text" id="siji_name" value="" class="btn-radius-system" />
				</td>
				<td class="C" valign="middle" width="10%">
					<span>车牌号码</span>
					<input type="text" id="siji_chepaihao" value="" class="btn-radius-system" />
				</td>
				<td class="C" valign="middle" width="10%">
					<span>&nbsp;&nbsp;&nbsp;形态</span>
					<input type="text" id="siji_xingtai" value="" class="btn-radius-system" />
				</td>
				<td class="C" valign="middle" width="10%">
					<input id="BasicSearchreput" class="createauto b_radius3" name="submit" onclick="submitResult(event,'')" value="查询" type="button">
				</td>
			</tr>
		</tbody>
	</table>
	<div id="div_everymonth" style="float:left; padding-left:10px; padding-top:20px; padding-right:10px;">
		{include file="langjie/siji_ticheng_content.tpl"}            
	</div>
</body>
</html>
<script>
{literal}
//查询
function submitResult(event,stype)
{
	var surl = "module=Customreport&action=CustomreportAjax&file=siji_ticheng&ajax=yes";
	//siji 开始日期
	if(ld('#siji_startdate') != undefined && ld('#siji_startdate').val() != ''){
		surl += "&siji_startdate="+ ld('#siji_startdate').val();
	}
	//siji 结束日期
	if(ld('#siji_enddate') != undefined && ld('#siji_enddate').val() != ''){
		surl += "&siji_enddate="+ ld('#siji_enddate').val();
	}
	//状态
	if(ld('#siji_zhuangtai') != undefined && ld('#siji_zhuangtai').val() != ''){
		surl += "&siji_zhuangtai="+ ld('#siji_zhuangtai').val();
	}
	//司机
	if(ld('#siji_name') != undefined && ld('#siji_name').val() != ''){
		surl += "&siji_name="+ ld('#siji_name').val();
	}
	//车牌号码
	if(ld('#siji_chepaihao') != undefined && ld('#siji_chepaihao').val() != ''){
		surl += "&siji_chepaihao="+ ld('#siji_chepaihao').val();
	}
	//形态
	if(ld('#siji_xingtai') != undefined && ld('#siji_xingtai').val() != ''){
		surl += "&siji_xingtai="+ ld('#siji_xingtai').val();
	}
	if(stype == 'duizhang'){
		surl += "&update_duizhang=yes";
		var billids = ld('#hidden_billid').val();
		if(billids != ''){
			surl += "&ids="+billids;
			RemindsMsg("", "LdPopWidth400px", '', "yes", "yes", "确定是否更改单据状态未已确认？");
			 //确定按钮
			ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
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
							ld('#div_everymonth').html(response.responseText);                                  
						}
					}
				);
			});
		}
	}else{
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
					ld('#div_everymonth').html(response.responseText);                                  
				}
			}
		);
	}
}
</script>
{/literal}
