/**
 * timetype
 * @param
 * @returns
 * @author Chj 
 */
function onChangeTimeType(row){
    var popupobj=CrmPopup.getPopupObj('last');
    var rowobj=popupobj.getDetailTableObj().find("[rowindex="+row+"]");
    
    //var rowobj=ld
   if(ld(rowobj).find('[detailcolumnname=timetype]').length>0){
		var timetype =ld(rowobj).find('[detailcolumnname=timetype]').val();
		if(timetype == 'Direct'){
			if(ld(rowobj).find('[detailcolumnname=entitytypeid_name]').length>0){
				ld(rowobj).find('[detailcolumnname=entitytypeid_name]').attr("disabled",false);
				ld(rowobj).find('[detailcolumnname=entitytypeid_name]').css("cursor","");
			     
				ld(rowobj).find('[detailcolumnname=clear_entitytypeid_]').show();
			}
			if(ld(rowobj).find('[detailcolumnname=indirectcharge]').length>0){
				ld(rowobj).find('[detailcolumnname=indirectcharge]').val(""); 
				//ld("#indirectcharge"+id_rowIndex).find("option[text='']").attr("selected",true); 
				ld(rowobj).find('[detailcolumnname=indirectcharge]').attr("disabled",true);
			}
			if(ld(rowobj).find('[detailcolumnname=select_entitytypeid]').length>0){
				ld(rowobj).find('[detailcolumnname=select_entitytypeid]').attr("disabled",false);
			}
		}else if(timetype == 'Indirect'){
		      if(ld(rowobj).find('[detailcolumnname=entitytypeid_name]').length>0){
				ld(rowobj).find('[detailcolumnname=entitytypeid_name]').val("");
				ld(rowobj).find('[detailcolumnname=entitytypeid_name]').val("");
				ld(rowobj).find('[detailcolumnname=entitytypeid_name]').attr("disabled",true);
				ld(rowobj).find('[detailcolumnname=entitytypeid_name]').hide();
			}
			if(ld(rowobj).find('[detailcolumnname=indirectcharge]').length>0){
				ld(rowobj).find('[detailcolumnname=indirectcharge]').attr("disabled",false);
			}
			if(ld(rowobj).find('[detailcolumnname=select_entitytypeid]').length>0){
				ld(rowobj).find('[detailcolumnname=select_entitytypeid]').attr("disabled",true);
				ld(rowobj).find('[detailcolumnname=select_entitytypeid]').find("option[value='']").attr("selected",true);
			}
		}else{
			if(ld(rowobj).find('[detailcolumnname=entitytypeid_name]').length>0){
				ld(rowobj).find('[detailcolumnname=entitytypeid_name]').attr("disabled",false);
				ld(rowobj).find('[detailcolumnname=entitytypeid_name]').css("cursor","");
			     
				ld(rowobj).find('[detailcolumnname=clear_entitytypeid_]').show();
			}
			if(ld(rowobj).find('[detailcolumnname=indirectcharge]').length>0){
			 
				ld(rowobj).find('[detailcolumnname=indirectcharge]').attr("disabled",true);
			}
			if(ld(rowobj).find('[detailcolumnname=select_entitytypeid]').length>0){
				ld(rowobj).find('[detailcolumnname=select_entitytypeid]').attr("disabled",false);
			}
		}
	}
}

/**
 * 锟叫断碉拷前锟斤拷锟斤拷锟斤拷锟街革拷锟斤拷锟斤拷锟斤拷诘墓锟绞憋拷欠癯锟?小时
 * @param 
 * @returns
 * @author Chj 
 */
