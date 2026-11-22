
function createContactRecords(obj,return_id,record,return_module,return_action)
{
   //quickPop.OtherPopupParam="&records="+record+"&return_module="+return_module;
   //quickPop("ContactRecords","select","");
  
    var objparams=new CreatePagePopup.params();
     objparams.params['refreshpage']='no';
   CreatePagePopup.showpage("ContactRecords","&return_module=ContactRecords&frommodule="+return_module+"&fromid="+record+"&relatedcreate=yes",objparams);
   
}

function createProjectProgress(obj,return_id,record,return_module,return_action)
{
	var objparams=new CreatePagePopup.params();
	objparams.params['refreshpage']='no';
	CreatePagePopup.showpage("ProjectProgress","&records="+record+"&return_module="+return_module,objparams);
   
}
function quickCreateSave(btnobj,module)
{
    var QcPopupobj=CrmPopup.getPopupObj("last");
    
    btnobj=document.getElementById(QcPopupobj.divid+"_btnok")

   if(getFormValidate(btnobj.form)) 
   {
   
     if(!FieldDuplicateValidate(module,btnobj.form,btnobj))
            btnobj.disabled=false;
   }
         
   else
   {
 
    
     btnobj.disabled=false;
   }
   
 
}
quickCreateSave.funname="quickCreateSave";

function quickPop(qcoptions,selecttype,quickcreate_detailrow)
{
    
   var objparams=new CreatePagePopup.params();
   objparams.params['refreshpage']='no';
   objparams.params['createdtype']='quickcreate';
	var lasturl = '';
   if(qcoptions == 'Contacts'){
	    var popupobj=CrmPopup.getPopupObj("last");
		var keyids = '';
		if(CrmPopup.findHtmlobj(popupobj.divid,"keyids").val() != undefined){
			keyids = CrmPopup.findHtmlobj(popupobj.divid,"keyids").val();
		}
		lasturl = '&fromid='+keyids;
   }
   CreatePagePopup.showpage(qcoptions,lasturl,objparams);
   
   return false;
    var module = qcoptions;//弹出层的快速创建
    var qcreatetype='popup';//快速创建类型(弹出层和菜单)
	var related_recordid;
 
    if(typeof module =='object')
    {   module = qcoptions.options[qcoptions.options.selectedIndex].value;//菜单快速创建
        qcreatetype='menu';
    }
	if(module !='Accounts'&&module!='Vendors'){
		if(document.getElementById('keyids') != undefined){
			var keyids = document.getElementById('keyids').value;
			related_recordid = keyids;
		}
	}
	if(module != 'none'){
		ld('#rptContentLoading').show();
		if(module == 'Events'){
			module = 'Calendar';
			var urlstr = '&activity_mode=Events';
		}else if(module == 'Calendar'){
			module = 'Calendar';
			var urlstr = '&activity_mode=Task';
		}else{
			var urlstr = '';
		}

        if(selecttype=='select'){
            qcreatetype='select';
        }
        ld.ajax({
        url: 'index.php?module='+module+'&action='+module+'Ajax&file=QuickCreate'+urlstr+"&qcreatetype="+qcreatetype+"&Create=true&quickcreate_detailrow="+quickcreate_detailrow+"&related_recordid="+related_recordid+quickPop.OtherPopupParam,
        type: 'POST',
        data:'',
       dataType:'json',
        async: true,//
        timeout: 5000,
       
        success: function(data)
        {
            if(data.code==1)
            {
                
                ld('#rptContentLoading').hide();
                 var jspopup=[];
                  
                 
                   cur_PageInfo.pagetype.push('poplayerlistview');
                    cur_PageInfo.modulenames.push(module);
                    cur_PageInfo.pagemode.push('poplayer');
                    
                    if(qcreatetype=='menu')//菜单栏选择的快速创建
                    {
                         
                        var QcPopupobj=QcPopup.load(data.result.title,quickCreateSave,"","LdPopWidth950px",module,jspopup,data.result.oktext,"",data.result.canceltext);
                        QcPopupobj.refreshpage='yes';
                       
                        
                    }
                    else
                    {
                        var QcPopupobj=QcPopup.load(data.result.title,qcSave,"","LdPopWidth950px",module,jspopup,data.result.oktext,"",data.result.canceltext);
                       
                         
                    }
                   
                     jspopup.push(document.getElementById(QcPopupobj.divid+"_btnok"));
                        
                     jspopup.push(module);
                    QcPopupobj.picklistdepency=data.result.picklistDependencyDatasource;
                    QcPopupobj.fieldname=data.result.fieldname;
                    QcPopupobj.fieldlabe=data.result.fieldlabel;
                    QcPopupobj.datatype=data.result.datatype;
                    QcPopupobj.fields=data.result.fields;
                    
                    QcPopupobj.setOkfunParamObj(jspopup)
                   QcPopupobj.show(data.result.content);
                 
            }
        
        }
    });
    

	}
}
quickPop.OtherPopupParam="";


