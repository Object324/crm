//切换页签
function getWorkSheetStatus(status,obj){
    if(obj!=null){
        var liobjs = ld('ul[class=ld-ui-tabs-nav]').children();
        ld.each(liobjs,function(){
            ld(this).removeClass();
        })

        ld(obj).addClass('ld-ui-tabs-active');
    }
    
    var url = 'worksheet_status='+status;
    getListViewEntries_js('WorkSheet',url);  
}

//选择配件
function changepart(rowid){
    var popupobj=CrmPopup.getPopupObj('last');
    //产品信息区块
    popupobj.js_detailtablename='newproTab';
    var tableobj=popupobj.getDetailTableObj();
    var rowobj=ld(tableobj).find("tr[rowindex="+rowid+"]");
    var productid = ld(rowobj).find('[name=hdnProductId]').val();
    popupobj.related_productid = productid;
    var popuptype = 'inventory_prod';
    var selectenable="&select=enable";
    //配件信息区块
    popupobj.js_detailtablename='proTab';
    popupobj.selectproductobj.tableobj = popupobj.getDetailTableObj();
    popupobj.selectproductobj.popup_selectsource = false;
    var trobjs=popupobj.getTrObjsByDelType("no");
    var curr_row = trobjs.length;
     
    if(curr_row==0){
        popupobj.detaildatavalue_arr = [];
    }

    //BUG20240322-16 ls 240725 	工单管理新建界面，选择源单更换配件选择产品后，再删除配件产品，再次点击更换配件（未选产品）时，配件信息区块会自动新增一行明细
    var  proTabtableobj=ld("#" + popupobj.divid + " [name=proTab]");
    var  proTablastTr = ld(proTabtableobj).find('tr:last');
    if (curr_row>0 && empty(ld(proTablastTr).find('[name=hdnProductId]').val())) {
    }else{
        popupobj.selectproductobj.fnaddProductRow();
        //选择配件时添加信息的目标行号要加1，否则会删除最后一行的信息
        curr_row++;
    }

    
    var surl="module=Products&action=Popup&popup=yes&page_popup=yes"+selectenable+"&html=Popup_picker&form=HelpDeskEditView&popuptype="+popuptype+"&curr_row="+curr_row+"&return_module="+popupobj.module+"&currencyid="+popupobj.selectproductobj.currencyid+"&frommodule="+popupobj.module;
    
    if(empty(productid)){
        var confirmstr = arrJsPopLabel['PLEASESELECTPRODUCT'];
        audioRemindsMsg("","","","","",confirmstr);
        return false;
    }else{
        surl+= "&related_productid="+productid;
    }
     CrmPopupWindow(popupobj.module,surl,'Products');
}
//切换选择配件按钮状态
function reportrepair(rowid,obj){
    var popupobj=CrmPopup.getPopupObj('last');
    popupobj.js_detailtablename='newproTab'; 
    var tableobj=popupobj.getDetailTableObj();
    var rowobj=ld(tableobj).find("tr[rowindex="+rowid+"]");
    if(ld(obj).is(':checked')){
        ld(rowobj).find("[name=changepart]").show();
    }else{
        ld(rowobj).find("[name=changepart]").hide();
    }
    popupobj.js_detailtablename='proTab';
}
//删除一行配件信息
function deletepart(rowid){
    var event=event||window.event;
    var srcElement=event.srcElement||event.target;
   
    var popupobj=CrmPopup.getPopupObj('last');
    var rowobj=popupobj.getTrObjByChild(ld(srcElement));//因为每次删除会重定义行号，那么rowId变量要重新赋值
    rowid=ld(rowobj).attr("rowindex");
    popupobj.js_detailtablename='proTab';
    var tableobj = popupobj.getDetailTableObj();
    var trobjs = popupobj.getTrObjsByDelType("no");
    if(trobjs.length==1){//删除最后一行
        fun_selectproduct.btn_clearProductInfo_Row(rowid);
        var delrowobj=ld(tableobj).find("tr[rowindex="+rowid+"]");
        ld(delrowobj).remove();
        ld(tableobj).find("[rowindex="+rowid+"]").find("td:eq(0)").html('');
        return ;
    }
	else if(trobjs.length>1){//document.getElementById("row"+rowid) != undefined)
        var delrowobj=ld(tableobj).find("tr[rowindex="+rowid+"]");
        ld(delrowobj).remove();
        popupobj.fieldformulaobj.CountsubTotal();
		if(ld("#"+popupobj.divid+" [name=module]").size() > 0 && ld("#"+popupobj.divid+" [name=module]").get(0).value === 'TimeSheet'){
			setTimeSheet();
		}
	}
    popupobj.detaildatavalue_arr.splice(rowid-1,1);
    
    ShowSequence_new(popupobj);
    popupobj.fieldformulaobj.setAllRowEvent();
}
//重新对行号排序
function ShowSequence_new(popupobj){
    if(popupobj === undefined){
        return false;
    }
  
    var tableobj=popupobj.getDetailTableObj();
    var seqno=1;
    var rowindex=1;
   
    ld.each(ld(tableobj).find("tr"),function(tmpindex,obj){

            if(ld(obj).attr("detaildeleted")=='no'||ld(obj).attr("detaildeleted")=='yes')
            {
                ld(obj).attr("rowindex",rowindex);
                ld(obj).attr("row",rowindex);//历史遗留，暂时保留
                ld(obj).attr("name","row"+rowindex);//历史遗留，暂时保留
                rowindex++;
                
            }
            if(ld(obj).attr("detaildeleted")=='no')
            {
                ld(obj).children('td').eq(2).html(seqno);
                seqno++;
            }  
    })
    
}

