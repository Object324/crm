<script type='text/javascript'>
    {literal}
  //  setProductDivWidth.pageMode = 'DetailView';

    function isRelatedListBlockLoadeds(id, urldata) {
        var elem = document.getElementById(id);
        if (elem == null || typeof elem == 'undefined' || urldata.indexOf('order_by') != -1 ||
            urldata.indexOf('start') != -1 || urldata.indexOf('withCount') != -1) {
            return false;
        }
        var tables = elem.getElementsByTagName('table');
        return tables.length > 0;
    }

    function loadRelatedListBlocks(urldata, target, imagesuffix) {

        var showdata = 'show_' + imagesuffix;
        var showdata_element = $(showdata);

        var hidedata = 'hide_' + imagesuffix;
        var hidedata_element = $(hidedata);
        if (isRelatedListBlockLoadeds(target, urldata) == true) {
            $(target).show();
            showdata_element.hide();
            hidedata_element.show();
            $('delete_' + imagesuffix).show();
            return;
        }
        var indicator = 'indicator_' + imagesuffix;
        var indicator_element = $(indicator);
        indicator_element.show();
        $('delete_' + imagesuffix).show();

        var target_element = $(target);
        new Ajax.Request(
            'index.php',
            {
                queue: {position: 'end', scope: 'command'},
                method: 'post',
                postBody: urldata,
                onComplete: function (response) {
                    var responseData = trim(response.responseText);
                    target_element.update(responseData);
                    target_element.show();
                    showdata_element.hide();
                    hidedata_element.show();
                    indicator_element.hide();
                    if ($('return_module').value == 'Campaigns') {
                        var obj = document.getElementsByName(imagesuffix + '_selected_id');
                        var relatedModule = imagesuffix.replace('Campaigns_', "");
                        $(relatedModule + '_count').innerHTML = numofRows;
                        if (selectallActivation == 'true') {
                            $(imagesuffix + '_selectallActivate').value = 'true';
                            $(imagesuffix + '_linkForSelectAll').show();
                            $(imagesuffix + '_selectAllRec').style.display = 'none';
                            $(imagesuffix + '_deSelectAllRec').style.display = 'inline';
                            var exculdedArray = excludedRecords.split(';');
                            if (obj) {
                                var viewForSelectLink = showSelectAllLink(obj, exculdedArray);
                                $(imagesuffix + '_selectCurrentPageRec').checked = viewForSelectLink;
                                $(imagesuffix + '_excludedRecords').value = $(imagesuffix + '_excludedRecords').value + excludedRecords;
                            }
                        } else {
                            $(imagesuffix + '_linkForSelectAll').hide();
                            rel_toggleSelect(false, imagesuffix + '_selected_id', relatedModule);
                        }
                        updateParentCheckbox(obj, imagesuffix);
                    }
                }
            }
        );
    }

    function hideRelatedListBlocks(target, imagesuffix) {

        var showdata = 'show_' + imagesuffix;
        var showdata_element = $(showdata);

        var hidedata = 'hide_' + imagesuffix;
        var hidedata_element = $(hidedata);

        var target_element = $(target);
        if (target_element) {
            target_element.hide();
        }
        hidedata_element.hide();
        showdata_element.show();
        $('delete_' + imagesuffix).hide();
    }

    function disableRelatedListBlocks(urldata, target, imagesuffix) {
        var showdata = 'show_' + imagesuffix;
        var showdata_element = $(showdata);

        var hidedata = 'hide_' + imagesuffix;
        var hidedata_element = $(hidedata);

        var indicator = 'indicator_' + imagesuffix;
        var indicator_element = $(indicator);
        indicator_element.show();

        var target_element = $(target);
        new Ajax.Request(
            'index.php',
            {
                queue: {position: 'end', scope: 'command'},
                method: 'post',
                postBody: urldata,
                onComplete: function (response) {
                    var responseData = trim(response.responseText);
                    target_element.hide();
                    $('delete_' + imagesuffix).hide();
                    hidedata_element.hide();
                    showdata_element.show();
                    indicator_element.hide();
                }
            }
        );
    }

    {/literal}
