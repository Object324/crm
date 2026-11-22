calendarParentid="ExpenseTab";


function checkPutDeposit(module,oform)
{
	var recordid=oform.record.value;
    if(module=='PutCash'||module=='CashDeposit')
    {
       if(recordid==undefined || recordid=="")
       {
        recordid="aa";
       }
    
        if(oform.outaccount.value==oform.inaccount.value)
        {
            alert(arrJsPopLabel['taaacnbtttsa']);
            puyoungJS_DialogBox.unblock();
            return false;
        }
   }
	//判断银行账号的钱是否够扣款
    if(module=='PutCash'||module=='CashDeposit'){
        var bankid = oform.outaccount.value;
	    var monery = oform.cashmoney.value;
    }else if(module=='SendCashBill'||module=='Commission'){
        var bankid = oform.bankaccountsetid.value;
        var monery = oform.totalplayment.value;        
    }else if(module=='Expense'){
        var bankid = oform.bankaccountsetid.value;
        var monery = oform.totalMoney.value;    
        
    }
    /*andrew
     *0009838: “提现单”、“存现单”：当金额大于转出账户的余额，保存时，建议给出提示“金额大于转出账户余额，是否保存”，确定后可以保存。
     */
	new Ajax.Request(
		'index.php',
       {queue: {position: 'end', scope: 'command'},
		method: 'post',
		postBody:"module="+module+"&action="+module+"Ajax&file=CheckBankMonery&bankid="+bankid+"&monery="+monery+"&recordid="+recordid+"&modules="+module,
		onComplete: function(response) {
		//alert("module="+module+"&action="+module+"Ajax&file=CheckBankMonery&bankid="+bankid+"&monery="+monery+"&recordid="+recordid+"&modules="+module);
			if(response.responseText.indexOf("SUCCESS")>-1)
			{
				oform.submit();
                return true;
			}
			else
			{
				if(window.confirm(arrJsPopLabel['TATIGTTABWTS']))
				{
					oform.submit();
					return true;
				}else{
                    //alert(arrJsPopLabel['Amountexceedstheaccountbalance']);
                 puyoungJS_DialogBox.unblock();
			     return false;
				}
			}
        }
	});
}
/*
edit:can
date:20130923
reason:新增费用明细
*/
function fnAddExpenseRow(obj)
{
    
    var expensetable=document.getElementById("proTab");
    if(document.getElementById('row2')==undefined)
         document.getElementById("row1").cells[0].innerHTML+=' <a class="icon-homearr icon-sdown"  title="向下" href="javascript:moveExpenseUpDown(\'DOWN\',1)"></a>';
    var rowcount=expensetable.rows.length;
    var newRow=expensetable.insertRow(rowcount);
   
    newRow.id='row'+(rowcount-1);
    newRow.style.verticalAlign='top';

    var cel=newRow.insertCell(0);
    cel.innerHTML='<a class="icon-homeimg icon-sdel marR8" title="删除" href="javascript:;" onclick="deleteExpenseRow('+(rowcount-1)+')"></a><input type="hidden" value="0" name="deleted2" id="deleted2">'+"<a class='icon-homearr icon-sup' title='向上' href='javascript:moveExpenseUpDown(\"UP\","+(rowcount-1)+")'></a>";
    cel.className='crmTableRow';
    cel.id=newRow.id+"_col1";
    
    cel=newRow.insertCell(1);
    cel.className="crmTableRow";
    cel.innerHTML="<input type='text' name='expenseuse"+(rowcount-1)+"' id='expenseuse"+(rowcount-1)+"'/>";
    
    cel=newRow.insertCell(2);
    cel.className='crmTableRow';
 //   cel.innerHTML=document.getElementById('row1').cells[2].innerHTML;
 var seloption="<select name='expensetype"+(rowcount-1)+"' id='expensetype"+(rowcount-1)+"'>";
     for(var j=0;j<document.getElementById('expensetype1').options.length;j++)
     {
        seloption+="<option value='"+document.getElementById('expensetype1').options[j].value+"'>"+document.getElementById('expensetype1').options[j].text+"</option>";
     }
     cel.innerHTML=seloption+"</select>";
   // var selectobj=cel.getElementsByTagName('SELECT');
   // selectobj[0].name='expensetype'+(rowcount-1);
   // selectobj[0].id='expensetype'+(rowcount-1);
  
    var startm=document.getElementById('StartMonth').value;//默认为本月第一天
    var endm=document.getElementById('EndMonth').value;//默认为本月最后一天
    cel=newRow.insertCell(3);
    cel.className='crmTableRow small';
    cel.innerHTML='<input type="text" readonly="true" value="'+startm+'" id="start'+(rowcount-1)+'" name="start'+(rowcount-1)+'" size="15" onClick="WdatePicker()" class="Wdate"/>';
    
    cel=newRow.insertCell(4);
    cel.className='crmTableRow small';
    cel.innerHTML='<input type="text" readonly="true" value="'+endm+'" id="end'+(rowcount-1)+'" name="end'+(rowcount-1)+'" size="15" onClick="WdatePicker()" class="Wdate"/>';
   
    cel=newRow.insertCell(5);
    cel.className='crmTableRow small';
    cel.innerHTML='<input type="text" onchange="MoneyChanged(this)" name="money'+(rowcount-1)+'" id="money'+(rowcount-1)+'" value="0" size="8"/>';
    
    cel=newRow.insertCell(6);
    cel.className='crmTableRow small';
    cel.innerHTML='<input type="text" name="description'+(rowcount-1)+'" id="description'+(rowcount-1)+'"/>';
    
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
                if(trim(document.getElementById("delExpensedetail").value)=="")
                {
                    document.getElementById("delExpensedetail").value=expensedetailid;
                }
                else
                {
                    document.getElementById("delExpensedetail").value+=" , "+expensedetailid;
                }
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
/*
edit:can
date:20130924
reason:费用明细非法判断
*/
function verifyExpense()
{
     var expensetable=document.getElementById("proTab");
     var i=1;
     var expenserow;
     var expenseusevalue;
     var startdate;
     var enddate;
     var money;
     var total=0;
    
     
     while(i<expensetable.rows.length)
     {
        expenserow=document.getElementById('row'+i);
       
        if(expenserow!=undefined)
        {
           
           expenseusevalue=document.getElementById("expenseuse"+i).value;
       
           if(trim(expenseusevalue)=="")
           {
                //"第"+i+"行费用用途不能为空！"
                alert(arrJsPopLabel['LINE']+i+arrJsPopLabel['PURPOSESCANOTEMPTY']);
                document.getElementById("expenseuse"+i).focus();
                return false;
           }
           startdate=document.getElementById("start"+i).value;
           enddate=document.getElementById("end"+i).value;
           if(enddate<startdate)
           {
                //第"+i+"行结束日期不能小于开始日期！
                alert(arrJsPopLabel['LINE']+i+arrJsPopLabel['ENDDATECANOTLESSSTARTDAATE']);
                return false;
           }
           money=document.getElementById("money"+i).value;
           if(trim(money)!=""&& isNaN(money))
           {
             //第"+i+"行报销金额内容非法！
             alert(arrJsPopLabel['LINE']+i+arrJsPopLabel['REIMBURSEMENTILLEGALCONTENT']);
             document.getElementById("money"+i).focus();
             return false;
           }
            var temp=/^\d+(\.\d+)?$/;
            if(!temp.test(money))
            {
                //第"+i+"行报销金额应该输入非负数！
                alert(arrJsPopLabel['LINE']+i+arrJsPopLabel['REIMBURSEDSHOULDNONNEGATIVE']);
                document.getElementById("money"+i).focus();
                return false;
            }
            total=parseFloat(total)+parseFloat(money);
            i++;
        }
        else
        {
            break;
        }
     }
     document.getElementById("grandTotal").innerHTML=parseFloat(total).toFixed(2);
     document.getElementById("totalMoney").value=parseFloat(total).toFixed(2);
     return true;
}