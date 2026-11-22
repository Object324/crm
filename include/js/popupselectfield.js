var isPopupButton='no';
//重新加载，查询弹出框
function reload_showrelationlist(module,selectmodule,type,PopupButton,fieldname)
{
    this.posturl="";
    this.module=module;
    this.selectmodule=selectmodule;
    this.fieldname=fieldname;
    this.type=type;
    this.PopupButton=PopupButton;
    var that=this;
    that.rowid=0;
    this.reload=function()
    {
         ld.ajax(
		
    		{
    			type: 'POST',
    			url: that.posturl,
                 dataType:'json',
    			success: function(data) {
        			 $("status").style.display="none";
                    
                     if(data.code==1)
    			     {
    			           var popupobj=CrmPopup.getPopupObj("last");
                           
                            popupobj.reload(data.result.content);
    			     }
                    
    			}
    		}
		);
    }
}
 /**
 * @edit:andrew
 * @date:2015-6-02
 * @reason:6.01
 * @description:选择客户弹层
 *PopupButton:yes:表示弹出框选择
 */
 function showrelatedlists(module,selectmodule,type,PopupButton,fieldname,obj=''){
	//克莱门特：热线单先输入序列号后，再选客户可以谁便选，会造成错误，如何避免？需客户没选时不能选产品，或产品为空；（老系统亦有控制必须先选客户）
	if(version_account != undefined && version_account == 'climaveneta' && module == 'Potentials' && selectmodule == 'Products'){
		var prevpopupobj=CrmPopup.getPopupObj("last");
		var divid = prevpopupobj.divid;
		if(CrmPopup.findHtmlobj(divid,'account_id').val() != undefined && CrmPopup.findHtmlobj(divid,'account_id').val() == ''){
			RemindsMsg("","LdPopWidth400px","","yes","yes",'客户名称不能为空！');
			return false;
		}
	}
    var popupobj=CrmPopup.getPopupObj('last');

	var posturl = showrelatedlists_url(module,selectmodule,type,PopupButton,fieldname);

      // alert(ld("#"+popupobj.divid+" [name=EditView]").serialize() );
	  if(popupobj.fields != undefined){
          var sensitiverequestfield_arr = [];
		  var  requestvalues="{";
		  if(empty(popupobj.columnfields_value)){
              popupobj.columnfields_value = {};
          }

		  ld.each(popupobj.fields,function(tmpindex,tmpfieldinfo){
              if(tmpfieldinfo.bigtype=='richtext'){
                  return true;
              }
              var tmpfieldvalue = '';
              if(tmpfieldinfo.havesensitivevalue != undefined && tmpfieldinfo.havesensitivevalue == 'yes'){
                  tmpfieldvalue = tmpfieldinfo.sensitiveencryptvalue;
                  sensitiverequestfield_arr.push("requestvalues-"+tmpfieldinfo.fieldname);
              }
              else{
                  if(ld("#"+popupobj.divid+" [name="+tmpfieldinfo.fieldname+"]").length>0 && tmpfieldinfo.uitype != 230){
                      tmpfieldvalue = ld("#"+popupobj.divid+" [name="+tmpfieldinfo.fieldname+"]").val();
                      if(tmpfieldinfo.bigtype=='reference')
                          tmpfieldvalue +='","'+tmpfieldinfo.columnname+'_name":"'+ld("#"+popupobj.divid+" [name="+tmpfieldinfo.fieldname+"_name]").val();
                      //chj 2020/11/24 关联单据传值，当字段值为中文时，IE下会有乱码 encodeURIComponent
                      requestvalues+='"'+tmpfieldinfo.columnname+'":"'+ld("#"+popupobj.divid+" [name="+tmpfieldinfo.fieldname+"]").val()+'",';
                  }else{
                      //duan 20240909 小编辑时获取不显示的字段值
                      if(!empty(popupobj.columnfields_value[tmpfieldinfo.fieldname])){
                          tmpfieldvalue = popupobj.columnfields_value[tmpfieldinfo.fieldname];
                      }
                  }
                  if (tmpfieldinfo.uitype == 33) {
                      //多选用户字段
                      var strtmp = getMultiPickListSelectValue(tmpfieldinfo.fieldname + "[]");
                      tmpfieldvalue = strtmp;
                  }
              }
              requestvalues += '"'+tmpfieldinfo.columnname+'":"'+tmpfieldvalue+'",';
		  })
		  requestvalues=requestvalues.substr(0,requestvalues.length-1);//删除“，”
		  requestvalues+="}"

		  posturl+="&requestvalues="+encodeURIComponent(requestvalues);
          posturl+='&sensitiverequestfield='+JSON.stringify(sensitiverequestfield_arr);
	  }
     // wym XUQIU1001879 合同关联创建收款计划界面没有fields属性，界面上也没有name为fieldname的input，所以添加属性
     if(!empty(popupobj.type)&&popupobj.type=='CreatePaymentplan') {
         posturl += '&requestvalues='+encodeURIComponent('{"entitytypeid":"' + popupobj.record+ '"}');
     }
	  //乐泽财务
	  if(module == 'HelpDesk' && selectmodule == 'Products'){
			var salesorder_id = ld("#"+popupobj.divid+" [name=salesorder_id]").val();
			posturl += "&leze_salesorderid="+salesorder_id;
	  }

     if(!empty(ld(obj))&&!empty(ld(obj).attr('index'))){
         popupobj.selectindex = ld(obj).attr('index');
     }
	var parentwindow=window;
	if(window.opener!=undefined){
		parentwindow=window.opener;
	}
     // @edit:liushuai,2021-02-19,reason:0044666: （http://mxq07223.3322.org:85/crm [^]）（上海富水化工有限公司）采购订单模块，新建选择供应商，点击加号没有反应{url过长}
    // posturl="index.php?"+posturl;

    var reload_showrelationlistobj=new reload_showrelationlist(module,selectmodule,type,PopupButton,fieldname);
    reload_showrelationlistobj.posturl=posturl;
  // console.log(posturl);
     ldAjaxNoProgress("index.php",posturl,function(data) {
         // $("status").style.display="none";

         if(data.code==1)
         {
             var  selectsearchpopupobj=selectSearchPopup.load(data.result.title,"","",CrmPopup.getSmallpopupwidth(),module,"","","","","",selectmodule);
             selectsearchpopupobj.prevshow()
             selectsearchpopupobj.popuptype = 'select_related_popup';
             selectsearchpopupobj.pop_type = 'selectRelatedPopup';
             selectsearchpopupobj.module = selectmodule;
             var divobj = ld('#'+selectsearchpopupobj.divid);
             CrmPopup.setPopupobjHtmlContent_scroll_jquery(selectsearchpopupobj,data.result.content);
             // selectsearchpopupobj.show(data.result.content);
             selectsearchpopupobj.selectfieldtype='mainfield';//弹出层界面快速查询;
             if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                 //通讯录(pc端企业微信要绑定)
                 cls_wxOpenDataobj.bindAllOpenDataByPopupObj(selectsearchpopupobj);
             selectsearchpopupobj.reload_showrelationlistobj=reload_showrelationlistobj;
             //36162: （1.6登录）选择客户弹出层界面：光标应该定位在【查找内容】搜索框中（跟进记录模块测试）
             ld("#"+selectsearchpopupobj.divid+" [name=pop_search_text]").focus();
             //甘特图隐藏设置字段
             if(popupobj.divid == 'ganttsearchdiv'){
                 ld("#"+selectsearchpopupobj.divid+' [name=search]').eq(0).css('display','none');
                 ld("#"+selectsearchpopupobj.divid+' [name=search]').eq(1).css('display','none'); //BUG0068820 xxy 2023-7-14 项目甘特图去掉“快速创建”操作按钮
                 if(ld("#"+selectsearchpopupobj.divid+' [name=search]').length>=3){
                     ld("#"+selectsearchpopupobj.divid+' [name=search]').eq(2).css('display','none');
                 }
             }

             //txy XUQIU1001546 为搜索框增加聚焦事件 销售订单单据上的单选字段弹窗
             ld('#'+selectsearchpopupobj.divid+' .ld-listview-basicsearch input').unbind('focus').bind('focus',function(){
                 ld('#'+selectsearchpopupobj.divid+' #basicsearchcolumns_real select').addClass('ld-border-color-3b7cff');
                 ld(this).addClass('ld-border-color-3b7cff');
             });
             ld('#'+selectsearchpopupobj.divid+' .ld-listview-basicsearch input').unbind('blur').bind('blur',function(){
                 ld('#'+selectsearchpopupobj.divid+' #basicsearchcolumns_real select').removeClass('ld-border-color-3b7cff');
                 ld(this).removeClass('ld-border-color-3b7cff');
             });
             //双击提示
             getJsScript('include/js/PopupProductListDoubleClicks.js', function () {
                 var PopupProductListDoubleClick = new PopupProductListDoubleClicks(selectsearchpopupobj);
                 PopupProductListDoubleClick.setProductListDoubleTip();
             });
             //树结构设置高度
             if (ld('#'+selectsearchpopupobj.divid).find('#isshowPopupModuleListTree') != undefined && ld('#'+selectsearchpopupobj.divid).find('#isshowPopupModuleListTree').val() == 'yes' && PopupModuleListTree != undefined){
                 PopupModuleListTree.setHeight();
             }

             setRelatedListMaxHeight(selectsearchpopupobj)

             var listresizeobj=new List_ResizeTable(selectsearchpopupobj);
             listresizeobj.setPopupResizeTable_Init(selectsearchpopupobj.module);
             selectsearchpopupobj.listresizeobj = listresizeobj;

             selectsearchpopupobj.getSearch=function (){
                 var fieldname = ld('#'+this.divid+' [name=fieldname]').val();
                 selectSearch(fieldname);
             };
             selectsearchpopupobj.center();

         }

     });


}

//设置关联单选列表最大高度
function setRelatedListMaxHeight(selectsearchpopupobj){
     var divobj = ld('#'+selectsearchpopupobj.divid);
    var popupHeight = selectsearchpopupobj.getPopContentHeight();
    var redfont_tipobj = divobj.find('#redfont_tip')
    var SelectRelatedPopdivobj = divobj.find('#SelectRelatedPop')
    var headerDivobj = divobj.find('#resize_header_tableid')
    if (redfont_tipobj.length > 0){
        popupHeight -= redfont_tipobj.outerHeight(true);
    }
    if (SelectRelatedPopdivobj.length > 0){
        popupHeight -= SelectRelatedPopdivobj.outerHeight();
    }
    if (headerDivobj.length > 0){
        popupHeight -= headerDivobj.outerHeight();
    }
    divobj.find('#resize_content_table_divid').css('max-height',popupHeight-10-30);
    selectsearchpopupobj.setPopBodyMaxHeight('#'+selectsearchpopupobj.divid+'_scroll');
}

function showrelatedlists_url(module,selectmodule,type,PopupButton,fieldname){
	//if(selectmodule=='Accounts')
		//ld("#single_accountid").keyup();

    isPopupButton=PopupButton;
    var keywords='';
    var keyids='';
    var record='';
    var popupobj = CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;

    /*if('projecttaskid' == fieldname && CrmPopup.isExistsObj(divid,'projectid')){
		fieldname = '';
	}*/
    if(cur_PageInfo.pagemode.length>0){
        if(cur_PageInfo.pagemode[cur_PageInfo.pagemode.length-1]=='poplayer'){
            var selectfieldinfoobj=cur_PageInfo.fieldinfoobjs[cur_PageInfo.fieldinfoobjs.length-1];
        }else if(typeof fieldinfoobjs!="undefined"&&typeof fieldinfoobjs!=undefined){
            var selectfieldinfoobj=fieldinfoobjs;
        }
    }
    if(selectmodule!=module){

        //30432: 服务回访单编辑界面：项目计划选择弹出层的数据和选择的客户名称相关联
        if(selectmodule=='Accounts'||(module=='Accounts')){
            //BUG20240407-26 ls 240408 天地选最终客户不想带出客户名称,故先都去掉,已告知沈倪正
            if(version_account != undefined && version_account == 'tiandi'){
            }else{
                if(CrmPopup.isExistsObj(divid,'account_id_name')){
                    if(CrmPopup.getHtmlobjval(divid,'account_id_name')!="")
                        keywords=CrmPopup.getHtmlobjval(divid,'account_id_name');
                }
            }

        }
        else if(selectmodule=='ProjectTask'){   
           //30434: 项目进度新增界面：选择项目计划弹出层中的数据没有根据所选择的项目名称来显示
            if(CrmPopup.isExistsObj(divid,'projectid'))
	                keyids = CrmPopup.getHtmlobjval(divid,'projectid');
            else if(CrmPopup.getHtmlobjval(divid,'account_id')!=0)
    			 keyids=CrmPopup.getHtmlobjval(divid,'account_id');
        }
        else if(account_version =='haige'&&selectmodule=='Potentials'&&module=='Quotes'){
            var potential_id = 0;
            if(CrmPopup.isExistsObj(divid,'potential_id')){
                potential_id = CrmPopup.getHtmlobjval(divid,'potential_id');
            }
        }
        else{
    		//chj : 0015517: 施明程：合同订单选择上级合同时，不应该限制只能选择选定客户的合同
            if(module=="SalesOrder"&&selectmodule =='SalesOrder'){
                
            }
            else if(CrmPopup.isExistsObj(divid,'account_id')){
    			//keyids=ld("input[name='account_id']").val();
    			if(CrmPopup.getHtmlobjval(divid,'account_id')!=0)
    			 keyids=CrmPopup.getHtmlobjval(divid,'account_id');
            }else if(!empty(popupobj.columnfields_value) && !empty(popupobj.columnfields_value['account_id'])){
                //duan 20240909 审批，推进小编辑时获取隐藏的字段值
                keyids = popupobj.columnfields_value['account_id'];
            }
        }
    }

    //alert(module+'|'+selectmodule+"|"+keyids)
    if(selectmodule=='PurchaseOrder'||selectmodule=='VendorContact'){
        if(CrmPopup.isExistsObj(divid,'vendor_id')){
            if(CrmPopup.getHtmlobjval(divid,'vendor_id')!=0)
            keyids=CrmPopup.getHtmlobjval(divid,'vendor_id');
            //alert(ld("[name=EditView] input[name='vendor_id']").val());
        }
    }
    if(selectmodule=='Contacts'){
        if(CrmPopup.isExistsObj(divid,'contact_id_name')){
            if(CrmPopup.getHtmlobjval(divid,'contact_id_name')!='')
                keywords=CrmPopup.getHtmlobjval(divid,'contact_id_name');
       }
       if(CrmPopup.isExistsObj(divid,'account_id'))
	       keyids = CrmPopup.getHtmlobjval(divid,'account_id');
    }
	if(module==selectmodule){
		record = CrmPopup.getHtmlobjval(divid,'record');
	}
    // 230720 wym BUG0068694 kfbcrm-项目甘特图-选择项目源单后再点击加号，输入框内没有自动带出当前源单
    if(module=='ProjectTask' && selectmodule=='Project'){
        keywords=CrmPopup.getHtmlobjval(divid,'projectid_name');
    }
	var url='module=Users&action=UsersAjax&file=select_related_popu&selectmodule='+selectmodule+'&keywords='+encodeURIComponent(keywords)+'&frommodule='+module+'&keyids='+keyids+"&type="+type+'&record='+record;
	
	if(fieldname!=undefined&&fieldname!="")
	{
		url+="&fieldname="+fieldname;
	}
   
    //26252: 费用报销新增界面：源单类型选择“销售机会”，选择源单时，设置显示的操作列字段，在点击连接字段时，没有反应
    if(details_showrelatedlists.return_columnname!='')
    {
        url+="&return_columnname="+details_showrelatedlists.return_columnname;
    }
    
    if(account_version =='haige'&&selectmodule=='Potentials'&&module=='Quotes'){
       url+="&potential_id="+potential_id;    
    }
    
  
	return url;
}

 /**
 * @edit:chj
 * @date:2016-10-10
 * @reason:多个字段可以选择同一模块单据信息
 * @description:特殊控制(多个字段选择客户)
 *PopupButton:yes:表示弹出框选择
 */