</script>
<table class="bgwhite" border=0 cellspacing=0 cellpadding=0 width="100%">
    <tr valign="top">
        <td style="padding:0px">
            <!-- Command Buttons -->
            <table border=0 cellspacing=0 cellpadding=0 width=100% class="linefeed">
                <!-- NOTE: We should avoid form-inside-form condition, which could happen when
                Singlepane view is enabled. -->
                <form action="index.php" method="post" name="DetailView" id="form">
                    {include file='DetailViewHidden.tpl'}
                    {*录音文件信息*}
                    {if ($MODULE eq 'Accounts' || $MODULE eq 'Contacts' || $MODULE eq 'HelpDesk' || $MODULE eq 'ContactRecords'
                    || $MODULE eq 'Vendors' || $MODULE eq 'VendorContact' || $MODULE eq 'VendorContactRecords') && $CALLDISPLAY eq 'yes'}
                        {include file="DetailView/CallButlerDetail.tpl"}
                    {/if}
                    {* 客户和联系人关联字段信息*}
                    {if $BESTATUS eq 'yes' && $DISPLAY_POSITION eq 0}
                        <tr>
                            <td id="showAccountsContactsInfoTr" name="showAccountsContactsInfoTr"  style="width:100%;">
                                <div id="showAccountsContactsInfo" name="showAccountsContactsInfo"></div>
                            </td>
                        </tr>
                    {/if}
                    <tr>
                        <td>
                            <div name="displayfields">
                                {if $MODULE =='SocialPromotion'}
                                    {include file='modules/SocialPromotion/SocialMainDetail.tpl'}
                                {else}
                                    {include file='DetailView/MainDetailFields.tpl'}
                                    {if $MODULE =='Questionnaire'} {*问卷调查 - 详情页 - 问卷分享区块*}
                                        {include file='modules/Questionnaire/DetailShareBlock.tpl'}
                                    {/if}
                                {/if}

                            </div>
                        </td>
                    </tr>

                    {* 客户和联系人关联字段信息*}
                    {if $BESTATUS eq 'yes' && $DISPLAY_POSITION eq 1}
                        <tr>
                            <td id="showAccountsContactsInfoTr" name="showAccountsContactsInfoTr" style="width:100%;">
                                <div id="showAccountsContactsInfo" name="showAccountsContactsInfo"></div>
                            </td>
                        </tr>
                    {/if}
                    {*服务合同信息*}
                    {if $MODULE|@get_file_address:'ShowServiceContractsDetail' eq true}
                        <tr>
                            <td style="width:100%;">
                                <div name="showServiceContactsInfo" style="display:none;"></div>
                            </td>
                        </tr>
                    {/if}
                    {if $NUMROWS>0 && $MODULE == 'Potentials'}
                        <tr>
                            <td style="padding:0px;">
                                <table border=0 cellspacing=0 cellpadding=0 width=100%>
                                    <tr>
                                        <td>
                                            {assign var='arrawcls' value='On'}
                                            <div class="DivCName DivCNamehover"
                                                 onclick="showHideStatus('potentialsStatus','approvecol_his');">
                                                <span class="{$arrawcls}" id="approvecol_his" name="approvecol_his"></span>{'Potentials'|@getTranstab}{'PHASEADVANCEHISTORY'|@getFixedLabel}
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td id="potentialsStatus" name="potentialsStatus" style='display:none;'>
                                            <div class="ld-shadow-first" style="overflow: auto; max-height: 100px; width: 100%;display:block;">
                                                <table border="0" cellspacing="1" cellpadding="0" width="100%" class="DetailContentTable">
                                                    {foreach key=id item=label from=$POTENIALSARR}
                                                        <tr>
                                                            <td style="padding: 0 8px;">
                                                                {'DATE'|@getFixedLabel}：{$label.lastmodified}&nbsp;&nbsp;
                                                                {'THESALESSTAGE'|@getFixedLabel}：{$label.sales_stage}&nbsp;&nbsp;
                                                                {'OPERATOR'|@getFixedLabel}：{$label.smownerid}
                                                            </td>
                                                        </tr>
                                                    {/foreach}
                                                </table>
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    {/if}
                    <!-- 评论 tujt 2014-08-05 -->
                    <!--tr><td style="width:100%;">
                        <div id="modcommentdiv"></div>
                    </td></tr-->
                    {* END *}
                    <!-- Inventory - Product Details informations -->
                    {if $UsedAmountDetail neq ''}
                        <tr>
                            <td style="width:100%;height:10mm">
                                {$UsedAmountDetail}
                            </td>
                        </tr>
                    {/if}
                    {if $ASSOCIATED_PRODUCTS neq ''}
                        <tr>
                            {$ASSOCIATED_PRODUCTS}
                        </tr>
                    {/if}
                    {if $MODULE eq 'Calendar'}
                        {include file= 'ActivityDetailView.tpl'}
                    {/if}
                    <!-- </form> -->

                    {if $MODULE eq "Commission"}
                        <tr>
                            <td style="padding:0px;width:100%;">
                            {include file="modules/Commission/CommissionDetail.tpl"}
                            </td>
                        </tr>
                    {else if get_file_address($MODULE,$MODULE|cat:'DetailFieldsHtml')}
                        <tr>
                            <td style="padding:0px;width:100%;">
                                {include file="modules/TabDetail/PopupEditList.tpl"}
                            </td>
                        </tr>

                    {/if}
					{if $VERSION_ACCOUNT eq 'baxter' && $MODULE eq 'CustomForm25'}
                        <tr>
                            <td style="padding:0px;width:100%;">
                                {include file="newpatient/BaxterFileList.tpl"}
                            </td>
                        </tr>
                    {/if}
                    <!-- 评论 tujt 2014-08-05 -->
                    {if $MODULE eq 'HelpDesk' && $HELPDESKLOG eq 1}
                        <!--客户单历史记录-->
                        <tr name='HelpDeskHistorytr' style='display:block;background:var(--ld-bg-list-head-color);'>
                            <td style="padding:0px;">
                                <div class="DivCName DivCNamehover"
                                     onclick="showHideStatus('HelpDeskHistory','HelpDeskHistorycol');">
                                    <span id="HelpDeskHistorycol"></span>{'SERVICE_HISTORY'|@getFixedLabel}
                                </div>
                            <td>
                        </tr>
                        <tr>
                            <td name="HelpDeskHistory" style='display:block;width:100%'></td>
                        </tr>
                    {/if}

                    {* editor:gyq_123 reason:显示服务小程序录入的沟通信息  2019/6/18 14:14 ID1000512 *}
                    {if ($COMMUNICATE eq 1)}
                        <tr name='communicate_tr' >
                            <td style="padding:0px;">
                                <div class="DivCName DivCNamehover"
                                     onclick="showHideStatus('communicate_div','communicate_tr_col');">
                                    <span name="communicate_tr_col" id="communicate_tr_col"></span>{'HELPDESKCOMMUNICATE'|@getFixedLabel}
                                </div>
                                <div name="communicate_div" id="communicate_div">

                                </div>
                            </td>
                        </tr>
                    {/if}
                    {*editor:gyq_127 reason:服务小程序增加评价  2019/6/26 11:49 ID1000419*}
                    {if ($MODULE eq "HelpDesk" && $EVALUATE eq 1)}
                        <tr name='evaluate_tr' >
                            <td style="padding:0px;">
                                <div class="DivCName DivCNamehover"
                                     onclick="showHideStatus('evaluate_div','evaluate_tr_col');">
                                    <span name="evaluate_tr_col" id="evaluate_tr_col"></span>{'EVALUATESETTING02'|@getFixedLabel}
                                </div>
                                <div name="evaluate_div" id="evaluate_div">

                                </div>
                            </td>
                        </tr>
                    {/if}
                    {if $MODCOMMENTDISPLAYRIGHT neq 'yes' && $MODULE neq 'Reminds' && 'ModComments'|@isPermitted:'index' eq 'yes'}
                        <tr>
                            <td style="width:100%;height:10mm">
                                <div style="width: auto;" id="modcommentdiv" name="modcommentdiv">
                                    {if $COMMENTMODE neq 'concise'}
                                        {include file="modules/ModComments/widgets/DetailViewBlockCommentNew.tpl"}
                                    {else}
                                        {include file="modules/ModComments/widgets/DetailViewBlockCommentOld.tpl"}
                                    {/if}
                                </div>
                            </td>
                        </tr>
                    {/if}
                    <tr id='approvelogtr' name="approvelogtr" style='display:none;'>
                        <td style="padding:0px;">
                            {if $BLOCKINITIALSTATUS[$header] neq 1}
                                {assign var='arrawcls' value=''}
                            {else}
                                {assign var='arrawcls' value='On'}
                            {/if}
                            <div class="DivCName DivCNamehover" onclick="showHideStatus('approveStaus','approvecol');">
                                <span class="{$arrawcls}" id="approvecol" name="approvecol"></span>{'approvelog'|@getFixedLabel}
                            </div>
                            <div id="approveStaus" name="approveStaus" style='display:block;'>
                                {*include file= 'Approve/ApproveLogEntries.tpl'*}
                            </div>
                        </td>
                    </tr>
            </table>
        </td>
        {if $labelinfo.tagdisplayright eq 'yes' || $MODCOMMENTDISPLAYRIGHT eq 'yes'}
            <td id="modcommentblock_paddingtd" class="modcommentblock_paddingtd ld-bg-color" style="width: 10px;min-width: 10px"></td>
            <td id="modcommentblock_parenttd" style="vertical-align: top;width: 60px;">
                <div id="modcommentblock_icon">
                    <div data-status="no" id="modcommentblock_Expanddiv" data-frommodule="{$MODULE}" data-record="{$UIKEY}" class="DivCName DivCNamehover modcommenttag-changeicon-div">
                        <i class="ld-fonticon ld-fonticon-toleft" tag="modcommentblock_icon" name="change_icon" data-tip="{'EXPANSION'|@getFixedLabel}" data-direction="top" data-type="position"></i>
                    </div>
                    <div id="modcommenttag_icon">
                        {if $labelinfo.tagdisplayright eq 'yes'}
                            <div class="modcommenttag-icon-div" id="modcommenttag_tag_icon">
                                <i class="ld-fonticon ld-fonticon-tag" id="modcommenttag_tag_icon"></i>
                                <div class="modcommenttag-icon-text">{'Tag'|@getFixedLabel}</div>
                            </div>
                        {/if}
                        {if $MODCOMMENTDISPLAYRIGHT eq 'yes'}
                            <div class="modcommenttag-icon-div" id="modcommenttag_modcomment_icon">
                                <i class="ld-fonticon ld-fonticon-comment"></i>
                                <div class="modcommenttag-icon-text">{'COMMENT1'|@getFixedLabel}</div>
                            </div>
                        {/if}
                    </div>
                </div>
                <div style="max-width:400px;background-color: #fff;padding-bottom: 8px;display: none" id="modcommentdiv" name="modcommentdiv" >
                    {if $labelinfo.tagdisplayright eq 'yes'}
                        {include file="DetailView/DetailViewBlockTag.tpl"}
                    {/if}
                    {*wym 240123 BUG20240123-40 公告-页面设置-开启标签，不生效，单据详情还是不显示标签*}
                    {*以前的代码不知道为什么要控制公告模块不显示右侧小按钮，目前改bug先把标签栏放出来，评论栏等待测试部讨论*}
                    {if $MODCOMMENTDISPLAYRIGHT eq 'yes' }
                        {include file="modules/ModComments/widgets/DetailViewBlockCommentNew.tpl"}
                    {/if}
                </div>
            </td>


        {/if}

    </tr>
</table>