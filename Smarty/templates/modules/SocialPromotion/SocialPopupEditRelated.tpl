<div class="List3Box">
    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
        <tr>
            <td class="TdLeft" style="display:none;" valign="top"></td>
            <td class="Tdcenter" valign="top">
                <input type="hidden" name="SearchScope" id="SearchScopeDetail" value="{$SEARCHSCOPE}"/>
                <div id="DetailContent">
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" aling="left">
                        <tr>
                            <td class="left">
                                <div class="DivC" id="div_pagerecord">
                                    {include file='EditViewHidden.tpl'}
                                    <table class="" border=0 cellspacing="0" cellpadding=0 width=100%>
                                        <tr>
                                            <td colspan="4">
                                                <div name='displayfields'>
                                                    {include file='modules/SocialPromotion/SocialEditBlockFields.tpl'}
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </td>
                        </tr>
                    </table>
                </div>

            </td>
        </tr>
    </table>

</div>
<!--公告选择用户,提醒选择接收人div-->
<div id="recipient_namediv" class="D_pop_box LdPopWidth600px"
     style="display:none; position: absolute; z-Index:9999"></div>
<div id="actiondiv" class="D_pop_box LdPopWidth900px" style="display:none; z-index:3;"></div>
<!--相关信息设置div-->
<div id="SetRelatedlists_div" class="D_pop_box LdPopWidth600px"
     style="display:none; position: absolute; z-Index:9999"></div>
<input name='search_url' id="search_url" type='hidden' value='{$SEARCH}'/>
</form>


