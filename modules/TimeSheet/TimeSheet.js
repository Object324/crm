/**
 * timetype
 * @param
 * @returns
 * @author Chj 
 */
function onChangeTimeType(row){
   if(ld('#timetype'+row) != undefined){
		var timetype = ld('#timetype'+row).val();
		if(timetype == 'Direct'){
			if(ld('#entitytypeid'+row+'_name') != undefined){
				ld('#entitytypeid'+row+'_name').attr("disabled",false);
				ld('#entitytypeid'+row+'_name').css("cursor","");
				//ld('#entitytypeid'+id_rowIndex+'_name').val(arrJsPopLabel['INPUTAKEYWORDSQUERY']);
				ld('#clear_entitytypeid_'+row).show();
			}
			if(ld('#indirectcharge'+row) != undefined){
				ld("#indirectcharge"+row).val(""); 
				//ld("#indirectcharge"+id_rowIndex).find("option[text='']").attr("selected",true); 
				ld("#indirectcharge"+row).attr("disabled",true);
			}
			if(ld('#select_entitytypeid'+row) != undefined){
				ld("#select_entitytypeid"+row).attr("disabled",false);
			}
		}else if(timetype == 'Indirect'){
			if(ld('#entitytypeid'+row+'_name') != undefined){
				ld('#entitytypeid'+row+'_name').val("");
				ld('#entitytypeid'+row).val("");
				ld('#entitytypeid'+row+'_name').attr("disabled",true);
				ld('#clear_entitytypeid_'+row).hide();
			}
			if(ld('#indirectcharge'+row) != undefined){
				ld("#indirectcharge"+row).attr("disabled",false);
			}
			if(ld('#select_entitytypeid'+row) != undefined){
				ld("#select_entitytypeid"+row).attr("disabled",true);
				ld("#select_entitytypeid"+row).find("option[value='']").attr("selected",true);
			}
		}else{
			if(ld('#entitytypeid'+row+'_name') != undefined){
				ld('#entitytypeid'+row+'_name').attr("disabled",false);
				ld('#entitytypeid'+row+'_name').css("cursor","");
				ld('#clear_entitytypeid_'+row).show();
			}
			if(ld('#indirectcharge'+row) != undefined){
				ld("#indirectcharge"+row).attr("disabled",false);
			}
			if(ld('#select_entitytypeid'+row) != undefined){
				ld("#select_entitytypeid"+row).attr("disabled",false);
			}
		}
	}
}

/**
 * 判断当前负责的在指定日期内的工时是否超过8小时
 * @param 
 * @returns
 * @author Chj 
 */
function getTimeSheetHour(now_rowid){
      
     var popupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
    
	var rowcnt = ld("#"+popupobj.divid+" [name=rowcnt]").val();
      alert(rowcnt);
	var nullfield = ld("#"+popupobj.divid+" [name=nullfield]").val();// ld('#nullfield').val();
	var nullfield_arr = nullfield.split('##');
	if(rowcnt >= 1){
		var smownerid = ld("#"+popupobj.divid+" [name=assigned_user_id]").val() ;//document.EditView.assigned_user_id.value;
		var record = popupobj.record;
		var time_date = [];
		var t = 0;
		for(var rowid = 1; rowid <= rowcnt; rowid++){
			var nullfield_num = 0;
			for(var j = 0; j < nullfield_arr.length; j++){
				if(ld('#'+nullfield_arr[j]+rowid).val() == ''){
					nullfield_num++;
				}
			}
			//如果当前行为空行则跳出计算
			if(nullfield_num == nullfield_arr.length){
				continue;
			}
			var workdate = ld("#"+popupobj.divid+" [name=workdate]").val();// ld('#workdate'+rowid).val();
			if(!empty(workdate)){
				var costtime =  ld("#"+popupobj.divid+" [name=costtime]").val();//ld('#costtime'+rowid).val();
				time_date[t] = workdate+'/'+costtime+'/'+rowid;
				t++;
			}
		}
		if(time_date.length >= 1){
			var url = 'index.php?module=TimeSheet&action=TimeSheetAjax&file=getTimeSheetHour&time_date='+time_date.join(',')+'&smownerid='+smownerid+'&record='+record+'&now_rowid='+now_rowid;
			http_reqfield=createfieldXMLHTTP();
			http_reqfield.open("POST",url,false);
			isDuplicate=false;
			http_reqfield.onreadystatechange=getTimeSheetHourDate;
			http_reqfield.setRequestHeader("If-Modified-Since","0");
			http_reqfield.send(null);
			if(isDuplicate)
			{
				return false;
			}else{
				//如果当前行为最后一行，则设置产品分录中最后一行选择产品后是否自动新增一个空行
				var next_row = now_rowid + 1;
				/*if(ld('#row'+next_row).val() == undefined){
					if(ld('#addproductrow').val() != undefined && ld('#addproductrow').val() == 0){
						fnAddTabDetailRow('TimeSheet');
					}
				}*/
				return true;
			}
		}
	}
}


