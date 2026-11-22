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

 var select_id = {};
  /** 服务单 - 选择常见问题  - 弹出层特殊控制展示JS
   * @param 
   * @returns 
   * @author Chj 
   */
	function showrelatedspeciallists(module,selectmodule,type,PopupButton){
		getJsScript('include/js/SystemPopup/FaqPopup.js',function(){
			ld.ajax({
				url: 'index.php?module=Users&action=UsersAjax&file=select_related_special_popu&ajax=true&selectmodule='+selectmodule+'&frommodule='+module,
				type: 'POST',
				data:'',
				dataType:'json',
				async: true,//
				timeout: 5000,
				error: function(XMLHttpRequest, textStatus, errorThrown) {
						
				   },
				success: function(data)
				{ 
					$("status").style.display="none";
					if(data.code==1)
					{
						var FaqPopupObj=FaqPopup.load(data.result.title,SubmitFaqBtn,"","LdPopWidth800px",'Faq',"",data.result.oktext,"",data.result.canceltext);
						FaqPopupObj.refreshpage='yes';
						FaqPopupObj.show(data.result.content); 
					}
				}
			});
		});
		return false;
	}
	/**
	 * 服务单 - 选择常见问题。 点击问题类别，获取级联关系的常见问题选项
	 * @param obj:问题类别checkxbox对象 module 当前模块  selectmodule 选择模块
	 * @returns
	 * @author Chj 
	 */
	function getFaqTypeValue(obj,module,selectmodule){
		var obj = document.getElementsByName(obj.name);
		if(obj){
			var select_faqcategory = new Array();//目前已勾选的所有问题类别
			var picklisttype;
			//获取已勾选的问题类别
			for (var i=0,n=0; i<obj.length;i++) {
				if(obj[i].checked == true){
					select_faqcategory[n] = obj[i].value;
					n++;
				}
			}
			//获取已勾选的常见问题
			if(document.getElementsByName("select_faqtype") != undefined){
				var faqtype = document.getElementsByName('select_faqtype');
				var select_faqtype = new Array();//已选的常见问题选项
				for(var i=0,k=0;i<faqtype.length;i++){
					if(faqtype[i].checked == true){
						select_faqtype[k] = faqtype[i].value;
						k++;
					}
				}
			}
			//获取问题类别和常见问题之间是否存在级联关系
			//如果不存在级联关系，当问题类别都不选中的情况下，默认显示全部    0 没有关系  1 有关系
			if(document.getElementById('picklisttype') != undefined){
				picklisttype = document.getElementById('picklisttype').value;
			}
			if(select_faqcategory.length >= 1 || picklisttype == 0){
				if(document.getElementById('faqtype_Style') != undefined){
					var url_str = 'module=Users&action=UsersAjax&file=select_related_special_popu&selectmodule='+selectmodule+'&frommodule='+module;
					url_str +='&category_type=true&faqcategory_name='+select_faqcategory.join('|');
					url_str +='&select_faqtype='+select_faqtype.join('|');
					new Ajax.Request(
					'index.php',
					{queue: {position: 'end', scope: 'command'},
						method: 'post',
						postBody: url_str,
						onComplete: function(response) {
							var results=response.responseText.split("##SUCCESS##");
							$("status").style.display="none";
                           
							if(results[0] == 1){ //判断是否有内容
                          
								document.getElementById('faqtype_Style').style.display="";
								var popupobj=CrmPopup.getPopupObj("last");
								var divid=popupobj.divid;
								CrmPopup.findHtmlobj(divid,'ListViewFaqtype').html(results[1]);
								getListViewFaqType(module,selectmodule);
							}else{
								setFaqContentDisplay('none');
								document.getElementById('faqtype_Style').style.display="none";
							}
						}
					});
				}
			}else{
				//如果没有选择任何的问题类别，则隐藏常见问题div
				if(document.getElementById('faqtype_Style') != undefined){
					document.getElementById('faqtype_Style').style.display="none";
				}
				//隐藏问题列表和问题描述、解决方法
				setFaqContentDisplay('none');
			}
		}
	}
	/**
	 * 服务单 - 选择常见问题 - 全选
	 * @param obj:常见问题对象的checked属性 relCheckName问题对象的name属性  selectmodule 选择模块
	 * @returns
	 * @author Chj 
	 */
	function toggleSelect_Faq(state,relCheckName,selectmodule){
		//获取当前页数
		var page;
		var new_select_id = {};
		if(document.getElementById('faq_page') != undefined){
			page = document.getElementById('faq_page').value;
		}
		//var obj = document.getElementsByName(relCheckName);
        var obj=ld("#contents_Style input[name=selected_id]");
		if (obj) {
			var ids = new Array();
			var n = 0;
			setFaqValue(selectmodule,ids,'Select');//每次全选时  清空问题和解决办法
			ld.each(select_id,function(faqid,pstart){
				if(page != pstart){
					new_select_id[faqid]=pstart;
					ids[n] = faqid;
					n++;
				}
			});
            
			for (var i=0;i<obj.length;i++) {
				obj[i].checked=state;
				if(obj[i].checked == true){
					new_select_id[obj[i].value]=page;
					ids[n] = obj[i].value;
					n++;
				}
			}
			select_id = {};
			select_id = new_select_id;
 			setFaqValue(selectmodule,ids,'Select');
			//赋值  已选的常见问题id
			if(document.getElementById('faqid_string') != undefined){
				document.getElementById('faqid_string').value = ids.join(',');
			}
		}
	}
	/**
	 * 
	 * @param 问题描述  解决办法  赋值
	 * @returns
	 * @author Tujt 
	 */
	function setFaqValue(selectmodule,ids,select_type){
		
		var popupobj=CrmPopup.getPopupObj("last");
		var divid=popupobj.divid;
	   if(ids.length > 0){
		    var faqNo = 1;
			var idstring = ids.join(',');
			var url_str = 'module='+selectmodule+'&action='+selectmodule+'Ajax&file=getFaqQuestion&idstring='+idstring+'&select_type='+select_type;
			 //获取已选记录
			if(document.getElementById('faqid_string') != undefined){
				if(document.getElementById('faqid_string').value != ''){
					var faqid_string = document.getElementById('faqid_string').value;
					var faqid_arr = faqid_string.split(',');
					faqNo = faqid_arr.length;
				}
			}
			url_str += '&faqNo='+faqNo;
			//alert(url_str);
			new Ajax.Request(
			'index.php',
			{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody: url_str,
				onComplete: function(response) {    
					 var restobj = eval('('+ response.responseText +')')?eval('('+ response.responseText +')'):JSON.parse(response.responseText);
					 //问题描述 赋值
					 if(CrmPopup.findHtmlobj(divid,'question_description').val() != undefined){
						 var question_description = CrmPopup.findHtmlobj(divid,'question_description').val();
						 if(question_description != ''){
							 CrmPopup.findHtmlobj(divid,'question_description').val(question_description+"\r\n"+restobj.question);
						 }else{
							 CrmPopup.findHtmlobj(divid,'question_description').val(restobj.question);
						 }
						
					 }
					 //解决办法 赋值
					 if(CrmPopup.findHtmlobj(divid,'answer').val() != undefined){
						 var answer = CrmPopup.findHtmlobj(divid,'answer').val();
						 if(answer != ''){
							 CrmPopup.findHtmlobj(divid,'answer').val(answer+"\r\n"+restobj.answer);
						 }else{
							 CrmPopup.findHtmlobj(divid,'answer').val(restobj.answer);
						 }
					 }
					 //问题编号 赋值
					 if(CrmPopup.findHtmlobj(divid,'faqno_string').val() != undefined){
						 var faqno_string = CrmPopup.findHtmlobj(divid,'faqno_string').val();
						if(faqno_string != ''){
							 CrmPopup.findHtmlobj(divid,'faqno_string').val(faqno_string+','+restobj.faqno);
						}else{
							CrmPopup.findHtmlobj(divid,'faqno_string').val(restobj.faqno);
						}
					 }
				}
			});
		}else{
			 //清空问题描述
             //22405: 客户服务单>新建：选择常见问题弹出层，勾选常见问题后，再取消。结果：问题描述中还是显示了内容。
			 if(CrmPopup.findHtmlobj(divid,'question_description').val() != undefined){
				CrmPopup.findHtmlobj(divid,'question_description').val('')
			 }
			 //清空解决办法 赋值
			 if(CrmPopup.findHtmlobj(divid,'answer').val() != undefined){
				CrmPopup.findHtmlobj(divid,'answer').val('');
			 }
			 //清空 问题编号
			 if(CrmPopup.findHtmlobj(divid,'faqno_string').val() != undefined){
				CrmPopup.findHtmlobj(divid,'faqno_string').val('');
			 }
			 if(CrmPopup.findHtmlobj(divid,'faqid_string').val() != undefined){
				CrmPopup.findHtmlobj(divid,'faqid_string').val('');
			 }
		}
	}
	/**
	 * 
	 * @param 服务单 - 选择常见问题 - 问题类别单选
	 * @returns
	 * @author Chj 
	 */
	function check_object_faq(obj,selectmodule){
		//获取当前页数
		var page;
		var popupobj=CrmPopup.getPopupObj("last");
		var divid=popupobj.divid;
		if(document.getElementById('faq_page') != undefined){
			page = document.getElementById('faq_page').value;
		}
       
		var ids = new Array();
		var new_select_id ={};
        
	   if(obj.checked == true){
			select_id[obj.value] = page;
			ids[0] = obj.value
			//赋值  已选的常见问题id
			if(CrmPopup.findHtmlobj(divid,'faqid_string').val() != undefined){
				var faqid_string = CrmPopup.findHtmlobj(divid,'faqid_string').val();
				if(faqid_string  != ''){
					CrmPopup.findHtmlobj(divid,'faqid_string').val(faqid_string+ ','+obj.value);
				}else{
					CrmPopup.findHtmlobj(divid,'faqid_string').val(faqid_string+obj.value);
				}
			}
			setFaqValue(selectmodule,ids,'Select');
	   }else{
			if (obj) {
				
				var n = 0;
				//清空
				setFaqValue(selectmodule,ids,'Reverse');
				ld.each(select_id,function(faqid,pstart){
					if(faqid != obj.value){
						ids[n] = faqid;
						new_select_id[faqid]=pstart;
						n++;
					}
				});
				select_id = {};
				select_id = new_select_id;
				//赋值  已选的常见问题id
				if(CrmPopup.findHtmlobj(divid,'faqid_string').val() != undefined){
					CrmPopup.findHtmlobj(divid,'faqid_string').val(ids.join(','));
				}
				setFaqValue(selectmodule,ids,'Reverse');
			}
	   }
	}
	/**
	 * 服务单 - 选择常见问题 - 点击确定按钮事件
	 * @param
	 * @returns
	 * @author Chj 
	 */
	function postHelpDeskValue(){
	  
	   if(document.getElementById('faqid_string') != undefined && document.getElementById('faqno_string') != undefined){
		   //常见问题赋值
			if(document.getElementById('faqid_string').value !='' && document.getElementById('faqno_string').value !=''){
				if(window.parent.document.EditView.questionid != undefined){
					if(window.parent.document.EditView.questionid.value != ''){
						window.parent.document.EditView.questionid.value += ','+document.getElementById('faqid_string').value;	
					}else{
						window.parent.document.EditView.questionid.value = document.getElementById('faqid_string').value;
					}
				}
				if(window.parent.document.EditView.question_name != undefined){
					if(window.parent.document.EditView.question_name.value != ''){
						window.parent.document.EditView.question_name.value += ','+document.getElementById('faqno_string').value;	
					}else{
						window.parent.document.EditView.question_name.value = document.getElementById('faqno_string').value;
					}
				}
				//问题描述赋值
			   if(document.getElementById('question_description') != undefined){
					if(window.parent.document.EditView.description != undefined){
						if(window.parent.document.EditView.description.value != ''){
							window.parent.document.EditView.description.value += "\r\n"+document.getElementById('question_description').value;	
						}else{
							window.parent.document.EditView.description.value = document.getElementById('question_description').value;
						}
					}
			   }
			   //解决办法赋值
			   if(document.getElementById('answer') != undefined){
					if(window.parent.document.EditView.solution != undefined){
						if(window.parent.document.EditView.solution.value != ''){
							window.parent.document.EditView.solution.value += "\r\n"+document.getElementById('answer').value;	
						}else{
							window.parent.document.EditView.solution.value = document.getElementById('answer').value;
						}
					}
			   }
			   fninvshnew('selectrelateddiv');
			}else{
				 alert(arrJsPopLabel['PLEASESELECTATLEASTONEPROBLEM']);
				return false;
		   }
	   }
	}
	//查找问题回车事件
	function EnterPress(e,module,selectmodule){ //传入 event
		var e = e || window.event;
		if(e.keyCode == 13){
			getListViewFaqType(module,selectmodule);
		}
	}
	/**
	 * 服务单 - 常见问题 - 点击常见问题刷选列表
	 * @param
	 * @returns
	 * @author Chj
	 */
	function getListViewFaqType(module,selectmodule){
		var url_str = 'module=Users&action=UsersAjax&file=select_related_special_popu&search_type=true&selectmodule='+selectmodule+'&frommodule='+module;
		
        var select_keys =new Array();
        
        var obj = document.getElementsByName('select_faqtype');
		var keywords = '';//查找关键字
		if (obj&&obj.length>0) {
			var faqtype_name = new Array();
			for (var i=0,n=0;i<obj.length;i++) {
				if(obj[i].checked == true){
					faqtype_name[n] = obj[i].value;
					n++;
				}
			}
			//判断常见问题选项是否勾选
			if(faqtype_name.length >= 1){
				setFaqContentDisplay('');
			}else{
				setFaqContentDisplay('none');
			}
            select_keys.push({'faqtype':faqtype_name.join('|')});
		}
        else{
            //常见问题为空 zkt 20230110 BUG0060611福州大禹——【客户服务单】关联选择【常见问题】模块，在选择单据时，应该是选择 “问题类别”为 ‘常见问题’  应该显示常见问题的 所有单据
            var faqcategoryobj = document.getElementsByName('select_faqcategory');
    		if(faqcategoryobj&&faqcategoryobj.length>0){
    			var faqcategory_name = new Array();//目前已勾选的所有问题类别
    			//获取已勾选的问题类别
    			for (var i=0,n=0; i<faqcategoryobj.length;i++) {
    				if(faqcategoryobj[i].checked == true){
    					faqcategory_name[n] = faqcategoryobj[i].value;
    					n++;
    				}
    			}
                select_keys.push({'category':faqcategory_name.join('|')});
                setFaqContentDisplay('');
                //url_str +='&faqcategory_name='+encodeURIComponent(faqcategory_name.join('|'));
            }
        }
        url_str += '&select_keys='+encodeURIComponent(JSON.stringify(select_keys));
        //37767: （1.6）客户服务单新增界面>常见问题弹出层：选择第一行的任意一个点击保存提示【请至少选择一个问题】
		var select_id_json ="";//JSON.stringify(select_id);
       
		url_str += '&select_id_json='+select_id_json;
		
		if(ld('#keywords') != undefined){
			keywords = ld('#keywords').val();
		}
		url_str += '&keywords='+keywords;
		//alert(url_str);
		new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody: url_str,
			onComplete: function(response) {  
				var popupobj=CrmPopup.getPopupObj("last");
				var divid=popupobj.divid;
                $("status").style.display="none";
				CrmPopup.findHtmlobj(divid,'ListViewContents').html(response.responseText);
				var keys= CrmPopup.findHtmlobj(divid,'keywords').val();
				CrmPopup.findHtmlobj(divid,'keywords').val("").focus().val(keys);
			}
		});
	}
	/**
	 * 服务单 - 选择常见问题  控制问题列表、问题描述、解决方案区块的显示和隐藏
	 * @param
	 * @returns
	 * @author Chj 
	 */
	function setFaqContentDisplay(displays){
	   if(document.getElementById('contents_Style') != undefined){
			document.getElementById('contents_Style').style.display=displays;
		}
		if(document.getElementById('description_Style') != undefined){
			document.getElementById('description_Style').style.display=displays;
		}
		if(document.getElementById('answer_Style') != undefined){
			document.getElementById('answer_Style').style.display=displays;
		}
	}
	/**
	* 
	* @param服务单 - 选择常见问题 - 分页
	* @returns
	* @author Chj 
	*/
	function getListViewFaqEntries_js(module,selectmodule,url_string){
		var url_str = 'module=Users&action=UsersAjax&file=select_related_special_popu&ajax=true&selectmodule='+selectmodule+'&frommodule='+module;
		url_str = url_str + url_string;
		//获取已选的常见问题 选项
		var obj = document.getElementsByName('select_faqtype');
		if (obj) {
			var faqtype_name = new Array();
			for (var i=0,n=0;i<obj.length;i++) {
				if(obj[i].checked == true){
					faqtype_name[n] = obj[i].value;
					n++;
				}
			}
			url_str +='&faqtype_name='+faqtype_name.join('|');
		}
		var select_id_json = JSON.stringify(select_id);
		url_str += '&select_id_json='+select_id_json;
		//获取已选的常见的问题
		//alert(url_str);
		new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody: url_str,
			onComplete: function(response) {
				var popupobj = CrmPopup.getPopupObj('last');
                $("status").style.display="none";
				//BUG0064685 zxm 20230413 客户服务单中，点击“常见问题”并在常见问题列表界面点击选择页码后，客户服务单序时簿列表会变成“常见问题”这个模块的列表界面
				CrmPopup.findHtmlobj(popupobj.divid,'ListViewContents').html(response.responseText);
                $("selectrelateddiv").className='D_pop_box LdPopWidth800px';
                fnvshobj(this,'selectrelateddiv');       
			}
		});
	}