function getFormValidate(divValidate)
{
	
	/**
	 * 判断提现单、存现单，控制转入账户转出账户不能是一个
	 * @reason 0013946: 快速创建-存现单、提现单：当转出账户和转入账号一样保存时，没有进行判断
	 * @author Tujt 2015-03-10
    */

    var divid=CrmPopup.global_listPopupObj[CrmPopup.global_listPopupObj.length-1].divid;
    var qcpopupobj=CrmPopup.global_listPopupObj[CrmPopup.global_listPopupObj.length-1];
    
	if(CrmPopup.getHtmlobjval(divid,'module') == 'CashDeposit' || CrmPopup.getHtmlobjval(divid,'module')== 'PutCash'){
        if(CrmPopup.findHtmlobj(divid,'outaccount') != undefined && CrmPopup.findHtmlobj(divid,'inaccount') != undefined){
            if(CrmPopup.findHtmlobj(divid,'outaccount').val() == CrmPopup.findHtmlobj(divid,'inaccount').val()){
				var confirm_str = arrJsPopLabel['taaacnbtttsa'];
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				return false;
            }   
        }
    }

	
        var qcfieldname = qcpopupobj.fieldname.split("','");

        var qcfieldlabel = qcpopupobj.fieldlabe.split("','");
        var qcfielddatatype = qcpopupobj.datatype.split("','");
        var quickcreatefieldinfojsonobj=qcpopupobj.fields;
        //var popfieldinfoobjs=  eval('('+ quickcreatefieldinfojsonobj +')')?eval('('+ quickcreatefieldinfojsonobj +')'):JSON.parse(quickcreatefieldinfojsonobj);
        cur_PageInfo.fieldinfoobjs.push(quickcreatefieldinfojsonobj);

  for (var i=0; i<qcfieldname.length; i++) {
		var curr_fieldname = qcfieldname[i];
        curr_fieldname=CrmPopup.deletequotation(curr_fieldname);
       
		if(CrmPopup.isExistsObj(divid,curr_fieldname))
		{
		 
             var strtype=qcfielddatatype[i];
		    strtype=CrmPopup.deletequotation(strtype);
      
			var type=strtype.split("~");
               
			var input_type = CrmPopup.findHtmlobj(divid,curr_fieldname).attr("type");
            
            var fieldlabel=qcfieldlabel[i];
            fieldlabel=CrmPopup.deletequotation(fieldlabel);

  
			if (type[1]=="M") {
			       
					if (!qcemptyCheck(curr_fieldname,fieldlabel,input_type))
						return false
				}
                
              
			switch (type[0]) {
				case "O"  : break;
				case "V"  : break;
				case "C"  : break;
				case "DT" :
					/**
					 * 把EditView.js->doformValidation中的判断方法拷贝了过来
					 * @reason 0014949: 快速创建：日程管理，快速创建无法保存，一直提示：请输入正确的时间-如图
					 * @author Tujt 2015-05-14
					 */
                    
					if ( CrmPopup.getHtmlobjval(divid,curr_fieldname).replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0)
					{
						if (type[1]=="M")
							if (!qcemptyCheck(curr_fieldname,fieldlabel,type[2]))
								return false;
						if(type[0]=='DT'){
									if(!dateTimesecValidate(curr_fieldname,fieldlabel,type[0]))
							                 return false;
								}
						if(type[2]=="DT"){//BY LD KEVIN type[2]="DT" 自定义字段添加日期时间控件                               
							if(!dateTimesecValidate(curr_fieldname,fieldlabel,type[2]))
							return false;
						}else if(typeof(type[3])=="undefined"&&type[2]!="DT") {var currdatechk="OTH"}
						else {var currdatechk=type[3]}
						//edit:kevin date:2013-05-30 reason:4028 type[2]!='time_start' 时间typeofdata:DT~M~time_start
						if(type[0]!="DT" && type[2]!="DT" && type[2]!='time_start')
						{
							if (!dateTimeValidate(curr_fieldname,type[2],fieldlabel,currdatechk))
							return false;
						}
						
						if (type[4]&&type[2]!="DT") {
							if (!dateTimeComparison(curr_fieldname,type[2],fieldlabel,type[5],type[6],type[4]))
								return false

						}
					}

				
				break;
				case "D"  :

					if ( CrmPopup.getHtmlobjval(divid,curr_fieldname).replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0)
					{
						if(typeof(type[2])=="undefined") var currdatechk="OTH"
						else var currdatechk=type[2]

							if (!qcdateValidate(curr_fieldname,fieldlabel,currdatechk))
								return false
									if (type[3]) {

										if (!qcdateComparison(curr_fieldname,fieldlabel,type[4],type[5],type[3]))
											return false
									}
					}
				break;
				case "T"  :
					if ( CrmPopup.getHtmlobjval(divid,curr_fieldname).replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0)
					{
						if(typeof(type[2])=="undefined") var currtimechk="OTH"
						else var currtimechk=type[2]

							if (!timeValidate(curr_fieldname,fieldlabel,currtimechk))
								return false
									if (type[3]) {
										if (!timeComparison(curr_fieldname,fieldlabel,type[4],type[5],type[3]))
											return false
									}
					}
				break;
				case "I"  :
                
					if ( CrmPopup.getHtmlobjval(divid,curr_fieldname).replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0)
					{
						if (CrmPopup.getHtmlobjval(divid,curr_fieldname).length!=0)
						{
							if (!qcintValidate(curr_fieldname,fieldlabel))
								return false
							if (type[2]) {
								if (!qcnumConstComp(curr_fieldname,fieldlabel,type[2],type[3]))
									return false
							}
						}
					}
				break;
				case "N"  :
					case "NN" :
                   
                    
					if ( CrmPopup.getHtmlobjval(divid,curr_fieldname).replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0)
					{
						if (CrmPopup.getHtmlobjval(divid,curr_fieldname).length!=0)
						{
							if (typeof(type[2])=="undefined") var numformat="any"
							else var numformat=type[2]

								if (type[0]=="NN") {

									if (!numValidate(curr_fieldname,fieldlabel,numformat,true))
										return false
								} else {
									if (!numValidate(curr_fieldname,fieldlabel,numformat))
										return false
								}
							if (type[3]) {
								if (!numConstComp(curr_fieldname,fieldlabel,type[3],type[4]))
									return false
							}
						}
					}
				break;
				case "E"  :
					if (CrmPopup.getHtmlobjval(divid,curr_fieldname).replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0)
					{
						if (CrmPopup.getHtmlobjval(divid,curr_fieldname).length!=0)
						{
							var etype = "EMAIL"
								if (!qcpatternValidate(curr_fieldname,fieldlabel,etype))
									return false
						}
					}
				break;
			}
		}
	}
     
       //added to check Start Date & Time,if Activity Status is Planned.//start
        for (var j=0; j<qcfieldname.length; j++)
		{
			curr_fieldname = qcfieldname[j];
            curr_fieldname=CrmPopup.deletequotation(curr_fieldname);
           	var fieldlabel = qcfieldlabel[j];
            fieldlabel=CrmPopup.deletequotation(fieldlabel);
			if(CrmPopup.isExistsObj(divid,curr_fieldname) )
			{
				if(curr_fieldname == "date_start")
				{
				
						var startdatevalue =CrmPopup.getHtmlobjval(divid,curr_fieldname).replace(/^\s+/g, '').replace(/\s+$/g, '')
				}
				if(curr_fieldname == "time_start")
				{
				
						var timeval=CrmPopup.getHtmlobjval(divid,curr_fieldname).replace(/^\s+/g, '').replace(/\s+$/g, '')
				}
				if(curr_fieldname == "eventstatus" || curr_fieldname == "taskstatus")
				{
				  
					var statusvalue = ld("#"+divid+" [name="+curr_fieldname+"] option:selected").val().replace(/^\s+/g, '').replace(/\s+$/g, '')
					var statuslabel = qcfieldlabel[j++];
				}
			}
		}
	if(statusvalue == "Planned")
        {
               var dateelements=splitDateVal(startdatevalue)
	       var hourval=parseInt(timeval.substring(0,timeval.indexOf(":")))
               var minval=parseInt(timeval.substring(timeval.indexOf(":")+1,timeval.length))
               var dd=dateelements[0]
               var mm=dateelements[1]
               var yyyy=dateelements[2]

               var chkdate=new Date()
               chkdate.setYear(yyyy)
               chkdate.setMonth(mm-1)
               chkdate.setDate(dd)
	       chkdate.setMinutes(minval)
               chkdate.setHours(hourval)
		if(!comparestartdate(chkdate)) return false;


	 }//end
	return true;
}