function getTimeSheetHourDate(){
	if(http_reqfield.readyState==4)
	{
		if(http_reqfield.status==0||http_reqfield.status==200)
		{
			var hour = 8;
			var response=http_reqfield.responseText;
			var restobj = eval('('+ response +')')?eval('('+ response +')'):JSON.parse(response);
			if(restobj == 'SUCCESS'){
				isDuplicate=false;
                return ;
			}else{
				if(restobj.length >= 1){
				    var datestr='';
				    for(var i=0;i<restobj.length;i++){
				        if(i==restobj.length-1){
				            datestr += restobj[i];
				        }else if((i+1)%6==0){
				            datestr += restobj[i]+',<br />';
				        }else{
				            datestr += restobj[i]+',';
				        }
				    }
					setTimeSheet();
					var str = arrJsPopLabel['BELOW']+arrJsPopLabel['YOUIN']+arrJsPopLabel['OVERTIME']+hour+arrJsPopLabel['HOUR']+','+arrJsPopLabel['WHETHERTOCONTINUE']+'<br />'+datestr;
					RemindsMsg("","LdPopWidth400px","","yes","yes",str);return true;
					ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
						return false;
					});
				}
			}
		}
	}
}

function setTimeSheet(){
	var sum_direct = 0;
	var sum_indirect = 0;
   var popupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
	var rowcnt = ld("#"+popupobj.divid+" [name=rowcnt]").val();
 
	for(var rowid = 1; rowid <= rowcnt; rowid++){
		if(ld("#"+popupobj.divid+" [name=hidden_rowid_"+rowid+"]").val()==0){
			if(ld("#"+popupobj.divid+" [name=timetype"+rowid+"]").length>0 && ld("#"+popupobj.divid+" [name=costtime"+rowid+"]").length>0){
				var costtime = ld("#"+popupobj.divid+" [name=costtime"+rowid+"]").val();
				if(costtime=='')
					costtime=0;
				if(ld("#"+popupobj.divid+" [name=timetype"+rowid+"]").val() == 'Direct'){
					sum_direct += eval(costtime);
				}else if(ld("#"+popupobj.divid+" [name=timetype"+rowid+"]").val() == 'Indirect') {
					sum_indirect += eval(costtime);
				}
			}
		}
	}

	if(ld("#"+popupobj.divid+" [name=sum_direct]").length>0){
		ld("#"+popupobj.divid+" [name=sum_direct]").val(sum_direct);
		ld("#"+popupobj.divid+" [name=sum_sum_direct]").html(sum_direct);
	}
	if(ld("#"+popupobj.divid+" [name=sum_indirect]").length>0){
		ld("#"+popupobj.divid+" [name=sum_indirect]").val(sum_indirect);
		ld("#"+popupobj.divid+" [name=sum_sum_indirect]").html(sum_indirect);
	}
    
	if(ld("#"+popupobj.divid+" [name=sum_total]").length>0){
		ld("#"+popupobj.divid+" [name=sum_total]").val(sum_indirect);
		ld("#"+popupobj.divid+" [name=total]").html(sum_indirect);
	}
	
}