<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<title>BOM清单查询</title>
	<meta http-equiv = "X-UA-Compatible" content = "IE=edge,chrome=1"/>
	<style type="text/css">@import url("themes/softed/style.css?v={$GLOBALMINVERSION}");</style>
	<style type="text/css">@import url("themes/softed/selfstyle.css?v={$GLOBALMINVERSION}");</style>
	<style type="text/css">@import url("themes/softed/common.css?v={$GLOBALMINVERSION}");</style>

	<script type="text/javascript" src="crmcommon/js/jquery/jquery.min.js?v={$GLOBALMINVERSION}"></script>
	<script type="text/javascript" src="crmcommon/js/jquery/jquery-ui.min.js?v={$GLOBALMINVERSION}"></script>
	<script type="text/javascript" language="JavaScript">
		var global_js_url = '';
		var language='{$LANGUAGE}';
		var ld = $;
	</script>
	<script language="JavaScript" type="text/javascript" src="include/language/zh.js"></script>
	<script language="javascript" type="text/javascript" src="crmcommon/js/My97DatePicker/WdatePicker.js?v={$GLOBALMINVERSION}"></script>
	<script language="JavaScript" type="text/javascript" src="include/js/general.js?v={$GLOBALMINVERSION}"></script><!--公共-->
	<script language="JavaScript" type="text/javascript" src="include/js/ldAjax.js?v={$GLOBALMINVERSION}"></script><!--公共-->
	<script language="JavaScript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/scriptaculous/prototype.js?v={$GLOBALMINVERSION}"></script>
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
	<style>
		.search_div{
			display: flex;
			align-items: center;
		}
		.search_div b{
			margin-left: 5px;
		}
		.bigfont{
			font-size: 14px;
			font-weight: bold;
			width: 150px;
			text-align: right;
		}
		.smallfont{
			font-size: 13px;
			width: 150px;
			text-align: right;
		}
		.icon-askgrey-help{
			width: 20px;
			height: 17px;
			background-position: -5px -250px;
			position: relative;
			cursor: pointer;
		}
	</style>
</head>
<body style="width: 100%;">
<div style="width: 100%;"></div>
<div class="container" style="width: 1200px; margin: 0 auto">
	<div class="head_title" style="border-bottom: 2px solid #ccc">
		<h1>{$LANG['title']}</h1>
	</div>
	<div style="margin-top: 20px; margin-bottom: 20px; clear: both">
		<form action="" id ='searchForm'>
			<table class="reportPopTable padLR10 padT5" border="0" cellpadding="0" cellspacing="0" width="100%" >
				<tbody>
				<tr>
					<td class="C" valign="middle" align="center"  width="25%" >
						<div class="search_div">
							<span class="bigfont"><em style="color: red">*</em>{$LANG['xlh']}：</span>
							<input id="search_no" class="btn-radius-system"  value="" name="search_no"  type="text">
							<b onclick="onclickHelp('search_no')"  class="icon-homeimg icon-askgrey-help"></b>
						</div>
					</td>
					<td class="C" valign="middle" align="center"  width="25%" >
						<div class="search_div">
							<span class="bigfont">{$LANG['xh']}：</span>
							<input id="search_model" class="btn-radius-system" value="" disabled name="search_model"  type="text">
						</div>
					</td>
				</tr>
				<tr>
					{if $LANGUAGE eq 'zh'}
						<td class="C" valign="middle" align="center"  width="25%" >
							<div class="search_div">
								<span class="smallfont" >{$LANG['bjh']}：</span>
								<input id="search_idnrk" class="btn-radius-system"  value="" name="search_idnrk"  type="text">
							</div>
						</td>
					{/if}
					<td class="C" valign="middle" align="center"  width="25%">
						<div class="search_div">
							<span class="smallfont"  >{$LANG['bjmc']}：</span>
							<input id="search_kmptx" class="btn-radius-system"  value="" name="search_kmptx"  type="text">
							<b onclick="onclickHelp('search_kmptx')"  class="icon-homeimg icon-askgrey-help"></b>
						</div>
					</td>

				</tr>
				<tr>
					<td class="C" valign="middle" align="center" width="30%" colspan="4" >
						<input style="width: 200px; margin-top: 10px;"  id="BasicSearchreput" class="createauto" name="submit" onclick="submitResult(event,'')" value="{$LANG['cx']}" type="button">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					</td>
				</tr>
				</tbody>
			</table>
		</form>
		<p><span id="apimsg" ></span><span style="float: right">{if $LANGUAGE eq 'zh'}如遇任何问题，可致电我公司售后服务热线：0086-4008807575{else}Any questions please contact our After Sales Serivce hotline: 0086-4008807575{/if}</span></p>
	</div>
	<div id="div_everymonth" style="">
		{include file="climaveneta_bomSearch_content.tpl"}
	</div>
