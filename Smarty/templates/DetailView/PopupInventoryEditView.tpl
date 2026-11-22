{*<!-- module header -->*}
<!--修改编码格式:统一编码：UTF-8-->
{assign value='EditView' var='formname'}
{assign var='languagetype' value={''|@getLanguageType}}
<div class="edit-left" >
</div>
<div class="edit-right">
    <div class="List3Box">
        <table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
            <tr>
                <td class="Tdcenter" valign="top">
                    <input type="hidden" name="productdeploy" id="productdeploy" value="{$PERODUCTDEPLOY}" />
                    <input type="hidden" name="SearchScope" id="SearchScopeDetail" value="{$SEARCHSCOPE}"/>
                    <input type="hidden" name="version_account" value="{$VERSION_ACCOUNT}" />
                    <div id="DetailContent" class="ld-createedit-content">
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td class="left">
                                    <div class="DivC" id="div_pagerecord">
                                        <div class="Top">
                                            {include file='EditViewHidden.tpl'}
                                            <input type="hidden" name="duplicateid" value="0"/>
                                            {if $MODULE == 'Stock' || $MODULE == 'OutboundOrder'}
                                                <input type="hidden" value="{$DEPLOYVALUE}" id="delpoyvalue" name="delpoyvalue" />
                                            {/if}
                                            <table border="0" cellspacing="0" cellpadding="0" width="100%" class="" id="blockTable">
                                                {include file='DetailView/EditViewForeach.tpl'}
                                                    <tr>
                                                        <td colspan="4" align="left" name="productdetailtabletd" class="ld-createedit-content-entry entryContentPad">
                                                            {* 出入库单 *}
                                                            {$ASSOCIATEDPRODUCTS}
                                                        </td>
                                                    </tr>
                                                {if $MODULE eq 'WorkSheet'}
                                                    <tr>
                                                        <td colspan="4" align="left" name="partdetailtabletd" class="ld-createedit-content-entry entryContentPad">
                                                            {* 工单管理特殊分录*}
                                                            {$ASSOCIATEDPART}
                                                        </td>
                                                    </tr>
                                                {/if}
                                                <tr colspan="4" style="display: none;"><td></td></tr>
                                            </table>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </div>
                    </form>
                </td>
            </tr>
        </table>
        <input name='search_url' id="search_url" type='hidden' value='{$SEARCH}'>
    </form>
    </div>

    <!-- This div is added to get the left and top values to show the tax details-->
    <div id="tax_container" style="display:none; position:absolute; z-index:1px;"></div>
    <!--同步库存，加载框-->
    <div id="divId" class="veil_newnobg" style="position:absolute;width:100%;display:none;top:0px;left:0px;z-index:9999;">
        <table border="0" cellpadding="0" cellspacing="0" align="center" style="vertical-align:middle;width:100%;height:100%;">
            <tbody><tr>
                    <td class="big" align="center">
                        <img src="themes/images/plsWaitAnimated.gif"/>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
    <!--相关信息设置div-->
    <div id="SetRelatedlists_div" class="D_pop_box LdPopWidth600px" style="display:none; position: absolute; z-Index:9999">
    </div>


    <table id="popup_submit_head" border="0" cellspacing="0" cellpadding="0" width="100%" style="{if empty($APPROVE_ARR) || ($APPROVE_ARR|@is_array && $APPROVE_ARR|@sizeof eq 0)}display: none;{/if}" class="DetailContentTable linefeed">
        <tbody><tr>
            <td colspan="4" class="ld-from-headblock">
                <div class="ld-from-headblock-title" tag="headblock-title">{"SELECTAPPROVALPROC"|@getFixedLabel}</div>
            </td>
        </tr></tbody>
    </table>
    <div id="popup_submit_content" style="{if empty($APPROVE_ARR) || ($APPROVE_ARR|@is_array && $APPROVE_ARR|@sizeof eq 0)}display: none;{/if}" class="ld-public-content-big dd">
        {include file="Approve/SubmitApproveNew.tpl"}
    </div>

</div>
