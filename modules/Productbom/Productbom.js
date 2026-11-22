/*********************************************************************************
**{*修改编码格式:统一编码：UTF-8*} 
* The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/
/**
 * 添加一行产品
 * @project PROT127 爱哆哆需求1：产品套餐
 * @author Tujt 2014-11-25
 */
function bomAddProductRow(module,image_path,span){
	rowCnt++;
	var tableName = document.getElementById('proTab');
	var prev = tableName.rows.length;
    // 2列头  
	var count = prev - 2 + 1;//As the table has two headers, we should reduce the count
	var row = tableName.insertRow(prev);
	row.id = "row"+count;
	row.style.verticalAlign = "top";
	if(typeof('popupBom') != 'undefined'){
		span = document.getElementById('spannameinfo').value;
	}else if(!span){
		span = document.getElementById('spannameinfo').value;
	}
    var productSpanname = span.split("==");
    var productinto = '';
    var productqty = '';
    if(productSpanname.length > 1)
    {
        var spanname = productSpanname[0].split(",");
        productinto = productSpanname[1];
        var productall = productinto.split(',');
    }
    else
    {
        var spanname = span.split(",");   
    }
    if(document.getElementById('productToolField') != undefined)
    {
        var producttoolfield=document.getElementById('productToolField').value.split(':');   
    }
    var cnt = 0;
	var colone = row.insertCell(0);
	var coltwo = row.insertCell(1);
    var control;
    var colnew;
    var colinfos;
    var colinfo;
    var defaultvalue;
    var uitype;
    var columnname;
    var typeofdata;
	/* Product Re-Ordering Feature Code Addition Starts */
	iMax = tableName.rows.length;
	for(iCount=1;iCount<=iMax-3;iCount++)
	{
		if(document.getElementById("row"+iCount) && document.getElementById("row"+iCount).style.display != 'none')
		{
			iPrevRowIndex = iCount;
		}
	}
    
	iPrevCount = eval(iPrevRowIndex);
	var oPrevRow = tableName.rows[iPrevRowIndex+1]; 
	var delete_row_count=count;
	/* Product Re-Ordering Feature Code Addition ends */

	//colone.className = "crmTableRow";
	if(document.getElementById('selectproductbom') == undefined){
		colone.id = row.id+"_col1";
		colone.innerHTML='<a class="icon-homeimg icon-sdel2" href="javascript:;" onclick="deleteRow('+count+')" title="'+arrJsPopLabel['DELETE']+'" ></a><input type="hidden" id="hidden_lineitem_id" name="hidden_lineitem_id" value="0" /><input id="deleted'+count+'" name="deleted'+count+'" type="hidden" value="0"><br/><br/>&nbsp;<a class="icon-category category-sup" href="javascript:bom_moveUpDown(\'UP\',\''+module+'\','+count+')" title="'+arrJsPopLabel['MOVEUP']+'"></a>';
		/* Product Re-Ordering Feature Code Addition Starts */
		if(iPrevCount != 1)
		{
			oPrevRow.cells[0].innerHTML = '<a class="icon-homeimg icon-sdel2" href="javascript:;" onclick="deleteRow(,'+iPrevCount+')" title="'+arrJsPopLabel['DELETE']+'"></a><input id="deleted'+iPrevCount+'" name="deleted'+iPrevCount+'" type="hidden" value="0"><br/><br/>&nbsp;<a class="icon-category category-sup marR8" href="javascript:bom_moveUpDown(\'UP\',\''+module+'\','+iPrevCount+')" title="'+arrJsPopLabel['MOVEUP']+'"></a><a class="icon-category category-sdown" href="javascript:bom_moveUpDown(\'DOWN\',\''+module+'\','+iPrevCount+')" title="'+product_labelarr.MOVEDOWN+'"></a>';
		}
		else
		{
			oPrevRow.cells[0].innerHTML = '<input id="deleted'+iPrevCount+'" name="deleted'+iPrevCount+'" type="hidden" value="0"><br/><br/><a class="icon-category category-sdown" href="javascript:bom_moveUpDown(\'DOWN\',\''+module+'\','+iPrevCount+')" title="'+arrJsPopLabel['MOVEDOWN']+'"></a>';
		}
	}else{//选择框创建产品套餐
		colone.id = row.id+"_col1";
		colone.style.whiteSpace = 'nowrap';
		colone.align = 'center';
		colone.innerHTML='<a class="icon-homeimg icon-sdel2" href="javascript:;" onclick="deleteRow('+count+')" title="'+arrJsPopLabel['DELETE']+'" ></a><input type="hidden" id="hidden_lineitem_id" name="hidden_lineitem_id" value="0" /><input id="deleted'+count+'" name="deleted'+count+'" type="hidden" value="0"><a class="icon-category category-sup" href="javascript:bom_moveUpDown(\'UP\',\''+module+'\','+count+')" title="'+arrJsPopLabel['MOVEUP']+'"></a>';
		/* Product Re-Ordering Feature Code Addition Starts */
		if(iPrevCount != 1)
		{
			oPrevRow.cells[0].innerHTML = '<a class="icon-homeimg icon-sdel2" href="javascript:;" onclick="deleteRow('+iPrevCount+')" title="'+arrJsPopLabel['DELETE']+'"></a><input id="deleted'+iPrevCount+'" name="deleted'+iPrevCount+'" type="hidden" value="0"><a class="icon-category category-sup" href="javascript:bom_moveUpDown(\'UP\',\''+module+'\','+iPrevCount+')" title="'+arrJsPopLabel['MOVEUP']+'"></a><a class="icon-category category-sdown" href="javascript:bom_moveUpDown(\'DOWN\',\''+module+'\','+iPrevCount+')" title="'+product_labelarr.MOVEDOWN+'"</a>';
		}
		else
		{
			oPrevRow.cells[0].innerHTML = '<input id="deleted'+iPrevCount+'" name="deleted'+iPrevCount+'" type="hidden" value="0"><a class="icon-category category-sdown" href="javascript:bom_moveUpDown(\'DOWN\',\''+module+'\','+iPrevCount+')" title="'+arrJsPopLabel['MOVEDOWN']+'"></a>';
		}
	}
	
	
	var producthtml = '<table class="OtherTab" width="100%" border="0" cellpadding="0" cellspacing="0"><tr><td><input id="productName'+count+'" name="productName'+count+'" class="f-l" autocomplete=\'off\' onfocus="return clickOnFoucus(this)" onblur="return clickOnBlur(this)" onkeyup="getInventoryProductKeyWords(this,'+count+',\'Products\',event)" style="width: 68%;" value="'+arrJsPopLabel['INPUTAKEYWORDSQUERY']+'" type="text"><div id="search_productName'+count+'" class="ProSearchResult"></div><a class="icon-homeimg icon-select f-l" href="javascript:;" id="searchIcon'+count+'" title="'+arrJsPopLabel['PRODUCTS']+'" onclick="bom_selectproduct(this,\''+module+'\','+count+')"></a><a class="icon-homeimg icon-clear f-l" href="javascript:;" title="'+arrJsPopLabel['CLEAR']+'"  onclick="bom_ClearProductInfo('+count+',\''+module+'\',\''+span+'\')" ></a>'+
					'<input id="hdnProductId'+count+'" name="hdnProductId'+count+'" value="" type="hidden"><input type="hidden" id="lineItemType'+count+'" name="lineItemType'+count+'" value="Products" />'+ 
					'<input type="hidden" value="" id="subproduct_ids'+count+'" name="subproduct_ids'+count+'" />'+
					'<div class="proClaer"><span id="subprod_names'+count+'" name="subprod_names'+count+'" style="color:#C0C0C0;font-style:italic;"> </span></div</td></tr>'+
					'<tr><td id="setComment'+count+'">';
	if(document.getElementById('selectproductbom') == undefined){
		producthtml += '<textarea id="comment'+count+'" name="comment'+count+'" class="proName_note"></textarea><a class="icon-homeimg icon-clear" href="javascript:;" title="'+product_labelarr.JSCLEAR+'" onClick="getObj(\'comment'+count+'\').value=\'\'"; ></a></td></tr>';
	}else{
		producthtml += '<input type="hidden" name="comment'+count+'" id="comment'+count+'"/>';
	}
	producthtml += '</table>';
	coltwo.innerHTML= producthtml;

   
 
    
    /*
        edit:can
        date:20130805
        reason:4614: 建议：将“销售订单”、“产品”、“发票”界面的“库存数量”隐藏不显示。
        */
	if(module != "PurchaseOrder"){
//	colthree.className = "crmTableRow small"
//	colthree.innerHTML='<span id="qtyInStock'+count+'">&nbsp;</span>';
	}
	//Quantity
	var temp='';
    var prevtdcount=1;
    if(span != "")
    {
        if(document.getElementById('productToolField') != undefined && document.getElementById('productToolField').value == "")
        {
            prevtdcount+=1;
        }
        prevtdcount+=spanname.length;
        for(i = 1; i<=spanname.length; i++)
        {
              colnew = row.insertCell(i+1);
              //colnew.className = "crmTableRow";
              colnew.innerHTML ='<span id="'+spanname[i-1]+''+count+'"></span>'; 
        }
    }
   //control:$columnname.'_'.$uitype.'_'.$typeofdata.'_'.$i
  // $columnname.'_'.$uitype.'_'.$defaultvalue.'_'.$typeofdata;
  /*
  更新操作
  edit:can
  date:20131202
  reason:产品工具自定义字段（V3.1)
  */
    var j=prevtdcount;
    if(document.getElementById('productToolField') != undefined && document.getElementById('productToolField').value != "")
    {
        j++;
        var date = new Date(); //日期对象
        var year=date.getFullYear();
        var month=date.getMonth()+1;
        var day=date.getDate();
        var hours=date.getHours();
        var minute=date.getMinutes();
        var second=date.getSeconds();
        if(minute<10)
        {
            minute="0"+minute;
        }
        for(var i=0;i<producttoolfield.length;i++)
        {
             colnew = row.insertCell(j);
             
             //colnew.className = "crmTableRow";
             colinfos=producttoolfield[i].split('_');
             defaultvalue=colinfos[2];//
             uitype=colinfos[1];
             columnname=colinfos[0];
             typeofdata=colinfos[3];
             control=columnname+'_'+uitype+'_'+typeofdata+'_'+count;
            // alert(uitype);
             if(uitype==7 ||uitype==1 || uitype==9 || uitype==71)
             {
                 colnew.innerHTML ='<input type="text" size="8" value="'+defaultvalue+'" name="'+control+'" id="'+control+'"/>';
             }
             else if(uitype==19)
             {
                 colnew.innerHTML ='<textarea id="'+control+'" name="'+control+'" style="width:90%; height:80px; font-size:12px;"></textarea>';
             }
             else if(uitype==5)
             {
                 if(defaultvalue=='thistoday')
                 {
                    defaultvalue=year+'-'+month+'-'+day;
                 }
                 colnew.innerHTML ='<input class="CustomInput" type="text" size="15" value="'+defaultvalue+'" name="'+control+'" id="'+control+'" onClick="WdatePicker()" class="Wdate"/>';
        
             
             }
             else if(uitype==14)
             {
                 if(defaultvalue=="thistime")
                 {
                    defaultvalue=hours+':'+minute+':'+second;
                 }
                colnew.innerHTML ='<input class="CustomInput" type="text" size="15" value="'+defaultvalue+'" name="'+control+'" id="'+control+'" onClick="WdatePicker()" class="Wdate"/>';
             }
             else if(uitype==86)
             {
                 if(defaultvalue=='thistodaytime')
                 {
                    defaultvalue=year+'-'+month+'-'+day+""+hours+':'+minute+':'+second;
                 }
                colnew.innerHTML ='<input class="CustomInput" type="text" size="15" value="'+defaultvalue+'" name="'+control+'" id="'+control+'" onClick="WdatePicker()" class="Wdate"/>';
             }
             else if(uitype==56)
             {
                if(defaultvalue==1)
                {
                    colnew.innerHTML='<input type="checkbox" name="'+control+'" id="'+control+'" checked="true"/>'
                }
                else
                {
                    colnew.innerHTML='<input type="checkbox" name="'+control+'" id="'+control+'" />'
                }
             }
             j++;
              
        }
    }
        cnt=2;
        if(span != ""||document.getElementById('productToolField').value!="")
        {
           cnt = j;
        }
        //end
	
	//cnt += 1;
    colnew = row.insertCell(cnt);
	colnew.innerHTML = '<input id="qty'+count+'" name="qty'+count+'" type="text" class="small " style="width:50px" value="" maxlength="19"/>';
	cnt += 1;
	colnew = row.insertCell(cnt);
	colnew.align = "left";
	colnew.innerHTML = '<input id="listPrice'+count+'" name="listPrice'+count+'" value="" type="text" style="width:50px" maxlength="19"/><input type="hidden" name="unitPrice'+count+'" id="unitPrice'+count+'" value=""/>';
	cnt += 1;
	colnew = row.insertCell(cnt);
	colnew.id = 'bomtotal'+count;
	colnew.align = "left";
	colnew.innerHTML = '&nbsp;';
	bom_totalnoofrows();
	return count;
}
/**
 * 选择产品弹出框
 * @project PROT127 爱哆哆需求1：产品套餐
 * @author Tujt 2014-11-25
 */
