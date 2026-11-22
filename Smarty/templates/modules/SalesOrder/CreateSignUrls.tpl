
    <div id="" style="max-height: 450px;">
        <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%" style="line-height:32px;">
            <tr>
                <th colspan="4">
                    {'DYNAMICASSIGNMENT'|@getFixedLabel}
                </th>
            </tr>

            {*控件 开始*}
            {foreach item=SignUrlInfo from=$SignUrlInfos}
                <tr>
                    <td align="right" width="250">
                        签署链接(复制发送给客户)：
                    </td>
                        <td align="left">
                            {$SignUrlInfo.SignUrl}
                        </td>
                </tr>

                <tr>
                    <td align="right">合同id：</td>
                    <td align="left">
                        {$SignUrlInfo.FlowId}
                    </td>
                </tr>
                <tr>
                    <td align="right">签署参与者机构名字：</td>
                    <td align="left">
                        {$SignUrlInfo.OrganizationName}
                    </td>
                </tr>
                <tr>
                    <td align="right">合同签署人姓名：</td>
                    <td align="left">
                        {$SignUrlInfo.Name}
                    </td>
                </tr>
                <tr>
                    <td align="right">合同签署人手机号：</td>
                    <td align="left">
                        {$SignUrlInfo.Mobile}
                    </td>
                </tr>
                <tr>
                    <td align="right">链接失效时间：</td>
                    <td align="left">
                        {$SignUrlInfo.Deadline|date_format:'%Y-%m-%d %H:%M:%S'}
                    </td>
                </tr>
            {/foreach}



        </table>
    </div>


