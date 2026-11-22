/*		全选、全不选相关代码/
function toggleSelects(state,relCheckName) {
    if (getObj(relCheckName)) {
		if (typeof(getObj(relCheckName).length)=="undefined") {
			getObj(relCheckName).checked=state
		} else {
			for (var i=0;i<getObj(relCheckName).length;i++){
			 if(!getObj(relCheckName)[i].disabled){
				getObj(relCheckName)[i].checked=state  
			 }
			}
		}
	}
    alert('www');
    
}	   */
function SelectListValAlls(mod,frommod,span)
{
    if(document.selectall.selected_id != undefined)
	{
        x = document.selectall.selected_id.length;
        if ( x == undefined)
        {
            if (document.selectall.selected_id.checked)
            {
                idstring = document.selectall.selected_id.value;
                y=1;
            }
            else
            {
                //至少选择一条记录！
				var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);                
                return false;
            }
        }
        else
        {
           y=0;
           idstring = "";
    		for(i = 0; i < x ; i++)
    		{
    			if(document.selectall.selected_id[i].checked)
    			{
    				idstring = document.selectall.selected_id[i].value +"|"+idstring;
    				y=y+1;
    			}
    		}
          
        }
      
        //end
        
        if (y != 0)
		{
			document.selectall.idlist.value=idstring;
		}
		else
		{
			//至少选择一条记录！  
			var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);   
			return false;
		}
		var frommodule = document.getElementById('frommodule').value;
       if(window.opener.document.getElementById('selectsource')==undefined && frommodule != 'SendCashBill')
            window.opener.document.EditView.listval.value=idstring+"#"+span;
       else
			window.opener.document.EditView.listval.value=idstring;//原单选择有下拉框的界面（如：佣金单，发票，收款单等)
       // alert(window.opener.document.EditView.listval.value);
       // return false;
        window.opener.document.EditView.action.value = 'EditView';
        
       
	
        //window.opener.document.EditView.selectsource.options[mode].selected = true;  
        opener.document.forms['EditView'].submit();
       self.close();
	}
    
}
function SelectProductAlls(mod,parmod)
{
    
    var entitytypeids="";
    if(document.selectall.selected_id != undefined)
	{
        x = document.selectall.selected_id.length;
        if ( x == undefined)
        {
            if (document.selectall.selected_id.checked)
            {
                idstring = document.selectall.selected_id.value;
                entitytypeids = ld("input[name=selected_id]").attr("billinfo");
                y=1;
            }
            else
            {
                //至少选择一条记录！
				var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);                 
                return false;
            }
        }
        else
        {
           y=0;
           idstring = "";
    		for(i = 0; i < x ; i++)
    		{
    			if(document.selectall.selected_id[i].checked)
    			{
    				idstring = document.selectall.selected_id[i].value +","+idstring;
                    var objs=ld("input[name=selected_id]").eq(i);
                  
                    entitytypeids = objs.attr("billinfo")+","+entitytypeids;
    				y=y+1;
    			}
    		}
        }
        if (y != 0)
		{
			document.selectall.idlist.value=idstring;
		}
		else
		{
			//至少选择一条记录！
			var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);    
			return false;
		}
        /*
        edit:can
        date:20140215
        reason:龙威、82服务器：“采购订单、发票、出入库单”，录入“选择源单”后，结果页面会刷新，导致其他所有的字段都被清空，希望修正。
        */
		var inputs = document.EditView;
        if(inputs.selectsourcename != undefined)
            inputs.selectsourcename.value = mod;
        inputs.listval.value=idstring;
        inputs.action.value = 'EditView';
        SelectProductAlls.calbackfun.inputs=inputs;
	   SameSourceBill(SelectProductAlls.calbackfun,mod,entitytypeids);
	}
    
}
SelectProductAlls.calbackfun=function()
{
   
     SelectProductAlls.calbackfun.inputs.submit();
     //self.close();
} 
function SameSourceBill(callbackfun,module,idstring)
{
		var popupfrommodule = ld('#popupfrommodule').val();
		//0025544: 出库单：出库单新建选入库单，选不同供应商的源单给出了提示
		if(popupfrommodule == 'OutboundOrder' && module == 'Stock'){
			callbackfun();
		}
    	new Ajax.Request(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody: 'module='+module+'&action='+module+'Ajax&file=SourceSame&idstring='+idstring,
				onComplete: function(response) {
					var results = trim(response.responseText);
                   
                    if(results.indexOf("$$##error###$$$")>=0)
                    {
                        var result=results.split("$$##error###$$$");
                        RemindsMsg("","LdPopWidth400px","","yes","yes",result[1]);
                        return false
                    }
				   callbackfun();
				}
			}
		);
}
function SelectAlls(mod,parmod)
{

	//BUG0075096 lius 20231106 客户-相关信息栏选择“产品”-选择-弹出层中在第一页选择产品后点击下一页，不选择产品点确定，弹出“至少选择一条记录的提示信息”
	var popupobj = CrmPopup.getPopupObj("last");

    if(document.selectall.selected_id != undefined)
	{
		x = document.selectall.selected_id.length;
		var y=0;
     
		if(parmod != 'Calendar')
		{
			var module = '';
			if(window.document.getElementById('RLreturn_module') != undefined){
				module = window.document.getElementById('RLreturn_module').value;
			}
			var entity_id = '';
			if(window.document.getElementById('RLparent_id') != undefined){
				entity_id = window.document.getElementById('RLparent_id').value;
			}
			var parenttab = '';
			if(window.document.getElementById('parenttab') != undefined){
				parenttab = window.document.getElementById('parenttab').value;
			}
		}
		idstring = "";
		namestr = "";

		/**
		 * 重写这段判断语句，不再区分一条或多条，也不在用if作唯一判断，而是改成用对象
		 * @reason 0014158: 销售机会>明细>相关信息>选择客户,选择客户有问题
		 * @author Tujt 2015-04-11
		 */
		//获取选中的checkbox对象
		var selectobj = jQuery('form[name=selectall]').find('[name=selected_id]:checked');
		var selectarr = {};
		var chooseid_arr = [];
		if(parmod == 'Calendar'){//日历模块，特别处理
			jQuery.each(selectobj,function(obj){
				if(typeof(selectarr[jQuery(this).val()]) == 'undefined'){
					idval = jQuery(this).val();
					namestr = document.getElementById('calendarCont'+idval).innerHTML+"\n"+namestr;
					y ++;
					selectarr[jQuery(this).val()] = jQuery(this).val();
					chooseid_arr.push(jQuery(this).val());
					idstring += jQuery(this).val()+';';
				}
			});
		}else{//循环下拉框项
			/*jQuery.each(selectobj,function(obj){
				//用selectarr对象来保证id不重复
                //不能用val(),用了val(),产品相关信息选择销售机会会有错误（销售机会要有产品明细）
				if(typeof(selectarr[jQuery(this).attr("billinfo")]) == 'undefined'){
					y ++;
					selectarr[jQuery(this).val()] = jQuery(this).attr("billinfo");
					idstring += jQuery(this).attr("billinfo")+';';
				}
			});*/
			if(popupobj.chooseproductid_arr == ''){//BUG0075248 xxy 2023-11-10 销售机会--点击进入详情页--联系人相关信息栏--选择按钮--勾选联系人后点击选择后报错：“请至少选择一条记录！”
				chooseid_arr = popupobj.chooseMainSourceInfo_arr;
			}else{
				chooseid_arr = popupobj.chooseproductid_arr;
			}
			idstring = chooseid_arr.join(';');
			
		}
		//ld("#popup_rows_selectall").val('all');
        if(document.getElementById("popup_rows_selectall")!='undefined'
            &&document.getElementById("popup_rows_selectall")!=undefined
            &&ld("#popup_rows_selectall").val()=='all')
        {
           
			if(confirm(arrJsPopLabel['SUREYOUWANTADDSELECTED']+ld("#popup_num_rows").val()+arrJsPopLabel['RECORDS']))
			{
				var viewname = document.getElementById("viewname").value;
				var urlstring = "module="+module+"&parentid="+entity_id+"&action="+module+"Ajax&file=updateRelations&destination_module="+mod+"&idlist=all&viewname="+viewname;
				var popupobj=CrmPopup.getPopupObj("last");
				var divid=popupobj.divid;
				var search_fld_val= CrmPopup.findHtmlobj(divid,'search_field').val();
				var search_txt_val = CrmPopup.findHtmlobj(divid,'search_text').val();
				if(popupobj.searchtype != undefined){
					if(popupobj.searchtype=='Basic')
					{
						if(search_txt_val != '')
							urlstring += '&query=true&search_field='+encodeURIComponent(search_fld_val)+'&searchtype=BasicSearch&search_text='+encodeURIComponent(search_txt_val);
					}
					else if(popupobj.searchtype=='Advanced')
					{
						var advft_criteria = popupobj.advft_criteria;
						var advft_criteria_groups = popupobj.advft_criteria_groups;
						urlstring+= '&query=true&advft_criteria='+encodeURIComponent(advft_criteria)+'&advft_criteria_groups='+advft_criteria_groups+'&';
						urlstring += 'searchtype=advance';
					}
				}
				else{
					if(CrmPopup.findHtmlobj(divid,'search_field').val() != undefined){
						search_txt_val= encodeURIComponent(search_txt_val.replace(/\'/,"\\'"));
						if(!empty(search_fld_val) && !empty(search_txt_val)){
							urlstring += '&search_field='+search_fld_val+'&searchtype=BasicSearch&search_text='+search_txt_val;
							urlstring += '&searchtype=BasicSearch';
						}
					}
				}
				ldAjaxHtmlNoProgress('index.php?',urlstring,function(){
					var popupobj=CrmPopup.getPopupObj('lastprev');
					var divid = popupobj.divid;
					var related_id = CrmPopup.findHtmlobj(divid,'hidden_related_id_'+mod).val();
					var viewid = CrmPopup.findHtmlobj(divid,'viewname_'+mod).val();
					cancelCrmPopup();
					DetailViewRelation.refresh_relatedlist(mod);
					popupobj.relatelistsizeobj.setRelatedResizeTable_Init(mod);
				});
             }
             return true;
        }
		else if (chooseid_arr.length > 0)
		{
			document.selectall.idlist.value=idstring;
		}
		else
		{
            var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		}
        var confirm_str = arrJsPopLabel['SUREYOUWANTADDSELECTED']+chooseid_arr.length+arrJsPopLabel['RECORDS'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        //点击确认
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                if(parmod == 'Calendar')
    			{
    				//this blcok has been modified to provide delete option for contact in Calendar
    				idval = window.document.EditView.contactidlist.value;
    				if(idval != '')
    				{
    					var avalIds = new Array();
    					avalIds = idstring.split(';');
    
    					var selectedIds = new Array();
    					selectedIds = idval.split(';');
    
    					for(i=0; i < (avalIds.length-1); i++)
    					{
    						var rowFound=false;
    						for(k=0; k < selectedIds.length; k++)
    						{
    							if (selectedIds[k]==avalIds[i])
    							{
    								rowFound=true;
    								break;
    							}
    
    						}
    						if(rowFound != true)
    						{
    							idval = idval+';'+avalIds[i];
    							window.document.EditView.contactidlist.value = idval;
    							var str=document.getElementById('calendarCont'+avalIds[i]).innerHTML;
    							window.addOption(avalIds[i],str);
    						}
    					}
    				}
    				else
    				{
    					window.document.EditView.contactidlist.value = idstring;
    					var temp = new Array();
    					temp = namestr.split('\n');
    
    					var tempids = new Array();
    					tempids = idstring.split(';');
    
    					for(k=0; k < temp.length; k++)
    					{
    						window.addOption(tempids[k],temp[k]);
    					}
    				}
    			//end
    			}
    			else
    			{
					var prev_popupobj=CrmPopup.getPopupObj('lastprev');
					if(CrmPopup.findHtmlobj(prev_popupobj.divid,'module_type').val() != undefined && CrmPopup.findHtmlobj(prev_popupobj.divid,'module_type').val() != 'undefined' && CrmPopup.findHtmlobj(prev_popupobj.divid,'module_type').val()=='callbutler' && mod == 'Potentials'){
						var ajaxurl = 'index.php?module=Users&action=UsersAjax&file=CallButler_MultiCenter&getPotentials=yes&idlist='+idstring;
						ldAjax(ajaxurl,'', function (data) {
							if(data.code == 1){
								CrmPopup.findHtmlobj(prev_popupobj.divid,'related_to').val(data.result.potentialid);
								CrmPopup.findHtmlobj(prev_popupobj.divid,'related_to_name').val(data.result.potentialname);
							}
							DelProgressObjs();
							cancelCrmPopup();
						})
						
					}else{
						 /**
						 edit:chj
						 date:2014-6-23
						 reason：教育行业：招募学员时，判断当前招募学员是否超过班级的人员上限
						 */
						if(mod == 'Accounts' && parmod == 'Project')
						{
							if(document.getElementById('haveprojecet_account_num') != undefined && document.getElementById('allprojecet_account_num') != undefined)
							{
								if(document.getElementById('versionedu') != undefined && document.getElementById('versionedu').value == 1)
								{
									var haveNum = document.getElementById('haveprojecet_account_num').value;
									var allNum = document.getElementById('allprojecet_account_num').value;
									if(eval(haveNum) + y >= eval(allNum))
									{
										var confirm_str = arrJsPopLabel['PROJECTHAVEACCOUNTNUM'];
										RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
										return false;
									}
								}
							}
						}
                        
                         var detailviewpopupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
                        //edit:can 20230320 62918:售后客户模块，点击客户名称:中山市固美特五金制品有限公司进去，点击对应的联系人赖玉兰进去。找到课程邀约模块，选择对应的内容，没添加到，如图。 
						new Ajax.Request(
						'index.php',
						{
							queue: {
								position: 'end',
								scope: 'command'
							},
							method: 'post',
							postBody:"module="+detailviewpopupobj.module+"&parentid="+detailviewpopupobj.record+"&action="+detailviewpopupobj.module+"Ajax&file=updateRelations&destination_module="+mod+"&idlist="+idstring,
							onComplete: function(response) {
								var lastpopupobj=CrmPopup.getPopupObj("last");
								var popupobj=CrmPopup.getPopupObj('lastprev');
								var divid = popupobj.divid;
								var version_account = CrmPopup.findHtmlobj(lastpopupobj.divid,'version_account').val();
								//东贸特殊开发：活动配置选择活动记录
								if(version_account != undefined && version_account == 'dongmao' && mod == 'ServiceCharge' && parmod == 'CustomForm99'){
									mod = 'CustomForm98';
								}
								var related_id = CrmPopup.findHtmlobj(divid,'hidden_related_id_'+mod).val();
								var viewid = CrmPopup.findHtmlobj(divid,'viewname_'+mod).val();
								cancelCrmPopup();
								DetailViewRelation.refresh_relatedlist(mod);
								//showRelatedCustomView(related_id,viewid);
								popupobj.relatelistsizeobj.setRelatedResizeTable_Init(mod);
								//set_rel_count();
							}
						}
						);
					}
    			};
        });
    return false;
	}
}
/* 全选、全不选相关代码 end */
function hideSelects(){
	var oselect_array = document.getElementsByTagName('SELECT');
	for(var i=0;i<oselect_array.length;i++)
	{
		oselect_array[i].style.display = 'none';
	}
}
function showSelects(){
	var oselect_array = document.getElementsByTagName('SELECT');
	for(var i=0;i<oselect_array.length;i++)
	{
		oselect_array[i].style.display = 'block';
	}
}

function dateTimeValidates(dateFldName,timeFldName,fldLabel,type) {
	if(patternValidate(dateFldName,fldLabel,"DATE")==false)
		return false;
	dateval=getObj(dateFldName).value.substr(0,10).replace(/^\s+/g, '').replace(/\s+$/g, '')

	var dateelements=splitDateVal(dateval)

	dd=dateelements[0]
	mm=dateelements[1]
	yyyy=dateelements[2]

	if (dd<1 || dd>31 || mm<1 || mm>12 || yyyy<1 || yyyy<1000) {
		var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		try {
			getObj(dateFldName).focus()
		} catch(error) { }
		return false
	}

	if ((mm==2) && (dd>29)) {//checking of no. of days in february month
		var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		try {
			getObj(dateFldName).focus()
		} catch(error) { }
		return false
	}

	if ((mm==2) && (dd>28) && ((yyyy%4)!=0)) {//leap year checking
		var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		try {
			getObj(dateFldName).focus()
		} catch(error) { }
		return false
	}

	switch (parseInt(mm)) {
		case 2 :
		case 4 :
		case 6 :
		case 9 :
		case 11 :
			if (dd>30) {
			var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			try {
				getObj(dateFldName).focus()
			} catch(error) { }
			return false
		}
	}

	if (patternValidate(timeFldName,fldLabel,"TIME")==false)
		return false

	var timeval=getObj(timeFldName).value.replace(/^\s+/g, '').replace(/\s+$/g, '')
	var hourval=parseInt(timeval.substring(0,timeval.indexOf(":")))
	var minval=parseInt(timeval.substring(timeval.indexOf(":")+1,timeval.length))
	var currObj=getObj(timeFldName)

	if (hourval>23 || minval>59) {
		var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		try {
			currObj.focus()
		} catch(error) { }
		return false
	}

	var currdate=new Date()
	var chkdate=new Date()

	chkdate.setYear(yyyy)
	chkdate.setMonth(mm-1)
	chkdate.setDate(dd)
	chkdate.setHours(hourval)
	chkdate.setMinutes(minval)

	if (type!="OTH") {
		//if (!compareDates(chkdate,fldLabel,currdate,"current date & time",type)) {
		 if (!compareDates(chkdate,fldLabel,currdate,arrJsPopLabel['CURRENTTIME'],type)) { 
			try {
				getObj(dateFldName).focus()
			} catch(error) { }
			return false
		} else return true;
	} else return true;
}
function dateTimeComparisons(dateFldName1,timeFldName1,fldLabel1,dateFldName2,timeFldName2,fldLabel2,type) {
	var dateval1=getObj(dateFldName1).value.replace(/^\s+/g, '').replace(/\s+$/g, '')
	var dateval2=getObj(dateFldName2).value.replace(/^\s+/g, '').replace(/\s+$/g, '')
	var dateelements1=splitDateVal(dateval1)
	var dateelements2=splitDateVal(dateval2)

	dd1=dateelements1[0]
	mm1=dateelements1[1]
	yyyy1=dateelements1[2]

	dd2=dateelements2[0]
	mm2=dateelements2[1]
	yyyy2=dateelements2[2]

	var timeval1=getObj(timeFldName1).value.replace(/^\s+/g, '').replace(/\s+$/g, '')
	var timeval2=getObj(timeFldName2).value.replace(/^\s+/g, '').replace(/\s+$/g, '')

	var hh1=timeval1.substring(0,timeval1.indexOf(":"))
	var min1=timeval1.substring(timeval1.indexOf(":")+1,timeval1.length)

	var hh2=timeval2.substring(0,timeval2.indexOf(":"))
	var min2=timeval2.substring(timeval2.indexOf(":")+1,timeval2.length)

	var date1=new Date()
	var date2=new Date()

	date1.setYear(yyyy1)
	date1.setMonth(mm1-1)
	date1.setDate(dd1)
	date1.setHours(hh1)
	date1.setMinutes(min1)

	date2.setYear(yyyy2)
	date2.setMonth(mm2-1)
	date2.setDate(dd2)
	date2.setHours(hh2)
	date2.setMinutes(min2)

	if (type!="OTH") {
	   
		if (!compareDates(date1,fldLabel1,date2,fldLabel2,type)) {
			try {
				getObj(dateFldName1).focus()
			} catch(error) { }
			return false
		} else return true;
	} else return true;
}

function dateComparisons(fldName1,fldLabel1,fldName2,fldLabel2,type) {
	var dateval1=getObj(fldName1).value.replace(/^\s+/g, '').replace(/\s+$/g, '')
	var dateval2=getObj(fldName2).value.replace(/^\s+/g, '').replace(/\s+$/g, '')

	var dateelements1=splitDateVal(dateval1)
	var dateelements2=splitDateVal(dateval2)

	dd1=dateelements1[0]
	mm1=dateelements1[1]
	yyyy1=dateelements1[2]

	dd2=dateelements2[0]
	mm2=dateelements2[1]
	yyyy2=dateelements2[2]

	var date1=new Date()
	var date2=new Date()

	date1.setYear(yyyy1)
	date1.setMonth(mm1-1)
	date1.setDate(dd1)

	date2.setYear(yyyy2)
	date2.setMonth(mm2-1)
	date2.setDate(dd2)
	if (type!="OTH") {
	  
		if (!compareDates(date1,fldLabel1,date2,fldLabel2,type)) {
			try {
				getObj(fldName1).focus()
			} catch(error) { }
			return false
		} else return true;
	} else return true
}

function timeComparisons(fldName1,fldLabel1,fldName2,fldLabel2,type) {
	var timeval1=getObj(fldName1).value.replace(/^\s+/g, '').replace(/\s+$/g, '')
	var timeval2=getObj(fldName2).value.replace(/^\s+/g, '').replace(/\s+$/g, '')

	var hh1=timeval1.substring(0,timeval1.indexOf(":"))
	var min1=timeval1.substring(timeval1.indexOf(":")+1,timeval1.length)

	var hh2=timeval2.substring(0,timeval2.indexOf(":"))
	var min2=timeval2.substring(timeval2.indexOf(":")+1,timeval2.length)

	var time1=new Date()
	var time2=new Date()

	//added to fix the ticket #5028
	if(fldName1 == "time_end" && (getObj("due_date") && getObj("date_start")))
	{
		var due_date=getObj("due_date").value.replace(/^\s+/g, '').replace(/\s+$/g, '')
		var start_date=getObj("date_start").value.replace(/^\s+/g, '').replace(/\s+$/g, '')
		dateval1 = splitDateVal(due_date);
		dateval2 = splitDateVal(start_date);

		dd1 = dateval1[0];
		mm1 = dateval1[1];
		yyyy1 = dateval1[2];

		dd2 = dateval2[0];
		mm2 = dateval2[1];
		yyyy2 = dateval2[2];

		time1.setYear(yyyy1)
		time1.setMonth(mm1-1)
		time1.setDate(dd1)

		time2.setYear(yyyy2)
		time2.setMonth(mm2-1)
		time2.setDate(dd2)

	}
	//end

	time1.setHours(hh1)
	time1.setMinutes(min1)

	time2.setHours(hh2)
	time2.setMinutes(min2)
	if (type!="OTH") {
		if (!compareDates(time1,fldLabel1,time2,fldLabel2,type)) {
			try {
				getObj(fldName1).focus()
			} catch(error) { }
			return false
		} else return true;
	} else return true;
}
/* To get only filename from a given complete file path */
function getFileNameOnlys(filename) {
	var onlyfilename = filename;
	// Normalize the path (to make sure we use the same path separator)
	var filename_normalized = filename.replace(/\\/g, '/');
	if(filename_normalized.lastIndexOf("/") != -1) {
		onlyfilename = filename_normalized.substring(filename_normalized.lastIndexOf("/") + 1);
	}
	return onlyfilename;
}
/* Function to validate the filename */
function validateFilenames(form_ele) {
	if (form_ele.value == '') return true;
    
	var value = getFileNameOnlys(form_ele.value);

	// Color highlighting logic
	var err_bg_color = "#FFAA22";

	if (typeof(form_ele.bgcolor) == "undefined") {
		form_ele.bgcolor = form_ele.style.backgroundColor;
	}

	// Validation starts here
	var valid = true;

	if (value!=undefined&&value.length > 255) {
		var confirm_str = arrJsPopLabel['FILENAMESCANOTEXCEED255CHAR'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		valid = false;
	}
    
	/**
	edit:chj
	reason:图片上传JS控制
	date:2015-1-4
	**/
	//公司信息与其他上传图片不一致，只允许jpg、jpeg、png
	if(document.EditView != undefined && (document.EditView.module.value == 'Contacts'||document.EditView.module.value == 'Users'||document.EditView.module.value == 'Products'))
	{
		if(!/\.(gif|jpg|jpeg|png|bmp|ico|GIF|JPG|JPEG|PNG|BMP|ICO)$/.test(value))
		{
			var confirm_str = value+arrJsPopLabel['CANNOTUOLOAD']+','+arrJsPopLabel['THEALLOWEDTYPES']+'jpg、jpeg、gif、png、bmp、ico;';
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			form_ele.value = '';
			return false;
		}	
	}
   
	if(document.EditView != undefined && document.EditView.module.value == 'Emails')
	{
		var fileinfo = value.split('.');
		if(fileinfo[1] == 'exe' || fileinfo[1] == 'bat'|| fileinfo[1] == 'php'|| fileinfo[1] == 'php3'|| fileinfo[1] == 'php5'|| fileinfo[1] == 'phtml'|| fileinfo[1] == 'asp'|| fileinfo[1] == 'aspx'|| fileinfo[1] == 'ascx'|| fileinfo[1] == 'jsp'|| fileinfo[1] == 'cfm'|| fileinfo[1] == 'cfc'|| fileinfo[1] == 'pl'|| fileinfo[1] == 'dll'|| fileinfo[1] == 'reg'|| fileinfo[1] == 'cgi')
		{
		    var confirm_str = arrJsPopLabel['FORSECURITYREASONS'] + '\n' + value;
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			value = '';
			return false;
		}
	}
	if (!valid) {
		form_ele.style.backgroundColor = err_bg_color;
		return false;
	}
	form_ele.style.backgroundColor = form_ele.bgcolor;

	//@edit:liushuai,2020-09-10,reason:【ID1000998】/成员管理上传个人头像后应该立即更新已上传的图片（单据详情页编辑上传头像时动态赋值）
	// form_ele.form[form_ele.name + '_hidden'].value = value;
	var popupobj=CrmPopup.getPopupObj('last');
	CrmPopup.setHtmlobjval(popupobj.divid,form_ele.name + '_hidden',value);

    //by LD can 20121213 婵″倹鐏夊ǎ璇插鐠囥儴顕㈤崣銉ユ躬IE娑撳绱伴張澶庡壖閺堫剟鏁婄拠?	//displayFileSize(form_ele);
	return true;
}
function openPopUp(winInst,currObj,baseURL,winName,width,height,features) {
	var left=parseInt(findPosX(currObj))
	var top=parseInt(findPosY(currObj))

	if (window.navigator.appName!="Opera") top+=parseInt(currObj.offsetHeight)
	else top+=(parseInt(currObj.offsetHeight)*2)+10

	if (browser_ie)	{
		top+=window.screenTop-document.body.scrollTop
		left-=document.body.scrollLeft
		if (top+height+30>window.screen.height)
			top=findPosY(currObj)+window.screenTop-height-30 //30 is a constant to avoid positioning issue
		if (left+width>window.screen.width)
			left=findPosX(currObj)+window.screenLeft-width
	} else if (browser_nn4 || browser_nn6) {
		top+=(scrY-pgeY)
		left+=(scrX-pgeX)
		if (top+height+30>window.screen.height)
			top=findPosY(currObj)+(scrY-pgeY)-height-30
		if (left+width>window.screen.width)
			left=findPosX(currObj)+(scrX-pgeX)-width
	}

	features="width="+width+",height="+height+",top="+top+",left="+left+";"+features
	var cls_encryptyurlobj = new cls_encryptyurl();
	var encrypttmpurl = cls_encryptyurlobj.puyoung_urlstringtoencrypty(baseURL);
	baseURL += '&'+encrypttmpurl;
	eval(winInst+'=window.open("'+baseURL+'","'+winName+'","'+features+'")')
}
//to display type of address for google map
function toggleAssignTypess(currType){
    if(currType=="US")
   {
    getObj("assign_users").style.display="block"
	getObj("assign_teams").style.display="none"
   }
   else
   {
    getObj("assign_users").style.display="none"
	getObj("assign_teams").style.display="block"
   }
}
function fnLoadValuess(obj1,obj2,SelTab,unSelTab,moduletype,module){
	var oform = document.forms['EditView'];
	oform.action.value='Save';
	//global variable to check the validation calling function to avoid validating when tab change
	gValidationCall = 'tabchange';
	gValidationCall = 'tabchange';
	var tabName1 = document.getElementById(obj1);
	var tabName2 = document.getElementById(obj2);
	var tagName1 = document.getElementById(SelTab);
	var tagName2 = document.getElementById(unSelTab);
	if(tabName1.className == "dvtUnSelectedCell")
		tabName1.className = "dvtSelectedCellCommon dvtSelectedCell";
	if(tabName2.className == "dvtSelectedCellCommon dvtSelectedCell")
		tabName2.className = "dvtUnSelectedCell";
	tagName1.style.display='block';
	tagName2.style.display='none';
	gValidationCall = '';
}
function exportTypeTelects(MODULE,ACTION){
	hideOptions('changeExport');
    var obj = document.getElementsByName("exporttype");
    for(var i=0; i<obj.length; i ++){
        if(obj[i].checked){
            var sel = obj[i].value;
        }
    }
    puyoungJS_DialogBox.unblock()
    if(sel==3){
        location.href="index.php?module="+MODULE+"&action=Export"+MODULE;
    }
    if(sel==2){
        location.href="index.php?module="+MODULE+"&action=ExportRecords&parenttab="+ACTION;
    }
}
//wipe for Convert Lead
function addOnloadEvent(fnc){
	if ( typeof window.addEventListener != "undefined" )
		window.addEventListener( "load", fnc, false );
	else if ( typeof window.attachEvent != "undefined" ) {
		window.attachEvent( "onload", fnc );
	}
	else {
		if ( window.onload != null ) {
			var oldOnload = window.onload;
			window.onload = function ( e ) {
				oldOnload( e );
				window[fnc]();
			};
		}
		else
			window.onload = fnc;
	}
}
function OpenCompose(id,mode)
{
	switch(mode)
	{
		case 'edit':
			url = 'index.php?module=Emails&action=EmailsAjax&file=EditView&record='+id;
			break;
		case 'create':
			url = 'index.php?module=Emails&action=EmailsAjax&file=EditView';
			break;
		case 'forward':
			url = 'index.php?module=Emails&action=EmailsAjax&file=EditView&record='+id+'&forward=true';
			break;
		case 'Invoice':
			url = 'index.php?module=Emails&action=EmailsAjax&file=EditView&attachment='+arrJsPopLabel['INVOICE']+id+'.pdf';
			break;
		case 'PurchaseOrder':
			url = 'index.php?module=Emails&action=EmailsAjax&file=EditView&attachment='+arrJsPopLabel['PURCHASEORDER']+id+'.pdf';
			break;
		case 'SalesOrder':
			url = 'index.php?module=Emails&action=EmailsAjax&file=EditView&attachment='+arrJsPopLabel['SALESORDER']+id+'.pdf';
			break;
		case 'Quote':
			url = 'index.php?module=Emails&action=EmailsAjax&file=EditView&attachment='+arrJsPopLabel['QUOTE']+id+'.pdf';
			break;
		case 'Documents':
			url = 'index.php?module=Emails&action=EmailsAjax&file=EditView&attachment='+id+'';
			break;
		case 'print':
			url = 'index.php?module=Emails&action=EmailsAjax&file=PrintEmail&record='+id+'&print=true';
	}
//	url += '&popup=yes&page_popup=yes';
	//CrmPopupWindow('Emails',url,'Emails');
	openPopUp('xComposeEmail',this,url,'createemailWin',820,689,'menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes');
}
function execJSs(node) {
	var st = node.getElementsByTagName('SCRIPT');
	var strExec;
	for(var i=0;i<st.length; i++) {
		if (bSaf) {
			strExec = st[i].innerHTML;
		}
		else if (bOpera) {
			strExec = st[i].text;
		}
		else if (bMoz) {
			strExec = st[i].textContent;
		}
		else {
			strExec = st[i].text;
		}
		try {
			eval(strExec);
		} catch(e) {
			RemindsMsg("","LdPopWidth400px","","yes","yes",e);
		}
	}
}
//Function added for getting the Tab Selected Values (Standard/Advanced Filters) for Custom View - Ahmed
function fnLoadCvValuess(obj1,obj2,SelTab,unSelTab){
	var tabName1 = document.getElementById(obj1);
	var tabName2 = document.getElementById(obj2);
	var tagName1 = document.getElementById(SelTab);
	var tagName2 = document.getElementById(unSelTab);
	if(tabName1.className == "dvtUnSelectedCell")
		tabName1.className = "dvtSelectedCellCommon dvtSelectedCell";
	if(tabName2.className == "dvtSelectedCellCommon dvtSelectedCell")
		tabName2.className = "dvtUnSelectedCell";
	tagName1.style.display='block';
	tagName2.style.display='none';
}

function validateUrls(name)
{
	var Url = getObj(name);
	var wProtocol;

	var oRegex = new Object();
	oRegex.UriProtocol = new RegExp('');
	oRegex.UriProtocol.compile( '^(((http):\/\/)|mailto:)', 'gi' );
	oRegex.UrlOnChangeProtocol = new RegExp('') ;
	oRegex.UrlOnChangeProtocol.compile( '^(http)://(?=.)', 'gi' );

	wUrl = Url.value;
	wProtocol=oRegex.UrlOnChangeProtocol.exec( wUrl ) ;
	if ( wProtocol )
	{
		wUrl = wUrl.substr( wProtocol[0].length );
		Url.value = wUrl;
	}
}

//To select the select all check box(if all the items are selected) when the form loads.
function default_togglestates(obj_id,elementId){
	var all_state=true;
	var groupElements = document.getElementsByName(obj_id);
	for (var i=0;i<groupElements.length;i++) {
		var state=groupElements[i].checked;
		if (state == false){
			all_state=false;
			break;
		}
	}
	if(typeof elementId=='undefined')
		elementId = 'selectall';
	if(getObj(elementId))
		getObj(elementId).checked=all_state;
}
function clear_checked_alls(module){
	var cookie_val=get_cookie(module+"_all");
	if(cookie_val != null)
		delete_cookie(module+"_all");
	var obj = document.getElementsByName(module+"_selected_id");
	if (obj) {
		for (var i=0;i<obj.length;i++) {
			obj[i].checked=false;
		}
	}
	if(getObj(module+"_selectall"))
		getObj(module+"_selectall").checked=false;
}
function toggleShowHides(showid, hideid){
	var show_ele = document.getElementById(showid);
	var hide_ele = document.getElementById(hideid);    
    if(show_ele != null)
        show_ele.style.display = "inline";
	if(hide_ele != null)
        hide_ele.style.display = "none";
}
function MoreCurrencytoggleShowHides(showid, hideid,price_type){
    var popupobj=CrmPopup.getPopupObj("last");
    var prevpopobj=CrmPopup.getPopupObj("lastprev");
    var prevdivid=prevpopobj.divid;
     var divid=popupobj.divid;

	var show_ele = CrmPopup.findHtmlobj(prevdivid,showid);
    var hiddens=ld("#"+divid).find("[name=base_currency_curid]");

    for(var i=0;i<hiddens.length;i++)
    {
         var hiddenobj=hiddens[i];

        CrmPopup.findHtmlobj(prevdivid,price_type+"_cur_"+hiddenobj.value+"_check").prop("checked", CrmPopup.findHtmlobj(divid,price_type+"_cur_"+hiddenobj.value+"_check").prop("checked"));
		//  CrmPopup.findHtmlobj(prevdivid,price_type+"_cur_"+hiddenobj.value+"_check").attr("checked", CrmPopup.findHtmlobj(divid,price_type+"_cur_"+hiddenobj.value+"_check").attr("checked"));
		CrmPopup.findHtmlobj(prevdivid,price_type+"_cur_"+hiddenobj.value+"_check").val(CrmPopup.findHtmlobj(divid,price_type+"_cur_"+hiddenobj.value+"_check").val());
		CrmPopup.findHtmlobj(prevdivid,price_type+"_curname"+hiddenobj.value).val(CrmPopup.findHtmlobj(divid,price_type+"_curname"+hiddenobj.value).val());
		if(CrmPopup.findHtmlobj(prevdivid,price_type+"_cur_"+hiddenobj.value+"_check").prop("checked"))
        {
            CrmPopup.findHtmlobj(prevdivid,price_type+"_curname"+hiddenobj.value).attr("disabled",false);
        }
        else
        {
            CrmPopup.findHtmlobj(prevdivid,price_type+"_curname"+hiddenobj.value).attr("disabled",true);
        }
       CrmPopup.findHtmlobj(prevdivid,price_type+"_cur_conv_rate"+hiddenobj.value).val(CrmPopup.findHtmlobj(divid,price_type+"_cur_conv_rate"+hiddenobj.value).val());
    
    }
   
    if(show_ele != null){
        show_ele.css("display",'inline');

        CrmPopup.findHtmlobj(prevdivid,price_type).val(CrmPopup.findHtmlobj(divid,price_type+'_curname1').val());
		//230726 wym XUQIU1000102 关闭更多币种弹窗时，触发原来对应input上的change事件，从而实现自动勾选复选框
		CrmPopup.findHtmlobj(prevdivid,price_type).trigger("change")
        popupobj.CancelEvent();
    }

   
}
/**
 * this function returns the center co-ordinates of the viewport as an array
 */
function getViewPortCenters(){
	var height;
	var width;

	if(typeof window.pageXOffset != "undefined"){
		height = window.innerHeight/2;
		width = window.innerWidth/2;
		height +=window.pageYOffset;
		width +=window.pageXOffset;
	}else if(document.documentElement && typeof document.documentElement.scrollTop != "undefined"){
		height = document.documentElement.clientHeight/2;
		width = document.documentElement.clientWidth/2;
		height += document.documentElement.scrollTop;
		width += document.documentElement.scrollLeft;
	}else if(document.body && typeof document.body.clientWidth != "undefined"){
		height = window.screen.availHeight/2;
		width = window.screen.availWidth/2;
		height += document.body.clientHeight;
		width += document.body.clientWidth;
	}
	return {
		x: width,
		y: height
	};
}
/**
 * this function accepts a number and displays a div stating that there is an outgoing call
 * then it calls the number
 * @param number - the number to be called
 */
function startCalls(jqueryobj){
    var number=ld(jqueryobj).attr('datavalue');
    var recordid=ld(jqueryobj).attr("record");
	div = document.getElementById('OutgoingCall').innerHTML;
	outgoingPopup = _defPopup();
	outgoingPopup.content = div;
	outgoingPopup.displayPopup(outgoingPopup.content);

	//var ASTERISK_DIV_TIMEOUT = 6000;
	new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody: 'action=PBXManagerAjax&mode=ajax&file=StartCall&ajax=true&module=PBXManager&number='+encodeURIComponent(number)+'&recordid='+recordid,
			onComplete: function(response) {
				if(response.responseText == ''){
				//successfully called
				}else{
					RemindsMsg("","LdPopWidth400px","","yes","yes",response.responseText);
				}
			}
		}
		);
}