function bom_selectproduct(currObj,module, row_no){
    var trObj=currObj.parentNode.parentNode
	var warehouseid = 0;
	var rowId = row_no;
	var currentRowId = parseInt(currObj.id.match(/([0-9]+)$/)[1]);
    var productNameUrl ='';
    productNameUrl = '&searchfieldname=productname&searchvalue=';   
    if(document.getElementById('hdnProductId'+row_no) != undefined && document.getElementById('hdnProductId'+row_no).value != '')
    {
        var productName = document.getElementById('productName'+row_no).value;
        productNameUrl = productNameUrl + encodeURIComponent(productName);
        
    }
	// If we have mismatching rowId and currentRowId, it is due swapping of rows
	if(rowId != currentRowId) {
		rowId = currentRowId;
	}
	var currencyid = document.getElementById("inventory_currency").value;   
	popuptype = 'inventory_prod';
    
	var record_id = '';var inputs = getBomFormObj();
	if(document.getElementsByName("account_id").length != 0 && inputs.account_id != undefined)
		record_id= inputs.account_id.value;
	var urlstr = '&html=Popup_picker&select=enable&form=HelpDeskEditView&popuptype='+popuptype+'';
	urlstr += '&curr_row='+rowId+productNameUrl+'&return_module='+module+'&currencyid='+currencyid+'';
	urlstr += '&isbom=true';
	if(record_id != '')
		window.open("index.php?module=Products&action=Popup&relmod_id="+record_id+"&parent_module=Accounts"+urlstr+"","bomproductWin","width=840,height=600,resizable=1,scrollbars=1,status=1,top=150,left=200");
	else
		window.open("index.php?module=Products&action=Popup&wareid="+warehouseid+""+urlstr+"","bomproductWin","width=840,height=600,resizable=1,scrollbars=1,status=1,top=150,left=200");
}
var bom_edit_qty = 0;
/**
 * 添加产品信息
 * @project PROT127 爱哆哆需求1：产品套餐
 * @author Tujt 2014-11-25
 */
function bom_setProduct(product_id,product_name,unitprice,desc,subprod_id,pro_all,curr_row){
	var parentwindow = window;var qty = 1;
	if(bom_edit_qty && bom_edit_qty > 0){//产品弹出框快速创建，编辑产品套餐时，产品数量赋值
		qty = bom_edit_qty;
	}
	if(window.opener != undefined && document.getElementById('proTab') == undefined)
		parentwindow = window.opener;
	var subpro = pro_all.split(",");

	var inputs = getBomFormObj(parentwindow);

	inputs.elements["productname"+curr_row].value = product_name;
    //设置产品名称为不可输入
    document.getElementById("productname"+curr_row).style.cursor = 'not-allowed';
	document.getElementById("productname"+curr_row).disabled  = true;
	
	inputs.elements["hdnProductId"+curr_row].value = product_id;
	//inputs.elements["comment"+curr_row].value = desc;
	inputs.elements["quantity"+curr_row].value = qty;
	//inputs.elements["listprice"+curr_row].value = unitprice;
	//inputs.elements["unitprice"+curr_row].value = unitprice;
	var bomtotal = qty * unitprice;
	//parentwindow.document.getElementById("bomtotal"+curr_row).innerHTML = bomtotal.toFixed(2);
	var subprolen = subpro.length;
	for(var i=0;i<subprolen; i++){//自定义产品字段
		spanname = subpro[i].split(":");
		if(parentwindow.document.getElementById(spanname[0]+curr_row) != undefined){
			if(spanname[0] == 'costprice')
				parentwindow.document.getElementById(spanname[0]+curr_row).value = spanname[1];   
			else
				parentwindow.document.getElementById(spanname[0]+curr_row).innerHTML = spanname[1];   
		}
	}
	bom_productEventBind(curr_row);//绑定事件
}
/**
 * 清空产品
 * @project PROT127 爱哆哆需求1：产品套餐
 * @author Tujt 2014-11-25
 */
