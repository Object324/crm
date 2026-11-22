//查看界面弹出层
//var datetimestr;
function DetailViewPage(){
    var that=this;
    that.related_module="detailview";
    var parentprevshow=this.prevshow;
    var parentshow=this.show;
    var parentCancelEvent=this.CancelEvent;
    this.position=CrmPopup.Positions.right;
    this.picklistobjarray=[];
    this.prevrecord=0;
    this.nextrecord=0;
    this.detailButtons={};//详情页的操作按钮 比如编辑、复制、删除等
    this.imageArr={};//详情页图片 比如收款单的预收、收款 以及模块的审批图片等
    this.tagArr={};
    this.detailsettings={};//详情页设置按钮
    that.js_detailtablename='proTab';//分录所在的表格名称
    this.CancelEvent=function(){
        var popupobj=CrmPopup.getPopupObj('last');
        if(popupobj.type=='relatelistpage')
        {

            CrmPopup.global_listPopupObj.pop();

        }
        parentCancelEvent.apply(that);
    }
    this.right=function()
    {
        CrmPopup.rightCenter(ld("#"+this.divid),this);
    }
    this.getpopupMaxHeight=function()
    {
        //高度全屏
        return CrmPopup.getClientHeight();
    }
    /*
    创建弹出层标题栏
    //zxm 20221121 标题栏样式和内容修改 左侧显示字段名称 字段值 上一页下一页
    */
    this.createHeadHtml=function()
    {
        that.popupheadhtml='<div class="E_pop_tit detail-popup-title" style="cursor:move" id="'+this.divid+'_head">';
        that.popupheadhtml+=this.getHeadHtmlContent();
        that.popupheadhtml+='</div>';
    }

    this.getHeadHtmlContent=function () {
        var popupheadhtmlcontnet = '';
        popupheadhtmlcontnet+='<div class="flex_between"><strong class="E_ptita">'+this.headtitle+'</strong>';
        // wym 20230215 添加复制字段图标 20230220 BUG复制图标出现太快
        popupheadhtmlcontnet+=' <i id="copy_icon" data-module="'+that.module+'" data-record="'+that.record+'" href="javascript:;" style="display: none;" data-tip="'+arrJsPopLabel['COPYID']+'" data-direction="bottom" data-type="position" class="ld-fonticon ld-fonticon-copy marL5 marR16 tip-items-list" onclick="CopyDetailPageTitle(this)" ></i>';
        //zxm 20221121 标题栏样式和内容修改 左侧显示字段名称 字段值 上一页下一页
        popupheadhtmlcontnet+='<div class="icon-left-inactive tip-items-list" data-tip="'+arrJsPopLabel['PREVPAGE']+'" data-direction="bottom" data-type="position" name="prevnextrecord" style="display:none;margin:8px 2px;" tag="prevrecord" onclick="DetailViewPreVNext(ld(this))" repeat="no"><b class="icon-pre-next"></b></div>';
        popupheadhtmlcontnet+='<div class="icon-right-inactive tip-items-list" data-tip="'+arrJsPopLabel['NEXTPAGE']+'" data-direction="bottom" data-type="position" name="prevnextrecord" style="display:none;margin:8px 2px;" tag="nextrecord" onclick="DetailViewPreVNext(ld(this))" repeat="no"><b class="icon-pre-next"></b></div>';

        // lqt 20230601 标题栏状态标签样式修改
        // approveTag 审批标签
        popupheadhtmlcontnet+='<div class="ld-tag-container">';
        ld.each(that.tagArr,function(tagname,taginfo){
            popupheadhtmlcontnet+= taginfo;
        });
        popupheadhtmlcontnet+='</div>';
        popupheadhtmlcontnet+='</div>';

        popupheadhtmlcontnet+='<div class="E_pop_tit_Second_Right ld-detailview-btnscontent">';

        var popupobj=CrmPopup.getPopupObj('last');
        ld.each(that.detailButtons,function(actionname,item){
            if(item.permit=='yes'){
                var tmptag = empty(item.tag)?'':item.tag;
                if(actionname=='channelcode_edit'){
                    popupheadhtmlcontnet+='<div class="ld-button" tag="'+tmptag+'" onclick="detail_channelcode_edit(event,\''+that.record+'\');return false;">'+item.label;
                }
                else if(actionname=='channelcode_delete'){
                    popupheadhtmlcontnet+='<div class="ld-button" tag="'+tmptag+'" onclick="detail_channelcode_delete(event,\''+that.record+'\');return false;">'+item.label;
                }
                else{
                    if(actionname!='More') {
                        // 自定义按钮
                        if(item.custombtn == 'yes'){
                            popupheadhtmlcontnet += '<div class="ld-button" tag="' + tmptag + '" onclick="customButtonClick(\'detail\',\'' + that.module + '\',\'' + that.record + '\',\'' + item.btnid + '\');return false;">' + item.label;
                        }else{
                            popupheadhtmlcontnet += '<div class="ld-button" tag="' + tmptag + '" onclick="detailbutton_click(this,\'' + that.module + '\',\'' + actionname + '\',\'' + that.record + '\');return false;">' + item.label;
                        }
                    }
                    else{
                        popupheadhtmlcontnet += '<div class="ld-button-more ld-button-detail-more" tag="' + tmptag + '">' + item.label;
                    }
                }
                if(actionname=='More'){
                    var tmpmore_btns = item.list;
                    var tmp_stickybtn_top = 0;// 固定按钮需要margin-top的px
                    popupheadhtmlcontnet+='<ol class="D_more_menua" style="z-index:100001;max-height:210px;">';
                    ld.each(tmpmore_btns,function(acname,btnitem){
                        if(btnitem.permit=='yes') {
                            var tmptag = empty(btnitem.tag)?'':item.tag;
                            // 自定义按钮
                            if(btnitem.custombtn == 'yes'){
                                popupheadhtmlcontnet += '<li onclick="customButtonClick(\'detail\',\'' + that.module + '\',\'' + that.record + '\',\'' + btnitem.btnid + '\');return false;">\n' +
                                    '  <a title="' + btnitem.label + '" tag="'+tmptag+'">\n' + btnitem.label + '</a>\n' +
                                    '  </li>';
                            }
                            else{
                                popupheadhtmlcontnet += '<li onclick="detailbutton_click(this,\'' + that.module + '\',\'' + acname + '\',\'' + that.record + '\');return false;">\n' +
                                    '  <a title="' + btnitem.label + '" tag="'+tmptag+'">\n' + btnitem.label + '</a>\n' +
                                    '  </li>';
                            }
                            tmp_stickybtn_top += 42;
                        }
                    });
                    popupheadhtmlcontnet += '</ol>';
                    tmp_stickybtn_top = tmp_stickybtn_top>0 ? (tmp_stickybtn_top-2):(tmp_stickybtn_top);
                    tmp_stickybtn_top = tmp_stickybtn_top>208 ? (208):(tmp_stickybtn_top);
                    popupheadhtmlcontnet += '<ol class="D_more_menua" style="z-index:100001;margin-top: '+(tmp_stickybtn_top)+'px;">';
                    var detailsettingshtml = '';
                    var bottom = 1;
                    var settinglength = that.detailsettings.length;
                    ld.each(that.detailsettings,function(settingindex,settingitem) {
                        var click = '';
                        if (settingitem.click){
                            click = settingitem.click;
                        }
                        var url = '';
                        if (settingitem.url){
                            url = settingitem.url+' '+'target="_blank"';
                        }
                        else{
                            url = 'href="javascript:;"';
                        }
                        var style='';
                        if(settingindex==(settinglength-1)){
                            style='border-top: 1px solid #e5e9f2;';
                        }
                        detailsettingshtml = '<li class="ld-setting-sticky" style="bottom:'+bottom+'px;'+style+'" '+click+'>' +
                            '<a '+url+' title="'+settingitem.label+'">'+settingitem.label+'</a>' +
                            '</li>'+detailsettingshtml;
                        bottom = parseInt(bottom)+42;
                    });
                    popupheadhtmlcontnet += detailsettingshtml;
                    popupheadhtmlcontnet += '</ol>';
                }
                popupheadhtmlcontnet+='</div>';
            }
        });
        /* 赛可出行
		* edit: chj
		* date: 2020/8/11
		* reason: 流转、更新、结案、结案备注
		*/
        //edit:can 20210409 45304: （https://61mis.com/kfbcrm [^]）报表-常用报表-签到统计表；刷新一下页面，拜访对象超链接字段失效
        if(that.module == 'Accounts' && global_js_version != undefined && global_js_version == 'saic' && popupobj.module =='Accounts'){
            popupheadhtmlcontnet+='<div class="ld-button" tag="closedremarks" value="结案备注" onclick="set_saic_account(ld(this),event);return false;" style="padding-right:50px;">结案备注</div>';
            popupheadhtmlcontnet+='<div class="ld-button" tag="closed" value="结案" onclick="set_saic_account(ld(this),event);return false;">结案</div>';
            popupheadhtmlcontnet+='<div class="ld-button" tag="wander" value="流转" onclick="set_saic_account(ld(this),event);return false;">流转</div>';
            popupheadhtmlcontnet+='<div class="ld-button" tag="update" value="更新" onclick="set_saic_account(ld(this),event);return false;">更新</a>';
        }
        popupheadhtmlcontnet+='<div class="ld-fonticon ld-fonticon-close tip-items-list" value="'+arrJsPopLabel['LBL_CLOSE']+'" data-tip="'+arrJsPopLabel['LBL_CLOSE']+'" id="'+this.divid+'_imgclose" data-direction="bottom" data-type="position"></div>';
        popupheadhtmlcontnet+='</div>';
        return popupheadhtmlcontnet;
    }
    this.refreshDetailHead=function () {
        var module = this.pagemodule;
        var record = this.pagerecord;

        var url = 'index.php?module='+module+'&action='+module+'Ajax&file=getDetailHeadinfo&record='+record;
        ldAjax(url,'',function(data) {
            if(data.code==-1)
            {
                RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                return false;
            }
            if(data.code==1)
            {
                if(!empty(data.result.detailButtons)){
                    that.detailButtons = data.result.detailButtons;//zxm 20221121 单据详情页 按钮换位置
                }
                if(!empty(data.result.imageArr)){
                    that.imageArr = data.result.imageArr;//zxm 20221121 单据详情页 审批图片等其他图片
                }
                if(!empty(data.result.tagArr)){
                    that.tagArr = data.result.tagArr;//lqt 20230601 单据详情页 审批标签等其他标签
                }
                if(!empty(data.result.detailsettings)){
                    that.detailsettings = data.result.detailsettings;//zxm 20221207 单据详情页 设置按钮 比如页面设置 单据分录设置 等
                }
                var headhtml = that.getHeadHtmlContent();
                ld('#'+that.popupdivid+'_head').html(headhtml);

                ld('#'+that.popupdivid+'_imgclose').on('click',function () {
                    that.CancelEvent();
                    if (this.Cancelfun != "" && this.Canclefun != undefined) {
                        CrmPopup.Cancel(this.Cancelfun, that.CancelfunParamObj);
                    }
                    //作用：相关信息点击关闭按钮会刷新
                    return false;
                })
            }
            DelProgressObjs();
        });
    }

    this.PopupAllReadFun=function(){
        if(that.isread=='yes'&&that.isfinishanimate=='yes')
        {
            //duan 20240110 因为推进可能修改啊divid ,重置弹出层id,避免选择到其他对象
            if(!empty(that.popupdivid)){
                that.divid = that.popupdivid;
            }
            //zkt 20240103 BUG0078197 提单指示和备货通知书——单据编号显示不全，别的单据也有该情况
            that.setHeadtitleMaxwidth();
            ld("#"+that.divid+" #PROGRESSTRACKING").css("width", (0.98*ld("#"+that.divid).width())+ 'px');
            setProductDivWidth(that)
        }

    }
    this.show=function(htmlcontent)
    {

        this.isclicklayerclose='yes'
        parentshow.apply(that,[htmlcontent]);

        that.InitPageValue();

        that.readylistBind();
        IsFrameElement();

        ld("#"+this.divid).ready(function(){

            that.isread='yes';
            that.PopupAllReadFun();

        })
        //加载tip 20200629 diony
        // tooltip(ld('#'+this.divid).find(" .tip-items-list"), {transition: true, time: 200});
    }
    this.workreportListShow=function (htmlcontent){
        this.isclicklayerclose='yes'
        parentshow.apply(that,[htmlcontent]);
        that.InitPageValue();
    }
    /**
     重新加载内容
     **/
    this.reload=function(htmlcontent)
    {
        that.createHeadHtml();//zxm 20221124 审批按钮放在header上  审批操作之后更新按钮
        ld("#"+this.divid).html(this.popupheadhtml+
            this.scrolldiv+
            htmlcontent+'</div>'+this.popupbottomhtml);
        this.setHeadtitleMaxwidth();
        document.getElementById(this.divid).style.display="block";
        this.setScrollDivMaxHeight();
        this.setEvent();
    }
    //动态设置标题名称最大宽度  wym 231206 BUG0076737
    this.setHeadtitleMaxwidth = function () {
        var headobj=ld("#" + this.divid + " .detail-popup-title");
        var head_width = headobj.width();
        var rightbtn_width = headobj.find(".E_pop_tit_Second_Right").width();

        var leftbtn_width = 150;//复制按钮（38）+上下翻页按钮宽度（64）+预留的内边距和外边距
        if (headobj.find(".ld-tag-container").length>0){
            leftbtn_width+=headobj.find(".ld-tag-container").width();
        }
        headobj.find(".E_ptita").css("max-width", head_width-leftbtn_width-rightbtn_width+'px');
    }
    //滚动条 zxm20221124 详情页增加padding 和背景色
    this.createScrollDiv=function()
    {
        var userid = '';
        if(this.userinfo){
            userid = this.userinfo.userid;
        }
        this.scrolldiv='<div class="dvpopupsroll popup-content-div ld-bg-color" style="max-height:1200px;width: 100%;overflow:hidden;">';
    }
    // ljj 2023-08-23 BUG0070733 kfbtest-工作汇报（列表），点击汇报详情，页面没有滚动条无法下滑
    this.WorkReportList_createScrollDiv=function()
    {
        this.scrolldiv='<div class="dvpopupsroll popup-content-div " style="max-height:1200px;width: 100%;overflow-y: auto;">';
    }
    this.setInnerHtml=function()
    {

        ld("#"+this.divid).html(this.popupheadhtml+

            this.scrolldiv+

            this.htmlcontent+'</div>'+this.popupbottomhtml );



        this.setHeadtitleMaxwidth();
        document.getElementById(this.divid).style.display="block";
        this.setScrollDivMaxHeight();
    }
    this.picklist_arrow_click = function (event, fieldname) {
        cmb_fldname = fieldname;//用于picklist.js中document.onclick调用
        cmb_parentdivid = this.divid;//用于picklist.js中document.onclick调用

        that.picklistobjarray[fieldname].arrow_click(fieldname);

    }
    this.picklist_end_foucs=function(event,fieldname)
    {
        ld("#"+this.divid+" [name=cmb_span_optiontext_"+fieldname+"]").select();

    }
    this.InitPageValue=function()
    {
        this.fieldname_fields=[];
        this.column_fields=[];
        this.uitypes=[];

        if(that.picklistcontent!=null&&that.picklistcontent!=undefined&&that.picklistcontent!="")
        {

            for(var k=0;k<that.picklistcontent.length;k++)
            {
                //下拉框
                var fieldname=that.picklistcontent[k].fieldname;
                that.picklistobjarray[fieldname]=new cls_picklist(fieldname,that.picklistcontent[k].optionvalue);
                //edit:can 20210728 047151: （https://81mis.com/kfbcrm [^]）启用服务合同新增保存后立即创建收款计划参数，进入客户单据查看详情保持不动，点击相关信息->服务合同下方浮显的新建按钮保存后，取消收款计划新建弹窗，再点击客户相关信息其他模块时点不动
                that.picklistobjarray[fieldname].setPopupobj(that);
                if(that.picklistdepencyfields!=null&&that.picklistdepencyfields!=""&&that.picklistdepencyfields[fieldname]!=undefined)
                {

                    that.picklistobjarray[fieldname].setparentDependField(that.picklistdepencyfields[fieldname]);

                }

            }
        }
        if(that.picklistdepencyfields!=null&&that.picklistdepencyfields!=undefined)
        {
            ld.each(that.picklistdepencyfields,function(childfieldname,parentfieldname){
                if(that.picklistobjarray[parentfieldname] != undefined){
                    that.picklistobjarray[parentfieldname].setchildDependField(childfieldname);
                }
            });
        }
        ld.each(this.fields,function(index,fieldinfo){
            var fieldname=fieldinfo.fieldname;

            that.fieldname_fields[fieldname]=fieldinfo;
            that.uitypes[fieldname] = fieldinfo.uitype;
            that.column_fields[fieldinfo.columnname]=fieldinfo;
            if(fieldinfo.uitype==33&&fieldinfo.allowedit!='no')//多选框字段在推进编辑 查看界面不能编辑,
            {
                //edit:can 20200822 42471: （https://61mis.com/kfbcrm [^]）客户问题（优纳伯重型包装），客户单据查看详情界面，“多选框”字段类型的字段小编辑功能无法使用，编辑时没有显示下拉选项（需要补丁）
                ld('#'+that.divid+" [name='"+fieldname+"']").select2({closeOnSelect: true, dropdownParent: ld("#"+that.divid)});
            }

        })

        var fieldruleobj=new cls_fieldrule(that,this.fieldrulefieldnames);
        this.fieldruleobj=fieldruleobj;
        fieldruleobj.setEvent();
        var fieldSensitiveruleobj=new cls_fieldSensitiverule(that,that.sensitiverelatedfield);
        that.fieldSensitiveruleobj=fieldSensitiveruleobj;
        fieldSensitiveruleobj.setEvent();
        var tmpvalues={};
        ld.each(this.column_fields_value,function(columnname,valueinfo){
            if(that.column_fields[columnname]!=undefined)
            {
                var fieldname=that.column_fields[columnname].fieldname;
                tmpvalues[fieldname]=valueinfo[0];
            }
        })
        //console.log(tmpvalues);
        fieldruleobj.setValues(tmpvalues);

        if(typeof cls_wxOpenDataobj!="undefined"&&typeof cls_wxOpenDataobj!=undefined){

            cls_wxOpenDataobj.bindAllOpenDataByPopupObj(this);

        }

        if(ld('#commentMode').data('commentmode') != 'concise'){
            ld('textarea').not('.proName_note').autosize();//修改文本域的高度
        }
        if(account_version=='langjie')
        {
            //edit:can 20200803 郎捷 设置列头标签显示
            if(that.module=='CustomForm18')
                setTableTdLabellangjie();
            else if(that.module=='CustomForm19')
                setTableTdLabellangjieCustomForm19();
        }
    }
    this.readylistBind=function(){
        //获取相关信息数量
        if (that.module == 'ChannelCode')
            return;
        initDetailRelationBtn();//加载相关信息点击事件

        var  accountid;
        var  contactid;
        ld.each(that.fields,function(tmpindex,tmpfieldinfo){
            if(tmpfieldinfo.uitype=='73')
            {
                accountid=that.column_fields_value[tmpfieldinfo.columnname][0];
                return false;
            }


        })
        ld.each(that.fields,function(tmpindex,tmpfieldinfo){
            if(tmpfieldinfo.uitype=='57')
            {
                contactid=that.column_fields_value[tmpfieldinfo.columnname][0];
                return false;
            }


        })

        //联合技术MER特殊控制:根据费用类别控制显示隐藏列
        if(that.module == 'Expense' && version_account == 'utrc'){
            changeDetailColumn(utrc_type);

        }

        //客户服务单、项目任务、销售机会显示 客户联系人关联字段
        if(that.bestatus == 'yes')
        {
            getAccountsContactsInfo(accountid,contactid,that.module,that);
        }
        // 服务信息
        if((that.module == 'Accounts' || that.module == 'HelpDesk') && select_servicedetail == 1){
            if(that.module=='Accounts')
            {
                var  accountid=that.record;
            }

            if(accountid>0)
                showServiceContractsDetail(accountid,that.module,that);
        }
        var def=ld.Deferred();
        //评论
        //edit:can 2021-02-26 44774: （61mis.com/kfbcrm）工具-公告；公告的单据审批后，没有审批日志
        if(that.module!='Rate'&&that.module!='PorjectProgress')//edit:can reason:16195: 提醒界面，多了评论区块。
        {
            //wym 240129 BUG20240126-42 消息中心，提醒内容单据查看界面，评论区块点击@后成员下拉选项没有显示出来
            showModCommentsHtml(that.module,that.record,that);
        }

        //服务单历史记录
        if(that.module=='HelpDesk' && helpdesk_log == 1){
            getAccountByHelpDeskHistory(accountid,'',that);
        }
        //editor:gyq_123 reason:显示服务小程序录入的沟通信息  2019/6/18 14:14 ID1000512
        if(that.module=='HelpDesk' && communicate === '1'){
            get_communicate_detail(that.record,that.module);
        }
        //editor:gyq_127 reason:服务小程序增加评价  2019/6/26 11:47 ID1000419
        if(that.module=='HelpDesk' && evaluate === '1'){
            get_evaluate_detail(that.record,that.module);
        }
        if(that.module == 'Accounts' || that.module == 'HelpDesk'){
            //	getLocationAddress('locationaddress','detail');
        }
        DetailViewRelation.getRelatedCount(that);
    }



    this.setTimeCount=function()
    {
        this.timeintervalid=setInterval(function(){ that.timeCount+=3;},3000);


    }
    this.clearTimeCount=function()
    {
        this.timeCount=0;

        clearInterval(this.timeintervalid);
    }

}