function showrelatedlists_special(module,selectmodule,type,PopupButton,fieldname){
	var keyids = '';
	var popupobj=CrmPopup.getPopupObj('last');
	if(selectmodule=='Contacts'){
       if(CrmPopup.isExistsObj(popupobj.divid,'related_accountid'))
	       keyids = CrmPopup.getHtmlobjval(popupobj.divid,'related_accountid');
    }
	var posturl='module=Users&action=UsersAjax&file=select_related_popu&selectmodule='+selectmodule+'&frommodule='+module+"&type="+type+'&select_fieldname='+fieldname+"&fieldname="+fieldname+"&keyids="+keyids;
	 
    
	    var param = {};
      // alert(ld("#"+popupobj.divid+" [name=EditView]").serialize() );
	  if(popupobj.fields != undefined){
		  var  requestvalues="{";
	 
		  ld.each(popupobj.fields,function(tmpindex,tmpfieldinfo){
			if(ld("#"+popupobj.divid+" [name="+tmpfieldinfo.fieldname+"]").length>0 && tmpfieldinfo.uitype != 230){
				//chj 2020/11/24 关联单据传值，当字段值为中文时，IE下会有乱码 encodeURIComponent
				requestvalues+='"'+tmpfieldinfo.columnname+'":"'+encodeURIComponent(ld("#"+popupobj.divid+" [name="+tmpfieldinfo.fieldname+"]").val())+'",';
			}
		  })
		  requestvalues=requestvalues.substr(0,requestvalues.length-1);//删除“，”
		  requestvalues+="}"
          param = {'requestvalues':requestvalues};
		  //posturl+="&requestvalues="+encodeURIComponent(requestvalues);
	  }

	var parentwindow=window;
	if(window.opener!=undefined){
		parentwindow=window.opener;
	}

    var reload_showrelationlistobj=new reload_showrelationlist(module,selectmodule,type,PopupButton,fieldname);
    reload_showrelationlistobj.posturl=posturl;
     ldAjaxNoProgress("index.php?"+posturl,param,function(data) {
         if($("status").length > 0){
             $("status").css('display','none');
         }


         if(data.code==1)
         {
             var  selectsearchpopupobj=selectSearchPopup.load(data.result.title,"","",CrmPopup.getSmallpopupwidth(),module,"","","","","",selectmodule);
             selectsearchpopupobj.prevshow();//需要prevshow,不然
             selectsearchpopupobj.popuptype = 'select_related_popup';
             selectsearchpopupobj.pop_type = 'selectRelatedPopup';
             selectsearchpopupobj.module = selectmodule;
             CrmPopup.setPopupobjHtmlContent_scroll_jquery(selectsearchpopupobj,data.result.content);

             //wyt 221118 BUG0058830 自用系统 创建合同订单--选择最终用户---光标没有定位（邱：autofocus="autofocus"）
             ld("#"+selectsearchpopupobj.divid+" [name=pop_search_text]").focus();
             selectsearchpopupobj.reload_showrelationlistobj=reload_showrelationlistobj;
             //树结构调整高度
             if (ld('#'+selectsearchpopupobj.divid).find('#isshowPopupModuleListTree') != undefined && ld('#'+selectsearchpopupobj.divid).find('#isshowPopupModuleListTree').val() == 'yes'&&PopupModuleListTree!=undefined){
                 PopupModuleListTree.setHeight();
             }
             if(data.result.fullscreen=='yes'){
                 selectsearchpopupobj.switchFullscreen();
             }

             setRelatedListMaxHeight(selectsearchpopupobj);

             var listresizeobj=new List_ResizeTable(selectsearchpopupobj);
             listresizeobj.setPopupResizeTable_Init(selectsearchpopupobj.module);
             selectsearchpopupobj.listresizeobj = listresizeobj;

             selectsearchpopupobj.getSearch=function (){
                 var fieldname = ld('#'+this.divid+' [name=fieldname]').val();
                 selectSearch(fieldname);
             };
             selectsearchpopupobj.center();
         }

     });


}
//editor:gyq_161 reason:费用报销选择源单   2019/12/3 9:33
function details_showrelatedlists(obj,event){
	var  popupobj=CrmPopup.getPopupObj("last");
	getJsScript('include/js/detail_selectReference.js',function(){
		var fun_detail_selectReference = new detail_selectReference(obj,event,popupobj);
		fun_detail_selectReference.show();
		return false;
	});
	return false;
    
    var rowobj=ld(obj).parent();
    while(ld(rowobj).prop("tagName")!="TR")
    {
            rowobj=ld(rowobj).parent();
    }
    type='tabdetail_'+ld(rowobj).attr("rowindex");//拖动行，导致行号改变，所以要重新定义type

	//26252: 费用报销新增界面：源单类型选择“销售机会”，选择源单时，设置显示的操作列字段，在点击连接字段时，没有反应
	details_showrelatedlists.return_columnname=selectmodule
	if(ld(rowobj).find(' [detailcolumnname="select_'+selectmodule+'"]').size() > 0){
		//选择源单
		var selectmodule = ld(rowobj).find(' [detailcolumnname="select_'+selectmodule+'"]').first().val();
		if(empty(selectmodule)){
			//if(ld('#detail_selectsource') != undefined){
			if(ld('#'+popupobj.divid+' [name="detail_selectsource"]').size() > 0){
			 //获取原单列名称
				var confirm_str = arrJsPopLabel['pleaseselect'] + ld('#'+popupobj.divid+' [name="detail_selectsource"]').first().html();
                RemindsMsg("","LdPopWidth400px",module,"yes","yes",confirm_str);
			}
			return false;
		}
	}
	var url = showrelatedlists_url(module,selectmodule,type,'no','');
	//费用报销明细
	var  EditView = ld('#' + popupobj.divid + ' form[name="EditView"]');
	//if(document.EditView.selectsource != undefined && document.EditView.salesorder_id != undefined){
	if(EditView.find('[name=selectsource]').size() > 0 && EditView.find('[name=salesorder_id]').size() > 0){
		if(EditView.find('[name=salesorder_id]').get(0).value > 0){
			url += '&selectsource='+EditView.find('[name=selectsource]').get(0).value;
			url += '&entitytype_id='+EditView.find('[name=salesorder_id]').get(0).value
		}
	}
	url+="&fieldname="+obj.getAttribute("columnname")+"&selectrelationfrom=entry";
	var reload_showrelationlistobj=new reload_showrelationlist(module,selectmodule,type,'',selectmodule);
	reload_showrelationlistobj.rowid=ld(rowobj).attr("rowindex");
    ldAjaxNoProgress("index.php?"+url,'',function(data) {
        $("status").style.display="none";

        if(data.code==1)
        {
            var  selectsearchpopupobj=selectSearchPopup.load(data.result.title,"","",CrmPopup.getSmallpopupwidth(),module,"","","","","",selectmodule);
            selectsearchpopupobj.show(data.result.content);
            selectsearchpopupobj.selectfieldtype='detailfield';
            selectsearchpopupobj.popuptype='select_related_popup';
            selectsearchpopupobj.reload_showrelationlistobj=reload_showrelationlistobj;
            if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                //通讯录(pc端企业微信)
                cls_wxOpenDataobj.bindAllOpenDataByPopupObj(selectsearchpopupobj);
        }

    });
	return false;
	
}
details_showrelatedlists.return_columnname='';
  /*键盘回车调用事件*/
 function keywordsearch(event,fieldname){
    var e = event || window.event;
    if(e.keyCode == 13)
	{
        selectSearchs(fieldname);
	}
  }
  /**
 * @edit:andrew
 * @date:2015-6-03
 * @reason:6.01
 * @description:选择客户弹层搜索功能
    */