function bom_ClearProductInfo(rowid,module,span){
    //清空产品名称
    document.getElementById('productName'+rowid).value = '';
    //清空产品ID
    document.getElementById('hdnProductId'+rowid).value = '';
    //清空产品数量
    if(document.getElementById('qty'+rowid) != undefined)
        document.getElementById('qty'+rowid).value = '';

	if(document.getElementById('listPrice'+rowid) != undefined)
        document.getElementById('listPrice'+rowid).value = '';

	if(document.getElementById('comment'+rowid) != undefined)
        document.getElementById('comment'+rowid).value = '';

	if(document.getElementById('bomtotal'+rowid) != undefined)
		document.getElementById('bomtotal'+rowid).innerHTML = '&nbsp;';

    //清空隐藏hidden_lineitem_id
    if(document.getElementById('hidden_lineitem_id'+rowid) != undefined)
        document.getElementById('hidden_lineitem_id'+rowid).value = 0;
    
    //清空产品关联字段
	if(!span) span = document.getElementById('spannameinfo').value;
    var fieldname = span.split(",");
    for(i = 0; i<fieldname.length; i++)
    {
        document.getElementById(fieldname[i]+rowid).innerHTML = '';
    }
    //清空自定义字段
    if(document.getElementById('productToolField') != undefined && document.getElementById('productToolField').value != "")
    {
        var producttoolfield=document.getElementById('productToolField').value.split(':');
        for(var i=0;i<producttoolfield.length;i++)
        {
             colinfos=producttoolfield[i].split('_');
             defaultvalue=colinfos[2];//
             uitype=colinfos[1];
             columnname=colinfos[0];
             typeofdata=colinfos[3];
             control=columnname+'_'+uitype+'_'+typeofdata+'_'+rowid;
             if(uitype==56) //checkbox 为不选中
             {
                 document.getElementById(control).checked  = false;
             }
             else   // 清空文本、文本域、日期格式的数据
             {
                document.getElementById(control).value = '';
             }
        }
    }
    //产品文本输入框变为可输入
    document.getElementById('productName'+rowid).style.cursor = '';
    document.getElementById('productName'+rowid).disabled  = false;
    document.getElementById('productName'+rowid).value = arrJsPopLabel['INPUTAKEYWORDSQUERY'];
	bom_conutTotal();
}

/**
 * 产品上下转换
 * @project PROT127 爱哆哆需求1：产品套餐
 * @author Tujt 2014-11-25
 */
function bom_moveUpDown(sType,oModule,iIndex)
{
	var aFieldIds = Array('hidtax_row_no','productName','subproduct_ids','hdnProductId','comment','qty','listPrice','unitPrice');
	//var aContentIds = Array('qtyInStock','netPrice','subprod_names');
    //var aGpField = Array('costprice','grossprofit');//成本 GP
	var aOnClickHandlerIds = Array('searchIcon');
	
	iIndex = eval(iIndex) + 1;
	var oTable = document.getElementById('proTab');
	iMax = oTable.rows.length;
	iSwapIndex = 1;
	if(sType == 'UP')
	{ 
		for(iCount=iIndex-2;iCount>=1;iCount--)
		{
			if(document.getElementById("row"+iCount))
			{
				if(document.getElementById("row"+iCount).style.display != 'none' && document.getElementById('deleted'+iCount).value == 0)
				{
					iSwapIndex = iCount+1;
					break;
				}
			}
		}
	}
	else
	{
		for(iCount=iIndex;iCount<=iMax-2;iCount++)
		{
			if(document.getElementById("row"+iCount) && document.getElementById("row"+iCount).style.display != 'none' && document.getElementById('deleted'+iCount).value == 0)
			{
				iSwapIndex = iCount;
				break;
			}
		}
		iSwapIndex += 1;
	}
	
	var oCurTr = oTable.rows[iIndex];//当前行
	var oSwapRow = oTable.rows[iSwapIndex];//上一行或下一行
	
	iMaxCols = oCurTr.cells.length;
	iIndex -= 1;
	iSwapIndex -= 1;
	
	iCheckIndex = 0;
	iSwapCheckIndex = 0;

	iMaxElement = aFieldIds.length;
	for(iCt=0;iCt<iMaxElement;iCt++)
	{
		sId = aFieldIds[iCt] + iIndex;
		sSwapId = aFieldIds[iCt] + iSwapIndex;
		if(document.getElementById(sId) && document.getElementById(sSwapId))
		{
		  /**
           * edit:chj
           * date:2014-9-10
           * reason:产品明细  产品名称样式切换
           * */
            if(aFieldIds[iCt] == 'productName')
            {
                var disabled = document.getElementById(sId).disabled;
                var cursor = document.getElementById(sId).style.cursor;
                document.getElementById(sId).disabled = document.getElementById(sSwapId).disabled;
                document.getElementById(sSwapId).disabled = disabled;
                document.getElementById(sId).style.cursor = document.getElementById(sSwapId).style.cursor;
                document.getElementById(sSwapId).style.cursor = cursor;
            }
			sTemp = document.getElementById(sId).value;
			document.getElementById(sId).value = document.getElementById(sSwapId).value;
			document.getElementById(sSwapId).value = sTemp;
            if(aFieldIds[iCt] == 'productName')
            {
                if(document.getElementById('hdnProductId'+iIndex).value == '')
                {
                    document.getElementById('productName'+iSwapIndex).style.cursor = '';
                    document.getElementById('productName'+iSwapIndex).disabled  = false;
                    document.getElementById('productName'+iSwapIndex).value = arrJsPopLabel['INPUTAKEYWORDSQUERY'];    
                }
                if(document.getElementById('hdnProductId'+iSwapIndex).value == '')
                {
        
                    document.getElementById('productName'+iIndex).style.cursor = '';
                    document.getElementById('productName'+iIndex).disabled  = false;
                    document.getElementById('productName'+iIndex).value = arrJsPopLabel['INPUTAKEYWORDSQUERY'];    
                }
            }
		}
		//oCurTr.cells[iCt].innerHTML;
	}
    //产品更多信息字段
    var productinfo = document.getElementById('spannameinfo').value;
    var sproduct = productinfo.split(',');
    if(sproduct.length >= 1)
    {
        for(var j=0;j<sproduct.length;j++)
    	{
    		sId = sproduct[j] + iIndex;
    		sSwapId = sproduct[j] + iSwapIndex;
    		if(document.getElementById(sId) && document.getElementById(sSwapId))
    		{
    			sTemp = document.getElementById(sId).innerHTML;
    			document.getElementById(sId).innerHTML = document.getElementById(sSwapId).innerHTML;
    			document.getElementById(sSwapId).innerHTML = sTemp;
    		}
    	}
    }
    //产品自定义字段信息
    var productdetailhtml = document.getElementById('productdetailhtml').value;
    var sproducthtml = productdetailhtml.split('&&');
    if(sproducthtml.length >= 1)
    {
        for(var k=0;k<sproducthtml.length;k++)
    	{
    		sId = sproducthtml[k] + '_' +iIndex;
    		sSwapId = sproducthtml[k] + '_' + iSwapIndex;
    		if(document.getElementById(sId) && document.getElementById(sSwapId))
    		{
                if(document.getElementById(sId).type == 'checkbox')
                {
                    var sIdCheckbox = document.getElementById(sId);
                    var sSwapIdCheckbox = document.getElementById(sSwapId);
                    if(sIdCheckbox.checked != sSwapIdCheckbox.checked)
                    {
                        if(sIdCheckbox.checked == true && sSwapIdCheckbox.checked == false)
                        {
                            sIdCheckbox.checked = false;
                            sSwapIdCheckbox.checked = true;
                        }
                        else
                        {
                            sIdCheckbox.checked = true;
                            sSwapIdCheckbox.checked = false;
                        }
                    }
                }
                else
                {
                    sTemp = document.getElementById(sId).value;
        			document.getElementById(sId).value = document.getElementById(sSwapId).value;
        			document.getElementById(sSwapId).value = sTemp;   
                }
    		}
    	}
    }
	iMaxElement = aOnClickHandlerIds.length;
	for(iCt=0;iCt<iMaxElement;iCt++)
	{
		sId = aOnClickHandlerIds[iCt] + iIndex;
		sSwapId = aOnClickHandlerIds[iCt] + iSwapIndex;
		if(document.getElementById(sId) && document.getElementById(sSwapId))
		{
			sTemp = document.getElementById(sId).onclick;
			document.getElementById(sId).onclick = document.getElementById(sSwapId).onclick;
			document.getElementById(sSwapId).onclick = sTemp;
			
			sTemp = document.getElementById(sId).src;
			document.getElementById(sId).src = document.getElementById(sSwapId).src;
			document.getElementById(sSwapId).src = sTemp;
			
			sTemp = document.getElementById(sId).title;
			document.getElementById(sId).title = document.getElementById(sSwapId).title;
			document.getElementById(sSwapId).title = sTemp;
		}
	}
	sId = 'tax1_percentage' + iIndex;
	sTaxRowId = 'hidtax_row_no' + iIndex;
	if(document.getElementById(sTaxRowId))
	{
		if(!(iTaxVal = document.getElementById(sTaxRowId).value))
			iTaxVal = 0;
	}
	
	sSwapId = 'tax1_percentage' + iSwapIndex;
	sSwapTaxRowId = 'hidtax_row_no' + iSwapIndex;
	if(document.getElementById(sSwapTaxRowId))
	{
		if(!(iSwapTaxVal = document.getElementById(sSwapTaxRowId).value))
			iSwapTaxVal = 0;
	}
	bomtotal = document.getElementById("bomtotal"+iIndex).innerHTML;
	document.getElementById("bomtotal"+iIndex).innerHTML =  document.getElementById("bomtotal"+iSwapIndex).innerHTML;
	document.getElementById("bomtotal"+iSwapIndex).innerHTML = bomtotal;
}
var istotal = 1;//是否计算套餐售价、商品总价（手动输入套餐售价后，不再再次计算套餐售价）
/**
 * 绑定某一行文本框的事件，并计算总计
 * @project PROT127 爱哆哆需求1：产品套餐
 * @author Tujt 2014-11-25
 */
