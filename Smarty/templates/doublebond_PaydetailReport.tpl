<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <title>应收款明细表</title>
    <meta http-equiv = "X-UA-Compatible" content = "IE=edge,chrome=1"/>
    <style type="text/css">@import url("themes/softed/style.css?v={$GLOBALMINVERSION}");</style>
    <style type="text/css">@import url("themes/softed/selfstyle.css?v={$GLOBALMINVERSION}");</style>
    <style type="text/css">@import url("themes/softed/common.css?v={$GLOBALMINVERSION}");</style>

    <script type="text/javascript" src="crmcommon/js/jquery/jquery.min.js"></script>
    <script type="text/javascript" src="crmcommon/js/jquery/jquery-ui.min.js"></script>
    <script type="text/javascript" language="JavaScript">
        var global_js_url = '';
        var language='{$LANGUAGE}';
        var ld = $;
    </script>
    <script language="JavaScript" type="text/javascript" src="include/language/zh.js"></script>
    <script language="javascript" type="text/javascript" src="crmcommon/js/My97DatePicker/WdatePicker.js?v={$GLOBALMINVERSION}"></script>
    <script language="JavaScript" type="text/javascript" src="include/js/general.js?v={$GLOBALMINVERSION}"></script><!--公共-->
    <script language="JavaScript" type="text/javascript" src="include/js/ldAjax.js?v={$GLOBALMINVERSION}"></script><!--公共-->
    <script language="JavaScript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/scriptaculous/prototype.js?v={$GLOBALMINVERSION}E"></script>
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
<div class="container" style="width: 1600px; margin: 0 auto">
    <div class="head_title" style="border-bottom: 2px solid #ccc">
        <h1>应收款明细表</h1>
    </div>
    <div style="margin-top: 20px; margin-bottom: 20px; clear: both">
        <form action="" id ='searchForm'>
            <table class="reportPopTable padLR10 padT5" border="0" cellpadding="0" cellspacing="0" width="100%" >
                <tbody>
                <tr>
                    <td class="C" valign="middle" align="center"  width="25%" >
                        <div class="search_div">
                            <span class="bigfont"><em style="color: red">*</em>结算组织：</span>
                            <select name="search_orgid" id="search_orgid" class="commonSelectPop" style="width:50%;">
                                <option value="100005">101  武汉双键开姆密封材料有限公司</option>
                                <option value="1">102  湖北双键精细化工有限公司</option>
                            </select>
                        </div>
                    </td>
                    <td class="C" valign="middle" align="center"  width="25%" >
                        <div class="search_div">
                            <span class="bigfont">客户编号：</span>
                            <input  id="search_account_start" class="btn-radius-system" value="" name="search_account_start"  type="text" style="margin-right: 10px">
                            <span>至</span>
                            <input id="search_account_end" class="btn-radius-system" value="" name="search_account_end"  type="text" style="margin-left: 10px">
                        </div>
                    </td>
                </tr>
                <tr>
                    <td class="C" valign="middle" align="center"  width="25%">
                        <div class="search_div">
                            <span class="smallfont">时间：</span>
                            {literal}
                                <input onclick="WdatePicker({startDate:'%y-%M-%d',dateFmt:'yyyy-MM-dd',alwaysUseStartDate:true});" id="search_BeginDate" class="btn-radius-system Wdate"  value="" name="search_BeginDate"  type="text" style="margin-right: 10px">
                                <span>至</span>
                                <input onclick="WdatePicker({startDate:'%y-%M-%d',dateFmt:'yyyy-MM-dd',alwaysUseStartDate:true});" id="search_FEndDate" class="btn-radius-system Wdate"  value="" name="search_FEndDate"  type="text" style="margin-left: 10px">
                            {/literal}
                        </div>
                    </td>
                    <td class="C" valign="middle" align="center"  width="25%" >
                        <div class="search_div">
                            <span class="bigfont">包含已出库未应收</span>
                            <input  id="search_FIncludePayEvaluate" class="btn-radius-system" value="" name="search_account_start"  type="checkbox" style="margin-right: 10px">
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
    </div>
    <div id="div_everymonth" style="">
        {include file="doublebond_PaydetailReport_content.tpl"}
    </div>
</div>
</body>
</html>

<script>
    var click =false;
    {literal}
    //查询
    function submitResult(event,stype)
    {
        var surl = "index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=doublebond_PaydetailReport&ajax=yes&language="+language;
        //序列号必填
        if(ld('#search_orgid') != undefined && ld('#search_orgid').val() != ''){
            surl += "&search_orgid="+ ld('#search_orgid').val();
        }else{
            RemindsMsg("","LdPopWidth400px","","yes","",'结算组织不能为空不能为空');
            return false;
        }

        var search_account_start = ld('#search_account_start').val();
        var search_account_end = ld('#search_account_end').val();
        var search_BeginDate = ld('#search_BeginDate').val();
        var search_FEndDate = ld('#search_FEndDate').val();
        var search_FIncludePayEvaluate = ld('#search_FIncludePayEvaluate').get(0).checked;
        surl += "&search_account_start="+search_account_start+"&search_account_end="+search_account_end+"&search_BeginDate="+search_BeginDate+"&search_FEndDate="+search_FEndDate+"&search_FIncludePayEvaluate="+search_FIncludePayEvaluate;

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
                }else{
                    RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
                    ld('#div_everymonth').html(data.result.content);
                }

            },error:function(){//请求出错处理
                RemindsMsg("","LdPopWidth400px","","yes","",'接口调用失败');
            }
        })

        return false;
    }
</script>
{/literal}
