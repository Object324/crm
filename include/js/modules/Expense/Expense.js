calendarParentid="ExpenseTab";

/*
edit:can
date:20130923
reason:新增费用明细
*/
function fnAddExpenseRow(module)
{
    var parentwindow=window;
	if(window.opener!=undefined&&parentwindow.document.getElementById('proTab')==undefined){
	  
		parentwindow=window.opener;
	}
	//获取当前明细总行数
	var rowcnt = parentwindow.document.getElementById('rowcnt').value;
	parentwindow.document.getElementById('rowcnt').value = eval(rowcnt) + 1;
	var count = eval(rowcnt) + 1;
	var url = 'index.php?module=Users&action=UsersAjax&file=addTabDetailsHtmlRow&frommodule='+module+'&rowid='+count;
	//alert(url);
	http_reqfield=createfieldXMLHTTP();
    http_reqfield.open("POST",url,false);
    addRow_finished=false;
    http_reqfield.onreadystatechange=AddProductRow;
    http_reqfield.setRequestHeader("If-Modified-Since","0");
    http_reqfield.send();
    if(addRow_finished == true)
    {
        parentwindow.fieldformulaobj.setEvent(eval(rowcnt) + 1);//给新增的行单元格添加事件
		return eval(rowcnt) + 1;
    }
    return '';
}