function selectSearchs(fieldname)
{
    if(typeof(document.QcEditView) != 'undefined'&&ld("#qcformDiv").css('display')=='block'){
        var viewtype = document.QcEditView;
    }else{
        var viewtype = document.EditView;
    }
    var urlstring = 'module=Users&action=UsersAjax&file=select_related_popu&ajax=true&search_type=true';
    var popupobj=CrmPopup.getPopupObj("last");
    //zkt 20221010 BUG0057450客户-关联选择单据，点击设置默认值，显示记录，保持输入框空白，点击查找后就只有5条了，见附件视频
    if(!empty(popupobj.blockid)){
        var maxrowsshow=ld("#maxrowsshow_"+popupobj.blockid).val();
        urlstring +="&maxrowsshow="+maxrowsshow;
    }
    if (ld('#'+popupobj.divid +' #isshowPopupModuleListTree') != undefined && ld('#'+popupobj.divid +' #isshowPopupModuleListTree').val() == 'yes'){
        urlstring += '&isshowModuleListTree=yes';
    }

     var prevpopupobj=CrmPopup.getlastPopupObjByPageType(CreatePagePopup.pagetype);
     
    if(CrmPopup.isExistsObj(popupobj.divid,"pop_search_text")&&ld("#"+popupobj.divid+" [name=pop_search_text]").val()!="")
    {
    
        //19989: 销售机会>相关信息>联系人>选择>快速创建，客户【+】添加界面查找功能无效
        urlstring+='&keywords='+encodeURIComponent(ld("#"+popupobj.divid+" [name=pop_search_text]").val());
    }
    if(CrmPopup.findHtmlobj(popupobj.divid,"selectmodule").val()!=undefined&&CrmPopup.findHtmlobj(popupobj.divid,"selectmodule").val()!='')
    {
        urlstring+='&selectmodule='+CrmPopup.findHtmlobj(popupobj.divid,"selectmodule").val();
    }
    if(CrmPopup.findHtmlobj(popupobj.divid,"frommodule").val()!=undefined&&CrmPopup.findHtmlobj(popupobj.divid,"frommodule").val()!='')
    {
        //wym BUG0072096 kfbcrm-商城设置-轮播图设置-编辑-选择产品-产品管理穿透页搜索功能不生效
        //wym BUG0072366 kfbcrm-商城设置-轮播图设置-新增-导航链接类型选择“产品明细”，选择产品页面，进行搜索，再清除搜索内容，回车，底下说明“仅显示符合条件的前10条数据”不生效
        if(CrmPopup.findHtmlobj(popupobj.divid,"frommodule").val()=='ShopSettings'){
            urlstring+='&frommodule=Products&maxrowsshow=10';
        }else{
            urlstring+='&frommodule='+CrmPopup.findHtmlobj(popupobj.divid,"frommodule").val();
        }
    }
    if(!CrmPopup.findHtmlobj(popupobj.divid,"selectmodule").val()=='Accounts'||(!CrmPopup.findHtmlobj(popupobj.divid,"frommodule").val()=='Accounts')){
        if(prevpopupobj != undefined && ld("#"+prevpopupobj.divid+" input[name='account_id']").val()!=undefined && ld("#"+prevpopupobj.divid+"  input[name='account_id']").val()!=''&&ld("#"+prevpopupobj.divid+" input[name='account_id']").val()!=0 && document.forms['EditView'] != undefined){
            //urlstring+='&keyids='+ld("input[name='account_id']").val();
            urlstring+='&keyids='+ld("#"+prevpopupobj.divid+" input[name='account_id']").val();
        }
    }
    //zkt 20230228 BUG0062312出库计划表，快速创建销售项目，选择签约客户，弹出层中进行搜索，再任意点击一个客户，页面卡住没有反应 
    if(CrmPopup.findHtmlobj(popupobj.divid,"type")!=undefined&&CrmPopup.findHtmlobj(popupobj.divid,"type").value!=''){
        urlstring+='&type='+ld("#"+popupobj.divid+" input[name='type']").val();
    }
    var keyids='';
   
    if(cur_PageInfo.pagemode.length>0)
    {
        if(cur_PageInfo.pagemode[cur_PageInfo.pagemode.length-1]=='poplayer')
        {
            
            var selectfieldinfoobj=cur_PageInfo.fieldinfoobjs[cur_PageInfo.fieldinfoobjs.length-1];
        }
    }
    else if(typeof fieldinfoobjs!="undefined"&&typeof fieldinfoobjs!=undefined)
    {
        var selectfieldinfoobj=fieldinfoobjs;
    }
     urlstring+='&fieldname='+fieldname;
    //zkt 20240111 BUG0078272 项目管理中相关联系人字段，选择了业主单位之后，选择相关联系人，搜索出现的联系人，搜索不出来
    if(fieldname == 'related_contactid' &&CrmPopup.findHtmlobj(popupobj.divid,"selectmodule").val()=='Contacts'){
        if(CrmPopup.isExistsObj(prevpopupobj.divid,'related_accountid')){
            keyids = CrmPopup.getHtmlobjval(prevpopupobj.divid,'related_accountid');
            urlstring+='&keyids='+keyids;
        }
    }
    else if((document.getElementById('selectmodule').value!='Accounts')){
		if(document.getElementById('frommodule').value!='Accounts'){
			if(prevpopupobj != undefined && ld("#"+prevpopupobj.divid+" input[name='account_id']").val()!=undefined && ld("#"+prevpopupobj.divid+" input[name='account_id']").val()!=''&&ld("#"+prevpopupobj.divid+" input[name='account_id']").val()!=0){
				//urlstring+='&keyids='+ld("input[name='account_id']").val();
				 if(document.getElementById('selectmodule').value!=document.getElementById('frommodule').value && document.forms['EditView'] != undefined){
					 urlstring+='&keyids='+ld("#"+prevpopupobj.divid+" input[name='account_id']").val();
					
				 }
			   // urlstring+='&keyids='+document.forms['EditView'].account_id.value;
			}
		}
    }
    else if(document.getElementById('selectmodule').value=='Vendors'||(document.getElementById('selectmodule').value=='VendorContact')){
        if(ld("input[name='vendor_id']").val()!=undefined && ld("input[name='vendor_id']").val()!=''&&ld("input[name='vendor_id']").val()!=0){
            //urlstring+='&keyids='+ld("input[name='vendor_id']").val();
            if(document.getElementById('selectmodule').value!=document.getElementById('frommodule').value && document.forms['EditView'] != undefined)
            urlstring+='&keyids='+document.forms['EditView'].vendor_id.value;
        }
    }
	if(document.getElementById('selectmodule').value=='ProjectTask'){
		urlstring+='&keyids='+document.getElementById('keyids').value;
	}
 
    
	if(document.getElementById('return_columnname')!=undefined&&document.getElementById('return_columnname').value!=''){
        urlstring+='&return_columnname='+ld("input[name='return_columnname']").val();
    }
	//多字段选择同一模块单据 参数：select_fieldname
	// var select_fieldname = ld('#select_fieldname').val();
    //BUG20240725-33 ls 240725 新建商机>终端客户字段>快速创建>所属区域>输入成都查找>点击成都市>发现没有被带出（select_fieldname的错误传参会影响列表点击的方法，导致从方法selectrelated变为了selectrelated_special）
	var select_fieldname =ld("#"+popupobj.divid+" #select_fieldname").val() || '';
	urlstring += '&select_fieldname='+select_fieldname;
    //zxm 20221229 选择搜索字段
    var select_searchfieldname = ld('#select_searchfieldname').val();
    urlstring += '&select_searchfieldname='+select_searchfieldname;

    if(popupobj.selectfieldtype=='mainfield')
    {
        urlstring +="&selectrelationfrom=main";
    }
    else if(popupobj.selectfieldtype=='detailfield')
    {
        urlstring +="&selectrelationfrom=entry";
    }
    var lastprevpopupobj=CrmPopup.getPopupObj("lastprev");
    //关联创建的查询条件
    var  requestvalues="";
	if(lastprevpopupobj.fields != undefined){
		requestvalues="{";
 
        ld.each(lastprevpopupobj.fields,function(tmpindex,tmpfieldinfo){
            if(tmpfieldinfo.uitype=='230'||tmpfieldinfo.uitype==231)//edit:can BUG20240204-21
                return true;
           if(ld("#"+lastprevpopupobj.divid+" [name="+tmpfieldinfo.fieldname+"]").length>0)
           {
                requestvalues+='"'+tmpfieldinfo.columnname+'":"'+encodeURIComponent(ld("#"+lastprevpopupobj.divid+" [name="+tmpfieldinfo.fieldname+"]").val())+'",';
                if(tmpfieldinfo.bigtype=='reference')
                    requestvalues+='"'+tmpfieldinfo.columnname+'_name":"'+encodeURIComponent(ld("#"+lastprevpopupobj.divid+" [name="+tmpfieldinfo.fieldname+"_name]").val())+'",';
           }
           if (tmpfieldinfo.uitype == 33) {
                //多选用户字段
                var strtmp = getMultiPickListSelectValueByObj(ld("#"+lastprevpopupobj.divid +" [name='"+tmpfieldinfo.fieldname + "[]"+"']"));
                //console.log(strtmp);
                requestvalues+='"'+tmpfieldinfo.columnname+'":"'+encodeURIComponent(strtmp)+'",'; 
            }
        })
        requestvalues=requestvalues.substr(0,requestvalues.length-1);//删除“，”
        requestvalues+="}";

	}else if(!empty(lastprevpopupobj.type)&&lastprevpopupobj.type=='CreatePaymentplan') {
        requestvalues = encodeURIComponent('{"entitytypeid":"' + lastprevpopupobj.record+ '"}');
    }

    urlstring+="&requestvalues="+requestvalues;
//	$("status").style.display="inline";
      ldAjaxNoProgress('index.php?',urlstring,function(data)
      {

          // $("status").style.display="none";
          var crmpopupobj=CrmPopup.getPopupObj("last");

          CrmPopup.findHtmlobj(crmpopupobj.divid,"popupListViewContents").html(data.result.content);
          //BUG20240419-41 hzx 服务合同选择客户弹出层界面，搜索关键字查询数据后，界面下方显示大片空白区域
          if(ld('#'+crmpopupobj.divid+'_fullscreen').length > 0){
              var pop_switchtotype = ld('#'+crmpopupobj.divid+'_fullscreen').attr('switchtotype');
              if(pop_switchtotype=='recovery'){
                  crmpopupobj.Fullscreencallback('fullscreen');
              }else{
                  crmpopupobj.Fullscreencallback('recovery');
              }
          }
          //双击提示
          getJsScript('include/js/PopupProductListDoubleClicks.js', function () {
              var PopupProductListDoubleClick = new PopupProductListDoubleClicks(crmpopupobj);
              PopupProductListDoubleClick.setProductListDoubleTip();
          });

          //树结构设置高度
          if (ld('#'+crmpopupobj.divid).find('#isshowPopupModuleListTree') != undefined && ld('#'+crmpopupobj.divid).find('#isshowPopupModuleListTree').val() == 'yes'){
              PopupModuleListTree.setHeight();
          }

      });
}

/*
2015-06-03
andrew
选择客户弹层设置搜索字段
*/
function setSearchs(module,frommodule,fieldname){
    
    var urlstring = 'module=Users&action=UsersAjax&file=setSearchField&ajax=true&setmodule='+module+'&frommodule='+frommodule;
    if(document.getElementById('type')!=undefined&&document.getElementById('type').value!=''){
        urlstring+='&type='+ld("input[name='type']").val();
    }
  
    if(fieldname!='')
    {
        urlstring+='&fieldname='+encodeURIComponent(fieldname);
    }
    ldAjaxNoProgress('index.php?'+urlstring,'',function(data)
    {
        var jspopup=[];
        jspopup.push(module);
        jspopup.push(frommodule);
        jspopup.push(fieldname);
        getJsScript('include/js/SystemPopup/selectSearchField.js',function(){
            var selectSearchFieldobj=selectSearchField.load(data.result.title,checkFieldlists,"","LdPopWidth500px",module,jspopup,data.result.oktext,"",data.result.canceltext);
            selectSearchFieldobj.setOkfunParamObj(jspopup);
            selectSearchFieldobj.show(data.result.content);
            // 设置内容最大高度
            selectSearchFieldobj.setPopBodyMaxHeight(".divPopOverflow");
        })
    });
}
//判断 清除按钮是否显示//zxm 20221214 XUQIU1000736	其他 关联单据选择界面的查找搜索框显示优化
function setRelatedShowOrHideClearIcons(){
    var search_text = ld('#SelectRelatedPop').find('[name=pop_search_text]').val();
    //显示清除按钮\
    if(!empty(search_text)){
        ld('#SelectRelatedPop').find('.ld-icon-clearsearch').css('visibility','visible');
    }else{
        ld('#SelectRelatedPop').find('.ld-icon-clearsearch').css('visibility','hidden');
    }
}
//zxm 20221214 XUQIU1000736	其他 关联单据选择界面的查找搜索框显示优化
function clearRelatedSearchs(obj,selectrealtionfrom,fieldname){
    //zkt 20240701 BUG20240628-01 新建服务完工单，分录明细选择关联设备，快速创建设备台账，选择所属产品界面，搜索关键字后点击删除按钮点不动
    var popupobj = CrmPopup.getPopupObj('last');
    ld('#'+popupobj.divid+' #SelectRelatedPop').find('[name=pop_search_text]').val('');
    //wym BUG0074062
    ld('#'+popupobj.divid+' #SelectRelatedPop').find('[name=pop_search_text]').focus();
    if(selectrealtionfrom=='entry'){
        fun_detail_selectReference.Search();
    }else{
        //edit:can BUG20240923-45
        //selectSearch(fieldname);
    }
}

/*
2015-10-27
edit:cyb
客户模块查重按钮弹出层设置搜索字段
*/
function setDuplicates(module,frommodule,type){
    var urlstring = 'module=Accounts&action=AccountsAjax&file=setDuplicateField&ajax=true&setmodule='+module+'&frommodule='+frommodule;
    if(document.getElementById('type')!=undefined&&document.getElementById('type').value!=''){
        urlstring+='&type='+ld("input[name='type']").val();
    }
    ldAjaxHtmlNoProgress('index.php',urlstring,function(ajaxhtml) {
        $("status").style.display="none";
        createElementDiv("div_setDuplicates");
        ld('#div_setDuplicates').html(ajaxhtml);
        ld('#div_setDuplicates').attr('class','D_pop_box LdPopWidth500px');
        fninvshnew('div_check_repeat');
        fnvshobj(this,'div_setDuplicates');

    });
  
}
function checkFieldlists(module,frommodule,fieldname){
    var popupobj=CrmPopup.getPopupObj("last");
	var prevpopupobj=CrmPopup.getPopupObj("lastprev");
    var obj =CrmPopup.findHtmlobj(popupobj.divid,'popup_selected_id');
    var checkid='';
    // var num=0;
    for(var i=0;i<obj.length;i++){
        if(obj[i].checked){
            checkid+=obj[i].value+"','";  
            // num++;
        }
    }
    /** 
    * @edit:diony 
    * @date:2020-11-04 
    * @reason:【单据新建/编辑界面，选择“关联选择单据（单选）字段类型”的单据弹出层界面，设置字段弹出层中去掉“最多仅允许设置6个查找字段”的控制】  
    * @description:https://www.tapd.cn/63637123/prong/stories/view/1163637123001000134
    */
    // if(num>6){
    //     var confirm_str = arrJsPopLabel['O5SFAA'];
    //     RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
    //     return false;
    // }
    checkid=checkid.substring(0,checkid.length-2);
    checkid="'"+checkid;
    var urlstring = 'module=Users&action=UsersAjax&file=setSearchField&ajax=true&settype=save&setmodule='+module+'&checklist='+checkid;
    if(document.getElementById('type')!=undefined&&document.getElementById('type').value!=''){
        var type=ld("input[name='type']").val();
    }
         
        
    if(typeof(return_column)!=undefined&&typeof(return_column)!='undefined')
    {
       
        //26252: 费用报销新增界面：源单类型选择“销售机会”，选择源单时，设置显示的操作列字段，在点击连接字段时，没有反应
        urlstring+='&return_column='+return_column;
    }
    if(fieldname!='')
    {
        urlstring+='&fieldname='+encodeURIComponent(fieldname);
    }
    ldAjaxHtml('index.php',urlstring,function(response) {
        ldAjaxHtmlNoProgress('index.php','module=Cache&action=CacheAjax&file=index&parenttab=Tools&ajax=true',function(response) {

            popupobj.CancelEvent();//关闭设置的弹出层
            //CrmPopup.getPopupObj("last").CancelEvent();	//关闭选择框弹出层
            popupobj=CrmPopup.getPopupObj("last");
            //表体关联选择单据
            popupobj.getSearch();
            DelProgressObjs();
        });


        // showrelatedlists(frommodule,module,type,'',fieldname);
    });
}
checkFieldlists.funname='checkFieldlists';