DetailViewPage.type='detailviewpage';
DetailViewPage.pagetype="detailview_modulepage";//

DetailViewPage.load=function(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText)
{
    DetailViewPage.prototype=new CrmPopup();
    DetailViewPage.prototype.constructor=DetailViewPage;
    DetailViewPage.prototype.type=DetailViewPage.type;
    DetailViewPage.prototype.record=0;
    var  Popupobj=new DetailViewPage();
    Popupobj.pagetype=DetailViewPage.pagetype;
    Popupobj.tabtype='detailinfo';//判断查看界面点击的页签
    Popupobj.setParams(headtitle,"","",cssWidth,module,"","","",CancelText);
    Popupobj.showafter=function()
    {

        //界面显示后，加载相关ajax
    }

    return Popupobj
}
DetailViewPage.getWidth=function(){
    return  parseInt((CrmPopup.getClientWidth()- getLeftMenuWidth())*0.9);
}
DetailViewPage.showpage=function(module,record,lasturl,paramsobj)
{
    var prev_popupobj=CrmPopup.getPopupObj('last');
    // //@edit:liushuai,2020-08-24,reason:0043583: （61mis.com/kfbcrm）客户管理-客户-详情；打开客户详情后，按回车键，会再次打开详情，可一直按回车循环(谷歌浏览器有此问题，火狐没有)
    /*if (prev_popupobj.pagetype != "listpage") return false;*/

    if(prev_popupobj != undefined && (prev_popupobj.module==module||prev_popupobj.module=='Approve'))
        var pagestart=ld("#"+prev_popupobj.divid+" [name=pagenum]").val();
    else
        var pagestart=-1;
    if(lasturl=='undefined'||lasturl==undefined)
    {
        lasturl='';
    }
    var url = 'index.php?module='+module+'&action='+module+'Ajax&file=DetailView&record='+record+lasturl+"&pagenum="+pagestart;
    //zkt 添加判断，链接模块的详情操作,防止与相关信息的详情冲突
    if (typeof linkmodulecustom != "undefined"&& typeof prev_popupobj != "undefined" && prev_popupobj.type != 'relatelistpage') {
        //@edit:zkt,reason:链接模块，单据新建/编辑/复制界面，“数据分类设置的条件”字段显示为只读的，不可编辑修改
        //获取链接模块viewname
        var page_addurl = getSearchString('page_addurl',location.href);
        if(page_addurl != undefined){
            var linkmodule_viewname = getSearchString('viewname',page_addurl);
            if(linkmodule_viewname != undefined){
                url +='&linkmodule_viewname='+linkmodule_viewname;
            }
        }
    }


    var tmpwidth=DetailViewPage.getWidth();//parseInt((CrmPopup.getClientWidth()- getLeftMenuWidth())*0.9);
    var Popupobj=DetailViewPage.load("","","",tmpwidth,module,"","","","");

    // Popupobj.createScrollDiv();
    Popupobj.prevshow();

    Popupobj.record=record;
    // diony 2023-12-15 XUQIU1002381 新增、编辑、明细界面做Skeleton 骨架屏
    AjaxJSPage('ld_Skeleton','include/js/component/ld_Skeleton.js');
    ld('#'+Popupobj.divid).find('div[name=prevshowdv]').remove();
    ld_Skeleton.showSkeletonPop(Popupobj, CrmPopup.getClientHeight()-64);
    // return;

    //20240726 hzx XUQIU1001729 经销商用PRM成员管理设置
    if(module == 'Users'){
        var tmp_user_type = 'crm';
        if(crmorprmtype == 'crm'){
            if(prev_popupobj != undefined && prev_popupobj.user_type){
                tmp_user_type = prev_popupobj.user_type;
            }
        }else{
            tmp_user_type = 'prm';
        }
        url += '&user_type='+tmp_user_type;
        Popupobj.user_type = tmp_user_type;
    }

    // Safari浏览器增加一个样式
    if (navigator.userAgent.indexOf('Safari') != -1 && navigator.userAgent.indexOf('Mac') != -1 && navigator.userAgent.indexOf('Chrome') == -1) {
        // console.log('Safari on Mac detected, applying class...');
        ld('#'+Popupobj.divid).addClass('ld-safari-mac'); // provide a class for the safari-mac specific css to filter with
    }

    ldAjax(url,{"namename": "uname", "namenameage": 18, "detailpagewidth": tmpwidth},function(data) {
        if(data.code==-1)
        {

            //40197: （51mis.com/kfbtest）工具>回收站>选择“客户”模块>序时簿界面：点击“客户名称”超链接字段，弹出“提示框”界面需要优化，界面右侧
            //chj 2021/1/5 44069: （本地php72，8.3.6）客户管理-客户-相关信息（需要补丁）；相关信息中，报价单是其他成员创建的，点击报价单提示没有权限查看；关闭弹出层后，左侧遮罩层消失，这时点击相关信息其他页签会一直转圈
            setTimeout(function(){
                Popupobj.CancelEvent();
                RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                return false;
            },200);
            DelProgressObjs();
            return false;
        }
        if(data.code==1)
        {
            Popupobj.lasturl=lasturl;
            Popupobj.pagerecord = record;
            Popupobj.pagemodule = module;
            DetailViewPage.showpage_content(Popupobj,data,module);

            //朗捷 报关单 隐藏字段
            if(CrmPopup.findHtmlobj(popupobj.divid,'version_account').val() == 'langjie' && Popupobj.module =='CustomForm22'){
                HideDetail()
            }

        }
        DelProgressObjs();

    });
}
// 单据详情页具体内容
DetailViewPage.showpage_content = function(Popupobj,data,module){
    // $("status").style.display="none";
    Popupobj.setParams(data.result.title,"","","LdPopWidth950px",module,"","","","");
    if (module == 'WorkReportList'){
        Popupobj.WorkReportList_createScrollDiv();
        Popupobj.workreportListShow(data.result.content);
    }
    var cashtype='';
    if(!empty(Popupobj.popupdivid)){
        //判断是否存在自动化任务，如果存在则重置divid
        var tableobj= ld("#"+Popupobj.divid+" table[name=advancetask]");
        if(tableobj.length >0){
            ld("#"+Popupobj.popupdivid+" [name=AllTaskvalue]").unbind('mouseout');
            ld("#"+Popupobj.popupdivid+" [name=AllTaskvalue]").unbind('mouseout');
            ld("#"+Popupobj.popupdivid+" [name=displayfields]").unbind('mouseover');
            ld("#"+Popupobj.popupdivid+" [name=displayfields]").unbind('mouseover');
            Popupobj.divid = Popupobj.popupdivid;
        }
    }
    Popupobj.validatasaverule = data.result.validatasaverule;
    if(module=='CashBill'){
        //显示预收款信息
        if(data.result.column_fields_value.cashtype!=undefined){
            //收款单的收款类型
            Popupobj.cashbilltype=data.result.column_fields_value.cashtype[0];
        }
        if(data.result.column_fields_value['accountid']!=undefined)
            var accountid=data.result.column_fields_value['accountid'][0];
        else
            var accountid=0;
        if(data.result.column_fields_value['bankaccountsetid']!=undefined)
            var bankaccountsetid=data.result.column_fields_value['bankaccountsetid'][0];
        else
            bankaccountsetid=0;
        //edit:can 2020-08-31 收款单关联预收单做核销的时，无需控制“银行账户”一致，控制币种一致即可
        if(data.result.column_fields_value['currency_id']!=undefined)
            var currency_id=data.result.column_fields_value['currency_id'];
        else
            currency_id=0;

        if(data.result.column_fields_value['cashtype']!=undefined)
            var cashtype=data.result.column_fields_value['cashtype'][0];
        else
            var cashtype='';

        if(accountid>0)
        {
            var relatelistobj;
            // include/js/modules/CashBill/CashBill.js;zxm 提成报表页面的点击收款单编号查看详情报错的问题
            getJsScript('include/js/modules/CashBill/CashBill.js',function() {

                relatelistobj = getChooseRelateLists.getInstance(Popupobj);

                relatelistobj.setCurrencyId(currency_id);
                relatelistobj.getChooseAccountRelateList(bankaccountsetid, accountid, cashtype);
            });
        }
    }


    if(module=='HelpDesk')
    {
        Popupobj.helpdesk_log=data.result.helpdesk_log;
        //reason:服务小程序增加评价  2019/6/18 13:52 ID1000512

        Popupobj.evaluate=data.result.evaluate;
    }
    if(module=='Account')
    {
        Popupobj.accountset=data.result.accountset;
    }

    Popupobj.prevrecord=data.result.prevrecord;
    Popupobj.nextrecord=data.result.nextrecord;
    Popupobj.communicate=data.result.communicate;
    Popupobj.isapprovemod=data.result.isapprovemod;

    Popupobj.bestatus=data.result.bestatus;
    Popupobj.columnfields_value=data.result.columnfields_value;
    Popupobj.detailfilejsondata=data.result.detailfilejsondata;

    Popupobj.validatasave=data.result.validatasave;
    Popupobj.column_fields_value=data.result.column_fields_value;
    //  console.log(Popupobj.column_fields_value);
    Popupobj.fields=data.result.fields;
    Popupobj.approvemod=data.result.approvemod;
    Popupobj.list_link_field=data.result.list_link_field;//超链接字段
    Popupobj.pagenum=data.result.pagenum;//当前记录所在的页号
    Popupobj.picklistdepencyfields=data.result.picklistdepencyfields;
    Popupobj.smownercolumnname=data.result.smownercolumnname;
    Popupobj.smownercolumnname_value='';
    Popupobj.picklistdepency=data.result.picklistdepency;//下拉框依赖项
    Popupobj.picklistcontent=data.result.picklistcontent;
    Popupobj.fieldrulefieldnames=data.result.fieldrulefieldnames;
    Popupobj.sensitiverelatedfield = data.result.sensitiverelatedfield;//敏感规则相关字段
    Popupobj.detailfields=[];
    Popupobj.popupdivid = Popupobj.divid;
    Popupobj.modcomment_fileImg_fieldobj = data.result.modcomment_fileImg_fieldobj;
    Popupobj.ModcommentReplyId = {};
    if(data.result.detailfields!=undefined)
    {
        Popupobj.detailfields=data.result.detailfields;
        Popupobj.detailmodule=data.result.detailmodule;
    }
    if(data.result.modcommentdisplayright!=undefined)
    {
        Popupobj.modcommentdisplayright=data.result.modcommentdisplayright;
    }
    //@edit:liushuai,2020-09-03,reason:【成员管理，修改当前用户密码保存后，当前用户自动退出CRM系统】(详情页修改密码时判断)
    if(data.result.userinfo){
        Popupobj.isadmin = data.result.userinfo.isadmin;
        Popupobj.userinfo = data.result.userinfo;
    }
    else{
        Popupobj.isadmin = data.result.isadmin;
    }
    if(!empty(data.result.detailButtons)){
        Popupobj.detailButtons = data.result.detailButtons;//zxm 20221121 单据详情页 按钮换位置
    }
    if(!empty(data.result.imageArr)){
        Popupobj.imageArr = data.result.imageArr;//zxm 20221121 单据详情页 审批图片等其他图片
    }
    if(!empty(data.result.tagArr)){
        Popupobj.tagArr = data.result.tagArr;//lqt 20230601 单据详情页 审批标签等其他标签
    }
    if(!empty(data.result.detailsettings)){
        Popupobj.detailsettings = data.result.detailsettings;//zxm 20221207 单据详情页 设置按钮 比如页面设置 单据分录设置 等
    }
    //  alert(data.result.filejsondata);
    // if(!empty(data.result.filejsondata)){
    //edit:can 20230908 72372 项目信息（客户模块）设置了布局规则，“项目阶段”字段变更为中标项目时，附件字段“附件(中标通知或其他附件等)”变为必填，大编辑状态下没问题，附件没上传无法保存，但是如果进入详情
    Popupobj.filejsondata = data.result.filejsondata;

    // }
    Popupobj.moduleData = data.result;

    Popupobj.createScrollDiv();
    Popupobj.show(data.result.content);
    DetailViewPage.moduleDetail(Popupobj);


    if(ld("#"+Popupobj.divid+" #modcommentblock_parenttd").length>0){
        //zkt 20230323 BUG0062618 kfbcrm 供应商联系记录 每次打开单据 评论的宽度都不一样
        var tmpwidth = (DetailViewPage.getWidth()*0.28)>400?400:DetailViewPage.getWidth()*0.28;
        //ld("#"+Popupobj.divid+" #modcommentblock_parenttd").find('#modcommentdiv').css('width',tmpwidth+'px');
        ld("#"+Popupobj.divid+" #modcommentblock_parenttd").find('#modcommentdiv').css('width','100%');
        //评论界面显示还是隐藏
        getJsScript('include/js/modules/ModComments/ModComments.js',function(){
            ModcommentblockRightload(Popupobj,module);
        })
    }

    if (ld("#"+Popupobj.divid+" #modcommentdiv").length>0){
        getJsScript('include/js/modules/ModComments/ModComments.js',function(){
            setModcommentFileUploaderEvent();
        })
    }

    //duan 20241009 详情页刷新时，要读取当前界面的高度，而不是最上层弹窗的高度
    //var lastcrmpopup =CrmPopup.getPopupObj("last");
    var lastcrmpopup = Popupobj;

    var DivCTable_detailmaxheight = lastcrmpopup.getMaxHeight()-20;
    if(ld('#'+Popupobj.divid+' .detail-relation-box').length > 0){
        DivCTable_detailmaxheight = DivCTable_detailmaxheight - ld('#'+Popupobj.divid+' .detail-relation-box').get(0).offsetHeight;
    }
    if(ld('#'+Popupobj.divid+' #related_keywords_field').length > 0){
        DivCTable_detailmaxheight = DivCTable_detailmaxheight - ld('#'+Popupobj.divid+' #related_keywords_field').get(0).offsetHeight;
    }
    ld('#'+Popupobj.divid+' .Tdcenter div.DivCTable').css('max-height',DivCTable_detailmaxheight+'px');
    ld('#'+Popupobj.divid+' .Tdcenter div.DivCTable').css('overflow-y','auto');
    ld('#'+Popupobj.divid+' .Tdcenter div.DivCTable').css('overflow-x','hidden');
    if(Popupobj.module == 'SocialPromotion'){
        ld('#'+Popupobj.divid+' .Tdcenter div.DivCTable').css('height',DivCTable_detailmaxheight+'px');
    }
    var previewimageobj_arr=ld("#"+Popupobj.divid+" [tag=detailview_image]");

    ld.each(previewimageobj_arr,function(){
        //edit:can 2020-12-04 0043576: （https://61mis.com/kfbcrm [^]）客户问题（王耀文），从费用报销单（EXP13）分录明细中点击关联的合同订单源单，点击合同订单的附件预览按钮没有反应（需要补丁）
        previewImage(ld(this).get(0));
    })

    // diony 2020-07-31
    // 0042220: （https://61mis.com/kfbtest/ [^]）单据查看详情界面，点击“上一条/下一条”后，单据弹出层中标签显示错误（销售线索模块测试）
    ld("#"+Popupobj.divid+" #"+Popupobj.divid+"_head strong").html(data.result.title);
    ld("#"+Popupobj.divid+" #"+Popupobj.divid+"_head #copy_icon").css('display','');

    if(cashtype=='cashbill'&&accountid>0)//收款单查看界面
    {
        time=10;
        if(relatelistobj==undefined)
            time=200;//cos加载
        setTimeout(function(){
            relatelistobj.showDebuctionList();

        },time)
    }
    var prevpopupobj=CrmPopup.getPopupObj('lastprev');
    //edit:can 2020-12-29 44016: （https://61mis.com/kfbcrm [^]）消息中心-点击未读内容-从详情页面退出应该更新一下信息（未读的提醒内容和右上角的消息条数）
    if(module=='Reminds'){
        //zkt 20240604 BUG20240603-46  消息提醒，我发送的，我翻到下面选择详情，进去后出来，列表会自动回到最上方
        if(ld('#'+prevpopupobj.module+'_navbar_div').length>0 && prevpopupobj.type == 'listpage'){
            ModelDataBindobj.setpropertyname='remindcount';
            var navbarobj = ld_NavBar.getCurNavBar(ld('#'+prevpopupobj.module+'_navbar_div').get(0));
            //zkt BUG0055732首页消息点击后，没有数据
            if(prevpopupobj.module == 'Reminds'&&navbarobj.NavBarItem != undefined &&navbarobj.NavBarItem.NavBarIndex  != undefined&&(navbarobj.NavBarItem.NavBarIndex==0 || navbarobj.NavBarItem.NavBarIndex==1)){
                //wyt 220824 XUQIU1000255 消息中心提醒功能优化（邹晓宇）221025 BUG0054693 221215 BUG0059939 消息提醒，点击头部弹出层中已读，右下角消息弹出层出现了，建议根据系统设置隐藏
                var isReminds_popupexist= ld('#reminds_popup').css('display');
                setRemindReaden(Popupobj.record,isReminds_popupexist);
                getListViewEntries_js('Reminds', 'start=1');//刷新页面
                // // 更新左侧分类 , 先注释后面有需求再还原
                // var listviewcategorytreeobj = ld('#'+prevpopupobj.divid).find('#ld-listview-reminds-categorytree');
                // if(listviewcategorytreeobj && listviewcategorytreeobj.length > 0){
                //     if(prevpopupobj.clsremindsobj && !empty(prevpopupobj.clsremindsobj)){
                //         prevpopupobj.clsremindsobj.reloadListCategory(prevpopupobj,listviewcategorytreeobj);
                //     }
                // }
                // // 刷新"未读"页签条数
                // if(navbarobj.NavBarItem.value == 108){
                //     if(!empty(prevpopupobj.ListViewNavbarlist)){
                //         var unreadobj = prevpopupobj.ListViewNavbarlist.find(obj => obj.value == 108);// 未读
                //         if(unreadobj){
                //             unreadobj.num = parseInt(unreadobj.num) - 1;
                //             if(unreadobj.num >= 0){
                //                 unreadobj.label = unreadobj.rawlabel+'（'+unreadobj.num+'）';
                //                 ld_NavBar.ShowNavBar(ld('#'+prevpopupobj.module+'_navbar_div').get(0),prevpopupobj.ListViewNavbarlist,prevpopupobj.ListViewNavBarObj.Options);
                //             }
                //         }
                //     }
                // }
            }
        }
        if(ld('#homestuffdiv #stuff_118').length>0){
            var navbarobj = ld_NavBar.getCurNavBar(ld('#homestuffdiv #stuff_118 #sales_target_tab').get(0));
            var curdata_type = navbarobj.NavBarItem.name;
            ld('#homestuffdiv #stuff_118').find('#stuff_118_pagenum').val(1);
            setRemindReaden(Popupobj.record,'');
            loadStuff(118,'customsheet',curdata_type);
        }
        if(prevpopupobj.module == 'Reminds' && prevpopupobj.type == 'relatelistpage' && !empty(prevpopupobj.relateid)){//相关信息中消息列表
            setRemindReaden(Popupobj.record,'');
            // 刷新相关信息列表
            var tmparra=new Array();
            var tmpobj=new AfterUpdatePrevPopupObjContent(module,getEmptyValueInfo(),tmparra);
            tmparra=[module];
            tmpobj.eachrefreshlistbyModules(tmparra);
        }
    }


    if(Popupobj.pagenum<=0||Popupobj.pagenum==undefined||prevpopupobj.module=='OftenUseReport'){
        //上一条，下一条
        ld("#"+Popupobj.divid+" [name=prevnextrecord]").css("display",'none');
    }
    else{
        ld("#"+Popupobj.divid+" [name=prevnextrecord]").css("display",'');
    }
    //zxm 20221121 标题栏样式和内容修改 左侧显示字段名称 字段值 上一页下一页
    if(Popupobj.prevrecord<=0){
        ld("#"+Popupobj.divid+" [tag=prevrecord]").removeClass("icon-left-active").addClass("icon-left-inactive");
        ld("#"+Popupobj.divid+" [tag=prevrecord]").attr('data-tip', '');
        ld("#"+Popupobj.divid+" [tag=prevrecord] b").addClass("cursorNotAllowed");
    }
    else
    {
        ld("#"+Popupobj.divid+" [tag=prevrecord]").removeClass("icon-left-inactive").addClass("icon-left-active");
        ld("#"+Popupobj.divid+" [tag=prevrecord]").attr('data-tip', arrJsPopLabel['PREVPAGE']);
        ld("#"+Popupobj.divid+" [tag=prevrecord] b").removeClass("cursorNotAllowed");
    }
    //zxm 20221121 标题栏样式和内容修改 左侧显示字段名称 字段值 上一页下一页
    if(Popupobj.nextrecord<=0){
        ld("#"+Popupobj.divid+" [tag=nextrecord]").removeClass("icon-right-active").addClass("icon-right-inactive");
        ld("#"+Popupobj.divid+" [tag=nextrecord]").attr('data-tip', '');
        ld("#"+Popupobj.divid+" [tag=nextrecord] b").addClass("cursorNotAllowed");
    }
    else{
        ld("#"+Popupobj.divid+" [tag=nextrecord]").removeClass("icon-right-inactive").addClass("icon-right-active");
        ld("#"+Popupobj.divid+" [tag=nextrecord]").attr('data-tip', arrJsPopLabel['NEXTPAGE']);
        ld("#"+Popupobj.divid+" [tag=nextrecord] b").removeClass("cursorNotAllowed");
    }
    setTimeout(function(){
        //明细界面推进内容宽度
        // var width = ld("#"+Popupobj.divid).width();
        //  ld("#"+Popupobj.divid+" .multi-step .modal-header").css("width", 0.98*width+"px");
    },200);

    //BUG0054393 点击查看单据详情时，有时会发生显示比例有误的情况(延时200当分录内容比较多时就会出现)
    /*setTimeout(function(popupobj){


        setProductDivWidth(popupobj);//设置列宽
    },5,Popupobj);*/
    //推进信息获取
    var advancedata = data.result.advancedata;
    if(!empty(advancedata)) {
        //如果自动化任务中设置了附件字段，则需要获取附件信息
        if (advancedata.filejsondata != undefined) {
            Popupobj.filejsondata = advancedata.filejsondata;
        }
        if (advancedata.advancefields != undefined) {
            Popupobj.advancefields = advancedata.advancefields;
        }
        Popupobj.advancedata = advancedata;
        //推进详情页显示流程图
        var module_advacne = advancedata.module_advacne;
        if (module_advacne.is_enable == 'yes') {
            Popupobj.AdvanceStageobj = AdvanceStage.getInstance(module, Popupobj.record);

            var advance_processobj = new cls_advance_process(Popupobj, Popupobj.module);
            var advance_process_info = data.result.advance_process_info;

            if (module_advacne.method == 'field') {
                advance_processobj.CreateDetailPreviewProcess(Popupobj, advance_process_info, module_advacne);
            }
        }
    }
    //用户模块，当前用户的部门信息
    if (data.result.cur_groupinfo != undefined) {
        Popupobj.cur_groupinfo = data.result.cur_groupinfo;
    }


    setBLockForLink();//附件区块帮助按钮
    Popupobj.setTimeCount();
    //字段 公式
    Popupobj.mainfieldformulaobj=new cls_mainfieldformula(data.result.mainfieldformula);
    Popupobj.mainfieldformulaobj.setPopupobj(Popupobj);
    Popupobj.mainfieldformulaobj.init();
    Popupobj.mainfieldformulaobj.CreatePageComputer();
    Popupobj.mainfieldformulaobj.setEvent();

    if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
    {
        //通讯录(pc端企业微信)

        cls_wxOpenDataobj.bindAllOpenDataByPopupObj(Popupobj);
    }


    DetailViewPage.setauto_wordwrap(Popupobj);

    // ljj 2023-08-22 BUG0070720 kfbcrm-单据详情页的头部的标题和x 还是title 应该改掉
    tooltip(ld("#"+Popupobj.divid).find('.tip-items-list'), {transition: true, time: 200});

}
//进入详情页面，判断给字段加自动换行
DetailViewPage.setauto_wordwrap = function(Popupobj){
    var fieldinfo_arr = Popupobj.fields;
    if(empty(fieldinfo_arr)){
        return;
    }

    var parentobj = ld("#"+Popupobj.divid+" .DetailContentTable").find('.DetailedTd2Info');
    if(empty(parentobj))
        return;

    fieldinfo_arr.forEach(function(field,index,fieldinfo_arr){


        var target_span = ld(parentobj).find('#dtlview_'+field.fieldname);

        if(target_span.length>0&&target_span.text() != '' && target_span.text() != '--'){
            var target_span_content = target_span.text();
            if(field.auto_wordwrap == 'no'){
                target_span.addClass('ld-overflow-hidden-listcontent');
                target_span.css('line-height','140%');

                if((field.uitype == 2 || field.uitype == 11 || field.uitype == 13 || field.uitype == 1101 || field.fieldname == 'express_no') && !(target_span[0].scrollWidth > target_span[0].clientWidth)){//处理客户名称,手机电话email后有图标会换行的情况
                    target_span.css('display','contents');
                }

                if(target_span[0].scrollWidth > target_span[0].clientWidth && field.uitype != 230 && field.uitype != 231){//判断是否内容溢出，并排除富文本框
                    target_span.addClass('tip-items-list').attr('data-tip',target_span_content).attr('data-direction','top').attr('data-type','position');
                }

                // 获取span所在td的最后一个子节点
                if(target_span.parent('td').length > 0 || target_span.parents('td').length > 0){
                    var lastNode;
                    if(target_span.parent('td').length > 0){
                        lastNode = target_span.parent('td')[0].lastChild;
                    }else{
                        lastNode = target_span.parents('td')[0].lastChild;
                    }

                    if (lastNode && (lastNode.nodeType == Node.TEXT_NODE)) {//若该子节点为空行则去除
                        lastNode.parentNode.removeChild(lastNode);
                    }
                }
            }
        }
        //文本区域
        if(field.bigtype!='textarea'&&field.bigtype!='longtextarea')
        {
            return false;
        }

        // var target_textarea =target_span; ld(parentobj).find('textarea[name='+field.fieldname+']').parent('div');
        var target_textarea_span =target_span// ld(parentobj).find('textarea[name='+field.fieldname+']').parent('div').prev("span");
        if(target_textarea_span.text() != '' && target_textarea_span.text() != '--'){
            var target_textarea_content = target_textarea_span.text();

            if(field.auto_wordwrap == 'no'){
                target_textarea_span.addClass('ld-overflow-hidden-listcontent');
                if(field.uitype != 230 && field.uitype != 231){//排除富文本框
                    target_textarea_span.addClass('tip-items-list').attr('data-tip',target_textarea_content).attr('data-direction','top').attr('data-type','position');
                }
            }
            /*
            if(target_textarea.length > 0){
                var nextNode = target_textarea[0].nextSibling;
                if (nextNode && nextNode.nodeType == Node.TEXT_NODE) {
                    nextNode.parentNode.removeChild(nextNode);
                }
            }
            */
        }
    })
}

