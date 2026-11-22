{*//editor:gyq_144 reason:����  2019/9/12 13:55*}
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js?v={$GLOBALMINVERSION}"></script>
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="module" value="Settings"/>
    <input type="hidden" name="parenttab" value="Settings"/>
    <input type="hidden" name="action"/>
    <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
    <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
    <div class="main_grid_top">
        <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat" style="color:black">
            {'zhiyuan_setting'|@getFixedLabel}
        </span>
        </div>
        <div class="grid_tool">
            <div class="displayflex">
                {*wym 231226 BUG0077847 �������ĵ�һ����ť��Ϊ��ɫ*}
                <a href="javascript:;" class="ld-button ld-button-primary" onclick="zhiyuan_setting_edit()" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
                {if 'oem_crm'|@getCommonVersion eq 'no'}
                    {*wym 240507 BUG20240506-66 ��Զ�ӿ����ã���������û��*}
                    <a class="ld-button" href="http://51mis.com.cn/forum.php?mod=viewthread&tid=1786&fromuid=1" target="_blank" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>
                {/if}
            </div>
        </div>
    </div>
    <div class="main_grid_box">
        <div class="grid-analysis-box">
            <div class="grid-analysis-header">
            </div>
            <div class="cont_wrap clear_float">
                <table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <th colspan="2">{'THEINTERFACEPARAMENTERS'|@getFixedLabel}
                    </tr>
                    {*editor:gyq_165 reason:�޸Ĳ�����ʽ   2019/12/26 14:57 *}
                    {*wym 240507 BUG20240506-65 ����ͳһ�޸�Ϊ��ɫ����Ҫ��ǳ��ɫ*}
                    <tr id="setting_1" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                        <td style="color:black">{'WECHATAPPLETSETTINGSTITLE02'|@getFixedLabel}</td>
                        <td>{$CRM_URL}</td>
                    </tr>
                    <tr id="setting_2" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                        <td style="color:black" width="20%">{'ZhiyuanAccessAddress'|@getFixedLabel}</td>
                        <td width="80%">{$ZHIYUAN_URL}</td>
                    </tr>
                    <tr id="setting_3" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                        <td style="color:black">{'ZhiyuanSystemRegistrationCode'|@getFixedLabel}</td>
                        <td>{$REGISTERCODE}</td>
                    </tr>
                    <tr id="setting_4" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                        <td style="color:black">{'ZhiyuanUsername'|@getFixedLabel}</td>
                        <td>{$USERNAME}</td>
                    </tr>
                    <tr id="setting_5" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                        <td style="color:black">{'ZhiyuanUserPassword'|@getFixedLabel}</td>
                        <td>{$PASSWORD}</td>
                    </tr>
                </table>
                <div class="listRloesHelp">
                    <font color="red">{'TIP'|@getFixedLabel}:</font>
                    <ul>
                        {*wym 240507 BUG20240506-65 ����ͳһ�޸�Ϊ��ɫ����Ҫ��ǳ��ɫ*}
                        <li style="color:black">{'ZHIYUANSETTINGSREMIND01'|@getFixedLabel}</li>
                        <li style="color:black">{'ZHIYUANSETTINGSREMIND02'|@getFixedLabel}</li>
                        <li style="color:red">{'ZHIYUANSETTINGSREMIND03'|@getFixedLabel}</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</form>