/**
*reason:客户查重模块，点击“设置字段”设置好字段点击确认按钮时。
*date:2015-10-27
*edit:cyb
**/
function checkDupFieldlists(module,frommodule){
            var obj = document.getElementsByName("dup_selected_id");   
            var checkid='';
            var num=0;
            for(var i=0;i<obj.length;i++){
                 if(obj[i].checked){
                    checkid+=obj[i].value+"','";  
                    num++;
                 } 
            }                     
            checkid=checkid.substring(0,checkid.length-2);
            checkid="'"+checkid;
        var urlstring = 'module=Accounts&action=AccountsAjax&file=setDuplicateField&ajax=true&settype=save&setmodule='+module+'&checklist='+checkid;
        if(document.getElementById('type')!=undefined&&document.getElementById('type').value!=''){
            var type=ld("input[name='type']").val();
        }
        ldAjaxHtmlNoProgress('index.php?',urlstring,function(response)
        {
            fninvshnew('div_setDuplicates');
            look_check_repeat(this,module);
        });
}
selectrelateds.spop = '';
//特殊控制：多个字段可以选择同一模块单据信息
function selectrelateds_special(module,mid,entityname,fieldname,frommodule){
	var entityname = unescape (decodeURIComponent(entityname));
	if(!empty(fieldname)){
        // lius 20230613 XUQIU1001607 圣拉维CRM项目：客户自动分配功能
        if (version_account == 'shenglawei' && module=='CustomForm24' && frommodule=='Accounts' && fieldname=='cf_7528') {
            entityname = unescape (decodeURIComponent(entityname));
            var winobj=window;

            //30412: 快速创建->跟进记录弹出层：客户名称文本框中录入关键字后，鼠标点击下拉值，结果快速创建弹出层被关闭了
            if(winobj.CrmPopup.isPopup()&&winobj.CrmPopup.getPopupObj("last").type==selectSearchPopup.type)//客户文本框输入内容的模糊选择
                winobj.CrmPopup.global_listPopupObj[winobj.CrmPopup.global_listPopupObj.length-1].CancelEvent();//关闭选择框的弹出层
            if(winobj.CrmPopup.getPopupObj("last").type == 'selectsearchdetail')
                winobj.CrmPopup.global_listPopupObj[winobj.CrmPopup.global_listPopupObj.length-1].CancelEvent();//关闭选择框的弹出层


            if(	winobj.CrmPopup.isPopup()){
                var divid=winobj.CrmPopup.global_listPopupObj[winobj.CrmPopup.global_listPopupObj.length-1].divid;

                ld("#"+divid+" input[name="+fieldname+"]").val(mid);
                ld("#"+divid+" input[name="+fieldname+"_name]").val(entityname);
                ld("#"+divid+" input[name="+fieldname+"_name]").attr("disabled",true);
                ld("#"+divid+" input[name="+fieldname+"_name]").css("cursor",'not-allowed');

                ld("#"+divid+" input[name="+fieldname+"]").change();

            }
            return ;
        }

		var prevpopupobj=CrmPopup.getPopupObj("lastprev");
		var divid = prevpopupobj.divid;
		CrmPopup.findHtmlobj(divid,fieldname).val(mid);
		CrmPopup.findHtmlobj(divid,fieldname+"_name").val(entityname);
		//选择字段带出关联信息
		getJsScript('include/js/relatedfield.js',function(){
			getRelatedFieldData.spop = selectrelateds.spop;
			getRelatedFieldData(module,mid,entityname,fieldname,frommodule,'special_popupselectfield');
		});
		var popupobj=CrmPopup.getPopupObj("last");
       
        popupobj.CancelEvent();
		//fninvshnew('selectrelateddiv');
	}
}
//特殊控制：多个字段可以选择同一模块单据信息
function dropdownselectrelateds_special(module,mid,entityname,fieldname,smownerid,frommodule){
    //edit:can 20220705 53657 （https://www.51mis.com/hy/zxyjxs220704）【通用问题】，申请的【经销商管理演示账套】中合同订单编辑页面，选择最终用户字段模糊查询的结果会把渠道伙伴字段的内容覆盖。
    
	var entityname = unescape (decodeURIComponent(entityname));
	if(!empty(fieldname)){
		var popupobj=CrmPopup.getPopupObj("last");
		var divid = popupobj.divid;
		CrmPopup.findHtmlobj(divid,fieldname).val(mid);
		CrmPopup.findHtmlobj(divid,fieldname+"_name").val(entityname);
		//选择字段带出关联信息
		getJsScript('include/js/relatedfield.js',function(){
			getRelatedFieldData.spop = selectrelateds.spop;
			getRelatedFieldData(module,mid,entityname,fieldname,frommodule,'special_popupselectfield');
		});
	 
		//fninvshnew('selectrelateddiv');
	}
}
function selectrelateds(module,rowid,mid,entityname,fieldname,smownerid,frommodule,spop){

	if(fieldname=='accountname'){
		fieldname='accounts_name';
	}
    var adddetails = 'no';
    var prev_prevpopupobj = CrmPopup.getPopupObj("lastprev");//编辑或新建界面
    //BUG0060218	已分派	功能BUG	zxm 项目甘特图关联选择单据项无法选择数据
    if(prev_prevpopupobj.type!='ganttReport'){
        if (prev_prevpopupobj.type == CreatePagePopup.type
         || prev_prevpopupobj.type == PageRecordPopup.type){
            for (var i = 0; i < prev_prevpopupobj.fields.length; i++) {
                if (prev_prevpopupobj.fields[i].fieldname == fieldname){
                    adddetails =prev_prevpopupobj.fields[i].adddetails ;
                    break;
                }
            }
         }
    }


    entityname = unescape (decodeURIComponent(entityname));
    var winobj=window;
   	
    //winobj.CrmPopup.getPopupObj("last")==selectSearchPopup.type:当前弹出层是选择框弹出才关闭，
    //30412: 快速创建->跟进记录弹出层：客户名称文本框中录入关键字后，鼠标点击下拉值，结果快速创建弹出层被关闭了
    if(winobj.CrmPopup.isPopup()&&winobj.CrmPopup.getPopupObj("last").type==selectSearchPopup.type)//客户文本框输入内容的模糊选择
            winobj.CrmPopup.global_listPopupObj[winobj.CrmPopup.global_listPopupObj.length-1].CancelEvent();//关闭选择框的弹出层
	if(winobj.CrmPopup.getPopupObj("last").type == 'selectsearchdetail')
		winobj.CrmPopup.global_listPopupObj[winobj.CrmPopup.global_listPopupObj.length-1].CancelEvent();//关闭选择框的弹出层

    //快速创建
    var before_accountid = 0;
        
	if(	winobj.CrmPopup.isPopup()){
		
        var divid=winobj.CrmPopup.global_listPopupObj[winobj.CrmPopup.global_listPopupObj.length-1].divid;
        before_accountid=ld("#"+divid+" input[name="+fieldname+"]").val();
		//均摊
		if(fieldname.indexOf("shareequally_") >= 0 ) {
			var fieldname_arr = fieldname.split('shareequally_');
			winobj.CrmPopup.setHtmlobjval(divid,'share_entitytypeid_'+fieldname_arr[1],mid);
			ld("#"+divid+" input[name=share_entitytype_"+fieldname_arr[1]+"]").val(entityname);
			
		}
		/*if(fieldname == 'shareequally' && rowid > 0){
			winobj.CrmPopup.setHtmlobjval(divid,'share_entitytypeid_'+rowid,mid);
			ld("#"+divid+" input[name=share_entitytype_"+rowid+"]").val(entityname);
		}*/
        else if((module=='ServiceContracts'||module=="SalesOrder")&&frommodule=='Project')
        {
            //项目：project选择源单
            //edit:can 2020-09-02 42557: (http://51mis.com.cn/XS/banpu/ [^])客户问题（厦门班普），实施菜单>实施项目模块>新建单据界面：选择源单“服务合同”，关联服务合同后，编辑界面没有显示出合同编号
            ld("#"+divid+" input[name=salesorder_id]").val(mid);
            ld("#"+divid+" input[name=salesorder_id_name]").val(entityname);
        }
		else if(frommodule == 'HelpDesk' && fieldname == 'parent_id'){
			getOpenerObj("parent_id_display").value = entityname;
			getOpenerObj("parent_id").value = mid;
		}
        else if(frommodule=='SendPayment'&&fieldname=='purchaseorder_id')
        {
            //edit:can 20210205 44622: （本地8.3.7）财务管理-收款计划/付款计划-编辑；编辑收/付款计划单机，清除选择源单时，点击没有任何反应
            //  ld("#"+divid+' [name=salesorder_id]').val(mid);
              ld("#"+divid+' [name=entitytypeid]').val(mid);
               
              ld("#"+divid+" [name=salesorder_name]").val(entityname);
        }
        else if(frommodule=='PaymentPlan'&&fieldname=='entitytypeid')
        {
            //edit:can 20210205 44622: （本地8.3.7）财务管理-收款计划/付款计划-编辑；编辑收/付款计划单机，清除选择源单时，点击没有任何反应
           //  ld("#"+divid+' [name=salesorder_id]').val(mid);
              ld("#"+divid+' [name=entitytypeid]').val(mid);
               
              ld("#"+divid+" [name=salesorder_name]").val(entityname);
        }
        else
        {

            if(!empty(winobj.CrmPopup.getPopupObj("last").selectindex)){
                var index=winobj.CrmPopup.getPopupObj("last").selectindex;
                ld("#"+divid+" input[name="+fieldname+index+"]").val(mid);
                ld("#"+divid+" input[name="+fieldname+index+"_name]").val(entityname);
                ld("#"+divid+" input[name="+fieldname+index+"_name]").attr("disabled",true);
                ld("#"+divid+" input[name="+fieldname+index+"_name]").css("cursor",'not-allowed');
                ld("#"+divid+" input[name="+fieldname+index+"]").change();
            }else{
                ld("#"+divid+" input[name="+fieldname+"]").val(mid);
                ld("#"+divid+" input[name="+fieldname+"_name]").val(entityname);
                ld("#"+divid+" input[name="+fieldname+"_name]").attr("disabled",true);
                ld("#"+divid+" input[name="+fieldname+"_name]").css("cursor",'not-allowed');
                ld("#"+divid+" input[name="+fieldname+"]").change();
            }
        }
	}
    
	//基本信息

    parentwindow = winobj;
	var popupobj=CrmPopup.getPopupObj('last');

    //20240726 hzx XUQIU1001729 经销商用PRM成员管理设置
    if(frommodule == 'Users' && fieldname == 'related_crmid'){
        ld('#'+popupobj.divid+' input[name=related_crmid]').val(mid);
        ld('#'+popupobj.divid+' div[name=related_crmid_name]').text(entityname);
        return;
    }

    if(winobj.CrmPopup.getPopupObj("last").type=='ganttReport'){
        if(ld('.SearchResult')!=undefined){
            ld('.SearchResult').css('display','none');
        }
        return false;
    }
    if(winobj.CrmPopup.isPopup()&&(winobj.CrmPopup.getPopupObj("last").type=='moduledetailpage'
        ||winobj.CrmPopup.getPopupObj("last").type==winobj.PageRecordPopup.type
        ||winobj.CrmPopup.getPopupObj("last").type==winobj.CreatePagePopup.type) && parentwindow.document.EditView != undefined){
        //38931: （kfbcrm）附件管理：新建单据“服务合同”字段选择单据后，【相关对象】字段也显示了同样的字段值
		//16222: 评论>新增,关于选择相关对象的问题
		//if(parentwindow.document.EditView.related_to!=undefined){
//			parentwindow.document.EditView.related_to.value=mid;
//			parentwindow.document.EditView.related_to_name.value=entityname;
//		}
		
		if(module=='Quotes'){
			if(parentwindow.document.EditView.quote_id != undefined)
				parentwindow.document.EditView.quote_id.value=mid;
			if(parentwindow.document.EditView.quotes_name != undefined)
				parentwindow.document.EditView.quotes_name.value=entityname;
			if(frommodule == 'SalesOrder'){
			 //edit:can 20200820 42440: （http://crmm.mfexcel.com/crm/ [^]）（客户问题：珠海市小源科技有限公司）销售菜单>代理销售确认单模块新增界面>销售报价单弹出层：选择后“销售报价单”后，界面自动跳转到首页了。
             
			//	parentwindow.document.EditView.action.value = 'EditView';
			//	parentwindow.document.EditView.convertmode.value = 'update_quote_val';
				//parentwindow.document.EditView.submit();
                //popupobj.selectproductobj.ResetProductTab(module,mid);
                //    return ;//BUG0078354 合同订单上新增单选报价单的字段没有关联带出
			}
		}
       
        if(module=="Potentials"&&ld("#"+divid+" input[name=deploy_205]").val() != undefined)
        {
            //zkt 20230512 BUG0066289海格：创建报价单时会把项目中的产品组预测带到特价单中的产品选择框内，实际应该需要是空白的 先做特殊判断,不然和移动端不统一
            if(ld("#"+divid+" input[name=deploy_205]").val()!=''&&parseInt(ld("#"+divid+" input[name=deploy_205]").val())==0&&account_version != 'haige')
            {
                	//parentwindow.document.EditView.action.value = 'EditView';
                    //parentwindow.document.EditView.convertmode.value = 'update_potential_val';
                   // parentwindow.document.EditView.submit();
                    popupobj.selectproductobj.ResetProductTab(module,mid);
            }
            else{
                adddetails = 'no';//销售机会未启用产品分录时不应去带出产品分录
            }
        }
      
		if(module=='SalesOrder'){
			if(parentwindow.document.EditView.salesorder_id != undefined && parentwindow.document.EditView.salesorder_id != 'undefined')
				parentwindow.document.EditView.salesorder_id.value=mid;
			if(parentwindow.document.EditView.salesorder_id_name!=undefined&&parentwindow.document.EditView.salesorder_id_name!='undefined')
				parentwindow.document.EditView.salesorder_id_name.value=entityname;
			else if(parentwindow.document.EditView.salesorder_id_name!=undefined&&parentwindow.document.EditView.salesorder_id_name!='undefined')
				parentwindow.document.EditView.salesorder_id_name.value=entityname;
			if(frommodule == 'ServiceContracts'){
			//	if(parentwindow.document.EditView.module != undefined &&parentwindow.document.EditView.module.value !='SalesOrder'){
					//parentwindow.document.EditView.action.value = 'EditView';
				//	parentwindow.document.EditView.convertmode.value = 'update_so_val';
				//	parentwindow.document.EditView.submit();
                //39104: （51mis.com/kfbcrm）服务合同模块>新建单据界面：选择“合同订单”没有自动带出“客户名称”“联系人姓名”。
                     popupobj.selectproductobj.ResetProductTab(module,mid);
                    // return ;
			//	}
			}
            
       
		}
        if(adddetails == 'yes'&&popupobj.selectproductobj !=undefined){
            popupobj.selectproductobj.ProductTabadddetails(module,mid);
        }
	
		//回款计划 - 选服务合同、合同订单
		if((module=='SalesOrder' || module=='ServiceContracts') && frommodule == 'PaymentPlan'){
			parentwindow.document.EditView['entitytypeid'].value=mid;
			//parentwindow.document.EditView[fieldname+'_display'].value=entityname;
		}
	
	
		if(module == 'Users'){
			if(parentwindow.document.EditView.reports_to_name!=undefined){
				parentwindow.document.EditView.reports_to_name.value = entityname;
				parentwindow.document.EditView.reports_to_id.value = mid;
			}
			else if(parentwindow.document.EditView.approveby_name!=undefined){
				parentwindow.document.EditView.approveby_name.value = entityname;
				parentwindow.document.EditView.approveby.value = mid;
			}
			/**
			*by andy
			*公海客户改进
			*/
			else if(parentwindow.document.EditView.user_name!=undefined){
			     //29612: 控制面板->公海参数设置：“ 公海已分配客户释放后，更改客户负责人为（为空表示不更改） ”选择用户后，显示空白
				if(document.getElementById('allotaccount') != undefined && document.getElementById('allotaccount').value == 'true')
				{
				  
					parentwindow.document.EditView.allotuser_name.value = entityname;
					parentwindow.document.EditView.allotuserid.value = mid;
				}
				else{
					parentwindow.document.EditView.user_name.value = entityname;
					parentwindow.document.EditView.userid.value = mid;
				}
			}
		}
		if('related_to' == fieldname){
			if(getOpenerObj("related_to") != undefined && getOpenerObj("related_to_name") != undefined){
				var related_to = getOpenerObj("related_to");
				var related_to_name = getOpenerObj("related_to_name");
				related_to.value = mid;
				related_to_name.value = entityname;
				//cancelCrmPopup();
			}
		}
        //30475: PC端>销售机会明细界面>相关信息>合同订单跳转页面>客户名称弹出层：选择客户名称自动关闭了页面。
       // if(global_ispopup_page=='yes')
		//  window.close();
	}
	else if(module == 'Users'){
		 if(parentwindow.document.EditView.user_name!=undefined){
			 //29612: 控制面板->公海参数设置：“ 公海已分配客户释放后，更改客户负责人为（为空表示不更改） ”选择用户后，显示空白
			if(document.getElementById('allotaccount') != undefined){
				if(document.getElementById('allotaccount').value == 'true'){
					parentwindow.document.EditView.allotuser_name.value = entityname;
					parentwindow.document.EditView.allotuserid.value = mid;
				}else{
					parentwindow.document.EditView.user_name.value = entityname;
					parentwindow.document.EditView.userid.value = mid;
				}
			}
		}
	}
    //分录布局规则（选择客户名称）
    if(popupobj.fieldruleobj){
        popupobj.fieldruleobj.CheckReLoadPopup();//是否重新加载界面
    }
	isPopupButton='no';
	//客户服务单 - 选择客户 - 带出客户关联服务单的历史记录
	if(frommodule != '' && frommodule == 'HelpDesk' && mid > 0){
		getAccountByHelpDeskHistory(mid,'',popupobj);
	}
	// 产品关联创建合同订单：选择客户名称后，没有根据该客户最近一次购买该产品的记录，更新最近一次价格
	if(module == 'Accounts' && mid > 0){
		getJsScript('include/js/modules/Accounts/Accounts.js',function(){
			getAccountLastPrice(mid,frommodule);
		})
		
	}
 
	//客户服务单选择客户带出客户关联的服务信息
	if((module == 'Accounts' && frommodule == 'HelpDesk') ){
    	showServiceContractsDetail(mid,module,popupobj)
	}
	//报价单和合同订单先选产品再选客户，需要提示更新产品价格
	if(module=='Accounts' && ('Quotes' == frommodule || 'SalesOrder' == frommodule)){
		if(before_accountid != mid){
			getAccountLastProductForPrice(before_accountid,mid);
		}
	}
	//duan 20240926字段变更后触发公共变化事件
    if(!empty(popupobj.common_field_event_obj) && before_accountid != mid ){
        popupobj.common_field_event_obj.common_changefun(ld("#"+divid+" input[name="+fieldname+"]"),fieldname);
    }


	//选择字段带出关联信息
	getJsScript('include/js/relatedfield.js',function(){
		getRelatedFieldData.spop = selectrelateds.spop;
		getRelatedFieldData(module,mid,entityname,fieldname,frommodule,'popupselectfield');
	});
	//chj 2022/8/11 维修内容产品严格参照源单，即选热线单后，自动判断是否有报损单，如无报损单或报损单无产品，则没有产品明细也可保存；如有产品，则维修内容产品及数量与报损单完全一致（选择CCF单后自动带出报损单和对应的产品），不允许变更。 产品新增图标也去掉。
	if(ld("#"+divid+" input[name=version_account]").val() != undefined && ld("#"+divid+" input[name=version_account]").val() == 'climaveneta' && module == 'Potentials' && frommodule == 'OutboundOrder'){ 
		getPotentialForQuotes_Climaveneta(mid,divid);
	}
	if(account_version == 'huacanguangdian' && frommodule == 'CustomForm37' && module=='Accounts' && mid > 0){
	    var detailurl = 'index.php?module=CustomForm37&action=CustomForm37Ajax&file=hc_getDetailForAccount&accountid='+mid;
        ldAjaxNoProgress(detailurl,'',function (data){
            if(data.code == 1){
                if(data.result.lineitem_id_list && data.result.lineitem_id_list.length > 0){
                    var tmp_lineitem_id = data.result.lineitem_id_list.join(',');
                    var new_url = "module=Products&action=ProductsAjax&file=GetSearchInfo&ReportHeader=dheader&getProductinfo=yes&wareid=0&accvenid=&currencyid=1&rowid=&frommodule=CustomForm37&productid="+tmp_lineitem_id+"&popup_selectsource=true&cur_record=0&selectentitytypeids=&withproductdetail=yes&source_idstr="+tmp_lineitem_id+"&agian=yes&selectmodule=CustomForm37";
                    prev_prevpopupobj.selectproductobj.getValue(1, new_url);
                }
            }
        });
    }
    ld("#popupdoubleclick").remove();
}


