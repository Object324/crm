{*<link rel="stylesheet" href="{$CSSURL}include/js/modules/WechatSession/WechatSession.css" />*}
{*<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/general.js"></script>

<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/WechatSession/ChatMemberList.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/WechatSession/ChatSessionList.js"></script>*}
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/WechatSession/ChatDataList.js"></script>
{*<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/WechatSession/WechatSession.js"></script>*}

<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/WechatSession/CustomerChatMemberList.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/WechatSession/CustomerChatSessionList.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/WechatSession/CustomerChatDataList.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/WechatSession/CustomerWechatSession.js"></script>

<script type="text/javascript" src="include/js/BenzAMRRecorder.min.js"></script>
{*<script type="text/javascript" src="include/js/amrnb.js"></script>*}
{*<script type="text/javascript" src="include/js/amrplayer.js"></script>*}

{*js加载写到leftmenu.tpl*}
{*{if $useWxOpendata eq 'yes'}
    <script src="https://res.wx.qq.com/open/js/jweixin-1.2.0.js"></script>
    <script src="https://open.work.weixin.qq.com/wwopen/js/jwxwork-1.0.0.js"></script>
    <script type="text/javascript" language="javascript" src="{$JSURL}include/js/cls_wxOpenData.js?v={$GLOBALMINVERSION}"></script>
{/if}*}
<script type="text/javascript" language="JavaScript">
    var useWxOpendata = '{$useWxOpendata}';
    if (useWxOpendata == 'yes') {
        var wx_timestamp='{$timestamp}';
        var wx_corpid='{$wx_corpid}';
        var wx_agentid='{$wx_agentid}';
        var wx_nonceStr='{$nonceStr}';
        var wx_agent_signature='{$agentsignature}';
        var wx_signature='{$signature}';

        var wechat_wxOpenDataobj=new cls_wxOpenData();
        wechat_wxOpenDataobj.init();
        //wechat_wxOpenDataobj.bindAllOpenDataByPopupObj();
    }

</script>

<div id="wechatsession" class="wechatsession-wrapper">
    <div class="ld-ui-tabs">
        <ul class="ld-ui-tabs-nav">
            <input type="hidden" name="searchbytype" value="{if $searchbytype eq 'searchbycustomer'}searchbycustomer{else}searchbymember{/if}">
            <li tag="1" class="ld-ui-tabs-active" onclick="WechatSessionobj.showSearchType(this,'member')"><a href="javascript:;">{'RetrieveByMember'|@getFixedLabel}</a></li>
            <li tag="2" onclick="WechatSessionobj.showSearchType(this,'customer');"><a href="javascript:;">{'RetrieveByAccount'|@getFixedLabel}</a></li>
        </ul>
    </div>
    {if $searchbytype eq 'searchbymember'}
        <div id="searchbymember" class="talk-wrapper linefeed">
            <div class="talk-wrapper-left gwidth20">
                <div class="talk-wrapper-title">{'MemberList'|@getFixedLabel}
                    {if $IS_ADMIN && $useWxOpendata eq 'yes'}
                        <span onclick="WechatSessionobj.ChatMemberListobj.clearApiCache(this);"><a class="rfloat fontnormal">{'UPDATE'|@getFixedLabel}{'MemberList'|@getFixedLabel}</a></span>
                    {/if}
                </div>
                <div class="talk-wrapper-content">
                    <div class="talk-wrapper-search-con">
                        <div class="positionFirst top5" title="{'SEARCH'|@getFixedLabel}" onclick="WechatSessionobj.ChatMemberListobj.search();">
                            <i class="ld-fonticon ld-fonticon-search hlineheight30"></i>
                        </div>
                        <input class="talk-wrapper-search gwidth100" type="text" name="searchmember" value=""
                               placeholder="{'SearchMembers'|@getFixedLabel}">
                    </div>
                    {*点击时保存起来*}
                    <input type="hidden" name="member_wx_userid" value="">
                    <div id="memberlist">
                        {include file='modules/WechatSession/MemberList.tpl'}
                    </div>
                </div>
            </div>
            <div class="talk-wrapper-center gwidth20">
                <div class="talk-wrapper-title">{'SessionList'|@getFixedLabel}<a class="rfloat fontnormal" onclick="WechatSessionobj.ChatSessionListobj.syncContactNameAndGroupName(this);">{'SYNCHRONIZE'|@getFixedLabel}</a></div>
                <div class="talk-wrapper-content">
                    <div class="talk-wrapper-search-con">
                        <div class="positionFirst top5" title="{'SEARCH'|@getFixedLabel}" onclick="WechatSessionobj.ChatSessionListobj.search();">
                            <i class="ld-fonticon ld-fonticon-search hlineheight30"></i>
                        </div>
                        <input class="talk-wrapper-search gwidth100" type="text" name="searchsession" value=""
                               placeholder="{'SearchSessions'|@getFixedLabel}">
                    </div>
                    {*@edit:liushuai,2021-07-21,reason: 45994: 会话存档->会话列表，选择人员之后，会话列表默认选择“外部”*}
                    <input name="session_type" type="hidden" value="external"/>
                    <div class="talk-tabs">
                        <ul class="talk-tabs-nav" name="session_type_event">
                            <li value="internal" class="talktabsselected">{'INTERNAL'|@getFixedLabel}</li>
                            <li value="external">{'EXTERNAL'|@getFixedLabel}</li>
                            <li value="groupchat">{'Groupchat'|@getFixedLabel}</li>
                        </ul>
                    </div>
                    <input type="hidden" name="session_wx_userid" value="">
                    <input type="hidden" name="session_roomid" value="">
                    <div id="sessionlist">
                        {include file='modules/WechatSession/SessionList.tpl'}
                    </div>
                </div>
            </div>
            <div class="talk-wrapper-right gwidth60">
                <div class="talk-wrapper-title talk-wrapper-righttitle" style="display: flex;">
                    <div class="overflow-space" style="flex: 1;"><span name="chatdata_personnel"></span></div>
                    <div class="talk-wrapper-search-con ld-form-item-content" style="flex: 1;display: flex;align-items: center;">
                        <input name="begin_date" class="Wdate ld-input-inner" type="text" style="width: 120px;margin: 0;margin-left: auto;" size="11" maxlength="10" value="" placeholder="{'Start_Date'|@getFixedLabel}" onclick="WdatePicker({ldelim}onpicked:function(){ldelim}WechatSessionobj.ChatDataListobj.search(){rdelim}{rdelim})">
                        <span style="color: var(--ld-font-placeholder-color);">~</span>
                        <input name="end_date" class="Wdate ld-input-inner" type="text" style="width: 120px;margin: 0;" size="11" maxlength="10" value="" placeholder="{'End_Date'|@getFixedLabel}" onclick="WdatePicker({ldelim}onpicked:function(){ldelim}WechatSessionobj.ChatDataListobj.search(){rdelim}{rdelim})">
                    </div>
                    <div class="talk-wrapper-search-con" style="flex: 1;">
                        <div class="positionFirst" title="{'SEARCH'|@getFixedLabel}" onclick="WechatSessionobj.ChatDataListobj.search('count');">
                            <i class="ld-fonticon ld-fonticon-search hlineheight30"></i>
                        </div>
                        <input class="talk-wrapper-search rfloat gwidth100" type="text" name="searchcontent" value="" placeholder="{'SearchSessionContent'|@getFixedLabel}">
                    </div>
                </div>
                <div class="talk-wrapper-content talk-wrapper-content-right">
                    <input name="page" type="hidden" value="{$page}"/>
                    <input name="page_num" type="hidden" value="{$page_num}"/>
                    
                    <input name="msgtype" type="hidden" value="all"/>
                    <div class="talk-tabs">
                        <ul class="talk-tabs-nav talk-tabs-nav-three" name="msgtype_event">
                            <li value="all" class="talktabsselected">{'ALL'|@getFixedLabel}</li>
                            <li value="file">{'FILE'|@getFixedLabel}</li>
                            <li value="image">{'PICTURE'|@getFixedLabel}/{'VIDEO'|@getFixedLabel}</li>
                            <li value="voice">{'VOICE'|@getFixedLabel}</li>
                        </ul>
                    </div>
                    <div id="chatdatalist">
                        {include file='modules/WechatSession/ChatData.tpl'}
                    </div>
                </div>
            </div>
        </div>
    {else}
        <div id="searchbycustomer" class="talk-wrapper linefeed">
            <div class="talk-wrapper-left gwidth20">
                <div class="talk-wrapper-title">{'CustomerList'|@getFixedLabel}</div>
                <div class="talk-wrapper-content">
                    <div class="talk-wrapper-search-con">
                        <div class="positionFirst top5" title="{'SEARCH'|@getFixedLabel}" onclick="WechatSessionobj.CustomerChatMemberListobj.search();">
                            <i class="ld-fonticon ld-fonticon-search hlineheight30"></i>
                        </div>
                        <input class="talk-wrapper-search gwidth100" type="text" name="searchmember" value=""
                               placeholder="{'SearchCustomers'|@getFixedLabel}">
                    </div>
                    {*点击时保存起来*}
                    <input type="hidden" name="member_wx_userid" value="">
                    <div id="memberlist">
                        {include file='modules/WechatSession/CustomerMemberList.tpl'}
                    </div>
                </div>
            </div>
            <div class="talk-wrapper-center gwidth20">
                <div class="talk-wrapper-title">{'SessionList'|@getFixedLabel}</div>
                <div class="talk-wrapper-content">
                    <div class="talk-wrapper-search-con">
                        <div class="positionFirst top5" title="{'SEARCH'|@getFixedLabel}" onclick="WechatSessionobj.CustomerChatSessionListobj.search();">
                            <i class="ld-fonticon ld-fonticon-search hlineheight30"></i>
                        </div>
                        <input class="talk-wrapper-search gwidth100" type="text" name="searchsession" value=""
                               placeholder="{'SearchSessions'|@getFixedLabel}">
                    </div>
                    <input name="session_type" type="hidden" value="external"/>
                    <div class="talk-tabs">
                        <ul class="talk-tabs-nav talk-tabs-nav-two2" name="session_type_event">
                            <li value="external" class="talktabsselected">{'Singlechat'|@getFixedLabel}</li>
                            <li value="groupchat">{'Groupchat'|@getFixedLabel}</li>
                        </ul>
                    </div>
                    <input type="hidden" name="session_wx_userid" value="">
                    <input type="hidden" name="session_roomid" value="">
                    <div id="sessionlist">
                        {include file='modules/WechatSession/CustomerSessionList.tpl'}
                    </div>
                </div>
            </div>
            <div class="talk-wrapper-right gwidth60">
                <div class="talk-wrapper-title talk-wrapper-righttitle" style="display: flex;">
                    <div class="overflow-space" style="flex: 1;"><span name="chatdata_personnel"></span></div>
                    <div class="talk-wrapper-search-con" style="flex: 1;">
                        <input name="end_date" class="Wdate" type="text" style="border:1px solid #dbdbdb;" size="11" maxlength="10" value="" placeholder="{'End_Date'|@getFixedLabel}"onclick="WdatePicker({ldelim}onpicked:function(){ldelim}WechatSessionobj.CustomerChatDataListobj.search(){rdelim}{rdelim})">
                        <input name="begin_date" class="Wdate" type="text" style="border:1px solid #dbdbdb;" size="11" maxlength="10" value="" placeholder="{'Start_Date'|@getFixedLabel}"onclick="WdatePicker({ldelim}onpicked:function(){ldelim}WechatSessionobj.CustomerChatDataListobj.search(){rdelim}{rdelim})">
                    </div>
                    <div class="talk-wrapper-search-con" style="flex: 1;">
                        <div class="positionFirst" title="{'SEARCH'|@getFixedLabel}" onclick="WechatSessionobj.CustomerChatDataListobj.search('count');">
                            <i class="ld-fonticon ld-fonticon-search hlineheight30"></i>
                        </div>
                        <input class="talk-wrapper-search rfloat gwidth100" type="text" name="searchcontent" value="" placeholder="{'SearchSessionContent'|@getFixedLabel}">
                    </div>
                </div>                        
                <div class="talk-wrapper-content talk-wrapper-content-right">
                    <input name="page" type="hidden" value="{$page}"/>
                    <input name="page_num" type="hidden" value="{$page_num}"/>
                    <input name="msgtype" type="hidden" value="all"/>
                    <div class="talk-tabs">
                        <ul class="talk-tabs-nav talk-tabs-nav-three" name="msgtype_event">
                            <li value="all" class="talktabsselected">{'ALL'|@getFixedLabel}</li>
                            <li value="file">{'FILE'|@getFixedLabel}</li>
                            <li value="image">{'PICTURE'|@getFixedLabel}/{'VIDEO'|@getFixedLabel}</li>
                            <li value="voice">{'VOICE'|@getFixedLabel}</li>
                        </ul>
                    </div>
                    <div id="chatdatalist">
                        {include file='modules/WechatSession/CustomerChatData.tpl'}
                    </div>
                </div>
            </div>
        </div>
    {/if}
</div>

<script>
    var Listpagepopupobj=new CrmPopup();
    Listpagepopupobj.divid='wechatsession';
    Listpagepopupobj.module='WechatSession';
    var searchbytype='{$searchbytype}';
    var WechatSessionobj;
    CrmPopup.global_listPopupObj.push(Listpagepopupobj);
    getJsScript('include/js/modules/WechatSession/ChatMemberList.js',function(){
        getJsScript('include/js/modules/WechatSession/ChatSessionList.js',function(){
            if(searchbytype == 'searchbymember'){
                //初始化WechatSession对象
                WechatSessionobj= new WechatSession();
            }
            else{
                WechatSessionobj = new CustomerWechatSession();
            }
            WechatSessionobj.startEvent();
            WechatSessionobj.setWechatSessionHeight();
        });
    });
</script>