function bom_productEventBind(curr_row){
	var oldqty = 0;
    document.getElementById('quantity'+curr_row).onfocus = function(event){
		var e = event||window.event;
		var obj = e.srcElement||e.target;
		oldqty = obj.value;
	}
	document.getElementById('quantity'+curr_row).onblur = function(event){
		var e = event||window.event;
		var obj = e.srcElement||e.target;
		if(parseFloat(oldqty) != parseFloat(obj.value)){
			var qty = rmb_getdecimal('quantity'+curr_row);
			var price = rmb_getdecimal('taxprice'+curr_row);
			var bomtotal = qty * price;
			//document.getElementById('bomtotal'+curr_row).innerHTML = bomtotal.toFixed(2);
			istotal = 1;
			bom_conutTotal();
		}
	}

	var oldprice = 0;
   
	bom_totalnoofrows();//计算当前单据有多少产品
	bom_conutTotal();
}
/**
 * 获取form表单对象
 * @project PROT127 爱哆哆需求1：产品套餐
 * @author Tujt 2014-11-27
 */
function getBomFormObj(parentwindow){
    var inputs;
	if(!parentwindow) parentwindow = window;
	if(typeof(parentwindow.document.EditView) != 'undefined')
		inputs = parentwindow.document.EditView;
	else if(typeof(parentwindow.document.QcbomEditView) != 'undefined')
		inputs = parentwindow.document.QcbomEditView;
	return inputs;
}
/**
 * 计算产品条数
 * @project PROT127 爱哆哆需求1：产品套餐
 * @author Tujt 2014-11-27
 */
function bom_totalnoofrows(){
    var max_row_count = document.getElementById('proTab').rows.length;
        max_row_count = eval(max_row_count)-2;
	//set the total number of products
	var inputs = getBomFormObj();
	//inputs.totalProductCount.value = max_row_count;	
}
/**
 * 计算当前页总计
 * @project PROT127 爱哆哆需求1：产品套餐
 * @author 2014-11-25
 */
function bom_conutTotal(){
	if(istotal == 2) return false;
	var inputs = getBomFormObj();
	bom_totalnoofrows();
	var max_row_count = inputs.rowcnt.value;
	if(max_row_count > 0){
		var bomtotal = 0;var netTotal = 0;var commoditytotal = 0;var unitprice = 0;
		for(var i=1;i<=max_row_count;i++){
			if(document.getElementById('hidden_rowid_'+i).value == 1) continue;
			if(document.getElementById('hdnProductId'+i).value == '' && document.getElementById('hdnProductId'+i).value < 1) continue;
			bomtotal = rmb_getdecimal('bomtotal'+i,'html');
			unitprice = rmb_getdecimal('unitPrice'+i);
			netTotal += bomtotal;commoditytotal += rmb_getdecimal('qty'+i)*unitprice;
		}
		//document.getElementById('commodityTotal_td').innerHTML = commoditytotal.toFixed(2);
		//document.getElementById('commodityTotal').value = commoditytotal.toFixed(2);
		document.getElementById('packageTotal').value = netTotal.toFixed(2);
	}
}
/**
 * 绑定套餐售价事件
 * @@project PROT127 爱哆哆需求1：产品套餐
 * @author Tujt 2014-11-25
 */
function bom_init(setype){
    var oldtotal = 0;
  
	document.getElementById('packageTotal').onfocus = function(event){//光标移入，记录套餐售价的值
		var e = event||window.event;
		var obj = e.srcElement||e.target;
		oldtotal = obj.value;
	}
	document.getElementById('packageTotal').onblur = function(event){//通过套餐售价反算售价
		var e = event||window.event;
		var obj = e.srcElement||e.target;
		if(parseFloat(oldtotal) != parseFloat(obj.value)){
			var packagetotal = obj.value;
			var commodityTotal = rmb_getdecimal('commodityTotal');
			var inputs = getBomFormObj();
			var max_row_count = inputs.totalProductCount.value;
			if(max_row_count > 1){
				var unitprice = 0;var listprice = 0;
				var totalprice = 0;var qty = 0;
				for(var i=1;i<max_row_count;i++){
					if(document.getElementById('deleted'+i).value == 1) continue;
					if(document.getElementById('hdnProductId'+i).value == '' && document.getElementById('hdnProductId'+i).value < 1) continue;
					unitprice = rmb_getdecimal('unitPrice'+i);//获得产品参考价
					qty = rmb_getdecimal('qty'+i);//获得产品数量
					if(unitprice > 0 && commodityTotal > 0 && packagetotal > 0){//必须大于0
						listprice = (unitprice * packagetotal) / commodityTotal;
						listprice = listprice.toFixed(2);
					}else{
						listprice = 0;
					}
					document.getElementById('listPrice'+i).focus();
					document.getElementById('listPrice'+i).value = listprice;
					document.getElementById('listPrice'+i).blur();
					totalprice += parseFloat(qty) * parseFloat(listprice);
				}
				var maxqty = rmb_getdecimal('qty'+max_row_count);//获得最后一位产品的数量
				var maxprice = (packagetotal - totalprice)/maxqty;//套餐售价减去累计的产品金额，除以数量就是最后一个产品的价格
				maxprice = parseFloat(maxprice.toFixed(2))
				totalprice += maxqty * maxprice;
				if(totalprice != packagetotal){
					if(totalprice > packagetotal){
						var diffprice = totalprice - packagetotal;
					}
				}
				istotal = 2;//修改过套餐售价后，就不允许反算套餐售价了，除非修改了数量或者单价
				document.getElementById('listPrice'+max_row_count).focus();
				document.getElementById('listPrice'+max_row_count).value = maxprice;
				document.getElementById('listPrice'+max_row_count).blur();
			}else if(max_row_count == 1){
				var qty = rmb_getdecimal('qty1');
				document.getElementById('listPrice1').value = (packagetotal / qty).toFixed(2);
			}
		}
	}
	if(setype == 'edit'){
		bom_totalnoofrows();
		var inputs = getBomFormObj();
		var max_row_count = inputs.totalProductCount.value;
		if(max_row_count > 0){
			var commodityTotal = 0;var packageTotal = 0;
			var qty = 0;var unitprice = 0;var listprice = 0;
			for(var i=1;i<=max_row_count;i++){
				qty = rmb_getdecimal('qty'+i);
				unitprice = rmb_getdecimal('unitPrice'+i);
				listprice = rmb_getdecimal('listPrice'+i);
				commodityTotal += qty * unitprice;
				packageTotal += qty * listprice;
				bom_productEventBind(i);
			}
			document.getElementById('commodityTotal_td').innerHTML = commodityTotal.toFixed(2);
			document.getElementById('commodityTotal').value = commodityTotal.toFixed(2);
			document.getElementById('packageTotal').value = packageTotal.toFixed(2);
		}
		bom_conutTotal();
	}
}

// /**************		产品选择框		**************/
/**
 * 产品套餐操作类
 * @project PROT127 爱哆哆需求1：产品套餐
 * @author Tujt 2014-11-27
 */
