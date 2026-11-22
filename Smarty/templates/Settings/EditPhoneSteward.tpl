<div class="divPopOverflow">
<form action="index.php" method="post" name="Phone" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name='mode'/>
    <input type="hidden" name="module" value="Settings"/>
    <input type="hidden" name="action" value="SavePhoneSteward"/>
    <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
    <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>

    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td class="ld-form-item-label">
                {'CALLCENTERTYPE'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                <select name="interfaceType" class="ld-select-inner gwidth40" onChange="checkPhoneSteward(this)">
                    <option value=""></option>
                    {foreach key=key item=item from=$CALLCENTERTYPE}
                        <option value="{$item}" {if $CALLCENTERVALUE == $item}selected{/if}>{$item}</option>
                    {/foreach}
                </select>
            </td>
        </tr>
        <tr id="interfaceurl" style="display:{if $CALLCENTERVALUE neq '苏州九维'}none{/if}">
            <td class="ld-form-item-label">
                {$JIUWEIURLNAME}
                <input type="hidden" id="numinter" name="" value="{$JIUWEIURL}"/>
            </td>
            <td class="ld-form-item-content">
                <input class="ld-input-inner" type="text" name="jiuweiurl" value="{$JIUWEIURL}"/>
                <span style="color: grey">{'FOREXAMPLE'|@getTranstab}http://222.92.194.166:8081</span>
            </td>
        </tr>
        <tr id="interfaceprefix" style="display:{if $CALLCENTERVALUE neq '苏州九维'}none{/if}">
            <td class="ld-form-item-label">
                {'CALLCENTERPREFIX'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                <input class="ld-input-inner" type="text" name="jiuweiprefix" value="{$JIUWEIPREFIX}"/>
            </td>
        </tr>
        <tr id="interfaceurl_sopho" style="display:{if $CALLCENTERVALUE neq '苏州思孚'}none{/if}">
            <td class="ld-form-item-label">
                {$JIUWEIURLNAME_sopho}
                <input type="hidden" name="" value="{$JIUWEIURL_sopho}"/>
            </td>
            <td class="ld-form-item-content">
                <input class="ld-input-inner" type="text" name="sophourl" value="{$JIUWEIURL_sopho}"/>
                <span style="color: grey">{'FOREXAMPLE'|@getTranstab}http://218.4.144.6:8080</span>
            </td>
        </tr>
        <tr id="interfaceurl_sopho2" style="display:{if $CALLCENTERVALUE neq '苏州思孚'}none{/if}">
            <td class="ld-form-item-label">
                WebSocket{'COMPANYADDRESS'|@getTranstab}
                <input type="hidden" name="" value="{$JIUWEIURL_sopho}"/>
            </td>
            <td class="ld-form-item-content">
                <input class="ld-input-inner" type="text" name="sophourl2" value="{$JIUWEIURL_sopho2}"/>
                <span style="color: grey">{'FOREXAMPLE'|@getTranstab}http://218.4.144.6:8088</span>
            </td>
        </tr>
        <tr id="interfaceurl_hantian" style="display:{if $CALLCENTERVALUE neq '汉天EC2'}none{/if}">
            <td class="ld-form-item-label">
                {$HANTIANURLNAME}
                <input type="hidden" name="" value="{$HANTIANURL}"/>
            </td>
            <td class="ld-form-item-content">
                <input class="ld-input-inner" type="text" name="hantianurl" value="{$HANTIANURL}"/>
                <span style="color: grey">{'FOREXAMPLE'|@getTranstab}http://210.13.87.109:8088</span>
            </td>
        </tr>
        <tr id="interfaceurl_hantian2" style="display:{if $CALLCENTERVALUE neq '汉天EC2'}none{/if}">
            <td class="ld-form-item-label">
                {$HANTIANRELATENAME}
            </td>
            <td class="ld-form-item-content">
                <input onclick="checkPhoneStewardrelbox(this)" type="checkbox" name="htrelvalue" value="1"
                       {if $HANTIANRELVALUE eq 0}checked{/if} />
                <span style="color: grey;display:{if $HANTIANRELVALUE neq 0}none{/if}">{'HANTIANSEATSTATERELATETOCRM'|@getTranstab}</span>
            </td>
        </tr>
        {*// @edit:dong @date:2020/09/02 @reason: 添加天润融通旧*}
        <tr id="interface_enterpriseId_tianrun" style="display:{if $CALLCENTERVALUE neq '天润融通旧'}none{/if}">
            <td class="ld-form-item-label">
                {$TIANRUNENTERPRISEID}
            </td>
            <td class="ld-form-item-content">
                <input class="ld-input-inner" type="text" name="tianrun_enterpriseId" value="{$TIANRUNENTERPRISEIDVALUE}"/>
                <span style="color: grey">{'FOREXAMPLE'|@getTranstab}3000005</span>
            </td>
        </tr>
        <tr id="interface_zhanghao_tianrun" style="display:{if $CALLCENTERVALUE neq '天润融通旧'}none{/if}">
            <td class="ld-form-item-label">
                {$TIANRUNZHANGHAO}
            </td>
            <td class="ld-form-item-content">
                <input class="ld-input-inner" type="text" name="tianrun_zhanghao" value="{$TIANRUNZHANGHAOVALUE}"/>
            </td>
        </tr>
        <tr id="interface_password_tianrun" style="display:{if $CALLCENTERVALUE neq '天润融通旧'}none{/if}">
            <td class="ld-form-item-label">
                {$TIANRUNPASSWORD}
            </td>
            <td class="ld-form-item-content">
                <input class="ld-input-inner" type="text" name="tianrun_password" value="{$TIANRUNPASSWORDVALUE}"/>
            </td>
        </tr>
        {*// @edit:dong @date:2020/11/11 @reason: 添加天润融通新*}
        <tr id="interface_address_tianrun" style="display:{if $CALLCENTERVALUE neq '天润融通新'}none{/if}">
            <td class="ld-form-item-label">
                {$NEWTIANRUNINTERFACEADDRESS}
            </td>
            <td class="ld-form-item-content">
                <input class="ld-input-inner" type="text" name="newtianrun_address" value="{$NEWTIANRUNURLVALUE}"/>
            </td>
        </tr>
        <tr id="interface_accesskeyid_tianrun" style="display:{if $CALLCENTERVALUE neq '天润融通新'}none{/if}">
            <td class="ld-form-item-label">
                {$NEWTIANRUNACCESSKEYID}
            </td>
            <td class="ld-form-item-content">
                <input class="ld-input-inner" type="text" name="newtianrun_accesskeyid" value="{$NEWTIANRUNKEYIDVALUE}"/>
            </td>
        </tr>
        <tr id="interface_secret_tianrun" style="display:{if $CALLCENTERVALUE neq '天润融通新'}none{/if}">
            <td class="ld-form-item-label">
                {$NEWTIANRUNSECRET}
            </td>
            <td class="ld-form-item-content">
                <input class="ld-input-inner" type="text" name="newtianrun_secret" value="{$NEWTIANRUNSECRETVALUE}"/>
            </td>
        </tr>
    </table>

    {* editor:gyq_11 reason:呼叫参数设置界面重新排版 date:2016 05 09 *}

    <table class="ld-public-content-small padT0" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td colspan="2">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'PHONECALLINFIELDS'|@getFixedLabel}</div>
                </div>
            </td>
        </tr>
        {foreach key=results name=resultswork item=list from=$RESULTLIST}
            <tr>
                <td class="ld-form-item-label">
                    {if $list.fieldlabel neq ''}
                        <input type="checkbox" class="Bornone input-btn-align" id="select{$list.tabname}"
                               name="select{$list.tabname}" onclick="checkPhoneStewardtabname('{$list.tabname}')"
                               checked="true"/>
                    {else}
                        <input type="checkbox" class="Bornone input-btn-align" id="select{$list.tabname}"
                               name="select{$list.tabname}" onclick="checkPhoneStewardtabname('{$list.tabname}')"/>
                    {/if}
                    <label style="cursor:pointer;" for="select{$list.tabname}">{$list.tabname|@getTranstab}</label>
                </td>
                <td class="ld-form-item-content">
                    <input class="detailedViewTextBox" type="hidden" id="id{$list.tabname}Text"
                           name="name{$list.tabname}Text" value="{$list.fieldlabel}"
                           onclick="BodyClick(this,'divSelect{$list.tabname}');"/>
                    <input type="hidden" name="id{$list.tabname}" id="id{$list.tabname}" value="{$list.fieldid}"/>
                    <div id="divSelect{$list.tabname}" class="selectUser" style="">
                        <div width="100%" cellpadding="0" border="0" cellspacing="0"
                             style="overflow-y:auto;overflow-x: hidden;border:0px #ccc solid;background:white;">
                            {assign var=count_num value=0}
                            {assign var=colum_num value=2}
                            <ul style="width:100%;">
                                {*zkt 20220509 【ID1002802】【电话录音盒和灵当语音盒，增加销售线索来电和去电匹配字段（郭惠宇-亿海蓝）】*}
                                {if $list.tabname eq 'Leads'}
                                    {foreach key=key_one item=arr from=$LEADSRESULTLIST}
                                        {foreach key=sel_value item=value from=$arr}
                                            <li style="float:left;width:33%;">
                                                <table width="100%" cellspacing="0" cellpadding="0" border="0">
                                                    <tr>
                                                        <td width="10%" style="padding-right: 5px;">
                                                            {if $value eq 'selected'}
                                                                <input checked="" type="checkbox" id="cb_select_{$list.tabname}"
                                                                       name="cb_select_{$list.tabname}"
                                                                       onclick="SelectedPhoneStewardPhone('id{$list.tabname}Text','id{$list.tabname}','{$list.tabname}')"
                                                                       style="border:none;"/>
                                                            {else}
                                                                <input type="checkbox" name="cb_select_{$list.tabname}" id="cb_select_{$list.tabname}"
                                                                       onclick="SelectedPhoneStewardPhone('id{$list.tabname}Text','id{$list.tabname}','{$list.tabname}')"
                                                                       style="border:none;"/>
                                                            {/if}
                                                        </td>
                                                        <td>
                                                            <span id="sp_user_{$list.tabname}_{$count_num}"
                                                                  mark="sp_user_{$list.tabname}"
                                                                  style="text-aligna:left;"><label style="cursor:pointer;" top="select{$list.tabname}" onclick="clicklabeltochecked(this)">{$sel_value}</label></span>
                                                            <input id="txt_user_{$list.tabname}_{$count_num++}"
                                                                   mark="txt_user_{$list.tabname}" type="hidden"
                                                                   value="{$key_one}"/>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </li>
                                        {/foreach}
                                    {/foreach}
                                {elseif $list.tabname eq 'Accounts'}
                                    {foreach key=key_one item=arr from=$ACCOUNTRESULTLIST}
                                        {foreach key=sel_value item=value from=$arr}
                                            <li style="float:left;width:33%;">
                                                <table width="100%" cellspacing="0" cellpadding="0" border="0">
                                                    <tr>
                                                        <td width="10%" style="padding-right: 5px;">
                                                            {if $value eq 'selected'}
                                                                <input checked="" type="checkbox" id="cb_select_{$list.tabname}"
                                                                       name="cb_select_{$list.tabname}"
                                                                       onclick="SelectedPhoneStewardPhone('id{$list.tabname}Text','id{$list.tabname}','{$list.tabname}')"
                                                                       style="border:none;"/>
                                                            {else}
                                                                <input type="checkbox" name="cb_select_{$list.tabname}" id="cb_select_{$list.tabname}"
                                                                       onclick="SelectedPhoneStewardPhone('id{$list.tabname}Text','id{$list.tabname}','{$list.tabname}')"
                                                                       style="border:none;"/>
                                                            {/if}
                                                        </td>
                                                        <td>{* gyq_25 *}
                                                            <span id="sp_user_{$list.tabname}_{$count_num}"
                                                                  mark="sp_user_{$list.tabname}"
                                                                  style="text-aligna:left;"><label style="cursor:pointer;" top="select{$list.tabname}" onclick="clicklabeltochecked(this)">{$sel_value}</label></span>
                                                            <input id="txt_user_{$list.tabname}_{$count_num++}"
                                                                   mark="txt_user_{$list.tabname}" type="hidden"
                                                                   value="{$key_one}"/>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </li>
                                        {/foreach}
                                    {/foreach}
                                {elseif $list.tabname eq 'Contacts'}
                                    {foreach key=key_one item=arr from=$CONTACTSRESULTLIST}
                                        {foreach key=sel_value item=value from=$arr}
                                            <li style="float:left;width:33%;">
                                                <table width="100%" cellspacing="0" cellpadding="0" border="0">
                                                    <tr>
                                                        <td width="10%" style="padding-right: 5px;">
                                                            {if $value eq 'selected'}
                                                                <input checked="" type="checkbox" id="cb_select_{$list.tabname}"
                                                                       name="cb_select_{$list.tabname}"
                                                                       onclick="SelectedPhoneStewardPhone('id{$list.tabname}Text','id{$list.tabname}','{$list.tabname}')"
                                                                       style="border:none;"/>
                                                            {else}
                                                                <input type="checkbox" name="cb_select_{$list.tabname}" id="cb_select_{$list.tabname}"
                                                                       onclick="SelectedPhoneStewardPhone('id{$list.tabname}Text','id{$list.tabname}','{$list.tabname}')"
                                                                       style="border:none;"/>
                                                            {/if}
                                                        </td>
                                                        <td>
                                                            <span id="sp_user_{$list.tabname}_{$count_num}"
                                                                  mark="sp_user_{$list.tabname}"
                                                                  style="text-aligna:left;"><label style="cursor:pointer;" top="select{$list.tabname}" onclick="clicklabeltochecked(this)">{$sel_value}</label></span>
                                                            <input id="txt_user_{$list.tabname}_{$count_num++}"
                                                                   mark="txt_user_{$list.tabname}" type="hidden"
                                                                   value="{$key_one}"/>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </li>
                                        {/foreach}
                                    {/foreach}
                                    {*editor:gyq_76 reason:呼叫中心增加销售机会 2018/8/22 16:46*}
                                {elseif $list.tabname eq 'Potentials'}
                                    {foreach key=key_one item=arr from=$POTENTIALSRESULTLIST}
                                        {foreach key=sel_value item=value from=$arr}
                                            <li style="float:left;width:33%;">
                                                <table width="100%" cellspacing="0" cellpadding="0" border="0">
                                                    <tr>
                                                        <td width="10%" style="padding-right: 5px;">
                                                            {if $value eq 'selected'}
                                                                <input checked="" type="checkbox" id="cb_select_{$list.tabname}"
                                                                       name="cb_select_{$list.tabname}"
                                                                       onclick="SelectedPhoneStewardPhone('id{$list.tabname}Text','id{$list.tabname}','{$list.tabname}')"
                                                                       style="border:none;"/>
                                                            {else}
                                                                <input type="checkbox" name="cb_select_{$list.tabname}" id="cb_select_{$list.tabname}"
                                                                       onclick="SelectedPhoneStewardPhone('id{$list.tabname}Text','id{$list.tabname}','{$list.tabname}')"
                                                                       style="border:none;"/>
                                                            {/if}
                                                        </td>
                                                        <td>
                                                            <span id="sp_user_{$list.tabname}_{$count_num}"
                                                                  mark="sp_user_{$list.tabname}"
                                                                  style="text-aligna:left;"><label style="cursor:pointer;" top="select{$list.tabname}" onclick="clicklabeltochecked(this)">{$sel_value}</label></span>
                                                            <input id="txt_user_{$list.tabname}_{$count_num++}"
                                                                   mark="txt_user_{$list.tabname}" type="hidden"
                                                                   value="{$key_one}"/>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </li>
                                        {/foreach}
                                    {/foreach}
                                {elseif $list.tabname eq 'Vendors'}
                                    {foreach key=key_one item=arr from=$VENDORSRESULTLIST}
                                        {foreach key=sel_value item=value from=$arr}
                                            <li style="float:left;width:33%;">
                                                <table width="100%" cellspacing="0" cellpadding="0" border="0">
                                                    <tr>
                                                        <td width="10%" style="padding-right: 5px;">
                                                            {if $value eq 'selected'}
                                                                <input checked="" type="checkbox" id="cb_select_{$list.tabname}"
                                                                       name="cb_select_{$list.tabname}"
                                                                       onclick="SelectedPhoneStewardPhone('id{$list.tabname}Text','id{$list.tabname}','{$list.tabname}')"
                                                                       style="border:none;"/>
                                                            {else}
                                                                <input type="checkbox" name="cb_select_{$list.tabname}" id="cb_select_{$list.tabname}"
                                                                       onclick="SelectedPhoneStewardPhone('id{$list.tabname}Text','id{$list.tabname}','{$list.tabname}')"
                                                                       style="border:none;"/>
                                                            {/if}
                                                        </td>
                                                        <td>
                                                            <span id="sp_user_{$list.tabname}_{$count_num}"
                                                                  mark="sp_user_{$list.tabname}"
                                                                  style="text-aligna:left;"><label style="cursor:pointer;" top="select{$list.tabname}" onclick="clicklabeltochecked(this)">{$sel_value}</label></span>
                                                            <input id="txt_user_{$list.tabname}_{$count_num++}"
                                                                   mark="txt_user_{$list.tabname}" type="hidden"
                                                                   value="{$key_one}"/>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </li>
                                        {/foreach}
                                    {/foreach}
                                {elseif $list.tabname eq 'VendorContact'}
                                    {foreach key=key_one item=arr from=$VENDORCONTACTSRESULTLIST}
                                        {foreach key=sel_value item=value from=$arr}
                                            <li style="float:left;width:33%;">
                                                <table width="100%" cellspacing="0" cellpadding="0" border="0">
                                                    <tr>
                                                        <td width="10%" style="padding-right: 5px;">
                                                            {if $value eq 'selected'}
                                                                <input checked="" type="checkbox" id="cb_select_{$list.tabname}"
                                                                       name="cb_select_{$list.tabname}"
                                                                       onclick="SelectedPhoneStewardPhone('id{$list.tabname}Text','id{$list.tabname}','{$list.tabname}')"
                                                                       style="border:none;"/>
                                                            {else}
                                                                <input type="checkbox" name="cb_select_{$list.tabname}" id="cb_select_{$list.tabname}"
                                                                       onclick="SelectedPhoneStewardPhone('id{$list.tabname}Text','id{$list.tabname}','{$list.tabname}')"
                                                                       style="border:none;"/>
                                                            {/if}
                                                        </td>
                                                        <td>
                                                            <span id="sp_user_{$list.tabname}_{$count_num}"
                                                                  mark="sp_user_{$list.tabname}"
                                                                  style="text-aligna:left;"><label style="cursor:pointer;" top="select{$list.tabname}" onclick="clicklabeltochecked(this)">{$sel_value}</label></span>
                                                            <input id="txt_user_{$list.tabname}_{$count_num++}"
                                                                   mark="txt_user_{$list.tabname}" type="hidden"
                                                                   value="{$key_one}"/>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </li>
                                        {/foreach}
                                    {/foreach}
                                {/if}
                            </ul>
                        </div>
                    </div>
                </td>
            </tr>
        {/foreach}
    </table>
</form>
</div>