function verify_data(form) {
	if(! form.createpotential.checked == true)
	{
        	if (form.potentials_name.value == "")
		{
                	alert(alert_arr.OPPORTUNITYNAME_CANNOT_BE_EMPTY);
			return false;	
		}
		if (form.closedate.value == "")
		{
                	alert(alert_arr.CLOSEDATE_CANNOT_BE_EMPTY);
			return false;	
		}
		return dateValidate('closedate','Potential Close Date','GECD');
			
		
        }
        return true;
}

function togglePotFields(form)
{
	if (form.createpotential.checked == true)
	{
		form.potentials_name.disabled = true;
		form.closedate.disabled = true;
		
	}
	else
	{
		form.potentials_name.disabled = false;
		form.closedate.disabled = false;
	}	

}

function toggleAssignType(currType)
{
        if (currType=="U")
        {
                getObj("assign_user").style.display="block"
                getObj("assign_team").style.display="none"
        }
        else
        {
                getObj("assign_user").style.display="none"
                getObj("assign_team").style.display="block"
        }
}

function set_return(product_id, product_name) {
	if(document.getElementById('from_link').value != '') {
        window.opener.document.QcEditView.parent_name.value = product_name;
        window.opener.document.QcEditView.parent_id.value = product_id;
	} else {
        window.opener.document.EditView.parent_name.value = product_name;
        window.opener.document.EditView.parent_id.value = product_id;
}
}