this.ProductBomEvent = function(){
	this.mode;// 状态
	var bomisinit = 0;//是否已经初始化
	var isbomsubmit = 1;//是否提交
	var bom_userid = 0;//用户初始ID
	this.bom_id = 0;
	this.confirmAndSelect = function(){//确认并选择，不修改数据库
		if(isbomsubmit == 2) return false;//防止重复点击
		isbomsubmit = 2;
		var inputs = getBomFormObj();
		var productcount = inputs.totalProductCount.value;//获得产品条数
		var product_i = 0;var productid = '';
		var deleted = 0;var bomproduct = {};
		var isproductnull = 0;
		if(productcount == 1){//只有一个产品时
			var product1 = ld('#hdnProductId1').val();
			deleted = ld('#deleted1').val()
			if(deleted == '0' && product1 > 0){//必须未删除且已经选择产品
				var prodarr = {};
				prodarr['qty'] = ld('#qty1').val();
				prodarr['price'] = ld('#listPrice1').val();
				bomproduct[product1]= prodarr;
				productid += product1+',';
				product_i ++;
			}
		}else if(productcount > 1){//有多个产品时
			var prodarr;
			for(var i=1;i<=productcount;i++){
				var product_id = ld('#hdnProductId'+i+'').val();
				deleted = ld('#deleted'+i+'').val();
				if(deleted == '0' && product_id > 0){
					product_i ++;
					productid += product_id+',';//记录保存产品的ID，方便选择套餐产品时使用
					prodarr = {};//必须每次都初始化，不能放到循环外，不然变量的引用会修改掉每次循环的赋值
					prodarr['qty'] =ld('#qty'+i+'').val();
					prodarr['price'] = ld('#listPrice'+i+'').val();
					bomproduct[product_id] = prodarr;
				}else{
					if(deleted != '1'){//如果某一行未选择产品，则保存不允许通过
						isproductnull = i;
						break;
					}
				}
			}
		}
		if(product_i == 0){//未选择产品
			RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['PLEASESELECTPRODUCT']);
			isbomsubmit = 1;
			return false;
		}
		if(isproductnull > 0){//提示：产品名称不能为空
			RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel.PRODUCTNAME+' '+arrJsPopLabel.CANOTEMPTY);
			ld('#productName'+isproductnull).focus();
			isbomsubmit = 1;
			return false;
		}
		ld('#numberCopies_bomid').val(this.bom_id);//产品套餐ID
		ld('#numberCopies_prodid').val(productid);//产品套餐ID
		var json_data = JSON.stringify(bomproduct);
		//var json_data =	j.toJSON(bomproduct);
		ld('#numberCopies_bomprod').val(json_data);//产品套餐ID
		fninvshnew('qcbomformDiv');
		//ld('.D_pbtn .D_pbtncancel').click();//关闭快速创建窗口
		isbomsubmit = 1;
		this.initNumberCopies(1);
		fnvshobj(this, 'qcbomnumberDiv');
	}
	this.selectProductList = function(){//选择产品套餐
		if(isbomsubmit == 2) return false;//防止重复点击
		isbomsubmit = 2;
		var bomid = ld('#numberCopies_bomid').val();
		var productid = ld('#numberCopies_prodid').val();
		if(productid != ''){//传入产品ID，单选产品套餐模式
			var nc_number = ld('#numberCopies_number').val();
			if(nc_number == ''){
				RemindsMsg("","LdPopWidth400px","","yes","",ld('#qcbomnumberDiv .D_ptita').html()+''+arrJsPopLabel.CANOTEMPTY);
				ld('#numberCopies_number').focus();
				isbomsubmit = 1;
				return false;
			}
			nc_number = parseFloat(nc_number);
			if(nc_number <= 0){
				RemindsMsg("","LdPopWidth400px","","yes","",ld('#qcbomnumberDiv .D_ptita').html()+''+arrJsPopLabel.Must_number_greater_than_0);
				ld('#numberCopies_number').focus();
				isbomsubmit = 1;
				return false;
			}
			var urlstr = 'module=Productbom&action=ProductbomAjax&file=getQcBomInfo';
			urlstr += '&setype=product&productid='+productid;
		
			this.Ajax(urlstr,function(rest){
				if(rest != ''){
					var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
					y = 0;var checkproduct = window.opener.rmb_checkRMBProduct();
					var mod = window.opener.document.EditView.module.value;
					var bomselectproduct = 1;var bomprod = ld('#numberCopies_bomprod').val();
					var bomprodobj = eval('('+ bomprod +')')?eval('('+ bomprod +')'):JSON.parse(bomprod);
					var nc_number = ld('#numberCopies_number').val();
					var bom_name = ld('[name=QcbomEditView] [name=subject]').val();
					var packageTotal = ld('[name=QcbomEditView] [name=packageTotal]').val();
					ld.each(restobj,function(entityid,entityobj){//循环产品信息，并添加到页面上
						var prod_array = entityobj.vt_prod_arr;
						if(y>0) {
							var row_id = window.opener.fnAddProductRow(mod);
						} else {
							var row_id = ld('#bom_curr_row').val();
						}
						for (var columnname in prod_array) {
							if(window.opener.document.getElementById(columnname+row_id) != undefined){
								if(columnname == 'quantity'){
									if(nc_number > 0 && prod_array['quantity'] > 0){
										prod_array['quantity'] = nc_number * prod_array['quantity'];
									}
								}
								if(window.opener.document.getElementById('span_'+columnname+row_id) != undefined){
									window.opener.document.getElementById('span_'+columnname+row_id).innerHTML = prod_array[columnname];
								}
								window.opener.document.getElementById(columnname+row_id).value = prod_array[columnname];
							}
							if(columnname == 'productname'){
								window.opener.document.getElementById('productname'+row_id).disabled  = true;
								window.opener.document.getElementById('productname'+row_id).style.cursor = 'not-allowed';
							}
						}
						y=y+1;
					});
				}
				window.close();
			});
		}else if(bomid != ''){//产品套餐多选
			var bomqty = {};var bom_bool = 0;var numcopies = 0;
			if(ld('#numberCopies_radio_1').attr('checked')){//相同份数
				var nc_number = ld('#numberCopies_number').val();
				if(nc_number == ''){
					RemindsMsg("","LdPopWidth400px","","yes","",ld('#qcbomnumberDiv .D_ptita').html()+''+arrJsPopLabel.CANOTEMPTY);
					ld('#numberCopies_number').focus();
					isbomsubmit = 1;
					return false;
				}
				nc_number = parseFloat(nc_number);
				if(nc_number <= 0){
					RemindsMsg("","LdPopWidth400px","","yes","",ld('#qcbomnumberDiv .D_ptita').html()+''+arrJsPopLabel.Must_number_greater_than_0);
					ld('#numberCopies_number').focus();
					isbomsubmit = 1;
					return false;
				}
				numcopies = 1;
			}else{
				ld('#numberCopies_div_2 table [name=numberCopies_bomnamenum]').each(function(){
					if(ldld(this).val() == ''){
						RemindsMsg("","LdPopWidth400px","","yes","",ld('#qcbomnumberDiv .D_ptita').html()+''+arrJsPopLabel.CANOTEMPTY);
						ld(this).focus();bom_bool = 1;
						return false;//跳出本次循环，类似于break
					}else if(ld(this).val() > 0)//数量必须大于0
						bomqty[ld(this).attr('bomid')] = ld(this).val();
					else{
						RemindsMsg("","LdPopWidth400px","","yes","",ld('#qcbomnumberDiv .D_ptita').html()+''+arrJsPopLabel.Must_number_greater_than_0);
						ld(this).focus();bom_bool = 1;
						return false;//跳出本次循环，类似于break
					}
				});
				if(bom_bool == 1){
					isbomsubmit = 1;
					return false;
				}
				numcopies = 2;
			}
			if(numcopies == 0) return false;
			var urlstr = 'module=Productbom&action=ProductbomAjax&file=getQcBomInfo';
			urlstr += '&setype=bomproduct&bomid='+bomid;
			if(document.getElementById('returnmodule')){
				urlstr += '&returnmodule='+document.getElementById('returnmodule').value;
			}
			if(document.getElementById('curr_row')){
				urlstr += '&curr_row='+document.getElementById('curr_row').value;
			}
			if(document.getElementById('currencyid')){
				urlstr += '&currencyid='+document.getElementById('currencyid').value;
			}
			if(document.getElementById('warehouse')){
				urlstr += '&wareid='+document.getElementById('warehouse').value;
			}
			//alert(urlstr);
			this.Ajax(urlstr,function(rest){//获取bom对应的产品信息
				if(rest != ''){
					var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
					y = 0;var checkproduct = window.opener.rmb_checkRMBProduct();
					var mod = window.opener.document.EditView.module.value;
					var nc_number =ld('#numberCopies_number').val();
					ld.each(restobj,function(entityid,entityobj){//循环产品信息，并添加到页面上
						var prod_array = entityobj.vt_prod_arr;
						if(y>0) {
							var row_id = window.opener.fnAddProductRow(mod);
						} else {
							var row_id = ld('#curr_row').val();//#bom_curr_row
						}
						for (var columnname in prod_array) {
							if(window.opener.document.getElementById(columnname+row_id) != undefined){
								if(columnname == 'quantity'){
									if(numcopies == 1){//相同份数
										if(nc_number > 0 && prod_array['quantity'] > 0){
											prod_array['quantity'] = nc_number * prod_array['quantity'];
										}
									}else{//不同份数
										if(bomqty[prod_array['bom_id']] > 0 && prod_array['quantity'] > 0){
											prod_array['quantity'] = bomqty[prod_array['bom_id']] * prod_array['quantity'];
										}
									}
								}
								if(window.opener.document.getElementById('span_'+columnname+row_id) != undefined){
									window.opener.document.getElementById('span_'+columnname+row_id).innerHTML = prod_array[columnname];
								}
								window.opener.document.getElementById(columnname+row_id).value = prod_array[columnname];
							}
							if(columnname == 'productname'){
								window.opener.document.getElementById('productname'+row_id).disabled  = true;
								window.opener.document.getElementById('productname'+row_id).style.cursor = 'not-allowed';
							}
						}
						y=y+1;
					});
					
				}
				window.close();
			});
		}
	}
	this.selectcancel = function(){//填写套餐份数界面，取消按钮事件
		this.clearhtml();
		//getListViewEntries_js('Productbom','parenttab=Tools&start=1');
		//fninvshnew('qcbomnumberDiv');
		cancelCrmPopup();
		isbomsubmit = 1;
	}
	this.copy = function(entityid){//赋值
		this.mode = 'copy';
		this.initBom(entityid);
	}
	this.update = function(entityid){//临时调整
		this.mode = 'update';
		this.initBom(entityid);
	}
	this.trim = function(string){//去除空格
		return string.replace(/\s/g,"");
	}
	this.clearhtml = function(){//清空
		if(bom_userid > 0){
			ld('[name=QcbomEditView] [name=bomsmownerid]').val(bom_userid);
			var defaultval = j("[name=QcbomEditView] [name=bomsmownerid]").find("option:selected").text()
			ld('[name=QcbomEditView] #cmb_span_optiontext_bomsmownerid').html(defaultval);
			ld('#productbom_no').val('');
			var inputs = getBomFormObj();
			var productcount = inputs.totalProductCount.value;
			ld('#row1 img[clearimg=clear]').click();
			if(productcount > 1){
				for(var i=2;i<=productcount;i++){
					deleteRow('ProductBom',i);
				}
			}
			document.getElementById('commodityTotal_td').innerHTML = '';
			document.getElementById('commodityTotal').value = 0;
			document.getElementById('packageTotal').value = 0;
		}
	}
	this.selectBom = function(){//多选产品套餐方法
		var bomidstr = '';var rowid = '';
		var bomobj = this;
		var parnetobj;
		var selected_i = 0;
		ld('[name=selected_id]:checked').each(function(){
			//获取多选框上级td的上级tr的ID，并把当前产品套餐ID取出来
			//rowid = ld(this).parent('td').parent('tr').attr('id');
			parnetobj = bomobj.getParentTag(this,'tr');
			rowid = ld(parnetobj).attr('id');
			rowid = rowid.split(',');
			rowid = rowid[0];
			rowid = rowid.split('_');
			rowid = rowid[1];
			bomidstr += rowid+',';
			selected_i++;
		});
		if(bomidstr == ''){
			RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['PLEASESELECTONEENTITY']);
			return false;
		}
		var crmPopupobj = CrmPopup.load(arrJsPopLabel['NUMBEROFCOPIES'],"", "", "LdPopWidth350px",'Productbom', '', "", "", "");
		var _divs = "<div id='qcbomnumberDiv'><div id='qcbomnumber'><table class='D_pop_bod' border='0' cellpadding='1' cellspacing='1' width='100%'><tbody>";
		if(selected_i > 1){
			_divs += "<tr align='left' style='display:;' id='numberCopies_radiotr' name='numberCopies_radiotr'>";
			_divs += "<td>";
			_divs += "<input class='input-btn-align' type='radio' id='numberCopies_radio_1' name='numberCopies_radio_1' value='1' onclick='bom.copiesRadio(1,\"\");' />&nbsp;"+arrJsPopLabel['SAMENUMBEROFCOPIES'];
			_divs += "&nbsp;&nbsp;<input class='input-btn-align' type='radio' id='numberCopies_radio_2' name='numberCopies_radio_2' value='0' onclick='bom.copiesRadio(0,\""+bomidstr+"\");' />&nbsp;"+arrJsPopLabel['NUMBEROFDIFFERENT'];
			_divs += "</td>";
			_divs += "</tr>";
		}
		_divs += "<tr>";
		_divs += "<td width='20%' style='padding:10px;'>";
		_divs += "<div id='numberCopies_div_1' name='numberCopies_div_1'>";
		_divs += "<font color='red'>*</font>"+arrJsPopLabel['NUMBEROFCOPIES']+':&nbsp;';
		_divs += "<input type='text' id='numberCopies_number' name='numberCopies_number' autocomplete='off' value=1  class='btn-radius-system' style='vertical-align: middle;margin-top: -2px;' onkeyup='this.value=this.value.replace(/\D/g,\"\");' maxlength='11'>";
		_divs += "</div>";
		_divs += "<div id='numberCopies_div_2' name='numberCopies_div_2' style='display:none;max-height:250px;overflow-y:auto;'>";
		_divs += "<table cellspacing='0' cellpadding='0' border='0' width='100%' name='numberCopies_div_2_table'>";
		_divs += "<tr>";
		_divs += "<td>"+arrJsPopLabel['PRODUCTPACKAGE']+"</td>";
		_divs += "<td><font color='red'>*</font>&nbsp;"+arrJsPopLabel['NUMBEROFCOPIES']+"</td>";
		_divs += "</tr>";
		_divs += "</table>";
		_divs += "</div>";
		_divs += "</td>";
		_divs += "</tr>";
		_divs += "</tbody>";
		_divs += "</table>";
		_divs += "<div class='D_pbtn'>";
		_divs += "<input name='button' class='D_pbtnok' value='"+arrJsPopLabel['CONFIRMED']+"' onclick='bom_selectProductList();' type='button'/>";
		_divs += "<span>&nbsp;</span>";
		_divs += "<input name='button' class='D_pbtncancel' value='"+arrJsPopLabel['CANCEL']+"' onclick='bom.selectcancel();' type='button'/>";
		_divs += "<input type='hidden' id='numberCopies_bomid' name='numberCopies_bomid'/>";
		_divs += "<input type='hidden' id='numberCopies_prodid' name='numberCopies_prodid'/>";
		_divs += "<input type='hidden' id='numberCopies_bomprod' name='numberCopies_bomprod'/>";
		_divs += "</div></div></div>";
		crmPopupobj.show(_divs);
		var prevdivid = crmPopupobj.divid;
		this.initNumberCopies(2);
		CrmPopup.findHtmlobj(prevdivid,'numberCopies_bomid').val(bomidstr);
		CrmPopup.findHtmlobj(prevdivid,'numberCopies_prodid').val('');
		//fnvshobj(this, 'qcbomnumberDiv');
	}
	this.copiesRadio = function(setype,bomidstr){
		var popupobj=CrmPopup.getPopupObj("last");
		var divid=popupobj.divid;
		if(setype == 1){
			CrmPopup.findHtmlobj(divid,'numberCopies_div_1').css('display','');
			CrmPopup.findHtmlobj(divid,'numberCopies_div_2').css('display','none');
			CrmPopup.findHtmlobj(divid,'numberCopies_radio_1').attr('checked',true);
			CrmPopup.findHtmlobj(divid,'numberCopies_radio_2').attr('checked',false);
		}else{
			var urlstr = 'module=Productbom&action=ProductbomAjax&file=getQcBomInfo';
			urlstr += '&setype=bomname&bomid='+bomidstr;
			this.Ajax(urlstr,function(rest){
				if(rest != ''){
					var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
					//ld("#numberCopies_div_2_table tr:not(:first)").remove();//删除除第一行外所有行
					CrmPopup.findHtmlobj(divid,'numberCopies_div_2_table').find('tr:not(:first)').remove();
					var tabletr = '';var restindex = 0;
					ld.each(restobj.bom,function(entityid,entityname){
						tabletr = '<tr  bgcolor="white"><td>'+entityname+'</td>'+
									'<td><input type="text" name="numberCopies_bomnamenum" '+
									'autocomplete="off" maxlength="11" bomid="'+entityid+'" '+
									'onkeyup="this.value=this.value.replace(/\\D/g,\'\');" ></td></tr>';
						CrmPopup.findHtmlobj(divid,'numberCopies_div_2_table').append(tabletr);
						++ restindex;
						
						if(restindex == restobj.row){
							CrmPopup.findHtmlobj(divid,'numberCopies_div_1').css('display','none');
							CrmPopup.findHtmlobj(divid,'numberCopies_div_2').css('display','');
							CrmPopup.findHtmlobj(divid,'numberCopies_radio_1').attr('checked',false);
							CrmPopup.findHtmlobj(divid,'numberCopies_radio_2').attr('checked',true);
						}
					});
				}
			});
		}
	}
	this.initNumberCopies = function(setype){//初始化套餐份数界面
		var popupobj=CrmPopup.getPopupObj("last");
		var divid=popupobj.divid;
		CrmPopup.findHtmlobj(divid,'numberCopies_div_1').css('display','');
		CrmPopup.findHtmlobj(divid,'numberCopies_div_2').css('display','none');
		CrmPopup.findHtmlobj(divid,'numberCopies_radio_1').attr('checked',true);
		CrmPopup.findHtmlobj(divid,'numberCopies_radio_2').attr('checked',false);
        
		CrmPopup.findHtmlobj(divid,'numberCopies_number').val('1');//35438: 合同订单新增界面>选择产品弹出层>选择产品套餐>选择产品套餐份数弹出层：套餐份数应该默认为“1”
		if(setype == '1'){//非选择产品套餐状态
			CrmPopup.findHtmlobj(divid,'numberCopies_radiotr').css('display','none');
		}else{//
			CrmPopup.findHtmlobj(divid,'numberCopies_radiotr').css('display','');
		}
	}
	this.getParentTag = function(obj,tag){//传入对象和tag标签名，递归回去对象上级（或上上级）的tag标签
		var els = '';var tagname = '';
		els = ld(obj).parent();
		tagname = ld(els).get(0).tagName;
		if(tagname.toLowerCase() != tag.toLowerCase()){
			els = this.getParentTag(els,tag);
		}
		return els;
	}
	/**
	 * Ajax封装方法，callback为回掉方法
	 * @author Tujt 2014-11-27
	 */
	this.Ajax = function(data,callback){
		ld("#status").css("display","inline");
		ld.ajax({
			url: 'index.php',
			type:'post',
			data: data,
			success:function(rest){
				ld("#status").css("display","none");
				callback(rest);
			}
		});
	}
}
var bom = new ProductBomEvent();



