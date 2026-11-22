<script type="text/javascript">
    AjaxJSPage("DetailViewTab_js",'include/js/DetailViewTab.js');
</script>
<script language="JavaScript" async type="text/javascript" src="{$JSURL}include/js/dtlviewajax.js?version={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/OA.js?version={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/ModComments/ModCommentsCommon.js?version={$GLOBALMINVERSION}"></script>
<script type="text/javascript" async src="{$JSURL}include/js/SystemPopup/PrintPopup.js?version={$GLOBALMINVERSION}"></script>
<script language="javascript" type="text/javascript" src="include/js/clipboard.min.js?v={$GLOBALMINVERSION}"></script>
<link rel="stylesheet" type="text/css" media="all" href="{$CSSURL}themes/softed/Paymentplan.css">
{*editor:gyqX161108 gyq_11CH*}

<span id="crmspanid" name="crmspanid" class="ld-detail-edit-small" style="display:none;" onmouseover="New_show('crmspanid');">
    <i class="ld-fonticon ld-fonticon-edit" title="{'EDIT'|@getFixedLabel}"></i>
</span>
<div id="convertleaddiv" style="display:block;position:absolute;left:225px;top:150px;"></div>

<div id="lstRecordLayout" class="LdPop_box LdPopWidth300px" style="display:none;"></div>
<!-- andy 新增单据弹出层 -->
<div id="CreateNewBill" class="D_pop_box LdPopWidth800px" style="display:none;z-Index:9999;position:absolute;">
    <div id="CreateNewBill_form_div" ></div>
</div>
<div id="divAccountShare" class="D_pop_box LdPopWidth500px" style="display:none;width:500px;position:absolute;z-index: 9999;"></div>
<div id="divPotentialsShare" class="D_pop_box LdPopWidth500px" style="display:none;width:500px;position:absolute;z-index: 9999;"></div>
<div id="SetRelatedlists_div" class="D_pop_box LdPopWidth600px" style="display:none; position: absolute; z-Index:9999"></div>
<div id="Quicksetactions_div" class="D_pop_box LdPopWidth600px" style="display:none; position: absolute; z-Index:9999"></div>
{assign var='languagetype' value={''|@getLanguageType}}
<div class="List3Box">
    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
        <tr>
            <input type="hidden" name="rel_list_count" id="rel_list_count" value="{$IS_REL_LIST|@count}">
            <td class="Tdcenter" valign="top">
                <div id="DetailContent" name="DetailContent">
                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <td class="left">
                                <div class="DivC" id="div_pagerecord" name="div_pagerecord">
                                    {if $IS_REL_LIST|@count > 0}
                                        {include file="DetailView/DetailButtons.tpl"}
                                    {/if}
                                    <div class="DivCTable">
{*                                        {include file="DetailView/PopupDetailButton.tpl"}*}
                                        <table border=0 cellspacing=0 cellpadding=0 width="100%">
                                            <tr valign=top>
                                                <td style="padding:0px">
                                                    <!-- Command Buttons -->
                                                    <table border=0 cellspacing=0 cellpadding=0 width=100% class="linefeed">
                                                        <!-- NOTE: We should avoid form-inside-form condition, which could happen when
                                                        Singlepane view is enabled. -->
                                                        <form action="index.php" method="post" name="DetailView" id="form">
                                                            {include file='DetailViewHidden.tpl'}
                                                            <tr>
                                                                <td>
                                                                    <div name="displayfields">
                                                                        {include file='modules/SocialPromotion/SocialMainDetail.tpl'}
                                                                    </div>
                                                                </td>
                                                            </tr>
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
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>

                                    </div>
                                    <!--	detail info exit	-->
                                </div>
                                </form>
                            </td>
                        </tr>
                    </table>
                </div>
            </td>
        </tr>
    </table>
</div>
{if 'yes' eq $DETAILBUTTON.submit.permit}
    <div id="SubmitApprove" class="D_pop_box LdPopWidth400px" style="display:none;"></div>
{/if}
<div id="Createreceivablesforecast" class="D_pop_box LdPopWidth650px" style="display:none;">
    <div id="potentialsid_form_div"></div>
