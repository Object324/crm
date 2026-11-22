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

document.write("<script type='text/javascript' src='include/js/Inventory.js'></"+"script>");
function set_checks_presence(stockid,persence,type)
{
    if(type == 0 && persence == 1)
    {
        window.location.href="index.php?action=DetailView&module=Checks&parenttab=Checks&record="+stockid+"&power=false"; 
        return false;
    }
    if(persence == 1)
    {
        ld.ajax('index.php?module=Checks&action=ChecksAjax&file=checkProducts&recordid='+stockid+'&persence='+persence)
        .done(function(productinfo){
            
            if(productinfo != ""&&productinfo.indexOf("||")>0)
            {
                //盘点单中部分产品的库存数量已变更，其中：
                //请重新选择上述产品，或者执行\"调入当前库存\"，操作后重新盘点
                var productarray = productinfo.split('||');
                var productstr='';
                for(var i = 0; i<productarray.length; i++){
                    productstr += productarray[i] + "\n" ;
                }
                var confirm_str = arrJsPopLabel['CHECKNUMBERHAVECHANGED']+"\n"+ productstr + "\n" + arrJsPopLabel['PLEASETHESEPRODUCTS'] + '。';
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                return false;
            }
             //确定盘点吗？
            var confirm_str = arrJsPopLabel['DETERMINEINVENTORY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            //点击确认
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                check_url(stockid,persence);
            });
            return false;
        })          
    }
    else
    {
        //执行后，该盘点单将被还原到“盘点中”状态，库存数量还原到盘点前。确定要撤销盘点吗？
        var confirm_str = arrJsPopLabel['PREVIOUSINVENTORYSTOCKQUANTITY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        //点击确认
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
            check_url(stockid,persence);
        }); 
    }

}
function check_url(stockid,persence){
	new Ajax.Request("index.php",
		{
			queue:{
				position:"end",
				scope:"command"
			},
			method:"post",
			postBody:"action=DetailView&module=Checks&parenttab=Stock&record="+stockid+"&salestype=yes&setstock=true",
			onComplete:function (response) {
			  if(persence != 1 && document.DetailView == undefined)
			  {
				window.location.href="index.php?action=ListView&module=Checks&parenttab=Stock"; 
			  }
			  else
			  {
			   window.location.href="index.php?action=DetailView&module=Checks&parenttab=Stock&record="+stockid+"&salestype=yes"; 
			  }
			  
			}
		}
	);
}
function getWarehouse(warehouseid,obj,type){
    	if(obj!=null){
        var classmethods = $$('.on');
        for(var i=0;i<classmethods.length;i++){
        classmethods[i].className = 'on';
        }
        obj.className='on On';

        }
		$('wareid').value=warehouseid; 
        getListViewEntries_js('Checks');
         if(document.getElementById('morewarehouseid')!=undefined)
    {
        ld('morewarehouseid').className='';   
    }
	if(ld('#ware_select_more') != undefined){
		ld('#ware_select_more').removeClass('On');
		ld('#cmb_span_optiontext_selectwareid').html('');
	}
        
}
function getMoreWarehouse(obj,id){
    var classmethods = $$('.on');
    var warehouseid=obj.value;
    if(warehouseid==''){
        //19330: 库存>出库单列表界面：全部仓库切换到更多选择“仓库数量”，然后在选择空白的，界面会闪下undefind
        //您没有这个仓库的权限！
        //alert(arrJsPopLabel['NOHAVEPERMISSIONWAREHOUSE']);
        return false;
    }
    for(var i=0;i<classmethods.length;i++){
        classmethods[i].className = 'on';
        }
        $(id).className='On';
        getListViewEntries_js('Checks','start=1&wareid='+warehouseid);        
        $('wareid').value=warehouseid; 
		ld('#ware_select_more').addClass('On');
}
function CheckMassedit(idlist,module,parenttab,smowner,obj,divid,stype)
{   
    var url="";
    if(typeof(parenttab) == 'undefined') parenttab = '';
	var excludedRecords=document.getElementById("excludedRecords").value;
	var viewid =getviewId();
    
    var searchScope= encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
    
      new Ajax.Request(
				'index.php',
				{
					queue: {
						position: 'end',
						scope: 'command'
					},
					method: 'post',
					postBody:"module=Checks&action=ChecksConfirm&type=check&&parenttab="+encodeURIComponent(parenttab)
            +"&idlist="+idlist+"&viewname="+viewid+"&excludedRecords="+excludedRecords+"&smowner="+smowner+"&SearchScope="+searchScope+url,
					onComplete: function(response) {
					        if(response.responseText.indexOf("#####:success")>-1)
                            {
                               mass_edit_formload(idlist,module,parenttab,smowner,obj,divid);
                            	
                            }
                            else 
                            {
                                //您选择的记录有已付款或者部分已付款的单据，删除失败！
                                getJsScript('include/js/ListViewButton.js',function(){
                                    if(stype!=''){
                                        var confirm_str = arrJsPopLabel['YOUCHOOSETOHAVEALREADYCOUNTEDEDIT'];
                                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                                    }else{
                                        var confirm_str = arrJsPopLabel['TDHBCYCNE'];
                                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                                    }
                                    $("status").style.display="none";
                                });
                                return false;
                            }
					}
				}
				);
}