//added for tooltip manager
function ToolTipManager(){
	var state = false;
	/**
	 * this function creates the tooltip div and adds the information to it
	 * @param string text - the text to be added to the tooltip
	 */
	function tip(node, text,id,fieldname){
		state=true;
		var divName = getDivId(id,fieldname);
		var div = document.getElementById(divName)
		if(!div){
			div = document.createElement('div');
			div.id = divName;
			div.style.position = 'absolute';
			if(typeof div.style.opacity == "string"){
				div.style.opacity = 0.8;
			}
			div.className = "tooltipClass";
		}

		div.innerHTML = text;
		document.body.appendChild(div);
		div.style.display = "block";
		positionTooltip(node, divName);
	}

	function getDivId(id,fieldname){
		return '__VT_tooltip_'+id+'_'+fieldname;
	}

	function exists(id,fieldname){
		return (typeof document.getElementById(getDivId(id,fieldname)) != 'undefined' &&
			document.getElementById(getDivId(id,fieldname)) != null);
	}

	function show(node,id,fieldname){
		var div = document.getElementById(getDivId(id,fieldname));
		if(typeof div !='undefined' && div != null){
			div.style.display = '';
			positionTooltip(node, getDivId(id,fieldname));
		}
	}

	/**
	 * this function removes the tooltip div
	 */
	function unTip(nodelay,id,fieldname){
		state=false;
		var divName = getDivId(id,fieldname);
		var div = document.getElementById(divName);
		if(typeof div != 'undefined' && div != null ){
			if(typeof nodelay != 'undefined' && nodelay != null){
				div.style.display = "none";
			}else{
				setTimeout(function(){
					if(!state){
						div.style.display = "none";
					}
				}, 700);
			}
		}
	}

	/**
	 * this function is used to position the tooltip div
	 * @param string obj - the id of the element where the div has to appear
	 * @param object div - the div which contains the info
	 */
	function positionTooltip(obj,div){
		var tooltip = document.getElementById(div);
		var leftSide = findPosX(obj);
		var topSide = findPosY(obj);
		var dimensions = getDimension(tooltip);
        if(dimensions==undefined)
            return;
		var widthM = dimensions.x;
		var getVal = eval(leftSide) + eval(widthM);
		var tooltipDimensions = getDimension(obj);
		var tooltipWidth = tooltipDimensions.x;

		if(getVal  > document.body.clientWidth ){
			leftSide = eval(leftSide) - eval(widthM);
		}else{
			leftSide = eval(leftSide) + (eval(tooltipWidth)/2);
		}
		if(leftSide < 0) {
			leftSide = findPosX(obj) + tooltipWidth;
		}
		tooltip.style.left = leftSide + 'px';

		var heightTooltip = dimensions.y;
		var bottomSide = eval(topSide) + eval(heightTooltip);
		if(bottomSide > document.body.clientHeight){
			topSide = topSide - (bottomSide - document.body.clientHeight) - 10;
			if(topSide < 0 ){
				topSide = 10;
			}
		}else{
			topSide = eval(topSide) - eval(heightTooltip)/2;
			if(topSide<0){
				topSide = 10;
			}
		}
		tooltip.style.top= topSide + 'px';
	}

	return {
		tip:tip,
		untip:unTip,
		'exists': exists,
		'show': show,
		'getDivId':getDivId
	};
}
//tooltip manager changes end
function submitFormForActionWithConfirmations(formName, action, confirmationMsg) {
    if( document.getElementById("return_module")!=undefined && document.getElementById("return_module").value=="PaymentPlan")
    {
			// url的值参考回款计划列表删除
        PaymentPlanDetialDel(confirmationMsg,formName,action);
        return true;
    }
   else if( document.getElementById("return_module")!=undefined && document.getElementById("return_module").value=="SendPayment")
   {
         SendPaymentDetialDel(confirmationMsg,formName,action);
         return true;
   }
   else if( document.forms[formName].return_module!=undefined && document.forms[formName].return_module.value=="BankAccountSet")
   {
   confirmationMsg=arrJsPopLabel['tdwbddnitrbsywtd'];
         BankAccountDeleteDetail(confirmationMsg,formName,action);
         return true;
   }
    
     if(document.forms[formName].return_module!=undefined && document.forms[formName].return_module.value=="CashBill")
    {
			// url的值参考回款计划列表删除
			/**
			 * 翻译确认窗文本
			 * @reason 0008430
			 * @author Tujt 
			 */
           confirmationMsg=arrJsPopLabel['tdwbddnitrbsywtd'];
			  //"删除后无法还原，确定要删除这条记录吗？";
    }
    if(document.forms[formName].return_module!=undefined && document.forms[formName].return_module.value=="SendCashBill")
    {
			// url的值参考回款计划列表删除
           confirmationMsg=arrJsPopLabel['tdwbddnitrbsywtd'];
			  //"删除后无法还原，确定要删除这条记录吗？";
    }
	if (confirm(confirmationMsg)) {
		return submitFormForAction(formName,action);
	}
	return false;
}
 /**
  * 创建悬浮弹出层方法
  * @parem String divid 弹出层ID
  * @return 返回层的js对象
  * @author Tujt 2015-04-21
  */
