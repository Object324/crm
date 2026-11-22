function mass_edit(obj,divid,module,parenttab,smowner) {
	var select_options = document.getElementById('allselectedboxes').value;
	var numOfRows = document.getElementById('numOfRows').value;
	var excludedRecords = $('excludedRecords').value;
	if(select_options=='all') {
		var idstring = select_options;
		var skiprecords = excludedRecords.split(";");
		var count = skiprecords.length;
		
		if(count > 1) {
			count = numOfRows - count + 1;
		}
        else {
			count = numOfRows;
		}
        //18868: 提醒>未读/已读：复选框批量勾选所有数据，点击【删除】按钮，缺少一个弹框消息，批量操作只对前500条有效，是否继续
		if(parseInt(count) >parseInt(getMaxMassOperationLimit())) {
			var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',parseInt(count),getMaxMassOperationLimit(),'');
		    //创建提示弹出层
            RemindsMsg("","LdPopWidth400px",module,"yes","yes",confirm_str);
            //确定事件
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                mass_edit_formload(idstring,module,parenttab,smowner,obj,divid);
            });
		}
        else {
			mass_edit_formload(idstring,module,parenttab,smowner,obj,divid);
		}
	}
    else {
		var x = select_options.split(';');
		var count = x.length;
		if(count > 1) {
			idstring = select_options;
			//chj: count- 1 因为取ID时，最后会多出个分好“;”
			if(count - 1 > getMaxMassOperationLimit()) {
				var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',count -1,getMaxMassOperationLimit(),'');
                RemindsMsg("","LdPopWidth400px",module,"yes","yes",confirm_str + arrJsPopLabel['WENHAO']);
                
                //确定事件
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                    mass_edit_formload(idstring,module,parenttab,smowner,obj,divid);
                });
			}
            else {
				mass_edit_formload(idstring,module,parenttab,smowner,obj,divid);
			}
		}
        else {
            MessagePopup.TipOne_warning();
			return false;
		}
	}
}

