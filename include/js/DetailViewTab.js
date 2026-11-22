// JavaScript Document
function DetailViewRelation(){
   var that=this;
}
DetailViewRelation.type='detailviewrelation_tab';
DetailViewRelation.pagetype="detailviewrelation_modulepage";

//用于相关信息内的操作弹出层
DetailViewRelation.load=function(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText){
    DetailViewPage.prototype=new CrmPopup();
    DetailViewPage.prototype.constructor=DetailViewPage;
    DetailViewPage.prototype.type=DetailViewPage.type;
    DetailViewPage.prototype.record=0;
    var Popupobj=new DetailViewPage();
    Popupobj.pagetype=DetailViewPage.pagetype;
    Popupobj.setParams(headtitle,"","",cssWidth,module,"","","",CancelText);
    Popupobj.showafter=function(){
        //界面显示后，加载相关ajax
    }
    return Popupobj
}

//相关信息
DetailViewRelation.search=function(event,related_menu_obj){

    var detailViewPopupObj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
	var popupobj=CrmPopup.getPopupObj("last");//相关信息的obj
    popupobj.headermodule=detailViewPopupObj.module;
    popupobj.detailpage_record=detailViewPopupObj.record;
    if(popupobj.module=='BalanceOfAccount' || popupobj.module=='GuanJiaPoReport')
    {
        var event=event||window.event;

        var li_srcelement=event.srcElement||event.target;

      //  popupobj.balanceaccountobj=new BalanceAccountInOut(popupobj);
      //edit:can 2020-10-28 43048: （8.2.8PHP7+Redis升级包测试）客户单据查看详情界面，相关信息->往来对账列表界面，切换任意数据分类的下拉选项，界面一直显示加载中
        popupobj.balanceaccountobj.callsearch(ld(li_srcelement).attr("relatetag"));
        return false;

    }
    var urldata = DetailViewRelation.judgeUrl(popupobj.headermodule,popupobj.module);
    if(!empty(related_menu_obj) && related_menu_obj.attr('detaillog')!= undefined){
        urldata += '&detaillog='+related_menu_obj.attr('detaillog');
    }
    popupobj.otherurl=urldata;
    DetailViewRelation.searchByPopupobj(popupobj);
}