function set_return_todo(product_id, product_name) {
	if(document.getElementById('from_link').value != '') {
        window.opener.document.QcEditView.task_parent_name.value = product_name;
        window.opener.document.QcEditView.task_parent_id.value = product_id;
	} else {
        window.opener.document.createTodo.task_parent_name.value = product_name;
        window.opener.document.createTodo.task_parent_id.value = product_id;
}
}

function set_return_specific(help_id, help_name) {
        
	//getOpenerObj used for DetailView 
        var fldName = getOpenerObj("helpdesk_name");
        var fldId = getOpenerObj("troubleticketid");
		var frommodule = document.getElementById('frommodule').value;
        fldName.value = help_name;
        fldId.value = help_id;
}

/**
 * 取消客户选择后会执行calcTotal方法，但服务单中没有这个方法所以报错，现在增加一个空方法
 * @reason 0009045 点击客户取消图标报错
 * @author Tujt 2014-05-22
 */
// @edit:liushuai,2020-09-18,reason:0042770: (http://51mis.com/YS/su1 [^])合同订单模块>单据详情界面：相关点击“记账报税”（客户服务单），再返回详情界面，工具栏点击“编辑”按钮，编辑单据界面点击“保存”没反应
/*function calcTotal()
{
   
}*/
/*
 function jsHelpDesk()
 { 
    
 
         this.form= document.forms['EditView']; 
      
                this.topBtnObj=document.getElementById("TopButton");//顶端保存按钮
                this.topBtnObj.onclick=this.resetEditViewButtonEvent;
                this.bottomBtnObj=document.getElementById('BottomButton'); //底端保存按钮             
                this.bottomBtnObj.onclick=this.resetEditViewButtonEvent;               
       
 }
 jsHelpDesk.prototype.getfieldlabelByColumName=function(columnname)
 {
    this.selectfieldinfoobj=fieldinfoobjs;
    for(var i=0;i<this.selectfieldinfoobj.fields.length;i++)
         {
            if(columnname==this.selectfieldinfoobj.fields[i]['columnname'])
            {                
                return this.selectfieldinfoobj.fields[i]['fieldlabel'];
            }
         }
 }
 jsHelpDesk.prototype.resetEditViewButtonEvent=function(event)
 {       
     event=event||window.event;
    var obj=event.srcElement||event.target;
    
    
    obj.disabled=true;//防止重复点击
    
     displaydeleted();    
     if( formValidate())  
     {     
       if(document.getElementById('cmb_span_optiontext_servicetype')!=undefined)
        {
            var servicetype=document.getElementById('cmb_span_optiontext_servicetype').innerHTML ;           
            if(servicetype.indexOf('上门')>=0)
            {   
                var hopetime='';
                var hopetime_end='';
                var hope_address='';
                if(document.getElementById('jscal_field_hopetime')!=undefined)
                {
                   hopetime=document.getElementById('jscal_field_hopetime').value ;                   
                }
                if(document.getElementById('jscal_field_hopetime_end')!=undefined)
                {
                   
                   hopetime_end=document.getElementById('jscal_field_hopetime_end').value ;                 
                }
                if(document.getElementById('hope_address')!=undefined)
                {
                    hope_address=document.getElementById('hope_address').value ;                 
                } 
               if(hopetime==''&&document.getElementById('jscal_field_hopetime')!=undefined) 
               {                 
                   alert(jsHelpDesk.prototype.getfieldlabelByColumName("hopetime")+arrJsPopLabel['CANOTEMPTY']);
               	   var currObj = getObj("hopetime");
                   currObj.focus();
                      obj.disabled=false;
                   return false; 
               }             
               else if(hopetime_end==''&&document.getElementById('jscal_field_hopetime_end')!=undefined)
                {               
                   alert(jsHelpDesk.prototype.getfieldlabelByColumName("hopetime_end")+arrJsPopLabel['CANOTEMPTY']);
               	   var currObj = getObj("hopetime_end");
               	    currObj.focus(); obj.disabled=false;
                   return false; 
                }
                else if(document.getElementById('hope_address')!=undefined&&trim(hope_address.replace(/[\n]/ig,''))==''||trim(hope_address.replace(/[\n]/ig,''))=='<br>')
                {                  
                   alert(jsHelpDesk.prototype.getfieldlabelByColumName("hope_address")+arrJsPopLabel['CANOTEMPTY']);
                   var currObj = getObj("hope_address");                  
                   currObj.focus(); obj.disabled=false;
                   return false;
                }                
                if(hopetime>hopetime_end&&document.getElementById('jscal_field_hopetime')!=undefined&&document.getElementById('jscal_field_hopetime_end')!=undefined  ) 
                {                
                    hopetime_fieldlabel=jsHelpDesk.prototype.getfieldlabelByColumName("hopetime");
                    hopetime_end_fieldlabel=jsHelpDesk.prototype.getfieldlabelByColumName("hopetime_end");
                    alert(hopetime_fieldlabel+arrJsPopLabel['SHOULDLESSTHANOREQUAL']+hopetime_end_fieldlabel);      obj.disabled=false;               
                    return false;
                }                              
            }                
         }
         this.form.action.value='Save';        
         FieldDuplicateValidate('HelpDesk',this.form);
		 obj.disabled=false;
     }
     else
     {
        obj.disabled=false;
        //jsHelpDesk.prototype.bottomBtnObj.disabled=false;
        return false;
     }       
      
 }*/
 