/*
edit:can
date:20130923
reason:互换费用明细行的位置
rowidnum:表示当前行id数字
*/
function moveExpenseUpDown(status,rowidnum)
{
    
    var curcel;
 
    var currow=document.getElementById('row'+rowidnum);
  
    var strHTML="";
    var startdate;
    var enddate;
    var startdatehtml;
    var enddatehtml;
   
    if(status=='DOWN')
    {
       
        rowidnum=rowidnum+1;
         status="UP";
         currow=document.getElementById('row'+rowidnum)
    }
    if(status=="UP")
    {
        
          var prevrownum=rowidnum-1;
          var prevrowobj=document.getElementById('row'+prevrownum);
          
          var prevobj=prevrowobj.parentNode.insertBefore(currow,prevrowobj);
        
          strHTML= document.getElementById("row"+rowidnum).cells[0].innerHTML;
          prevobj.cells[0].innerHTML= document.getElementById("row"+(rowidnum-1)).cells[0].innerHTML;
          document.getElementById("row"+(rowidnum-1)).cells[0].innerHTML=strHTML;
          prevobj.id=10000;
          document.getElementById('row'+prevrownum).id="row"+rowidnum;
          prevobj.id="row"+(rowidnum-1);
          
           document.getElementById("expenseuse"+rowidnum).name='expenseuse'+(rowidnum-1);
           document.getElementById("expenseuse"+(rowidnum-1)).name='expenseuse'+rowidnum;
           var obj= document.getElementById("expenseuse"+rowidnum);
           obj.id="expensemn";
           var objnext= document.getElementById("expenseuse"+(rowidnum-1));
           objnext.id="expenseuse"+rowidnum;
           obj.id="expenseuse"+(rowidnum-1);
          
           document.getElementById("expensetype"+rowidnum).name='expensetype'+(rowidnum-1);
           document.getElementById("expensetype"+(rowidnum-1)).name='expensetype'+rowidnum;
           obj=document.getElementById("expensetype"+(rowidnum-1));
           obj.id="expensee10";
           objnext=document.getElementById("expensetype"+rowidnum);
           objnext.id='expensetype'+(rowidnum-1);
           obj.id="expensetype"+ rowidnum;
           
           startdate=document.getElementById("start"+(rowidnum-1)).value;
           startdatehtml='<input size="15" onClick="WdatePicker()" class="Wdate"  readonly="true" type="text" name="start'+rowidnum+ '" id="start'+rowidnum+'" value="'+startdate+'">';
           //startdatehtml+="<img  class='popimg' src='themes/softed/images/btnL3Calendar.gif'  onclick='showCalendar(\"start"+rowidnum+"\",\"%Y-%m-%d\",\"true\",\"12\",this)'/>";
           enddate=document.getElementById("end"+(rowidnum-1)).value;    
           enddatehtml='<input size="15" onClick="WdatePicker()" class="Wdate" readonly="true" type="text" name="end'+rowidnum+'" id="end'+rowidnum+'" value="'+enddate+'"/>';
           //enddatehtml+="<img  class='popimg' src='themes/softed/images/btnL3Calendar.gif'    onclick='showCalendar(\"end"+rowidnum+"\",\"%Y-%m-%d\",\"true\",\"12\",this)'/>";
         
           startdate=document.getElementById("start"+rowidnum).value;
           document.getElementById("row"+(rowidnum-1)).cells[3].innerHTML='<input readonly="true" size="15" onClick="WdatePicker()" class="Wdate" type="text" name="start'+(rowidnum-1)+
                                '" id="start'+(rowidnum-1)+'" value="'+startdate+'">';
           //document.getElementById("row"+(rowidnum-1)).cells[3].innerHTML+="<img  class='popimg' src='themes/softed/images/btnL3Calendar.gif'  onclick='showCalendar(\"start"+(rowidnum-1)+"\",\"%Y-%m-%d\",\"true\",\"12\",this)'/>";
           enddate=document.getElementById("end"+rowidnum).value;    
           
           document.getElementById("row"+(rowidnum-1)).cells[4].innerHTML='<input  readonly="true" size="15" onClick="WdatePicker()" class="Wdate" type="text" name="end'+(rowidnum-1)+'" id="end'+(rowidnum-1)+'" value="'+enddate+'"/>';                    
           //document.getElementById("row"+(rowidnum-1)).cells[4].innerHTML+="<img  class='popimg'  src='themes/softed/images/btnL3Calendar.gif'  onclick='showCalendar(\"end"+(rowidnum-1)+"\",\"%Y-%m-%d\",\"true\",\"12\",this)'/>";                     
          
           document.getElementById("row"+rowidnum).cells[3].innerHTML=startdatehtml;
           
           document.getElementById("row"+rowidnum).cells[4].innerHTML=enddatehtml;
           
           document.getElementById("money"+rowidnum).name='money'+(rowidnum-1);
           document.getElementById("money"+(rowidnum-1)).name='money'+rowidnum;
           obj=document.getElementById("money"+rowidnum);
           obj.id='expense10000';
           objnext=document.getElementById("money"+(rowidnum-1));
           objnext.id='money'+rowidnum;
           obj.id="money"+ (rowidnum-1);
           
           document.getElementById("description"+rowidnum).name='description'+(rowidnum-1);
           document.getElementById("description"+(rowidnum-1)).name='description'+rowidnum;
           obj= document.getElementById("description"+rowidnum);
           obj.id='expense10000';
           objnext=document.getElementById("description"+(rowidnum-1));
           objnext.id='description'+rowidnum;
           obj.id="description"+ (rowidnum-1);
    }
    var expensetable=document.getElementById('proTab');
     for(var i=1;i<expensetable.rows.length;i++)
     {
         if(document.getElementById("row"+i)==undefined)
         {
             break;
         }
          document.getElementById("row"+i).style.verticalAlign="top";
         for(var j=0;j<document.getElementById("row"+i).cells.length;j++)
         {
            if(i==1)
             {
                document.getElementById("row"+i).cells[j].className="crmTableRow small lineOnTop";
             }
             else
             {
                document.getElementById("row"+i).cells[j].className="crmTableRow small";
             }
         }
     }
}
/*
edit:can
date:20130926
reason:删除行
*/
function deleteExpenseRow(rowid)
{
    var expensetable=document.getElementById('proTab');
    var cel;
    var delMoney=document.getElementById('money'+rowid).value;
   
    var total=document.getElementById("grandTotal").innerHTML;
    total=parseFloat(total)-parseFloat(delMoney);
    total=parseFloat(total).toFixed(2);
    if( document.getElementById("expensedetailid"+rowid)!=undefined)
    {
        var expensedetailid=document.getElementById("expensedetailid"+rowid).value;
         if(trim(document.getElementById("delExpensedetail").value)=="")
          {
                document.getElementById("delExpensedetail").value=expensedetailid;
          }
          else
          {
                document.getElementById("delExpensedetail").value+=" , "+expensedetailid;
          }
    }
     
    expensetable.deleteRow(rowid+1);
    var j=1;
    rowid=rowid+1;
    for(var i=rowid;i<expensetable.rows.length;i++)
    {
        if( document.getElementById("expensedetailid"+i)!=undefined)
        {
            document.getElementById("expensedetailid"+i).name='expensedetailid'+(i-1);
            document.getElementById("expensedetailid"+i).id='expensedetailid'+(i-1);
           
        }
        document.getElementById("expenseuse"+i).name='expenseuse'+(i-1);
        document.getElementById("expenseuse"+i).id='expenseuse'+(i-1);  
        document.getElementById("expensetype"+i).name='expensetype'+(i-1);
        document.getElementById("expensetype"+i).id='expensetype'+(i-1);
        document.getElementById("start"+i).name='start'+(i-1);
        document.getElementById("start"+i).id='start'+(i-1);
        document.getElementById("end"+i).name='end'+(i-1);
        document.getElementById("end"+i).id='end'+(i-1);
        document.getElementById("description"+i).name='description'+(i-1);
        document.getElementById("description"+i).id='description'+(i-1);
        document.getElementById("money"+i).name='money'+(i-1);
        document.getElementById("money"+i).id='money'+(i-1);
        document.getElementById("row"+i).id='row'+(i-1);
        cel= document.getElementById("row"+(i-1)).cells[0];
           if(document.getElementById("expensedetailid"+(i-1))!=undefined)
           {
                var expensedetailid=document.getElementById("expensedetailid"+(i-1)).value;
               /* if(trim(document.getElementById("delExpensedetail").value)=="")
                {
                    document.getElementById("delExpensedetail").value=expensedetailid;
                }
                else
                {
                    document.getElementById("delExpensedetail").value+=" , "+expensedetailid;
					alert(expensedetailid);
                }*/
               // alert( document.getElementById("delExpensedetail").value);
                cel.innerHTML="<input type=hidden value='"+expensedetailid+"' id='expensedetail"+(i-1)+"' name='expensedetailid"+(i-1)+"'/>";
           }
           else
           {
                 cel.innerHTML="";
           }
            cel.innerHTML+='<a class="icon-homeimg icon-sdel" href="javascript:;" title="删除" onclick="deleteExpenseRow('+(i-1)+')"></a><a class="icon-homearr icon-sup" title="向上" href="javascript:moveUpDown(\'UP\','+(i-1)+')"></a>';
            cel.className='crmTableRow small';
          
        
    }
   if(expensetable.rows.length==3)
   {
        var row1=document.getElementById('row1');
        cel= document.getElementById("row1").cells[0];
        if(document.getElementById("expensedetailid1")!=undefined)
           {
                var expensedetailid=document.getElementById("expensedetailid1").value;
              
               
                cel.innerHTML="<input type=hidden value='"+expensedetailid+"' id='expensedetailid1' name='expensedetailid1'/>";
                
           }
           else
            row1.cells[0].innerHTML='';
   }

    document.getElementById("grandTotal").innerHTML=total;
    document.getElementById('totalMoney').value=total;
}
/*
edit:can
date:20130924
reason:报销金额值改变
*/
function MoneyChanged(obj)
{
    var expensetable=document.getElementById('proTab');
    if(trim(obj.value)=="")
    {
        obj.value=0;
        
    }
    if(isNaN(obj.value))
    {
        //报销金额内容非法！
        alert(arrJsPopLabel['REIMBURSEMENTILLEGALCONTENT']);
        obj.focus();
        return false;
    }
    var temp=/^\d+(\.\d+)?$/;
    if(temp.test(money))
    {
        //报销金额应该输入非负数！
        alert(arrJsPopLabel['REIMBURSEDSHOULDNONNEGATIVE']);
        obj.focus();
        return false;
    }
   var i=1;
   var money=0;
   var expenserow;
   var total=0;
    while(i<expensetable.rows.length)
     {
        expenserow=document.getElementById('row'+i);
        if(expenserow!=undefined)
        {
             money=document.getElementById("money"+i).value;
             
             total=parseFloat(total)+parseFloat(money);
        }
        else
        {
            break;
        }
        i++;
     }
     
     document.getElementById("grandTotal").innerHTML=parseFloat(total).toFixed(2);
     document.getElementById("totalMoney").value=parseFloat(total).toFixed(2);
}

