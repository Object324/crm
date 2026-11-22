//chj 2021/6/9 销售合同：增加类似“订单状态”的字段，不受审批控制可以随时修改编辑
function SpecialField_Edit(obj,module) {
	var select_options = document.getElementById('allselectedboxes').value;
	var numOfRows = document.getElementById('numOfRows').value;
	var excludedRecords = $('excludedRecords').value;
	if(select_options=='all') {
		var idstring = select_options;
		var skiprecords = excludedRecords.split(";");
		var count = skiprecords.length;
		
		if(count > 1) {
			count = numOfRows - count + 1;
		} else {
			count = numOfRows;
		}
	  //18868: 提醒>未读/已读：复选框批量勾选所有数据，点击【删除】按钮，缺少一个弹框消息，批量操作只对前500条有效，是否继续
		if(parseInt(count) >parseInt(getMaxMassOperationLimit())) {
			var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',parseInt(count),getMaxMassOperationLimit(),'');
			//创建提示弹出层
			RemindsMsg("","LdPopWidth400px",module,"yes","yes",confirm_str);       

			
			//确定事件
			ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
				SpecialField_Detail_Edit(idstring,module,obj);
			});
		} else {
			SpecialField_Detail_Edit(idstring,module,obj);
		}
	} else {
		var x = select_options.split(';');
		var count = x.length;
		if(count > 1) {
			idstring = select_options;
			//chj: count- 1 因为取ID时，最后会多出个分好“;”
			if(count - 1 > getMaxMassOperationLimit()) {
				var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',count -1,getMaxMassOperationLimit(),'');
				RemindsMsg("","LdPopWidth400px",module,"yes","yes",confirm_str);
				
				//确定事件
				ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
					SpecialField_Detail_Edit(idstring,module,obj);
				});
			} else {
				SpecialField_Detail_Edit(idstring,module,obj);
			}

		} else {
			RemindsMsg("","LdPopWidth400px",module,"yes","yes","");
			return false;
		}
	}	
}

//编辑
function SpecialField_Detail_Edit(idstring,module,obj){
	url = 'index.php?module='+module+'&action='+module+'Ajax&file=SpecialField_Edit&idstring='+idstring;
    var tmpwidth=CreatePagePopup.getWidth();
    var Popupobj=CreatePagePopup.load("","","",tmpwidth,module,"","","","");
    Popupobj.prevshow();
	ld.ajax({
        url: url,
        type: 'POST',
        data:{"namename": "uname", "namenameage": 18},
        dataType:'json',
        async: true,//
        timeout: 20000,

        success: function(data)
        {
            if(data.code=="-1")
            {

                Popupobj.CancelEvent();
                RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
                return false;
            }
            if(data.code==1)
            {
				
				Popupobj.setParams(data.result.title,SpecialField_Save,"",tmpwidth,module,"",data.result.oktext,"",data.result.canceltext);
				Popupobj.show(data.result.content);
				ld("#"+Popupobj.divid+" .E_morefields ").css('display','none');
				Popupobj.refreshpage='yes';
				Popupobj.picklistdepency=data.result.picklistDependencyDatasource;
				Popupobj.fieldname=data.result.fieldname;
				Popupobj.fieldlabel=data.result.fieldlabel;
				Popupobj.fielddatatype=data.result.datatype;
				Popupobj.fields=data.result.fields;
				Popupobj.validatasave=data.result.validatasave;
				if(data.result.picklistcontent!=null&&data.result.picklistcontent!=undefined){
					for(var k=0;k<data.result.picklistcontent.length;k++)
					{
						//下拉框
						var fieldname=data.result.picklistcontent[k].fieldname;

						Popupobj.picklistobjarray[data.result.picklistcontent[k].fieldname]=new cls_picklist(data.result.picklistcontent[k].fieldname,data.result.picklistcontent[k].optionvalue);

						if(data.result.picklistdepencyfields!=null&&data.result.picklistdepencyfields!=""&&data.result.picklistdepencyfields[fieldname]!=undefined)
						{
							Popupobj.picklistobjarray[fieldname].setparentDependField(data.result.picklistdepencyfields[fieldname]);
						}
                    }
					if(data.result.picklistdepencyfields!=null&&data.result.picklistdepencyfields!=undefined)
					{
						ld.each(data.result.picklistdepencyfields,function(childfieldname,parentfieldname){
							if(Popupobj.picklistobjarray[parentfieldname] != undefined){
								Popupobj.picklistobjarray[parentfieldname].setchildDependField(childfieldname);
							}
						});
					}
                   CrmPopup.findHtmlobj(Popupobj.divid,"record").val(data.result.idstring);
				   CrmPopup.findHtmlobj(Popupobj.divid,"speciale_field").val(data.result.speciale_field);
                }
			}
		}
  })
}