//popupobj:相关信息的popupobj,
DetailViewRelation.searchByPopupobj=function(popupobj){
    var divid = popupobj.divid;
	var module = popupobj.headermodule;//相关信息所关联的模块(查看界面的模块)
	var record = popupobj.detailpage_record;//相关信息所关联的
    var related_module=popupobj.module;
    //alert(related_module);


    var related_id=popupobj.relateid;
    var otherurl=popupobj.otherurl;
	//var related_module = related_menu_obj.attr('relatetag');
	//var related_id = related_menu_obj.attr('relatedid');
	var _start = 1;
	var urldata = "&header="+module+"&record="+record+"";
	urldata += "&relatedid="+related_id+"&currpage=1&related_left_type=1";
	urldata += "&SearchScope="+popupobj.SearchScope;
	urldata += '&related_module='+encodeURIComponent(related_module);
    //分页
    urldata+="&start="+popupobj.pagenum;
    var ajax = false;
    if (popupobj.searchtype == 'basic' && !empty(popupobj.search_text)){
        urldata += "&searchtype=basic";
        urldata += "&search_field="+popupobj.search_field;
        urldata += "&search_text="+popupobj.search_text;
        urldata += "&ajax=true";
        ajax = true;
    } else if(popupobj.advft_criteria!=''&&popupobj.advft_criteria!=undefined){
	    urldata+="&advft_criteria="+popupobj.advft_criteria;
        urldata+="&advft_criteria_groups="+popupobj.advft_criteria_groups;
        urldata+="&searchtype=advance";
	}
	//数据分类
    if(ld("#"+popupobj.divid+" [name=selectcustomview_"+popupobj.module+"]").length>0&&popupobj.viewid!=undefined){
        //alert(ld("#"+popupobj.divid+" [name=selectcustomview_"+popupobj.module+"]").val());
        urldata+="&viewid="+popupobj.viewid;
    }
    urldata+=otherurl;
	var url = 'index.php?module=Users&action=UsersAjax&file=setRelatedModList'+urldata;
    //EmptyProgressObjs();//edit:can 2020-12-31 44002: （https://61mis.com/kfbcrm [^]）（云泰五金）合同订单（SO175）-相关信息-收款单（GR31）-提交审批，页面信息不会更新（审批状态和和提交审批按钮都没有改变）
    ldAjax(url,"",function(data){
        if(data.code=="-1"){
            // Popupobj.CancelEvent();
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            DelProgressObjs();
            return false;
        }
        if(data.code==1){
            if(related_module === 'ContactsNetGraph'){
                AjaxJSPage('ContactsNetGraph','include/js/modules/Contacts/ContactsNetGraph.js');
                var PopupJqObj = ld("#"+popupobj.divid),
                    DivCTableObj = PopupJqObj.find('.DivCTable'),
                    width = (0.98*PopupJqObj.width()) + 'px',
                    heigth = (PopupJqObj.height() - 125) + 'px';
                DivCTableObj.html(`<div id="ContactsNetGraph" style="width: ${width};height: ${heigth}"><div id="ContactsNetGraphChart" style="height: 100%"></div>`);
                var GrapObj = new ContactsNetGraph();
                GrapObj.init(DivCTableObj.find('#ContactsNetGraphChart'),data.result);
                GrapObj.showGraph();
                DelProgressObjs();
                return 1;
            }
            if(data.result.type=='datacategory_template_js'||data.result.type=='datacategory_templatelink'||data.result.type=='datacategory_template_url'){
                DelProgressObjs();
                //自定义报表
                var a = document.createElement('a');
                var filename=data.result.functionname;
                var default_report=data.result.default_report;
                var report_name=encodeURIComponent(data.result.report_name);
                var record=data.result.record;
               // CustomReport/index.php?stimulsoft_client_key=ViewerFx&stimulsoft_report_key=".$report_template."&default_report=$tmpsystemdefault
                if(data.result.type=='datacategory_templatelink'){
                    //zkt 20231024 BUG0074446 kfbcrm-客户-相关信息栏点击“产品出库记录”，报错
                    var tmpurl = 'CustomReport/index.php?stimulsoft_client_key=ViewerFx&stimulsoft_report_key='+filename+'&default_report='+default_report+'&report_name='+report_name+"&record="+record;
                    tmpurl = cls_encryptyurl.Puyoung_Encryptyurlhavephp(tmpurl,'');
                    a.setAttribute('href',tmpurl );
                }
                else if(data.result.type=='datacategory_template_url'){
                    a.setAttribute('href', 'gantindex.php?record='+record);
                }
                else{
                    var tmpurl = 'CustomReport/JsReport/index.php?crm_report_key='+filename+'&default_report='+default_report+'&report_name='+report_name+"&record="+record;
                    tmpurl = cls_encryptyurl.Puyoung_Encryptyurlhavephp(tmpurl,'');
                    a.setAttribute('href',tmpurl );
                }
                a.setAttribute('target', '_blank');
                a.setAttribute('id', 'datacategory_customreport');
                // 防止反复添加
                if(document.getElementById('datacategory_customreport')) {
                	document.body.removeChild(document.getElementById('datacategory_customreport'));
                }
                document.body.appendChild(a);
                a.click();
                return false;
            }
            if (module == 'PriceBooks' && related_module == 'Products' && ajax){
                ld('#'+popupobj.divid+' #relatedList').html(data.result.content);
                ld('#'+popupobj.divid+' #totalDiv').html(data.result.navigation[0]);
                ld('#'+popupobj.divid+' #pageDiv').html(data.result.navigation[1]);
            }else {
                ld('#'+popupobj.divid+' .DivCTable').html(data.result.content);
            }
            if (module == 'PriceBooks' && related_module == 'Products'){
                tooltip("#relatedList .tip-items-list", {transition: true, time: 200});
            }

            popupobj.advancefieldnames=data.result.advancefieldnames;
            popupobj.CRITERIA_GROUPS=data.result.CRITERIA_GROUPS;
            popupobj.advanceset=data.result.advanceset;//相关信息栏-高级设置
            popupobj.fields=data.result.fields;

            if(data.result.noofrows!=null&&parseInt(data.result.noofrows)>0){

                if(ld("#"+popupobj.divid+" [tag="+related_module+"_count]").length>0)
                {

                    ld("#"+popupobj.divid).find(" [tag="+related_module+"_count][relateidtag="+related_id+"]").css("display",'');
                    ld("#"+popupobj.divid).find(" [tag="+related_module+"_count][relateidtag="+related_id+"]").html('['+data.result.noofrows+']');
                }
                else{
                    ld("#"+popupobj.divid+" [tag=detailviewmore_count]").css("display",'');
                   ld("#"+popupobj.divid+" [tag=detailviewmore_count]").html('['+data.result.noofrows+']');
                }
            }
            else{
                ld("#"+popupobj.divid).find(" [tag="+related_module+"_count][relateidtag="+related_id+"]").css("display",'none');
                ld("#"+popupobj.divid).find(" [tag=detailviewmore_count][relateidtag="+related_id+"]").css("display",'none');
            }
            if(!empty(data.result.mapdata)&&data.result.mapdata.show == 'yes'){
                getJsScript('include/js/ModuleMap.js', function () {
                    var modulemapobj = new ModuleMap();
                    modulemapobj.module = related_module;
                    modulemapobj.fromrecordid = popupobj.detailpage_record;//直接使用record对应的值为undefined
                    modulemapobj.relatedid = related_id;
                    modulemapobj.frommodule = popupobj.headermodule;//相关信息所关联的模块(查看界面的模块);
                    modulemapobj.showmap(popupobj,data.result.mapdata);
                    modulemapobj.resize('view');
                });
            }
            else if (!empty(data.result.showChart) && data.result.showChart == 'yes'){
                getJsScript('include/js/cls_relationshipChart.js', function () {
                    var cls_relationshipChartobj = new cls_relationshipChart(data.result.frommodule,data.result.fromrecord,data.result.chartmodule);
                    cls_relationshipChartobj.setPopupObj(popupobj);
                    cls_relationshipChartobj.setParams(data.result);
                    cls_relationshipChartobj.showRelationshipChart();
                    popupobj.relationshipChartobj = cls_relationshipChartobj;
                });
            }

            //zkt 20230411 BUG0063269  kfbcrm 客户----相关信息联系人----联系人手机字段不显示绿色手机拨打样式----需要点开联系人查看界面，然后再关闭，才显示样式
            IsFrameElement();
            //edit: xll XUQIU1001172 2023/02/23 相关信息栏打开新页签
            ld("#"+popupobj.divid+" .DivCTable .relation_blank").unbind('click').bind('click',function(event){
                relation_click(this);
            });
			DelProgressObjs();
		}
    })
}
//获取相关信息的数量
DetailViewRelation.getRelatedCount=function(popupobj){
    var module=popupobj.module;
    var relateids=[];
    ld.each(ld("#"+popupobj.divid+" [type=DetailViewTab]"),function(){
        relateids.push(ld(this).attr('relatedid'));
    })

    ldAjaxNoProgress("index.php?module=Users&action=UsersAjax&file=setRelatedModList&related_left_type=3&header="+module+"&record="+popupobj.record+"&SearchScope=SmOwner_Search_All&relateids="+relateids.join(','),{},function(data){
        ld.each(data.result.count,function(relateid,tmpcount){
            if(tmpcount!=undefined&&parseInt(tmpcount)>0){
                //duan 20220808 获取原始divid
                if(!empty(popupobj.popupdivid)){
            	   popupobj.divid=popupobj.popupdivid;
            	}
                ld("#"+popupobj.divid).find(" [relateidtag="+relateid+"]").css('display','');
                ld("#"+popupobj.divid).find(" [relateidtag="+relateid+"]").html('['+tmpcount+']');
            }
        })
    })
}
//相关信息列表：分页
DetailViewRelation.setRelatedListPage = function(event,page_obj){
	var popupobj=CrmPopup.getPopupObj("last");
	var _start = page_obj.attr('start');

	ld("#"+popupobj.divid+ " [name=pagenum]").val(_start);
    popupobj.pagenum=ld("#"+popupobj.divid+ " [name=pagenum]").val();
	DetailViewRelation.search(event,page_obj);
}

//@edit:liushuai,2020-09-23,reason 0042706: 成员管理，进入姓名为“测试001”账号详情界面，修改日志中输入页数点击“Go”点不动
//相关信息列表：分页 点击GO
DetailViewRelation.setRelatedListPageByGo = function(event,page_obj){
    var popupobj=CrmPopup.getPopupObj("last");
    popupobj.pagenum=ld("#"+popupobj.divid+ " [name=pagenum]").val();
    DetailViewRelation.search(event,page_obj);
}