DetailViewPage.moduleDetailFun = {
    PricePolicy: function () {
        AjaxJSPage('PricePolicy', 'include/js/modules/PricePolicy/PricePolicy.js');
        PricePolicy.getInstance().getDetailInstance().moduleDetail();
    },
    Products: function () {
        AjaxJSPage('ProductsDetail', 'include/js/modules/Products/ProductsDetail.js');
        ProductsDetail.moduleDetail();
    },
}
/** 分录 */
DetailViewPage.moduleDetail_DetailFun = {
    Products: function () {
        AjaxJSPage('PricePolicy', 'include/js/modules/PricePolicy/PricePolicy.js');
        PricePolicy.getInstance().getUseDetailInstance().moduleDetail();
    },
}

DetailViewPage.moduleDetail = function (popupObj) {
    var module = popupObj.module,
        detailModule = popupObj.detailmodule,
        moduleDetail = DetailViewPage.moduleDetailFun[module],
        moduleDetailPolicy = DetailViewPage.moduleDetail_DetailFun[detailModule];
    if(typeof moduleDetail === "function") {
        moduleDetail();
    }
    if(typeof moduleDetailPolicy === "function") {
        moduleDetailPolicy();
    }
}

//列表界面的查看按钮
function ListLinkClick(obj,event)
{
    StopEvent(event);
    // alert(ld(obj).attr("module"));
    EmptyProgressObjs();
    var module=ld(obj).attr("module");
    var record=ld(obj).attr('record');
    var lasturl=ld(obj).attr("lasturl");
    // $('allselectedboxes').value = record+';';
    var popupobj=CrmPopup.getPopupObj('last');
    if(popupobj!=undefined&&popupobj.type=='relatelistpage')
    {
        //edit:can 2021-01-05 43662: （本地8.3.4）客户管理>客户>相关信息>联系人>详情；在客户有多个联系人时，客户相关信息，打开联系人详情，右上角“上一个”“下一个”是灰色
        if(lasturl==undefined||lasturl=='undefined')
        {
            lasturl="";
        }
        lasturl+="&pagefrom=relateinfo";

    }
    ld(" .first-drawer-wrapper").remove();//关闭抽屉

    //工作汇报列表详情页增加删除按钮
    DetailViewPage.showpage(module,record,lasturl,{});
 /*   if (module == 'WorkReportList') {
        DetailViewPageExtraWorkReportList(module,record,lasturl,{});
    }else{
        DetailViewPage.showpage(module,record,lasturl,{});
    }*/

}
/**

 **/
