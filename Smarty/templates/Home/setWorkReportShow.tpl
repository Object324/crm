{if $type eq 'settings'}
    <div class="ld-pop-container ld-table-container ld-table-container-lines">
        <div class="divPopOverflow">
            <table id="dv_workreportshow" class="" border="0" cellpadding="0" cellspacing="0" width="100%">
                <thead>
                    <tr>
                        <th width="35%" align="left">{'ZHPARENTMENUNMAE'|@getFixedLabel}</th>
                        <th width="35%" align="left">{'ENPARENTMENUNMAE'|@getFixedLabel}</th>
                        <th width="30%" align="center">{'WHETHERTOENABLE'|@getFixedLabel}</th>
                    </tr>
                </thead>
                <tbody>
                    {assign var='rowid' value='0'}
                    {foreach from=$WORKREPORTSHOW item=allcontent}
                        {assign var="rowid" value=$rowid+1}
                        {assign var="zh_fieldlabel" value=$WORKREPORTTYPE[$allcontent.type]['zh']}
                        {assign var="en_fieldlabel" value=$WORKREPORTTYPE[$allcontent.type]['en']}
                        <tr reporttype="{$allcontent.type}" tag="reportsettings">
                            {*ls 2021-10-20 【1002089】工作汇报，工作类别增加编辑功能*}
                            <td>
                                <input class="ld-input-inner" tag="zh_fieldlabel" title="{$zh_fieldlabel}" value="{$zh_fieldlabel}">
                            </td>
                            <td>
                                <input class="ld-input-inner" tag="en_fieldlabel" title="{$en_fieldlabel}" value="{$en_fieldlabel}">
                            </td>
                            <td align="center">
                                <input tag="presence" type="checkbox" class="second_switch" {if $allcontent.reportshow eq 'yes'}checked{/if}/>
                            </td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
        </div>
    </div>
{else}
    {* @edit:liushuai,2020-07-28,reason:ID1000926/工作汇报设置弹出层界面优化，增加“类别设置”和“文字描述设置”区块标签，文字描述可修改*}
    <table id="dv_workreportshowtwo" class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <th colspan="2">{'TextDescriptionSettings'|@getFixedLabel}</th>
        </tr>
        <tr>
            <td align="left" style="width:90%;padding:15px 10px;"><input class="ld-input-inner" name="fieldlabel_description" value="{'COOPERATIVEWORKTITLE'|@getFixedLabel}" placeholder="{$placeholder}"></td>
        </tr>
    </table>
{/if}