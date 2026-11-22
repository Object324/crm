{*@edit:liushuai,2021-04-28,reason:【ID1001572】增加【调查问卷】模块-第一版*}
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/modules/Questionnaire/Questionnaire.js"></script>
<link rel="stylesheet" type="text/css" href="themes/softed/base.css">
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
                                                <div name='displayfields' id="">
                                                    {include file='modules/Questionnaire/QuestionnaireEditBlockFields.tpl'}
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
<div id="recipient_namediv" class="D_pop_box LdPopWidth600px" style="display:none; position: absolute; z-Index:9999"></div>
<div id="actiondiv" class="D_pop_box LdPopWidth900px" style="display:none; z-index:3;"></div>
<!--相关信息设置div-->
<div id="SetRelatedlists_div" class="D_pop_box LdPopWidth600px" style="display:none; position: absolute; z-Index:9999"></div>
<input name='search_url' id="search_url" type='hidden' value='{$SEARCH}'/>
</form>
<script type="text/javascript">
    var topics = '{$TOPICS}';/*题目的集合*/
    var question_status = '{$status}';/*问卷状态*/
    var quretion_Duplicate = '{$DUPLICATE}';
	var cls_questionnaire = new Questionnaire(topics,question_status,quretion_Duplicate);
	// cls_questionnaire.BindQuestionTopic();
cls_questionnaire
    ld(function () {
        // 复制
        var Clipboard = new ClipboardJS('.copyUrl');
        Clipboard.on('success', function(e) {
            MessagePopup.TipZero_success(arrJsPopLabel['SUCCESSFULOPERATION']);
        });
    })

</script>