//相关信息列表：查询分类
DetailViewRelation.setRelatedListCustomView = function(event,page_obj){
    var popupobj=CrmPopup.getPopupObj('last');
    popupobj.viewid=ld(page_obj).attr("related_cvid");
	DetailViewRelation.search(event,page_obj);
}

//单据详情
DetailViewRelation.showpage_moduledetail = function(popupobj){

    var module = popupobj.module;
	var record = popupobj.record;
    //duan 2022-6-17 去除更改弹出层divid的事件，为了避免刷新页面时出现取对象错误的问题
    if(!empty(popupobj.popupdivid)){
        //判断是否存在自动化任务，如果存在则重置divid
        var tableobj= ld("#"+popupobj.divid+" table[name=advancetask]");
        if(tableobj.length >0){
            ld("#"+popupobj.popupdivid+" [name=AllTaskvalue]").unbind('mouseout');
            ld("#"+popupobj.popupdivid+" [name=AllTaskvalue]").unbind('mouseout');
            ld("#"+popupobj.popupdivid+" [name=displayfields]").unbind('mouseover');
            ld("#"+popupobj.popupdivid+" [name=displayfields]").unbind('mouseover');
            popupobj.divid = popupobj.popupdivid;
        }
    }

    ld("#"+popupobj.divid+" [type=DetailViewTab]").removeClass("current");
    ld("#"+popupobj.divid+" [type=DetailViewTab][relatetag=detailview]").addClass("current");
	var url = 'index.php?module='+module+'&action='+module+'Ajax&file=DetailView&record='+record;
    url+="&pagenum="+popupobj.pagenum+popupobj.lasturl;
    ldAjax(url,{"detailpagewidth": DetailViewPage.getWidth()},function(data){
        if(data.code=="-1"){
            // @edit:dong @date:2020/08/11 @reason: Popupobj 大小写错误
            popupobj.CancelEvent();
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            DelProgressObjs();
            return false;
        }
        if(data.code==1){
			DetailViewPage.showpage_content(popupobj,data,module);
           DelProgressObjs();
		}
    })
}

//刷新选中的相关信息列表
DetailViewRelation.refresh_relatedlist = function(refresh_module){
	var related_id = 0;
	ld.each(ld(".detail-relation-box .detail-relation-btn li a"),function(){
		var related_module = ld(this).attr('relateTag');
		if(refresh_module == related_module){
			var e=event||window.event;
			related_id = ld(this).attr('relatedid');
			var related_menu_obj = ld(this);
			DetailViewRelation.search(e,related_menu_obj);
			return false;
		}
	})
    var popupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
	if(related_id <= 0){
		DetailViewRelation.showpage_moduledetail(popupobj);
	}
}

//上下结构时得，相关信息点击事件逻辑处理
DetailViewRelation.judgeUrl=function(module,related_module){
	var urldata = '';
	var popupobj=CrmPopup.getPopupObj("last");
	var isrecordmod = ',Accounts,Potentials,Contacts,HelpDesk,SalesOrder,ProjectTask,Project,';
	if(isrecordmod.indexOf(','+module+',') > -1){

	}
	//urldata += "&account_id="+ld("#"+popupobj.divid+ " [name=account_id]").val();
	return urldata;
}

//高级查询弹出层
DetailViewRelation.HighersearchPopup=function(event,jqueryobj){
    var detailviewpagepopup=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);//明细弹出层
    var popupobj=CrmPopup.getPopupObj("last");//明细界面的相关信息弹出层
    if(popupobj.balanceaccountobj!=undefined){
        popupobj.balanceaccountobj.HighersearchPopup(event,jqueryobj);
        return false;
    }
    var Popupobj=new CrmPopup.load("","","","LdPopWidth800px",popupobj.module,"","","","");
    Popupobj.prevshow();
    /*wym BUG0069927 提醒框跳出后会覆盖最新popobj，所以给高级查找popobj加了type，后续还是需要优化该代码，最好改成类文件*/
    Popupobj.type='advancesearch';
    Popupobj.advanceSearchDivid=Popupobj.divid;
    ld('#rptContentLoading').hide();
    var params={'advft_criteria_groups':popupobj.advft_criteria_groups,'advft_criteria':popupobj.advft_criteria};
    ldAjaxNoProgress("index.php?module="+popupobj.module+"&action="+popupobj.module+"Ajax&file=ShowAdvanceFilter",params,function(data){
        Popupobj.setParams(data.result.title,DetailViewRelation.callSearch,"","LdPopWidth800px",popupobj.module,"",data.result.oktext,data.result.canceltext);
        Popupobj.setInnerHtml=function(){
            if(Popupobj.scrolldiv!=""){
               ld("#"+Popupobj.divid).html(Popupobj.popupheadhtml+Popupobj.scrolldiv+Popupobj.htmlcontent+"</div>"+Popupobj.popupbottomhtml);
            }
            else{
                ld("#"+Popupobj.divid).html(Popupobj.popupheadhtml+Popupobj.htmlcontent+Popupobj.popupbottomhtml);
            }
            document.getElementById(Popupobj.divid).style.display="block";
        }
        Popupobj.show(data.result.content);

        var advancefilterobj = new cls_advanceFilter();
        var params = {};
        params.columnOptionHtml = popupobj.advancefieldnames;
        params.fLabels = data.result.fLabels;
        params.datetimestr = data.result.datetimestr;
        params.advfilterhtml = data.result.advfilterhtml;
        params.criteria_groups_arr = data.result.criteria_groups_arr;
        params.module = popupobj.module;
        // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
        params.advanceFields = data.result.advanceFields;
        advancefilterobj.setPrevPopupobj(popupobj);
        advancefilterobj.showAdvanceFilter(Popupobj,params);

    });
    // Popupobj.divid=detailviewpagepopup.module+"_"+popupobj.module+"_advancesearchid";
}
DetailViewRelation.callSearch=function(){
    var detailviewpopupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.type);//明细弹出层
    var prevpopupobj=CrmPopup.getPopupObj("lastprev");//
    var popupobj=CrmPopup.getPopupObj("last");//高级查询弹出层
    gPopupAlphaSearchUrl = '';

    if(!popupobj.advanceFilterObj.checkAdvancedFilter()) return false;
    var advft_criteria =popupobj.advft_criteria;
    var advft_criteria_groups = popupobj.advft_criteria_groups;
    prevpopupobj.advft_criteria=advft_criteria;
    prevpopupobj.advft_criteria_groups=advft_criteria_groups;
    prevpopupobj.searchtype = 'advance';
    popupobj.CancelEvent();
    DetailViewRelation.search("","");
	return false;
}
DetailViewRelation.callSearch.funname="DetailViewRelation.callSearch";
DetailViewRelation.changetabcolor=function(popupobj,jqueryobj){
    //BUG0061119 kfbcrm 单据查看详情界面----点击页面上链接字段---返回详情----点击相关信息列中右侧下拉框中隐藏的单据----点击后没有显示模块名称 zxm20220206
    popupobj=CrmPopup.getPopupObj('last');
    ld("#"+popupobj.divid+" [type=DetailViewTab]").each(function(){
        ld(this).removeClass('current');
    });
    ld("#"+popupobj.divid+" [type=DetailView_moremenu]").each(function(){
        ld(this).removeClass('current');
    });

    if(ld(jqueryobj).attr('type')=='DetailView_moremenu'||ld(jqueryobj).attr("tag")=='more'){
        var title=ld(jqueryobj).attr("title");
        var texthtml = '<span style="display: inline-block;max-width: 52px;white-space: nowrap;overflow: hidden;text-overflow: ellipsis;">'+title+'</span>';
        //edit:can 20211013 48265: （https://81mis.com/kfbcrm/ [^] ）销售机会》详情，相关信息更多中打开合同订单后，再次点击相关信息处的合同订单，界面一直转圈
        ld("#"+popupobj.divid+" [tag=more]").html(texthtml+'<i class="relationdown"></i>')
        .attr('relatetag',popupobj.module)
        .attr('title', title).attr('relatedid', ld(jqueryobj).attr("relatedid"));

        ld("#"+popupobj.divid+" [tag=more]").addClass('current');
        ld('#detail-relation-btnmore').hide();
        ld('#detail-relation-btnmore-settings').hide();
    }
    else{
        var text=ld("#"+popupobj.divid+" [tag=more]").attr('text');
        var texthtml = '<span style="display: inline-block;max-width: 52px;white-space: nowrap;overflow: hidden;text-overflow: ellipsis;">'+text+'</span>';
        ld("#"+popupobj.divid+" [tag=more]").html(texthtml+'<i class="relationdown"></i>').attr('title', text).attr('relatedid', '');
        ld(jqueryobj).addClass('current');
    }
}

