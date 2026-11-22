<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>租赁统计表</title>
</head>
{literal}
<style>
.Forms-Forms { width:100%;font-family:Arial, Helvetica, sans-serif;}
.Forms-Forms .tableName{ color: #999999;font-family: 黑体;font-size: 15pt;margin-bottom:10px;}
.Forms-Forms  table { width:100%; border-top:1px solid #dedede; border-left:1px solid #dedede; border-collapse: collapse;}
.Forms-Forms  table tr td{ padding:0 5px; border-bottom:1px solid #dedede; border-right:1px solid #dedede; margin:0; font-size:12px; line-height:30px; }
.T-Color{ background:#7B95C7;text-align:center;font-weight:bold;color:#fff;}
.Forms-Forms  table tr td.Bgimg { background:url(thead_bg.png) repeat-x; font-size:14px; font-weight:bold; color:#555;}
.Forms-Forms  table tr td.Alone { background:#c0d3df;}
</style>
{/literal}
<body>
<div class="Forms-Forms">
<div class="tableName">租赁统计表:  {$DATETITLE}</div>
<table cellspacing="0" cellpadding="5" border="0" class="listTable">
    <tbody>
        <tr class="T-Color">
            <td class="colHeader small">{$MOD.LBL_HXregion}</td>
            <td class="colHeader small">{$MOD.LBL_HxProductName}</td>
            <td class="colHeader small" >{$MOD.LBL_HxHaverentArea}</td>
            <td class="colHeader small">{$MOD.LBL_HxSendrentArea}</td>
            <td class="colHeader small" >{$MOD.LBL_HxRentPercent}</td>
            <td class="colHeader small" >{$MOD.LBL_HxRMBMonthMeter}</td>
            <td class="colHeader small">{$MOD.LBL_HxRMBMonth}</td>
            <td class="colHeader small">{$MOD.LBL_HxRMBYear}</td>
            <td class="colHeader small" >{$MOD.LBL_HxProdcutCostPrice}</td>            
        </tr>
           {$REPORTHTML}
     
    </tbody>
</table>
</div>
</body>
</html>