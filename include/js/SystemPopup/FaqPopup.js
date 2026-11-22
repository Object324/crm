//客户服务单 - 常见问题
function FaqPopup(){
    
    //滚动条
    this.createScrollDiv=function()
    {
       
        this.scrolldiv='<div class="dvpopupsroll" style="max-height:450px;width: 100%;overflow-y:auto;margin: 0 0;diplay:inline">';
        
    }
    
}
FaqPopup.type="FaqPopup";
FaqPopup.load=function(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText,searchmodule)
{       
    
     FaqPopup.prototype=new CrmPopup();  
     FaqPopup.prototype.constructor=FaqPopup;  
     FaqPopup.prototype.type=FaqPopup.type;
     FaqPopup.prototype.curmodule=module;//弹出层所在的模块
     
     var  FaqPopupObj=new FaqPopup();
     FaqPopupObj.setParams(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText);
    return FaqPopupObj;
    
}

//确认
function SubmitFaqBtn()
{
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var prevpopupobj=CrmPopup.getPopupObj('lastprev');
	var predivid=prevpopupobj.divid;
	if(CrmPopup.findHtmlobj(divid,'faqid_string').val() != undefined && CrmPopup.findHtmlobj(divid,'faqno_string').val() != undefined){
	   //常见问题赋值
		if(CrmPopup.findHtmlobj(divid,'faqid_string').val() !='' && CrmPopup.findHtmlobj(divid,'faqno_string').val() !=''){
			var faqid_string = CrmPopup.findHtmlobj(divid,'faqid_string').val();
			var faqno_string = CrmPopup.findHtmlobj(divid,'faqno_string').val();
			if(CrmPopup.findHtmlobj(predivid,'questionid').val() != undefined){
				var questionid = CrmPopup.findHtmlobj(predivid,'questionid').val();
				if(questionid != ''){
					CrmPopup.findHtmlobj(predivid,'questionid').val(questionid+','+faqid_string);					
				}else{
					CrmPopup.findHtmlobj(predivid,'questionid').val(faqid_string);
				}
				var questionid_text = document.getElementById('questionid');
				if(questionid_text != null){
		            questionid_text.style.height = 'auto';
		            questionid_text.style.height = questionid_text.scrollHeight+'px';
		        }
			}
			if(CrmPopup.findHtmlobj(predivid,'questionid_name').val() != undefined){
				var question_name = CrmPopup.findHtmlobj(predivid,'questionid_name').val();
				if(question_name != ''){
					CrmPopup.findHtmlobj(predivid,'questionid_name').val(question_name+','+faqno_string);
				}else{
					CrmPopup.findHtmlobj(predivid,'questionid_name').val(faqno_string);
				}
				var question_name_text = document.getElementById('questionid_name');
				if(question_name_text != null){
		            question_name_text.style.height = 'auto';
		            question_name_text.style.height = question_name_text.scrollHeight+'px';
		        }
			}
			//问题描述赋值
		   if(CrmPopup.findHtmlobj(divid,'question_description').val() != undefined){
			   var question_description = CrmPopup.findHtmlobj(divid,'question_description').val();
				if(CrmPopup.findHtmlobj(predivid,'description').val() != undefined){
					var description = CrmPopup.findHtmlobj(predivid,'description').val();
					if(description != ''){
						CrmPopup.findHtmlobj(predivid,'description').val(description+"\r\n"+question_description);
					}else{
						CrmPopup.findHtmlobj(predivid,'description').val(question_description);
					}
					var description_text = document.getElementById('description');
					if(description_text != null){
			            description_text.style.height = 'auto';
			            description_text.style.height = description_text.scrollHeight+'px';
			        }
				}
		   }
		   //解决办法赋值
		   if(CrmPopup.findHtmlobj(divid,'answer').val()!= undefined){
			   var answer = CrmPopup.findHtmlobj(divid,'answer').val();
				if(CrmPopup.findHtmlobj(predivid,'solution').val()!= undefined){
					var solution = CrmPopup.findHtmlobj(predivid,'solution').val();
					if(solution != ''){
						CrmPopup.findHtmlobj(predivid,'solution').val(solution+"\r\n"+answer);
					}else{
						CrmPopup.findHtmlobj(predivid,'solution').val(answer);
					}
					var solution_text = document.getElementById('solution');
					if(solution_text != null){
			            solution_text.style.height = 'auto';
			            solution_text.style.height = solution_text.scrollHeight+'px';
			        }
				}
		   }
		  cancelCrmPopup();
		}else{
			RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['PLEASESELECTATLEASTONEPROBLEM']);
			return false;
	   }
   }
}
SubmitFaqBtn.funname="SubmitFaqBtn";