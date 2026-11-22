//@edit:liushuai,2020-11-18,reason:ID1000713/企业微信会话存档(获取相关会话数据)
function CustomerWechatSession()
{
    var parent = new WechatSession();
    this.popupobj = CrmPopup.getPopupObj('last');
    // document.write('<script language="JavaScript" type="text/javascript" src="include/js/modules/WechatSession/ChatMemberList.js"></script>');
    this.CustomerChatMemberListobj = new CustomerChatMemberList();
    this.CustomerChatSessionListobj = new CustomerChatSessionList();
    this.CustomerChatDataListobj = new CustomerChatDataList();
    this.startEvent = function () {
        this.CustomerChatMemberListobj.setMemberListEvent();
    }

    //根据成员（客户）搜索
    this.showSearchType = function (obj, searchtype) {
        parent.showSearchType(obj, searchtype);
    };

    this.setWechatSessionHeight = function () {
        parent.setWechatSessionHeight();
    }
}