//chj 2022/8/11 维修内容产品严格参照源单，即选热线单后，自动判断是否有报损单，如无报损单或报损单无产品，则没有产品明细也可保存；如有产品，则维修内容产品及数量与报损单完全一致（选择CCF单后自动带出报损单和对应的产品），不允许变更。 产品新增图标也去掉。
function getPotentialForQuotes_Climaveneta(mid,divid){
	var strurl ='index.php?module=OutboundOrder&action=OutboundOrderAjax&file=getPotentialForQuotes_Climaveneta&record='+mid;
    ldAjaxNoProgress(strurl,'',function(data)
    {
        if(data.code==1)
        {
            CrmPopup.findHtmlobj(divid,'selectlistval').val(data.result.quoteid);
            CrmPopup.findHtmlobj(divid,'selectlistval_label').val(data.result.quote_no);
            if(data.result.limeiten_ids){
                var urlstring = 'module=Products&action=ProductsAjax&file=GetSearchInfo&ReportHeader=dheader&getProductinfo=yes&wareid=2&accvenid='+mid+'&currencyid=1&rowid=1&frommodule=OutboundOrder&productid='+data.result.limeiten_ids+'&popup_selectsource=true&cur_record=&selectentitytypeids=&withproductdetail=yes&source_idstr='+data.result.limeiten_ids+'&agian=yes&selectmodule=Quotes';
                var popupobj=CrmPopup.getPopupObj('last');
                //alert(prevpopupobj.selectproductobj);
                popupobj.selectproductobj.getValue(1,urlstring);
            }
        }
    });
}
//明细选择原单
function selectTabDetailRelateds(obj,event,rowid){
	var popupobj=CrmPopup.getPopupObj('last');
    getJsScript('include/js/detail_selectReference.js',function(){
		var fun_detail_selectReference = new detail_selectReference(obj,event,popupobj);
		fun_detail_selectReference.setvalue(obj,rowid);
		return false;
	});
    /*var  prepopupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
    var tableobj=prepopupobj.getDetailTableObj();

    var rowobj=ld(tableobj).find("tr[rowindex="+rowid+"]");
    
    //var paymenttab = ld('#'+popupobj.divid+' table[name="proTab"]').get(0);
  //26252: 费用报销新增界面：源单类型选择“销售机会”，选择源单时，设置显示的操作列字段，在点击连接字段时，没有反应
     details_showrelatedlists.return_columnname='';
	//if(window.parent.document.getElementById(columnname) != undefined){
	if(ld(rowobj).find(' [detailcolumnname="'+columnname+'"]').size() > 0){
		var entityname = decodeURI(entityname);
      
        ld(rowobj).find(' [detailcolumnname="'+columnname+'"]').val(mid);
        
        ld(rowobj).find(' [detailcolumnname="'+columnname+'_name"]').get(0).value = decodeURI(entityname);
        ld(rowobj).find(' [detailcolumnname="'+columnname+'_name"]').get(0).disabled  = true;
        ld(rowobj).find(' [detailcolumnname="'+columnname+'_name"]').get(0).style.cursor = 'not-allowed';
		//window.parent.document.getElementById(columnname).value = mid;
		//window.parent.document.getElementById(columnname+'_name').value = decodeURI(entityname);
		//window.parent.document.getElementById(columnname+'_name').disabled  = true;
       // window.parent.document.getElementById(columnname+'_name').style.cursor = 'not-allowed';
	getRelatedData(frommodule,mid,columnname,rowid);
	//	fninvshnew('selectrelateddiv');
        var popupobj=CrmPopup.getPopupObj("last");
        if(prepopupobj!=popupobj)//费用报销选择源单（手动输入查询）
             popupobj.CancelEvent();
        
		
	}*/
}
//报价单和合同订单先选产品再选客户，需要提示更新产品价格
function getAccountLastProductForPrice(before_accountid,mid){
	var prevpopupobj=CrmPopup.getPopupObj('lastprev');
	if(prevpopupobj == undefined){
		var prevdivid = 'div_pagerecord';
	}else{
		var prevdivid=prevpopupobj.divid;
	}
	if(CrmPopup.findHtmlobj(prevdivid,'SYstemArg').val() != undefined){
		var System_deploy=CrmPopup.findHtmlobj(prevdivid,'SYstemArg').val();
		if(System_deploy == 0){
			var tableName =ld("#"+prevpopupobj.divid+" [name=proTab").get(0);// document.getElementById('proTab');
			var rowcount = tableName.rows.length;
			var row_i = 0;
			for(var i = 1; i<=rowcount - 1; i++){
				if(  ld("#"+popupobj.divid+"#hdnProductId"+i) .val()> 0){
					row_i++;
					//setProductPriceTax(i);
				}
			}
			getAccountForDiscountRate(mid,0);
			if(row_i >= 1){
				var divobj = createElementDivs('getAccountForProductPrice');
				ld(divobj).find('.D_pop_tit .D_ptita').html(arrJsPopLabel['Reminder1']);
				var content_html = '';
				content_html += '<div class="qui_dialog_body ww_dialog_body" id="wechat_showTips">'
                content_html += '<div class="msgDlg">';
                content_html += '<div class="msgDlg_left">';
                content_html += '<div class="ww_commonImg ww_commonImg_Alert msgDlg_left_icon"></div>';
                content_html += '</div>';
                content_html += '<div class="msgDlg_right">';
                content_html += '<div class="msgDlg_right_text">'+arrJsPopLabel['youhavechangedcustomname']+'</div>';
                content_html += '</div></div></div>';
				ld('#getAccountForProductPricecontent').html(content_html);
				ld(divobj).css('max-height','500px');
				ld(divobj).css('width','450px');
				ld(divobj).css('background','#FDFDFD');
				ld('#getAccountForProductPricecontent').css('max-height','400px');
				ld('#getAccountForProductPricecontent').css('border','none');
				fnvshobj('', 'getAccountForProductPrice');
				ld(divobj).find('div.D_pbtn').addClass('ww_dialog_foot');
				ld(divobj).find('div.D_pbtn .D_pbtnok').unbind('click').on('click',function(){
				    
                      /**
                    * edit:chj
                    * date:2014-5-8
                    * reason: 如果客户有扣率则直接在产品明细中带出
                    */
                	//合同订单选择客户，如果客户有扣率则直接在产品明细中带出
                	//if(module == 'SalesOrder'&& account_id > 0){
                	   //if(gVTModule=="SalesOrder"||gVTModule=="Quotes");
                       
                	           	
                	//}
                    if(fieldformulaobj.version_trade != 'jiangjing'){
						for(var i = 1; i <= row_i; i++){
							setProductPriceTax(i);
						}
					}
                    
					fninvshnew('getAccountForProductPrice');puyoungJS_DialogBox.unblock();
                    
				});
			}
		}
	}
}
/**
 * 选择单据 带出关联信息
 * @param
 * @returns
 * @author Chj 
 */
