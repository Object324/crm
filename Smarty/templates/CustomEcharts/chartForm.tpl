    <table border="0" cellspacing="0" cellpadding="0" width="100%" class="DetailContentTable linefeed">
        <tbody>
        <tr>
            <td colspan="4">
                <div name="displayfields">
                    <table border="0" cellspacing="0" cellpadding="0" width="100%" class="DetailContentTable linefeed">
                        <tbody>
                        {*基本信息设置  都是一样的  包含图表类型 图表名称 图表文件夹 图表描述四项*}
                        {include file="CustomEcharts/basicSet.tpl"}
                        {*图表参数*}
                        {*X轴（类目） 统计维度设置 *}
                        {include file="CustomEcharts/groupBySet.tpl"}
                        {*Y轴（数值）-- 统计字段设置 *}
                        {include file="CustomEcharts/columnsSet.tpl"}
                        {*显示设置 所有的都一样*}
                        {include file="CustomEcharts/showSet.tpl"}
                        </tbody>
                    </table>
                </div>
            </td>
        </tr>
        </tbody>
    </table>