function ListReferenceLinkClick(obj,event)
{
    StopEvent(event);
    var prevpopupobj=CrmPopup.getPopupObj('last');

    var module=ld(obj).attr("referencemodule");
    var record=ld(obj).attr('referencerecord');
    var lasturl=ld(obj).attr("lasturl");
    if(lasturl==undefined)
    {
        lasturl='';
    }
    if(prevpopupobj!=undefined)//42097: （61mis.com/kfbcrm）系统设置界面：点击右上角“个人设置”没反应
        prevpopupobj.lasturl=lasturl;//首页，待审批组件
    AjaxJSPage(module+"_js",'include/js/modules/'+module+'/'+module+'.js');
    EmptyProgressObjs();
    ld(" .first-drawer-wrapper").remove();//关闭抽屉
    if (module == 'WorkReportList') {
        DetailViewPageExtraWorkReportList(module,record,lasturl,{'pageto_module':module,'pageto_action':'DetailView','pageto_record':record});
    }else{
        DetailViewPage.showpage(module,record,lasturl,{'pageto_module':module,'pageto_action':'DetailView','pageto_record':record});
    }
}
function DetailViewReferenceLinkClick(jqueryobj,event)
{
    EmptyProgressObjs();
    var module=ld(jqueryobj).attr("referencemodule");
    var record=ld(jqueryobj).attr('referencerecord');
    var lasturl=ld(jqueryobj).attr("lasturl");
    if(lasturl==undefined)
    {
        lasturl='';
    }
    // ld(jqueryobj).attr("target","_blank");
    // ld(jqueryobj).attr("href","index.php?pageto_module="+module+"&pageto_action=DetailView&pageto_record="+record);
    // ld(jqueryobj).click();
    // 41805: （61mis.com/kfbcrm）财务管理>现金银行流水账>查询期间选择“本年”:点击“单据编号”，弹出层一直“转圈”，加载不出内容
    AjaxJSPage(module + "_js", 'include/js/modules/' + module + '/' + module + '.js');
    DetailViewPage.showpage(module,record,lasturl,{});
}
function OpenTabDetailView(jqueryobj,event){
    // EmptyProgressObjs();
    var module=ld(jqueryobj).attr("referencemodule");
    var record=ld(jqueryobj).attr('referencerecord');
    var lasturl=ld(jqueryobj).attr("lasturl");
    if(lasturl==undefined)
    {
        lasturl='';
    }
    ld(jqueryobj).attr("target","_blank");
    ld(jqueryobj).attr("href","index.php?pageto_module="+module+"&pageto_action=index&pageto_record="+record);
    ld(jqueryobj).click();
    DetailViewPage.showpage(module,record,lasturl,{});
}
function DetailViewPreVNext(obj)
{
    //上一条，下一条
    // var module=ld(obj).attr("module");
    //var record=ld(obj).attr(('record'));
    // var lasturl=ld(obj).attr('lasturl');
    // var pagestart=ld(obj).attr(("pagestart"));
    if(ld(obj).attr('repeat')=='yes'){//BUG0067658 xxy 2023-8-23 日程管理---列表视图---打开任意单据---切换到跟进记录页签---点击两下下一页按钮----会跳转回序时簿列表界面
        return false; //防止点击多次重复执行，导致弹出层定位错误
    }
    ld(obj).attr('repeat','yes');
    //BUG0072205 ls kfbcrm-销售订单-单据详情，相关信息栏点击收款计划，然后点击下一页，界面一直显示加载中
    var popupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);

    var prevpopupobj=CrmPopup.getPopupObj("lastprev");

    if(popupobj.related_module!='detailview'){
        //  041574: （61mis.com/kfbcrm）客户管理>客户模块>单据详情界面：相关点击“查看上下级关系”，弹出框点击“关闭”然后再点击右上角“下一条”一直“转圈”
        // CrmPopup.global_listPopupObj.pop();
        popupobj.related_module='detailview';
        CrmPopup.getPopupObj("last").CancelEvent();
    }
    var module=popupobj.module;
    var recordtag=ld(obj).attr("tag");
    var url="index.php?module="+module+"&action="+module+"Ajax&file=getPrevNextRecord&record="
        +popupobj.record+"&recordtag="+recordtag;
    if(recordtag=='prevrecord'&&parseInt(popupobj.prevrecord)<=0)
    {
        return false;

    }
    else if(recordtag=='nextrecord'&&parseInt(popupobj.nextrecord)<=0)
    {
        return false;
    }
    if(prevpopupobj.type.toLowerCase()=='quicksearch')
    {
        url+="&pagefrom=quicksearch";
    }

    if(typeof prevpopupobj.frommodule!=undefined &&prevpopupobj.frommodule=='Approve'){
        //alert(getSearchString("approvestatus",page_addurl));
        var pare_addurl=getSearchString("page_addurl",location.href)
        var approvestatus=getSearchString("approvestatus",pare_addurl);

        if(parseInt(approvestatus)==0){
            url+="&result_aprove=1";//待处理
        }
        else if(parseInt(approvestatus)==1){
            url+="&result_aprove=2";//已处理
        }
        else if(parseInt(approvestatus)==2){
            url+="&result_aprove=3";//我提交的
        }

    }
    if(recordtag=='nextrecord')
    {
        // alert(popupobj.nextrecord);
        popupobj.record=popupobj.nextrecord;
        DetailViewRelation.showpage_moduledetail(popupobj);

    }
    else
    {   popupobj.record=popupobj.prevrecord;
        DetailViewRelation.showpage_moduledetail(popupobj);
    }
    ld(obj).attr('repeat','no');
    return ;

    ldAjax(url,{},function(data){

        if(data.result.nextpagestart==undefined)
        {


            if(recordtag=='nextrecord')
            {
                ld("#"+popupobj.divid+" [tag=nextrecord]").css("color",'#999');
                DelProgressObjs();
                return false;

            }
        }
        if(data.result.prevrecordid==undefined)
        {


            if(recordtag=='prevrecord')
            {
                ld("#"+popupobj.divid+" [tag=prevrecord]").css("color",'#999');
                DelProgressObjs();
                return false;
            }
            //
        }
        if(recordtag=='nextrecord')
        {
            popupobj.pagenum=data.result.nextpagestart;
            popupobj.record=data.result.nextrecordid;
        }
        else{
            popupobj.pagenum=data.result.prevpagestart;
            popupobj.record=data.result.prevrecordid;
        }
        DetailViewRelation.showpage_moduledetail(popupobj);
        DelProgressObjs();
    })

    //  var pagestart=popupobj.pagenum;
    // popupobj.record=record;
    //popupobj.CancelEvent();
    /// DetailViewPage.showpage(module,record,lasturl+"&start="+pagestart,{});
    // DetailViewRelation.showpage_moduledetail(popupobj);


}
function showHideStatus(sname,anchorImgId)
{
    //防止冒泡事件 点击区块上的下拉框不要展开收起区块
    if(event.target.nodeName == 'SELECT' || event.target.nodeName == 'OPTION'){
        return ;
    }
    var popupobj=CrmPopup.getPopupObj("last");
    //wym 2023/1/10 name属性带有括号时，加引号
    oObj = ld("#"+popupobj.divid+" [name='"+sname+"']").get(0);
    //edit: xll 2023/03/30 BUG0062614 kfbcrm 采购订单---产品分录---查看界面无法收起
    if(sname == 'productsStaus'){
        Obj = ld("#"+popupobj.divid+" [name='"+sname+"']");
        if(Obj.length < 1)
            Obj = ld("#"+popupobj.divid+" #"+sname);
        oObj = Obj.get(0);
    }
    if(oObj.style.display == 'block' || empty(oObj.style.display))
    {
        oObj.style.display = 'none';
        if(anchorImgId !=null){
            var anchorobj = ld("#"+popupobj.divid+" [name='"+anchorImgId+"']");
            if(anchorobj.length<=0){

                var anchorobj = ld("#"+popupobj.divid+" #"+anchorImgId);
            }
            if(anchorobj.length >0){
                anchorobj.get(0).className = 'On';
                anchorobj.closest('.DivCName').addClass('ld-shadow-first');//diony 20230506 明细区块化，增加空格，目前不增加底部阴影
                //@edit:ljj,2023-08-10,reason:BUG0070737 kfbtest-销售线索-单据详情页面，区块展开提示浮显信息改成展开，且改成黑色的tip
                anchorobj.closest('.DivCName').addClass('tip-items-list');
                anchorobj.closest('.DivCName').attr('data-direction', 'left');
                anchorobj.closest('.DivCName').attr('data-type', 'position');
                anchorobj.closest('.DivCName').attr('data-tip', arrJsPopLabel['EXPANSION']);
                tooltip(anchorobj.find(".tip-items-list"), {transition: true, time: 200});

                var modcomment_highselectobj = anchorobj.closest('.DivCName').find('#modcomment_highselect');
                if (modcomment_highselectobj.length > 0){
                    anchorobj.closest('.DivCName').css('padding-right','10px');
                    modcomment_highselectobj.css('padding-right','0px');
                }
            }
        }
    }
    else
    {
        oObj.style.display = 'block';
        if(anchorImgId !=null){
            var anchorobj = ld("#"+popupobj.divid+" [name='"+anchorImgId+"']");
            if(anchorobj.length<=0){
                var anchorobj = ld("#"+popupobj.divid+" #"+anchorImgId);
            }
            if(anchorobj.length >0){
                anchorobj.get(0).className = '';
                anchorobj.closest('.DivCName').removeClass('ld-shadow-first');//diony 20230506 明细区块化，增加空格，目前不增加底部阴影
                //wym BUG0071812 单据查看详情界面，鼠标放在区块名称上，没有浮显“展开”和“收起”提示字样
                anchorobj.closest('.DivCName').attr('data-tip', arrJsPopLabel['COLLAPSE']);//@edit:ljj,2023-08-10,reason:BUG0070737 kfbtest-销售线索-单据详情页面，区块展开提示浮显信息改成展开，且改成黑色的tip

                var modcomment_highselectobj = anchorobj.closest('.DivCName').find('#modcomment_highselect');
                if (modcomment_highselectobj.length > 0){
                    modcomment_highselectobj.css('padding-right','0px');
                    anchorobj.closest('.DivCName').css('padding-right','10px');
                }
            }

        }
    }
}
//zxm 2021-0409 二维码字段类型 点击查看二维码生成二维码并弹窗
function viewQrCode(modulename,fieldid,uitype,recordid){
    var url = "index.php?module="+modulename+"&action="+modulename+"Ajax&file=getFieldQrCode";
    ldAjax(url,{fieldid:fieldid,uitype:uitype,recordid:recordid},function(data){
        if(data.code==-1){
            RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
        }
        else{
            var filename = data.result.path;
            filename = filename.replace(/(^\s*)|(\s*$)/g, "");
            var randnum = Math.random()*10000;
            randnum = randnum.toFixed(2);
            filename += '?a='+randnum;
            var confirm_str = '<div class="ld-pop-container">';
            confirm_str += '<table id="qrcode_content" class="" border="0" cellpadding="0" cellspacing="0" width="100%">';
            confirm_str += '<tr><td class="ctextalign">';
            confirm_str += '<img class="width180" src="' + filename + '">';
            confirm_str += '<p class="ctextalign marT16">' + arrJsPopLabel['SELFSERVICEQRCODEEXPLAIN'] + '</p>'
            confirm_str += '</td></tr>';
            confirm_str += "</table>";
            confirm_str += "</div>";

            var popupobj=CrmPopup.load("","","","LdPopWidth400px","","","","","");
            popupobj.prevshow();
            popupobj.setParams(data.result.title,"","","LdPopWidth400px","","","","","");
            popupobj.show(confirm_str);

            var popupobj = CrmPopup.getPopupObj('last');
            CrmPopup.center(ld("#" + popupobj.divid), popupobj);
            ld("#" + popupobj.divid).find('.msgDlg_left').hide();
        }
    });
}