function getRelatedData(module,mid,columnname,rowid){
    var  prepopupobj=CrmPopup.getPopupObj("lastprev");
	var url = 'module=Users&action=UsersAjax&file=getRelatedData&ajax=true&selectmodule=true&relatedmodule='+module+'&recordid='+mid;
	if(rowid == '' && !empty(columnname)){
		url += '&columnname='+columnname;
	}
 
	var parentwindow=window;
	if(window.opener!=undefined){
		parentwindow=window.opener;
	}
    ldAjaxHtmlNoProgress('index.php',url ,function(ajaxhtml) {
        var res = eval('('+ ajaxhtml +')')?eval('('+ ajaxhtml +')'):JSON.parse(ajaxhtml);
        if(res['related_list'] != undefined && res['related_list'].length != undefined){
            for(var i= 0; i<res['related_list'].length; i++){
                ld.each(res['related_list'][i], function(related_type, related_info){
                    if(related_type == 'detail' || related_type == 'main'){
                        if(related_info.length > 0){
                            //明细
                            if(!empty(res['related_list'][i]['detail'])){
                                var tableobj=prepopupobj.getDetailTableObj();
                                var rowobj=ld(tableobj).find("tr[rowindex="+rowid+"]");

                                ld.each(res['related_list'][i]['detail'], function(key, related_info){
                                    ld.each(related_info, function(v_type, related_data){
                                        var input_name = related_data['input_name'];
                                        var input_value = related_data['value'];
                                        //var relatedfield_str = ld('#relatedfield_'+columnname).val();
                                        var relatedfield_str = ld(rowobj).find(' [name="relatedfield_'+columnname+'"]').first().val();
                                        if(v_type == 'rawValue'){

                                            if(ld(rowobj).find(' [detailcolumnname="'+input_name+'"]').size() > 0){
                                                ld(rowobj).find(' [detailcolumnname="'+input_name+'"]').val(input_value) ;
                                                if(empty(relatedfield_str)){
                                                    ld(rowobj).find(' [name="relatedfield_'+columnname+'"]').first().val(input_name+rowid)
                                                }else{
                                                    ld(rowobj).find(' [name="relatedfield_'+columnname+'"]').first().val(relatedfield_str+','+input_name+rowid)
                                                }
                                            }

                                        }else{
                                            if(ld(rowobj).find(' [detailcolumnname="span_'+input_name+'"]').size() > 0){
                                                ld(rowobj).find(' [detailcolumnname="span_'+input_name+'"]').html(input_value) ;
                                                if(empty(relatedfield_str)){
                                                    ld(rowobj).find(' [name="relatedfield_'+columnname+'"]').first().val('span_'+input_name+rowid)
                                                }else{
                                                    ld(rowobj).find(' [name="relatedfield_'+columnname+'"]').first().val(relatedfield_str+','+'span_'+input_name+rowid)
                                                }
                                            }

                                        }

                                        prepopupobj.fieldformulaobj.finishedcolumncount[input_name]=1;
                                        prepopupobj.fieldformulaobj.setValueByFormula( ld(rowobj).find(' [detailcolumnname="'+input_name+'"]'), ld(rowobj).attr("rowindex"));

                                        //edit:can 61484 【苏州灵当】V8.4.8.6（https://kh.xiaoshou360.com/suzhould/））报销平台->报销申请模块，发票实报金额设置了分录函数，但是不生效，演示账套也是同样的问题（系统部署在上海总部）
                                        prepopupobj.detail2mainformulaobj.CheckisComputer([input_name]);
                                        //edit:can 63863:V8.4.9.1 佣金单录入比例，第一次会带不出来佣金金额，不管是服务合同还是合同订单
                                        prepopupobj.fieldformulaobj.haveFinishedFormulaColumnsarr = new Array();
                                        prepopupobj.fieldformulaobj.finishedcolumncount=[];
                                    });

                                });
                            }else{//基本信息
                                ld.each(res['related_list'][i]['main'], function(key, related_info){
                                    ld.each(related_info, function(v_type, related_data){
                                        var input_name = related_data['input_name'];
                                        var input_value = related_data['value'];
                                        //负责人
                                        if(input_name == 'assigned_user_id'){
                                            if(v_type == 'rawValue'){
                                                selectAccountChangeSmownerid(1, '',input_value);
                                            }
                                        }else{
                                            if(ld('#'+prepopupobj.divid+' form[name="EditView"]').find('[name="'+input_name+'"]').size() > 0){
                                                ld('#'+prepopupobj.divid+' form[name="EditView"]').find('[name="'+input_name+'"]').get(0).value = input_value;
                                            }
                                            /*if(eval("parentwindow.document.EditView."+input_name) != undefined){
                                                eval("parentwindow.document.EditView."+input_name).value = input_value;
                                            }*/
                                        }
                                        //eval("document.EditView."+fieldname+"_name").value = '';

                                    });
                                });
                            }
                        }
                    }else if(related_type == 'main_sql'){//特殊
                        if(!empty(res['related_list'][i][related_type])){
                            ld.each(res['related_list'][i][related_type], function(key, related_info){
                                ld.each(related_info, function(input_name, input_value){
                                    //负责人
                                    if(input_name == 'assigned_user_id'){
                                        if(v_type == 'rawValue'){
                                            selectAccountChangeSmownerid(1, '',input_value);
                                        }
                                    }else{
                                        if(ld('#'+prepopupobj.divid+' form[name="EditView"]').find('[name="'+input_name+'"]').size() > 0){
                                            ld('#'+prepopupobj.divid+' form[name="EditView"]').find('[name="'+input_name+'"]').get(0).value = input_value;
                                        }
                                    }
                                });
                            });
                        }
                    }else if(related_type == 'main_more'){//1对多
                        if(!empty(res['related_list'][i][related_type])){
                            ld.each(res['related_list'][i][related_type], function(key, related_info){
                                ld.each(related_info, function(v_type, related_data){
                                    var input_name = related_data['input_name'];
                                    var input_value = related_data['value'];
                                    if(ld('#'+prepopupobj.divid+' form[name="EditView"]').find('[name="'+input_name+'"]').size() > 0){
                                        ld('#'+prepopupobj.divid+' form[name="EditView"]').find('[name="'+input_name+'"]').get(0).value = input_value;
                                    }
                                });
                            });
                        }
                    }
                });
            }
        }
        prepopupobj.fieldformulaobj.CountsubTotal();
    });
}
/**
 * 清除单据关联信息  表体
 * @param
 * @returns
 * @author 
 */
function clearRelatedFieldValue(jqueryobj,columnname){
    var rowobj=ld(jqueryobj).parent();
    while(ld(rowobj).prop('tagName')!='TR')
    {
        rowobj=ld(rowobj).parent();
    }
   // var columnname=ld(jqueryobj).attr("detailcolumnname");
//	ld('#'+columnname).val('');
    var popupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);//编辑或者新增界面
    var input_obj = ld(rowobj).find(" [detailcolumnname="+columnname+']');
    var before_value = input_obj.val();
    var rowid = ld(rowobj).attr('rowindex');
   // alert(columnname);
	//ld(rowobj).find(" [detailcolumnname="+columnname+'_name]').val(arrJsPopLabel['INPUTAKEYWORDSQUERY']);
	ld(rowobj).find(" [detailcolumnname="+columnname+'_name]').val('');
	ld(rowobj).find(" [detailcolumnname="+columnname+'_name]').attr("disabled",false);
	ld(rowobj).find(" [detailcolumnname="+columnname+'_name]').css("cursor","");
    input_obj.val('');

    //duan 20240926 分录字段变更后触发公共变化事件
    if(!empty(popupobj.common_field_event_obj) && before_value > 0 ){
        popupobj.common_field_event_obj.common_entry_changefun(input_obj,columnname,rowid);
    }

	getJsScript('include/js/detail_selectReference.js',function(){
		var fun_detail_selectReference = new detail_selectReference(jqueryobj,event,popupobj);
		var rowid = ld(rowobj).attr('rowindex');
		fun_detail_selectReference.clearRelatedModuleField(popupobj.module,columnname,rowid);
		return false;
	});
    if (account_version == 'probiotic'){
        clearRelatedModuleFieldPuluo(rowobj);
    }
	var relatedfield_str = ld(rowobj).find(" [name=relatedfield_"+columnname+"]").val();
	if(!empty(relatedfield_str)){
		var relatedfield_arr = relatedfield_str.split(',');
		for(var i = 0; i<relatedfield_arr.length; i++){
			if(ld('#'+relatedfield_arr[i]) != undefined){
				ld('#'+relatedfield_arr[i]).val('');
				ld('#'+relatedfield_arr[i]).html('');
				
			}
		}
		ld(rowobj).find(" [name=relatedfield_"+columnname+"]").val('');
        ld(rowobj).find(" [detailcolumnname="+columnname+']').val('');
		//调用计算公式
		popupobj.fieldformulaobj.CountFormulaColumn();
	}
	return false;
}
function selectAccountChangeSmownerid(account_id, account_name,smownerid){
    /* let prepopupobj=CrmPopup.getPopupObj("lastprev");
    if(account_id > 0 && ld('#'+prepopupobj.divid+' form[name="EditView"]').find('[name="module"]').size() > 0){
		 var EditViewModule = ld('#'+prepopupobj.divid+' form[name="EditView"]').find('[name="module"]').get(0).value;*/
    if(account_id > 0 && document.EditView.module != undefined){
        var EditViewModule = document.EditView.module.value;
		 if(EditViewModule == 'ServiceContracts' || EditViewModule == 'SalesOrder' || EditViewModule == 'PurchaseOrder'){
		  //Liver 2017-04-10 收/付款单不根据供应商带出负责人，刘影提交的需求bug
			 var fldname = 'assigned_user_id';//18287: 合同订单、收款单、付款单-新增界面：选择客户名称和供应商名称后，负责人没有自动更新为该客户或供应商的“负责人”
             //edit:can reason:15312: 服务合同模块的“销售负责人”改进：新增时，销售负责人默认显示为当前操作员，选择客户后不需要自动更新为该客户的“负责人”。
             if(EditViewModule == 'ServiceContracts')
             {
                 fldname="ServiceContractsassigned_user_id";//edit:can reason:14542: 服务合同>新增：新增时，销售负责人默认显示为当前操作员，选择客户后没有自动更新为该客户的“负责人”。
             }
             
			 if(document.getElementById(fldname) != undefined){
				var objoption=document.getElementById(fldname);
				var optiontext='';
				picklist=true;
				if(objoption.length != undefined){
					for(var i=0;i<objoption.length;i++)
					{
					  
						if(objoption[i].value==smownerid)
						{
							objoption[i].selected=true;
							optiontext=objoption[i].text;
                            
							document.getElementById(fldname).options[i].selected=true;
						 
							document.getElementById(fldname).selectedIndex=i;
							document.getElementById(fldname).options[i].value=smownerid;
							if(typeof document.getElementById(fldname).onchange=='function')
								document.getElementById(fldname).onchange();
							if(typeof(fielddepend)!='undefined'&&fielddepend!=undefined)
							{
								var sourcename = objoption.name;
								var sourcevalue = objoption.value;	
								fielddepend.fieldValueChange(sourcename, sourcevalue);
							}
							break;
						}
					}
                    
					document.getElementById('cmb_span_optiontext_'+fldname).value=optiontext;
                   
				}
			 }
		 }
	 }
    
}

/*
*新增操作 by andy
*联系记录新增项目任务字段，弹出窗
*date:20140108
*/
function selectprojecttask(mod)
{
	// To support both B2B and B2C model
	var record_id = '';
	var parent_module = '';
    var account_id = '';
	var acc_element = document.EditView.projectid;
	var accountid = document.EditView.account_id;
    var module=document.EditView.module.value;
    
	if (acc_element != null) {
		record_id= acc_element.value;
        account_id= accountid.value;
		parent_module = 'ProjectTask';
	}
	if(record_id != ''){
		window.open("index.php?module=ProjectTask&action=Popup&html=Popup_picker&popuptype=specific&form=EditView&relmod_id="+record_id+"&projectid="+record_id+"&parent_module="+parent_module+"&fromModule=1&account_id="+account_id,"test","width=840,height=602,resizable=1,scrollbars=1");
	}else{
		window.open("index.php?module=ProjectTask&action=Popup&html=Popup_picker&popuptype=specific&form=EditView&account_id="+account_id,"test","width=840,height=602,resizable=1,scrollbars=1");
    }

}