//加载相关信息点击事件
//tab点击事件
function initDetailRelationBtn(){
	var popupobj=CrmPopup.getPopupObj('last');
    var detailviewpopupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);

    //销售机会保存后立即创建回款预测
    ld("#"+detailviewpopupobj.divid+" [type=DetailViewTab],[type=DetailView_moremenu]").unbind("click").click(function(){
	    EmptyProgressObjs();
    	var e=event||window.event;
        var tag=ld(this).attr("tag");
        var related_module = ld(this).attr('relateTag');
		var related_id = ld(this).attr('relatedid');
        var popupobj=CrmPopup.getPopupObj('last');

        //edit:xll 2023/03/14 BUG0062179 每次点击重新获取，防止detailviewpopupobj被修改导致参数错误
        var detailviewpopupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
        var last_related_module = detailviewpopupobj.related_module;

        detailviewpopupobj.related_module=related_module;
        if(related_module=='more' || related_module=='custom'){
            return;//点击更多、自定义按钮
        }

        if(popupobj.type==RelateListPage.type||popupobj.type=='workreport'){
            popupobj.CancelEvent();
            popupobj=CrmPopup.getPopupObj('last');
        }

		if(relajax == 'balance'){
			relajax = 'list';
		}
        if(ld("#"+popupobj.divid+" [name=crmspanid]").length>0){
            ld("#"+popupobj.divid+" [name=crmspanid]").css('display','none');
        }
		if(related_module == 'detailview'){//详情
			DetailViewRelation.showpage_moduledetail(popupobj);
		}
        else if(related_module == 'custom'){	//相关信息模块设置
			var popupobj=CrmPopup.getPopupObj("last");
			var module = popupobj.module;

			SetRelatedlist(this,module,'','');
		}
        else{//相关模块数据显示
			var related_menu_obj = ld(this);
            var tmpobj=new Object();
            tmpobj.getMaxHeight=popupobj.getMaxHeight;
            tmpobj.divid=popupobj.divid;
            tmpobj.module=ld(related_menu_obj).attr("relatetag");
            tmpobj.type='relatelistpage';
            tmpobj.relateid=related_menu_obj.attr("relatedid");
            tmpobj.getpopupMaxHeight=function(){
                return CrmPopup.getClientHeight();
            }
            tmpobj.CancelEvent=function(){
                 CrmPopup.global_listPopupObj.pop();
            }
            /*ld(window).resize(function(){
                var tmpobj=CrmPopup.getPopupObj('last');
                tmpobj.reSizePosition();
                var detailpopupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
                detailpopupobj.right();
            });*/

            tmpobj.reSizePosition=function(){
                //相关信息设置界面大小
                var strname=ListView_Page.fullwidth_divid+"_"+this.module;
                
                 var tmp_obj =ld("#"+this.divid+" [name="+strname+"]");
                
                //tmpobj=ld("#"+popupobj.divid+" .List3Cols");
                var detailpopupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
                var detailpopupobjmaxheight = this.getMaxHeight();
           
                detailpopupobjmaxheight = detailpopupobjmaxheight-61;//edit:hzx 2022/12/08 减去关联关系头部按钮的高度和padding高度（上下一起16px）
                if(ld("#"+this.divid+" #related_keywords_field").length > 0){
                    detailpopupobjmaxheight = detailpopupobjmaxheight - ld("#"+this.divid+" #related_keywords_field").get(0).offsetHeight;
                }
                if(ld("#"+this.divid+" #DetailContent .DivCTable .DivC .Top").length > 0){
                    detailpopupobjmaxheight = detailpopupobjmaxheight - ld("#"+this.divid+" #DetailContent .DivCTable .DivC .Top").get(0).offsetHeight;
                }
                //zkt 20221026  XUQIU1000463 灵当CRM详细需求-PC端_移动端：相关信息-联系人列表增加“联系人图谱”
                //控制图谱界面显示，防止当联系人数据很少时界面中间空白太多
                var listmap_divobj = ld("#"+this.divid+" #listmap_div");
                if(!empty(listmap_divobj)){
                    ld(listmap_divobj).css("height",detailpopupobjmaxheight);
                    var tmp_objheight = ld(tmp_obj).height();
                    var mapheight = ld(listmap_divobj).height();//
                    if((tmp_objheight+mapheight)<detailpopupobjmaxheight){
                        ld(listmap_divobj).css("max-height",detailpopupobjmaxheight-tmp_objheight);
                    }
                    //(tmp_objheight+mapheight)<detailpopupobjmaxheight?detailpopupobjmaxheight=detailpopupobjmaxheight:detailpopupobjmaxheight=tmp_objheight;
                    detailpopupobjmaxheight = tmp_objheight;
                    if(detailpopupobjmaxheight-50 < 46){//空态情况
                        detailpopupobjmaxheight = 350;
                        ld('#'+tmpobj.divid).find('div.warningTableContent').css('top','calc(50% - 80px)');
                    }
                    ld('#'+tmpobj.divid+' .Tdcenter div.DivCTable').css('overflow','auto');
                    ld(tmp_obj).find('#resize_content_table_divid_'+this.module).css('min-height','140px');
                }
                else{// BUG0069604 相关信息列表界面 滚动优化 非联系人需要去掉DivCTable的滚动条
                    //BUG0071229 往来对帐没有滚动条
                    if(this.module == 'BalanceOfAccount'  || this.module == 'GuanJiaPoReport' ){
                        ld('#'+this.divid+' .Tdcenter div.DivCTable').css('overflow','auto');
                    }else{
                        ld('#'+this.divid+' .Tdcenter div.DivCTable').css('overflow','hidden');
                    }
                }
                // ld(tmp_obj).css("max-height",detailpopupobjmaxheight+'px');
              

                // BUG0069604 相关信息列表界面 滚动优化 有问题找黄祝雄
                if (this.module == 'publicaccount_log' || this.module == 'ChangeView'){// ljj 20240129 BUG20240129-58 客户-相关信息栏点击“公海日志”，界面没有滚动条滑不动
                    ld("#"+this.divid).find("#divRelated_yy").css('height',detailpopupobjmaxheight+'px').css('overflow','auto').css('position','relative');
                }
                else if (ld("#"+this.divid+" #relatedList").length > 0){
                    detailpopupobjmaxheight -= 10;
                    ld(tmp_obj).css("height",detailpopupobjmaxheight+'px');
                    ld('#'+this.divid+' .Tdcenter div.DivCTable').css('overflow','hidden');
                    ld(tmp_obj).find('#resize_content_table_divid_'+this.module).css('height',detailpopupobjmaxheight-58+'px');
                }
                else {
                    ld(tmp_obj).find('#resize_content_table_divid_'+this.module).css('height',detailpopupobjmaxheight-58+'px').css('overflow','auto');
                }

            }
            tmpobj.InitValue=function(){
                this.SearchScope="SmOwner_Search_All";
                this.advft_criteria="";
                this.advft_criteria_groups="";
                this.pagenum=1;
            }
            tmpobj.InitValue();
            tmpobj.headermodule=detailviewpopupobj.module;
            tmpobj.detailpage_record=detailviewpopupobj.record;
            CrmPopup.global_listPopupObj.push(tmpobj);

            if(related_module == '项目甘特图'){//BUG0074897 xxy 2023-11-13 实施立项模块，查看甘特图后，上方导航栏与下方页面不对应，导致点击下方按钮报错 
                DetailViewRelation.search(e,related_menu_obj);        
                if(last_related_module != 'detailview'){
                    tmpobj.module = last_related_module;//需要重新获取跳转前的page信息
                    var last_relateid_obj = ld("#"+detailviewpopupobj.divid+' a[relatetag='+last_related_module+'][type=DetailViewTab]');
                    var last_relateid = last_relateid_obj.attr('relatedid');
                    tmpobj.relateid = last_relateid;
                    CrmPopup.global_listPopupObj.push(tmpobj);
                    DetailViewRelation.search(e,last_relateid_obj);
                }
                return;
            }
            if(related_module=='AccountHierarchy'){
                DetailViewRelation.changetabcolor(popupobj,ld(this));
                getAccountHierarchy(detailviewpopupobj.record,'yes');
                return false;
            }
            if(related_module=='ContactsHierarchy'){
                DetailViewRelation.changetabcolor(popupobj,ld(this));
                getContactHierarchy(detailviewpopupobj.record,'yes');
                return false;
            }
            if(related_module=='Home'){
                DetailViewRelation.changetabcolor(popupobj,ld(this));

                getJsScript('include/js/modules/Home/Coordination.js',function(){
                        tmpobj.type='workreport';
                        show_workreports(ld(this),detailviewpopupobj.module,detailviewpopupobj.record,related_id);
                });

                return false;
            }

            if( related_module==='GuanJiaPoReport'){//管家婆往来对账
                if(ld("#BalanceGJPSalesOrderInOut_js").length>0){
                    tmpobj.balanceaccountobj=new BalanceGJPSalesOrderInOut(tmpobj);
                    tmpobj.balanceaccountobj.init();
                }else {
                    var oS = DocmentWriteJs('include/js/modules/SalesOrder/BalanceGJPSalesOrderInOut.js', 'BalanceGJPSalesOrderInOut_js');
                    oS.onload = oS.onreadystatechange = function () {
                        if (!this.readyState || this.readyState == 'loaded' || this.readyState == 'complete') {
                            tmpobj.balancegjpsalesorderobj = new BalanceGJPSalesOrderInOut(tmpobj);
                            tmpobj.balancegjpsalesorderobj.init();
                        }
                    }
                }
            }else if(related_module=='BalanceOfAccount'){//往来对账
                if(ld("#BalanceAccountInOut_js").length>0){
                     tmpobj.balanceaccountobj=new BalanceAccountInOut(tmpobj);
                     tmpobj.balanceaccountobj.init();
                }
                else{
                    var oS=DocmentWriteJs('include/js/modules/Accounts/BalanceAccountInOut.js','BalanceAccountInOut_js');
                    oS.onload=oS.onreadystatechange=function(){
                        if(!this.readyState||this.readyState=='loaded'||this.readyState=='complete'){
                            tmpobj.balanceaccountobj=new BalanceAccountInOut(tmpobj);
                            tmpobj.balanceaccountobj.init();
                        }
                    }
                }
            }
            else{
			    DetailViewRelation.search(e,related_menu_obj);
            }
            // hzx 2023-12-11 BUG0077017 相关信息栏：合同订单--创建时间显示缩略，但鼠标悬浮没有提示
            setTimeout(function (){tooltip(ld("#"+popupobj.divid).find(" .tip-items-list"), {transition: true, time: 200});},500);

		}
        DetailViewRelation.changetabcolor(detailviewpopupobj,ld(this));
    });

    //更多事件
    ld("#"+popupobj.divid+" [name=detail-relation-btnmore-bar]").hover(function (){
        var popupobj=CrmPopup.getPopupObj("last");
        ld("#"+popupobj.divid+" [name=detail-relation-btnmore]").show();
        ld("#"+popupobj.divid+" [name=detail-relation-btnmore-settings]").show();
        //关键信息的高度 zxm 20221212
        var ketwords_height = ld("#"+popupobj.divid+" #related_keywords_field").height();
        var divid = popupobj.divid;
        var a = ld("#"+divid+"_head").height(),//弹出层头部高度
            b = ld('#'+popupobj.divid+ ' .detail-relation-box').outerHeight(true),//相关信息标签高度
            scrollTop = ld('#'+divid+'_scroll').scrollTop();
        if(b==null) b=0;
        if(scrollTop==null) scrollTop=0;
        var btnmoreTop = parseInt(ketwords_height) + 8 + parseInt(a)+parseInt(b)-parseInt(scrollTop)-parseInt(1);
        var a1 = ld('#'+divid).offset().left,//弹出层距离左边宽度
            b1 = ld('#'+popupobj.divid+" [name=detail-relation-btnmore-bar]").offset().left;//更多弹出层距离左边宽度
        if(a1==null) a1=0;
        if(b1==null) b1=0;
        var btnmoreLeft = parseInt(b1)-parseInt(a1);
        ld('#'+popupobj.divid+" [name=detail-relation-btnmore]").css('top', btnmoreTop+'px').css('left', btnmoreLeft+'px');
        btnmore_height = ld('#'+popupobj.divid+" ul[name=detail-relation-btnmore]").height();
        ld('#'+popupobj.divid+" [name=detail-relation-btnmore-settings]").css('top', btnmoreTop+btnmore_height+'px').css('left', btnmoreLeft+'px');
    },function (){
        ld('#'+popupobj.divid+' [name=detail-relation-btnmore]').hide();
        ld('#'+popupobj.divid+' [name=detail-relation-btnmore-settings]').hide();
    });

    //edit: xll 2023/05/11 XUQIU1001386 单据明细界面，相关信息模块中的“新建”操作按钮异步加载---解决速度慢的问题
    ld("#"+detailviewpopupobj.divid+" [type=DetailViewTab],[type=DetailView_moremenu]").one('mouseenter',function(event){
        var that = this;
        //var popupobj=CrmPopup.getPopupObj("last"); 重新获取popupobj会是刷新后无法获取record值
		var module = detailviewpopupobj.module;
        var relatedid = ld(this).attr('relatedid');
        var record = detailviewpopupobj.record;
        var type = (ld(this).attr('type') == 'DetailViewTab') ? 'list' : 'more';
        var url = 'index.php?module='+module+'&action='+module+'Ajax&file=DetailviewRelButton&getRelated_listButton=yes';
        url += '&relatedid='+relatedid+'&record='+record+'&type='+type;
        ldAjaxNoProgress(url,'',function(data)
        {
            if(data.code==1)
            {
                ld(that).parent().append(data.result);
                //edit: xll XUQIU1001172 2023/02/23 相关信息栏打开新页签
                ld("#"+detailviewpopupobj.divid+" .relation_blank").unbind('click').bind('click',function(event){
                    relation_click(this);
                });
            }
        });
    });

}