//duan 2022-0111 二维码字段类型增加表单码字段
function viewFormQrCode(modulename,fieldid,uitype,recordid){
    var url = "index.php?module="+modulename+"&action="+modulename+"Ajax&file=getFormQrcode";
    var param = {'fieldid':fieldid,'uitype':uitype,'recordid':recordid};
    ldAjax(url,param,function(data){
        if(data.code==-1){
            RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
        }
        else{
            var filename = data.result.path;
            filename = filename.replace(/(^\s*)|(\s*$)/g, "");
            var confirm_str = '<div class="ld-pop-container">';
            //显示有效时间
            confirm_str +="<div class='ctextalign'><span name='endtime'>"+data.result.timestr+"</span>";
            confirm_str +="<a class='marL12' name='resetformcode' onclick='ResetFormcode()'>"+data.result.refreshstr+"</a>";
            if(data.result.is_admin == 1){
                //管理员显示设置按钮
                getJsScript('include/js/modules/Settings/qrcodeTemplate.js', function(){});
                confirm_str += "<a class='marL12' data-templateid='"+data.result.templateid+"' id='qrcodeTemplateEdit' onclick='qrcodeTemplate.Formcreate("+fieldid+",this,"+'"'+modulename+'"'+");'>"+arrJsPopLabel['Configure']+"</a>"
            }
            confirm_str += '</div>'
            confirm_str += '<table id="qrcode_content" class="" border="0" cellpadding="0" cellspacing="0" width="100%">';
            confirm_str += '<tr><td class="ctextalign">';
            confirm_str += '<img class="marT16 width180" style="height: 180px;" src="' + filename + '">';
            confirm_str += '<p class="ctextalign marT16">' + arrJsPopLabel['SELFSERVICEQRCODEEXPLAIN'] + '</p>';
            confirm_str += "</td></tr>";
            confirm_str += "</table>";
            confirm_str += "</div>";

            var popupobj=CrmPopup.load("","","","LdPopWidth400px",modulename,"","","","");
            popupobj.prevshow();
            popupobj.param = param;
            popupobj.module = modulename;
            popupobj.setParams(data.result.title,"","","LdPopWidth400px",modulename,"","","","");
            popupobj.show(confirm_str);
            popupobj.center();

            // var prevpopupobj = CrmPopup.getPopupObj('lastprev');
            // ld("#" + popupobj.divid).css('z-index',CrmPopup.zIndex);
            // CrmPopup.center(ld("#" + popupobj.divid), popupobj);
            //BUG0067471  zxm 20230601 单据详情界面，点击“查看二维码”，返回序时簿列表界面，点击“平铺查找”，功能按钮缺失
            ld("#" + popupobj.divid).find('.msgDlg_left').hide();
        }
    });
}
//刷新二维码
function ResetFormcode(){
    var popupobj = CrmPopup.getPopupObj('last');
    var url = "index.php?module="+popupobj.module+"&action="+popupobj.module+"Ajax&file=getFormQrcode";
    url += '&reset=yes';
    var param = popupobj.param;
    ldAjax(url,param,function(data){
        DelProgressObjs();
        if(data.code==1){
            ld("#"+popupobj.divid+" img").attr('src',data.result.path);
            ld("#"+popupobj.divid+" span[name=endtime]").text(data.result.timestr);
        }
    })
}
//查看提交日志
function FormQrCode_Viewlog(trackid,module,fieldid,uitype,record){
    var param = {};
    if(trackid >0){
        param['trackid'] = trackid;
    }else if(fieldid>0 && record>0){
        param['fieldid'] = fieldid;
        param['uitype'] = uitype;
        param['record'] = record;
    }else{
        return false;
    }

    var url = 'index.php?module='+module+'&action='+module+'Ajax&file=Show_FormCode_Viewlog';
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth900px",module,"","","","");
    crmPopupobj.prevshow();
    ldAjax(url,param,function(data){
        if(data.code == 1){
            crmPopupobj.setParams(data.result.title,"","","LdPopWidth900px",module,"",data.result.oktext,"",data.result.canceltext);
            crmPopupobj.show(data.result.content);
            ld("#"+crmPopupobj.divid+' .E_pbtnok').unbind('click').bind('click',function(){
                crmPopupobj.CancelEvent();
            });
            DelProgressObjs();
        }
    })
}
//ls 20221231  XUQIU1000922：表单码-分录可编辑
function FormQrCode_ViewlogDetail(obj) {
    var crmPopupobj=CrmPopup.getPopupObj('last');
    var module = crmPopupobj.module;
    var detaillog = ld(obj).attr('detaillog');//yes  分录
    var qrcodebasicid = ld('#'+crmPopupobj.divid+' [name=qrcodebasicid]').val();
    var param = {};
    param['qrcodebasicid'] = qrcodebasicid;
    param['detaillog'] = detaillog;

    var url = 'index.php?module='+module+'&action='+module+'Ajax&file=Show_FormCode_Viewlog';
    ldAjax(url,param,function(data){
        if(data.code == 1){
            crmPopupobj.show(data.result.content);

            //拖动及修改宽度
            crmPopupobj.relatelistsizeobj=new List_ResizeTable(crmPopupobj);
            crmPopupobj.relatelistsizeobj.setRelatedResizeTable_Init(module,'');
            // crmPopupobj.reSizePosition();//设置相关信息全屏

        }
        DelProgressObjs();
    })
}
//表单码修改日志分页
function FormQrCode_Viewlog_page(obj){
    var popupobj = CrmPopup.getPopupObj('last');
    var pagetype = ld(obj).attr('pagetype');
    var start = parseInt(ld(obj).attr('start'));
    var qrcodebasicid = ld('#'+popupobj.divid+' [name=qrcodebasicid]').val();
    var detaillog = ld('#'+popupobj.divid+' [name=detaillog]').val();

    if(pagetype == 'pagenum'){
        start = ld('#'+popupobj.divid+' #pagenum').val();
    }else if(start<=0){
        start = 1;
    }
    var param = {};
    param['start'] = start;
    param['qrcodebasicid'] = qrcodebasicid;
    param['detaillog'] = detaillog;
    var url = 'index.php?module='+popupobj.module+'&action='+popupobj.module+'Ajax&file=Show_FormCode_Viewlog';
    ldAjax(url,param,function(data){
        if(data.code == 1){
            DelProgressObjs();
            popupobj.show(data.result.content);
            //拖动及修改宽度
            popupobj.relatelistsizeobj=new List_ResizeTable(popupobj);
            popupobj.relatelistsizeobj.setRelatedResizeTable_Init(popupobj.module,'');
        }
    })
}

