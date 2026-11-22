<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>年度租金计划表</title>
</head>
{literal}
<style>
.Forms-Forms { width:100%;font-family:Arial, Helvetica, sans-serif;}
.Forms-Forms .tableName{ color: #999999;font-family: 黑体;font-size: 15pt;margin-bottom:10px;}
.Forms-Forms  table { width:250%; border-top:1px solid #dedede; border-left:1px solid #dedede; border-collapse: collapse;}
.Forms-Forms  table tr td{ padding:0 5px; border-bottom:1px solid #dedede; border-right:1px solid #dedede; margin:0; font-size:12px; line-height:30px; }
.T-Color{ background:#7B95C7;text-align:center;font-weight:bold;color:#fff;}
.Forms-Forms  table tr td.Bgimg { background:url(thead_bg.png) repeat-x; font-size:14px; font-weight:bold; color:#555;}
.Forms-Forms  table tr td.Alone { background:#c0d3df;}
</style>
{/literal}
<body>
<div class="Forms-Forms">
<div class="tableName"><font color='red'>年度租金计划表: </font> {$DATETITLE}</div>
<table cellspacing="0" cellpadding="5" border="0" class="listTable">
    <tbody>
        <tr class="T-Color">
            <td  class="colHeader small">{$MOD.LBL_HXregion}</td>
            <td class="colHeader small">{$MOD.LBL_HxProductName}</td>
            <td class="colHeader small">{$MOD.LBL_HxHaverentArea}</td>
            <td class="colHeader small">{$MOD.LBL_HxSendrentArea}</td>
            <td class="colHeader small">{$MOD.LBL_HxRentPercent}</td>
            <td class="colHeader small">{$MOD.LBL_HxRMBYearPaymentPlan}</td>
            <td class="colHeader small">{$MOD.LBL_HxRMBCashBill}</td>
            <td class="colHeader small">{$MOD.LBL_HxRMBMonth}</td>
            <td class="colHeader small">{$MOD.LBL_HxRentMonthYear}</td>
            <td class="colHeader small">{$MOD.LBL_HxCostPrice}</td>
            <td class="colHeader small">{$MOD.LBL_HxGrossProfit}</td>
            {*<!--
            <td  class="colHeader small" width="100" align="center">{$MOD.LBL_HXregion}</td>
            <td class="colHeader small" width="200" align="center">{$MOD.LBL_HxProductName}</td>
            <td class="colHeader small" width="100" align="center">{$MOD.LBL_HxHaverentArea}</td>
            <td class="colHeader small" width="100" align="center">{$MOD.LBL_HxSendrentArea}</td>
            <td class="colHeader small" width="100" align="center">{$MOD.LBL_HxRentPercent}</td>
            <td class="colHeader small" width="100" align="center">{$MOD.LBL_HxRMBYearPaymentPlan}</td>
            <td class="colHeader small" width="100" align="center">{$MOD.LBL_HxRMBCashBill}</td>
            <td class="colHeader small" width="100" align="center">{$MOD.LBL_HxRMBMonth}</td>
            <td class="colHeader small" width="100" align="center">{$MOD.LBL_HxRentMonthYear}</td>
            <td class="colHeader small" width="100" align="center">{$MOD.LBL_HxCostPrice}</td>
            <td class="colHeader small" width="100" align="center">{$MOD.LBL_HxGrossProfit}</td>
            -->*}
            {$REPORTMONTHHEADER}
            
        </tr>
           {$REPORTHTML}
      {*<!--
       
        <tr  style="border:1px solid #999999;">
            <td class="listTableRow" style="background-color: #dbe2f2;"></td>
            <td class="listTableRow" style="background-color:#EEEEEE;">总计</td>
            <td class="listTableRow" style="background-color:#EEEEEE;">{$sumsubtotal_all}</td>
            <td class="listTableRow" style="background-color:#EEEEEE;"></td>
            <td class="listTableRow" style="background-color:#EEEEEE;"></td>
            <td class="listTableRow" style="background-color:#EEEEEE;"></td>
            <td class="listTableRow" style="background-color:#EEEEEE;"></td>
        </tr>-->*}
    </tbody>
</table>
</div>
</body>
</html>