//tab显示效果
/*function navigationResize() {
    var popupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);

    ld('#'+popupobj.divid +' #nav-relation-btn li.more').before(ld('#'+popupobj.divid +' #overflow-relation-btn > li'));

    var $navItemMore = ld('#'+popupobj.divid +' #nav-relation-btn > li.more-relation-btn'),
        $navItems = ld('#'+popupobj.divid +' #nav-relation-btn > li:not(.more-relation-btn)'),
        navItemMoreWidth = navItemWidth = $navItemMore.width(),
        //41997: (61mis.com/kfbcrm)客户模块：点击不同“单据编号”进入单据详情界面，相关信息显示宽度不一致（截图红框所示）
        windowWidth = DetailViewPage.getWidth()-100;

    $navItems.each(function() {
        navItemWidth += ld(this).width();
    });

    navItemWidth > windowWidth ? $navItemMore.show() : $navItemMore.hide();

    while (navItemWidth > windowWidth) {
        navItemWidth -= $navItems.last().width();
        $navItems.last().prependTo('#'+popupobj.divid +' #overflow-relation-btn');
        $navItems.splice(-1, 1);
    }

    ld('#'+popupobj.divid +' #overflow-relation-btn > li > a').each(function() {
        ld(this).addClass('more');
        ld(this).attr('type', 'DetailView_moremenu');
    });

    ld('#'+popupobj.divid +' #overflow-relation-btn ul').each(function() {
        // ld(this).remove();
        ld(this).removeClass('detail-relation-second').addClass('detail-relation-moresecond');
    });

}*/
/**
 * 相关信息，排序事件
 * editor:zkt 20210910
 */
 //0047536: （81mis.com/kfbcrm）（需要补丁）客户管理-客户；编号admin368，相关信息-合同订单，点击列头字段无法排序了