/**
*edit:chj
date:2013-12-25
reason:编辑保存盘点时，判断产品的当前库存数量是否等于上次盘算时的数量
**/

var iserror=true;
function ChecksProduct()
{
    /*
    edit:can
    date:20140103
    reason:6648: 盘点编辑界面保存：编辑保存判断账面数量和库存数量不一致后，再重新选择产品使得账面数量和库存数量一致后保存无法保存，一直提示部分产品的库存数量已变更
    */
    var popupobj=CrmPopup.getPopupObj("last");
    
    var max_row_count = document.getElementById('proTab').rows.length;
    max_row_count = parseInt(document.getElementById('rowcnt').value);//As the table has two header rows, we will reduce two from table row length
    
    var wareid=document.getElementById('wareid').options[document.getElementById('wareid').selectedIndex].value;//仓库id
    var batchtexturls="index.php?module=Products&action=ProductsAjax&file=getbatchquantity";
    var batchtexturl="";
    var productbatchtexturl="";
    var pagehavebatchtextrowindex=new Array();//有批次的行号
    var productbatchquantity=new Array();
   for(var i=1;i<=max_row_count;i++)
   {
      
       if(document.getElementById('paperquantity'+i)==undefined)
            break;
        var productid=ld("#hdnProductId"+i).val();
              
        if(document.getElementById("batchtext"+i)!=undefined&&productid>0)
        {
                   
                        //不用根据产品是否启用判断，如果产品启用批次管理，但是出入库界面批次字段被关闭，这种情况不做提示
                        if(ld("#batchtext"+i).css("display")!='none')
                        {
                            pagehavebatchtextrowindex.push(i);
                            
                            if(max_row_count==i)
                            {
                                batchtexturl+=trim(ld("#batchtext"+i).val());
                               productbatchtexturl+=productid;
                            }
                            else
                            {
                                batchtexturl+=trim(ld("#batchtext"+i).val())+"##";
                               productbatchtexturl+=productid+",";
                            }
                         
                           if(trim(ld("#batchtext"+i).val())=='')
                           {
                             if(language=='zh-cn')
                                audioRemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['LINE']+i+arrJsPopLabel['row']+'批次'+arrJsPopLabel['CANOTEMPTY']);
                             else
                                audioRemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['LINE']+i+" "+'批次'+arrJsPopLabel['CANOTEMPTY']);
                            return false;
                           }
                           var tmpbatchtext=trim(ld("#batchtext"+i).val());
                           //界面可以输入相同的产品和批次，所以判断数量
                           if(productbatchquantity[productid]==undefined||productbatchquantity[productid]=='undefined')
                           {
                                productbatchquantity[productid]=new Array();
                                productbatchquantity[productid][tmpbatchtext]=new Array();
                                productbatchquantity[productid][tmpbatchtext]=ld("#firmoffer"+i).val();
                           }
                           else
                           {
                                productbatchquantity[productid][tmpbatchtext]+=parseFloat(ld("#firmoffer"+i).val());
                           }
                        }
                        
        }
       var paperquantity=document.getElementById('paperquantity'+i).value;
       var productid=document.getElementById('hdnProductId'+i).value;
	   if(tmpbatchtext == undefined)tmpbatchtext = '';
        var url="index.php?module=Checks&action=ChecksfirmofferCount&hdnProductId="+productid+"&ReportHeader=DHeader&ware="+wareid+"&paperquantity="+paperquantity;
        httpreq=createfieldXMLHTTP();
        httpreq.open("POST",url,false);
        isDuplicate=false;
        httpreq.onreadystatechange=ChecksCountRequest;
        httpreq.setRequestHeader("If-Modified-Since","0");
        httpreq.send(null);
        if(!iserror)
        {
            iserror=true;
            return false;
        }
   }
   
    batchtexturls+="&batchtexts="+batchtexturl+"&productids="+productbatchtexturl+"&id="+popupobj.record;
   
    var lengthdecimaldigits=document.getElementById("lengthdecimaldigits").value;
    var error_info="";
    /*
    if(batchtexturl!="")
    {
        ld.ajax({
					url: batchtexturls,
					type: 'POST',
					data:'',
					dataType: 'json',
					async: false,
					timeout: 5000,
					
					success: function(data)
					{   var error=false;
						ld.each(pagehavebatchtextrowindex,function(rowindex,key){
						  
                             var tmpproductid=ld("#hdnProductId"+key).val();
                             var tmpbatchtext=ld("#batchtext"+key).val();
                            // var tmpquantity=parseFloat(parseFloat(ld("#quantity"+key).val()).toFixed(lengthdecimaldigits));
                            //界面输入的产品数量
                             var tmpquantity=parseFloat(productbatchquantity[tmpproductid][tmpbatchtext]);
                             //产品在数据库剩余的数量
                            var  databasequantity=parseFloat(data.result[tmpproductid][tmpbatchtext]);
                            
                             if(tmpquantity>databasequantity)
                             {
                              
                                error_info+=ld("#productname"+key).val()+arrJsPopLabel['QUANTITYMORTHANCURRENTROWBATCH']+"\n";
                                
                             }
                          
						})
                       
                        if(error_info!="")
                        {
                            alert(error_info);
                            return false;
                        }
					}
	       });
        
    }*/
   
    if(error_info!="")
    {
        return false;
        
    }  
   
    return false;  
   return true;
}
function ChecksCountRequest()
{
    if(httpreq.readyState==4)
    {
        if(httpreq.status==0||httpreq.status==200)
        {
                var str=httpreq.responseText;
            	if(str.indexOf('###SUCCESS###') <= -1)
                {
                    var results=str.split('###ERROR###');
                    lingdangJS_DialogBox.unblock();	
                    alert(results[1]);
                    iserror=false;
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
function setProductQtyInstock(obj){
	var rowcnt = 0;
	var productStr='';
	var surl='';
	var productArray = new Array();
	if(document.getElementById('rowcnt') != undefined && document.getElementById('rowcnt').value >=1){
		rowcnt = document.getElementById('rowcnt').value;
		for(var i=1; i<=rowcnt; i++){
			if(document.getElementById('hidden_rowid_'+i) != undefined && document.getElementById('hidden_rowid_'+i).value == 0){
				if(document.getElementById('hdnProductId'+i) != undefined && document.getElementById('hdnProductId'+i).value > 0){
					productStr +=document.getElementById('hdnProductId'+i).value +',';
					productArray[document.getElementById('hdnProductId'+i).value] = i;
				}
			}
		}
		if(productStr != ''){
			surl = "module=Checks&action=ChecksConfirm&type=getProductQtyInstock&wareid="+obj.value+"&productstr="+productStr;
		}
		//alert(surl);
		new Ajax.Request(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody:surl,
				onComplete: function(response) {
					if(response.responseText.indexOf("success:")>-1){
						var results = response.responseText.split("success:");
						var proStr = results[1].split(',');
						for(var i = 0; i<proStr.length; i++){
							//alert(proStr[i]);
							var productQty = proStr[i].split('|');
							var productId = productQty[0];
							var productQtyInstock =productQty[1];
							var rowid = productArray[productId];
							if(document.getElementById('paperquantity'+rowid) != undefined){
								document.getElementById('paperquantity'+rowid).value = productQtyInstock;
								document.getElementById('span_paperquantity'+rowid).innerHTML = productQtyInstock;
								 fieldformulaobj.CountRowFormulaColumn(rowid);
								 fieldformulaobj.CountsubTotal();
							}
						}
						
					}
				}
			}
		);
	}
}