function fnAddExpenseRow(module)
{
    var parentwindow=window;
	if(window.opener!=undefined&&parentwindow.document.getElementById('proTab')==undefined){
	  
		parentwindow=window.opener;
	}
	//获取当前明细总行数
	var rowcnt = parentwindow.document.getElementById('rowcnt').value;
	parentwindow.document.getElementById('rowcnt').value = eval(rowcnt) + 1;
	var count = eval(rowcnt) + 1;
	var tag = ld('#expensetype1').find("option:selected").attr("tag");
	var url = 'index.php?module=Users&action=UsersAjax&file=addTabDetailsHtmlRow&frommodule='+module+'&rowid='+count+'&utrc_expensetype='+tag;
	//alert(url);
	http_reqfield=createfieldXMLHTTP();
    http_reqfield.open("POST",url,false);
    addRow_finished=false;
    http_reqfield.onreadystatechange=AddProductRow;
    http_reqfield.setRequestHeader("If-Modified-Since","0");
    http_reqfield.send();
    if(addRow_finished == true)
    {
        parentwindow.fieldformulaobj.setEvent(eval(rowcnt) + 1);//给新增的行单元格添加事件
		return eval(rowcnt) + 1;
    }
    return '';
}

//联合技术MER特殊控制：获取费用类别
function getDetailExpenseType(columnname,rowid){
	if(rowid != 1)return;
	var tag = ld('#'+columnname+rowid).find("option:selected").attr("tag");
	changeDetailColumn(tag);
}
function changeDetailColumn(tag){
	
	var url = 'module=Expense&action=ExpenseAjax&file=changeDetailColumn&expensetype='+tag;
	var sWidth = 0;//隐藏的宽度和
	var alltypeofdata = ld('#alltypeofdata').val();
	var typeofdata = alltypeofdata.split('::');
	var typeofdata_array = [];
	//获取每个自定义字段对应的宽度
	ld.each(typeofdata,function(j,typeofdatastring){
		var typeofdataarr = typeofdatastring.split(':');
		var column = typeofdataarr[0];
		var column_width = typeofdataarr[5];
		typeofdata_array[column] = column_width;
	});
	var rowcnt = ld('#rowcnt').val();
	//获取上一次隐藏列
	if(ld('#select_columns') != undefined){
		var select_columns = ld('#select_columns').val();
		if(!empty(select_columns)){
			var select_column_arr = select_columns.split(',');
			ld.each(select_column_arr,function(k,column){
				if(ld('#detail_'+column) != undefined){
					ld('#detail_'+column).show();
					ld('#subtotal_'+column).show();
					for(var i = 1; i<=rowcnt; i++){
						ld('#detail_'+column+i).show();
					}
					sWidth = parseInt(sWidth) + parseInt(typeofdata_array[column]);
				}
			});
			//获取当前明细的总宽度
			var table_width = ld('#table_width').val();
			var new_width = parseInt(table_width) + parseInt(sWidth);
			ld('#table_width').val(new_width);
			ld('#proTab').css("width",new_width +'mm');
			sWidth = 0;
		}
	}
	if(tag == 'MileageReimbursement'){
		ld('#detail_subtotal_row').hide();
	}else{
		ld('#detail_subtotal_row').show();
	}
	//根据Business Reason的utrc_type获取需要的隐藏字段
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody: url,
			onComplete: function(response){
				if(empty(response)) return false;
				var rest=response.responseText;
				var report = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
				var select_columns = report.hidden_column.split(',');
				var select_column = report.select_column;
				 //记录上一次的隐藏列
				 ld('#select_columns').val(select_columns);
				 ld.each(select_columns,function(i,column){
					 if(ld('#detail_'+column) != undefined){
						ld('#detail_'+column).hide();
						ld('#subtotal_'+column).hide();
						for(var i = 1; i<=rowcnt; i++){
							ld('#'+column+i).val('');
							ld('#detail_'+column+i).hide();
							//setExpenseAmount(i);
						}
						sWidth = parseInt(sWidth) + parseInt(typeofdata_array[column]);
					 }
				 });
				 //默认根据第一行的Business Reason的tag
				if(!empty(select_column)){
					if(rowcnt >= 2){
						for(var i = 2; i<=rowcnt; i++){
							var expensetype = document.getElementById('expensetype'+i);
							var is_val = expensetype.value;
							var expensetype_len = expensetype.options.length;
							var opts = 0;
							//清空
							/*alert(expensetype_len);
							for(var k = 0; k < expensetype_len; k++){
								expensetype.options.remove(k);
							}*/
							document.getElementById('expensetype'+i).options.length=0; 
							//添加
							
							for(option_value in select_column){
								var is_selected = '';
								if(select_column[option_value] == tag){
									if(is_val == option_value){
										is_selected = 'selected';
									}
									//alert(is_selected);
									ld('#expensetype'+i).append("<option value='"+option_value+"' tag="+select_column[option_value]+" "+is_selected+">"+option_value+"</option>");
								}
							}
						}
					}
					
				}
				 //获取当前明细的总宽度
				 var table_width = ld('#table_width').val();
				 var new_width = parseInt(table_width) - sWidth;
				 ld('#table_width').val(new_width);
				 ld('#proTab').css("width",new_width +'mm');
				 //再次重新计算
				 setProductDivWidth();
				 fieldformulaobj.CountsubTotal();
				
			}
		}
	);
	
	/*if(rowcnt >= 2){
		for(var i = 2; i<=rowcnt; i++){
			var expensetype = document.getElementById('expensetype'+rowcnt);
			var expensetype_len = expensetype.options.length;
			var opts = 0;
			for(var k = 0; k < expensetype_len; k++){
				if(expensetype.options[opts].getAttribute('tag') != tag){
					expensetype.options.remove(opts);
				}else{
					opts++;
				}
			}
		}
	}*/
}
function setExpenseAmount(rowid){
    //editor:gyq_161 reason:设置费用报销金额   2019/12/2 17:41
    var popupobj = CrmPopup.getPopupObj("last");
    var tableobj=popupobj.getDetailTableObj();
    
    var rowobj=ld(tableobj).find("tr[rowindex="+rowid+"]");
    var trobjs=popupobj.getTrObjsByDelType('no');
    
	//if(ld('#expensetype'+rowid) != undefined && ld('#expensetype'+rowid).val() != ''){
	if(ld(rowobj).find(' [name="expensetype"]').size() > 0 && ld(rowobj).find(' [name="expensetype"]').val() != ''){
		//var tag = ld('#expensetype'+rowid).find("option:selected").attr("tag");
		//var tag = ld('#' + popupobj.divid + ' [name="expensetype' + rowid + '"]').first().find("option:selected").attr("tag");
		var mileage = 0;
		var reimburserate = 0;
		var rmb_amount = 0;
		var total = 0;
		//var rowcnt = ld('#rowcnt').val();
		//var rowcnt = ld('#' + popupobj.divid + ' [name="rowcnt"]').first().val();
		//if(ld('#mileage'+rowid) != undefined){
		if(ld(rowobj).find(' [name="mileage"]').size() > 0){
			//mileage = ld('#mileage'+rowid).val();
			mileage = ld(rowobj).find(' [name="mileage"]').val();
			if(empty(mileage))mileage = 0;
		}
		//if(ld('#reimburserate'+rowid) != undefined){
		if(ld(rowobj).find(' [name="reimburserate"]').size() > 0){
			//reimburserate = ld('#reimburserate'+rowid).val();
			reimburserate = ld(rowobj).find(' [name="reimburserate"]').first().val();
			if(empty(reimburserate))reimburserate=0;
		}
		rmb_amount = eval(mileage) * eval(reimburserate);
		//ld('#span_rmb_total'+rowid).html(rmb_amount.toFixed(2));
		 ld(rowobj).find(' [name="span_rmb_total"]').first().html(rmb_amount.toFixed(2));
		//ld('#rmb_total'+rowid).val(rmb_amount.toFixed(2));
		 ld(rowobj).find(' [name="rmb_total"]').first().val(rmb_amount.toFixed(2));
	//	for(var i = 1; i <= rowcnt; i++){
			//var row_total = ld('#rmb_total'+i).val();
            ld.each(trobjs,function(){
                var row_total = ld(this).find(' [name="rmb_total"]').first().val();
		      	total += eval(row_total);
            })
			
	//	}
		//ld('#total').val(total.toFixed(2));
		ld('#' + popupobj.divid + ' [name="total"]').first().val(total.toFixed(2));
		//ld('#sum_rmb_total').html(total.toFixed(2));
        ld('#' + popupobj.divid + ' [name="sum_rmb_total"]').first().html(total.toFixed(2));
	}

}