</div>
</body>
</html>

<script>
	var click =false;
	{literal}
	function onclickHelp(type) {
		var msg = '';
		switch (type) {
			case 'search_no':
				if(language=='zh'){
					msg ='1、“Serial Number”为必填项，其位于机组电控箱门外或电控箱内的铭牌上<br/>';
					msg +='2、“Serial Number”通常由10位字母及数字组成，必须准确填写，如B100001000；部分机组由2组10位字母及数字组成，请填写后面的一组信息，例如：B100002000-H100001000，则填写H100001000'
				}else{
					msg ='1. "Serial Number" must be filled in correctly. You may get this information from the nameplate pasted on/behind the electric cabinet door of the machine.<br>';
					msg +='2. You need to fill in the serial number completely and exactly.The serial number is usually composed of 10 letters and numbers,for example：B100001000. Part of the unit consists of 2 groups of 10 letters and Numbers. Please fill in the following group of information, for example: B100002000-H100001000, please fill in H100001000';
				}
				break;
			case 'search_kmptx':
				if(language=='zh'){
					msg ='为缩小备件搜索范围，您在输入机组Serial Number后，可在“备件名称”一栏中简要写明备件名称或规格，如“传感器”';
				}else{
					msg =' You may fill in the brief spare part description in column "Spare Part Description" to find what you need easily, for example: sensor.';
				}
				break;
		}
		RemindsMsg("","LdPopWidth600px","","yes","",msg);
	}
	//查询
	function submitResult(event,stype)
	{
		var surl = "index.php?module=Customreport&action=CustomreportAjax&file=climaveneta_bomSearch&ajax=yes&language="+language;
		//序列号必填
		if(ld('#search_no') != undefined && ld('#search_no').val() != ''){
			surl += "&search_no="+ ld('#search_no').val();
		}else{
			RemindsMsg("","LdPopWidth400px","","yes","",'序列号不能为空');
			return false;
		}

		ld.ajax({
			url: surl,
			type: 'POST',
			data: ld('#searchForm').serialize(),
			dataType: 'json',
			async: true,//
			timeout: 10000,
			success: function (data) {
				if(data.code==1){
					ld('#div_everymonth').html(data.result.content);
					ld('#search_model').val(data.result.model);
				}else{
					RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
					ld('#div_everymonth').html(data.result.content);
					ld('#search_model').val('');
				}

			},error:function(){//请求出错处理
				RemindsMsg("","LdPopWidth400px","","yes","",'8021接口调用失败转为8022');
				var surl = "index.php?module=Customreport&action=CustomreportAjax&file=climaveneta_bomSearch&ajax=yes&language="+language+"&apiId=8022";
				surl += "&search_no="+ ld('#search_no').val();
				ld.ajax({
					url: surl,
					type: 'POST',
					data: ld('#searchForm').serialize(),
					dataType: 'json',
					async: true,//
					timeout: 10000,
					success: function (data) {
						if(data.code==1){
							ld('#div_everymonth').html(data.result.content);
							ld('#search_model').val(data.result.model);
						}else{
							RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
							ld('#div_everymonth').html(data.result.content);
							ld('#search_model').val('');
						}

					},error:function(){//请求出错处理
						RemindsMsg("","LdPopWidth400px","","yes","",'接口调用失败');

					}
				})
			}
		})

		return false;
	}
</script>
{/literal}
