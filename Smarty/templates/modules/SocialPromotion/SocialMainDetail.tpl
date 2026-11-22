
<div class="socialDetail">
    <div class="socialDetailLeft detail">
        <table border=0 cellspacing=0 cellpadding=0 width=100% >
            {foreach key=header item=detail from=$BLOCKS}
                {if $header eq 'show_origin_information'}
                    <tr>
                        <td class="" colspan="4" style="padding:0px;width:100%;">
                            <div class="">{$RELATEDORDERINFORMATION}</div>

                        </td>
                    </tr>
                {else}
                    <tr><td style="width:100%;">

                            <!-- Detailed View Code starts here-->
                            <table border=0 cellspacing=0 cellpadding=0 width=100% >
                                {assign var=publiclog value='RECORDSOFOPERATION'|@getFixedLabel}
                                {if $header eq $publiclog  && $ACCOUNTSET eq 0}
                                    <tr id='publicaccountlogtr' style='display:none;'>
                                        <td>
                                            {if $BLOCKINITIALSTATUS[$header] neq 1}
                                                {assign var='arrawcls' value=''}
                                            {else}
                                                {assign var='arrawcls' value='On'}
                                            {/if}
                                            <div class="DivCName DivCNamehover" onclick="showHideStatus('publicaccountlog','aidpublicaccountlog');">
                                                <span class="{$arrawcls}" id="aidpublicaccountlog"></span>{$header}
                                            </div>
                                            <div id="publicaccountlog" style="overflow: auto; height: 100px; width: 100%;display:block;padding-left: 5px;">
                                                <!-- {$PUBLICACCOUNT_LOG} -->
                                            </div>
                                        </td>
                                    </tr>
                                {/if}
                            </table>

                            {if $header neq 'Comments'&& $header neq $publiclog}
                            {assign var='arrawcls' value=''}

                            {if $HIDDENSTYLE eq 1}
                                <div class="DivCName">
                                {if !empty($BLOCKS_LABELTOID[$header])}
                                    <span class="{$arrawcls}" id="aid{$BLOCKS_LABELTOID[$header]|@str_replace:' ':''}" name="aid{$BLOCKS_LABELTOID[$header]|@str_replace:' ':''}"></span>{$header}
                                {else}
                                    <span class="{$arrawcls}" id="aid{$header|@str_replace:' ':''}" name="aid{$header|@str_replace:' ':''}"></span>{$header}
                                {/if}
                                </div>
                            {else}
                                {if !empty($BLOCKS_LABELTOID[$header])}
                                    <div class="DivCName DivCNamehover" onclick="showHideStatus('tbl{$BLOCKS_LABELTOID[$header]|@replace:' ':''}','aid{$BLOCKS_LABELTOID[$header]|@replace:' ':''}');">
                                        <span class="{$arrawcls}" id="aid{$BLOCKS_LABELTOID[$header]|@replace:' ':''}" name="aid{$BLOCKS_LABELTOID[$header]|@replace:' ':''}"></span>{$header}
                                {else}
                                    <div class="DivCName DivCNamehover" onclick="showHideStatus('tbl{$header|@replace:' ':''}','aid{$header|@replace:' ':''}');">
                                        <span class="{$arrawcls}" id="aid{$header|@replace:' ':''}" name="aid{$header|@replace:' ':''}"></span>{$header}
                                {/if}
                                        {$header|@getBlockInfoForLinks:'detailview'}
                                    </div>
                                {/if}
                            {/if}

                            {if $header neq 'Comments'&& $header neq $publiclog}


                            <div class="DivCNotice" style="width:auto;display:block;" id="tbl{$header|replace:' ':''}" name="tbl{$header|replace:' ':''}" >
                                    <table border=0 cellspacing="1" cellpadding=0 width="100%" class="DetailContentTable">
                                        {foreach item=details from=$detail name=detailforeach}

                                            <tr>
                                                {foreach key=label item=data from=$details}
                                                    {assign var=keyid value=$data.ui}
                                                    {assign var=keyval value=$data.value}
                                                    {assign var=rawvalue value=$data.rawvalue}
                                                    {assign var=keytblname value=$data.tablename}
                                                    {assign var=keyfldname value=$data.fldname}
                                                    {assign var=keycolname value=$data.colname}
                                                    {assign var=keyfldid value=$data.fldid}
                                                    {assign var=keyoptions value=$data.options}
                                                    {assign var=keysecid value=$data.secid}
                                                    {assign var=keyseclink value=$data.link}
                                                    {assign var=keycursymb value=$data.cursymb}
                                                    {assign var=keysalut value=$data.salut}
                                                    {assign var=keyaccess value=$data.notaccess}
                                                    {assign var=keycntimage value=$data.cntimage}
                                                    {assign var=keyadmin value=$data.isadmin}
                                                    {assign var=display_type value=$data.displaytype}
                                                    {assign var=_readonly value=$data.readonly}
                                                    {assign var=fieldonly value=$data.fieldonly}
                                                    {assign var=allowedit value=$data.allowedit}
                                                    {assign var=allowprofilefieldedit value=$data.profileeditfield}
                                                    {assign var=value_name value=$data.value_name}
                                                    {assign var=ShowHyperlinks value=$data.ShowHyperlinks}
                                                    {assign var = "BUSINESSQUERY" value = $data.businessquery}{* 是否为工商查询字段 *}
                                                    {assign var = "ENABLEBUSINESS" value = $data.isenablebusiness}{* 是否启用工商查询 *}
                                                    {assign var = "BUSINESSFUZZYQUERY" value = $data.isenablebusinessfuzzyquery}{* 是否启用工商模糊查询 *}
                                                    {if $ACCOUNTSCONTACTS eq 'yes'}
                                                        {assign var=ID value=$data.recordid}
                                                        {assign var=MODULE value=$data.module}
                                                    {/if}

                                                    {if $label neq ''}
                                                        {*editor:gyq_170 reason:0039489: （51mis.com/kfbtest）客户模块明细界面：红框中全部要加上全角的冒号  2020/3/10 15:45*}
                                                        {assign var=label value=$label|cat:"："}
                                                        {if $keycntimage ne ''}
                                                            <td class="DetailedTd1Label" width="20%" align="right"><input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/><span>{$keycntimage}</span></td>
                                                            {elseif $keyid eq '71' || $keyid eq '72'}<!-- Currency symbol -->
                                                            <td class="DetailedTd1Label" width="20%" align="right"><span>{$label}</span><input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/></td>
                                                        {elseif $keyid eq '9'}
                                                            <td class="DetailedTd1Label" width="20%" align="right"><input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/><span>{$label}</span></td>
                                                        {elseif $keyid eq '14'}
                                                            <td class="DetailedTd1Label" width="20%" align="right"><span>{$label}</span><input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/></td>
                                                        {elseif $keyid eq '202'}
                                                            <td class="DetailedTd1Label" width="20%" align="right"><input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/><span>{$label}{if $ISSOURCEMODULE} {$ISSOURCEMODULE|@getTranstab}{/if}</span></td>
                                                        {elseif $keyid eq '102'||$keyid eq '112'}
                                                            <td class="DetailedTd1Label" width="20%" align="right"><input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/><span>{$label}{if $ISSOURCEMODULE} {$ISSOURCEMODULE|@getTranstab}{/if}</span></td>
                                                        {elseif $keyid eq '15'}
                                                            <td class="DetailedTd1Label" width="20%" align="right"><input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/><span>{$label}</span></td>
                                                        {elseif $keyid eq '1109' || $keyid eq '1108'}
                                                            <td class="DetailedTd1Label" width="20%" align="right">
                                                                <a id="AttachmentBlock" class="icon-homeimg icon-askgrey" style="cursor:pointer;margin:-4px 2px 0 0;" title="" onclick="getLinksUrl('0','module','AttachmentBlock');"></a>
                                                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/><span>{$label}</span>
                                                            </td>
                                                        {elseif $keyid eq '56' && $keyfldname eq 'viewothers'}
                                                            <td class="DetailedTd1Label" width="20%" align="right">
                                                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>
                                                                <span><b title="{'viewothers'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>{$label}</span>
                                                            </td>
                                                        {elseif $keyid eq '56' && $keyfldname eq 'editothers'}
                                                            <td class="DetailedTd1Label" width="20%" align="right">
                                                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>
                                                                <span><b title="{'editothers'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>{$label}</span>
                                                            </td>
                                                        {elseif $keyid eq '56' && $keyfldname eq 'delothers'}
                                                            <td class="DetailedTd1Label" width="20%" align="right">
                                                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>
                                                                <span><b title="{'delothers'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>{$label}</span>
                                                            </td>
                                                        {elseif $keyid eq '56' && $keyfldname eq 'viewselfbills'}
                                                            <td class="DetailedTd1Label" width="20%" align="right">
                                                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>

                                                                <input  type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>


                                                                <span><b title="{'viewselfbills'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>{$label}</span>


                                                            </td>
                                                        {elseif $keyid eq '56' && $keyfldname eq 'edit_other_mobile'}
                                                            <td class="DetailedTd1Label" width="20%" align="right">
                                                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>

                                                                <input  type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>

                                                                <span><b title="{'edit_other_mobile'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>{$label}</span>


                                                            </td>
                                                        {elseif $keyid eq '56' && $keyfldname eq 'edit_me_mobile'}
                                                            <td class="DetailedTd1Label" width="20%" align="right">
                                                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>

                                                                <input  type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>

                                                                <span><b title="{'edit_me_mobile'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>{$label}</span>

                                                            </td>
                                                        {elseif $keyid eq '56' && $keyfldname eq 'is_mobile_style'}
                                                            <td class="DetailedTd1Label" width="20%" align="right">
                                                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>
                                                                <input  type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>

                                                                <span><b title="{'is_mobile_style'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>{$label}</span>

                                                            </td>
                                                        {elseif $keyid eq '56' && $keyfldname eq 'select_servicedetail'}
                                                            <td class="DetailedTd1Label" width="20%" align="right">
                                                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>
                                                                <input  type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>


                                                                <span><b title="{'select_servicedetail'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>{$label}</span>

                                                            </td>
                                                        {elseif $keyid eq '56' && $keyfldname eq 'select_due_date'}
                                                            <td class="DetailedTd1Label" width="20%" align="right">
                                                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>
                                                                <input  type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>

                                                                <span><b title="{'select_due_date'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>{$label}</span>

                                                            </td>
                                                        {elseif $keyid eq '56' && $keyfldname eq 'helpdesk_log'}
                                                            <td class="DetailedTd1Label" width="20%" align="right">
                                                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>
                                                                <input  type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
                                                                <span><b title="{'helpdesk_log'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>{$label}</span>

                                                            </td>
                                                        {elseif $keyid eq '56' && $keyfldname eq 'accountallview'}
                                                            <td class="DetailedTd1Label" width="20%" align="right">
                                                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>

                                                                <input  type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>


                                                                <span><b title="{'accountallview'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>{$label}</span>

                                                            </td>
                                                        {elseif $keyid eq '56' && $keyfldname eq 'view_quantity'}
                                                            <td class="DetailedTd1Label" width="20%" align="right">
                                                                <input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/>
                                                                <input  type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>

                                                                <span>
                                                            {if 'Quotes'|@vtlib_isModuleActive eq 'true' && 'SalesOrder'|@vtlib_isModuleActive eq 'true'}
                                                                <b title="{'Quotes'|@getTranstab}{'AND'|@getTranstab}{'SalesOrder'|@getTranstab}{'showthetotalinventory'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>

    														{elseif 'Quotes'|@vtlib_isModuleActive eq 'true' && 'SalesOrder'|@vtlib_isModuleActive eq 'false'}
    															<b title="{'Quotes'|@getTranstab}{'showthetotalinventory'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>
    														{elseif 'Quotes'|@vtlib_isModuleActive eq 'false' && 'SalesOrder'|@vtlib_isModuleActive eq 'true'}
    															<b title="{'SalesOrder'|@getTranstab}{'showthetotalinventory'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>
    														{else}
    															<b title="{'showthetotalinventory'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>
                                                            {/if}
                                                                    {$label}
                                                        </span>
                                                            </td>
                                                        {elseif $keyid eq '83'}
                                                        {else}
                                                            <td class="DetailedTd1Label" width="20%" align="right"><input type="hidden" id="hdtxt_IsAdmin" value="{$keyadmin}"/><span>{$label}</span></td>
                                                        {/if}
                                                        {if $allowedit eq 'no'||$allowprofilefieldedit eq 'no'}
                                                            {include file="DetailNoEdit.tpl"}
                                                        {else}
                                                            {if (($USERPHOTOPERMIT eq 'yes'&&$keyid eq 105 )||$DETAILBUTTON.Edit.permit eq 'yes' ||$DETAILBUTTON.moduledetailEdit.permit eq 'yes' ) && $display_type neq '2' }
                                                                {if !empty($DETAILVIEW_AJAX_EDIT)}
                                                                    {if $EDITSTATUS eq 'no' || $keyfldname eq 'currency_id'
                                                                    ||$keyfldname eq 'initmoney' || $_readonly == 1
                                                                    ||($MODULE eq 'BankAccountSet' && ($keyfldname eq 'initmoney' || $keyfldname eq 'currency_id')&& $CONFIRMEDST eq '1')
                                                                    ||(($MODULE eq 'Accounts'||$MODULE eq 'ServiceCharge')&& ($keytblname eq 'ld_contactdetails' || $keytblname eq 'LD_contactaddress' || $keytblname eq 'ld_contactscf')
                                                                    || ($MODULE eq 'Potentials' && $keyfldname eq 'sales_stage') )
                                                                    ||($MODULE eq 'Users'&&$keyfldname eq 'approvestatus')}

                                                                        {include file="DetailNoEdit.tpl"}
                                                                    {else}
{*                                                                        // @edit:dong @date:2020/07/16 @reason: 详情页使用不能小编辑的模板*}
                                                                        {include file="DetailNoEdit.tpl"}
{*                                                                      {include file="DetailViewUI.tpl"}*}
                                                                    {/if}
                                                                {else}

                                                                    {include file="DetailViewFields.tpl"}
                                                                {/if}
                                                            {else}

                                                                {include file="DetailViewFields.tpl"}
                                                            {/if}
                                                        {/if}
                                                    {else}
                                                        <td width="20%" class="DetailedTd2Info" align="right"></td>
                                                        <td width="30%" class="DetailedTd2Info" align="left" ></td>
                                                    {/if}
                                                {/foreach}
                                            </tr>
                                        {/foreach}
                                    </table>
                                </div>
                                {/if}
                        </td>
                    </tr>
                {/if}
            {/foreach}
            <tr><td style="width:100%;">

                    <!-- Detailed View Code starts here-->

                    {if $header neq 'Comments'&& $header neq $publiclog}
                        {if $HIDDENSTYLE eq 1}
                            <div class="DivCName">
                                <span class="{$arrawcls}" id="aid{$header|@str_replace:' ':''}" name="aid{$header|@str_replace:' ':''}"></span>{$header}
                            </div>
                        {else}
                            <div class="DivCName DivCNamehover" onclick="showHideStatus('tbltgm','aidtgm')">

                                <span class="{$arrawcls}" id="aidtgm" name="aidtgm"></span>{'ACTIVITYMARKETINGPROMOTIONCODE'|@getFixedLabel}
                            </div>
                        {/if}


                    {/if}
                    <div id="tbltgm" name="tbltgm">
                        <table class="DetailContentTable " style="width: 100%; text-align: center">
                            {foreach key=key item=item from=$shareUserValue}
                                {if $item['lastname'] neq ''}
                                    <tr>
                                        <td width="25%">{$item['lastname']}</td>
                                        <td  width="25%">
                                        {* 模拟点击img 展示图片*}
                                            <img width="0" height="0" name="qrcode{$key}" onclick="" data-original="{$item['qrcode']}" src="{$item['qrcode']}" alt="">
                                            <a href="javascript:void(0)" onclick="ld('img[name=qrcode{$key}]').click()">{'ACTIVITYMOBILEPHONESCANANDSHARE'|@getFixedLabel}</a>
                                        </td>
                                        <td  width="25%">
                                            <a  href="{$item['downQrcode_URL']}" target="_blank" >{'ACTIVITYDOWNEWM'|@getFixedLabel}</a>
                                        </td>
                                        <td  width="25%">
                                            <a href="javascript:void(0)" class="copyUrl" data-clipboard-text="{$item['shareUrl']}">{'ACTIVITYCOPYURL'|@getFixedLabel}</a>
                                        </td>
                                    </tr>
                                {/if}
                            {/foreach}
                        </table>
                    </div>
                   </td>
            </tr>
        </table>
    </div>
    <div class="socialDetailRight detail">

        <div class="phone" style="top: 0">
            <div class="bg-inner">
                <div class="phone-header">
                    <div class="phone-time">
                        12:00
                    </div>
                    <div class="phone-notch">
                        <div class="receiver"></div>
                        <div class="camera"></div>
                    </div>
                    <div class="header-right">
                        <div class="signal">
                            <ul>
                                <li></li>
                                <li></li>
                                <li></li>
                                <li></li>
                            </ul>
                        </div>
                        <div class="wifi">
                            <div class="wifi1">
                                <div class="wifi2">
                                    <div class="wifi3">
                                        <div class="wifi4">
                                            <div class="wifi5">
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="battery"></div>
                    </div>

                    <div class="phone-title">
                        <div class="left-arrow">
                            <img src="../images/left-arrow.png" />
                        </div>
                        <div class="middle-title">{'CRMSOCIALPROMOTION'|@getFixedLabel}</div>
                        <div class="right-3-dots">...</div>
                    </div>
                </div>

                <div class="phone-content">
                    <div class="phone-content-header" style="background-color: {$formheadcolor}">
                        <h3 id="show_activitytitle">{$activitytitle}</h3>
                        <p id="show_activityintroduction">{if $activityintroduction eq ''}参与有奖！{else}{$activityintroduction|regex_replace:"/(^|[\n ])([\w]+?:\/\/.*?[^ \"\n\r\t<]*)/":"\\1<a href=\"\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])((www|ftp)\.[\w\-]+\.[\w\-.\~]+(?:\/[^ \"\t\n\r<]*)?)/":"\\1<a href=\"http://\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])([a-z0-9&\-_.]+?)@([\w\-]+\.([\w\-\.]+\.)*[\w]+)/i":"\\1<a href=\"mailto:\\2@\\3\">\\2@\\3</a>"|regex_replace:"/,\"|\.\"|\)\"|\)\.\"|\.\)\"/":"\""|replace:"\n":"<br>"}{/if}</p>
                    </div>
                    <div id="mainFieldsIphone">

                        {include file='modules/SocialPromotion/SocialCustomFieldIphone.tpl'}
                    </div>
                    <div class="phone-content-button">
                        <button class="submit" style="background-color: {$buttoncolor}" id="show_buttonname" type="button">{$buttonname}</button>
                    </div>

                </div>
                <div class="phone-footer"></div>
            </div>

        </div>

    </div>
</div>
<script>


    // 使用listview.js中的previewImage函数 展示图片
    ld(function(){
        // 复制插件
        var Clipboard = new ClipboardJS('.copyUrl');
        Clipboard.on('success', function(e) {
            //@edit:ljj,2023-08-03,reason:BUG0070376 kfbcrm-表单推广-单据详情-点击复制链接，提示信息样式错误
            MessagePopup.TipZero_success(arrJsPopLabel['SUCCESSFULLYCOPIED']);
        });

        var images= ld('#tbltgm img');
        if(images.length>0){
            ld.each(images,function (i,val) {
                // 使用previewImage函数 需要提前加载加载事件。要不会出现第一次点击不能弹出
                previewImage(val);
            })
        }
    })
</script>