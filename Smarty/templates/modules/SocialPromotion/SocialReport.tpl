{*//表单推广 统计数据页面 特殊页面*}
{*人员分为下拉框 需要第二个文件中的函数*}
<script type="application/javascript" src="include/js/picklist.js"></script>
<script type="application/javascript" src="include/js/modules/OftenUseReport/OftenUseReport.js"></script>
{*人员分为下拉框 end*}
{*daterangepicker插件*}
<script type='text/javascript' src='include/daterangepicker/moment.js'></script>
<script type='text/javascript' src='include/daterangepicker/daterangepicker.js'></script>
<link rel="stylesheet" type="text/css" href="include/daterangepicker/daterangepicker-bs3.css"/>
{*daterangepicker插件 end*}
<div id="searchAcc" class="grid-analysis-search" style='width:{$PAGEWIDTHPERCENT}%;'>
<form name="basicSearch" method="post" action="index.php">
    <table border="0" cellspacing="0" cellpadding="0">
        <tr id="OftenUseReport_search_date">
                {$BASICFILTERHTML}
            </tr>
        <tr>
            <td>
                <label class="Name lfloat" style="margin-bottom: 0 !important;line-height: 52px;">
                    <span style="font-weight:normal;">{'RANGESTAFF'|@getFixedLabel}</span>
                </label>
                {include file='Comprehensivereport/SmownerSearchScope.tpl'}
            </td>
            <td align="right" >
                <!--生成报表按钮-->
                <input name="submit" id='BasicSearchreput' type="button" onclick="getReportContentHtml(this,'basicSearch')" class="createauto b_radius3 marL20 b" style="height: 25px;" value="{'QUERYTO'|@getFixedLabel}"/>
                <!--生成报表按钮end-->
            </td>
        </tr>
    </table>
</form>
</div>

<div class="cont_wrap clear_float">
{*    // @edit:dong @date:2020/07/17 @reason: 添加最小高度 否则选择单一用户时 出现滚动条*}
    <div id="UseReportList" class="DivCNotice-list" style="min-height:300px;margin:0px;">
{*        加载内容模板*}
        {include file='modules/SocialPromotion/SocialReportHtml.tpl'}
    </div>
</div>
<script>
    ld(function () {
        // 加载页面加载时间选择插件
        ld('#startmonth').daterangepicker(null, function(start, end, label) {
        });
    })
</script>