//保存
function SpecialField_Save(){
	var popupobj=CrmPopup.getPopupObj('last');
	var popupobjprev=CrmPopup.getPopupObj('lastprev');
	var speciale_field =  ld("#"+popupobj.divid+" [name=speciale_field]").val();
	var records =  ld("#"+popupobj.divid+" [name=record]").val();
	//SpecialField_Save
	if(!empty(speciale_field)){
		var speciale_fields = new Array();
		speciale_fields = speciale_field.split(',');
		var filterstr = '';
		ld.each(speciale_fields,function(_key,fieldname){
			if(CrmPopup.findHtmlobj(popupobj.divid,fieldname).val() != ''){
				filterstr += '&'+fieldname+'='+encodeURIComponent(CrmPopup.findHtmlobj(popupobj.divid,fieldname).val());
			}
		})
		//异常处理  无修改内容或者无单据ID时，直接关闭弹出层
		if(filterstr == '' || records == ''){
			popupobj.CancelEvent();
            return false;
		}
		var urlstring = 'index.php?module='+popupobj.module+'&action='+popupobj.module+'Ajax&file=SpecialField_Save&mode=edit&records='+records+filterstr;
		ldAjax(urlstring,{},function(data){
			if(data.code == 1){
				popupobj.CancelEvent();
				if(popupobjprev.type == 'listpage'){
					createElementDiv('massedit_div');//创建DIV
					ld('#massedit_divtitlename').html(data.result.title);
					sethtml(document.getElementById('massedit_divcontent'),data.result.log);
					ld('#massedit_div .E_pbtn .E_pbtncancel').css('display','none');
					fnvshobj(this,'massedit_div');
					////edit:can 2020-11-16 43280: （61mis.com/kfbcrm）客户管理-客户-分配/共享/批量编辑；在客户单据列表，选择单据进行分配/共享/批量编辑操作，弹出操作成功弹窗；在该弹窗点击单据编号，进入详情，详情界面显示在了操作成功弹窗后面；
					ld("#layer").css("z-Index",CrmPopup.zIndex);
					CrmPopup.zIndex++;
					ld('#massedit_div').css("z-Index",CrmPopup.zIndex);
					CrmPopup.zIndex++;
					ld('#massedit_div .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
						fninvshnew('massedit_div');puyoungJS_DialogBox.unblock();
						if(document.getElementById('allselectedboxes') != undefined){
							document.getElementById('allselectedboxes').value='';
						}
						if(document.getElementById('selectedboxes') != undefined){
							document.getElementById('selectedboxes').value='';

						}
						var _page = ld("#"+popupobjprev.divid+" [name=pagenum]").val();
						getListViewEntries_js(popupobj.module,'start='+_page);//刷新页面

					});
				}else{
					var lastpopupobj=CrmPopup.getPopupObj('last');
					var tmparra=new Array();
					tmparra.push(popupobjprev.record);
					var tmpobj= new AfterUpdatePrevPopupObjContent(popupobjprev.module,"",tmparra);
					tmparra=[popupobjprev.module];
					tmpobj.eachrefreshlistbyModules(tmparra);
					var refreshlistmodules = new Array(popupobjprev.module);
					tmpobj.eachrefreshDetailViewByModules(refreshlistmodules);
					tmpobj.update();
                    
					delete tmpobj;
				}
				DelProgressObjs();
			}
		})
	}
}