//工单管理，因为原有的覆盖事件会导致两个分录同时生效，所以重写新的
function specialdetailOnMouseOver(jqueryobj){
     ld(jqueryobj).find("[span_seq_no=yes]").css("display",'none');
     ld(jqueryobj).find("[dv_operatetool=yes]").css("display",'block');
     ld(jqueryobj).addClass( "lvtColDataHover");
}
function specialdetailOnMouseOut(jqueryobj,type){
     ld(jqueryobj).find("[span_seq_no=yes]").css("display",'block');
     ld(jqueryobj).find("[dv_operatetool=yes]").css("display",'none');
    if(type == 'On'){
        ld(jqueryobj).removeClass("lvtColDataHover").addClass("lvtColDataBj");// document.getElementById(rows).className = "lvtColDataBj";
    }else{
        ld(jqueryobj).removeClass("lvtColDataHover").addClass("lvtColData");// document.getElementById(rows).className = "lvtColData";
    }
}

//保存原产品信息分录信息
function getpartdetailfieldurl(){
    var ret=true;
    var popupobj = CrmPopup.getPopupObj('last');
    var module=popupobj.module;
    popupobj.js_detailtablename='newproTab';
    var tableobj=popupobj.getDetailTableObj();
    var trobjs=popupobj.getTrObjsByDelType("no");
    
    var i=1;
    var url = '&worksheet_rowcnt='+ld(trobjs).length;

    var worksheet_sourcevalue = popupobj.selectproductobj.worksheet_sourcevalue_arr;
    
    ld.each(trobjs,function(){
        var trobj=ld(this);
        var productid = ld(this).find(" [name=hdnProductId]").val();
       
        if(ld.trim(productid)==''||parseInt(productid)<=0)
        {
            //判断是否为空行
            return true;
        }
        var paramname="worksheet_hdnProductId"+i;
        url += "&" + paramname + "=" + productid;
        var lineitem_name = "worksheet_lineitem_id" + i;
        // url += "&" + lineitem_name + "=" + ld(this).attr('value');
        url += "&" + lineitem_name + "=" + worksheet_sourcevalue[i-1]['lineitem_id'];
        /*
        var repairedobj = ld(this).find(" [name=repaired]");
        if(repairedobj.is(':checked')){
            url += "&worksheet_repaired"+i+"=yes";
        }else{
            url += "&worksheet_repaired"+i+"=no";
        }
        */
        url += "&worksheet_repaired"+i+"=yes";
        // url += "&worksheet_entitytype"+i+"="+ld(this).find(" [detailcolumnname=entitytype]").attr('value');
        // url += "&worksheet_entitytypeid"+i+"="+ld(this).find(" [detailcolumnname=entitytypeid]").attr('value');
        url += "&worksheet_entitytype"+i+"="+ worksheet_sourcevalue[i-1]['entitytype'];
        url += "&worksheet_entitytypeid"+i+"="+ worksheet_sourcevalue[i-1]['entitytypeid'];

        i++;
    });
    
    return url;
}
//切换选择源单后，配件信息和产品信息都要清空
function deleteAllPartinfo(obj){
    var popupobj = CrmPopup.getPopupObj('last');
    popupobj.js_detailtablename='proTab';
    var trobjs=popupobj.getTrObjsByDelType("no");
    ld.each(trobjs,function(){
        ld(this).remove();
    });
    ld("#"+popupobj.divid+" [name=productDiv]").hide();
    ld("#"+popupobj.divid+" [name=LastContent]").hide();
    ShowSequence_new(popupobj);
    popupobj.fieldformulaobj.setAllRowEvent();
    //切换报修产品分录字段
    changedetails(obj);
}
//根据源单类型切换分录字段
function changedetails(obj){
    var popupobj = CrmPopup.getPopupObj('last');
    var selectedmodule = ld(obj).val();
    var detailtrobj = ld("#"+popupobj.divid+" td[name=productdetailtabletd]");
    
    if(empty(selectedmodule)||selectedmodule == undefined){
        selectedmodule = ld('#'+popupobj.divid+' select[id=selectsource]').val();
        if(empty(selectedmodule)||selectedmodule == undefined){
            return false;
        }
    }
    var url = 'index.php?module=WorkSheet&action=WorkSheetAjax&file=getProductDetail';
    url += '&selectedmodule='+selectedmodule;
    ldAjax(url,'',function(data){
        DelProgressObjs();
        if(data.code==1){
            detailtrobj.html(data.result.htmlcontent);
            popupobj.selectproductobj. worksheettablecolumn_arr=data.result.headcolumn;
            setProductDivWidth(popupobj);
        }
    })
}
//领取工单
function receive_worksheet(){
    var popupobj=CrmPopup.getPopupObj('last');
    var idstring = "";
    var selectid =ld("#"+popupobj.divid+" [name=allselectedboxes]").val();
    var selectlen = 0;
    if (selectid != 'all') {//非全选状态，依次获取选中的单据ID
        var selectobj = document.getElementsByName("selected_id");
        var selectobjlen = selectobj.length;
        selectid = '';
        for (var i = 0; i < selectobjlen; i++) {
            if (selectobj[i].checked) {//获取选中的ID
                selectid += selectobj[i].value + ',';
                selectlen++;
            }
        }
        if (selectid == '') {//请至少选择一条记录
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", "");
            return false;
        }
    } else {
        selectlen = parseInt(document.getElementById('numOfRows').value);//获取全选的条数
    }
    
    var url = 'index.php?module=WorkSheet&action=WorkSheetAjax&file=receive_worksheet';
    url += '&selectid='+selectid+'&selectlen='+selectlen;
    ldAjax(url,'',function(data){
        DelProgressObjs();
        if(data.code==1){
            var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",module,"","","","");
			crmPopupobj.prevshow();
			crmPopupobj.setParams(data.result.title,cancel_received,"","LdPopWidth600px",module,"",data.result.oktext,"",data.result.canceltext,"");  
			crmPopupobj.selectid=selectid;
            crmPopupobj.show(data.result.content);
        }
    });
}
// ljj 20230914 XUQIU1001883 工单管理优化
//工单管理操作列 领取 按钮
// function receive_worksheetlist(record){
var receive_worksheetlist=function(record){
    var url = 'index.php?module=WorkSheet&action=WorkSheetAjax&file=receive_worksheet&fromtype=list';
    url += '&selectid='+record+'&selectlen=1';
    ldAjax(url,'',function(data){
        DelProgressObjs();
        if(data.code==1){
            var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",module,"","","","");
            crmPopupobj.prevshow();
            crmPopupobj.setParams(data.result.title,cancel_received,"","LdPopWidth600px",module,"",data.result.oktext,"","","");
            crmPopupobj.selectid=record;
            crmPopupobj.show(data.result.content);
        }
    });
}