function related_left_block(urldata,relatedid){
    var popupobj = CrmPopup.getPopupObj('last');
    var related_module=popupobj.module;

    urldata += "&currpage=1";
    urldata += '&related_module='+encodeURIComponent(related_module);
    if(popupobj.advft_criteria!=''&&popupobj.advft_criteria!=undefined){
	    urldata+="&advft_criteria="+popupobj.advft_criteria;
        urldata+="&advft_criteria_groups="+popupobj.advft_criteria_groups;
        urldata+="&searchtype=advance";
	}
	var url = 'index.php?module=Users&action=UsersAjax&file=setRelatedModList'+urldata;

    ldAjax(url,"",function(data){
        if(data.code=="-1"){
            // Popupobj.CancelEvent();
            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
            DelProgressObjs();
            return false;
        }
        if(data.code==1){
            if(data.result.type=='datacategory_template_js'||data.result.type=='datacategory_templatelink'){
                DelProgressObjs();
                //自定义报表
                var a = document.createElement('a');
                var filename=data.result.functionname;
                var default_report=data.result.default_report;
                var report_name=encodeURIComponent(data.result.report_name);
                var record=data.result.record;
               // CustomReport/index.php?stimulsoft_client_key=ViewerFx&stimulsoft_report_key=".$report_template."&default_report=$tmpsystemdefault
                if(data.result.type=='datacategory_templatelink'){
                    //zkt 20231024 BUG0074446 kfbcrm-客户-相关信息栏点击“产品出库记录”，报错
                    var tmpurl = 'CustomReport/index.php?stimulsoft_client_key=ViewerFx&stimulsoft_report_key='+filename+'&default_report='+default_report+'&report_name='+report_name+"&record="+record;
                    tmpurl = cls_encryptyurl.Puyoung_Encryptyurlhavephp(tmpurl,'');
                    a.setAttribute('href',tmpurl );

                }
                else{
                    var tmpurl = 'CustomReport/JsReport/index.php?crm_report_key='+filename+'&default_report='+default_report+'&report_name='+report_name+"&record="+record;
                    tmpurl = cls_encryptyurl.Puyoung_Encryptyurlhavephp(tmpurl,'');
                    a.setAttribute('href',tmpurl );
                }
                a.setAttribute('target', '_blank');
                a.setAttribute('id', 'datacategory_customreport');
                // 防止反复添加
                if(document.getElementById('datacategory_customreport')) {
                	document.body.removeChild(document.getElementById('datacategory_customreport'));
                }
                document.body.appendChild(a);
                a.click();
                return false;
            }
		    ld('#'+popupobj.divid+' .DivCTable').html(data.result.content);
            popupobj.advancefieldnames=data.result.advancefieldnames;
            popupobj.CRITERIA_GROUPS=data.result.CRITERIA_GROUPS;
            popupobj.advanceset=data.result.advanceset;//相关信息栏-高级设置
            popupobj.fields=data.result.fields;

            if(data.result.noofrows!=null&&parseInt(data.result.noofrows)>0){

                if(ld("#"+popupobj.divid+" [tag="+related_module+"_count]").length>0)
                {

                    ld("#"+popupobj.divid).find(" [tag="+related_module+"_count][relateidtag="+relatedid+"]").css("display",'');
                    ld("#"+popupobj.divid).find(" [tag="+related_module+"_count][relateidtag="+relatedid+"]").html('['+data.result.noofrows+']');
                }
                else{
                    ld("#"+popupobj.divid+" [tag=detailviewmore_count]").css("display",'');
                   ld("#"+popupobj.divid+" [tag=detailviewmore_count]").html('['+data.result.noofrows+']');
                }
            }
            else{
                ld("#"+popupobj.divid).find(" [tag="+related_module+"_count][relateidtag="+relatedid+"]").css("display",'none');
                ld("#"+popupobj.divid).find(" [tag=detailviewmore_count][relateidtag="+relatedid+"]").css("display",'none');
            }
            //zkt 20230104 zkt 20230104 BUG0060372相关信息联系人模块，调整列表排序后，联系人图谱不显示
            if(!empty(data.result.mapdata)&&data.result.mapdata.show == 'yes'){
                getJsScript('include/js/ModuleMap.js', function () {
                    var modulemapobj = new ModuleMap();
                    modulemapobj.module = related_module;
                    modulemapobj.fromrecordid = popupobj.detailpage_record;//直接使用record对应的值为undefined
                    modulemapobj.relatedid = relatedid;
                    modulemapobj.frommodule = module;
                    modulemapobj.showmap(popupobj,data.result.mapdata);
                });
            }
            IsFrameElement();
			DelProgressObjs();
		}
    })
}
//获取单据分录修改日志
function getdetailviewhistory(obj){
    var e=event||window.event;
    var related_menu_obj = ld(obj);
    var popupobj = CrmPopup.getPopupObj('last');
    popupobj.pagenum = 1;
    DetailViewRelation.search(e,related_menu_obj);
}