</div>
{if 'yes' eq $DETAILBUTTON.approve.permit}
    <div id="ApproveBlocks" class="D_pop_box LdPopWidth650px" style="display:none;"></div>
    <div id="approvelog" class="D_pop_box LdPopWidth800px" style="display:none;z-index:9999;"></div>
    <div id="approvestepresult" class="D_pop_box LdPopWidth800px" style="display:none;z-index:9999;"></div>
{/if}
<div id="cancelApproved" class="D_pop_box LdPopWidth400px" style="display:none;"></div><!-- 反审批 -->
<div id="dingjieSalesdiv" class="D_pop_box LdPopWidth900px" style="display:none;"></div><!-- 鼎捷订单 -->
<!-- DIV Start -->
<div id="createprojecttaskdiv" class="D_pop_box LdPopWidth800px" style="display:none; z-index:10000;"></div>

</div>

<input  type="hidden" name="balanceaccountinout" value="{$MODBALANCESTR}"/>
<!-- DIV Edit -->

<!--修改负责人-->
<div id="smowneredit" class="D_pop_box LdPopWidth350px" style="display:none;">
    <div id="smowneredit_form_div"></div>
</div>
<!--批量分配-->
<div id="massallocate" class="D_pop_box LdPopWidth350px" style="display:none;">
    <div id="massallocate_form_div"></div>
</div>

<div id="oashowAttendance" class="D_pop_box LdPopWidth350px" style="display:none;z-Index:2147483647;position:absolute;">

    <div id="oashowAttendance_div" >
        <div class="D_pop_tit">
            <strong class="D_ptita">{'VIEWADDJOBBILLHISTORY'|@getFixedLabel}</strong>
            <a class="D_ptitc" href="javascript:fninvshnew('oashowAttendance');">
                <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"></a>
        </div>
        <div style="margin: 12px 0 0 6px;">
            <input  type="checkbox" checked="" onclick="objoa.showAttencePop(this)" id='oachkAttendance'/>
            {'OASTATISTICSAPPROVE'|@getFixedLabel}
        </div>
        <table class="listEntries D_pop_bod" cellspacing="1" cellpadding="1" border="0">
            <tr class="lvtColData">
                <td style="width:60%;">{'OATOTALOVERTIME'|@getFixedLabel}</td>
                <td style="width:40%;" align="center" id='oatotalovertimetd'></td>
            </tr>
            <tr class="lvtColDataBj">
                <td>{'OATOTALDAYSOFF'|@getFixedLabel}</td>
                <td align="center" id='oatotaldaysofftd'></td>
            </tr>
            <tr class="lvtColData">
                <td>{'OAREMAININGOVERTIME'|@getFixedLabel}</td>
                <td align="center" id='oaremainingovertimetd'></td>
            </tr>
            <tr class="lvtColDataBj">
                <td>{'OATOTALANNUALLEAVE'|@getFixedLabel}</td>
                <td align="center" id="oatotalannualleavetd"></td>
            </tr>
            <tr class="lvtColData">
                <td>{'OAUSEDANNUALLEAVE'|@getFixedLabel}</td>
                <td align="center" id="oausedannualleavetd"></td>
            </tr>
            <tr class="lvtColDataBj">
                <td>{'OAREMAININGANNUALLEAVE'|@getFixedLabel}</td>
                <td align="center" id='oaremainingannualleavetd'></td>
            </tr>
        </table>
        <div style="margin: 10px 0 9px 10px;">
            <a id='oaviewdetailattendance' target="_blank" href="CustomReport/index.php?stimulsoft_client_key=ViewerFx&stimulsoft_report_key=oa_attendance_statistics.mrt&default_report=1">{'VIEWATTENDANCEDETAILINFO'|@getFixedlabel}</a>
        </div>
    </div>