function DetailViewPageExtraWorkReportList(module,record,lasturl,{}) {
    var tmpwidth=DetailViewPage.getWidth();//parseInt((CrmPopup.getClientWidth()- getLeftMenuWidth())*0.9);
    var Popupobj=DetailViewPage.load("","","",tmpwidth*0.8,module,"","","","");

    // Popupobj.createScrollDiv();
    Popupobj.prevshow();
    var url = 'index.php?module='+module+'&action='+module+'Ajax&file=DetailView&record='+record+lasturl;
    Popupobj.record=record;
    ldAjax(url,{"namename": "uname", "namenameage": 18, "detailpagewidth": tmpwidth},function(data)
    {
        if(data.code==-1)
        {
            setTimeout(function(){
                Popupobj.CancelEvent();
                RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                return false;
            },200);

            DelProgressObjs();
            return false;
        }
        if(data.code==1)
        {
            Popupobj.lasturl=lasturl;
            Popupobj.setParams(data.result.title,"","","LdPopWidth950px",module,"","","","");
            Popupobj.WorkReportList_createScrollDiv();// ljj 2023-08-23 BUG0070733 kfbtest-工作汇报（列表），点击汇报详情，页面没有滚动条无法下滑
            Popupobj.workreportListShow(data.result.content);
        }
        DelProgressObjs();
    });
}