//关闭弹窗并刷新页面
function cancel_received(){
	var popupobj=CrmPopup.getPopupObj("last");
	popupobj.CancelEvent();
	var tmparra=new Array();
	var tmpobj= new AfterUpdatePrevPopupObjContent(popupobj.module,"",tmparra);
	var refreshlistmodules = new Array(popupobj.module);
	tmpobj.eachrefreshlistbyModules(refreshlistmodules);
}

//详情页操作按钮（催单,结单，重新打开）
function WorkSheetAble(module,record,mode){
    var url = 'index.php?module='+module+'&action='+module+'Ajax&file=WorkSheetAble';
    url += '&record='+record+'&mode='+mode;
    ldAjax(url,'',function(data){
        DelProgressObjs();
        if(data.code==1){
            if(data.result.confirmstr != undefined){
                MessagePopup.TipZero_success(data.result.confirmstr);
            }
            setTimeout(function(){
                var popupobj=CrmPopup.getPopupObj("last");
                if(popupobj.type==DetailViewPage.type){
                    DetailViewRelation.showpage_moduledetail(popupobj);
                }
            },500);
            var tmparra=new Array();
            var tmpobj= new AfterUpdatePrevPopupObjContent(popupobj.module,"",tmparra);
            var refreshlistmodules = new Array(popupobj.module);
            tmpobj.eachrefreshlistbyModules(refreshlistmodules);
        }else if(data.code == -1){
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes",data.result.confirmstr);
        }
    });
}

//工单管理-解决方案
function WorkSheetSolution(module,record){
    var Popupobj=PageRecordPopup.loadobj("","","","LdPopWidth950px",module,"","","","",record);
    Popupobj.prevshow();
    PageRecordPopup.params['refreshpage']='no';
    var tmpurl = '&get_solution=yes';
    PageRecordPopup.showpage(module,record,tmpurl,PageRecordPopup.params);
}