/* editor:gyq_12 reason:新增查重显示列字段设置 date:20160601 */
function search_accounts(obj,module,fromtype='')
{
	var prevpopupobj=CrmPopup.getPopupObj("last");
	var divid = prevpopupobj.divid;
    var module_use = module;
    if(module == 'ServiceCharge') //服务收费管理模块调用客户查重功能
        module_use = 'Accounts';
    var action_type = 'datadup_load';
	var search_content = encodeURIComponent(CrmPopup.findHtmlobj(divid,'cheack_repeat_columnname').val());
    var hyperlinkobj = ld('#'+divid+' [name=hyperlink]');
    var strurl ='index.php?module='+module_use+'&action='+module_use+'Ajax&file=duplicate_related_popu&action_type='+action_type+'&ajax=true&search_content='+search_content+"&modulename="+module_use;
    strurl += '&search=true&fromtype='+fromtype;
    if(hyperlinkobj.length>0){ //超链接存在则添加返回值，否则非管理员查重时不显示超链接
        var hyperlink = (hyperlinkobj.is(':checked')=== true) ? '0':'1'; //数据库 显示超链接 0：显示  1：不显示
        strurl +="&hyperlink="+hyperlink;
    }
    var joinCheckDuplicateobj = ld('#'+divid+' [name=joinCheckDuplicate]');
    if(joinCheckDuplicateobj.length>0){
        var joinCheckDup = (joinCheckDuplicateobj.is(':checked')=== true) ? 'yes':'no'; //是否开启联合查询 yes：显示  no：不显示
        strurl +="&joinCheckDup="+joinCheckDup+"&accountname="+joinCheckDup;
    }
    strurl += '&duplicateviewwidth='+ld('#'+divid).width();
	ldAjaxNoProgress(strurl,'',function(data){
        if(data.code==1){
            if($("status") != undefined)
                $("status").style.display="none";
                CrmPopup.findHtmlobj(divid,'div_check_repeat').html(data.result.content);

                CrmPopup.findHtmlobj(divid,'cheack_repeat_columnname').keypress(function(event){
                var  e=window.event||event;
                if(e.keyCode==13){
                    search_accounts(null,module);
                }
            });
            if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                //通讯录(pc端企业微信要绑定)
                cls_wxOpenDataobj.bindAllOpenData();
            // if(fromtype=='settings'){
                prevpopupobj.center();//查重-联合查重按钮点击后,居中弹窗(先不修改其他情况)
            // }

            var crmPopupobj=CrmPopup.getPopupObj("last");

            if (crmPopupobj.modulelistresizeobj){
                ld.each(crmPopupobj.modulelistresizeobj,function (module,obj) {
                    obj.setPopupResizeTable_Init(module);
                })
            }

            // 需要去掉的给高度
            crmPopupobj.reduceBodyHeight = 0;
            if(ld('#'+crmPopupobj.divid + ' .ld-description').length > 0){
                crmPopupobj.reduceBodyHeight += parseInt(ld('#'+crmPopupobj.divid + ' .ld-description').outerHeight());
            }
            // 设置内容最大高度
            crmPopupobj.setPopBodyMaxHeight(".ld-pop-container");
        }
        else if(data.code==-2){
            var confirm_str = data.msg;
            MessagePopup.TipZero_warning(confirm_str);
        }
    });
}

function look_check_repeats(obj,module){
	var prevpopupobj=CrmPopup.getPopupObj("last");
	var divid = prevpopupobj.divid;
    var labelname = CrmPopup.findHtmlobj(divid,'datadup_icon').attr("labelname");;
	//先在序时簿列表查重，再在新建编辑等页面客户名称字段查重时look_check_repeat.pagetype的判断不严谨
    if(look_check_repeat.pagetype=='listview' && prevpopupobj.pagetype == "listpage"){
        var name_check='';
    }
    else{
        look_check_repeat.pagetype = 'editview';
        var name_check=CrmPopup.findHtmlobj(divid,labelname).val();
    }
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",module,"",'none',"","");
	crmPopupobj.prevshow();
   
	var module_use = module;
    var action_type = 'datadup_load';
    if(module == 'ServiceCharge') //服务收费管理模块调用客户模块查重功能
        module_use = 'Accounts';
    var tmpurlsting = 'index.php?module='+module_use+'&action='+module_use+'Ajax&file=duplicate_related_popu&action_type='+action_type+'&ajax=true&search_content='+encodeURIComponent(name_check)+"&modulename="+module_use;
    tmpurlsting += '&duplicateviewwidth=868';//"LdPopWidth800px" = 868px
    ldAjaxNoProgress(tmpurlsting,'',function(data){
        if(data.code==1){
            if($("status") != undefined)
                $("status").style.display="none";
            crmPopupobj.setParams(data.result.title,"","","LdPopWidth650px",module,"","","","");
            crmPopupobj.quickcreatehtml=data.result.content;
            crmPopupobj.show(data.result.content);

            if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                //通讯录(pc端企业微信要绑定)
                cls_wxOpenDataobj.bindAllOpenData();

            CrmPopup.findHtmlobj(crmPopupobj.divid,'cheack_repeat_columnname').keypress(function(event){
                var  e=window.event||event;
                if(e.keyCode==13)
                {
                    search_accounts(null,module);
                }
            });

            //加载列表列宽拖拽和记住
            crmPopupobj.pop_type = 'duplicatePopup';

            crmPopupobj.modulelistresizeobj = {};
            var tmp_module = crmPopupobj.module;
            ld.each(data.result.listModule,function (index,module) {
                crmPopupobj.module = module;
                var listresizeobj=new List_ResizeTable(crmPopupobj);
                crmPopupobj.modulelistresizeobj[module] = listresizeobj;
                listresizeobj.setPopupResizeTable_Init(module);
            })
            crmPopupobj.module = tmp_module;

            // 需要去掉的给高度
            crmPopupobj.reduceBodyHeight = 0;
            if(ld('#'+crmPopupobj.divid + ' .ld-description').length > 0){
                crmPopupobj.reduceBodyHeight += parseInt(ld('#'+crmPopupobj.divid + ' .ld-description').outerHeight());
            }
            // 设置内容最大高度
            crmPopupobj.setPopBodyMaxHeight(".ld-pop-container");
        }
    });
}

//edit:duan  山水：多选用户字段，选择按钮，可选择多条用户单据
function selectMoreRecord(module,fieldname,selectmodule){
    var popupobj=CrmPopup.getPopupObj("last");
    var prevpopupobj=CrmPopup.getPopupObj("lastprev");
    var selected_objs = ld("#"+popupobj.divid+" [name=selected_id]");
    var allselected_obj = ld("#"+popupobj.divid+" [name=select_all]");
    var cur_sequence = parseInt(allselected_obj.attr('cur_sequence'));
    
    var id_str= ld("#"+prevpopupobj.divid+" input[name="+fieldname+"]").val();
    var value_str= ld("#"+prevpopupobj.divid+" input[name="+fieldname+"_name]").val();
    var value_arr = new Array();
    var id_arr = new Array();
    if(value_str !=''&&id_str !=''){
        value_arr = value_str.split(',');
        id_arr =  id_str.split(',');
    }
    
    var tmp_id = 0;
    var tmp_value = '';
    var count = 0;
    var sequence = 0;
    var i = 0;
    var tmp_objs ;
    
    for(i=0;i<cur_sequence;i++){
        ld.each(selected_objs,function(){
            sequence = ld(this).attr('sequence');
            if(ld(this).is(':checked')&&sequence==i){
                tmp_id = ld(this).attr('billinfo');
                //已选择的用户不再加入
                if(tmp_id>0&&id_arr.indexOf(tmp_id)==-1){
                    tmp_value = ld(this).attr('link_field_value');
                    id_arr.push(tmp_id);
                    value_arr.push(tmp_value);
                }
                count++;
            }
        });
    }
    
    if(count==0){
        audioRemindsMsg("","LdPopWidth400px","","yes","yes","");
        return false;
    }
    id_str = id_arr.toString();
    value_str = value_arr.toString();
    
    ld("#"+prevpopupobj.divid+" input[name="+fieldname+"]").val(id_str);
    ld("#"+prevpopupobj.divid+" input[name="+fieldname+"_name]").val(value_str);
    ld("#"+prevpopupobj.divid+" input[name="+fieldname+"_name]").attr("title",value_str);
    ld("#"+prevpopupobj.divid+" input[name="+fieldname+"_name]").attr("disabled",true);
    ld("#"+prevpopupobj.divid+" input[name="+fieldname+"_name]").css("cursor",'not-allowed');
    ld("#"+prevpopupobj.divid+" input[name="+fieldname+"]").change();
    
    popupobj.CancelEvent();
}
//edit:duan  山水：多选用户字段，单选按钮，根据选择顺序显示结果
function SpecialUserSelectAll(obj,selectAllName,sel_id) {
    var popupobj=CrmPopup.getPopupObj("last");
    var divid = popupobj.divid;
    var relCheckName = ld(obj).attr('name');
    var selected_objs = ld("#"+divid+" [name="+relCheckName+"]");
    var allselected_obj = ld("#"+divid+" [name="+selectAllName+"]");
    var all_selected = 'yes';
    var cur_sequence = parseInt(allselected_obj.attr('cur_sequence'));

    if(ld(obj).is(':checked')){
        ld(obj).attr('sequence',cur_sequence);
        allselected_obj.attr('cur_sequence',cur_sequence+1);
        ld.each(selected_objs,function(){
           if(ld(this).is(':checked')){   
           }else{
            all_selected = 'no';
           }
        });
        if(all_selected == 'yes'){
            allselected_obj.prop('checked',true);
        }
    }else{
        allselected_obj.prop('checked',false);
        ld(obj).attr('sequence',-1);
    }
}
//edit:duan  山水：多选用户字段,全选按钮
function SpecialUserSelect(obj,relCheckName) {
    var popupobj=CrmPopup.getPopupObj('last');
    var divid = popupobj.divid;
    var selected_objs = ld("#"+popupobj.divid+" [name="+relCheckName+"]");
    ld(obj).attr('cur_sequence',1);
    selected_objs.prop('checked',ld(obj).is(':checked'));
    
    if(ld(obj).is(':checked')){
        selected_objs.attr('sequence',0);
        ld('input[name=selected_id]').parent().parent().attr('class','lvtColDataSelected');
    }else{
        selected_objs.attr('sequence',-1);
        ld('input[name=selected_id]').parent().parent().attr('class','lvtColDataBj');
        var checkObj = document.getElementsByName(relCheckName);
        for(var i=0;i<checkObj.length;i++){
            var rows = "row_"+checkObj[i].value;
            if(document.getElementById(rows) != undefined){
                if((i+1)%2==1){
                    document.getElementById(rows).className = "lvtColData";
                }
                else{
                    document.getElementById(rows).className = "lvtColDataBj";
                }
            }
        }
    }
}
//山水-推荐设计师界面增加规则说明
function show_description(){
    var idname = 'RulesDescription';
    fnvshobj('',idname);
}