function CopyDetailPageTitle(obj){
    var modulename = ld(obj).data("module");
    var recordid = ld(obj).data("record");
    var url = "index.php?module="+modulename+"&action="+modulename+"Ajax&file=copyid";
    var param = {'recordid':recordid};

    ldAjax(url,param,function(data){
        if(data.code==-1){
            MessagePopup.TipOne_warning(data.msg)
        }else{
            // 赋值复制内容
            var copycontent = data.result.copycontent;
            // 创建input标签，将复制内容暂存为value值
            var copy_content = document.createElement("input");
            copy_content.setAttribute("value", copycontent);
            // 将input添加到body
            document.body.appendChild(copy_content);
            // 选中input的文本内容
            copy_content.select();
            // 执行复制
            document.execCommand("copy");
            // 删除input标签
            document.body.removeChild(copy_content);
            DelProgressObjs();
            MessagePopup.TipZero_success(arrJsPopLabel['SUCCESSFULLYCOPIED'])
        }
    });
}
function relevantInfoSearch(obj)
{
    getJsScript('include/js/multipingyin.js',function(){
        relevantInfoSearch_(obj);
    });

}
// wsh 2024-08-05 XUQIU20240702-03 相关信息下拉框界面增加搜索框
function relevantInfoSearch_(obj) {
    var popupobj = CrmPopup.getPopupObj("last");
    var divid = popupobj.divid;
    var searchobj = obj;//查询文本框
    if (searchobj == undefined) {
        return false;
    }
    var searchtext = searchobj.value;
    var uppersearch = searchtext.toLowerCase();
    var b = false;
    // var j = 0;
    var pingyin = false;
    var color = "#3B7CFF";
    var relevantInfoArr = [];
    var divobj = ld('#'+divid+' [name=detail-relation-btnmore]')
    relevantInfoArr = divobj.find('li[tag=more_related_liobj]');

    var relevantNameArr = [];
    for (var t = 0; t < relevantInfoArr.length; t++) {
        relevantNameArr.push(ld(relevantInfoArr[t]).attr("related_name"))
    }
    if (searchtext.length === 0){
        for (var h = 0; h < relevantInfoArr.length; h++) {
            var textSpan = ld(relevantInfoArr[h]).find("span[name=related_span_name]");
            var text = textSpan.text();
            textSpan.html(text);
        }
        ld(relevantInfoArr).show();
        return true;
    }
    relevantNameArr=relevantNameArr.filter(res=>{return res!="undefined"})

    for (var i = 0; i < relevantNameArr.length; i++) {
        pingyin = false;
        var arrRslt = makePy(relevantNameArr[i].toLowerCase());
        var textSpan = ld(relevantInfoArr[i]).find("span[name=related_span_name]");
        var text = textSpan.text();
        if (arrRslt !== undefined) {
            for (var k = 0; k < arrRslt.length; k++) {
                if (arrRslt[k].toLowerCase().indexOf(uppersearch) >= 0 || uppersearch === '') {
                    ld(relevantInfoArr[i]).show();
                    var index = arrRslt[k].toLowerCase().indexOf(uppersearch);
                    var indexText = text.substring(index, index + searchtext.length);
                    // 遍历字符数组并包裹特定索引的字符
                    ld(textSpan).html(text.replace(indexText, '<span style="color:' + color + ';">' + indexText + '</span>'));
                    pingyin = true;
                    b = true;
                    break;
                }
            }
            if (arrRslt.indexOf(uppersearch) >= 0 || true === pingyin || relevantNameArr[i].indexOf(searchtext) >= 0 ){
                b = true;
                ld(relevantInfoArr[i]).show();
                if (relevantNameArr[i].indexOf(searchtext) >= 0 ){
                    ld(textSpan).html(text.replace(searchtext, '<span style="color:' + color + ';">' + searchtext + '</span>'));
                }
            } else {
                ld(textSpan).html(text);
                ld(relevantInfoArr[i]).hide();
            }
        }
    }
    if (false === b) {
        divobj.find('li[tag=no-record]').show();
    } else {
        divobj.find('li[tag=no-record]').hide();
    }
}
// 详情页 - 通用按钮排序 弹出层
function setSortDetailButtons(obj,module,record) {
    var url = "index.php?module=Settings&action=SettingsAjax&file=LayoutBlockList&parenttab=Settings&ajax=true";
    var param = { 'sub_mode': 'SortDetailButtons', 'modulename': module, 'record': record, 'mode': 'set'};
    ldAjax(url,param,function(data){
        if (data.code == 1){
            var OkfunParamsObj = [module];
            var popupobj = CrmPopup.load(data.result.title,saveSortDetailButtons,'','LdPopWidth400px','Settings',OkfunParamsObj,data.result.oktext,'',data.result.canceltext)
            var btninfo_arr = data.result.btninfo_arr;
            // 穿梭框div
            var table_html = '<table id="SortDetailButtonsTable" class="ld-pop-container-second" style=""></table>';
            popupobj.show(table_html);
            var divobj = ld('#'+popupobj.divid);
            var tableobj = divobj.find('#SortDetailButtonsTable');
            var RightObj = btninfo_arr;
            var Drag_Transfer = new DragTransfer();
            var translabel = {
                available: '',
                selected: '',
                placeholder: arrJsPopLabel['PleaseEnterColumnSearchFor'],
            };
            Drag_Transfer.SetTranslabel(translabel);
            Drag_Transfer.right_Sortable = true;
            Drag_Transfer.SetDragTransfer(tableobj,"",RightObj,'set','320');
            popupobj.dragtransferObj = Drag_Transfer;
            ld('#rptContentLoading').hide();
        }
    });
}
// 详情页 - 通用按钮排序 保存
function saveSortDetailButtons(module) {
    var popupobj = CrmPopup.getPopupObj("last");
    var btnseq_arr = popupobj.dragtransferObj.getData('right','array');

    var url = "index.php?module=Settings&action=SettingsAjax&file=LayoutBlockList&parenttab=Settings&ajax=true";
    var param = { 'sub_mode': 'SortDetailButtons', 'modulename': module, 'mode': 'save', 'btnseq_str': JSON.stringify(btnseq_arr)};
    ldAjaxNoProgress(url,param,function(data){
        if (data.code == 1){
            popupobj.CancelEvent();
            MessagePopup.TipZero_success(arrJsPopLabel['SUCCESSFULLYSAVED']);
            var prevpopupobj = CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
            if(!empty(prevpopupobj)){
                DetailViewRelation.showpage_moduledetail(prevpopupobj);
            }
        }
    });
}