//客户服务单发送短信切换接收人范围
function range_select(obj){
    
    var record = ld('#ticketid').val();
    var fromview = ld('#fromview').val();
    var listurl = ld('#listurl').val();
    var postbody = '';
    if(fromview == 'detail'){
        postbody = 'module=MassSMS&action=SendMessage&frommodule=HelpDesk&Ajax=yes&record='+record+'&rangetype='+obj.value;
    }
    if(fromview == 'listview'){
        postbody = "module=MassSMS&action=SendMessage&frommodule=HelpDesk&Ajax=true&fromview=list"+listurl+'&rangetype='+obj.value;
    }
    
     ld.ajax({
        url: 'index.php?'+postbody,
        type: 'POST',
        data:'',
       dataType:'json',
        async: true,//
        timeout: 5000,
       
        success: function(data)
        {
            if(data.code==1)
            {
                
                 $("status").style.display="none";
                    var SMSSendPopupobj=SMSSendPopup.getInstance(data.result.title,SaveSendMessage,"","LdPopWidth900px","HelpDesk","",data.result.oktext,"",data.result.canceltext,data.result.createnewtext);
                   SMSSendPopupobj.show(data.result.content);

            }
        
        }
    });
    
}

function toggleallbox(check){

    ld("#SendMessage :checkbox").prop("checked",check);

}

function select_one(obj){
    var countcon = ld('#count_con').val();

    var select_all = true;
    for(var i=0;i<countcon;i++){
        var state = ld("input[name='box_"+i+"']").is(':checked');
        if(state == false){
            select_all = false;
            break;
        }
    }

    if(getObj("selectallboxes")) {
    	getObj("selectallboxes").checked=select_all;
   	}
}

