var fun_setCrmPopupWindow = function(module,popup_url,selectmodule){

    if(module == 'Project' && selectmodule == ''){
        var confirm_str = arrJsPopLabel['SOURCEMODULE'] + arrJsPopLabel['CANOTEMPTY'];
        MessagePopup.TipOne_warning(confirm_str);
        return;
    }

    //wym 231205 XUQIU1002278 弹窗统一宽度
    // if((module=="PriceBooks" || module=="ShopSettings") &&selectmodule=="Products")
    // 		var crmPopupobj=CrmPopup.load("","","",CrmPopup.getSmallpopupwidth(),selectmodule,"",'none',"","");
    // else
    var crmPopupobj=CrmPopup.load("","","",CrmPopup.getSmallpopupwidth(),selectmodule,"",'none',"","");
    crmPopupobj.isShowFullscreen='yes';
    crmPopupobj.Fullscreencallback = function (switchtotype){
        if(crmPopupobj.listresizeobj != undefined){
            crmPopupobj.listresizeobj.setPopupResizeTable_Init(crmPopupobj.module, 'Ajax');
        }
        var fullscreen_obj = ld("#" + crmPopupobj.divid + "_fullscreen");
        var windowHeight = CrmPopup.getClientHeight();
        //弹窗标题固定为50px
        var minusheight= ld('#'+crmPopupobj.divid+'_head').outerHeight(true);
        //产品管理/产品套餐标签
        if(CrmPopup.isExistsObj(crmPopupobj.divid,'probom_div')){
            minusheight+=CrmPopup.findHtmlobj(crmPopupobj.divid,'probom_div').height();
        }
        //查询分类/搜索框/查找按钮
        if(CrmPopup.isExistsObj(crmPopupobj.divid,'resize_popupsearch_tableid')){
            minusheight+=CrmPopup.findHtmlobj(crmPopupobj.divid,'resize_popupsearch_tableid').height();
        }
        //确定按钮/分页信息
        var tableobj=CrmPopup.findHtmlobj(crmPopupobj.divid,'ListViewContents').find("table.small");
        var trobj =ld(tableobj).children('tbody').children('tr:not(:has(#hdScrolllistentries_yy))');//排除掉包含列表的tr
        if (trobj.length > 0) {
            trobj.each(function() {
                minusheight += ld(this).height();
            });
        }
        //表格内边距为10
        minusheight+=10;
        if(switchtotype=="fullscreen"){//全屏
            var headerheight = CrmPopup.findHtmlobj(crmPopupobj.divid,'resize_header_table_divid').height();
            CrmPopup.findHtmlobj(crmPopupobj.divid,'hdScrolllistentries_yy').css('height',windowHeight-minusheight);
            CrmPopup.findHtmlobj(crmPopupobj.divid,'resize_content_table_divid').css("height",windowHeight-minusheight-headerheight);
            if(CrmPopup.isExistsObj(crmPopupobj.divid,'ListViewContents')){
                CrmPopup.findHtmlobj(crmPopupobj.divid,'ListViewContents').css("max-height",windowHeight-minusheight);
            }
            if(ld('#'+crmPopupobj.divid+' #producttable').length>0){//群发短信-客户管理-搜索后页面
                ld('#'+crmPopupobj.divid+' #producttable').parent().css("height",windowHeight-minusheight);
            }
        }else{//缩小
            var preheight = parseInt(fullscreen_obj.attr('small-height'));
            if(preheight === null || preheight === undefined ){
                preheight= windowHeight*0.8 ;
            }
            CrmPopup.findHtmlobj(crmPopupobj.divid,'hdScrolllistentries_yy').css('height',preheight-minusheight);
            //wym 240110 BUG0077815 商城设置-首页专题设置-选择产品-弹出层中点击右上角放大，单据列表还是没有展开，下半部分显示空白
            if(CrmPopup.isExistsObj(crmPopupobj.divid,'resize_content_table_divid')){
                CrmPopup.findHtmlobj(crmPopupobj.divid,'resize_content_table_divid').css("height",400);
            }else if(CrmPopup.isExistsObj(crmPopupobj.divid,'ListViewContents')){
                CrmPopup.findHtmlobj(crmPopupobj.divid,'ListViewContents').css("max-height",350);
            }
        }
        //树结构调整高度
        if (ld('#'+crmPopupobj.divid).find('#isshowPopupModuleListTree') != undefined && ld('#'+crmPopupobj.divid).find('#isshowPopupModuleListTree').val() == 'yes'&&PopupModuleListTree!=undefined){
            PopupModuleListTree.setHeight();
            if (switchtotype!="fullscreen"){
                crmPopupobj.center();
            }
        }

    }
    crmPopupobj.prevshow();

    //35053: （1.6登录）选择“产品管理”弹出层界面：快速创建产品管理保存时，产品管理字段应直接显示快速创建的新产品字段值（报价单模块测试）
    crmPopupobj.type=selectDataPopup.type;

    crmPopupobj.advanceSearchDivid="dv_popup_listhighersearch"  ;
    var urlstring='index.php?';//+popup_url+'&selectmodule='+selectmodule;
    var moduletreeurl = '';
    if(module == 'Products'){
        moduletreeurl += '&isshowModuleListTree=yes'
    }
    if (module != 'Emails' && module != 'MassSMS' && !(module == 'CooperativeWork' && selectmodule == 'Accounts')){
        popup_url += "&setsequence=yes";
    }
    var  prevpopupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);

    popup_url += fun_setCrmPopupWindow.getSelectTypeSettingsUrl(selectmodule,prevpopupobj);
    ldAjax(urlstring,popup_url+'&selectmodule='+selectmodule+moduletreeurl, function(data){
        if(data.code==1)
        {
            if(data.result.fieldname!=undefined)
            {
                crmPopupobj.fieldname=data.result.fieldname;
            }
            else
            {
                crmPopupobj.fieldname='';
            }
            if(data.result.selectrelationfrom!=undefined)
            {
                crmPopupobj.selectrelationfrom=data.result.selectrelationfrom;
            }
            else
            {
                crmPopupobj.selectrelationfrom='';
            }

            crmPopupobj.advancefieldnames=data.result.advancefieldnames;//高级查询
            crmPopupobj.advft_criteria='';
            crmPopupobj.selectmodule=selectmodule;
            crmPopupobj.chooseproductid_arr=[];//edit:can 20220711 选择的产品ID
            crmPopupobj.chooseSourceInfo_arr=[];//选择原单
            crmPopupobj.chooseMainSourceInfo_arr=[];//选择原单的单据 @edit:ljj,2023-07-19,reason:XUQIU1000552 选择产品、选择源单，相关信息选择单据界面增加显示选中单据的记录条数
            crmPopupobj.url=urlstring.replace("popup=yes",'popup=no');
            crmPopupobj.currentmodule = module;
            //36711: （1.6）合同订单明细界面>关联创建出库单>将联系人或者客户字段擦除：擦除时会将源单也清除掉，编辑历史的出库单也有该问题，直接新增出库是正常的
            //	getJsScript('include/js/ListView.js',function(){
            //	getJsScript('include/js/picklist.js',function(){
            getJsScript('include/js/FieldDependencies.js',function(){
                crmPopupobj.setParams(data.result.title,'',"",CrmPopup.getSmallpopupwidth(),selectmodule,"","","","");//wym 231205 XUQIU1002278 产品弹窗统一宽度
                crmPopupobj.curr_row=data.result.curr_row;//选择的当前行（合同订单产品明细）
                crmPopupobj.contentdivid=crmPopupobj.divid+"_content";
                crmPopupobj.setInnerHtml=function(){


                    if(crmPopupobj.scrolldiv!="")
                    {

                        document.getElementById(crmPopupobj.divid).innerHTML=crmPopupobj.popupheadhtml+crmPopupobj.scrolldiv+"<div id='"+crmPopupobj.contentdivid+"'>"+crmPopupobj.htmlcontent+"</div></div>"+this.popupbottomhtml;
                    }
                    //else  if(module=="PriceBooks"&&selectmodule=="Products")
                    else
                        ld("#"+crmPopupobj.divid).html(crmPopupobj.popupheadhtml+"<div id='"+crmPopupobj.contentdivid+"'>"+crmPopupobj.htmlcontent+"</div>"+crmPopupobj.popupbottomhtml);




                };
                if(module=="PriceBooks"&&selectmodule=="Products")
                {
                    crmPopupobj.unit_price=data.result.UNIT_PRICE_ARRAY;
                    crmPopupobj.field_name=data.result.FIELD_NAME_ARRAY;
                    crmPopupobj.basicsearchheaders=data.result.basicsearchheaders;
                    crmPopupobj.datetimestr=data.result.datetimestr;
                    fun_ProductPriceBooks.getInstance().init();

                }
                // ls 2021-10-26 【ID1001109】增加“小程序商城设置”
                if(module=="ShopSettings"&&selectmodule=="Products")
                {
                    crmPopupobj.unit_price=data.result.UNIT_PRICE_ARRAY;
                    crmPopupobj.field_name=data.result.FIELD_NAME_ARRAY;
                    crmPopupobj.basicsearchheaders=data.result.basicsearchheaders;
                    crmPopupobj.datetimestr=data.result.datetimestr;
                    fun_ProductTopic.getInstance().init();

                }

                crmPopupobj.show(data.result.content);
                if(data.result.fullscreen=='yes'){
                    crmPopupobj.switchFullscreen();
                }
                var popuptype = ld('#'+crmPopupobj.divid).find('[name=popuptype]').val();
                crmPopupobj.popuptype = popuptype;
                //zkt 20221010 BUG0057125在费用报销单，单据分录中，点击‘源单’之后的加号，进入搜索界面，光标应该停留在搜索框（查找内容）里面。涉及合同订单里的选择源单后的框，合同订单里的团队成员
                if(ld("#"+crmPopupobj.divid+" [name=search_text]").length>0){
                    ld("#"+crmPopupobj.divid+" [name=search_text]").focus();
                }

                ListView_Page.fullwidth_divid = 'hdScrolllistentries_yy';
                ListView_Page.header_table_divid='resize_header_table_divid';//列头table所在div的id
                ListView_Page.header_tableid='resize_header_tableid';//列头所在table的id

                ListView_Page.content_tableid="resize_content_tableid";//内容所在table的id
                ListView_Page.content_table_divid="resize_content_table_divid";//内容table所在div的id
                var listresizeobj=new List_ResizeTable(crmPopupobj);
                crmPopupobj.listresizeobj=listresizeobj;
                listresizeobj.setPopupResizeTable_Init(selectmodule, 'Ajax');



                if(selectmodule == 'Products'){//BUG0072661 20230914 选产品套餐点不动
                    fun_setCrmPopupWindow.setProductEvent(module,selectmodule);
                }
                //@edit:ljj,2023-07-26,reason:BUG0070076 评论/提醒，新建界面，选择附件管理等单据弹出层界面，右上角不需要显示“已选n条记录”
                else if(module == 'ModComments' || module == 'PriceBooks' || module == 'Reminds'){
                    ld("#"+crmPopupobj.divid+" [name=choosebilltotal_div]").remove();
                }
                crmPopupobj.center();
                fun_setCrmPopupWindow.setCheckBoxEvent(crmPopupobj);
                fun_setCrmPopupWindow.setCheckBoxPropselected(crmPopupobj);
                //duan 20230407 增加特殊回调事件,用于重新绑定选择按钮事件
                fun_setCrmPopupWindow.OtherReturnFun(crmPopupobj);
                if(crmPopupobj.selectmodule != 'Products' && empty(crmPopupobj.isMultiple)){
                    // ljj 20231102 XUQIU1001640 选择源单弹出层界面，增加“选中某个单据的产品时自动勾选该单据所有明细行”参数（徐昱轩）
                    getJsScript('include/js/PopupProductListDoubleClicks.js',function(){
                        var PopupProductListDoubleClick= new PopupProductListDoubleClicks(crmPopupobj);
                        PopupProductListDoubleClick.setProductListDoubleClickEvent();
                    });
                    if (module != 'Emails' && module != 'MassSMS' && !(module == 'CooperativeWork' && selectmodule == 'Accounts')){
                        crmPopupobj.setsequence='yes';
                    }
                    // ljj 20231123 XUQIU1001991 选择源单优
                    fun_setCrmPopupWindow.setSelectCheckedInputByShift();
                }

                //txy XUQIU1001546为搜索框增加聚焦事件 单据上的选择产品弹窗中产品管理的基本查找
                ld('#'+crmPopupobj.divid+' .ld-listview-basicsearch input').unbind('focus').bind('focus',function(){
                    ld('#'+crmPopupobj.divid+' #basicsearchcolumns_real select').addClass('ld-border-color-3b7cff');
                    ld(this).addClass('ld-border-color-3b7cff');
                });
                ld('#'+crmPopupobj.divid+' .ld-listview-basicsearch input').unbind('blur').bind('blur',function(){
                    ld('#'+crmPopupobj.divid+' #basicsearchcolumns_real select').removeClass('ld-border-color-3b7cff');
                    ld(this).removeClass('ld-border-color-3b7cff');
                });
                //duan 20231011 价格表请求时需要当前行id,否则会找不到行
                if(selectmodule == 'PriceBooks'){
                    var curr_row = crmPopupobj.curr_row;
                    var tmp_url = '&rowid='+curr_row;
                    if(!empty(crmPopupobj.extral_url)){
                        crmPopupobj.extral_url += tmp_url;
                    }else{
                        crmPopupobj.extral_url = tmp_url;
                    }
                }
                fun_setCrmPopupWindow.setTotalTipContent();

                crmPopupobj.getSearch=function (){
                    fun_setCrmPopupWindow.callSearch('Basic');
                };

                //ljj 20240910 XUQIU1001487 客户增加【客户图谱】，类似于联系人图谱（戚涛） 选择相关客户
                if (crmPopupobj.popuptype == 'AccountsChart'){
                    var prepopupobj = CrmPopup.getPopupObj('lastprev');
                    crmPopupobj.relationshipChartobj = prepopupobj.relationshipChartobj;
                }

                // edit: xll 2024/10/24 XUQIU20240909-02 选择产品增加产品属性的选择（需求暂停）
                if(selectmodule === 'PriceBooks'){
                    try {
                        AjaxJSPage('ProductPropertyGroup', 'include/js/modules/ProductProperty/ProductPropertyGroup.js');
                        ProductPropertyGroup.getInstance(crmPopupobj).init();
                    }
                    catch (e) {
                        console.log(e)
                    }
                }

            });

        }else{
            cancelCrmPopup();
            ld('#rptContentLoading').hide();
            RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
        }
    })
    fun_setCrmPopupWindow._popup_url = popup_url;
}
fun_setCrmPopupWindow.save=function(){

}
//{*zxm20221212 新的基本查找组件*}
fun_setCrmPopupWindow.clearPopupLayerSearch=function(obj){
    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
    ld('#'+divid+' #basicSearchNewDiv').find('[name=search_text]').val('');
    //wym BUG0074062
    ld('#'+divid+' #basicSearchNewDiv').find('[name=search_text]').focus();
    //zkt 20240906 BUG20240906-25 {刘总提}关联选择单据弹窗，点击“X”的时候，不要直接刷新列表，点查询后才刷新
    //fun_setCrmPopupWindow.callSearch('Basic');
    if (popupobj.type == 'relatelistpage'){
        ld('#'+popupobj.divid+' [name=clearSearchBtn]').css('display','none');
    }
    ld(obj).hide();
}
fun_setCrmPopupWindow.searchSubmit=function(event,searchtype){
    var e = event || window.event;
    if(e.keyCode == 13){// Enter 鍥炶溅閿?                    if(searchtype == 'Basic'){
        fun_setCrmPopupWindow.callSearch('Basic');//鍩烘湰
    }


}
//弹窗基本查找 输入后控制清除按钮的显示
fun_setCrmPopupWindow.showClearBtn = function(obj){
    var value = ld(obj).val();
    var clearSearchBtnBtnObj = ld(obj).parent().find('#clearSearchBtn');
    if (empty(value)){
        clearSearchBtnBtnObj.hide();
    }else {
        clearSearchBtnBtnObj.show();
    }
}