function mass_edit_formload(idstring,module,parenttab,smowner,obj,divid) {
    var url="";
    //批量删除时判断，审批状态
    if(module=='Accounts' || module=='SalesOrder' || module=='Quotes' || module=='Invoice' || module=='HelpDesk' 
    || module=='Expense' || module=='PurchaseOrder' || module=='Documents' || module=='Project' ||
     module=='ProjectTask' || module=='ContactRecords' || module=='CashDeposit' || module=='PutCash' ||
      module=='Potentials' || module=='Calendar' || module=='Commission'||module=='ServiceContracts'||module=='ServiceCharge')
        url="&ajax=true";
        
	if(typeof(parenttab) == 'undefined') parenttab = '';
	//var excludedRecords=document.getElementById("excludedRecords").value;
	var excludedRecords=idstring;
	var viewid =getviewId();
	ld('#rptContentLoading').show();
        
    var searchScope="";
    if(document.getElementById("SmOwnerSearchScope")!=undefined){
		searchScope= encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);  
    }
	var numOfRows_url;//当批量操作全选时获取页面总行数
	if(document.getElementById("numOfRows") != undefined){
		numOfRows_url="&totalrows="+document.getElementById("numOfRows").value;	
	}
    else if(document.getElementById("numOfRows_selectall1") != undefined){
		numOfRows_url="&totalrows="+document.getElementById("numOfRows_selectall1").value;	
	}
   
   var popupobj=CrmPopup.getPopupObj('last');
   var surl = "index.php?module="+module+"&action="+module+'Ajax'
            +"&file=MassEdit&massedit=yes&mode=ajax&idstring="+idstring+"&viewname="+viewid+"&excludedRecords="+excludedRecords+"&smowner="+smowner+"&SearchScope="+searchScope+url+numOfRows_url;
    //0047710: （81mis.com/kfbcrm）客户管理-‘客户_成交客户’；在客户列表，选择客户单据后点击批量编辑按钮，客户状态字段可以编辑；该字段是分类条件，应为不可编辑
    if (typeof linkmodulecustom != "undefined") {
        //@edit:zkt,reason:链接模块，单据新建/编辑/复制界面，“数据分类设置的条件”字段显示为只读的，不可编辑修改
        //获取链接模块viewname
        surl += '&is_linkmodulecustom='+linkmodulecustom;
        var page_addurl = getSearchString('page_addurl',location.href);
        if(page_addurl != undefined){
            var linkmodule_viewname = getSearchString('viewname',page_addurl);
            if(linkmodule_viewname != undefined){
                surl +='&linkmodule_viewname='+linkmodule_viewname;
            }
        }
    }
    ldAjax(surl,{'page_list_query':popupobj.page_list_query,'list_query':popupobj.list_query},function(data){
        DelProgressObjs();
        if(module=="PaymentPlan"){
            if(smowner!='smowner'){
                paymentplanop(smowner,data,obj, divid);
                //  $("massedit_form")["massedit_recordids"].value = $("massedit_form")['idstring'].value;
                //$("massedit_form")["massedit_module"].value = module;
                return;
            }
        }

        if(module=='SendPayment'){
            if(smowner!='smowner'){
                sendpaymentop(smowner,data,obj, divid);
                //$("massedit_form")["massedit_recordids"].value = $("massedit_form")['idstring'].value;
                //	$("massedit_form")["massedit_module"].value = module;
                return;
            }
        }

        if(data.code==1){
            //弹出框的设计
            if(smowner == 'smowner'){
                var results=response.responseText.split(('###SUCCESS###'));
                result=trim(results[1]);
                //$("smowneredit_form_div").update(result);
                ld("#smowneredit_form_div").html(result);
                //chj:日程管理和知识管理特殊控制
                if(module != 'Documents' && module != 'Calendar'){
                    //	$("massedit_form_div").update("");
                    //$("massCashBill_form_div").update("");
                    //	$("massSendCashBill_form_div").update("");
                }
            }
            else{
                var MassEditPopupobj=MassEditPopup.load(data.result.title,massEditSave,"","LdPopWidth950px",module,"",data.result.oktext,"",data.result.canceltext);
                MassEditPopupobj.refreshpage='yes';
                // MassEditPopupobj.createScrollDiv();//创建滚动条
                MassEditPopupobj.picklistdepency=data.result.picklistDependencyDatasource;
                MassEditPopupobj.fieldname=data.result.fieldname;
                MassEditPopupobj.fieldlabel=data.result.fieldlabel;
                MassEditPopupobj.fielddatatype=data.result.datatype;
                MassEditPopupobj.fields=data.result.fields;
                MassEditPopupobj.validatasave=data.result.validatasave;
                MassEditPopupobj.oCKeditors = [];
                //   MassEditPopupobj.show(data.result.content);
                CrmPopup.setPopupobjHtmlContent_scroll(MassEditPopupobj,data.result.content);

                if(data.result.picklistcontent!=null&&data.result.picklistcontent!=undefined)
                    for(var k=0;k<data.result.picklistcontent.length;k++)
                    {
                        //下拉框
                        var fieldname=data.result.picklistcontent[k].fieldname;

                        MassEditPopupobj.picklistobjarray[data.result.picklistcontent[k].fieldname]=new cls_picklist(data.result.picklistcontent[k].fieldname,data.result.picklistcontent[k].optionvalue);

                        if(data.result.picklistdepencyfields!=null&&data.result.picklistdepencyfields!=""&&data.result.picklistdepencyfields[fieldname]!=undefined)
                        {

                            MassEditPopupobj.picklistobjarray[fieldname].setparentDependField(data.result.picklistdepencyfields[fieldname]);

                        }
                    }

                if(data.result.picklistdepencyfields!=null&&data.result.picklistdepencyfields!=undefined)
                {

                    ld.each(data.result.picklistdepencyfields,function(childfieldname,parentfieldname){
                        if(MassEditPopupobj.picklistobjarray[parentfieldname] != undefined){
                            MassEditPopupobj.picklistobjarray[parentfieldname].setchildDependField(childfieldname);
                        }
                    });
                }

                //ls 2022-02-17 0050010: （https://81mis.com/kfbcrm/index.php [^]）（需补丁）客户》选择单据》批量编辑，备注信息区块的“富文本框”字段，在批量编辑时不是富文本框格式，然后调用文档模板是代码
                if(data.result.fields!=null&&data.result.fields!=undefined)
                {
                    for(var i=0;i<MassEditPopupobj.fields.length;i++)
                    {
                        if (MassEditPopupobj.fields[i].uitype == 230 || MassEditPopupobj.fields[i].uitype == 231) {
                            var tmpokeditor = UE.getEditor(MassEditPopupobj.fields[i].fieldname);//实例化编辑器
                            MassEditPopupobj.oCKeditor = tmpokeditor;
                            MassEditPopupobj.oCKeditors[MassEditPopupobj.fields[i].fieldname] = tmpokeditor;

                            var tmpfieldname = MassEditPopupobj.fields[i].fieldname;
                            window.setTimeout(function (j) {
                                var id = ld('#' + j).children("div:first-child").attr("id");
                                ld('#' + id).css('z-index', '99999');
                                MassEditPopupobj.center();
                            }, 500, tmpfieldname);//防止变量污染，故需传递到闭包里面，可拿联系人模块的负责项目uitype为33测试。
                        }
                    }
                }



                CrmPopup.findHtmlobj(MassEditPopupobj.divid,"massedit_recordids").val($("massedit_form")['idstring'].value);
                CrmPopup.findHtmlobj(MassEditPopupobj.divid,"massedit_module").val(module);

            }
            //can 049721: （https://81mis.com/kfbcrm [^]）（刘总所提问题） 在批量编辑单据时（以产品模块为例），选择了需要批量编辑的下拉框值，前方的复选框不会自动勾选，容易导致误操作
            massedit_initOnChangeHandlers();

            if(divid == 'smowneredit')
            {
                fnvshobj(obj, divid);
                $("massedit_form")["massedit_recordids"].value = $("massedit_form")['idstring'].value;
                $("massedit_form")["massedit_module"].value = module;
                BatchOperation(divid,module,idstring,'ListView');
            }

            //xxy 2023-12-13 BUG0077150 项目立项-批量编辑-区块名称过长时，弹出层中区块名与字段重叠 
            ld('#'+MassEditPopupobj.divid).find('.ld-ui-tabs-nav').find('li').find('a').css('max-width',ld('#'+MassEditPopupobj.divid).width());
        }else{
            MessagePopup.TipOne_warning(data.msg);
        }

    });
    
    
}
function paymentplanop(smowner,result,obj,divid)
{
    if(result.code<=0)
    {
        //您选择的记录有已收款或者部分已收款的单据，不允许批量修改！
        var confirm_str = arrJsPopLabel['SELECTECOLLECTIONDOCUMENTSNOTEDIT'];
        if(smowner=='massCashBill')
        {
            //请选择尚未收款的单据！
            confirm_str = arrJsPopLabel['PLEASESELECTDOCUMENTSNOTYET'];
        }
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }
    if(smowner=="massCashBill")//批量收款
    {
        var crmPopupobj=CrmPopup.load(result.result.title,SaveMassCashBill,"","LdPopWidth900px",module,"",result.result.oktext,"",result.result.canceltext);
          crmPopupobj.setOkfunParamObj(['frmpaymentplan']);
          crmPopupobj.show(result.result.content); 
          
       
    }
    else//批量修改
    {
             var MassEditPopupobj=MassEditPopup.load(result.result.title,massEditSave,"","LdPopWidth900px",module,"",result.result.oktext,"",result.result.canceltext);
             MassEditPopupobj.refreshpage='yes';
             MassEditPopupobj.picklistdepency=result.result.picklistDependencyDatasource;
             MassEditPopupobj.fieldname=result.result.fieldname;
             MassEditPopupobj.fieldlabel=result.result.fieldlabel;
             MassEditPopupobj.fielddatatype=result.result.datatype;
             MassEditPopupobj.fields=result.result.fields;
             if(result.result.picklistcontent!=null&&result.result.picklistcontent!=undefined)
                    for(var k=0;k<result.result.picklistcontent.length;k++)
                    {
                        //下拉框
                        var fieldname=result.result.picklistcontent[k].fieldname;
                       
                        MassEditPopupobj.picklistobjarray[result.result.picklistcontent[k].fieldname]=new cls_picklist(result.result.picklistcontent[k].fieldname,result.result.picklistcontent[k].optionvalue);
                        
                        if(result.result.picklistdepencyfields!=null&&result.result.picklistdepencyfields!=""&&result.result.picklistdepencyfields[fieldname]!=undefined)
                        {
                            
                            MassEditPopupobj.picklistobjarray[fieldname].setparentDependField(result.result.picklistdepencyfields[fieldname]);
                            
                        }
                    }
                    
             if(result.result.picklistdepencyfields!=null&&result.result.picklistdepencyfields!=undefined)
             {
                    
                     ld.each(result.result.picklistdepencyfields,function(childfieldname,parentfieldname){
						 if(MassEditPopupobj.picklistobjarray[parentfieldname] != undefined){
							MassEditPopupobj.picklistobjarray[parentfieldname].setchildDependField(childfieldname);
						 }
                     });
            }
             MassEditPopupobj.show(result.result.content); 
             CrmPopup.findHtmlobj(MassEditPopupobj.divid,"massedit_recordids").val($("massedit_form")['idstring'].value);
             CrmPopup.findHtmlobj(MassEditPopupobj.divid,"massedit_module").val(module);
    }
    
}
function sendpaymentop(smowner,result,obj,divid)
{
   
    if(result.code=="-1")
    {
        //您选择的记录有已付款或者部分已付款的单据，不允许批量修改！
        var confirm_str = arrJsPopLabel['SELECTEPAYMENTDOCUMENTSNOTEDIT'];
        if(smowner=='massSendCashBill')
        {
            //请选择尚未付款的单据！
            confirm_str = arrJsPopLabel['PLEASESELECTDOCUMENTSNOTPAID'];
        }
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return ;
    }else if(result.code=="-2"){
        if(smowner=='massSendCashBill')
        {
            //账户为必选
            var confirm_str = arrJsPopLabel['bnoempty'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return ;
        }
    }
    if(smowner=="massSendCashBill")//批量付款
    {   
        var crmPopupobj=CrmPopup.load(result.result.title,SaveMassSendCashBill,"","LdPopWidth900px",module,"",result.result.oktext,"",result.result.canceltext);
          crmPopupobj.setOkfunParamObj(['frmsendpayment']);
          crmPopupobj.show(result.result.content); 
    }
    else//批量修改
    {
            var MassEditPopupobj=MassEditPopup.load(result.result.title,massEditSave,"","LdPopWidth900px",module,"",result.result.oktext,"",result.result.canceltext);
             MassEditPopupobj.refreshpage='yes';
             MassEditPopupobj.picklistdepency=result.result.picklistDependencyDatasource;
             MassEditPopupobj.fieldname=result.result.fieldname;
             MassEditPopupobj.fieldlabel=result.result.fieldlabel;
             MassEditPopupobj.fielddatatype=result.result.datatype;
             MassEditPopupobj.fields=result.result.fields;
             if(result.result.picklistcontent!=null&&result.result.picklistcontent!=undefined)
                    for(var k=0;k<result.result.picklistcontent.length;k++)
                    {
                        //下拉框
                        var fieldname=result.result.picklistcontent[k].fieldname;
                       
                        MassEditPopupobj.picklistobjarray[result.result.picklistcontent[k].fieldname]=new cls_picklist(result.result.picklistcontent[k].fieldname,result.result.picklistcontent[k].optionvalue);
                        
                        if(result.result.picklistdepencyfields!=null&&result.result.picklistdepencyfields!=""&&result.result.picklistdepencyfields[fieldname]!=undefined)
                        {
                            
                            MassEditPopupobj.picklistobjarray[fieldname].setparentDependField(result.result.picklistdepencyfields[fieldname]);
                            
                        }
                    }
                    
             if(result.result.picklistdepencyfields!=null&&result.result.picklistdepencyfields!=undefined)
             {
                    
                     ld.each(result.result.picklistdepencyfields,function(childfieldname,parentfieldname){
						 if(MassEditPopupobj.picklistobjarray[parentfieldname] != undefined){
							MassEditPopupobj.picklistobjarray[parentfieldname].setchildDependField(childfieldname);
						 }
                     });
                }
             MassEditPopupobj.show(result.result.content); 
             
             CrmPopup.findHtmlobj(MassEditPopupobj.divid,"massedit_recordids").val($("massedit_form")['idstring'].value);
             CrmPopup.findHtmlobj(MassEditPopupobj.divid,"massedit_module").val(module);
    }
   // fnvshobj(obj, divid);   
}