function fieldSel(obj)
{
    document.getElementById("selField").value="[var."+obj.value+"]";
    
}
var template_focusid;
function setFocusId(focusid){
    template_focusid = focusid;
}
function InsertTwoTemplate(obj){
    if(trim(document.getElementById("selField").value )=="")
    {
        //请选择字段！
        alert(arrJsPopLabel['PLEASESELECTFIELD']);   
        return false;
    }

    var txtvalue=document.forms['frmsendInfoContent'].SelectField.options[document.forms['frmsendInfoContent'].SelectField.selectedIndex].text;

    (function($){
	 $.fn.extend({
	  insertAtCaret: function(myValue){
	   var $t=$(this)[0];
	   if (document.selection) {
		this.focus();
		sel = document.selection.createRange();
		sel.text = myValue;
		this.focus();
	   }
	   else 
		if ($t.selectionStart || $t.selectionStart == '0') {
		 var startPos = $t.selectionStart;
		 var endPos = $t.selectionEnd;
		 var scrollTop = $t.scrollTop;
		 $t.value = $t.value.substring(0, startPos) + myValue + $t.value.substring(endPos, $t.value.length);
		 this.focus();
		 $t.selectionStart = startPos + myValue.length;
		 $t.selectionEnd = startPos + myValue.length;
		 $t.scrollTop = scrollTop;
		}
		else {
		 this.value += myValue;
		 this.focus();
		}
	  }
	 }) 
	})(ld);
       ld('#'+template_focusid).insertAtCaret(ld('#selField').val());
}
function SaveSendMessage(){
    
    var obj=CrmPopup.getPopupObj("last").getbtnOkobj();
    
    var form=document.forms['frmsendInfo'];
    
    var countcon = ld('#count_con').val();

    var select_one = false;
    for(var i=0;i<countcon;i++){
        var state = ld("input[name='box_"+i+"']").is(':checked');
        if(state == true){
            select_one = true;
            break;
        }
    }
    if(!select_one){
       alert(arrJsPopLabel['PLEASESELECTONEENTITY']);
	   return false;
    }
    form.submit();
}
SaveSendMessage.funname="SaveSendMessage";

//新增短信息条目
function NewSendMessage(){
    var countcon = ld('#count_con').val();

    var content = '';
    content += '<tr>';
    content += '<td><input onclick="select_one(this)" name="box_'+countcon+'" value="1" type="checkbox" /></td>';
    content += '<td><input style="width:100px" type="text" name="text_'+countcon+'" value=""/></td>';
    content += '<td><textarea name="area_'+countcon+'" style="width:675px;height: 30px;"></textarea></td>'
    content += '</tr>';
    ld("#contenttable").append(content);
    ld("[name='box_"+countcon+"']").attr('checked',true);
    countcon = parseInt(countcon)+1;
    ld('#count_con').val(countcon); 
}

/**
 * 帮我吧服务单同步
 * @param
 * @returns
 * @author Chj 
 */
function bw_sync(stype){
	if(stype == 'listbtn'){
		fnvshobj(this,'bw_sync_helpdesk_div');//显示提示帮我吧同步弹出层
		var url = "module=HelpDesk&action=HelpDeskAjax&frommodule=HelpDesk&Ajax=true&file=bw_helpdesk&sync=true";
		ldAjaxHtmlNoProgress('index.php?',url,function (response) {
			fninvshnew('bw_sync_helpdesk_div');
			if(response == 'error'){
				MessagePopup.TipOne_warning(arrJsPopLabel['NOHELPDESKSERVICERECORD']);
			}else if(response == '##NOURL##'){
				MessagePopup.TipOne_warning(arrJsPopLabel['crmserver']);
			}else{
				MessagePopup.TipOne_success(arrJsPopLabel['Synchronizedsuccess']);
			}
			getListViewEntries_js('HelpDesk','start=1');//刷新页面

		})

		
	}else{
		var surl = "module=HelpDesk&action=HelpDeskAjax&frommodule=HelpDesk&Ajax=true&file=bw_helpdesk&is_sync=1";
		ldAjaxHtmlNoProgress('index.php?',surl,function (response) {
			if (response == 'success'){
				fnvshobj(this,'bw_sync_helpdesk_div');//显示提示帮我吧同步弹出层
				var url = "module=HelpDesk&action=HelpDeskAjax&frommodule=HelpDesk&Ajax=true&file=bw_helpdesk";
				ldAjaxHtmlNoProgress('index.php?',url,function (res) {
					if(res == 'success'){
						fninvshnew('bw_sync_helpdesk_div');
						MessagePopup.TipOne_success(arrJsPopLabel['Synchronizedsuccess']);
						getListViewEntries_js('HelpDesk','start=1');//刷新页面
					}
				})
			}
		});
	}
}

function InsertTemplate(obj){
	
    //28818: 客户服务单明细界面：发送短信->设定短信格式弹出层中，选择一字段变量插入到内容模板保存，结果界面显示灰色
		if(trim(document.getElementById("selField").value )=="")
        {
            //请选择字段！
            alert(arrJsPopLabel['PLEASESELECTFIELD']);   
            return false;
        }

  
        document.getElementById('CKcontent').value += document.getElementById("selField").value;
        ld('#CKcontent').focus();
    
	
}

//弹出短信弹出层
function SMSSendPopup()
{
    var parentshow=this.show;
    this.createBottomHtml=function()
    {
		this.popupbottomhtml='<div class="E_pbtn">';
		this.popupbottomhtml+='<input name="button" id="'+this.divid+'_btnok" class="D_pbtnok ld-button ld-button-primary" value="'+this.OkText+'" tagClick="'+this.Okfun.funname+'"  type="button">';
		this.popupbottomhtml+='<input name="button" class="D_pbtncancel ld-button" value="'+this.CancelText+'" id="'+this.divid+'_btncancel" type="button">'
		this.popupbottomhtml+='</div>';
        this.btnokid=this.divid+"_btnok";
        this.btncancelid=this.divid+"_btncancel";
    }
}
SMSSendPopup.type='helpdesksms';
SMSSendPopup.load=function(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText,createNewText)
{
     SMSSendPopup.prototype=new CrmPopup();  
     SMSSendPopup.prototype.constructor=SMSSendPopup;  
   
     
     SMSSendPopup.prototype.type=SMSSendPopup.type;
    SMSSendPopup.prototype.createNewText=createNewText;
    

     var  QcPopupobj=new SMSSendPopup();
     QcPopupobj.setParams(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText);
    return QcPopupobj;
    
}
 
 
 //弹出层的单例