</div>
<div id="divSendInform" class="D_pop_box LdPopWidth600px" style="display:none;">
    <div id="divSendInform_div" ></div>
</div>

<div id="divSendInform_content" class="D_pop_box LdPopWidth900px" style="display:none;z-index:100000;">
    <div id="divSendInform_content_div"></div>
</div>
<div id="camaigns_account_status" class="D_pop_box LdPopWidth450px" style="display:none;z-index:100000;">
</div>
<!--中间 end-->
<div id="ShowSetUeryScopdiv" class="D_pop_box" style="display:none;position:absolute;left:33%;top:35%;width:1200px" ></div>
<div id="tempdiv" style="display:block;top:200px;"></div>
<div id="changepw" class="D_pop_box LdPopWidth350px" style="display:none;position:absolute;left:350px;top:200px;z-index:1102;"></div>
{if $MODULE eq 'HelpDesk' && $SENDTYPE eq 'yes' && ($IS_SEND eq 1 || $IS_SEND eq 2)}
    <script type="text/javascript">
        CreateSendForm('{$MODULE}',{$ID});
    </script>
{/if}

<script>
    var version_account = '{$VERSION_ACCOUNT}';

    var relcount = "{$smarty.foreach.relatedfor.iteration}";
    //if(relcount > 0)
    //	set_rel_count();
    //set_rel_createbtn();//获取相关信息数量
    //

    var accountset = '{$ACCOUNTSET}';//公海操作日志
    var utrc_type = '{$UTRC_TYPE}';
    var select_servicedetail = '{$SELECTSERVICEDETAIL}';//客户和服务单是否显示服务信息 1显示 0不显示
    fromcalendar='{$FROMCALENDAR}';
    var helpdesk_log = '{$HELPDESKLOG}';
    //reason:服务小程序增加评价  2019/6/18 13:52 ID1000512
    var communicate = '{$COMMUNICATE}';
    var evaluate = '{$EVALUATE}';
    //var isapprovemod = '{$APPROVEMOD}';//是否开启审批

</script>
<!-- added for validation -->

</td>
</tr>
</table>
<script>

    var ViewallCooperativeWork='no';
    var gVTModule = '{$smarty.request.module|@vtlib_purify}';

    {literal}
    //编辑价格表中选择的产品价格弹出层
    function editProductListPrice(id,pbid,price)
    {
        ldAjax("index.php?action=ProductsAjax&file=EditListPrice&module=Products&return_module=PriceBooks&listprice="+price,{},function(data){

            var popupobj=  CrmPopup.load(data.result.title,gotoUpdateListPrice,"","400","Products","",data.result.oktext,"",data.result.canceltext);
            popupobj.id=id;
            popupobj.pbid=pbid;
            popupobj.price=price;
            popupobj.show(data.result.content);

            DelProgressObjs();

        })

    }
    //产品价格弹出层保存
    function gotoUpdateListPrice()
    {
        var popupobj=CrmPopup.getPopupObj('last');
        var lastprevpopupobj=CrmPopup.getPopupObj('lastprev');
        var id=popupobj.id;//选择产品id
        var proid=popupobj.id;//选择产品id
        var pbid=popupobj.pbid;//价格表ID
        // $("status").style.display="inline";
//        $("roleLay").style.display = "none";
        puyoungJS_DialogBox.unblock();
        var listprice=$("list_price").value;
        new Ajax.Request(
            'index.php',
            {queue: {position: 'end', scope: 'command'},
                method: 'post',
                postBody: 'module=Products&action=ProductsAjax&file=UpdateListPrice&ajax=true&return_action=CallRelatedList&return_module=PriceBooks&record='+id+'&pricebook_id='+pbid+'&product_id='+proid+'&list_price='+listprice,
                onComplete: function(response) {
                    $("status").style.display="none";
                    popupobj.CancelEvent();
                    DetailViewRelation.searchByPopupobj(lastprevpopupobj);
                }
            }
        );

    }
    gotoUpdateListPrice.funname='gotoUpdateListPrice';
    {/literal}
</script>