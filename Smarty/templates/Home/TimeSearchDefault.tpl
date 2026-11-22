{*系统设置的默认时间 zxm20211112 【首页，销售简报时间增加可设置默认值（王楠）】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001002217*}
<input type="hidden" value="{$boardid}">
<div class="">
    <table class="relatedListsTable" border="0" cellpadding="0" cellspacing="0">
        <tbody>
            <tr>
                <td>{'Default'|@getFixedLabel}：</td>
                <td width="200">
                    <div>
                        <label>
                            <select id="defaultTime" class="commonSelectPop" style="width: 180px;margin-left: 3px;">
                                {foreach item=select_name key=data_type from=$DATASELECT}
                                    {if $data_type == $deploy_value}
                                        <option selected value="{$data_type}"> {$select_name} </option>
                                    {else}
                                        <option value="{$data_type}"> {$select_name} </option>
                                    {/if}
                                {/foreach}
                            </select>
                        </label>
                    </div>
                </td>
            </tr>
        </tbody>
    </table>
</div>