function bom_edit(entityid,mode)
{
    var entityarr = [];
	var bom_id;
	var curr_row = 0;
	var frommdoule = '';
    
	if(entityid != '')
		entityarr = entityid.split(',');
	var record = parseInt(entityarr[0],10);
	if(record > 0){//获取对应的产品套餐ID
		bom_id = record;
	}else{
		bom_id = '';
	}
	if(document.getElementsByName('curr_row') != undefined){
		curr_row = document.getElementsByName('curr_row')[0].value;
	}
	if(document.getElementsByName('module') != undefined){
		frommdoule = document.getElementsByName('module')[1].value;
	}
    //17084: 快速创建产品套餐弹出层，选择产品后，”含税单价“没有根据”不含税单价“进行计算
    var str_json={"file":'getQcBomInfo','curr_row':curr_row,'frommodule':frommdoule,'setype':'edit','bomid':bom_id,'mode':mode};
    var urlstr = 'index.php?module=Productbom&action=ProductbomAjax';
    ld.ajax({
        type:"POST",
        dataType:'json',
        data:str_json,
        url:urlstr,
        async:false,
        success:function(rest)
        {
            	
					var crmPopupobj=CreatePagePopup.load("","","","LdPopWidth950px",frommdoule,"",'none',"","");
					crmPopupobj.prevshow();
					crmPopupobj.setParams(rest.result.title,'',"","LdPopWidth950px",frommdoule,"","","","");  
					crmPopupobj.quickcreatehtml=rest.result.content;
					crmPopupobj.show(rest.result.content);
					//ld("#qcbomformDiv").html(rest);
					fieldformulaobj.setAllRowEvent();
					//fnvshobj(this, 'qcbomformDiv');//显示快速创建界面
                 
			
        }
        
    });
}
/**
 * 
 * @param
 * @returns
 * @author Tujt 
 */
