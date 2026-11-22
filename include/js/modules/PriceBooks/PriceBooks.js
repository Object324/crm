/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *
 ********************************************************************************/

prod_array = new Array();
function addtopricebook()
{
  
    var popupobj=CrmPopup.getPopupObj('last');
     var detailpopupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
	if(document.addToPB.selected_id != undefined){
		var idstring='';
		var y=0;
		var x = document.addToPB.selected_id.length;
		//再次选择时
		if(x == undefined){
			cnt= 2;
			idstring = document.addToPB.selected_id.value;
			y = 1;
		}else{
			for(i = 0; i < x ; i++) {
				//获取选中的产品id
				if(document.addToPB.selected_id[i].checked) {
					idstring = document.addToPB.selected_id[i].value+";"+idstring;
					y = y + 1;
				}
			}
			cnt = 1;
		}
	}
	if (y != 0) {
		document.addToPB.idlist.value=idstring;
	}else{
		var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
   
    var urlstring="index.php?module=Products&action=ProductsAjax&file=addPbProductRelToDB";
    
    var chkboxobjs=ld("#"+popupobj.divid+" input[type=checkbox]");
    
    ld.each(chkboxobjs,function(){
        if(ld(this).prop("checked")){
            var product_id=ld(this).attr("value");
            urlstring+="&"+product_id+"_listprice="+ld("#"+popupobj.divid+" [name="+product_id+"_listprice]").val();
            
        }
    })
    var lastprevpopupobj=CrmPopup.getPopupObj('lastprev');
    urlstring+='&idlist='+idstring+"&pricebook_id="+detailpopupobj.record;
    
    //var params={'idlist':idlist,'pricebook_id':detailpopupobj.record};
    ldAjax(urlstring,{},function(data){
            popupobj.CancelEvent();
            DetailViewRelation.searchByPopupobj(lastprevpopupobj);
            DelProgressObjs();
            
    })
   
	//document.addToPB.action="index.php?module=Products&action=ProductsAjax&file=addPbProductRelToDB&return_module=Products&return_action=AddProductsToPriceBook";
}

function updateListPrice(unitprice,fieldname,oSelect)
{
	if(oSelect.checked == true)
	{
		document.getElementById(fieldname).style.visibility = 'visible';
		document.getElementById(fieldname).value = unitprice;
	}else
	{
		document.getElementById(fieldname).style.visibility = 'hidden';
	}
}

function check4null(form)
{
	var isError = false;
	var errorMessage = "";
	if (trim(form.productname.value) =='') 
	{
		isError = true;
		errorMessage += "\n Product Name";
		form.productname.focus();
	}
	if (isError == true) 
	{
		var confirm_str = arrJsPopLabel['CANOTEMPTY'] + errorMessage;
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
	return true;
}



function set_return_specific(vendor_id, vendor_name) 
{
        //getOpenerObj used for DetailView 
        var fldName = getOpenerObj("vendors_name");
        var fldId = getOpenerObj("vendor_id");
        fldName.value = vendor_name;
        fldId.value = vendor_id;
}

function deletePriceBookProductRel(id,pbid)
{
	var confirm_str = arrJsPopLabel['AREYOUSUREYOUWANTTOCANCELTHECONNECTION'];
	MessagePopup.TipTwo_warning(confirm_str);
    //确定按钮
    var messagePopup = CrmPopup.getPopupObj('last');
    ld('#'+messagePopup.divid+' input[tagclick="msgConfirm"]').off('click').on('click',function(){
        var url = 'index.php?module=Products&action=ProductsAjax&file=DeletePriceBookProductRel&ajax=true&return_action=CallRelatedList&return_module=PriceBooks&record='+id+'&pricebook_id='+pbid+'&return_id='+pbid;
        ldAjaxNoProgress(url,'',function (data){
            var popupobj=CrmPopup.getPopupObj('last');
            DetailViewRelation.searchByPopupobj(popupobj);
        })
    });
    return ;
}
function verify_data()
{
    var tmpobj=new Object();
    tmpobj.divid="editlistprice";
    CrmPopup.global_listPopupObj.push(tmpobj);
	var returnValue = true;
	var list_price = $('list_price');
        if(list_price.value != '' && list_price.value != 0)
        {
                 intval= intValidate('list_price','EditListPrice');

                if(!intval)
                {
                        returnValue =  false;
                }
               
        }
        else
        {
		if(list_price.value == '')
		{
			var confirm_str = arrJsPopLabel['WHOLESALEPRICECANOTEMPTY'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			returnValue = false;
		}
        }
	return returnValue;

}


function updateAllListPrice()
{
    var popupobj=CrmPopup.getPopupObj("last");
    
	var unitprice_array = popupobj.unit_price
	var fieldname_array = popupobj.field_name;

	var n=unitprice_array.length;	
	var unitprice,fieldname;
	var id;
	var fieldinfo;
	var checkid;

	for(j=0; j<unitprice_array.length; j++)
	{
		fieldinfo = fieldname_array[j].split("_");
		id = fieldinfo[0];
		checkid = "check_"+id;
      
		unitprice=unitprice_array[j];
		fieldname=fieldname_array[j];	
		updateListPrice(unitprice,fieldname,document.getElementById(checkid));
	}
}

function updateListPriceForField(fieldname,element)
{

     var popupobj=CrmPopup.getPopupObj("last");
    
	var unitprice_array = popupobj.unit_price
	var fieldname_array = popupobj.field_name;

	var index = fieldname_array.indexOf(fieldname);
    
	updateListPrice(unitprice_array[index],fieldname,element);
}

function fun_ProductPriceBooks()
{
    var that=this;
    this.startpage=1;
    this.searchtype="";
    that.pageclick='no';//是否点击的分页
    this.basicsearch_field="";
    this.basicsearch_content="";
    this.init=function()
    {
        this.startpage=1;
        this.searchtype="";
        that.pageclick='no';//是否点击的分页
        this.basicsearch_field="";
        this.basicsearch_content="";
    }
    this.highsearch=function()
    {
        that.searchtype='Advanced';
        that.pageclick='no';
        that.search();
    }
    this.basicsearch=function(){
        //wym BUG0073276 价格表相关信息选择产品界面，“基本查找”显示效果优化 基本查找没有弹窗了，pageclick属性修改为yes
        that.pageclick='yes';
        that.searchtype='Basic';
        that.search();
    }
    this.search=function()
    {
        //alert('wwww');
        var detailviewpopupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);//查看界面
       	var popupobj=CrmPopup.getPopupObj("last");
        var lastprevpopup=CrmPopup.getPopupObj('lastprev');
        
      	  var divid=popupobj.divid;
         var urlstring = 'module=Products&action=ProductsAjax&ajax=yes&search=true&start='+that.startpage;
         urlstring+="&file=AddProductsToPriceBook";
        if(that.searchtype == 'Basic')
        {
        
            that.basicsearch_field=ld("#"+popupobj.divid+" [name=search_field]").val();
            that.basicsearch_content=ld("#"+popupobj.divid+" [name=search_text]").val();
    		urlstring += '&search_field='+that.basicsearch_field+'&searchtype=BasicSearch&search_text='+encodeURIComponent(that.basicsearch_content);
             urlstring+="&query=true"
             lastprevpopup.advft_criteria="";
             lastprevpopup.advft_criteria_groups="";
           
             ld("#"+lastprevpopup.divid+" [name=search_text]").val(that.basicsearch_content);
        }
        else if(that.searchtype=='Advanced')
        {
       	    that.basicsearch_field="";
            that.basicsearch_content="";
            if(!New_checkAdvancedFilter()) return false;
                var advft_criteria =popupobj.advft_criteria;
                var advft_criteria_groups = popupobj.advft_criteria_groups;
                      
                lastprevpopup.advft_criteria=advft_criteria;
                lastprevpopup.advft_criteria_groups=advft_criteria_groups;
              
    		urlstring += '&advft_criteria='+encodeURIComponent(advft_criteria)+'&advft_criteria_groups='+advft_criteria_groups;
            urlstring += '&searchtype=advance';
            urlstring+="&query=true";
            
        }
  		urlstring += '&pricebook_id='+detailviewpopupobj.record;
 
        ld.ajax({
            type:'post',
            dataType:"json",
            timeout:30000,
            url:"index.php?"+urlstring,
            success:function(data){
                
                    if(that.pageclick!='yes'&&that.searchtype!="")
                        CrmPopup.getPopupObj('last').CancelEvent();
                    //zkt 20220601 0052133价格表查看详情界面，相关信息->选择产品管理界面，翻到第二页，全选单据时，“单价”字段没有显示编辑框
                    if(popupobj !=undefined&&popupobj.module == 'PriceBooks'&&popupobj.type == 'selectsearchdetail'){
                        
                        popupobj.unit_price=data.result.UNIT_PRICE_ARRAY;
                        popupobj.field_name=data.result.FIELD_NAME_ARRAY;
                    }
                    
                     that.pageclick='no';  
                    //}
                        var prevpopupobj=CrmPopup.getPopupObj('last');
                       
    				    CrmPopup.findHtmlobj(prevpopupobj.divid,'ListViewContents').html(data.result.content);
                      
                        CrmPopup.findHtmlobj(prevpopupobj.divid,'navigationoutput').html(data.result.navigationoutput);
                        prevpopupobj.center();
                       
                
            }
            
        })
    }
    this.search.tagname='ProductPriceBooks.getInstance().search';
    this.basicsearchpop=function()
    {
        //基本查询的弹出层
        var detailpopupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
        var lastpopupobj=CrmPopup.getPopupObj("last");//选择产品的弹出层
        getJsScript("include/js/SystemPopup/ListBasicSearchPopup.js",function(){
           ld.each(lastpopupobj.basicsearchheaders,function(tmpindex,tmpinfo){
                var optionhtml="<option value='"+tmpinfo.columnname+"'>"+tmpinfo.fieldlabel+"</option>";
                ld("#"+lastpopupobj.divid+" [name=search_field]").append(optionhtml);
           })
            var Popupobj=new ListBasicSearchPopup.load("",fun_ProductPriceBooks.getInstance().basicsearch,"","LdPopWidth400px",detailpopupobj.module,"",btn_findnow_label,"","");
            Popupobj.show(ld("#"+lastpopupobj.divid+" [name=dv_listbasicsearch]").html());
        });
    }

    this.advancesearchpop=function()
    {
        //showPopupHighSearch
        //高级查询的弹出层
        global_showPopupHighSearch(fun_ProductPriceBooks.getInstance().highsearch);
        var Popupobj=CrmPopup.getPopupObj('last');

    }
    this.getProductsPricebookList_js=function(start)
    {
        //分页
        this.startpage=start;
        this.pageclick='yes';
        var popupobj=CrmPopup.getPopupObj('last');
        ld("#"+popupobj.divid+' [name=pagenum]').val(start);
        that.search();
    }
    
    this.searchRelatedProductsByEnter=function(obj,event)
    {
        if(event.keyCode==13) {
            that.searchRelatedProducts();
        }else {
            var popupobj = CrmPopup.getlastPopupObjByType(RelateListPage.type);
            var clearSearchBtnobj = ld('#'+popupobj.divid+' [name=clearSearchBtn]');
            if (clearSearchBtnobj.length > 0){
                var value = ld(obj).val();
                if (empty(value)){
                    clearSearchBtnobj.css('display','none');
                }else {
                    clearSearchBtnobj.css('display','');
                }
            }
        }
    }
    this.searchRelatedProducts = function () {
        var popupobj = CrmPopup.getlastPopupObjByType(RelateListPage.type);
        var relatedPopupBasicSearchDivobj = ld('#'+popupobj.divid+' #basicSearchNewDiv');
        popupobj.search_field = relatedPopupBasicSearchDivobj.find('[name=search_field]').val();
        popupobj.search_text = relatedPopupBasicSearchDivobj.find('[name=search_text]').val();
        popupobj.searchtype = 'basic';
        DetailViewRelation.searchByPopupobj(popupobj)
    }
  
}
fun_ProductPriceBooks.getInstance=function()
{
    //获取价格表查看界面的
    var popupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
    if(popupobj.productpricebooksobj==undefined)
    {
        popupobj.productpricebooksobj=new fun_ProductPriceBooks();
    }
    return popupobj.productpricebooksobj;
    
}
/**/