function getTimeSheetHour(now_rowid){
    var popupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
	//var rowcnt = ld('#rowcnt').val();
    var tableobj=popupobj.getDetailTableObj();
    var rowobj=ld(tableobj).find("[rowindex="+now_rowid+"]");
    var trobjs=popupobj.getTrObjsByDelType('no');
    
	var rowcnt = ld(trobjs).length;
	//var nullfield = ld('#nullfield').val();
	var nullfield = ld('#'+popupobj.divid+' [name="nullfield"]').first().val();
	var nullfield_arr = nullfield.split('##');
	if(rowcnt >= 1){
		//var smownerid = document.EditView.assigned_user_id.value;
		var smownerid = ld('#'+popupobj.divid+' [name="assigned_user_id"]').get(0).value;
		//var record = document.EditView.record.value;
		var record = ld('#'+popupobj.divid+' [name="record"]').get(0).value;
		var time_date = [];
		var t = 0;
		ld.each(trobjs,function(){
			var nullfield_num = 0;
			for(var j = 0; j < nullfield_arr.length; j++){
				//if(ld('#'+nullfield_arr[j]+rowid).val() == ''){
				if(ld(this).find(' [detailcolumnname="'+nullfield_arr[j]+'"]').first().val() == ''){
					nullfield_num++;
				}
			}
			//锟斤拷锟斤拷锟角帮拷锟轿拷锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷锟?
			if(nullfield_num == nullfield_arr.length){
				return true;
			}
			//var workdate = ld('#workdate'+rowid).val();
			var workdate = ld(this).find(' [detailcolumnname="workdate"]').first().val();
            
			if(!empty(workdate)){
				//var costtime =  ld('#costtime'+rowid).val();
				var costtime =  ld(this).find(' [detailcolumnname="costtime"]').first().val();
				time_date[t] = workdate+'/'+costtime+'/'+rowid;
				t++;
			}
		})
      
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
				//锟斤拷锟斤拷锟角帮拷锟轿拷锟斤拷一锟叫ｏ拷锟斤拷锟斤拷锟矫诧拷品锟斤拷录锟斤拷锟斤拷锟揭伙拷锟窖★拷锟斤拷品锟斤拷锟角凤拷锟皆讹拷锟斤拷锟斤拷一锟斤拷锟斤拷锟斤拷
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
function getTimeSheetHour(now_rowid){
      
     var popupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
     var trobjs=popupobj.getTrObjsByDelType("no");
	var rowcnt = ld(trobjs).length;
      
	var nullfield = ld("#"+popupobj.divid+" [name=nullfield]").val();// ld('#nullfield').val();
	var nullfield_arr = nullfield.split('##');
	if(rowcnt >= 1){
		var smownerid = ld("#"+popupobj.divid+" [name=assigned_user_id]").val() ;//document.EditView.assigned_user_id.value;
		var record = popupobj.record;
		var time_date = [];
		var t = 0;
        var rowid=0;
		ld.each(trobjs,function(){
			var nullfield_num = 0;
			for(var j = 0; j < nullfield_arr.length; j++){
				if(!empty(nullfield) && ld(this).find("[detailcolumnname="+nullfield_arr[j]+"]").val() == ''){
					nullfield_num++;
				}
			}
            rowid=ld(this).attr("rowindex");
			//如果当前行为空行则跳出计算
			if(nullfield_num == nullfield_arr.length){
				return true;
			}
			var workdate = ld("#"+popupobj.divid+" [name=workdate]").val();// ld('#workdate'+rowid).val();
			if(!empty(workdate)){
				var costtime =  ld("#"+popupobj.divid+" [name=costtime]").val();//ld('#costtime'+rowid).val();
				time_date[t] = workdate+'/'+costtime+'/'+rowid;
				t++;
			}
		});
       
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
   
    return true;
}

function setTimeSheet(){
	var sum_direct = 0;
	var sum_indirect = 0;
   var popupobj=CrmPopup.getlastPopupObjByPageType(PageRecordPopup.pagetype);
	var rowcnt = ld("#"+popupobj.divid+" [name=rowcnt]").val();
    var trobjs=popupobj.getTrObjsByDelType("no");
    var total=0;
    
	ld.each(trobjs,function(){
		//if(ld("#"+popupobj.divid+" [name=hidden_rowid_"+rowid+"]").val()==0){
			if(ld(this).find("[detailcolumnname=timetype]").length>0 && ld(this).find("[detailcolumnname=costtime]").length>0){
				var costtime = ld(this).find("[detailcolumnname=costtime]").val();
                
				if(costtime=='')
					costtime=0;
				if(ld(this).find("[detailcolumnname=timetype]").val() == 'Direct'){
					sum_direct += eval(costtime);
                   // total+=sum_direct;
				}else if(ld(this).find("[detailcolumnname=timetype]").val() == 'Indirect') {
					sum_indirect += eval(costtime);
                 //   total+=sum_indirect;
				}
			}
		//}
	});
    //（https://61mis.com/kfbtest [^]）项目工时新建界面，工时分录明细中“合计”计算错误，合计应该等于直接工时合计加间接工时合计
    total=sum_indirect+sum_direct;
    
	if(ld("#"+popupobj.divid+" [name=sum_direct]").length>0){
		ld("#"+popupobj.divid+" [name=sum_direct]").val(sum_direct);
		ld("#"+popupobj.divid+" [name=sum_sum_direct]").html(sum_direct);
	}
	if(ld("#"+popupobj.divid+" [name=sum_indirect]").length>0){
		ld("#"+popupobj.divid+" [name=sum_indirect]").val(sum_indirect);
		ld("#"+popupobj.divid+" [name=sum_sum_indirect]").html(sum_indirect);
	}
    
	if(ld("#"+popupobj.divid+" [name=sum_total]").length>0){
		ld("#"+popupobj.divid+" [name=sum_total]").html(total);
		ld("#"+popupobj.divid+" [name=total]").val(total);
	}
	
}