function createElementDivs(divid){
	var divObj;

	if(0 == ld('#'+divid).length){//当层未创建时，创建层
		divObj = document.createElement("div");
		divObj.setAttribute('id',divid);
		divObj.className = 'E_pop_box LdPopWidth600px';
		divObj.style.position = "absolute";
		divObj.style.zIndex = "10001";
		divObj.style.top = "120px";
		divObj.style.left = "350px";
		//divObj.style.maxHeight = "200px";
		divObj.style.display = "none";
		//divObj.style.backgroundColor = "#ffffff";
		document.body.appendChild(divObj);
		divObj.innerHTML = '<div class="E_pop_tit">'+
								'<strong class="E_ptita" id="'+divid+'titlename"></strong>'+
								'<button class="E_ptitc" value="'+arrJsPopLabel['LBL_CLOSE']+'" title="'+arrJsPopLabel['LBL_CLOSE']+'"></button>'+
							'</div>'+
							'<div id="'+divid+'content" class="pop_remind_content">'+
								'&nbsp;'+
							'</div>'+
							'<div class="E_pbtn"><input class="E_pbtnok ld-button  ld-button-primary" value="'+arrJsPopLabel['CONFIRME']+'" type="button">'+
							'<input class="E_pbtncancel ld-button ld-button-cancel" value="'+arrJsPopLabel['CANCEL']+'" type="button"></div>';
		var isbg = 0;
		if(ld('#layer').length > 0){
			isbg = 1;
			ld('#'+divid).css('display','');
		}else{
			fnvshobj('', divid);
		}
		/**
		 * 关闭事件
		 * @author Tujt 2015-04-15
		 */
		ld('#'+divid+' .E_pop_tit .E_ptitc').on('click',function(){
			ld('#'+divid+' .E_pbtn .E_pbtncancel').click();
			return false;
		});
		ld('#'+divid+' .E_pbtn .E_pbtncancel').on('click',function(){
			if(0 == isbg){
				fninvshnew(divid);
			}else{
				ld('#'+divid).css('display','none');
			}
		});
	}else{
		divObj = document.getElementById(divid);
		if(ld('#layer').length > 0){
			ld('#'+divid).css('display','');
		}else{
			fnvshobj('', divid);
		}
	}
	return divObj;
}
function showBgDiv(){
	var divid = 'bgDiv';
	var zIdx = arguments[0]?arguments[0]:'9999';
	if(document.getElementById(divid)){
		var sHeight = screen.height;
		var clientheight = document.body.clientHeight
		var bgheight = sHeight + clientheight;
		document.getElementById(divid).style.height = bgheight +"px";
		show(divid);
	}else{
		var msgw,msgh,bordercolor;
		msgw=400;//
		msgh=100;//
		titleheight=25 //
		bordercolor="#c51100";//
		titlecolor="#c51100";//
		var sWidth,sHeight;
		sWidth=screen.width;
		sHeight=screen.height;
		var bgObj=document.createElement("div");
		bgObj.setAttribute('id',divid);
		bgObj.style.position="absolute";
		bgObj.style.top="0";
		bgObj.style.background="#cccccc";
		bgObj.style.filter="progid:DXImageTransform.Microsoft.Alpha(style=3,opacity=25,finishOpacity=75";
		bgObj.style.opacity="0.3";
		bgObj.style.left="0";
		if(sWidth > 1550){
			sWidth = 1800;
		}
		bgObj.style.width = sWidth + "px";
		var clientheight = document.body.scrollHeight
		var bgheight = sHeight + clientheight;
		bgObj.style.height = bgheight +"px";
		bgObj.style.zIndex = zIdx;
		document.body.appendChild(bgObj);
	}
}


