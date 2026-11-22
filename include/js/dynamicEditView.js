
function EditViewformValidation(module,form,edit_type) {
    
	//Validation for Portal User
    var act_time;
    if(gVTModule == 'Contacts' && gValidationCall != 'tabchange')
	{
		//if existing portal value = 0, portal checkbox = checked, ( email field is not available OR  email is empty ) then we should not allow -- OR --
		//if existing portal value = 1, portal checkbox = checked, ( email field is available     AND email is empty ) then we should not allow
		if(edit_type=='')
		{
			if(getObj('existing_portal') != null
				&& ((getObj('existing_portal').value == 0 && getObj('portal').checked &&
					(getObj('email') == null || trim(getObj('email').value) == '')) ||
				(getObj('existing_portal').value == 1 && getObj('portal').checked &&
					getObj('email') != null && trim(getObj('email').value) == ''))) {

				var confirm_str = arrJsPopLabel['PLEASEENTERVALIDEMAIL'];
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				return false;
			}
		}
		else
		{
			if(getObj('portal') != null && getObj('portal').checked && getObj('portal_mass_edit_check').checked && (getObj('email') == null || trim(getObj('email').value) == '' || getObj('email_mass_edit_check').checked==false))
			{
				var confirm_str = arrJsPopLabel['PLEASEENTERVALIDEMAIL'];
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				return false;
			}
			if((getObj('email') != null && trim(getObj('email').value) == '' && getObj('email_mass_edit_check').checked) && !(getObj('portal').checked==false && getObj('portal_mass_edit_check').checked))
			{
				var confirm_str = arrJsPopLabel['SAVEEMPTYEMAILCANPROHIBITACCESS'];
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				return false;
			}
		}
	}
    if(gVTModule=='CashDeposit'||gVTModule=='PutCash'){
		/**
		 * 提现单编辑界面，点击快速创建提现单，将两个账户设置为不一样，关闭后，
		 * 提现单编辑页面将跳过账户判断直接保存，因为这个时候界面上有了两个name值
		 * 现在精确判断form表单下的name值，保证判断的精确性
		 * @reason 0013946: 快速创建-存现单、提现单：当转出账户和转入账号一样保存时，没有进行判断
		 * @author Tujt 2015-03-10
		 */
		var inputs;
		if(document.EditView != undefined)
			inputs = document.EditView;
		else if(document.DetailView != undefined)
			inputs = document.DetailView;
        if(inputs.outaccount != undefined && inputs.inaccount != undefined)
        {
            if(inputs.outaccount.value == inputs.inaccount.value){
                var confirm_str = arrJsPopLabel['taaacnbtttsa'];
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                return false;
            }   
        }
    }
    if(gVTModule == 'Attachment' && gValidationCall != 'tabchange')
	{
		if(edit_type=='')
		{
			if(trim(getObj('file_name').value) == '') 
            {
				//上传附件为空，请上传附件！
                var confirm_str = arrJsPopLabel['PLEASEUPLOADATT'];
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				return false;
			}
		}
	}
    /*202 收款单 销售发票 佣金单  费用报销 源单合同订单必录时， 判断是否为空*/
    if(document.getElementById('salesordertypeofdata') != undefined && document.getElementById('salesordertypeofdata').value == 'M')
    {
        if(gVTModule == 'Expense')
        {
            if(document.EditView.salesorder_name.value == '')
            {
                var confirm_str = arrJsPopLabel['SOURCEMODULE'] + arrJsPopLabel['CANOTEMPTY'];
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                return false;
            }
        }
        else if(gVTModule == 'SendCashBill' || gVTModule == 'Stock')
        {
            if(document.getElementById('purchaseorder_id').value == '')
            {
                var confirm_str = arrJsPopLabel['PURCHASEORDER'] + arrJsPopLabel['CANOTEMPTY'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                return false;
            }
        }
        else
        {
            if(document.getElementById('salesorder_id').value == '')
            {
				if(gVTModule == 'PurchaseOrder')
					var confirm_str = arrJsPopLabel['SALESORDER'] + arrJsPopLabel['CANOTEMPTY'];
				else
					var confirm_str = arrJsPopLabel['SOURCEMODULE'] + arrJsPopLabel['CANOTEMPTY'];

				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                return false;
            }
        }
        
    }
	if(gVTModule == 'SalesOrder') {
		if(edit_type == 'mass_edit') {
			if (getObj('enable_recurring_mass_edit_check') != null
				&& getObj('enable_recurring_mass_edit_check').checked
				&& getObj('enable_recurring') != null) {
				if(getObj('enable_recurring').checked && (getObj('recurring_frequency') == null
					|| trim(getObj('recurring_frequency').value) == '--None--' || getObj('recurring_frequency_mass_edit_check').checked==false)) {
					//不需要修改
                    //alert(alert_arr.RECURRING_FREQUENCY_NOT_PROVIDED);
					return false;
				}
				if(getObj('enable_recurring').checked == false && getObj('recurring_frequency_mass_edit_check').checked
					&& getObj('recurring_frequency') != null && trim(getObj('recurring_frequency').value) !=  '--None--') {
					//不需要修改
                    //alert(alert_arr.RECURRING_FREQNECY_NOT_ENABLED);
					return false;
				}
			}
		} else if(getObj('enable_recurring') != null && getObj('enable_recurring').checked) {
			if(getObj('recurring_frequency') == null || getObj('recurring_frequency').value == '--None--') {
				//不需要修改
                //alert(alert_arr.RECURRING_FREQUENCY_NOT_PROVIDED);
				return false;
			}
			var start_period = getObj('start_period');
			var end_period = getObj('end_period');
			if (trim(start_period.value) == '' || trim(end_period.value) == '') {
				var confirm_str = arrJsPopLabel['DTARTTIMEENDTIMECANOTEMPTY'];
				RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
				return false;
			}
		}
	}

    //add by ld tifa 20130304 for reminds time should higher than current time

    if(gVTModule == 'Reminds'||gVTModule == 'ContactRecords'){
        if(gVTModule == 'Reminds'||document.getElementById('pop_reminds')!=undefined&&document.getElementById('pop_reminds').checked){
            
            /*txt_hour=getObj('date_time_hr').options[getObj('date_time_hr').options.selectedIndex].value;
            txt_min=getObj('date_time_min').options[getObj('date_time_min').options.selectedIndex].value;
            act_time=getObj('date_only').value+' '+txt_hour+':'+txt_min; 
            getObj('date_time').value=act_time;
            getObj('time_reminds').value=txt_hour+':'+txt_min;*/
			if(gVTModule == 'Reminds'){
				act_time=getObj('date_time').value;
				
			}
			else{
				act_time=getObj('date_only').value;
							getObj('date_time').value=act_time;
			}
                
            
            cur_time=new Date();
            cur_time.setMinutes(cur_time.getMinutes()-10);
            now_mon=cur_time.getMonth()+1;
            cur_time=cur_time.getFullYear()+'-'+getDigital(now_mon)+'-'+getDigital(cur_time.getDate())+' '+getDigital(cur_time.getHours())+':'+getDigital(cur_time.getMinutes());
            if(act_time<cur_time ){
                var confirm_str = arrJsPopLabel['REMINDENTIMESHOULDGREATERCURRENTTIME'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                return false;
            }
        }
        //Edit:can reason:9873: 手动新建提醒后，弹出的提醒查看界面，相关模块字段没有显示数据
        if(gVTModule == 'Reminds')
        getObj('reltab').value=getObj('related_to_type').options[getObj('related_to_type').options.selectedIndex].value;

        if(gVTModule == 'ContactRecords'){
             cur_time=new Date();
            cur_time.setMinutes(cur_time.getMinutes()-10);
            now_mon=cur_time.getMonth()+1;
            cur_time=cur_time.getFullYear()+'-'+getDigital(now_mon)+'-'+getDigital(cur_time.getDate())+' '+getDigital(cur_time.getHours())+':'+getDigital(cur_time.getMinutes());
            if(document.getElementById('set_remind')!=undefined&&document.getElementById('set_remind').checked)
            {
                
                act_time=getObj('email_date_only').value;
                getObj('email_remind').value=act_time;
            }
            if(document.getElementById('pop_reminds')!=undefined&&document.getElementById('pop_reminds').checked){
              
                act_time=getObj('date_only').value;
                getObj('date_time').value=act_time;
               }
            
          
            if(act_time!=undefined &&act_time<cur_time ){
                var confirm_str = arrJsPopLabel['REMINDENTIMESHOULDGREATERCURRENTTIME'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                return false;
            }
            if((document.getElementById('set_remind')!=undefined && document.getElementById('set_remind').checked) ||
             (document.getElementById('pop_reminds')!=undefined && document.getElementById('pop_reminds').checked)){
                textValue = getObj('contents').value;
            if(trim(textValue) == '' || trim(textValue) == '<br>'){
                var confirm_str = arrJsPopLabel['REMINDERSCANOTEMPTY'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                return false;
            }
            }
            
        }

    }
    if(fieldname != undefined){
		for (var i=0; i<fieldname.length; i++) {
		 
			if(edit_type == 'mass_edit') {
				if(fieldname[i]!='salutationtype')
					var obj = getObj(fieldname[i]+"_mass_edit_check");
				if(obj == null || obj.checked == false) continue;
			}
			if(getObj(fieldname[i]) != null)
			{
				var type=fielddatatype[i].split("~")
				if (type[1]=="M") {
				  if(getObj(fieldname[i]).type!=undefined)
				  {
				  
					if (!emptyCheck(fieldname[i],fieldlabel[i],getObj(fieldname[i]).type))
						   return false;
				  }
						
				}
				switch (type[0]) {
				  case "P"://正整数
						var fldobj= getObj(fieldname[i]);
						var r = /^\+?[1-9][0-9]*$/;　　//正整数 
					   
						if( isNaN(fldobj.value))
						{
							var confirm_str = fieldlabel[i]+arrJsPopLabel['SHOULDPOSITIVEINTEGER'];
							RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
							return false;
						}
						if(!r.test(fldobj.value))
						{
							 var confirm_str = fieldlabel[i]+arrJsPopLabel['SHOULDPOSITIVEINTEGER'];
							 RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
							return false;
						}
						break;
					case "O"  :
						break;
					case "V"  :
					//by andy qq 改进 临时会话
						if(fieldname[i] == 'qq'){
							if(getObj(fieldname[i]).value != '')
							{
								if(!isQQ(getObj(fieldname[i]).value)){
								var confirm_str = fieldlabel[i]+arrJsPopLabel['FORMATERROR'];
								RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
								return false;
								}
							}
						}
						break;
					case "C"  :
						break;
					case "DT" :                
						if (getObj(fieldname[i]) != null && getObj(fieldname[i]).value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0)
						{
							if (type[1]=="M")
								if (!emptyCheck(fieldname[i],fieldlabel[i],type[2]))
									return false
									if(type[0]=='DT'){
										if(!dateTimesecValidate(fieldname[i],fieldlabel[i],type[0]))
								return false;
									}
							if(type[2]=="DT"){//BY LD KEVIN type[2]="DT" 自定义字段添加日期时间控件                               
								if(!dateTimesecValidate(fieldname[i],fieldlabel[i],type[2]))
								return false;
							}else if(typeof(type[3])=="undefined"&&type[2]!="DT") {var currdatechk="OTH"}
							else {var currdatechk=type[3]}
							//edit:kevin date:2013-05-30 reason:4028 type[2]!='time_start' 时间typeofdata:DT~M~time_start
							if(type[0]!="DT" && type[2]!="DT" && type[2]!='time_start')
							{
								if (!dateTimeValidate(fieldname[i],type[2],fieldlabel[i],currdatechk))
								return false;
							}
							
							if (type[4]&&type[2]!="DT") {
								if (!dateTimeComparison(fieldname[i],type[2],fieldlabel[i],type[5],type[6],type[4]))
									return false

							}
						}
						break;
					case "D"  :
					
						if (getObj(fieldname[i]) != null && getObj(fieldname[i]).value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0)
						{
							if(typeof(type[2])=="undefined") var currdatechk="OTH"
							else var currdatechk=type[2]

							if (!dateValidate(fieldname[i],fieldlabel[i],currdatechk))
								return false
							if (type[3]) {
								if(gVTModule == 'SalesOrder' && fieldname[i] == 'end_period'
									&& (getObj('enable_recurring') == null || getObj('enable_recurring').checked == false)) {
									continue;
								}
							   
								if (!dateComparison(fieldname[i],fieldlabel[i],type[4],type[5],type[3]))
									return false
							}
						}
						break;
					case "T"  :
						if (getObj(fieldname[i]) != null && getObj(fieldname[i]).value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0)
						{
							if(typeof(type[2])=="undefined") var currtimechk="OTH"
							else var currtimechk=type[2]

							if (!timeValidate(fieldname[i],fieldlabel[i],currtimechk))
								return false
							if (type[3]) {
								if (!timeComparison(fieldname[i],fieldlabel[i],type[4],type[5],type[3]))
									return false
							}
						}
						break;
					case "I"  :
					
						if (getObj(fieldname[i]) != null && getObj(fieldname[i]).value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0)
						{
						  
							if (getObj(fieldname[i]).value.length!=0)
							{
								if (!intValidate(fieldname[i],'',fieldlabel[i]))
									return false
								if (type[2]) {
									if (!numConstComp(fieldname[i],fieldlabel[i],type[2],type[3]))
										return false
								}
							}
						}
						break;
					case "N"  :
					case "NN" :
						if (getObj(fieldname[i]) != null && getObj(fieldname[i]).value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0)
						{
							if (getObj(fieldname[i]).value.length!=0)
							{
								if (typeof(type[2])=="undefined") var numformat="any"
								else var numformat=type[2]
							   
								if(type[0]=="NN")
								{
									if (!numValidate(fieldname[i],fieldlabel[i],numformat,true))
										return false
								}
								else if (!numValidate(fieldname[i],fieldlabel[i],numformat))
									return false
								if (type[3]) {
									if (!numConstComp(fieldname[i],fieldlabel[i],type[3],type[4]))
										return false
								}
							}
						}
						break;
					case "E"  :
					
						if (getObj(fieldname[i]) != null && getObj(fieldname[i]).value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0)
						{
							if (getObj(fieldname[i]).value.length!=0)
							{
								var etype = "EMAIL";
								if (!patternValidate(fieldname[i],fieldlabel[i],etype))
									return false;
							}
						}
						break;
				}
				//start Birth day date validation
				if(fieldname[i] == "birthday" && getObj(fieldname[i]).value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0 )
				{
					var now =new Date()
					var currtimechk="OTH"
					var datelabel = fieldlabel[i]
					var datefield = fieldname[i]
					var datevalue =getObj(datefield).value.replace(/^\s+/g, '').replace(/\s+$/g, '')
					if (!dateValidate(fieldname[i],fieldlabel[i],currdatechk))
					{
						try {
							getObj(datefield).focus()
						} catch(error) { }
						return false
					}
					else
					{
						datearr=splitDateVal(datevalue);
						dd=datearr[0]
						mm=datearr[1]
						yyyy=datearr[2]
						var datecheck = new Date()
						datecheck.setYear(yyyy)
						datecheck.setMonth(mm-1)
						datecheck.setDate(dd)
						if (!compareDates(datecheck,datelabel,now,arrJsPopLabel['CURRENTDATE'],"L"))
						{
							try {
								getObj(datefield).focus()
							} catch(error) { }
							return false
						}
					}
				}
			//End Birth day
			}

		}
	}
	if(gVTModule == 'Contacts')
	{
		if(getObj('imagename'))
		{
			if(getObj('imagename').value != '')
			{
				var image_arr = new Array();
				image_arr = (getObj('imagename').value).split(".");
				var image_arr_last_index = image_arr.length - 1;
				if(image_arr_last_index < 0) {
					var confirm_str = arrJsPopLabel['AVAILABLEFILETYS'];
					RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
					return false;
				}
				var image_ext = image_arr[image_arr_last_index].toLowerCase();
				if(image_ext ==  "jpeg" || image_ext ==  "png" || image_ext ==  "jpg" || image_ext ==  "gif" || image_ext ==  "bmp" || image_ext ==  "ico")
				{
					return true;
				}
				else
				{
					var confirm_str = arrJsPopLabel['AVAILABLEFILETYS'];
					RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
					return false;
				}
			}
		}
	}

	//added to check Start Date & Time,if Activity Status is Planned.//start
	for (var j=0; j<fieldname.length; j++)
	{
		if(getObj(fieldname[j]) != null)
		{
			if(fieldname[j] == "date_start" || fieldname[j] == "task_date_start" )
			{
				var datelabel = fieldlabel[j]
				var datefield = fieldname[j]
				var startdatevalue = getObj(datefield).value.replace(/^\s+/g, '').replace(/\s+$/g, '')
			}
			if(fieldname[j] == "time_start" || fieldname[j] == "task_time_start")
			{
				var timelabel = fieldlabel[j]
				var timefield = fieldname[j]
				var timeval=getObj(timefield).value.replace(/^\s+/g, '').replace(/\s+$/g, '')
			}
			if(fieldname[j] == "eventstatus" || fieldname[j] == "taskstatus")
			{
				var statusvalue = getObj(fieldname[j]).value.replace(/^\s+/g, '').replace(/\s+$/g, '')
				var statuslabel = fieldlabel[j++]
			}
		}
	}
	if(statusvalue == "Planned")
	{
		var dateelements=splitDateVal(startdatevalue)

		var hourval=parseInt(timeval.substring(0,timeval.indexOf(":")))
		var minval=parseInt(timeval.substring(timeval.indexOf(":")+1,timeval.length))


		dd=dateelements[0]
		mm=dateelements[1]
		yyyy=dateelements[2]

		var chkdate=new Date()
		chkdate.setYear(yyyy)
		chkdate.setMonth(mm-1)
		chkdate.setDate(dd)
		chkdate.setMinutes(minval)
		chkdate.setHours(hourval)
		if(!comparestartdate(chkdate)) return false;
	}//end
  FieldDuplicateValidate(module,form);
	return false;
}



var eidtviewbol=false;
var http_reqfield;

function createfieldXMLHTTP()
     {
        var request;
        var browser=navigator.appName;
     
        if(browser=="Microsoft Internet Explorer")
        {
            var arrVersions=["MSXML2.XMLHttp.5.0","MSXML2.XMLHTTP.4.0","MSXML2.XMLHTTP.3.0","MSXML2.XMLHTTP","Microsoft.XMLHTTP"];
            for( var i=0;i<arrVersions.length;i++)
            {
                try
                {
                     request=new ActiveXObject(arrVersions[i]);
                    return request;
                }
                catch(exception)
                {
                }
            }
        }
        else 
        {
          request=new XMLHttpRequest();
          return request;
        }
     }
function RequestFieldDuplicate()
{
    if(http_reqfield.readyState==4)
    {
        if(http_reqfield.status==0||http_reqfield.status==200)
        {
                var str=http_reqfield.responseText;
                if(str.indexOf('##systemcode##$$')>=0)
                {
                    var results=str.split('##systemcode##$$');
                    var objid=results[1];
                    var systemcode=results[2];
                    puyoungJS_DialogBox.unblock();
                    document.getElementById(objid).value=systemcode;

					RemindsMsg("","LdPopWidth400px","","yes","",results[3]);
                    isDuplicate=true;
                    return ;
                }else if(str.indexOf('##error##') > -1)
                {
                    var results=str.split('##error##');
                    puyoungJS_DialogBox.unblock();
                    RemindsMsg("","LdPopWidth400px","","yes","",results[1]);
                    isDuplicate=true;
                }else if(str.indexOf('divNoRecord') > -1){
					//您没有权限执行这个操作（可能是查重）
					var confirm_str = arrJsPopLabel['NOPERMITTEDEXECUTE'];
					RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
					puyoungJS_DialogBox.unblock();
					isDuplicate=true;
				}
        }
    }
}
/*
edit:can
date:20130805
reason:自定义设置增加是否允许重复设置

*/
function FieldDuplicateValidate(module,oform,obj)
{
   
   
   var url="";
   var fieldvalue="";
   var recordid=oform.record.value;
   if(module=='Events')
   {
     module='Calendar';//edit:can reason:014634: 公司CRM：编辑日程管理，然后再保存，结果提示undefined。(账号：liver)
   }
   for(var i=0;i<oform.length;i++)
   {
    
      if(oform[i].getAttribute("fieldonly")&&oform[i].getAttribute("fieldonly")=="1")
      {
        fieldvalue=(trim(oform[i].value));
        if(oform[i].tagName.toLowerCase()=="select")
        {
            fieldvalue=trim(oform[i].options[oform[i].options.selectedIndex].value);
        }
        if(fieldvalue=="")
        {
            continue;
        }
        var bill_city='';
        var bill_state='';
         fieldvalue=encodeURIComponent(fieldvalue);
         url="index.php?module="+module+"&action="+module+"Ajax&file=FieldDuplicate&fieldname="+oform[i].name+"&fieldvalue="+fieldvalue+"&fieldid="+recordid;
         //edit:can date:20140821 reason:10837: 【保存】单据时，若提示单据编号重复，建议点击确定后，系统会自动生成新的，并且不重复的流水编号
         if(document.getElementById('bill_city')!=undefined)
         {
            bill_city=document.getElementById('bill_city').value;
            url=url+'&bill_city='+encodeURIComponent(bill_city);
         }
         if(document.getElementById('bill_state')!=undefined)
         {
            bill_state=document.getElementById('bill_state').value;
            url=url+'&bill_state='+encodeURIComponent(bill_state);
         }
         http_reqfield=createfieldXMLHTTP();
         http_reqfield.open("POST",url,false);
         isDuplicate=false;
         http_reqfield.onreadystatechange=RequestFieldDuplicate;
         http_reqfield.setRequestHeader("If-Modified-Since","0");
         http_reqfield.send();
         if(isDuplicate)
         {
            oform[i].focus();
            if(obj!=undefined)//edit:can reason:快速创建可以重复点击
            {
                 obj.disabled=false;
            }
            return false;
         }
            
      }
   }
   if(module=='PaymentPlans' && oform.paymentstatus!=undefined)
   {
  
      if(oform.paymentstatus[oform.paymentstatus.selectedIndex].value.indexOf('已收')!=-1)
      {

         if(confirm(arrJsPopLabel['ifthestatehasebeenselectedaspartofthe'])==false)
         {
            puyoungJS_DialogBox.unblock();
            return false;
         }
      }
    
   }
   if(module=='SendPayments' && oform.cpstatus!=undefined)
   {
      
      if(oform.cpstatus[oform.cpstatus.selectedIndex].value.indexOf('已付')!=-1)
      {

         if(confirm(arrJsPopLabel['ifthestatehasebeenselectedaspartofthe'])==false)
         {
            puyoungJS_DialogBox.unblock();
            return false;
         }
      }
    
   }

   if(module=='Users')//用户姓名判断是否重复，会用到该函数
   {
    
	   
                
   }
   else
   {
        //diony 2014-11-26 合同订单保存判断仓库是否被禁用，如果被禁用弹出窗口 
        if(module=='SalesOrder'&&document.getElementById('autowarehouseid')!=undefined)
        {
            fnvshobj(this,'outboundorderDiv');
            return false;;
        }
        else
        {
            
          //  oform.submit();
            return true;    
        }      	
   }
    return false;
    
}


/*
 * edit:chj
 * date:2014/12/17
 * 编辑、新增页面，切换币种，更改银行账户和当前页的所有金额字段
 */
function EditViewgetCurrencyRateAmount(obj,module,cur_id,formname)
{
	//根据原单自动带出币种ID,根据币种ID自动默认币种类型、银行账户
    var formobj=document.forms[formname];
    if(cur_id > 1)
	{
		//默认币种类型
		if(formobj.currency_id != undefined)
		{
			formobj.currency_id.value = cur_id;
			formobj.hidden_currency_id.value = cur_id;
	
			formobj.currency_id.value = cur_id;
		}
		//默认银行账户
		if(formobj.bankaccountsetid != undefined)
		{
			var bankaccountset = formobj.bankaccountsetid;
			var bank_len = bankaccountset.options.length;
			var opts = 0;
			for(var k = 0; k < bank_len; k++)
			{
				if(bankaccountset.options[opts].getAttribute('bank_curid') != cur_id)
				{
					bankaccountset.options.remove(opts);
				}else{
					opts++;
				}
			}
		}
		return false;
	}
    var currency_id = obj.value;    //选择后的币种ID
    var before_currency_id = '';    //选择前的币种ID
    var mode = '';
    if(formobj.mode != undefined)
        mode = formobj.mode.value;       
    if(module != 'BankAccountSet')//银行初始化不需要提醒
    {
        if(window.confirm(arrJsPopLabel['ALLCURRENCYOFAMOUNTWILLBEFIXED']))
        {
        }
        else
        {
            //取消，币种默认值还原
            formobj.currency_id.value = formobj.hidden_currency_id.value;
            return false;
        }
    }
    if(formobj.hidden_currency_id != undefined)
    {
        before_currency_id = formobj.hidden_currency_id.value;
        formobj.hidden_currency_id.value = currency_id; 
		formobj.currency_id.value = currency_id;
    }
    //alert('module=Users&action=UsersAjax&file=ChangeRateAmount&ajax=true&return_module='+module+'&currency_id='+currency_id+'&before_currency_id='+before_currency_id);
    new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody: 'module=Users&action=UsersAjax&file=ChangeRateAmount&ajax=true&return_module='+module+'&currency_id='+currency_id+'&before_currency_id='+before_currency_id,
			onComplete: function(response) { 
                if(response.responseText.indexOf('###SUCCESS###') > -1)
                {
                    var results=response.responseText.split('###SUCCESS###');
                    //获取结果集 0：选择前币种汇率 1：选择后的币种汇率 2：金额fieldname字段3:币种对应的银行账户信息
                    var result=results[1].split('|');
                    var fieldnameArr = result[2].split(',');
					var beforecurrency_id = parseFloat(result[0]);
					var selectcurrency_id = parseFloat(result[1]);
					if(formobj.hidden_currency_rate != undefined)
					{
						formobj.hidden_currency_rate.value = result[1];
					}
					//提现单和存现单 有转出和转入2个账户  select命名不一致
                    if(formobj.bankaccountsetid != undefined)
                    {
						var selectValue = formobj.bankaccountsetid;	//银行账户
						UpdateBankAccount(selectValue,result[3]);
						
                    }
					if(formobj.inaccount != undefined)
					{
						var selectValue = formobj.inaccount;	//转入账户
						UpdateBankAccount(selectValue,result[3]);
					}
					if(formobj.outaccount != undefined)
					{
						var selectValue = formobj.outaccount;	//转出账户
						UpdateBankAccount(selectValue,result[3]);
					}
					//收款单特殊控制 原单金额
					if(module == 'CashBill')
					{
						var tableName = document.getElementById('proTab');
						var prev = tableName.rows.length - 1;//列头函数
						//本次收款
						for(var i = 1; i<=prev; i++)
						{
							if(document.getElementById('curCashBill'+i) != undefined)
							{
								var curCashBill = document.getElementById('curCashBill'+i).value;
								curCashBill = parseFloat(curCashBill);
								if(beforecurrency_id == 1)
									curCashBill = curCashBill*selectcurrency_id;
								else
									curCashBill = parseFloat(curCashBill/beforecurrency_id)*selectcurrency_id;
								curCashBill = curCashBill.toFixed(2);
								document.getElementById('curCashBill'+i).value = curCashBill;
								document.getElementById('curCashBill'+i).onchange();
							}
						}
						//调整
						if(document.getElementById('nopaymentplan') != undefined && document.getElementById('nopaymentplan').value > 0)
						{
							var nopaymentplan = document.getElementById('nopaymentplan').value;
							nopaymentplan = parseFloat(nopaymentplan);
							if(beforecurrency_id == 1)
								nopaymentplan = nopaymentplan*selectcurrency_id;
							else
								nopaymentplan = parseFloat(nopaymentplan/beforecurrency_id)*selectcurrency_id;
							nopaymentplan = nopaymentplan.toFixed(2);
							document.getElementById('nopaymentplan').value = nopaymentplan;
							document.getElementById('nopaymentplan').onchange();
						}
					}
					//佣金单
					if(module == 'Commission')
					{
						var tableName = document.getElementById('proTab');
						var prev = tableName.rows.length - 1;//列头函数
						//本次收款
						for(var i = 1; i<=prev; i++)
						{
							if(document.getElementById('noamount'+i) != undefined && document.getElementById('noamount'+i).value > 0)
							{
								var noamount = document.getElementById('noamount'+i).value;
								noamount = parseFloat(noamount);
								if(beforecurrency_id == 1)
									noamount = noamount*selectcurrency_id;
								else
									noamount = parseFloat(noamount/beforecurrency_id)*selectcurrency_id;
								noamount = noamount.toFixed(2);
								document.getElementById('noamount'+i).value = noamount;
								document.getElementById('noamount'+i).onchange();
							}
						}
						//调整
						if(document.getElementById('setnoamount') != undefined && document.getElementById('setnoamount').value > 0)
						{
							var setnoamount = document.getElementById('setnoamount').value;
							setnoamount = parseFloat(setnoamount);
							if(beforecurrency_id == 1)
								setnoamount = setnoamount*selectcurrency_id;
							else
								setnoamount = parseFloat(setnoamount/beforecurrency_id)*selectcurrency_id;
							setnoamount = setnoamount.toFixed(2);
							document.getElementById('setnoamount').value = setnoamount;
							document.getElementById('setnoamount').onchange();
						}
					}
					//费用报销
					if(module == 'Expense') 
					{
						var tableName = document.getElementById('proTab');
						var prev = tableName.rows.length - 1;//列头函数
						//本次收款
						for(var i = 1; i<=prev; i++)
						{
							if(document.getElementById('money'+i) != undefined && document.getElementById('money'+i).value > 0)
							{
								var money = document.getElementById('money'+i).value;
								money = parseFloat(money);
								if(beforecurrency_id == 1)
									money = money*selectcurrency_id;
								else
									money = parseFloat(money/beforecurrency_id)*selectcurrency_id;
								money = money.toFixed(2);
								document.getElementById('money'+i).value = money;
								document.getElementById('money'+i).onchange();
								
							}
						}
					}
							 //付款单
					if(module == 'SendCashBill')
					{
						var tableName = document.getElementById('SendPaymentList');
						var prev = tableName.rows.length - 1;//列头函数
						//本次收款
						for(var i = 1; i<=prev; i++)
						{
							if(document.getElementById('curSendCashBill'+i) != undefined && document.getElementById('curSendCashBill'+i).value > 0)
							{
								var curSendCashBill = document.getElementById('curSendCashBill'+i).value;
								curSendCashBill = parseFloat(curSendCashBill);
								if(beforecurrency_id == 1)
									curSendCashBill = curSendCashBill*selectcurrency_id;
								else
									curSendCashBill = parseFloat(curSendCashBill/beforecurrency_id)*selectcurrency_id;
								curSendCashBill = curSendCashBill.toFixed(2);
								document.getElementById('curSendCashBill'+i).value = curSendCashBill;
								document.getElementById('curSendCashBill'+i).onchange();
							}
						}
						//调整
						if(document.getElementById('nosendpayment') != undefined && document.getElementById('nosendpayment').value > 0)
						{
							var nosendpayment = document.getElementById('nosendpayment').value;
							nosendpayment = parseFloat(nosendpayment);
							if(beforecurrency_id == 1)
								nosendpayment = nosendpayment*selectcurrency_id;
							else
								nosendpayment = parseFloat(nosendpayment/beforecurrency_id)*selectcurrency_id;
							nosendpayment = nosendpayment.toFixed(2);
							document.getElementById('nosendpayment').value = nosendpayment;
							document.getElementById('nosendpayment').onchange();
						}
					}
                    for(var k= 0; k <fieldnameArr.length; k++)
                    {
                        var fieldname = fieldnameArr[k];
                        if(formobj[fieldname] != undefined && formobj[fieldname].value > 0)
                        {
                            var amount = formobj[fieldname].value;
							amount=parseFloat(amount);
							
                            //选择前币种为人民币  默认1
                            if(beforecurrency_id == 1)
                                //人民币 - 非人民币 / 公式：金额*非人民币汇率
								amount = amount*selectcurrency_id;
                            else
                                //非人民币 - 非人民币 or  非人民币  - 人民币 / 公式:(金额/选择前汇率)*选择后汇率
                                amount = parseFloat(amount/beforecurrency_id)*selectcurrency_id;
                            amount = amount.toFixed(2);
                            formobj[fieldname].value = amount;
                        }
                    }
                }
                return false;
			}
		}
		
	);
}


var http_reqfield;

function createfieldXMLHTTP()
     {
        var request;
        var browser=navigator.appName;
     
        if(browser=="Microsoft Internet Explorer")
        {
            var arrVersions=["MSXML2.XMLHttp.5.0","MSXML2.XMLHTTP.4.0","MSXML2.XMLHTTP.3.0","MSXML2.XMLHTTP","Microsoft.XMLHTTP"];
            for( var i=0;i<arrVersions.length;i++)
            {
                try
                {
                     request=new ActiveXObject(arrVersions[i]);
                    return request;
                }
                catch(exception)
                {
                }
            }
        }
        else 
        {
          request=new XMLHttpRequest();
          return request;
        }
     }
function RequestFieldDuplicate()
{
    if(http_reqfield.readyState==4)
    {
        if(http_reqfield.status==0||http_reqfield.status==200)
        {
                var str=http_reqfield.responseText;
                if(str.indexOf('##systemcode##$$')>=0)
                {
                    var results=str.split('##systemcode##$$');
                    var objid=results[1];
                    var systemcode=results[2];
                    puyoungJS_DialogBox.unblock();
                    document.getElementById(objid).value=systemcode;
                    RemindsMsg("","LdPopWidth400px","","yes","",results[3]);
                    isDuplicate=true;
                    return ;
                }else if(str.indexOf('##error##') > -1)
                {
                    var results=str.split('##error##');
                    puyoungJS_DialogBox.unblock();
                    RemindsMsg("","LdPopWidth400px","","yes","",results[1]);
                    isDuplicate=true;
                }else if(str.indexOf('divNoRecord') > -1){
					//您没有权限执行这个操作（可能是查重）
					var confirm_str = arrJsPopLabel['NOPERMITTEDEXECUTE'];
					RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
					puyoungJS_DialogBox.unblock();
					isDuplicate=true;
				}
        }
    }
}
