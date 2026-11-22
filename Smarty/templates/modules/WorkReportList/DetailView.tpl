<div class="wrapper-panel-inner"> <link type="text/css" href="themes/softed/coordination.css" rel="stylesheet">
    <script type="text/javascript">
        var current_language = "zh";
        AjaxJSPage("Coordination_js",'include/js/modules/Home/Coordination.js');
    </script>
</div>
{*//ls 20221012 XUQIU1000284  增加“工作汇报（列表）”模块*}
<input type="hidden" name='record' value="{$RECORD}">
<div id="worklist_page_1">
    <div class="mainuser">
        <div class="userInfo">

            <div class="pubclear plan-leader">
                {$StayCommentInfo}
            </div>
            <div class="content">
                {foreach  item=columninfo from=$ShowSpecialColumnInfo}
                    <p class="content-title writesummary">{$columninfo.fieldlabel}</p>
                    <div class="content-text writeexperience"
                         style="-webkit-user-select: text !important;-moz-user-select: text !important;-ms-user-select: text !important;">
                        {$columninfo.value}
                    </div>
                {/foreach}

                {if $detailData['readername'] neq ''}
                    <p class="relation-title" style="padding-top:0px;">点评人</p>
                    <div class="ui-acct-list relation-list">
                        {$detailData['readername']}
                    </div>
                    <br/>
                {/if}


                 <!-- 中间自定义字段显示的的地方 -->
                {*<p class="ui-hide relation-title" style="padding-top:0px;">签到</p>
                <div class="ui-acct-list relation-list ui-hide"></div>*}
                {if $AccountList neq ''}
                    <p class="relation-title" style="padding-top:0px;">{'Accounts'|@getTranstab}</p>
                    <div class="ui-acct-list relation-list">
                        {$AccountList}
                    </div>
                    <br/>
                {/if}

                {if $ContactList neq ''}
                    <p class="relation-title">{'Contacts'|@getTranstab}</p>
                    <div class="ui-cont-list relation-list">
                        {$ContactList}
                    </div>
                    <br/>
                {/if}

                {if $ProductList neq ''}
                    <p class="relation-title">{'Products'|@getTranstab}</p>
                    <div class="ui-cont-list relation-list">
                        {$ProductList}
                    </div>
                    <br/>
                {/if}

                <br/>
                {if $detailData['text'] neq ''}
                    <p class="relation-title" style="padding-top:0px;">以下为点评人的点评：</p>
                    <div class="ui-acct-list relation-list">
                        {$detailData['readername']} <font class="Anu3_a redFont">点评</font> ({$detailData['commenttime']})
                        <p class="relation-title" style="padding-top:0px;">{$detailData['text']}</p>
                    </div>
                {/if}
            </div>

        </div>
    </div>
</div>