/*创建提示弹出层方法
*1.参数divID：创建的divid、title标题、content提示内容、showCancel是否显示取消按钮(yes显示)
*type：提示图标样式，暂时还没有需要判断的，先放着，后面用的到
*2.btnClick：默认确定、取消都是div，为no需要自己重新写确定、取消按钮事件
*/
function create_divobj(divID,title,content,showCancel,type,btnClick){
         var div_text = '<div class="qui_dialog_body ww_dialog_body">'
                         +'<div class="msgDlg_left">'
                         +'<div class="ww_commonImg ww_commonImg_Alert msgDlg_left_icon"></div>'
                         +'</div>'
                         +'<div class="msgDlg_right">'   
                         +'<div class="msgDlg_right_text" style="font-size:13px;padding-left: 4px;">'+content
                         +'</div>'
                         +'</div>'
                         +'</div>';
        var divobj = createElementDivs(divID);
        ld(divobj).find('.E_pop_tit .E_ptita').html(title);
        ld('#'+divID+'content').html(div_text);
        ld(divobj).css('max-height','500px');
        ld(divobj).css('width','400px');
        ld(divobj).css('background','#FDFDFD');
        ld('#'+divID+'content').css('max-height','400px');
        ld('#'+divID+'content').css('border','none');
        ld(divobj).find('div.E_pbtn').addClass('ww_dialog_foot');
        ld(divobj).find('div.E_pop_tit a').attr("onclick","fninvshnew('"+divID+"');");
        
        //只显示 确定按钮
        if(showCancel !='yes'){
            ld(divobj).find('div.E_pbtn .E_pbtncancel').remove();
            ld(divobj).find('div.E_pbtn span').remove();
        }
        //点击确定后，关闭弹出层
        if(btnClick == 'yes'){
            ld(divobj).find('div.E_pbtn .E_pbtnok').attr("onclick","fninvshnew('"+divID+"');");
        }
        //取消按钮事件
        if(showCancel =='yes'){
            ld(divobj).find('div.E_pbtn .E_pbtncancel').attr("onclick","fninvshnew('"+divID+"');");
        }
        ld(divobj).find('div.E_pop_tit .E_ptitc').attr("onclick","fninvshnew('"+divID+"');");
        fnvshobj(this,divID);
    
}