SMSSendPopup.getInstance=function(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText,createNewText)
{
     for(var i=0;i<CrmPopup.global_signleInstance.length;i++)
     {
        if(CrmPopup.global_signleInstance[i].type==SMSSendPopup.type)
        {
            return CrmPopup.global_signleInstance[i];
        }
     }

      var crmpopupobj=SMSSendPopup.load(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText,createNewText);
     CrmPopup.global_signleInstance.push(crmpopupobj);
    return crmpopupobj;

}

// @edit:dong @date:2020/08/04 @reason: 移动到listview.js
/*var location_lat = 0;
var location_lng = 0;
function getLocationAddress(fldname,mode){
	
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	//默认省份
	var bill_state = '';
	var bill_city = '';
	if(mode == 'edit'){
		bill_state = CrmPopup.findHtmlobj(divid,'bill_state').val();
		bill_city = CrmPopup.findHtmlobj(divid,'bill_city').val();
	}else if(mode == 'detail'){
		bill_state =trim(ld('#dtlview_bill_state font').html());
		bill_city = trim(ld('#dtlview_bill_city font').html());
	}
	//定位地址
	var address  = '';
	if(!empty(fldname) && CrmPopup.findHtmlobj(divid,fldname).val() != undefined){
		address = CrmPopup.findHtmlobj(divid,fldname).val();
	}
	if(empty(address) && (!empty(bill_state) || !empty(bill_city))){
		address = bill_state + bill_city;
	}
  
  
	//详情页
	if(mode == 'detail' && document.getElementById('dtlview_locationaddress') != undefined && document.getElementById('dtlview_locationaddress').innerHTML != ''){
		address = document.getElementById('dtlview_locationaddress').innerHTML;
	}
    
     if(address==''||address=='undefined'||address==undefined){
        return false;
     }
 
	var module_mod = '';
	if(mode == 'detail' || mode == 'edit'){
		var urlajax = "module=Accounts&action=AccountsAjax&file=TencentMap&address="+encodeURIComponent(address)+"&getpoint=yes";	//单
	}else{
		var urlajax = "module=Accounts&action=AccountsAjax&file=TencentMap&address="+encodeURIComponent(address)+"&getpoint_list=yes";	//多、列表
		module_mod = 'select';
	}
	new Ajax.Request
	(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody:urlajax,
				onComplete: function(response) 
				{
					var results = trim(response.responseText);    
					var restobj = eval('('+ results +')')?eval('('+ results +')'):JSON.parse(results);
					if(restobj != ''){
						 ld('#'+divid + ' .f-item').css('display', 'block');
						if(empty(module_mod)){
							location_lat = restobj['entries']['lat'];
							location_lng = restobj['entries']['lng'];
							//创建script标签
							var script = document.createElement("script");
							//设置标签的type属性
							script.type = "text/javascript";
							//设置标签的链接地址
							script.src = "https://map.qq.com/api/js?v=2.exp&callback=initMap&key=P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X";
							//添加标签到dom
							document.body.appendChild(script);
						}else{
							var info = '';
							for(var i in restobj['entries']){
								if(restobj['entries'][i]['address'] != undefined){
									info += '<li city="'+restobj['entries'][i]['city']+'" district="'+restobj['entries'][i]['district']+'" address="'+restobj['entries'][i]['address']+'" point="'+restobj['entries'][i]['point']+'">';
									info += '<span>'+restobj['entries'][i]['address']+'</span>';
									info += '</li>';

								}
							}

							CrmPopup.findHtmlobj(divid,'search_location_address').html(info);
							CrmPopup.findHtmlobj(divid,'search_location_address').show();

			              ld('#'+divid).unbind('click').on('click',function(){
			                CrmPopup.findHtmlobj(divid,'search_location_address').hide();
			              })
							
							ld('#search_location_address').find('li').each(function() {
								ld(this).click(function() {
									var district = ld(this).attr('district');
									var city = ld(this).attr('city');
									var address = ld(this).attr('address');
									var point = ld(this).attr('point');
									var point_arr = point.split(',');
									location_lat = point_arr[0];
									location_lng = point_arr[1];
								//	city = trim(city.replace('市',''));
									if(CrmPopup.findHtmlobj(divid,'bill_street').val() != undefined && CrmPopup.findHtmlobj(divid,'bill_street').val() != ''){
										RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['doyouuselocationaddress']);
										ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
											CrmPopup.findHtmlobj(divid,'locationaddress').val(address);
											scriptMap(address)
										});
										ld('input[class="D_pbtncancel"]').unbind('click').on('click',function(){
					                      CrmPopup.findHtmlobj(divid,'search_location_address').hide();
					                    });
									}else{
										CrmPopup.findHtmlobj(divid,'locationaddress').val(address);
										scriptMap(address)
									}
								})
							})

						}
					}else{
						//var info = '<li><span>'+arrJsPopLabel['thelocationaddress']+'</span></li>';
						//CrmPopup.findHtmlobj(divid,'search_location_address').html(info);
						//CrmPopup.findHtmlobj(divid,'search_location_address').show();
						ld('#'+divid + ' .f-item').css('display', 'none');
					}
					
				}
			}
	  )
}
//加载地图
function scriptMap(address){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	CrmPopup.findHtmlobj(divid,'search_location_address').hide();
	//创建script标签
	var script = document.createElement("script");
	//设置标签的type属性
	script.type = "text/javascript";
	//设置标签的链接地址
	script.src = "https://map.qq.com/api/js?v=2.exp&callback=initMap&key=P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X";
	//添加标签到dom
	document.body.appendChild(script);
}
//加载地图api后的回调函数
function initMap(){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var center = new qq.maps.LatLng(location_lat,location_lng);
	//定义map变量 调用 qq.maps.Map() 构造函数   获取地图显示容器
	ld("#"+divid+" [name=location_map_td]").show();
	 var map = new qq.maps.Map(ld("#"+divid+" [name=container]")[0], {
		center: center,      // 地图的中心地理坐标。
		zoom:15,                                                 // 地图的中心地理坐标。
		disableDefaultUI: true
	});
	//创建标记
	var anchor = new qq.maps.Point(6, 6),
	size = new qq.maps.Size(23, 38),
	origin = new qq.maps.Point(0, 0),
	icon = new qq.maps.MarkerImage('themes/images/location.png', size, origin, anchor);
	var marker = new qq.maps.Marker({
		icon: icon,
		position: center,
		map: map
	});
}

function enlarge_map(address){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	if(empty(address)){
		address = CrmPopup.findHtmlobj(divid,'locationaddress').val();
	}
	var record = CrmPopup.findHtmlobj(divid,'record').val();
	var urlajax = "module=Accounts&action=AccountsAjax&file=TencentMap&address="+encodeURIComponent(address)+"&getpoint=yes&record="+popupobj.record+"&frommodule="+popupobj.module;	//单
	new Ajax.Request
	(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody:urlajax,
				onComplete: function(response) 
				{
					var results = trim(response.responseText);
					var restobj = eval('('+ results +')')?eval('('+ results +')'):JSON.parse(results);
					if(restobj != ''){
						location_lat = restobj['entries']['lat'];
						location_lng = restobj['entries']['lng'];
						var table_html = '<div name="big_container" id="big_container" style="height:500px;"></div>';
						resultRemindsMsg(arrJsPopLabel['ACCOUNTSMAP'],"LdPopWidth800px","","yes","",table_html);
						//创建script标签
						var script = document.createElement("script");
						//设置标签的type属性
						script.type = "text/javascript";
						//设置标签的链接地址
						script.src = "https://map.qq.com/api/js?v=2.exp&callback=Big_initMap&key=P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X";
						//添加标签到dom
						document.body.appendChild(script);
					}
				}
			}
	  )
}
//
function Big_initMap(){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var center = new qq.maps.LatLng(location_lat,location_lng);
	//定义map变量 调用 qq.maps.Map() 构造函数   获取地图显示容器
	var map = new qq.maps.Map(ld("#"+divid+" [name=big_container]")[0], {
		center: center,      // 地图的中心地理坐标。
		zoom:15,                                           // 地图的中心地理坐标。
		disableDefaultUI: true
	});
	//创建标记
	var anchor = new qq.maps.Point(6, 6),
	size = new qq.maps.Size(23, 38),
	origin = new qq.maps.Point(0, 0),
	icon = new qq.maps.MarkerImage('themes/images/location.png', size, origin, anchor);
	var marker = new qq.maps.Marker({
		icon: icon,
		position: center,
		map: map
	});
}*/