fun_setCrmPopupWindow.callSearch = function(searchtype){

    //34443:
    /*if(empty(search_txt_val)){
        var confirm_str = arrJsPopLabel['Searchcannotbeempty'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}*/
    var urlstring = '';
    var create_editPopupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
    // ljj 20230920 XUQIU1000542 选择源单、选择产品、基本查找和高级查找增加“搜索历史”功能（参考单据列表高级查找搜索历史功能）
    var popupobj=CrmPopup.getPopupObj("last");
    //zkt 20240910 BUG20240910-40 销售发票选择销售订单源单时，高级查找按编号搜索“XSHT409 ”查询后，源单没有根据产品分录显示（kfbcrm也有这个问题）
    var selectpopupobj=popupobj;
    var searchhistory_urlstring = fun_setCrmPopupWindow.getUrlString(searchtype);
    if(searchhistory_urlstring==false){
        return false;
    }
    save_search_history(searchhistory_urlstring,popupobj.module);

    if(searchtype == 'Basic')
    {
        var prevpopupobj=CrmPopup.getPopupObj("lastprev");

        //  popupobj.chooseproductid_arr=[];
        //  popupobj.chooseSourceInfo_arr=[];//选择原单
        var divid=popupobj.divid;
        var module=CrmPopup.findHtmlobj(divid,'module').val();
        var frommodule = CrmPopup.findHtmlobj(divid,'frommodule').val();

        var search_fld_val= ld("#"+popupobj.divid+" [name=search_field]").val();// document.basicSearch.search_field[document.basicSearch.search_field.selectedIndex].value;
        var search_txt_val= encodeURIComponent( ld("#"+popupobj.divid+" [name=search_text]").val().replace(/\'/,"\\'"));
        urlstring = 'search_field='+search_fld_val+'&searchtype=BasicSearch&search_text='+search_txt_val;
        if (search_fld_val == 'all'){
            var optionvalues = ld("#"+popupobj.divid+" select[name=search_field]").eq(0).find(' option').map(function() {
                if(ld(this).val() != 'all'){
                    return ld(this).val();
                }
            }).get();
            var search_fld_val_arr=JSON.stringify(optionvalues);
            urlstring += '&search_field_arr='+search_fld_val_arr;
        }

        popupobj.searchtype=searchtype;
        if(!empty(popupobj.extral_url)){
            urlstring+=popupobj.extral_url;
        }
        // ljj 20231114 XUQIU1002047 选择源单界面，增加“已选单据合计”、“本页合计”和“全部合计”功能（邹晓宇）
        if (popupobj.selectmodule != 'Products' && empty(popupobj.isMultiple)){
            urlstring += "&gettotal=all";
            urlstring += "&isselectsearchdetail=yes";
            if (popupobj.setsequence == 'yes'){
                urlstring += "&setsequence=yes";
            }
            urlstring += "&chooseSourceInfoarr="+JSON.stringify(popupobj.chooseSourceInfo_arr);
        }
        //ljj 20240910 XUQIU1001487 客户增加【客户图谱】，类似于联系人图谱（戚涛） 选择相关客户
        if (popupobj.popuptype == 'AccountsChart'){
            urlstring += popupobj.relationshipChartobj.AccountsChartUrl;
        }

    }
    else if(searchtype=='Advanced')
    {

        var prevpopupobj=CrmPopup.getPopupObj("lastprev");
        //prevpopupobj.chooseproductid_arr=[];
        // prevpopupobj.chooseSourceInfo_arr=[];//选择原单
        prevpopupobj.searchtype=searchtype;
        var divid=prevpopupobj.divid;
        var module=CrmPopup.findHtmlobj(divid,'module').val();
        var frommodule = CrmPopup.findHtmlobj(divid,'frommodule').val();

        var advft_criteria = popupobj.advft_criteria;;
        var advft_criteria_groups = popupobj.advft_criteria_groups;;
        prevpopupobj.advft_criteria=popupobj.advft_criteria;;
        prevpopupobj.advft_criteria_groups=popupobj.advft_criteria_groups;;

        urlstring = 'advft_criteria='+encodeURIComponent(advft_criteria)+'&advft_criteria_groups='+advft_criteria_groups+'&';

        urlstring += 'searchtype=advance';

        urlstring+="&viewname="+CrmPopup.findHtmlobj(divid,'selectcustomview_'+module).val();

        if(!empty(prevpopupobj.extral_url)){
            urlstring+=prevpopupobj.extral_url;
        }
        // ljj 20231114 XUQIU1002047 选择源单界面，增加“已选单据合计”、“本页合计”和“全部合计”功能（邹晓宇）
        if (prevpopupobj.selectmodule != 'Products' && empty(prevpopupobj.isMultiple)){
            urlstring += "&gettotal=all";
            urlstring += "&isselectsearchdetail=yes";
            if (prevpopupobj.setsequence == 'yes'){
                urlstring += "&setsequence=yes";
            }
            urlstring += "&chooseSourceInfoarr="+JSON.stringify(prevpopupobj.chooseSourceInfo_arr);
        }
        selectpopupobj=prevpopupobj;

        //ljj 20240910 XUQIU1001487 客户增加【客户图谱】，类似于联系人图谱（戚涛） 选择相关客户
        if (prevpopupobj.popuptype == 'AccountsChart'){
            urlstring += prevpopupobj.relationshipChartobj.AccountsChartUrl;
        }
    }
    if(frommodule == 'CashBill'||frommodule == 'SendCashBill'){
        urlstring+='&selectmodule='+module;
    }
    //ljj 20240628 选择源单增加不允许重复
    var  editpopupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
    urlstring+=fun_setCrmPopupWindow.getSelectTypeSettingsUrl(selectpopupobj.selectmodule,editpopupobj);

    popuptype = CrmPopup.findHtmlobj(divid,'popup_type').val();
    act_tab = CrmPopup.findHtmlobj(divid,'maintab').val();
    urlstring += '&popuptype='+popuptype;
    urlstring += '&selectmoduleformore='+CrmPopup.findHtmlobj(divid,'selectmoduleformore').val();;
    urlstring += '&maintab='+act_tab;
    //zkt 20241111 BUG20241108-40 出差申请单，选客户界面，搜索客户名称后有记录数显示，但记录信息不显示
    if(popuptype == 'MultiplePopup'){
        urlstring = urlstring +'&query=true&file=Popup&module=Users&action=UsersAjax&ajax=true&selectmodule='+module+'&search=true&frommodule='+frommodule+'';
    }else{
        urlstring = urlstring +'&query=true&file=Popup&module='+module+'&action='+module+'Ajax&ajax=true&search=true&frommodule='+frommodule+'';
    }
    if(typeof popupobj.fieldname!= 'undefined' && !empty(popupobj.fieldname))
        urlstring += "&fieldname="+popupobj.fieldname;
    if(typeof popupobj.selectrelationfrom!= 'undefined' && !empty(popupobj.selectrelationfrom))
        urlstring += "&selectrelationfrom="+popupobj.selectrelationfrom;
    urlstring += fun_setCrmPopupWindow.gethiddenelements();
    //新增或者编辑界面的弹出层
    var createEditPopupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
    var  requestvalues="";
    var  sensitiverequestfield="";
    if(createEditPopupobj!=undefined)
    {
        //edit:can 20200825 42506: （https://61mis.com/kfbtest [^]）客户问题（邬丹华），群发邮件，选择【联系人】接收人email弹出层界面，搜索“销售负责人”关键字，点击【立即查找】点不动（需要补丁）

        var requestvaluearr = getPageValueByCrmPopupFields(createEditPopupobj);
        requestvalues = requestvaluearr['requestvalue'];
        sensitiverequestfield = requestvaluearr['sensitiverequestfield'];
    }
    record_id = CrmPopup.findHtmlobj(divid,'record_id').val();
    if(CrmPopup.findHtmlobj(divid,'account_id').val() != '')
    {
        urlstring+='&accountid='+CrmPopup.findHtmlobj(divid,'account_id').val();
    }
    if(CrmPopup.findHtmlobj(divid,'vendor_id').val() != '')
    {
        urlstring+='&vendorid='+CrmPopup.findHtmlobj(divid,'vendor_id').val();
    }
    urlstring+="&SearchScope=SmOwner_Search_All";
    urlstring += "&popupmode="+CrmPopup.findHtmlobj(divid,'popupmode').val();
    urlstring += "&callback="+CrmPopup.findHtmlobj(divid,'callback').val();
    if(CrmPopup.findHtmlobj(divid,'warehouse').val() > 0)
    {
        urlstring+='&wareid='+CrmPopup.findHtmlobj(divid,'warehouse').val();
    }
    if(CrmPopup.findHtmlobj(divid,'listval').val() != undefined)
    {
        urlstring +='&listval='+CrmPopup.findHtmlobj(divid,'listval').val();
    }
    if(record_id!='')
        urlstring += '&record_id='+record_id;
    urlstring += '&page_popup=yes';
    //zkt 模块树结构显示增加条件，获取树结构点击条件——选择产品界面
    //树结构
    if((ld("#"+divid +" #isshowPopupModuleListTree") != undefined && ld("#"+divid +" #isshowPopupModuleListTree").val() == 'yes'))
    {
        urlstring += '&isshowModuleListTree=yes';
        var tree_expand_display = ld('#' + divid+ ' #popupmoduletreelist_td').is(':hidden');
        var tree_expand = tree_expand_display?'no':'yes';
        urlstring += '&tree_expand='+tree_expand;
    }
    //关联创建的查询条件
    var lastprevpopupobj=prevpopupobj;//CrmPopup.getPopupObj("lastprev");

    if(lastprevpopupobj!=undefined&&lastprevpopupobj.fields!=undefined)
    {
        var requestvaluearr = getPageValueByCrmPopupFields(lastprevpopupobj);
        requestvalues = requestvaluearr['requestvalue'];
        sensitiverequestfield = requestvaluearr['sensitiverequestfield'];
        ld.each(lastprevpopupobj.fields,function(tmpindex,tmpfieldinfo){
            if(tmpfieldinfo.displaytype==3 &&tmpfieldinfo.bigtype=='reference'&&tmpfieldinfo.columnname=='pricebooksid')
            {
                //海格
                urlstring += "&pricebooksid="+ld("#"+lastprevpopupobj.divid+" [name=pricebooksid]").val();
                return false;
            }
        })
    }
    if(!empty(requestvalues)){
        urlstring+="&requestvalues="+encodeURIComponent(requestvalues);
    }
    if(!empty(sensitiverequestfield)){
        urlstring+="&sensitiverequestfield="+encodeURIComponent(sensitiverequestfield);
    }


    fun_setCrmPopupWindow.showData(urlstring);
}

fun_setCrmPopupWindow.getUrlString = function(searchtype){
    var popupobj=CrmPopup.getPopupObj('last');
    var prevpopupobj=CrmPopup.getPopupObj('lastprev');
    var SmOwnerSearchScope=ld("#"+popupobj.divid+" #SmOwnerSearchScope");
    if (!empty(SmOwnerSearchScope)){
        var searchScope = encodeURIComponent(SmOwnerSearchScope.options[SmOwnerSearchScope.options.selectedIndex].value);
    }else{
        var searchScope='';
    }
    var urlstring = '';
    if (searchtype == 'Basic'){
        var search_fld_val= ld("#"+popupobj.divid+" select[name=search_field]").val();
        var search_text_value = trim(ld("#"+popupobj.divid+" input[name=search_text]").val());
        var search_txt_val= encodeURIComponent(search_text_value);
        urlstring = 'search_field='+search_fld_val+'&searchtype=BasicSearch&search_text='+search_txt_val+'&';
        urlstring=urlstring+'SearchScope='+searchScope+'&';

        urlstring= urlstring+'viewid='+ld("#"+popupobj.divid+" #viewname").val()+'&';
        urlstring= urlstring+'viewname='+ld("#"+popupobj.divid+" #viewname").val()+'&';
        urlstring += 'searchfrom='+popupobj.type+'&';
    }
    else if(searchtype == 'Advanced'){
        var advanceFilterobj = popupobj.advanceFilterObj;
        if (advanceFilterobj != undefined && !advanceFilterobj.checkAdvancedFilter()){
            return false;
        }
        var advft_criteria=popupobj.advft_criteria;
        if (!empty(advft_criteria)){
            var advft_criteria_groups=popupobj.advft_criteria_groups;

            urlstring += '&advft_criteria='+encodeURIComponent(advft_criteria)+'&advft_criteria_groups='+advft_criteria_groups+'&';
        }
        urlstring=urlstring+'SearchScope='+searchScope+'&';

        urlstring= urlstring+'viewid='+ld("#"+prevpopupobj.divid+" #viewname").val()+'&';
        urlstring= urlstring+'viewname='+ld("#"+prevpopupobj.divid+" #viewname").val()+'&';
        urlstring += 'searchtype=advance&';
        urlstring += 'searchfrom='+prevpopupobj.type+'&';
    }
    var wareid = 0;
    if(ld("#"+popupobj.divid+" #wareid") != undefined && ld("#"+popupobj.divid+" #wareid").val() > 0){
        wareid = ld("#"+popupobj.divid+" #wareid").val();
    }
    urlstring += 'wareid='+wareid+'&';
    // var module = popupobj.module;
    // if(module == 'Approve'){
    // 	if(ld('#fromapprovemodule') != undefined){
    // 		urlstring += '&fromapprovemodule='+ld('#fromapprovemodule').val()+'&';
    // 	}
    // 	if(ld('#approvestatus') != undefined) {
    // 		urlstring += '&approvestatus='+ld('#approvestatus').val()+'&';
    // 	}
    // }
    return urlstring;
}

fun_setCrmPopupWindow.showData=function(urlstring){


    var popupobj=CrmPopup.getlastPopupObjByType(selectDataPopup.type);

    popupobj.url=urlstring;

    ldAjaxHtml('index.php?',urlstring,function (response) {
        DelProgressObjs();
        if(popupobj.searchtype=='Advanced' || popupobj.searchtype == 'advance')
        {
            CrmPopup.getPopupObj('last').CancelEvent();
            //popupobj=CrmPopup.getPopupObj('last');
        }
        CrmPopup.findHtmlobj(popupobj.divid,'ListViewContents').html(response);
        popupobj.center();
        //wym 231117 BUG0075666 全屏弹窗-点击搜索后,会切回缩小弹窗
        if(ld('#'+popupobj.divid+'_fullscreen')){
            var pop_switchtotype = ld('#'+popupobj.divid+'_fullscreen').attr('switchtotype');
            if(pop_switchtotype=='recovery'){
                popupobj.Fullscreencallback('fullscreen');
            }else{
                popupobj.Fullscreencallback('recovery');
            }
        }else{
            //wym 选择源单弹出层会自适应宽度，与全屏功能冲突
            popupobj.setSelectPopupListSize();
        }
        popupobj.listresizeobj.setPopupResizeTable_Init(popupobj.module, 'Ajax');
        fun_setCrmPopupWindow.setCheckBoxEvent(popupobj);
        fun_setCrmPopupWindow.setCheckBoxPropselected(popupobj);
        //duan 20230407 增加特殊回调事件,用于重新绑定选择按钮事件
        fun_setCrmPopupWindow.OtherReturnFun(popupobj);

        if(popupobj.selectmodule != 'Products' && empty(popupobj.isMultiple)){
            // ljj 20231102 XUQIU1001640 选择源单弹出层界面，增加“选中某个单据的产品时自动勾选该单据所有明细行”参数（徐昱轩）
            getJsScript('include/js/PopupProductListDoubleClicks.js',function(){
                var PopupProductListDoubleClick= new PopupProductListDoubleClicks(popupobj);
                PopupProductListDoubleClick.setProductListDoubleClickEvent();
            });
            // ljj 20231123 XUQIU1001991 选择源单优
            fun_setCrmPopupWindow.setSelectCheckedInputByShift();
        }
    })
}
fun_setCrmPopupWindow.setCheckBoxEvent=function(popupobj)
{

    ld("#"+popupobj.divid+" [name=selected_id]").unbind('click').bind("click",function(){
        //显示产品按照选择顺序
        fun_setCrmPopupWindow.setChooseInfo_arr(ld(this))
    })
    ld("#"+popupobj.divid+" [name=selected_all]").unbind('click').bind("click",function(){
        //显示产品按照选择顺序
        ld.each(ld("#"+popupobj.divid+' [name=selected_id]'),function(){
            fun_setCrmPopupWindow.setChooseInfo_arr(ld(this))
        })

    })
    ld("#"+popupobj.divid+" [name=select_all]").unbind('click').bind("click",function(){
        //显示产品按照选择顺序
        ld.each(ld("#"+popupobj.divid+' [name=selected_id]'),function(){
            fun_setCrmPopupWindow.setChooseInfo_arr(ld(this))
        })

    })
    if(module == 'ShopSettings'){ //BUG0068709 xxy 2023-7-26 商城设置模块的查询下拉框载入
        fun_ProductTopic.getInstance().basicsearchpop();
    }
}
fun_setCrmPopupWindow.setCheckBoxPropselected=function(popupobj){
    //

    ld.each(popupobj.chooseproductid_arr,function(tmpindex,tmpproductid){

        ld("#"+popupobj.divid+' [billinfo='+tmpproductid+"]").prop("checked",true);
        // ljj 20231107 BUG0075103 选择源单点击搜索等功能后，选中效果（底色）消失
        ld("#"+popupobj.divid+' [record='+tmpproductid+"]").attr('class','lvtColDataSelected');
    })
    ld.each(popupobj.chooseSourceInfo_arr,function(tmpindex,tmpinfo){
        //BUG0070075 出库单选择“工单管理”源单，勾选一条单据，翻页或者搜索查询后，会自动全选所有单据
        ld("#"+popupobj.divid+" tr[record="+tmpinfo.record+"]").find("[value="+tmpinfo.detailid+"]").prop("checked",true);
        // ljj 20231107 BUG0075103 选择源单点击搜索等功能后，选中效果（底色）消失
        ld("#"+popupobj.divid+" tr[record="+tmpinfo.record+"]").attr('class','lvtColDataSelected');
    })


    //@edit:ljj,2023-07-19,reason:XUQIU1000552 选择产品、选择源单，相关信息选择单据界面增加显示选中单据的记录条数
    fun_setCrmPopupWindow.setTotalTipContent();
}
fun_setCrmPopupWindow.setChooseInfo_arr=function(chkboxobj)
{
    var popupobj=CrmPopup.getPopupObj('last');
    if(popupobj.module=='Products')
    {
        AjaxJSPage('ProductPropertyGroup', 'include/js/modules/ProductProperty/ProductPropertyGroup.js');
        // edit: xll 2024/10/24 XUQIU20240909-02 选择产品增加产品属性的选择（需求暂停）
        var propertyGroupObj = ProductPropertyGroup.getInstance(popupobj);
        if(ld(chkboxobj).prop("checked"))
        {
            if(!popupobj.chooseproductid_arr.includes(ld(chkboxobj).attr("billinfo")))
                popupobj.chooseproductid_arr.push(ld(chkboxobj).attr("billinfo"));

            // edit: xll 2024/10/24 XUQIU20240909-02 选择产品增加产品属性的选择（需求暂停）
            propertyGroupObj.showPropertyGroup(chkboxobj);
        }
        else{
            ld.each(popupobj.chooseproductid_arr,function(tmpindex,tmpproductid){
                if(tmpproductid==ld(chkboxobj).attr("billinfo"))
                {
                    popupobj.chooseproductid_arr.splice(tmpindex,1);
                    return false;

                }
            })

            // edit: xll 2024/10/24 XUQIU20240909-02 选择产品增加产品属性的选择（需求暂停）
            propertyGroupObj.hidePropertyGroup(chkboxobj);
        }

        //@edit:ljj,2023-07-19,reason:XUQIU1000552 选择产品、选择源单，相关信息选择单据界面增加显示选中单据的记录条数
        fun_setCrmPopupWindow.setTotalTipContent();

    }
    else{
        //选择原单
        if(ld(chkboxobj).prop("checked"))
        {
            var detailid=ld(chkboxobj).attr("value");
            isfind='no';

            ld.each(popupobj.chooseSourceInfo_arr,function(tmpindex,tmpinfo){
                if(tmpinfo.detailid==detailid)
                {
                    //hzx 20240312 客户和供应商没有联系人的情况下不会选中
                    if((popupobj.module=='Accounts' || popupobj.module=='Vendors') && detailid == 0){}else{
                        isfind='yes';
                        return false;
                    }

                }
            })

            if(isfind=='no')
            {
                //有两种形式：ld(chkboxobj).attr("value") 1:3_203  2:3
                var record=ld(chkboxobj).attr("billinfo");
                if(record==undefined)
                {
                    var record_arr=ld(chkboxobj).attr("value").split("_")
                    record=record_arr[1];

                }

                popupobj.chooseSourceInfo_arr.push({'detailid':ld(chkboxobj).attr("value"),'record':record});
            }
        }
        else{
            ld.each(popupobj.chooseSourceInfo_arr,function(tmpindex,tmpinfo){
                if(tmpinfo.detailid==ld(chkboxobj).attr("value"))
                {

                    popupobj.chooseSourceInfo_arr.splice(tmpindex,1);
                    return false;

                }
            })
        }
        //@edit:ljj,2023-07-19,reason:XUQIU1000552 选择产品、选择源单，相关信息选择单据界面增加显示选中单据的记录条数
        popupobj.chooseMainSourceInfo_arr=[];
        for( var i=0;i<popupobj.chooseSourceInfo_arr.length;i++){
            if(!popupobj.chooseMainSourceInfo_arr.includes(popupobj.chooseSourceInfo_arr[i]['record'])){
                popupobj.chooseMainSourceInfo_arr.push(popupobj.chooseSourceInfo_arr[i]['record']);
            }
        }
        fun_setCrmPopupWindow.setTotalTipContent();

        if (ld("#"+popupobj.divid+" [name=curtotalpage]").length !=0 && empty(popupobj.isMultiple)){
            // ljj 20231114 XUQIU1002047 选择源单界面，增加“已选单据合计”、“本页合计”和“全部合计”功能（邹晓宇）
            fun_setCrmPopupWindow.setChooseCheckedInputAjax();
        }
    }

}
fun_setCrmPopupWindow.gethiddenelements = function()
{
    var popupobj=CrmPopup.getPopupObj("last");
    // alert(CrmPopup.getPopupObj('lastprev').module);
    var divid=popupobj.divid;
    var urlstring=''
    //chj 2021/1/14 43633: （https://61mis.com/kfbtest/ [^]）工具>产品管理明细界面>相关信息>合同订单新建>选择产品弹出层后，点击立即查找，所有产品前面的多选框消失
    var prevpopupobj=CrmPopup.getPopupObj('lastprev');
    var module='';
    if(prevpopupobj!=undefined)
        var module=CrmPopup.getPopupObj('lastprev').module;//CrmPopup.findHtmlobj(divid,'frommodule').val();
    if(popupobj.type!='selectsearchdetail')
    {
        //edit:can 20210201 44516: （https://61mis.com/kfbcrm [^]）客户问题（徐燕男），合同订单选择产品弹出层界面，高级查找按“产品名称”搜索后，选择产品弹出层界面产品名称前面的复选框没有显示（需要补丁）
        divid=CrmPopup.getPopupObj('lastprev').divid;
        module= CrmPopup.findHtmlobj(divid,'frommodule').val();
    }

    if(CrmPopup.findHtmlobj(divid,'select_enable').val() != '' && CrmPopup.findHtmlobj(divid,'select_enable').val() != undefined ){
        if(module == 'Products' && account_version == 'yiwen')
        {

        }
        else
            urlstring +='&select=enable';
    }
    divid=popupobj.divid;
    if( module == 'Products' && account_version == 'yiwen'){
        // @edit:ls @date:2020-7-8 @reason: 义文机电一键检测需求
        urlstring += '&account='+ account_version;
    }

    if(CrmPopup.findHtmlobj(divid,'curr_row').val() != '')
        urlstring +='&curr_row='+document.getElementById('curr_row').value;
    if(CrmPopup.findHtmlobj(divid,'fldname_pb').val() != '')
        urlstring +='&fldname='+getObj('fldname_pb').value;
    if(CrmPopup.findHtmlobj(divid,'productid_pb').val() != '')
        urlstring +='&productid='+getObj('productid_pb').value;
    if(CrmPopup.findHtmlobj(divid,'recordid').val() != '')
        urlstring +='&recordid='+getObj('recordid').value;
    if(CrmPopup.findHtmlobj(divid,'relmod').val() != '')
        urlstring +='&'+CrmPopup.findHtmlobj(divid,'relmod').attr('tag')+'='+CrmPopup.findHtmlobj(divid,'relmod').val();
    if(CrmPopup.findHtmlobj(divid,'relrecord_id').val() != '')
        urlstring +='&'+CrmPopup.findHtmlobj(divid,'relrecord_id').attr('tag')+'='+CrmPopup.findHtmlobj(divid,'relrecord_id').val();
    if(CrmPopup.findHtmlobj(divid,'popupform').val() != undefined && CrmPopup.findHtmlobj(divid,'popupform').val() != '')
        urlstring +='&form='+encodeURIComponent(CrmPopup.findHtmlobj(divid,'popupform').val());
    if(CrmPopup.findHtmlobj(divid,'forfield').val() != undefined && CrmPopup.findHtmlobj(divid,'forfield').val() != '')
    {
        urlstring +='&forfield='+encodeURIComponent(CrmPopup.findHtmlobj(divid,'forfield').val());

    }
    if(CrmPopup.findHtmlobj(divid,'srcmodule').val() != undefined && CrmPopup.findHtmlobj(divid,'srcmodule').val() != '')
    {
        urlstring +='&srcmodule='+encodeURIComponent(CrmPopup.findHtmlobj(divid,'srcmodule').val());

    }
    if(CrmPopup.findHtmlobj(divid,'forrecord').val() != undefined && CrmPopup.findHtmlobj(divid,'forrecord').val() != '')
        urlstring +='&forrecord='+encodeURIComponent(CrmPopup.findHtmlobj(divid,'forrecord').val());
    if(CrmPopup.findHtmlobj(divid,'currencyid').val() != null && CrmPopup.findHtmlobj(divid,'currencyid').val() != '')
        urlstring +='&currencyid='+CrmPopup.findHtmlobj(divid,'currencyid').val();
    // END
    var return_module = CrmPopup.findHtmlobj(divid,'return_module').val();
    if(return_module != '')
        urlstring += '&return_module='+return_module;
    return urlstring;
}


fun_setCrmPopupWindow.getListViewEntries_js = function(module,url)
{
    // ld('#rptContentLoading').show();
    var popupobj=CrmPopup.getPopupObj("last");
    var create_editPopupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
    var divid=popupobj.divid;
    var frommodule='';
    if(CrmPopup.findHtmlobj(divid,'frommodule').val() != undefined)
    {
        frommodule = CrmPopup.findHtmlobj(divid,'frommodule').val();
    }
    if(CrmPopup.findHtmlobj(divid,'popupfrommodule').val() != undefined)
    {
        frommodule = CrmPopup.findHtmlobj(divid,'popupfrommodule').val();
    }

    var popuptype = CrmPopup.findHtmlobj(divid,'popup_type').val();
    var urlstring ="module="+module+"&action="+module+"Ajax&file=Popup&ajax=true&"+url;

    if(typeof popupobj.fieldname!= 'undefined' && !empty(popupobj.fieldname))
        urlstring += "&fieldname="+popupobj.fieldname;// liushuai BUG0070805 服务合同-新增-“合同订单”选择页面，一开始显示有5页数据，点击下一页后，变成了2页(前后台都做了修改)

    urlstring +=fun_setCrmPopupWindow.gethiddenelements();
    var record_id = CrmPopup.findHtmlobj(divid,'record_id').val();
    search_fld_val= CrmPopup.findHtmlobj(divid,'search_field').val();
    search_txt_val=CrmPopup.findHtmlobj(divid,'search_text').val();
    if(popupobj.searchtype=='Basic')
    {
        if(search_txt_val != '')
            urlstring += '&query=true&search_field='+encodeURIComponent(search_fld_val)+'&searchtype=BasicSearch&search_text='+encodeURIComponent(search_txt_val);
    }
    else if(popupobj.searchtype=='Advanced')
    {
        var advft_criteria = popupobj.advft_criteria;;
        var advft_criteria_groups = popupobj.advft_criteria_groups;;
        //edit:can 20210513 045884: （http://corp.mdmedical.com.cn/index.php [^] ）（美迪医疗内镜维修）新建合同订单，点击选择源单为“验收单”，然后使用高级查找“源单类型”为“发票”，查出的结果点击下一页会出

        urlstring+= '&query=true&advft_criteria='+encodeURIComponent(advft_criteria)+'&advft_criteria_groups='+advft_criteria_groups+'&';

        urlstring += 'searchtype=advance';
    }

    urlstring += '&popuptype='+popuptype;
    if(record_id!='')
        urlstring += '&record_id='+record_id;
    var return_module = CrmPopup.findHtmlobj(divid,'return_module').val();
    if(module == 'Documents' && return_module == 'MailManager')
    {
        urlstring += '&callback=MailManager.add_data_to_relatedlist';
        urlstring += '&popupmode=ajax';
        urlstring += '&srcmodule=MailManager';
    }
    if(CrmPopup.findHtmlobj(divid,'warehouse').val() != undefined && CrmPopup.findHtmlobj(divid,'warehouse').val() > 0)
    {
        urlstring+='&wareid='+CrmPopup.findHtmlobj(divid,'warehouse').val();
    }
    if(frommodule!='')
    {
        urlstring=urlstring+'&frommodule='+frommodule;
    }
    if(module == 'SalesOrder' && (frommodule == 'SalesOrder' || frommodule == 'ServiceContracts')){
        //zkt 20230808 BUG0070805  销售订单模块，新建单据，选择租赁合同字段，点击进去，然后点击下一页，会出现乱码，如图。
        //zkt 20230808 先注销，
        //urlstring =urlstring+'&fieldname=salesorder_id';
    }
    if(CrmPopup.findHtmlobj(divid,'account_id').val()!=undefined && CrmPopup.findHtmlobj(divid,'account_id').val() > 0)
    {
        urlstring+='&accountid='+CrmPopup.findHtmlobj(divid,'account_id').val();
    }
    if(CrmPopup.findHtmlobj(divid,'vendor_id').val() != undefined &&CrmPopup.findHtmlobj(divid,'vendor_id').val() > 0)
    {
        urlstring += '&vendorid='+CrmPopup.findHtmlobj(divid,'vendor_id').val();
    }
    urlstring += '&listval='+CrmPopup.findHtmlobj(divid,'listval').val();
    urlstring += "&SearchScope=SmOwner_Search_All&viewname="+CrmPopup.findHtmlobj(divid,'viewname').val();
    urlstring += '&page_popup=yes';
    var  editpopupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
    //ljj 20240628 选择源单增加不允许重复
    urlstring+=fun_setCrmPopupWindow.getSelectTypeSettingsUrl(popupobj.selectmodule,editpopupobj);
    if(!empty(popupobj.extral_url)){
        urlstring+=popupobj.extral_url;
    }
    //zkt 模块树结构显示增加条件，获取树结构点击条件——选择产品界面
    if((ld("#"+divid +" #isshowPopupModuleListTree") != undefined && ld("#"+divid +" #isshowPopupModuleListTree").val() == 'yes'))
    {
        urlstring += '&isshowModuleListTree=yes';
        var tree_expand_display = ld('#' + divid+ ' #popupmoduletreelist_td').is(':hidden');
        var tree_expand = tree_expand_display?'no':'yes';
        urlstring += '&tree_expand='+tree_expand;
    }
    //关联创建的查询条件
    var lastprevpopupobj=CrmPopup.getPopupObj("lastprev");
    var requestvalues="{";
    /**
     * @edit:ls
     * @date:2020-7-9
     * @reason:0041680: （61mis.com/kfbcrm）营销>群发短信：选择“联系人”，点击“下一页”一直转圈
     * @description:因为群发短信的上一层不是新建或编辑弹窗，fields为undefined。
     */
    if(lastprevpopupobj!= undefined && lastprevpopupobj.fields != undefined && lastprevpopupobj.fields != 'undefined'){
        var requestvaluearr = getPageValueByCrmPopupFields(lastprevpopupobj);
        requestvalues = requestvaluearr['requestvalue'];
        var sensitiverequestfield = requestvaluearr['sensitiverequestfield'];
        ld.each(lastprevpopupobj.fields,function(tmpindex,tmpfieldinfo){
            if(tmpfieldinfo.displaytype==3 &&tmpfieldinfo.bigtype=='reference'&&tmpfieldinfo.columnname=='pricebooksid')
            {
                //海格
                urlstring += "&pricebooksid="+ld("#"+lastprevpopupobj.divid+" [name=pricebooksid]").val();
                return false;
            }
        });
    }
    urlstring+="&requestvalues="+requestvalues;
    urlstring+="&sensitiverequestfield="+sensitiverequestfield;

    // ljj 20231114 XUQIU1002047 选择源单界面，增加“已选单据合计”、“本页合计”和“全部合计”功能（邹晓宇）
    if (ld("#"+popupobj.divid+" [name=curtotalpage]").length !=0 && empty(popupobj.isMultiple)){
        urlstring += "&gettotal=all";
        urlstring += "&isselectsearchdetail=yes";
        urlstring += "&chooseSourceInfoarr="+JSON.stringify(popupobj.chooseSourceInfo_arr);
    }
    if (popupobj.selectmodule != 'Products' && empty(popupobj.isMultiple) && popupobj.setsequence == 'yes'){
        urlstring += "&setsequence=yes";
    }
    //ljj 20240910 XUQIU1001487 客户增加【客户图谱】，类似于联系人图谱（戚涛） 选择相关客户
    if (popupobj.popuptype == 'AccountsChart'){
        urlstring += popupobj.relationshipChartobj.AccountsChartUrl;
    }
    ldAjaxHtml('index.php',urlstring,function(ajaxhtml) {
        DelProgressObjs();
        CrmPopup.findHtmlobj(divid,'ListViewContents').html(ajaxhtml);
        //setPopContentHeight(module);

        //BUG0075884 lius 20231129 选择源单弹出层，翻页后宽度会重算导致从全屏变为缩小
        if(ld('#'+popupobj.divid+'_fullscreen')){
            var pop_switchtotype = ld('#'+popupobj.divid+'_fullscreen').attr('switchtotype');
            if(pop_switchtotype=='recovery'){
                popupobj.Fullscreencallback('fullscreen');
            }else{
                popupobj.Fullscreencallback('recovery');
            }
        }else{
            popupobj.setSelectPopupListSize();
        }

        popupobj.center();
        //edit:can 2020-10-29 43054: （61mis.com/kfbcrm）（施明程客户问题）合同订单模块新增界面>选择产品弹出层>翻到第二页：界面列宽无法拖动，在第一页的时候是可以拖动的。（需要补丁）
        popupobj.listresizeobj.setPopupResizeTable_Init(frommodule, 'Ajax');

        fun_setCrmPopupWindow.setCheckBoxEvent(popupobj);
        fun_setCrmPopupWindow.setCheckBoxPropselected(popupobj);
        //duan 20230407 增加特殊回调事件,用于重新绑定选择按钮事件
        fun_setCrmPopupWindow.OtherReturnFun(popupobj);
        if(popupobj.selectmodule != 'Products' && empty(popupobj.isMultiple)) {
            // ljj 20231102 XUQIU1001640 选择源单弹出层界面，增加“选中某个单据的产品时自动勾选该单据所有明细行”参数（徐昱轩）
            getJsScript('include/js/PopupProductListDoubleClicks.js', function () {
                var PopupProductListDoubleClick = new PopupProductListDoubleClicks(popupobj);
                PopupProductListDoubleClick.setProductListDoubleClickEvent();
            });
            // ljj 20231123 XUQIU1001991 选择源单优
            fun_setCrmPopupWindow.setSelectCheckedInputByShift();
        }
    });
}


fun_setCrmPopupWindow.set_return_specific = function(entiyid, entityname, fieldname) {
    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
    var module=CrmPopup.findHtmlobj(divid,'module').val();
    var frommodule=CrmPopup.findHtmlobj(divid,'frommodule').val();
    var prevpopupobj=CrmPopup.getPopupObj('lastprev');
    var prevdivid = '';
    if(prevpopupobj != undefined){
        prevdivid=prevpopupobj.divid;
    }


    if(!empty(fieldname)){
        CrmPopup.findHtmlobj(prevdivid,fieldname).val(entiyid);
        CrmPopup.findHtmlobj(prevdivid,fieldname+'_name').val(entityname);
    }else{
        if(module == 'SalesOrder' && frommodule == 'SalesOrder'){
            if(CrmPopup.findHtmlobj(prevdivid,'salesorder_name').val() != undefined){
                CrmPopup.findHtmlobj(prevdivid,'salesorder_name').val(entityname);
            }
            if(CrmPopup.findHtmlobj(prevdivid,'salesorder_id').val() != undefined){
                CrmPopup.findHtmlobj(prevdivid,'salesorder_id').val(entiyid);
            }
        }else {
            //if(module == 'Accounts' || module == 'Contacts' || module == 'Products' || module == 'Vendors')
            if(window.setContactInfo != undefined){
                if(module == 'Contacts'){
                    window.setContactInfo(entiyid, entityname);
                }else if(module == 'Accounts'){
                    window.setAccountInfo(entiyid, entityname);
                }else if(module == 'Products'){
                    window.setProductsInfo(entiyid, entityname);
                }
            }
            if(!empty(prevdivid)){
                var frommodule = CrmPopup.findHtmlobj(prevdivid,'module').val();
                if(frommodule == 'Attachment'||frommodule=='ModComments'||frommodule == 'Reminds'){
                    CrmPopup.findHtmlobj(prevdivid,'related_to_name').val(entityname);
                    CrmPopup.findHtmlobj(prevdivid,'related_to').val(entiyid);
                    CrmPopup.findHtmlobj(prevdivid,'related_to_name').css('cursor','not-allowed');
                }else{
                    if(module == 'Accounts'){
                        CrmPopup.findHtmlobj(prevdivid,'accounts_name').val(entityname);
                        CrmPopup.findHtmlobj(prevdivid,'account_id').val(entiyid);
                        CrmPopup.findHtmlobj(prevdivid,'accounts_name').css('disabled',true);
                    }else if(module == 'Contacts'){
                        CrmPopup.findHtmlobj(prevdivid,'contacts_name').val(entityname);
                        CrmPopup.findHtmlobj(prevdivid,'contact_id').val(entiyid);
                        CrmPopup.findHtmlobj(prevdivid,'contacts_name').css('disabled',true);
                    }else if(module == 'Products'){
                        CrmPopup.findHtmlobj(prevdivid,'products_name').val(entityname);
                        CrmPopup.findHtmlobj(prevdivid,'product_id').val(entiyid);
                    }
                }
            }
        }
    }

    //添加布局规则验证  //ls 2021202 BUG0059404 客户、联系人相关信息->工作汇报列表，选择关联“产品管理”后，选择产品管理弹窗没有关闭
    if (typeof prevpopupobj != "undefined" && typeof prevpopupobj.fieldruleobj != 'undefined')
        prevpopupobj.fieldruleobj.CheckReLoadPopup();
    popupobj.CancelEvent();
}
fun_setCrmPopupWindow.VT_disableFormSubmit = function(evt) {
    var evt = (evt) ? evt : ((event) ? event : null);
    var node = (evt.target) ? evt.target : ((evt.srcElement) ? evt.srcElement : null);
    if ((evt.keyCode == 13) && (node.type=='text')) {
        node.onchange();
        return false;
    }
    return true;
}
//请求结束后执行的事件，用于其他地方调用
fun_setCrmPopupWindow.OtherReturnFun = function (popupobj){
    //duan 20230407 增加特殊回调事件,用于重新绑定选择按钮事件
    if(!empty(popupobj.Multipleobj)){
        popupobj.Multipleobj.showPopupAfter();
    }
}

//产品套餐对象
var bom;
/**
 选择产品和产品套餐切换按钮事件
 **/
function chooseProductSwitch(obj,selectmodule){

    if(obj.attr('class') == "ld-ui-tabs-active"){
        return false;
    }
    var tag = obj.attr('tag');
    var url = window.location.search;
    ld('#rptContentLoading').show();
    var popupobj=CrmPopup.getPopupObj('last');
    // popupobj.chooseproductid_arr=[];
    // popupobj.chooseSourceinfo_arr=[];
    var probom_divobj=ld('#'+popupobj.divid+" [name=probom_div]");

    ld(probom_divobj).find(' .ld-ui-tabs-nav li').each(function(){
        if(ld(this).attr('tag') == tag){
            ld(this).attr('class','ld-ui-tabs-active');
        }
        else{
            ld(this).attr('class','');
        }
    });

    var beforemodule="";
    var module="";
    if(tag==1||tag==3){
        module='Products';
        beforemodule="Productbom";
        popupobj.module='Products';
        popupobj.beforemodule="Productbom";
        popupobj.refreshdata='no';
    }
    else if(tag==2){
        module="Productbom";
        beforemodule="Products";
        popupobj.module="Productbom";
        popupobj.beforemodule="Products";
        popupobj.refreshdata='yes';
    }

    var viewid=popupobj.searchs[module].viewid;
    var search_field=popupobj.searchs[module].search_field;
    var search_text=popupobj.searchs[module].search_text;
    var pagenum=popupobj.searchs[module].pagenum;

    popupobj.searchs[beforemodule].viewid=ld("#"+popupobj.divid+" [name=selectcustomview_"+beforemodule+"]").val();
    popupobj.searchs[beforemodule].search_field=ld("#"+popupobj.divid+" [name=search_field]").val();
    popupobj.searchs[beforemodule].search_text=ld("#"+popupobj.divid+" [name=search_text]").val();
    popupobj.searchs[beforemodule].pagenum=ld("#"+popupobj.divid+" [name=pagenum]").val();

    var sUrl = fun_setCrmPopupWindow._popup_url.replace("searchvalue","chenghuangjian");

    //zkt 20240325 BUG20240313-71  服务合同选产品套餐界面，搜索数据后，操作列显示阴影
    popupobj.extral_url = '&prodbomtag_d='+tag;
    sUrl = sUrl + popupobj.extral_url;

    if(viewid>0){
        sUrl+="&viewname="+viewid;
    }
    sUrl+="&start="+pagenum;
    if(trim(search_text)!=""){
        sUrl+="&search_field="+search_field+"&search_text="+search_text+"&searchtype=BasicSearch";
    }

    var divid=popupobj.divid;
    var urlstring=sUrl+'&selectmodule='+selectmodule;
    if(tag==3){
        //工单管理选择‘近期使用’页签时，显示该产品近期使用的配件信息
        urlstring +='&worksheetinfo=recentuse';
    }
    popupobj.url=urlstring.replace("popup=yes",'popup=no')+"&ajax=yes";
    ldAjax('index.php?'+urlstring,'',function(data){
        if(data.code==1){
            ld('#rptContentLoading').hide();

            //ls 20230724 BUG0069602 单据分录选择产品界面，点击“产品套餐”，再单击“产品管理”，树结构展开、收起点击无效
            // document.getElementById(popupobj.contentdivid).innerHTML=data.result.content;
            ld('#'+popupobj.contentdivid).html(data.result.content);

            probom_divobj=ld('#'+popupobj.divid+" [name=probom_div]");//edit:can 20200729 需要重新获取，否则无法来回切换tab页签
            ld(probom_divobj).find(' .ld-ui-tabs-nav li').click(function(){

                chooseProductSwitch(ld(this),selectmodule);
            });
            popupobj.advancefieldnames=data.result.advancefieldnames;//高级查询
            popupobj.advft_criteria='';

            popupobj.listresizeobj.setPopupResizeTable_Init(selectmodule,'Ajax');

            if(popupobj.moduletreeobj!=undefined){
                PopupModuleListTree.listfirst=1;
                PopupModuleListTree.listparams={CustomViewObj:"",viewid:0};
                PopupModuleListTree.nowdepth=0;
                PopupModuleListTree.nodecount=[];
                PopupModuleListTree.setEvent();
                PopupModuleListTree.init();
                if(tag==1){
                    PopupModuleListTree.module='Products';
                }
                else if(tag==2){
                    PopupModuleListTree.module='Productbom';
                }
                else if(tag==3){

                    PopupModuleListTree.listfirst=2;
                }
            }
            if(tag==2){
                if(dynamicJsScript["Productbom_js"]!=1){
                    var oS = document.createElement('script');
                    oS.id="Productbom_js";
                    //防止重复加载
                    oS.src = "include/js/modules/Productbom/Productbom.js?v="+Math.random();
                    document.getElementById(popupobj.divid).appendChild(oS);

                    oS.onload=oS.onreadystatechange=function(){
                        if(!this.readyState||this.readyState=='loaded'||this.readyState=='complete'){
                            dynamicJsScript["Productbom_js"] = 1
                            bom = new ProductBomEvent();
                        }
                    }
                }
                else{
                    bom = new ProductBomEvent();
                }
            }
            if(tag==3){
                //近期使用页签中隐藏搜索功能
                ld("#"+divid+" div[class=Category]").hide();
                ld("#"+divid+" table[class=homePageMatrixHdr]").hide();
            }
            //txy XUQIU1001546为搜索框增加聚焦事件 单据上的选择产品弹窗中产品套餐的基本查找
            ld('#'+divid+' .ld-listview-basicsearch input').unbind('focus').bind('focus',function(){
                ld('#'+divid+' #basicsearchcolumns_real select').addClass('ld-border-color-3b7cff');
                ld(this).addClass('ld-border-color-3b7cff');
            });
            ld('#'+divid+' .ld-listview-basicsearch input').unbind('blur').bind('blur',function(){
                ld('#'+divid+' #basicsearchcolumns_real select').removeClass('ld-border-color-3b7cff');
                ld(this).removeClass('ld-border-color-3b7cff');
            });
            fun_setCrmPopupWindow.setCheckBoxEvent(popupobj);
            fun_setCrmPopupWindow.setCheckBoxPropselected(popupobj);
            if(popupobj.selectmodule != 'Products' && empty(popupobj.isMultiple)) {
                // ljj 20231102 XUQIU1001640 选择源单弹出层界面，增加“选中某个单据的产品时自动勾选该单据所有明细行”参数（徐昱轩）
                getJsScript('include/js/PopupProductListDoubleClicks.js', function () {
                    var PopupProductListDoubleClick = new PopupProductListDoubleClicks(popupobj);
                    PopupProductListDoubleClick.setProductListDoubleClickEvent();
                });
                // ljj 20231123 XUQIU1001991 选择源单优
                fun_setCrmPopupWindow.setSelectCheckedInputByShift();
            }
            //点击产品套餐高度没有重新计算
            if(ld('#'+popupobj.divid+'_fullscreen')){
                var pop_switchtotype = ld('#'+popupobj.divid+'_fullscreen').attr('switchtotype');
                if(pop_switchtotype=='recovery'){
                    popupobj.Fullscreencallback('fullscreen');
                }else{
                    popupobj.Fullscreencallback('recovery');
                }
            }else{
                popupobj.setSelectPopupListSize();
            }
        }
    })
}

fun_setCrmPopupWindow.setProductEvent = function(module,selectmodule){
    var popupobj=CrmPopup.getPopupObj("last");
    popupobj.searchs=[];
    popupobj.searchs["Products"]={};
    popupobj.searchs["Products"].viewid=0;
    popupobj.searchs["Products"].search_field="";
    popupobj.searchs["Products"].search_text="";
    popupobj.searchs["Products"].pagenum=1;
    popupobj.searchs["Productbom"]={};
    popupobj.searchs["Productbom"].viewid=0;
    popupobj.searchs["Productbom"].search_field="";
    popupobj.searchs["Productbom"].search_text="";
    popupobj.searchs["Productbom"].pagenum=1;
    var parentcancelevent=popupobj.CancelEvent;
    popupobj.CancelEvent=function()
    {


        if(popupobj.selectproductbtn!=undefined)
        {

            //edit:can 2021020444570: （61mis.com/kfbcrm）销售管理-合同订单-新建；产品分录中，选择2个以上产品时，多次点击确定按钮，除第一个产品，其他产品会在分录中多次录入
            popupobj.selectproductbtn=0;
        }
        parentcancelevent.apply(this,[]);
    }
    //选择产品的tab页签事件
    ld('#'+popupobj.divid+' [name=probom_div]').find(' .ld-ui-tabs-nav li').click(function(){

        chooseProductSwitch(ld(this),selectmodule);
    });
}

/*
editer:ljj
time:20231114
reason:XUQIU1002047
content:选择源单界面，增加“已选单据合计”、“本页合计”和“全部合计”功能（邹晓宇）
note:
1.popupobj.chooseCheckedInputAjaxobj_arr :存储“已选单据合计”请求ajaxobj的全局函数
2.ajax对象的readyState==4为请求已完成，0-3都未完成请求
3.abort()终止请求
*/
fun_setCrmPopupWindow.setChooseCheckedInputAjax=function (){
    var popupobj=CrmPopup.getPopupObj('last');
    var frommodule = CrmPopup.findHtmlobj(popupobj.divid,'frommodule').val();
    var urlstring="module="+popupobj.selectmodule+"&action="+popupobj.selectmodule+"Ajax&file=Popup&ajax=true";
    urlstring += "&gettotal=select";
    urlstring += "&isselectsearchdetail=yes";
    urlstring += "&frommodule="+frommodule;
    if (popupobj.setsequence == 'yes'){
        urlstring += "&setsequence=yes";
    }
    var param_url='';
    var createEditPopupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
    if(createEditPopupobj!=undefined)
    {
        //edit:can 20200825 42506: （https://61mis.com/kfbtest [^]）客户问题（邬丹华），群发邮件，选择【联系人】接收人email弹出层界面，搜索“销售负责人”关键字，点击【立即查找】点不动（需要补丁）

        var  requestvalues="";
        var  sensitiverequestfield="";
        var requestvaluearr = getPageValueByCrmPopupFields(createEditPopupobj);
        requestvalues = requestvaluearr['requestvalue'];
        sensitiverequestfield = requestvaluearr['sensitiverequestfield'];

        param_url+="&requestvalues="+encodeURIComponent(requestvalues);
        param_url+="&sensitiverequestfield="+encodeURIComponent(sensitiverequestfield);
    }
    urlstring += "&chooseSourceInfoarr="+JSON.stringify(popupobj.chooseSourceInfo_arr);
    //多次连续请求终止之前的请求
    // if(popupobj.chooseCheckedInputAjaxobj_arr.length>0 && popupobj.chooseCheckedInputAjaxobj_arr.last().readyState != 4){
    //     popupobj.chooseCheckedInputAjaxobj_arr.last().abort();
    // }
    if ( fun_setCrmPopupWindow.choose_checked_input_ajaxobj){
        fun_setCrmPopupWindow.choose_checked_input_ajaxobj.abort();
    }
    if (popupobj.chooseSourceInfo_arr.length == 0){
        ld("#"+popupobj.divid+" [name=totalofselecteddocuments]").remove();
        return false;
    }
    fun_setCrmPopupWindow.choose_checked_input_ajaxobj=ldAjaxNoProgress("index.php?"+urlstring,param_url,function (data){
        if (data.code == 1){
            ld("#"+popupobj.divid+" [name=totalofselecteddocuments]").remove();
            ld("#"+popupobj.divid+" [name=curtotalpage]").before(data.result.content);
        }
    });
    // popupobj.chooseCheckedInputAjaxobj_arr.push(choose_checked_input_ajaxobj);
}

/*
* editor:ljj
* time:20231124
* reason:XUQIU1001991
* content:选择源单优化
  * */
fun_setCrmPopupWindow.setSelectCheckedInputByShift=function (){
    var popupobj=CrmPopup.getPopupObj('last');
    popupobj.firstsearchdetailindexbyshift = '';//第一个shift选中的单据序号
    popupobj.lastsearchdetailindexbyshift = '';//最后一个shift选中的单据序号
    popupobj.lastclickindexbyshift = '';//最后一个shift选中的单据序号
    //监听keyup事件
    ld('#'+popupobj.divid+','+'#'+popupobj.divid+'_olayernodeid').bind('keyup',function (event){
        var e = event || window.event;
        var keycode=e.which;
        if (keycode == 16){
            popupobj.firstsearchdetailindexbyshift='';
            popupobj.lastsearchdetailindexbyshift='';
        }
    });
    //shift点击事件
    var shiftobj=ld("#"+popupobj.divid+" [name=resize_content_tableid]").find("[shift=yes]");
    if (shiftobj.length >0){
        shiftobj.bind('click',function (event) {
            var e = event || window.event;
            if (e.shiftKey) {//判断是否按住shift键
                var index = parseInt(ld(this).parent().find('[name=sequence]').attr('index'));
                if (empty(popupobj.firstsearchdetailindexbyshift)) {
                    popupobj.firstsearchdetailindexbyshift = index;
                    popupobj.lastclickindexbyshift=index;
                } else {//第一个不为空
                    if (empty(popupobj.lastsearchdetailindexbyshift)) {//第二个为空
                        popupobj.lastsearchdetailindexbyshift = index;
                        popupobj.lastclickindexbyshift = index;
                    } else {//两个参数都有值时
                        if (popupobj.firstsearchdetailindexbyshift == popupobj.lastclickindexbyshift) {//第一个是上一次点击
                            popupobj.lastclickindexbyshift = index;//更新最后一次点击
                            popupobj.lastsearchdetailindexbyshift = index;//第二个更新为最后一次点击
                        } else if (popupobj.lastsearchdetailindexbyshift == popupobj.lastclickindexbyshift) {//第二个是上一次点击
                            popupobj.lastclickindexbyshift = index;//更新最后一次点击
                            popupobj.firstsearchdetailindexbyshift = index;//第一个更新为最后一次点击
                        }
                    }
                }
                if (!empty(popupobj.firstsearchdetailindexbyshift) && !empty(popupobj.lastsearchdetailindexbyshift)){
                    //判断前一次点击和后一次点击
                    if (popupobj.firstsearchdetailindexbyshift == popupobj.lastclickindexbyshift){
                        var firstindex=parseInt(popupobj.lastsearchdetailindexbyshift);
                        var lastindex=parseInt(popupobj.firstsearchdetailindexbyshift);
                    }else if(popupobj.lastsearchdetailindexbyshift == popupobj.lastclickindexbyshift){
                        var firstindex=parseInt(popupobj.firstsearchdetailindexbyshift);
                        var lastindex=parseInt(popupobj.lastsearchdetailindexbyshift);
                    }
                    //判断大小和之间选中范围
                    if (firstindex<lastindex){
                        var selectobj = ld("#" + popupobj.divid + " [name=resize_content_tableid] tr:lt(" + (lastindex) + "):gt(" + (firstindex) + ")").find('input');
                        var maxindex=lastindex;
                        var minindex=firstindex;
                    }else {
                        var selectobj = ld("#" + popupobj.divid + " [name=resize_content_tableid] tr:lt(" + (firstindex) + "):gt(" + (lastindex) + ")").find('input');
                        var maxindex=firstindex;
                        var minindex=lastindex;
                    }
                    var true_count=0;
                    var length=selectobj.length;
                    var lastindexchecked=ld("#" + popupobj.divid + " [name=resize_content_tableid] tr:eq(" + (lastindex) + ")").find('input').prop('checked');
                    if (length == 0){
                        var checked_result=lastindexchecked;
                    }else {
                        selectobj.each(function (){
                            var checked=ld(this).prop('checked');
                            if (checked == true){
                                true_count++;
                            }
                        });
                        if(true_count == length){//中间全为true
                            if (lastindexchecked == false){
                                var checked_result=false;
                            }else {
                                var checked_result=true;
                            }
                        }else {
                            var checked_result = true;
                        }
                    }
                    var allselectobj=ld("#" + popupobj.divid + " [name=resize_content_tableid] tr:lt(" + (maxindex+1) + "):gt(" + (minindex-1) + ")");//批量操作的单据
                    allselectobj.each(function () {
                        if (ld(this).find('input').prop('checked') != checked_result) {
                            ld(this).find('input').prop('checked', checked_result);
                            fun_setCrmPopupWindow.setChooseInfo_arr(ld(this).find('input'));
                        }
                    });
                }
            }else {//第一次不带shift点击也记住
                var index=ld(this).parent().find('[name=sequence]').attr('index');
                popupobj.firstsearchdetailindexbyshift=index;
                popupobj.lastclickindexbyshift=index;
            }
            ld(this).find('input').focus();
        });
    }

}

/*
* editor:ljj
* time:20240301
* reason:选择源单 已选提示优化
* */
fun_setCrmPopupWindow.setTotalTipContent = function () {
    var popupobj=CrmPopup.getPopupObj('last');
    var module =popupobj.selectmodule;
    var currentmodule = popupobj.currentmodule;
    var popuptype=popupobj.popuptype;
    var totalobj = ld("#"+popupobj.divid+" [name=choosebilltotal_div]");
    if (popupobj.isMultiple != 'yes' && popuptype != 'detailview'){
        if(module=='Products'){//产品分录选择产品
            if (popupobj.module == 'Products'){//产品分录选择产品
                var array=[popupobj.chooseproductid_arr.length];
            }else {//产品分录选择产品套餐
                var array=[popupobj.chooseSourceInfo_arr.length];
            }
            var confirm_str = getVarJsPop('POPUPTOTALTIP',array);
            totalobj.html(confirm_str);
        }else if ((module == 'Accounts' && currentmodule != 'CooperativeWork') || module == 'Users' || module ==  'Contacts' || module == 'Productbom'){//Productbom选择原单选择产品套餐
            var array=[popupobj.chooseMainSourceInfo_arr.length];
            var confirm_str = getVarJsPop('POPUPTOTALTIP',array);
            totalobj.html(confirm_str);
        }else if(module == 'ModComments' || module == 'PriceBooks' || module == 'Reminds' || (module == 'Accounts' && currentmodule == 'CooperativeWork')){
            //已去除已选提示
            ld("#"+popupobj.divid+" [name=choosebilltotal_div]").remove();
        }else {
            var isHaveDetailField = ld('#'+popupobj.divid).find('#isHaveDetailField').val();
            if (isHaveDetailField != undefined && isHaveDetailField == 'no'){
                var array=[popupobj.chooseMainSourceInfo_arr.length];
                var confirm_str = getVarJsPop('POPUPTOTALTIP',array);
                totalobj.html(confirm_str);
            }else {
                var array=[popupobj.chooseMainSourceInfo_arr.length,popupobj.chooseSourceInfo_arr.length];
                var confirm_str = getVarJsPop('POPUPPRODUCTTOTALTIP',array);
                totalobj.html(confirm_str);
            }
        }
    }else if (popuptype == 'detailview') {
        var array=[popupobj.chooseSourceInfo_arr.length];
        var confirm_str = getVarJsPop('POPUPTOTALTIP',array);
        totalobj.html(confirm_str);
    }
}

//获取选择源单类型设置url
//ljj 20240628 选择源单增加 不允许重复
fun_setCrmPopupWindow.getSelectTypeSettingsUrl = function (selectmodule,popupobj) {
    var url = '';

    if(popupobj==undefined || popupobj.sourcemodule_arr==undefined)
    {
        return "";

    }

    ld.each(popupobj.sourcemodule_arr,function(tmpindex,sourcemoduleinfo){
        if(sourcemoduleinfo.entitytype==selectmodule)
        {
            var withdetail = sourcemoduleinfo.withdetail;
            url += '&withproductdetail='+withdetail;
            //选择源单增加不允许重复
            var unallowrepeat = sourcemoduleinfo.unallowrepeat;
            url += '&unallowrepeat='+unallowrepeat;
            if (unallowrepeat == 'yes'){
                var selectDetailLineitemid = [];
                if (popupobj.module == 'WorkSheet'){
                    ld.each(popupobj.selectproductobj.worksheet_sourcevalue_arr,function (index,detailinfo) {
                        var parent_lineitem_id = detailinfo.lineitem_id;
                        selectDetailLineitemid.push(parent_lineitem_id);
                    });
                }else {
                    ld.each(popupobj.detaildatavalue_arr,function (index,detailinfo) {
                        var parent_lineitem_id = detailinfo.parent_lineitem_id;
                        selectDetailLineitemid.push(parent_lineitem_id);
                    });
                }
                url += '&selectDetailLineitemid='+selectDetailLineitemid.join(',');
                url += '&selectListValue='+ld('#'+popupobj.divid+' [name=selectlistval]').val();
            }
            return false;
        }
    });
    return url;
}