function bom_save(obj,SaveType){
   var isbomsubmit = 1;
   if(isbomsubmit == 2) return false;//防止重复点击
   var bomid=0;
	//1、判断产品套餐名称必填
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var subject = CrmPopup.findHtmlobj(divid,'subject').val();
	if(this.trim(subject) == ''){
		RemindsMsg("","LdPopWidth400px","","yes","",ld('[name=QcbomEditView] [fldname=subject]').html()+''+arrJsPopLabel.CANOTEMPTY);
		CrmPopup.findHtmlobj(divid,'subject').focus();
		return false;
	}
	isbomsubmit = 2;
	//2、Ajax判断产品套餐名称不能重复
	var urlstring = 'module=Productbom&action=ProductbomAjax&file=Save';
	urlstring += '&check_repeat=subject&check_value='+subject+'';
	if(document.QcbomEditView.record != undefined &&  document.QcbomEditView.record.value > 0){
		bomid = document.QcbomEditView.record.value;
		urlstring += '&record='+bomid+'';
	}
	new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody: urlstring,
			onComplete: function(response) {
				if(response.responseText.indexOf("##REPEAT##")>-1){
					document.QcbomEditView.subject.focus();
					var repeatalert = response.responseText.split('##REPEAT##');
					RemindsMsg("","LdPopWidth400px","","yes","",repeatalert[1]);
					isbomsubmit = 1;
					return false;
				}
				//3.判断是否选中产品
				var rowcnt = document.QcbomEditView.rowcnt.value;
				if(rowcnt > 0){
					for(var i = 1; i<=rowcnt; i++){
						if(CrmPopup.findHtmlobj(divid,'hdnProductId'+i) != undefined && CrmPopup.findHtmlobj(divid,'hdnProductId'+i).val() == ''){
							RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel.PRODUCTNAME+arrJsPopLabel.CANOTEMPTY);
							return false;
						}
					}
					var columnnameValue;
					var subject = document.QcbomEditView.subject.value;
					var productbom_no = document.QcbomEditView.productbom_no.value;
					var assigned_user_id = document.QcbomEditView.assigned_user_id.value;
					//var packageTotal = document.QcbomEditView.packageTotal.value;
                    //editor:gyqX160802  Bug:0022129
                    var packageTotal = ld('#packageTotal').val();
					var urls = 'module=Productbom&action=ProductbomAjax&file=QcBomSave'
					//产品套餐字段
					urls += '&setype=edit&record='+bomid;
					urls += '&subject='+subject;
					urls += '&productbom_no='+productbom_no;
					urls += '&assigned_user_id='+assigned_user_id;
					urls += '&packageTotal='+packageTotal;
					//产品套餐 - 产品明细字段
					if(document.getElementById('productToolField') != undefined){
						var producttoolfield=document.getElementById('productToolField').value.split('::');
						var columnname;
						for(var pi=0;pi<producttoolfield.length;pi++){
							colinfos=producttoolfield[pi].split(':');
							columnname = colinfos[0];
							for(var i = 1; i <= rowcnt; i++){
								if(CrmPopup.findHtmlobj(divid,columnname+i) != undefined && CrmPopup.findHtmlobj(divid,'hidden_rowid_'+i).val() == 0){
									if(columnname == 'productname'){
										var hdnProductIdValue =  CrmPopup.findHtmlobj(divid,'hdnProductId'+i).val();
										urls +='&hdnProductId'+i+'='+hdnProductIdValue;
									}else{
										columnnameValue = CrmPopup.findHtmlobj(divid,columnname+i).val();
										urls +='&'+columnname+i+'='+columnnameValue;
									}
								}	
							}
						}
					}
					urls += '&rowcnt='+rowcnt;
					new Ajax.Request(
						'index.php',
						{
							queue: {
								position: 'end',
								scope: 'command'
							},
							method: 'post',
							postBody: urls,
							onComplete: function(response) {
								if(SaveType == 'SaveAndSelect'){
									//fninvshnew('qcbomformDiv');
									isbomsubmit = 1;
									cancelCrmPopup();//关闭当前层
									//显示套餐分数层
									var crmPopupobj = CrmPopup.load(arrJsPopLabel['NUMBEROFCOPIES'],"", "", "LdPopWidth350px",'Productbom', '', "", "", "");
									var _divs = "<div id='qcbomnumberDiv'><div id='qcbomnumber'><table class='D_pop_bod' border='0' cellpadding='1' cellspacing='1' width='100%'><tbody>";
									_divs += "<tr align='left' style='display:;' id='numberCopies_radiotr' name='numberCopies_radiotr'>";
									_divs += "<td>";
									_divs += "<input class='input-btn-align' type='radio' id='numberCopies_radio_1' name='numberCopies_radio_1' value='1' onclick='bom.copiesRadio(1,\"\");' />&nbsp;"+arrJsPopLabel['SAMENUMBEROFCOPIES'];
									_divs += "&nbsp;&nbsp;<input class='input-btn-align' type='radio' id='numberCopies_radio_2' name='numberCopies_radio_2' value='0' onclick='bom.copiesRadio(0,\""+response.responseText+"\");' />&nbsp;"+arrJsPopLabel['NUMBEROFDIFFERENT'];
									_divs += "</td>";
									_divs += "</tr>";
									_divs += "<tr>";
									_divs += "<td width='20%' style='padding:10px;'>";
									_divs += "<div id='numberCopies_div_1' name='numberCopies_div_1'>";
									_divs += "<font color='red'>*</font>"+arrJsPopLabel['NUMBEROFCOPIES']+':&nbsp;';
									_divs += "<input type='text' id='numberCopies_number' name='numberCopies_number' autocomplete='off'  class='btn-radius-system' style='vertical-align: middle;margin-top: -2px;' onkeyup='this.value=this.value.replace(/\D/g,\"\");' value=1 maxlength='11'>";
									_divs += "</div>";
									_divs += "<div id='numberCopies_div_2' name='numberCopies_div_2' style='display:none;max-height:250px;overflow-y:auto;'>";
									_divs += "<table cellspacing='0' cellpadding='0' border='0' width='100%' name='numberCopies_div_2_table'>";
									_divs += "<tr>";
									_divs += "<td>"+arrJsPopLabel['PRODUCTPACKAGE']+"</td>";
									_divs += "<td><font color='red'>*</font>&nbsp;"+arrJsPopLabel['NUMBEROFCOPIES']+"</td>";
									_divs += "</tr>";
									_divs += "</table>";
									_divs += "</div>";
									_divs += "</td>";
									_divs += "</tr>";
									_divs += "</tbody>";
									_divs += "</table>";
									_divs += "<div class='D_pbtn'>";
									_divs += "<input name='button' class='D_pbtnok' value='"+arrJsPopLabel['CONFIRMED']+"' onclick='bom_selectProductList();' type='button'/>";
									_divs += "<span>&nbsp;</span>";
									_divs += "<input name='button' class='D_pbtncancel' value='"+arrJsPopLabel['CANCEL']+"' onclick='bom.selectcancel();' type='button'/>";
									_divs += "<input type='hidden' id='numberCopies_bomid' name='numberCopies_bomid'/>";
									_divs += "<input type='hidden' id='numberCopies_prodid' name='numberCopies_prodid'/>";
									_divs += "<input type='hidden' id='numberCopies_bomprod' name='numberCopies_bomprod'/>";
									_divs += "</div></div></div>";
									crmPopupobj.show(_divs);
									var curdivid=crmPopupobj.divid;
									CrmPopup.findHtmlobj(curdivid,'numberCopies_bomid').val(response.responseText);
									CrmPopup.findHtmlobj(curdivid,'numberCopies_div_1').show();
									CrmPopup.findHtmlobj(curdivid,'numberCopies_div_2').hide();
									CrmPopup.findHtmlobj(curdivid,'numberCopies_radio_1').attr('checked',true);
									CrmPopup.findHtmlobj(curdivid,'numberCopies_radio_2').attr('checked',false);
									CrmPopup.findHtmlobj(curdivid,'numberCopies_number').val('');
									CrmPopup.findHtmlobj(curdivid,'numberCopies_radiotr').hide('');
								}

								return false;
							}
						}
					);
					if(SaveType != 'SaveAndSelect'){
						//obj.form.submit();
						getListViewEntries_js('Productbom','parenttab=Tools&start=1');//静态刷新最新产品套餐信息
						cancelCrmPopup();
						isbomsubmit = 1;//初始化
					}

				}else{
					RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['PLEASESELECTPRODUCT']);
					isbomsubmit = 1;
					return false;
				}
			}
		}
	);
}
function calcBomTotal(){
	var rowcnt = document.getElementById('rowcnt').value;
	if(rowcnt >= 1){
		var total = 0;
		for(var i=1; i<=rowcnt; i++){
			if(document.getElementById('hidden_rowid_'+i) != undefined && document.getElementById('hidden_rowid_'+i).value == 0){
				var tax_amount = document.getElementById('tax_amount'+i).value;
				total += eval(tax_amount);
			}
		}
		if(total > 0){
			if(document.getElementById('packageTotal') != undefined){
				document.getElementById('packageTotal').value = total.toFixed(2);
			}
			if(document.getElementById('span_packageTotal') != undefined){
				document.getElementById('span_packageTotal').innerHTML = total.toFixed(2);
			}
		}
	}
}
/**
 * 
 * @param
 * @returns
 * @author Tujt 
 */	
