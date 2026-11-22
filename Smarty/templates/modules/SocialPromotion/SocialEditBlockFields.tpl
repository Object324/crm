<script>
    var activitytypeArr ={$activitytypeArr};
    var mode ='{$MODE}';
</script>
{*    //复制*}
<script language="javascript" type="text/javascript" src="{$JSURL}include/js/modules/SocialPromotion/SocialPromotionCreate.js?v={$GLOBALMINVERSION}"></script>

<script language="javascript" type="text/javascript" src="include/js/clipboard.min.js?v={$GLOBALMINVERSION}"></script>
{*<script type="text/javascript">*}
{*    AjaxJSPage('clipboard_min_js','include/js/modules/SocialPromotion/clipboard.min.js');*}
{*</script>*}

<div>
    <input type="hidden" name="step" value="{$step}">
    <div class="multi-step-soc">
        <div class="step {if $step eq 4}completed current{/if}{if $step eq 1}current {/if}">
            <label>{'SETACTIVITYTYPE'|@getFixedLabel}</label>
            <div class="socialdot"></div>
        </div>
        <div class="step {if $step  eq 4}completed current{/if}">
            <label>{'CUSTOMACTIVITYPAGE'|@getFixedLabel}</label>
            <div class="socialdot"></div>
        </div>

        <div class="step {if $step eq 4}completed current{/if}">
            <label>{'SHARINGSETTINGS'|@getFixedLabel}</label>
            <div class="socialdot"></div>
        </div>

        <div class="step {if $step eq 4}completed current{/if}">
            <label>{'SPCOMPLETED'|@getFixedLabel}</label>
            <div class="socialdot"></div>
        </div>
    </div>
    {if $step neq 4}
    {foreach key=key item=data from=$BLOCKS name=blocknames}
        <div class="stepContent " id="step{$smarty.foreach.blocknames.index+1}"  {if $smarty.foreach.blocknames.index+1 neq 1} style="display: none"{/if}>
            <table style="float: left;" border=0 cellspacing="0" cellpadding=0 id="{if $smarty.foreach.blocknames.index+1 eq 2}coustomPage{/if}{if $smarty.foreach.blocknames.index+1 eq 3}sharePage{/if}" {if $smarty.foreach.blocknames.index+1 neq 1} width="60%"{else}width = "100%"{/if} class=" {if $smarty.foreach.blocknames.index+1 neq 1} social-form{/if}">
                <colgroup><col style="width: 200px"><col style="width: calc(100% - 200px)"><col style="width: 200px"><col style="width: calc(100% - 200px)"></colgroup>
                {foreach key=mainlabel item=maindata from=$data}
                    <tr>
                        {assign var="uitype" value=$maindata[0][0][0]}
                        {assign var="fieldonly" value=$maindata[0][1][0]}
                        {assign var="fldlabel" value=$maindata[1][0]}
                        {assign var="fldlabel_sel" value=$maindata[1][1]}
                        {assign var="fldlabel_combo" value=$maindata[1][2]}
                        {assign var="fldlabel_other" value=$maindata[1][3]}
                        {assign var="fldname" value=$maindata[2][0]}
                        {assign var="fldvalue" value=$maindata[3][0]}
                        {assign var="secondvalue" value=$maindata[3][1]}
                        {assign var="thirdvalue" value=$maindata[3][2]}
                        {assign var="typeofdata" value=$maindata[4]}
                        {assign var="colname" value=$maindata[5]}
                        {assign var="vt_tab" value=$maindata[5][0]}
                        {if $uitype eq 15}
                            {assign var="optText" value=$maindata[6]}
                        {/if}
                        {assign var="allowedit" value=$maindata['allowedit']}
                        {assign var="allowedit_presence" value=$maindata['allowedit_presence']}
                        {assign var="allowcreate" value=$maindata['allowcreate']}
                        {assign var="allowcreate_presence" value=$maindata['allowcreate_presence']}
                        {assign var="allowprofileeditfield" value=$maindata['profileeditfield']}
                        {assign var='value_name' value=$maindata['value_name']}
                        {if $typeofdata eq 'M'}
                            {assign var="mandatory_field" value="*"}
                        {else}
                            {assign var="mandatory_field" value=""}
                        {/if}
                        {* vtlib customization: Help information for the fields *}
                        {assign var="usefldlabel" value=$fldlabel}
                        {assign var="fldhelplink" value=""}
                        <!--$uitype值为 2 26 53 4 19 28 56 27 1 -->
                        {if $FIELDHELPINFO && $FIELDHELPINFO.$fldname}
                            {assign var="fldhelplinkimg" value='help_icon.gif'|@lingdang_imageurl:$THEME}
                            <!--assign var="fldhelplink" value="<img style='cursor:pointer' onclick='vtlib_field_help_show(this, \"$fldname\");' border=0 src='$fldhelplinkimg'>"-->
                            {if $uitype neq '10'}
                                {assign var="usefldlabel" value="$fldlabel $fldhelplink"}
                            {/if}
                        {/if}
                        {*映射单据*}
                        {if $maindata[5] == 'mappingmodule' && $smarty.foreach.blocknames.index+1 eq 1}
                            {*                        // @edit:dong @date:2020/07/17 @reason: 编辑不允许修改活动类型*}
                            {if  $MODE eq 'edit'}
                                <tr>
                                    <td class="ld-form-item-label">{$fldlabel}</td>
                                    <td class="ld-form-item-content">
                                        <input type="hidden" id="{$fldname}" name="{$fldname}" value="{$maindata['value_name']}">
                                        {*BUG0056459 表单推广单据编辑界面，映射单据字段值显示英文*}
                                        {if $fldname eq 'mappingmodule'}
                                            {$maindata['value_name']|@getTranstab}
                                        {else}
                                            {$maindata['value_name']}
                                        {/if}
                                    </td>
                                </tr>
                            {else}
                                {include file='modules/SocialPromotion/SocialPickClickList.tpl'}
                            {/if}
                        {elseif $maindata[5] == 'h5buttoncolor' && $smarty.foreach.blocknames.index+1 eq 1}
                            <td class="ld-form-item-label">
                                {$fldlabel}
                            </td>
                            <td class="ld-form-item-content">
                                <input fieldonly='{$fieldonly}' style="width: 200px;" type="text" tabindex="{$vt_tab}" name="{$fldname}" id ="{$fldname}" value="{$fldvalue}" class="ld-input-inner" >
                                <div class="choosed_color btn1 SocialPromotion" style="top:8px;left:-32px;background: {$fldvalue};" name="div_{$fldname}"  onclick="socialSetColpick('{$fldname}')"></div>
                            </td>
                        {elseif $smarty.foreach.blocknames.index+1 eq 1}
                            {*@edit:dong @date:2020/07/17 @reason: 编辑不允许修改活动类型*}
                            {if  $MODE eq 'edit' and  ($maindata[5] eq 'social_activitytype'  or $maindata[5] eq 'mappingmodule' )}
                                <tr>
                                    <td class="ld-form-item-label">{$fldlabel}</td>
                                    <td class="ld-form-item-content">
                                        <input type="hidden" id="{$fldname}" name="{$fldname}" value="{$maindata['value_name']}">{$maindata['value_name']}
                                    </td>
                                </tr>
                            {else}
                                {include file='DetailView/EditViewUI.tpl'}
                            {/if}
                        {elseif $maindata[5] == 'buttoncolor' || $maindata[5] == 'formheadcolor'}
                            <td colspan="2">
                                    <div>
                                        <label>{$fldlabel}</label>
                                        <input type="text" class="ld-input-inner" style="width: 200px;" name="{$fldname}" id ="{$fldname}" value="{$fldvalue}">
                                        <div class="choosed_color btn1 SocialPromotion" style="background: {$fldvalue};" name="div_{$fldname}"  onclick="socialSetColpick('{$fldname}')"></div>
                                    </div>
                            </td>
                        {elseif $maindata[5] == 'customfieldsorder'}
                            <td colspan="2" >
                                <div class="selectField">
                                    <span>{'ACTIVITYFIELDSETTINGS'|@getFixedlabel}</span>
                                    <button class="ld-button ld-button-primary" type="button" onclick="getCustomField()">{'ACTIVITYADDFIELD'|@getFixedlabel}</button>
                                </div>
                                <div>
                                    <table cellspacing=1 cellpadding=0>
                                        <thead>
                                        <tr>
                                            <th>{'ACTIVITYCRMFIELD'|@getFixedlabel}</th>
                                            <th>{'ACTIVITYDISPLAYLABEL'|@getFixedlabel}</th>
                                            <th>{'ACTIVITYMUSTFILL'|@getFixedlabel}</th>
                                            <th>{'ACTIVITYONLYFIELD'|@getFixedlabel}</th>
                                            <th>{'ACTIVITYOPERATION'|@getFixedlabel}</th>
                                        </tr>
                                        </thead>
                                        <tbody id="mainFields">
                                            {*   加载自定义字段的模板 需要 $customFields  数组*}
                                            {include file='modules/SocialPromotion/SocialCustomFieldHtml.tpl'}
                                        </tbody>
                                    </table>
                                </div>
                            </td>
                        {elseif $maindata[5] == 'activityintroduction'}
                            <td colspan="2">
                                <div>
                                    <label>{$usefldlabel}</label>
                                    <script id="{$fldname}" name="{$fldname}" type="text/plain" class="edui-default" style="background-color:#E8E8E8; height:100px; width: 100%;">{$fldvalue}</script>
                                </div>
                            </td>
                        {elseif $maindata[5] == 'shareintroduction'}
                            <td colspan="2">
                                <div>
                                    <font color="red">*</font>
                                    <label>{$usefldlabel}</label>
                                    <textarea value="{$fldvalue}" name="{$fldname}" id="{$fldname}" tabindex="{$vt_tab}" class="ld-textarea-inner" style="height:50px;">{$fldvalue}</textarea>
                                </div>
                            </td>
                        {elseif $maindata[5] == 'sharepicture' }
                            {* 共享范围字段展示 展示再分享图片上面*}
                                <td colspan="2">
                                    <div>
                                        <label>{'ACTIVITYSHARESCOPE'|@getFixedLabel}</label>
                                        <div class="shareuser">
                                            <input type="hidden" name="newShareUsers" value="{$newShareUsers}" />
                                            <input type="hidden" name="oldShareUsers" value="{$oldShareUsers}" />
                                            <label><input {if $shareUserType eq 0 }checked{/if} onclick="clearHiddenShareUserValue()" name="shareUserType" type="radio" value="0" style="margin-right: 5px;margin-top: -2px;" />{'ACTIVITYSHARESCOPENOSHARE'|@getFixedLabel}</label>
                                            {*create'  不传值js代码无法运行*}
                                            {*ls 20220915 表单推广->新建，“分享设置”界面共享范围选择共享给其他人选择成员保存后，界面一直显示加载中*}
                                            <label><input {if $shareUserType eq 1 }checked{/if} onclick="detailbutton_click(this,'SocialPromotion','Share',{$ID})" name="shareUserType" type="radio" value="1" style="margin-right: 5px;margin-top: -2px;" />{'ACTIVITYSHAREWITHOTHERS'|@getFixedLabel}</label>
                                        </div>
                                    </div>
                                </td>
                            </tr>

                            <tr>
                                <td colspan="2">
                                    <div>
                                        <font color="red">*</font><label>{$fldlabel}</label>
                                        <div class="showPicture">
                                            <img src="themes/images/socialupload.jpg" alt="" width="80" />
                                        </div>
                                        <div name="{$fldname}_I__" style="width: 400px;">
                                            <div name="{$fldname}" class="wu-example">
                                            </div>
                                        </div>
                                    </div>
                                </td>
                        {else}
                            <td colspan="2">
                                <div>
                                    {if $maindata[5] == 'sharetitle'}<font color="red">*</font>{/if}
                                    <label>{$usefldlabel}</label>
                                    <input fieldonly='{$fieldonly}' type="text" tabindex="{$vt_tab}" name="{$fldname}" id ="{$fldname}" value="{$fldvalue}" class="ld-input-inner" />
                                </div>
                            </td>
                        {/if}
                    </tr>
                {* 活动状态 文字介绍*}
                {if $maindata[5] == 'social_activitytype'}
                    <tr id="ACTIVITYDESCFORM">
                        <td></td>
                        <td><span class="spdesc">{'ACTIVITYDESCFORM'|@getFixedLabel}</span></td>
                    </tr>
                    <tr id="ACTIVITYDESCH5ANDFORM" style="display: none">
                        <td></td>
                        <td><span class="spdesc">{'ACTIVITYDESCH5ANDFORM'|@getFixedLabel}</span></td>
                    </tr>
                {* h5url*}
                {elseif $maindata[5] == 'h5pageurl'}
                    <tr id="ACTIVITYH5PAGEHELP" style="display: none">
                        <td></td>
                        <td><span style="cursor:pointer;text-decoration: underline" onclick="activityH5PageHelp()" class="spdesc">{'ACTIVITYH5PAGEHELP'|@getFixedLabel}</span></td>
                    </tr>
                {/if}
            {/foreach}
            </table>
            {if $smarty.foreach.blocknames.index+1 ==2 }
                <div class="preview">
                    <div class="phone">
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
                                        <img src="themes/images/left-arrow.png" />
                                    </div>
                                    <div class="middle-title">{'CRMSOCIALPROMOTION'|@getFixedLabel}</div>
                                    <div class="right-3-socialdots">...</div>
                                </div>
                            </div>

                            <div class="phone-content">
                                <div class="phone-content-header" style="background-color: {$formheadcolor}">
                                    <h3 id="show_activitytitle">{$activitytitle}</h3>
                                    <div id="show_activityintroduction" style="margin-top: 5px;">{if $activityintroduction}{$activityintroduction|regex_replace:"/(^|[\n ])([\w]+?:\/\/.*?[^ \"\n\r\t<]*)/":"\\1<a href=\"\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])((www|ftp)\.[\w\-]+\.[\w\-.\~]+(?:\/[^ \"\t\n\r<]*)?)/":"\\1<a href=\"http://\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])([a-z0-9&\-_.]+?)@([\w\-]+\.([\w\-\.]+\.)*[\w]+)/i":"\\1<a href=\"mailto:\\2@\\3\">\\2@\\3</a>"|regex_replace:"/,\"|\.\"|\)\"|\)\.\"|\.\)\"/":"\""|replace:"\n":"<br>"}{else}参与有奖！{/if}</div>
                                </div>
                                <div id="mainFieldsIphone">
                                {*   此处为ajax加载的html 自定义字段*}
                                </div>
                                <div class="phone-content-button">
                                    <button class="submit" style="background-color: {$buttoncolor}" id="show_buttonname" type="button">{if $buttonname}{$buttonname}{else}提交{/if}</button>
                                </div>

                            </div>
                            <div class="phone-footer"></div>
                        </div>

                    </div>
                </div>
                <div style="clear:both;"></div>
            {elseif $smarty.foreach.blocknames.index+1 ==3}
                <div class="preview">
                    <div class="phone">
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
                                        <img src="themes/images/left-arrow.png" />
                                    </div>
                                    <div class="middle-title">{'CRMSOCIALPROMOTION'|@getFixedLabel}</div>
                                    <div class="right-3-dots">...</div>
                                </div>
                            </div>
                            <div class="phone-content">
                                <div class="dialog-time">
                                    <span>12:00</span>
                                </div>
                                <div class="dialog" id="shareActivity">
                                    <img src="themes/images/person.png" />
                                    <div class="dialog-content">
                                        <h4 id="show_sharetitle">{$sharetitle}</h4>
                                        <span id ="show_shareintroduction">{$shareintroduction}</span>
                                        <img id="show_sharepicture" src="themes/images/ldcrm100100.jpg" />
                                    </div>
                                </div>
                                <div class="dialog   dialog-me">
                                    <img src="themes/images/person.png" />
                                    <div class="dialog-content">
                                        这是我们公司的推广页面，快来转发！
                                    </div>
                                </div>
                                <div class="dialog   dialog-others">
                                    <img src="themes/images/person.png" />
                                    <div class="dialog-content">
                                        好的，我转发朋友圈
                                    </div>
                                </div>

                            </div>
                            <div class="phone-footer"></div>
                        </div>

                    </div>
                </div>
                <div style="clear:both;"></div>
            {/if}
        </div>
    {/foreach}
    {else}
    <div class="stepContent" id="step4" >
        <div class="step4Content">
            <div class="success-tip">
                <img src="themes/images/complete.png" />
                <span>{'ACTIVITYCREATEDSUCCESSFULLY'|@getFixedLabel}</span>
            </div>
            <table cellspacing=1 cellpadding=0 style="width: 100%;border-collapse: collapse">
                <thead>
                    <tr>
                        <td colspan="2" class="step4tip">{'ACTIVITYMARKETINGPROMOTIONCODE'|@getFixedLabel}</td>
                    </tr>
                </thead>
                <tbody>
                {foreach key=key item=item from=$shareUserValue}
                    <tr>
                        <td style="width: 30%">{$item['lastname']}</td>
                        <td>
                            <div class="qrcode">
                                <div class="qrcode_img">
                                    <img src="{$item['qrcode']}" />
                                    <span>{'ACTIVITYMOBILEPHONESCANANDSHARE'|@getFixedLabel}</span>
                                </div >
                                <div class="qrcode_a">
                                    <a href="{$item['downQrcode_URL']}" target="_blank"  >{'ACTIVITYDOWNEWM'|@getFixedLabel}</a>
                                    <a href="javascript:void(0)" class="copyUrl" data-clipboard-text="{$item['shareUrl']}">{'ACTIVITYCOPYURL'|@getFixedLabel}</a>
                                </div>
                            </div>
                        </td>
                    </tr>
                {/foreach}
                </tbody>
            </table>
        </div>
    </div>
    {/if}
</div>
<script>
    ld(function () {
        // 复制
        var Clipboard = new ClipboardJS('.copyUrl');
        Clipboard.on('success', function(e) {
            audioRemindsMsg("","","","","",arrJsPopLabel['SUCCESSFULOPERATION']);
        });
    })
</script>