//ls 20221111 XUQIU1000848  普罗定制开发表单特殊带入需求(支持多选)
function selectMoreRecordForPuluo(module,fieldname,selectmodule) {
    var popupobj=CrmPopup.getPopupObj("last");
    var prevpopupobj=CrmPopup.getPopupObj("lastprev");

    var formObj = ld("#"+popupobj.divid+" [name=popupListViewContents]");
    var x = formObj.find('input[name="selected_id"]').size();
    var y=0;
    if(x > 0){
        var idstring='';
        var record = '';

        formObj.find('input[name="selected_id"]').each(function(index,element){
            //获取选中的单据id
            if(ld(this).prop("checked")){
                if(record === ''){
                    record = ld(this).attr('billinfo');
                }
                idstring = ld(this).val()+";"+idstring;
                y = y + 1;
            }
        });
    }

    if (y > 0) {
        var id_str = [];
        var ids = idstring.split(';');
        for(var i = 0; i< ids.length; i++){
            var id_arr = ids[i].split('_');
            id_str[i] = id_arr[0];
        }

        var ids = id_str.join(',');

        getValuePuluo(module,fieldname,selectmodule,ids);

    }else{
        var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }
    popupobj.CancelEvent();
}
//普罗多选确定或者单选超连接字段时，获取日报信息并赋值
function getValuePuluo(module,fieldname,selectmodule,ids) {
    var urlstring = 'index.php?module='+module+'&action='+module+'Ajax&file=GetDailyReportInfo&idstring='+ids+'&selectmodule='+selectmodule;
    ldAjax(urlstring,{},function(data){
        if(data.code == 1){
            var res_arr = data.result;//关联单据返回值

            // var popupobj=CrmPopup.getPopupObj("last");
            var popupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
            var trobjs=popupobj.getTrObjsByDelType('no');//获取没有删除的行

            // var rowcnt = ld(trobjs).length;//总行
            var select_rowid = 0;	//赋值行

            var emptyrows=[];//记录空行的rowindex
            var startemptyrowindex=0;//空行的索引下标
            ld.each(trobjs,function(){
                //获取空行
                if(ld(this).find(' [name="'+fieldname+'"]').val()==''||ld(this).find(' [name="'+fieldname+'"]').val()==0)
                {
                    emptyrows.push(ld(this).attr("rowindex"));
                }
            })
            var entmprowslen=emptyrows.length;

            var tableobj=popupobj.getDetailTableObj();
            var recordid = '';
            for(var i = 0; i<res_arr.length; i++){
                select_rowid = 0;
                //有空行时，默认从第一个空行开始赋值
                if (entmprowslen>0 && startemptyrowindex<entmprowslen) {//如果有空行且空行还没有用完
                    select_rowid=emptyrows[startemptyrowindex];

                    if(empty(select_rowid)){//异常情况时
                        select_rowid = fnAddTabDetailRow(module);
                    }
                    startemptyrowindex++;
                }else{
                    select_rowid = fnAddTabDetailRow(module);
                }
                var rowobj=ld(tableobj).find("tr[rowindex="+select_rowid+"]");//赋值的行对象;
                var rowindex=ld(rowobj).attr("rowindex");


                recordid = res_arr[i]['recordid'];
                ld(rowobj).find(" input[name="+fieldname+"]").val(recordid);
                ld(rowobj).find(" input[name="+fieldname+"_name]").val(res_arr[i]['recordino']);
                ld(rowobj).find(" input[name="+fieldname+"_name]").attr("title",res_arr[i]['recordino']);
                ld(rowobj).find(" input[name="+fieldname+"_name]").attr("disabled",true);
                ld(rowobj).find(" input[name="+fieldname+"_name]").css("cursor",'not-allowed');

                if (module == 'CustomForm26' && selectmodule == 'CustomForm23') {//日常费用报销单 选 优马工作日报
                    ld(rowobj).find("[name=sf333]").val(res_arr[i]['cf_5433']);//日期
                    ld(rowobj).find("[name=sf334]").val(res_arr[i]['cf_5435']);//行程
                    ld(rowobj).find(" [name=sf344]").val(res_arr[i]['sf345']);//交通工具   下拉框
                    ld(rowobj).find(" [name=cmb_span_optiontext_sf344]").val(res_arr[i]['sf345']);
                    ld(rowobj).find("[name=sf335]").val(res_arr[i]['sf306']);//长途跨区
                    ld(rowobj).find("[name=sf336]").val(res_arr[i]['sf307']);//短途特殊费用
                    ld(rowobj).find("[name=sf337]").val(res_arr[i]['sf308']);//短途车费
                    ld(rowobj).find("[name=sf339]").val(res_arr[i]['sf309']);//住宿费用
                    ld(rowobj).find("[name=sf341]").val(res_arr[i]['sf310']);//日补助
                    ld(rowobj).find("[name=remark]").val(res_arr[i]['remark']);//备注
                    ld(rowobj).find("[name=sf488]").val(res_arr[i]['sf491']);//公路水路实名客票/公路通行费电子普票/滴滴车票
                    ld(rowobj).find("[name=sf489]").val(res_arr[i]['sf492']);//桥/闸通行费
                    ld(rowobj).find("[name=sf499]").val(res_arr[i]['sf497']);//住宿费税率%(普票税率选0)
                    ld(rowobj).find("[name=cmb_span_optiontext_sf499]").val(res_arr[i]['sf497']);

                    ld(rowobj).find("[name=sf341]").change();
                    ld(rowobj).find(" input[name=sf335]").change();//日常费用报销单 长途跨区触发计算
                }
                else if(module == 'CustomForm26' && selectmodule == 'CustomForm22'){//日常费用报销单 选 耕道工作日报
                    ld(rowobj).find("[name=sf333]").val(res_arr[i]['cf_5307']);//日期
                    ld(rowobj).find("[name=sf334]").val(res_arr[i]['cf_5309']);//行程
                    ld(rowobj).find(" [name=sf344]").val(res_arr[i]['sf346']);//交通工具   下拉框
                    ld(rowobj).find(" [name=cmb_span_optiontext_sf344]").val(res_arr[i]['sf346']);
                    ld(rowobj).find("[name=sf335]").val(res_arr[i]['sf299']);//长途跨区
                    ld(rowobj).find("[name=sf336]").val(res_arr[i]['sf298']);//短途特殊费用
                    ld(rowobj).find("[name=sf337]").val(res_arr[i]['sf300']);//短途车费
                    ld(rowobj).find("[name=sf339]").val(res_arr[i]['sf301']);//住宿费用
                    ld(rowobj).find("[name=sf341]").val(res_arr[i]['sf302']);//日补助
                    
                    ld(rowobj).find("[name=remark]").val(res_arr[i]['remark']);//备注
                    ld(rowobj).find("[name=sf488]").val(res_arr[i]['sf494']);//公路水路实名客票/公路通行费电子普票/滴滴车票
                    ld(rowobj).find("[name=sf489]").val(res_arr[i]['sf495']);//桥/闸通行费
                    ld(rowobj).find("[name=sf499]").val(res_arr[i]['sf498']);//住宿费税率%(普票税率选0)
                    ld(rowobj).find("[name=cmb_span_optiontext_sf499]").val(res_arr[i]['sf498']);

                     ld(rowobj).find("[name=sf341]").change();
                     
                    ld(rowobj).find(" input[name=sf335]").change();//日常费用报销单 长途跨区触发计算
                }
                else if(module == 'CustomForm25' && selectmodule == 'CustomForm23'){//私车公用报销单 选 优马工作日报
                    ld(rowobj).find("[name=sf323]").val(res_arr[i]['cf_5433']);//日期
                    ld(rowobj).find("[name=sf325]").val(res_arr[i]['cf_5435']);//起讫地点
                    ld(rowobj).find("[name=sf332]").val(res_arr[i]['cf_5436']);//里程记录

                    ld(rowobj).find("[name=sf327]").val(res_arr[i]['sf448']);//路桥费
                    ld(rowobj).find("[name=sf328]").val(res_arr[i]['sf449']);//停车费
                    ld(rowobj).find("[name=sf330]").val(res_arr[i]['sf450']);//补贴标准
                    ld(rowobj).find("[name=remark]").val(res_arr[i]['remark']);//备注

                    ld(rowobj).find(" input[name=sf327]").change();//私车公用报销单 路桥费触发计算
                    ld(rowobj).find(" input[name=sf332]").change();//补贴费用计算
                }
                else if(module == 'CustomForm25' && selectmodule == 'CustomForm22'){//私车公用报销单 选 耕道工作日报
                    ld(rowobj).find("[name=sf323]").val(res_arr[i]['cf_5307']);//日期
                    ld(rowobj).find("[name=sf325]").val(res_arr[i]['cf_5309']);//起讫地点
                    ld(rowobj).find("[name=sf332]").val(res_arr[i]['cf_5310']);//里程记录

                    ld(rowobj).find("[name=sf327]").val(res_arr[i]['sf453']);//路桥费
                    ld(rowobj).find("[name=sf328]").val(res_arr[i]['sf454']);//停车费
                    ld(rowobj).find("[name=sf330]").val(res_arr[i]['sf452']);//补贴标准
                    ld(rowobj).find("[name=remark]").val(res_arr[i]['remark']);//备注

                    ld(rowobj).find(" input[name=sf327]").change();//私车公用报销单 路桥费触发计算
                    ld(rowobj).find(" input[name=sf332]").change();//补贴费用计算
                }

                getJsScript('include/js/detail_selectReference.js',function(){
                    var reference_arr=[];
                    reference_arr.push(selectmodule);
                    reference_arr.push(module);
                    reference_arr.push(fieldname);
                    reference_arr.push(rowindex);
                    // console.log(reference_arr);
                    var fun_detail_selectReference = new detail_selectReference(reference_arr,'',popupobj);
                    fun_detail_selectReference.getRelatedModuleField(selectmodule,recordid,rowindex,fieldname);
                });

            }
            // ld("#"+popupobj.divid+" input[name=sf335]").change();
            popupobj.fieldformulaobj.CountsubTotal();//小计
            // 分类计算主表字段
            // popupobj.detail2mainformulaobj.changeRowEvent();

        }
        DelProgressObjs();
    })
}
//普罗点清除按钮时
function clearRelatedModuleFieldPuluo(rowobj) {
    ld(rowobj).find("[name=sf333]").val('');//日期
    ld(rowobj).find("[name=sf334]").val('');//行程
    ld(rowobj).find(" [name=sf344]").val('');//交通工具   下拉框
    ld(rowobj).find(" [name=cmb_span_optiontext_sf344]").val('');
    ld(rowobj).find("[name=sf335]").val(0);//长途跨区
    ld(rowobj).find("[name=sf336]").val(0);//短途特殊费用
    ld(rowobj).find("[name=sf337]").val(0);//短途车费
    ld(rowobj).find("[name=sf339]").val(0);//住宿费用
    ld(rowobj).find("[name=sf341]").val(0);//日补助
    ld(rowobj).find("[name=remark]").val('');//备注
    ld(rowobj).find(" input[name=sf335]").change();//日常费用报销单

    ld(rowobj).find("[name=sf323]").val('');//日期
    ld(rowobj).find("[name=sf325]").val('');//起讫地点
    ld(rowobj).find("[name=sf332]").val('');//里程记录
    ld(rowobj).find("[name=sf327]").val(0);//路桥费
    ld(rowobj).find("[name=sf328]").val(0);//停车费
    ld(rowobj).find("[name=sf330]").val(0);//补贴标准
    ld(rowobj).find("[name=remark]").val('');//备注
    ld(rowobj).find(" input[name=sf327]").change();//私车公用报销单
        ld(rowobj).find("[name=sf341]").change(0);//日补助
    ld(rowobj).find(" input[name=sf332]").change();
    var popupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);//编辑或者新增界面
    popupobj.fieldformulaobj.CountsubTotal();//小计
}

//lius 20231121 XUQIU1002192【 广东金瓷三维】开发报价单中历史产品报价、成交价的弹框显示，并且带出分录信息。（CustomFrom35 点击物料号后弹窗）
function getEntryPopupJinci(obj){

    var event = event || window.event;
    var srcElement = event.srcElement || event.target;

    var popupobj = CrmPopup.getPopupObj('last');

    var rowobj = popupobj.getTrObjByChild(ld(srcElement));//考虑拖动换行 ，那么rowId变量要重新赋值
    var rowId = ld(rowobj).attr("rowindex");

    var cur_module = popupobj.selectproductobj.cur_module;

    var account_id = CrmPopup.getHtmlobjval(popupobj.divid,'account_id');
    var surl = "module="+cur_module+"&action="+cur_module+"Ajax&file=Popupjinci";
    surl += "&popup=yes&curr_row=" + rowId + "&frommodule=" + cur_module + "&account_id=" + account_id;

    // 客户和产品必须先选
    if(empty(account_id)){
        MessagePopup.TipOne_warning("请先选择客户！");
        return false;
    }
    if (cur_module == "CustomForm35") { //3D砂型报价申请：通过“物料号”字段判断
        var product_no = ld(rowobj).find(" [detailcolumnname=sf706]").val();//物料号
        if (empty(product_no)){
            MessagePopup.TipOne_warning("请先填写物料号！");
            return false;
        }

        surl += "&product_no=" + encodeURIComponent(product_no);
    }else if(cur_module == "CustomForm23"){//商贸报价申请：通过“产品名称”、”用户物料识别信息”、“材质”字段判断
        var productname = ld(rowobj).find(" [detailcolumnname=sf714]").val();
        if (empty(productname)){
            MessagePopup.TipOne_warning("请先填写产品名称！");
            return false;
        }

        var wuliao = ld(rowobj).find(" [detailcolumnname=sf715]").val();//用户物料识别信息
        var caizhi = ld(rowobj).find(" [detailcolumnname=sf716]").val();//材质
        surl += "&productname=" + encodeURIComponent(productname) + "&wuliao=" + encodeURIComponent(wuliao) + "&caizhi=" + encodeURIComponent(caizhi);
    }



    var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth1300px", cur_module, "", 'none', "", "");
    crmPopupobj.prevshow();
    ldAjax('index.php?'+surl,'',function(data){
        if(data.code==1){
            ld('#rptContentLoading').hide();
            crmPopupobj.setParams(data.result.title,"","","LdPopWidth1300px",cur_module,"","","","");
            crmPopupobj.show(data.result.content);
        }
    })

}
//普通分录的两个自定义报价单模块
setEntryInfojinci = function (rowid,selectmodule,recordid,lineitem_id) {
    // console.log(rowid,selectmodule,recordid,lineitem_id);
    if (this.debounceTimer) {
        clearTimeout(this.debounceTimer);
    }
    this.debounceTimer = setTimeout(() => {
        var prevpopupobj = CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);

        var popupobj = CrmPopup.getPopupObj('last');
        popupobj.CancelEvent();

        var cur_module = prevpopupobj.module;
        var urlstring = "module="+cur_module+"&action="+cur_module+"Ajax&file=Popupjinci&operation=getentryinfo";
        urlstring += '&rowid=' + rowid + '&frommodule=' + cur_module+ '&selectmodule=' + selectmodule + '&recordid=' + recordid + '&lineitem_id=' + lineitem_id
        // urlstring += "&requestvalues=" + getPageValueByCrmPopupFields(prevpopupobj);

        ldAjax('index.php?'+urlstring,'',function(data){
            if(data.code==1){
                ld('#rptContentLoading').hide();

                var prod_array = data.result;
                var tableobj=prevpopupobj.getDetailTableObj();
                var rowobj=ld(tableobj).find("tr[rowindex="+rowid+"]");
                for (var columnname in prod_array) {
                    if(ld(rowobj).find(' [detailcolumnname="span_'+columnname+'"]').size() > 0){//单据编号等不可编辑分录字段
                        ld(rowobj).find(' [detailcolumnname="span_'+columnname+'"]').text(prod_array[columnname]);
                    }
                    if(ld(rowobj).find(' [detailcolumnname="'+columnname+'"]').size() > 0){
                        ld(rowobj).find(' [detailcolumnname="'+columnname+'"]').val(prod_array[columnname]);

                        ld(rowobj).find('  [detailcolumnname="'+columnname+'"]').change();//触发字段公式事件
                    }
                }
            }
        })
    }, 200);
}