function qcemptyCheck(fldName,fldLabel, fldType) {
    var divid=CrmPopup.global_listPopupObj[CrmPopup.global_listPopupObj.length-1].divid;
   
	var currObj=CrmPopup.findHtmlobj(divid,fldName);

	if (fldType=="text") {
		if (currObj.val().replace(/^\s+/g, '').replace(/\s+$/g, '').length==0) {
			var confirm_str = fldLabel+arrJsPopLabel['CANOTEMPTY'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			currObj.focus();
	     	return false;
		} else{
       		return true;
		}
	}
     else if(fldType=='select-multiple')
    {
        //23925: 联系人>编辑：多选框字段设为必填字段，编辑联系人，保存提示“多选框”不能为空。实际上已经录入内容。
        if(CrmPopup.findHtmlobj(divid,fldName).find( "option:selected").length<=0)
        {
            	var confirm_str = fldLabel+arrJsPopLabel['CANOTEMPTY'];
            	RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                return false;
        }
    }
    else if(currObj.prop("tagName").toLowerCase()=='select')
    {       
       
        	if(trim(currObj.find("option:selected").text())==''){	
			var confirm_str = fldLabel+arrJsPopLabel['CANOTEMPTY'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
	    	return false;
			} else
			return true;
    } 
    else {
		if (trim(currObj.val()) == "" ) {		
			var confirm_str = fldLabel+arrJsPopLabel['CANOTEMPTY'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
	    	return false;
			} else
			return true;
	}
    return true;

}

function qcpatternValidate(fldName,fldLabel,type) {
     divid=CrmPopup.global_listPopupObj[CrmPopup.global_listPopupObj.length-1].divid;
	var currObj=CrmPopup.findHtmlobj(divid,fldName);
	if (type.toUpperCase()=="EMAIL") //Email ID validation
	{
		
		var re=new RegExp(/^[a-zA-Z0-9]+([\_\-\.]*[a-zA-Z0-9]+[\_\-]?)*@[a-zA-Z0-9]+([\_\-]?[a-zA-Z0-9]+)*\.+([\_\-]?[a-zA-Z0-9])+(\.?[a-zA-Z0-9]+)*$/)
	}
	
	if (type.toUpperCase()=="DATE") {//DATE validation 
		

		switch (userDateFormat) {
			case "yyyy-mm-dd" : 
								var re = /^\d{4}(\-|\/|\.)\d{1,2}\1\d{1,2}$/
								break;
			case "mm-dd-yyyy" : 
			case "dd-mm-yyyy" : 
								var re = /^\d{1,2}(\-|\/|\.)\d{1,2}\1\d{4}$/								
		}
	}
	
	if (type.toUpperCase()=="TIME") {//TIME validation
		var re = /^\d{1,2}\:\d{1,2}$/
	}
	
	//Asha: Remove spaces on either side of a Email id before validating
	if (type.toUpperCase()=="EMAIL") currObj.value = trim(currObj.value);
    
	if (!re.test(currObj.val())) {
		var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		currObj.focus()
		return false
	}
	else return true
}
function qcdateValidate(fldName,fldLabel,type) {
	if(qcpatternValidate(fldName,fldLabel,"DATE")==false)
		return false;
     var divid=CrmPopup.global_listPopupObj[CrmPopup.global_listPopupObj.length-1].divid;
	var currObj=CrmPopup.findHtmlobj(divid,fldName);
	dateval=currObj.val().replace(/^\s+/g, '').replace(/\s+$/g, '') 

	var dateelements=splitDateVal(dateval)
	
	dd=dateelements[0]
	mm=dateelements[1]
	yyyy=dateelements[2]
	
	if (dd<1 || dd>31 || mm<1 || mm>12 || yyyy<1 || yyyy<1000) {
		var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		currObj.focus()
		return false
	}
	
	if ((mm==2) && (dd>29)) {//checking of no. of days in february month
		var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		currObj.focus()
		return false
	}
	
	if ((mm==2) && (dd>28) && ((yyyy%4)!=0)) {//leap year checking
		var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		currObj.focus()
		return false
	}

	switch (parseInt(mm)) {
		case 2 : 
		case 4 : 
		case 6 : 
		case 9 : 
		case 11 :	if (dd>30) {
						var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
						RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
						currObj.focus()
						return false
					}	
	}
	
	var currdate=new Date()
	var chkdate=new Date()
	
	chkdate.setYear(yyyy)
	chkdate.setMonth(mm-1)
	chkdate.setDate(dd)
	
	if (type!="OTH") {
		if (!compareDates(chkdate,fldLabel,currdate,"current date",type)) {
			forms[fldName].focus()
			return false
		} else return true;
	} else return true;
}

function qcdateComparison(fldName1,fldLabel1,fldName2,fldLabel2,type) {
    
     var divid=CrmPopup.global_listPopupObj[CrmPopup.global_listPopupObj.length-1].divid;

	var dateval1=CrmPopup.findHtmlobj(divid,fldName1).val().replace(/^\s+/g, '').replace(/\s+$/g, '')
	var dateval2=CrmPopup.findHtmlobj(divid,fldName2).val().replace(/^\s+/g, '').replace(/\s+$/g, '')

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
		if (!compareDate(date1,fldLabel1,date2,fldLabel2,type)) {
			CrmPopup.findHtmlobj(divid,fldName1).focus()
			return false
		} else return true;
	} else return true
}

function qcintValidate(fldName,fldLabel) {
   
   var divid=CrmPopup.global_listPopupObj[CrmPopup.global_listPopupObj.length-1].divid;
	var val=CrmPopup.findHtmlobj(divid,fldName).val().replace(/^\s+/g, '').replace(/\s+$/g, '')
	if (isNaN(val) || (val.indexOf(".")!=-1 && fldName != 'potential_amount')) 
	{
		var confirm_str = arrJsPopLabel['INVALID']+fldLabel;
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		CrmPopup.findHtmlobj(divid,fldName).focus()
		return false
	}
	else if( (fldName != 'employees' || fldName != 'noofemployees') && (val < -2147483648 || val > 2147483647))
	{
		var confirm_str = fldLabel +alert_arr.OUT_OF_RANGE;
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
	else if((fldName == 'employees' || fldName == 'noofemployees') && (val < 0 || val > 2147483647))
	{
		var confirm_str = fldLabel +alert_arr.OUT_OF_RANGE;
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
	else
	{
		return true
	}
}

function qcnumConstComp(fldName,fldLabel,type,constval) {
       var divid=CrmPopup.global_listPopupObj[CrmPopup.global_listPopupObj.length-1].divid;
	var val=parseFloat(CrmPopup.findHtmlobj(divid,fldName).val().replace(/^\s+/g, '').replace(/\s+$/g, ''))
	constval=parseFloat(constval)

	var ret=true
	switch (type) {
		case "L"  : if (val>=constval) {
						var confirm_str = fldLabel+arrJsPopLabel['SHOULDLESSTHAN']+constval;
						RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
						ret=false
					}
					break;
		case "LE" :	if (val>constval) {
					var confirm_str = fldLabel+arrJsPopLabel['SHOULDLESSTHANOREQUAL']+constval;
					RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			        ret=false
					}
					break;
		case "E"  :	if (val!=constval) {
										var confirm_str = fldLabel+arrJsPopLabel['SHOULDBEEQUAL']+constval;
										RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                                        ret=false
                                }
                                break;
		case "NE" : if (val==constval) {
							var confirm_str = fldLabel+alert_arr.SHOULDNOTBE_EQUAL+constval;
							RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
							ret=false
					}
					break;
		case "G"  :	if (val<=constval) {
							var confirm_str = fldLabel+alert_arr.SHOULDBE_GREATER+constval;
							RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
							ret=false
					}
					break;
		case "GE" : if (val<constval) {
							var confirm_str = fldLabel+alert_arr.SHOULDBE_GREATER_EQUAL+constval;
							RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
							ret=false
					}
					break;
	}
	
	if (ret==false) {
		CrmPopup.findHtmlobj(divid,fldName).focus()
		return false
	} else return true;
}
function qcdateTimeValidate(dateFldName,timeFldName,fldLabel,type) {
	if(qcpatternValidate(dateFldName,fldLabel,"DATE")==false)
		return false;
  
    var divid=CrmPopup.global_listPopupObj[CrmPopup.global_listPopupObj.length-1].divid;
	dateval=CrmPopup.findHtmlobj(divid,dateFldName).replace(/^\s+/g, '').replace(/\s+$/g, '').substr(0,10); 
	var dateelements=splitDateVal(dateval);
	
	dd=dateelements[0];
	mm=dateelements[1];
	yyyy=dateelements[2];
	
	if (dd<1 || dd>31 || mm<1 || mm>12 || yyyy<1 || yyyy<1000) {
		var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		CrmPopup.findHtmlobj(divid,dateFldName).focus()
		return false
	}
	
	if ((mm==2) && (dd>29)) {//checking of no. of days in february month
		var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		CrmPopup.findHtmlobj(divid,dateFldName).focus()
		return false
	}
	
	if ((mm==2) && (dd>28) && ((yyyy%4)!=0)) {//leap year checking
		var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		CrmPopup.findHtmlobj(divid,dateFldName).focus()
		return false
	}

	switch (parseInt(mm)) {
		case 2 : 
		case 4 : 
		case 6 : 
		case 9 : 
		case 11 :	if (dd>30) {
						var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
						RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
						CrmPopup.findHtmlobj(divid,dateFldName).focus()
						return false
					}	
	}
	
	if (qcpatternValidate(timeFldName,fldLabel,"TIME")==false)
		return false
		
	var timeval=CrmPopup.findHtmlobj(divid,timeFldName).val().replace(/^\s+/g, '').replace(/\s+$/g, '')
	var hourval=parseInt(timeval.substring(0,timeval.indexOf(":")))
	var minval=parseInt(timeval.substring(timeval.indexOf(":")+1,timeval.length))
	var currObj=CrmPopup.findHtmlobj(divid,timeFldName);
	
	if (hourval>23 || minval>59) {
		var confirm_str = arrJsPopLabel['PLEASEENTERTHECORRECT']+' '+fldLabel;
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		currObj.focus()
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
		if (!compareDates(chkdate,fldLabel,currdate,"current date & time",type)) {
			CrmPopup.findHtmlobj(divid,dateFldName).focus()
			return false
		} else return true;
	} else return true;
}


function qcSave(obj,module)
{
    var htmlurl='';
   var divid=CrmPopup.getPopupObj("last").divid;
   var qcpopupobj=CrmPopup.getPopupObj("last");

   var  btnobj=document.getElementById(qcpopupobj.divid+"_btnok")
   btnobj.disabled=true;
    if(getFormValidate("")) 
    {
       
         
		   var fieldonlyfld = '';//需要唯一判断的字段
            var qcfieldname = qcpopupobj.fieldname.split(",");
            for(var i=0;i<qcfieldname.length;i++)
            {
				//将唯一判断的字段取出来
                var curr_fieldname=CrmPopup.deletequotation(qcfieldname[i]);
                
				 if(CrmPopup.isExistsObj(divid,curr_fieldname))
                 {
                    
                    var elementobj=CrmPopup.findHtmlobj(divid,curr_fieldname);
                    
                    if(1 == elementobj.attr("fieldonly")){
				            	fieldonlyfld += curr_fieldname + ',';
    				}
    
                        htmlurl+='&'+curr_fieldname+'='+encodeURIComponent(CrmPopup.findHtmlobj(divid,curr_fieldname).val());
                     
                 }
            
            }
           
		
			/**
			 * 判断当前创建客户、联系人，是否为群发邮件、短信界面
			 * @reason 0011795 群发短信界面：联系人、客户选择窗口中快速创建联系人和客户后，没有带出手机、公司电话
			 * @author Tujt 2014-09-28
			 
             if(window.opener!=undefined)
             {
                if(window.opener.document.sendSMS != undefined){
				htmlurl += '&qctype=sendSMS';
    			}else if( window.opener.document.EditView.module.value == 'Emails'){
    				htmlurl += '&qctype=Emails';
    			}
    			
             }*/
             if(!empty(fieldonlyfld)){
    				htmlurl += '&fieldonlyfld='+fieldonlyfld;
    			}
			var frommodule="";
            if(CrmPopup.global_listPopupObj.length>=2)
            {
                 var parentdivid=CrmPopup.getPopupObj(CrmPopup.global_listPopupObj.length-2).divid;
                frommodule=CrmPopup.findHtmlobj(parentdivid,"module").val();
            }
                
            new Ajax.Request(
                		'index.php',
                		{
                			queue: {
                				position: 'end',
                				scope: 'command'
                			},
                			method: 'post',
                			postBody: "module="+module+"&action="+module+"Ajax&file=SaveQuickCreate"+htmlurl+"&frommodule="+frommodule,
                			onComplete: function(response) {
                		      
								var rest = response.responseText;
								/**
								* 增加字段唯一判断，并通过回传的值判断是否重复
								* @reason 0014245: 客户->客户名称唯一性判断漏洞：创建其他单据->选择该资料->使用快速创建未控制字段唯一性
								* @author Tujt 2015-04-21
								*/
								if(!empty(fieldonlyfld)){
									if(rest.indexOf('##systemcode##$$') > -1){//自动生成编号重复
										var rests = rest.split('##systemcode##$$');
										var objid = rests[1];
										var systemcode = rests[2];
										document.getElementById(objid).value = systemcode;
										RemindsMsg("","LdPopWidth400px","","yes","",rests[3]);
										btnobj.disabled=false;
										return true;
									}else if(rest.indexOf('##error##') > -1){//字段重复
										var rests = rest.split('##error##');
										RemindsMsg("","LdPopWidth400px","","yes","",rests[1]);
										btnobj.disabled=false;
										return false;
									}
								}
								var results = rest.split('####SUCCESS#####');
								var id=results[1];
							
							
								//工作协同
								if(document.getElementById('popup_type') != undefined){
									var pop_type = document.getElementById('popup_type').value;
									if(pop_type == 'specific_account_address_pop'||pop_type == 'specific_contact_address_pop'){
										if(location.search.split('Popup').length>1){
											window.close();
										}
										if(pop_type == 'specific_account_address_pop'){
											if(set_return_account_address != undefined){
												set_return_account_address(id,results[2],'','','');
											}
										}
										if(pop_type == 'specific_contact_address_pop'){
											if(set_return_contact_address != undefined){
												set_return_contact_address(id,results[2],'','','');
											}
										}
									}
								}
                                //关闭当前界面
                                 popupobj=CrmPopup.getPopupObj("last");
                                popupobj.CancelEvent();
                                //30617: 单据新增界面：选择客户弹出层--打开快速创建弹出层，点击取消关闭快速创建弹出层后，结果选择客户弹出层也被关闭了
                                if(CrmPopup.getPopupObj('last')!=undefined&&CrmPopup.getPopupObj('last').type==selectSearchPopup.type)
                                     {
                                        CrmPopup.getPopupObj('last').CancelEvent();//删除选择框的弹出层
                                     }
                                   
                                var winobj=window;
                                if(global_ispopup_page=='yes')
                                {
                                    winobj=window.opener;
                                }
                                if(module!="Products")
                               	    selectrelated(module,'',id,results[2],'','',frommodule);//给上一层界面赋值，且删除当前弹出层
                                popupobj=CrmPopup.getPopupObj("last");//获取快速创建弹出层的上一层弹出层
                                if(popupobj==undefined)
                                {
                                    //一定要这样判断，因为新页签也有可能是多层弹出层（快速创建)
                                    //例如首页->工作协同->日志->联系人
                                    popupobj=winobj.CrmPopup.getPopupObj("last");
                                }
                                if(popupobj!=undefined)//群发邮件界面没有弹出层
                                var divid=popupobj.divid;
                                
						           if(module == 'Contacts'){
							     
									//群发短信
									if(location.search.split('set_return_groupmasssms').length>1){
                                       document.getElementById('contactid').value=id;
                                        contact_btn_MassSMS();
                                    }
									if(window.opener!=undefined&&window.opener.document.getElementById('parent_id')!=undefined&&window.opener.document.getElementById('cc_name')!=undefined){
                                        //发送邮件
                                        var lastname=results[2];
                                        var emails=results[3];
                                       
                                        emails=emails.split(',');
                                        
                                        var emailfields=results[4];
                                        emailfields=emailfields.split(',');
                                        for(var jk=0;jk<emailfields.length;jk++){
                                            
                                             set_return_emails(id,emailfields[jk],lastname,emails[jk],'',jk+1);
                                             
                                        }
                                        window.close();
									} else if(window.opener!=undefined&&window.opener.document.getElementById('parent_name') != undefined &&location.search.split('set_return_groupemails').length>1){
                                        /**
										 * @reason 0011796 群发邮件界面：联系人、客户选择窗口中快速创建联系人和客户后，没有带出Email、公司邮件
										 * @author Tujt 2014-09-26
										 */
                                        var lastname=results[2];
                                        var emails=results[3];
                                        emails=emails.split(',');
										//window.opener.document.getElementById('parent_name').innerHTML += emails+'<'+lastname+'>'+"\r\n";
										var emailfields=results[4];
                                        emailfields=emailfields.split(',');
                                        for(var jk=0;jk<emailfields.length;jk++){
                                             set_return_emails(id,emailfields[jk],lastname,emails[jk],'',jk+1);
                                             
                                        }
                                        window.close();
                                    }
                                    vtlib_setvalue_from_popup(id,results[2], "related_to");//相关对象
                                    
								}else if(module == 'Potentials'){
									if(document.getElementById('detail_quickcreate') != undefined && document.getElementById('detail_quickcreate').value >= 1){
										var rowid = document.getElementById('detail_quickcreate').value;
										ld('#entitytypeid'+rowid).val(id);
										ld('#entitytypeid'+rowid+'_name').val(results[2]);
								   }
								}else if(module == 'Products'){
								   
									/**
									* 更新操作
									* edit:can
									* date:20131228
									* reason:6512: IE8浏览器兼容模式下：采购订单新增界面点击产品产品调用图标，弹出的产品调用窗口中快速创建产品无法保存，点击保存按钮无效
									* */
									var proinfo=id.split('###');
									if(document.getElementById('popup_type')!=undefined && (document.getElementById('popup_type').value=='inventory_prod_po'||document.getElementById('popup_type').value=='inventory_prod')){
										if(proinfo[4]=='$$@'){
											proinfo[4]='';
										}
                                        
										if(proinfo[5]=='$$@'){
											proinfo[5]='';
										}
										
										//15734: 服务合同-新增：产品名称-选择产品窗口快速创建产品后没有带出产品名称
										var str_json=eval('('+proinfo[5]+')')?eval('('+proinfo[5]+')'):JSON.parse(proinfo[5]);
										var rowid = document.getElementById('curr_row').value;
										setproduct_value(proinfo[0],str_json,rowid);
										window.close();
									}else{
								
										set_return_specific(proinfo[0],proinfo[1]);
                                        window.close();
									}
								}
                            
						      	
                			}
                              
                		}
                        
		          );
        } 
        else 
        { 
            btnobj.disabled=false;
            return false;
        }
    
}
qcSave.funname="qcSave";



