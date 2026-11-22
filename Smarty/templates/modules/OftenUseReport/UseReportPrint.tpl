<style type="text/css">@import url("themes/softed/style.css");</style>
<style type="text/css">@import url("themes/softed/OftenUseReport.css");</style>

<script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.min.js"></script>
<script type="text/javascript" language="javascript" src="{$JSURL}include/js/cls_wxOpenData.js?v={$GLOBALMINVERSION}"></script>
<style type="text/css">
	.print_span {
		height: 32px;
		line-height: 33px;
	}
    .print_table{
        border-left: 1px solid #DDDDDD;
        border-bottom: 1px solid #DDDDDD;
        border-top: 1px solid #DDDDDD;
    }
	.print_table tr th,
	.print_table tr td {
		height: 32px;
		line-height: 33px;
        border-right: 1px solid #ddd;
        border-top: 1px solid #ddd;
	}
</style>
<span class="print_span">{$REPORTNAMES}</span>
<table width="150%" cellspacing="0" cellpadding="3" border="0" class="small print_table">
	<tr>
	  {$REPORTFINDHEADER}
	</tr>
	{$REPORTFILTERHTML}
</table>
<script>
//36704: 报表-常用报表：打印，没有调出打印机选择界面
var wx_timestamp='{$timestamp}';
var wx_corpid='{$wx_corpid}';//'wxa246741d62d718f0';
var wx_agentid='{$wx_agentid}';//'1000345';
var wx_nonceStr='{$nonceStr}';
var wx_agent_signature='{$agentsignature}';
var wx_signature='{$signature}';
var iskehu001='{$iskehu001}';
 var ld = $;
var cls_wxOpenDataobj;
cls_wxOpenDataobj=new cls_wxOpenData();
       
cls_wxOpenDataobj.init();
//报表选中变色
function reportListOnMouseOver(sel_id){
    var rows = "report_"+sel_id;
    document.getElementById(rows).className = "lvtColDataHover";
}
function reportListOnMouseOut(sel_id,type){
    var rows = "report_"+sel_id;
    if(type == 'On'){
        document.getElementById(rows).className = "lvtColDataBj";
    }else{
        document.getElementById(rows).className = "lvtColData";
    }
}


window.print();
</script>