function editModuleMap(obj){
    // ljj 20231229 XUQIU1002228 联系人图谱增加锁定功能
    //点击编辑获取判断该单据是否被锁
    var popupobj=CrmPopup.getPopupObj('last');
    var lockobj=ld('#'+popupobj.divid+' #map_lock');
    var module = lockobj.attr('module');
    var frommodule = lockobj.attr('frommodule');
    var fromrecordid = lockobj.attr('fromrecordid');
    var urlstring = "index.php?module="+module+"&action="+module+"Ajax&file=editModuleMap&mode=getlockstate&frommodule="+frommodule+"&fromrecordid="+fromrecordid;
    ldAjaxNoProgress(urlstring,'',function (data){
        if (data.code == 1){
            var lockstate=data.result.lockstate;
            popupobj.lockstate=lockstate;
            updateMapLock(popupobj,lockstate);
            if (lockstate == 'no' || lockstate == '-1'){//没被锁
                getJsScript('include/js/ModuleMap.js', function () {
                    var editmodulemapobj = new ModuleMap();
                    editmodulemapobj.setmoduleinfobyobj(obj);
                    editmodulemapobj.editshow();
                });
            }else {//被锁提示
                MessagePopup.TipOne_warning(arrJsPopLabel['LOCKHINTS']);
            }
        }
    });
}
/**
 * editor:ljj
 * time:20231229
 * reason:XUQIU1002228
 * content:联系人图谱增加锁定功能
 * node:图谱查看界面,锁的点击事件
 **/
function moduleMapLockClick(obj){
    var popupobj=CrmPopup.getPopupObj('last');
    var lockstate=ld(obj).attr('lockstate');
    var newlockstate=(lockstate == 'yes')?'no':'yes';
    var frommodule=ld(obj).attr('frommodule');
    var module=ld(obj).attr('module');
    var fromrecordid=ld(obj).attr('fromrecordid');
    var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=editModuleMap&mode=savelockstate';
    surl += '&frommodule='+frommodule;
    surl += '&fromrecordid='+fromrecordid;
    surl += '&newlockstate='+newlockstate;
    ldAjaxNoProgress(surl,'',function (data) {
        if (data.code == 1){
            var newlockstate=data.result.lockstate;
            updateMapLock(popupobj,newlockstate);//更新锁和编辑的情况
        }
    })
}
/**
 * editor:ljj
 * time:20231229
 * reason:XUQIU1002228
 * content:联系人图谱增加锁定功能
 * node:图谱查看/编辑界面,更新锁和编辑按钮的情况
 **/