var isbomsubmit = 1;
function bom_selectProductList(){
	
	//alert(isbomsubmit);
	if(isbomsubmit == 2) return false;//防止重复点击
	isbomsubmit = 2;
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var prevpopupobj=CrmPopup.getPopupObj('lastprev');
    var prevdivid=prevpopupobj.divid;
	var bomid = CrmPopup.findHtmlobj(divid,'numberCopies_bomid').val();
	var productid = CrmPopup.findHtmlobj(divid,'numberCopies_prodid').val();
	//alert(bomid);
	if(bomid != ''){//传入产品ID，单选产品套餐模式
		var bomqty = {};var bom_bool = 0;var numcopies = 0;
		if(CrmPopup.findHtmlobj(divid,'numberCopies_radio_1').is(":checked")){//相同份数
			var nc_number = CrmPopup.findHtmlobj(divid,'numberCopies_number').val();
			if(nc_number == ''){
				RemindsMsg("","LdPopWidth400px","","yes","",ld('#qcbomnumberDiv .D_ptita').html()+''+arrJsPopLabel.CANOTEMPTY);
				CrmPopup.findHtmlobj(divid,'numberCopies_number').focus();
				isbomsubmit = 1;
				return false;
			}
			nc_number = parseFloat(nc_number);
			if(nc_number <= 0){
				RemindsMsg("","LdPopWidth400px","","yes","",ld('#qcbomnumberDiv .D_ptita').html()+''+arrJsPopLabel.Must_number_greater_than_0);
				ld('#numberCopies_number').focus();
				isbomsubmit = 1;
				return false;
			}
			numcopies = 1;
		}else{
			ld('#numberCopies_div_2 table [name=numberCopies_bomnamenum]').each(function(){
				if(ld(this).val() == ''){
					RemindsMsg("","LdPopWidth400px","","yes","",ld('#qcbomnumberDiv .D_ptita').html()+''+arrJsPopLabel.CANOTEMPTY);
					ld(this).focus();bom_bool = 1;
					return false;//跳出本次循环，类似于break
				}else if(ld(this).val() > 0)//数量必须大于0
					bomqty[ld(this).attr('bomid')] = ld(this).val();
				else{
					RemindsMsg("","LdPopWidth400px","","yes","",ld('#qcbomnumberDiv .D_ptita').html()+''+arrJsPopLabel.Must_number_greater_than_0);
					ld(this).focus();bom_bool = 1;
					return false;//跳出本次循环，类似于break
				}
			});
			if(bom_bool == 1){
				isbomsubmit = 1;
				return false;
			}
			numcopies = 2;
		}
		if(numcopies == 0) return false;
		var urlstr = 'module=Productbom&action=ProductbomAjax&file=getQcBomInfo';
		urlstr += '&setype=bomproduct&bomid='+bomid;
		//alert(urlstr);
		//alert(CrmPopup.findHtmlobj(prevdivid,'returnmodule').val());
		if(CrmPopup.findHtmlobj(prevdivid,'return_module').val() != undefined){
			urlstr += '&returnmodule='+CrmPopup.findHtmlobj(prevdivid,'return_module').val();
		}
		
		if(CrmPopup.findHtmlobj(prevdivid,'curr_row').val() != undefined){
			urlstr += '&curr_row='+CrmPopup.findHtmlobj(prevdivid,'curr_row').val();
		}
		var bom_total = 0;//套餐售价
		var total = 0;
		if(CrmPopup.findHtmlobj(prevdivid,'total').val() != undefined){
			total = CrmPopup.findHtmlobj('div_pagerecord','total').val();
		}
		new Ajax.Request(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody: urlstr,
				onComplete: function(response) {
					if(response.responseText != ''){
						var restobj = eval('('+ response.responseText +')')?eval('('+ response.responseText +')'):JSON.parse(response.responseText);
						y = 0;
						var mod =  CrmPopup.findHtmlobj('div_pagerecord','module').val();
						var nc_number = CrmPopup.findHtmlobj(divid,'numberCopies_number').val();//份数
						ld.each(restobj,function(entityid,entityobj){//循环产品信息，并添加到页面上

							var prod_array = entityobj.vt_prod_arr;
							if(y>0) {
								var row_id = fnAddProductRow(mod);
							} else {
								var row_id = ld('#curr_row').val();//#bom_curr_row
							}
							for (var columnname in prod_array) {
								if(CrmPopup.findHtmlobj('div_pagerecord',columnname+row_id).val() != undefined && columnname != 'comment'){
									if(columnname == 'quantity'){
										if(numcopies == 1){//相同份数
											if(nc_number > 0 && prod_array['quantity'] > 0){
												prod_array['quantity'] = nc_number * prod_array['quantity'];
											}
										}else{//不同份数
											if(bomqty[prod_array['bom_id']] > 0 && prod_array['quantity'] > 0){
												prod_array['quantity'] = bomqty[prod_array['bom_id']] * prod_array['quantity'];
											}else{
												prod_array['quantity'] = nc_number * prod_array['quantity'];
											}
										}
									}
									if(CrmPopup.findHtmlobj('div_pagerecord','span_'+columnname+row_id).html() != undefined){
										CrmPopup.findHtmlobj('div_pagerecord','span_'+columnname+row_id).html(decodeURIComponent(prod_array[columnname]));
									}
									CrmPopup.findHtmlobj('div_pagerecord',columnname+row_id).val(decodeURIComponent(prod_array[columnname]));
								}
								if(columnname == 'productname'){
									CrmPopup.findHtmlobj('div_pagerecord','productname'+row_id).attr("disabled",true); 
									CrmPopup.findHtmlobj('div_pagerecord','productname'+row_id).css("cursor",'not-allowed');
								}
								if(columnname == 'product_desc' && CrmPopup.findHtmlobj('div_pagerecord','comment'+row_id).html() != undefined){
									var product_desc = prod_array['bom_name'] +'('+ prod_array['bom_total'] +'*'+ prod_array['quantity']+')';
									CrmPopup.findHtmlobj('div_pagerecord','comment'+row_id).html(decodeURIComponent(product_desc));
								}
								if(columnname == 'bom_total'){
									if(numcopies == 1){//相同份数
										bom_total = prod_array[columnname] * nc_number;
									}else{
										bom_total = prod_array[columnname] * bomqty[prod_array['bom_id']];
									}
								}
								
							}
							
							y=y+1;
						});
						fieldformulaobj.changetaxprice();
						if(CrmPopup.findHtmlobj('div_pagerecord','total').val() != undefined){
							CrmPopup.findHtmlobj('div_pagerecord','total').val(eval(total) + eval(bom_total))
							calcGrandTotal();
						}

					}
					popupobj.CancelEvent();
					prevpopupobj.CancelEvent();
				}
			}
		);

	}
}