function CreateSendForm(module,recordid)
{
     ld.ajax({
        url: 'index.php?'+"module=HelpDesk&action=HelpDeskAjax&file=SendMessage&frommodule="+module+"&ids=" +recordid+"&ReportHeader=dheader",
        type: 'POST',
        data:'',
       	dataType:'json',
        async: true,//
        timeout: 5000,
        success: function(data)
        {
            if(data.code==1)
            {
				$("status").style.display="none";
				var SMSSendPopupobj=SMSSendPopup.getInstance(data.result.title,SaveSendMessageClick,"","LdPopWidth800px",module,"",data.result.oktext,"",data.result.canceltext,data.result.createnewtext);
				SMSSendPopupobj.show(data.result.content);
				// 设置内容最大高度
				SMSSendPopupobj.setPopBodyMaxHeight(".divPopOverflow");

				if (data.result.platform = 'aliyun') {

					//获取短信模板  并赋值
					var templateparamconf_arr = [];
					if (typeof data.result.smsrelated_arr['templateparamconf_arr'] != 'undefined') {//编辑
						var smsrelated_arr = data.result.smsrelated_arr;
						ld("#"+SMSSendPopupobj.divid+" [name=smstemplatelist]").val(smsrelated_arr['templateid']);
						templateparamconf_arr = smsrelated_arr['templateparamconf_arr'];

						SmsContentSetting.getInstance().ShowSmsTemplateEvent(SMSSendPopupobj,templateparamconf_arr);
					}else{
						ld("#"+SMSSendPopupobj.divid+" [name=smstemplatelist]").change();//初始化短信内容html //等价于 SmsContentSetting.getInstance().ShowSmsTemplateEvent();
					}

					var selectsmsobj=ld('#'+SMSSendPopupobj.divid).find("[name=smstemplatelist]");
					if(selectsmsobj.length>0&&selectsmsobj!=undefined) {
						var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectsmsobj.attr("name"));
						cls_resetComboxHtmlobj.setPopupObj(SMSSendPopupobj);
						cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectsmsobj, 160);
					}
					var selectobj=ld('#'+SMSSendPopupobj.divid).find("[name=moduleselect]");
					if(selectobj.length>0&&selectobj!=undefined) {
						var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectobj.attr("name"));
						cls_resetComboxHtmlobj.setPopupObj(SMSSendPopupobj);
						cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj, 160);
					}

					var tabid = ld("#"+SMSSendPopupobj.divid+" [name=moduleselect]").val();
					var urlstring = '&tabid='+tabid+'&printtabid='+tabid;
					ldAjaxNoProgress('index.php?module=Settings&action=SettingsAjax&file=TemplatePrintField'+urlstring,{},function(data){
						ld("#"+SMSSendPopupobj.divid+" #tabField").html(data.result.fieldsel);
						ld("#"+SMSSendPopupobj.divid+" #selField").val('');
						ld("#"+SMSSendPopupobj.divid+" textarea#templateTextArea").val("");
					});
				}

            }
        }
    });
    
}