function updateMapLock(popupobj,lockstate){
    var mapeditobj=ld('#'+popupobj.divid+' #map_edit');
    var lockobj=ld('#'+popupobj.divid+' #map_lock');
    if (lockstate == 'yes'){
        lockobj.parent().css('display','block');
        lockobj.attr('lockstate',lockstate);
        lockobj.attr('class','modulemapview-lock');
        mapeditobj.addClass('editBtnDisabled');
        mapeditobj.attr('disabled',true);
        mapeditobj.addClass('tip-map-edit');
        if (popupobj.mapedit_tooltip != 'yes' ){
            tooltip('.tip-map-edit',{transition: true, time: 200});
            popupobj.mapedit_tooltip = 'yes';
        }
    }else if(lockstate == 'no') {
        lockobj.parent().css('display','block');
        lockobj.attr('lockstate',lockstate);
        lockobj.attr('class','modulemapview-unlock');
        mapeditobj.removeClass('editBtnDisabled');
        mapeditobj.attr('disabled',false);
        mapeditobj.removeClass('tip-map-edit');
    }else if (lockstate == '-1') {
        lockobj.parent().css('display','none');
    }
}

//edit: xll XUQIU1001172 2023/02/23 相关信息栏打开新页签
function relation_click(obj){
    event.preventDefault();//取消元素默认的行为
    event.stopPropagation();//阻止事件冒泡到父元素

    var event_content = ld(obj).parent().attr("onclick");
    var event_name = event_content.split("(")[0];
    var module = 'Home';
    if(event_name == 'NewPaymentPlan' || event_name == 'CreatePaymentPlanfun'){
        module = 'PaymentPlan';
    }else if(event_name == 'NewSendPayment'){
        module = 'SendPayment';
    }else{
        module = ( event_content.split("&")[0] ).split("=")[1];
    }
    var url_pre = 'index.php?pageto_module=?module?&pageto_action=index';
    var url = url_pre.replace("?module?", module);
    var thisMoudule = ld(this).attr("this_module");
    sessionStorage.setItem('isNewPage',event_content + '%' + thisMoudule);
    setTimeout(function(){ OpenNewWebTab(url); }, 1000);
    setTimeout(function(){ sessionStorage.removeItem('isNewPage'); }, 5000);
}

// zl XUQIU1000760 修改日志，增加“隐藏富文本框的修改日志”参数控制,点击事件
function Hiderichtext(obj)
{
    var modulename = ld(obj).attr('data-module');
    var label = ld(obj).attr('id');
    var urlstring = 'module=Users&action=UsersAjax&file=HiderichtextSetting&modulename='+modulename;
    urlstring += '&'+label+'=';
    if(ld(obj).prop('checked')){
        urlstring += 'yes';
    }else{
        urlstring += 'no';
    }

    ldAjax('index.php?',urlstring,function(data){       //调用ldAjax.js里的方法,第三个参数为一个函数,用来验证是否走到后台,code值在后台返回为1,所以后台返回时code为1,加上alert,代表走到了后台

        if(data.code == 1){                //触发刷新修改日志界面的点击事件
            var popupobj=CrmPopup.getPopupObj('last');
            var ViewHistoryobj = ld("#"+popupobj.divid+" [name=relatelisttab] [type=DetailViewTab][relatetag=ViewHistory]");
            ld(ViewHistoryobj).click();
        }
        DelProgressObjs();    //去除加载圆圈
    });

}
//wsh 2024-07-03 XUQIU20240607-08 单据查看详情界面，相关信息操作日志，“编辑”操作详情增加“修改日志详情”操作按钮
function get_edit_detail_log(obj)
{
    var module = ld(obj).attr('module');
    var record = ld(obj).attr('record');
    var relatedid = ld(obj).attr('relationId');
    var logid = ld(obj).attr('logId');
    var detaillog = ld(obj).attr('detaillog');
    var whodid = ld(obj).attr('whodid');
    var changedon = ld(obj).attr('changedon');
    var pop = ld(obj).attr('pop');
    var title = arrJsPopLabel['ModifyingLogDetails'];
    var headinfo = whodid + '(' + changedon + ')';
    var urlstring = 'module=Users&action=UsersAjax&file=setRelatedModList&header=' +module+ '&record=' +record+ '&relatedid=' +relatedid+ '&logid=' +logid+ '&detaillog=' +detaillog+ '&currpage=1&related_left_type=1&isEditDetail=yes&SearchScope=SmOwner_Search_All&related_module=ViewHistory';
    var popwidth = CrmPopup.getClientWidth()*0.6;
    if (pop !== 'no'){
        var Popupobj=new CrmPopup.load("","","",popwidth,module,"","","","");
        //Popupobj.prevshow();
        Popupobj.createHeadHtml = function () {
            this.popupheadhtml = '<div class="E_pop_tit" id="' + this.divid + '_head" style="cursor:move">';
            this.popupheadhtml += '<strong class="E_ptita">' + this.headtitle + '</strong>';
            this.popupheadhtml += '<div class="E_ptita">' + headinfo + '</div>';
            var popupobj = CrmPopup.getPopupObj("last");

            this.popupheadhtml+='<div class="E_pop_tit_Second_Right">';
            this.popupheadhtml += '<div class="ld-fonticon ld-fonticon-close tip-items-pop" value="' + arrJsPopLabel['LBL_CLOSE'] + '" data-tip="' + arrJsPopLabel['LBL_CLOSE'] + '" data-direction="bottom" data-type="position"  id="' + this.divid + '_imgclose"></div>';
            this.popupheadhtml += '</div>';
            this.popupheadhtml += '</div>';

        }
    }else  {
        var Popupobj=CrmPopup.getPopupObj('last');
        Popupobj.isshow = 'no';
        Popupobj.isprevshow = 'yes';
    }
    ldAjax('index.php?',urlstring,function(data){       //调用ldAjax.js里的方法,第三个参数为一个函数,用来验证是否走到后台,code值在后台返回为1,所以后台返回时code为1,加上alert,代表走到了后台


        Popupobj.setParams(title,Popupobj.CancelEvent,"",popwidth,module,"",arrJsPopLabel['LBL_CLOSE'],'',"");



        Popupobj.show(data.result.content);
        //Popupobj.show(data.result.content);
        Popupobj.relatelistsizeobj=new List_ResizeTable(Popupobj);
        Popupobj.relatelistsizeobj.setRelatedResizeTable_Init('ViewHistory','');
        Popupobj.reSizePosition();
        Popupobj.center();
        DelProgressObjs();    //去除加载圆圈
    });

}
