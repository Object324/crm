{*自定义统计图现在在首页的模板文件 *}
<div id="stuff_charts_{$tablestuff.Stuffid}" class="MatrixLayer MatrixLayer_row twoColumnWidget">
    <div id="chartInfoForm">
    <table width="100%" cellpadding="0" cellspacing="0" class="E_stripe">
        <tr id="headerrow_charts_{$tablestuff.Stuffid}" >
            <th class="N_con_tit">
                <div class="N_con_tit_name" style="float: left;">
                    <span class="icon-bluelt">{$tablestuff.Stufftitle}</span>
                </div>
            </th>
        </tr>
    </table>
    <table width="100%" cellpadding="0" cellspacing="0" class="small" >
        <tr id="maincont_row_{$tablestuff.Stuffid}">
            <td colspan="2">
                <div id="myChart_{$tablestuff.Stuffid}" class="EchartDiv" style="width: 100%;height:330px;"></div>
            </td>
        </tr>
    </table>
    </div>
</div>