function SaveSendMessageClick(){
	$("status").style.display="inline";
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var is_send = CrmPopup.findHtmlobj(divid,'is_send').val();
	var textRecipient = CrmPopup.findHtmlobj(divid,'textRecipient').val();
	var textContext = CrmPopup.findHtmlobj(divid,'textContext').val();
	var record = CrmPopup.findHtmlobj(divid,'record').val();
	if(empty(textRecipient)){
		RemindsMsg("","LdPopWidth400px","","","",arrJsPopLabel['CORRECTRECIPIENTINFORMATION']);
		return false;
	}
	var platform = CrmPopup.findHtmlobj(divid,'platform').val();

	if(platform == 'aliyun'){

		var select_smstemplateid = ld("#"+popupobj.divid+" [name=smstemplatelist]").val();
		if (select_smstemplateid < 1) {
			var confirm_str = arrJsPopLabel["TEMPLATE"]+arrJsPopLabel["CANOTEMPTY"];
			MessagePopup.TipZero_warning(confirm_str);
			return false;
		}
		var templateparamconf = {};
		try {
			ld.each(SmsContentSetting.getInstance().smsTemplateList,function(tmpindex,tmpsmstemplateinfo){
				if (select_smstemplateid == tmpsmstemplateinfo.templateid) {
					var templateparaminfo = JSON.parse(tmpsmstemplateinfo.templateparaminfo) || eval('('+tmpsmstemplateinfo.templateparaminfo+')');
					if (!empty(templateparaminfo)) {

						ld.each(templateparaminfo,function(tmp_varname,tmp_crmvarname){
							var tmp_crmvarname_value = trim(ld("#"+popupobj.divid+" [name=smstemplateparam_table] tbody [name="+tmp_varname+"]").val());
							if (tmp_crmvarname_value.length == 0) {
								ld("#"+popupobj.divid+" [name=smstemplateparam_table] tbody [name="+tmp_varname+"]").focus();
								var confirm_str = 'CRM' + arrJsPopLabel['VAR'] + arrJsPopLabel['CANOTEMPTY'] + '!';
								MessagePopup.TipZero_warning(confirm_str);
								throw 'ExitLoops';
							}
							templateparamconf[tmp_varname] = tmp_crmvarname_value;

						})


					}
					return false;//跳出循环
				}

			})
		}catch(e){
			if (e === 'ExitLoops') {
				console.log('退出循环');
				return false;
			}
		}


	}
	else{
		if(empty(textContext)){
			RemindsMsg("","LdPopWidth400px","","","",arrJsPopLabel['CONTENTCANOTEMPTY']);
			return false;
		}
	}

	var textRecipient_array = new Array();
	textRecipient_array = textRecipient.split('\n');
	var url_str = "module=HelpDesk&action=HelpDeskAjax&file=SendMessage&is_send="+is_send+"&textRecipient=" +textRecipient_array.join(',')+"&textContext="+textContext+"&record="+record;
	if (!empty(select_smstemplateid)) {
		templateparamconf = !empty(templateparamconf)?JSON.stringify(templateparamconf):'';
		url_str += "&smstemplateid="+select_smstemplateid+"&smstemplateparamconf="+templateparamconf;
	}
	//alert(url_str);
	new Ajax.Request(
	'index.php',
	{queue: {position: 'end', scope: 'command'},
		method: 'post',
		postBody: url_str,
		onComplete: function(response) {
			$("status").style.display="none";
			if(response.responseText == -1){
				RemindsMsg("","LdPopWidth400px","","","",arrJsPopLabel['COMMUNICATIONACCOUNTISNOTSETEMPTYFAILED']);
				return false;
			}else if(response.responseText == -2){
				RemindsMsg("","LdPopWidth400px","","","",arrJsPopLabel['MAILACCOUNTNOTDETECTEDPLESEESET']);
				return false;
			}else{
				cancelCrmPopup();
				MessagePopup.TipZero_success(arrJsPopLabel['SENDSUCCESSFULLY']);
				return false;
			}
		}
	});
}

//选择其他联系人
function selectOtherContacts(contactid,accountid){
	$("status").style.display="inline";
     ld.ajax({
        url: 'index.php?'+"module=HelpDesk&action=HelpDeskAjax&file=SendMessage&contactid="+contactid+"&accountid=" +accountid+"&getAccountOtherContacts=yes",
        type: 'POST',
        data:'',
       dataType:'json',
        async: true,//
        timeout: 5000,
       
        success: function(data)
        {
			$("status").style.display="none";
            if(data.code==1)
            {
               var crmPopupobj=CrmPopup.load(data.result.title,SaveOtherContacts,"","LdPopWidth350px",'HelpDesk',"",data.result.oktext,"",data.result.canceltext);
			   crmPopupobj.show(data.result.content);
            }else{
				RemindsMsg("","LdPopWidth400px","","","",arrJsPopLabel['NOTFOUNDANYRECORD']);
				return false;
			}
        
        }
    });
}
//确认选择其他联系人
function SaveOtherContacts(){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var is_select = 0;
	var is_select_array = new Array();
	CrmPopup.findHtmlobj(divid,'selectcontacts').each(function(){
		var id_check = ld(this).prop("checked");
		if(id_check){
			is_select_array[is_select] = ld(this).attr("tag");
			is_select++;
		}
	});
	if(is_select <= 0){
		RemindsMsg("","LdPopWidth400px","","","",arrJsPopLabel['SELECTATLEASTONE']);
		return false;
	}else{
		var prevpopupobj=CrmPopup.getPopupObj("lastprev");
		var prevdivid=prevpopupobj.divid;
		var textRecipient = CrmPopup.findHtmlobj(prevdivid,'textRecipient').val();
		if(empty(textRecipient)){
			var len = 0;
		}else{
			var textRecipient_array = textRecipient.split('\n');
			var len = textRecipient_array.length;
		}
		if(len >= 1){
			ld.each(is_select_array,function(key,sel_res){
				if(ld.inArray(sel_res, textRecipient_array)<0){
					var new_textRecipient = CrmPopup.findHtmlobj(prevdivid,'textRecipient').val();
					CrmPopup.findHtmlobj(prevdivid,'textRecipient').val(new_textRecipient+'\r\n'+sel_res);
				}
			});
		}else{
			var is_select_string = is_select_array.join('\r\n');
			CrmPopup.findHtmlobj(prevdivid,'textRecipient').val(is_select_string);
		}
		cancelCrmPopup();
	}
}
//设置短信格式
function CreateSendInformContent(module,tabid){
    $("status").style.display="inline";
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var is_send = CrmPopup.findHtmlobj(divid,'is_send').val();
	var postbody = "module=Users&action=UsersAjax&file=SendInformContent&frommodule="+module+"&out_id="+tabid+"&tabid="+tabid+"&fromview=&smstype=allocate&is_send="+is_send;
	ld.ajax({
		url: 'index.php?'+postbody,
		type: 'POST',
		data:'',
		dataType:'json',
		async: true,//
		timeout: 5000,
        success: function(data)
        {
            if(data.code==1)
            {
				$("status").style.display="none";
				var jspopup=[];
				var crmPopupobj=CrmPopup.load(data.result.title,SaveSendInfoContentHelpDesk,"","LdPopWidth800px",module,jspopup,data.result.oktext,"",data.result.canceltext);
				crmPopupobj.show(data.result.content);
				OutboundOrdermoduleSel(tabid);
            }
        }
    });
}
/*
* 28818: 客户服务单明细界面：发送短信->设定短信格式弹出层中，选择一字段变量插入到内容模板保存，结果界面显示灰色
* */
function SaveSendInfoContentHelpDesk(obj)
{
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var textRecipient = CrmPopup.findHtmlobj(divid,'CKcontent').val();
    if(textRecipient==''){
        //内容模板为空！
		RemindsMsg("","LdPopWidth400px","","","",arrJsPopLabel['CONTENTTEMPLATEEMPTY']);
		return false;
    }
	var prevpopupobj=CrmPopup.getPopupObj("lastprev");
	var prevdivid=prevpopupobj.divid;
	CrmPopup.findHtmlobj(prevdivid,'textContext').val(textRecipient);
	cancelCrmPopup();
}









