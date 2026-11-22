
function load_mask()
{
    getJsScript('include/js/modules/MailManager/Mask.js',function(){});
}
load_mask();
//document.write("<script language='JavaScript' type='text/javascript' src='modules/MailManager/Mask.js'></script>");
/**
andrew
第一个导入的弹层页面。
*/
function showDivImport(obj,importmodel){
	$("status").style.display="inline";
	new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody: 'action=ImportXls_Popup&module=XlsImport&xlsStep=First&importmodel='+importmodel,
			onComplete: function(response) {
			
    			$("status").style.display="none";
               if(ld("#actiondiv").length<=0)
                {
                    
                    var divObj = document.createElement("div");
	               	divObj.setAttribute('id','actiondiv');
                     document.body.appendChild(divObj);
                     /*class="D_pop_box LdPopWidth900px"*/
                     ld("#actiondiv").addClass("D_pop_box");
                      ld("#actiondiv").addClass("LdPopWidth900px");
                     
                }
           
            
                ld("#actiondiv").get(0).style.zIndex='9999';
    			ld("#actiondiv").get(0).innerHTML=response.responseText;
              //  setUpload(importmodel);//调用导入
                
              global_flash_fileattachmentphp='index.php?module=XlsImport&action=ImportXls_upload&myatt_moduel=Contacts';
                getJsScript('include/js/webuploader.js',function(){
                    fnvshobj(obj,'actiondiv');
                    
                    ld("#uploader_popup").powerWebUpload({
						uploderFileType:'xls,xlsx'
					});
                })
                
			}
		}
		);
}
//第二个弹窗页面，选择印射
function showDivImportSecond(obj,importmodel){
   	$("status").style.display="inline";
	//下一步时，先判断引入文件是否为空
	//017880: 销售机会>明细>相关信息>联系人：导入，当没有文件时，提示框显示不合理
	if(ld('#file_name_1') != undefined && ld('#file_name_1').val() == ''){
		var confirm_str = arrJsPopLabel['IMPORTFILECANOTEMPTY'];
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
	new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody: 'action=ImportXls_Popup&module=XlsImport&xlsStep=Second&importmodel='+importmodel,
			onComplete: function(response) {
    			$("status").style.display="none";
    			$("actiondiv").style.display ='none';
                $("actiondiv").style.zIndex='9999';
    			$("actiondiv").innerHTML=response.responseText;
                fnvshobj(obj,'actiondiv');
			}
		}
		); 
}

//导入并弹出第三个弹层
function showDivImportThird(importmodel,mapped_fieldsListListjson,defaultvalueListjson,isfieldnamevalueListjson,isfieldnameListjson){
   	$("status").style.display="inline";
    var urlvalue='&mapped_fields='+mapped_fieldsListListjson+'&defaultvalue='+defaultvalueListjson+'&isfieldnamevalue='+isfieldnamevalueListjson+'&isfieldname='+isfieldnameListjson;
    document.getElementById("canceltype").setAttribute("disabled", "disabled");  
    var recordid = document.getElementsByName('record')[0].value;
    var currrelid= document.getElementById('currrelid').value;
    //alert(currrelid);
	//alert('action=ImportXls_Popup&module=XlsImport&xlsStep=Third&importmodel='+importmodel+urlvalue+'&recordid='+recordid+'&currrelid='+currrelid);
    new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody: 'action=ImportXls_Popup&module=XlsImport&xlsStep=Third&importmodel='+importmodel+urlvalue+'&recordid='+recordid+'&currrelid='+currrelid,
			onComplete: function(response) {
    			$("status").style.display="none";
    			$("actiondiv").style.display ='none';
                $("actiondiv").style.zIndex='9999';
    			$("actiondiv").innerHTML=response.responseText;
                fnvshobj(this,'actiondiv');closeNewDiv();
			}
		}
		); 
}
/*
导入插件调用
*/
function setUpload (importmodel){
	var myatt_id=0;
  
    
	var myatt_moduel=importmodel;
	var is_type = 0;
	UploadBind('potentialimportcontacts',new function(){
		this.select = function(file){
			if(file.size < 10485760){// 10 * 1024 * 2014(10MB)
				//var fieldtype = new Array('xls');
				var file_type=file.type;
				var field_arr = file_type.split('.');
				field_arr[1] = field_arr[1].toLowerCase();
				if(field_arr[1] != 'xls' && field_arr[1] != 'xlsx'){
					var confirm_str = arrJsPopLabel['FILEFORMATCORRECT'] +'\n'+file.name;
					RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
					ld('#potentialimportcontacts').uploadify('stop');
					ld('#potentialimportcontacts').uploadify('cancel');
					ld('#potentialimportcontacts').onCancel(file);
					return false;
				}
				is_type = 1;
				/*for(var i =0;i<fieldtype.length;i++){
					if(fieldtype[i] == field_arr[1]){
						is_type = 1;break;
					}
				}*/
			}
			/*if(is_type == 0){
				alert(onlyjpggifimg +'\n'+file.name);
				ld('#multiple').uploadify('stop');
				ld('#multiple').uploadify('cancel');
				ld('#multiple').onCancel(file);
				return false;
			}*/
		},
		this.start = function(file){
			if(is_type == 1){
				myatt_id = document.getElementById("current_userid").value;
				//alert(myatt_id);
				var str = {'myatt_id':myatt_id,'myatt_moduel':myatt_moduel,'uploadtype':'uploadimg'};
				ld('#potentialimportcontacts').uploadify('settings','method','post');
				ld('#potentialimportcontacts').uploadify('settings','formData',str);
			}
		},
		this.success = function(file, data, response){
			if(ld('#files') != undefined){
				ld('#files').html(file.name);
			}
			if(empty(data)) return false;
			var restobj = eval('('+ data +')')?eval('('+ data +')'):JSON.parse(data);
			if(empty(restobj.record)) return false;
			var tag = '';
			ld('#stream-hsent-title > li > a').each(function(){
				if('curr' == ld(this).attr('class')){
					tag = ld(this).attr('cont');
				}
			});
			if('' == tag) tag = 'sendLog';
			ld('#'+tag+'UploadImg ul').append('<li record="'+restobj.record+'"><span class="item-name"><img class="name-img" alt="" src="'+restobj.path+restobj.name+'"></span><span class="remove-h">×</span></li>');
			ld('#'+tag+'UploadImg').css('display','');
			//绑定移入显示删除标志事件
			ld('#'+tag+'UploadImg ul li').on('mouseenter',function(){
				//alert('here 1');
				ld(this).find('span.remove-h').css('display','inline');
			});
			//绑定移出隐藏删除标志事件
			ld('#'+tag+'UploadImg ul li').on('mouseleave',function(){
				ld(this).find('span.remove-h').css('display','none');
			});
			//绑定图片删除事件
			ld('#'+tag+'UploadImg ul li span.remove-h').on('click',function(){
				var record = ld(this).parent().attr('record');
				ld('#'+tag+'UploadImg ul li[record='+record+']').remove();
				if(0 == ld('#'+tag+'UploadImg ul li').length){
					ld('#'+tag+'UploadImg').css('display','none');
				}
				return false;
			});
		},
		this.end = function(){
			ld('#potentialimportcontacts').addClass('multiple-div');
		}
	});
}

/**
 * flash上传图片加载事件集成方法
 * @author Tujt 2015-02-10
 */
function UploadBind(ids,callback){
	var maxfilesize = 100 * 1024 * 1024;
  
    
	ld('#'+ids).uploadify({
		//uploadify.swf文件的路径。如果可能的话，这个路径应该是相对于根以避免出现问题，但也将接受相对于当前脚本的路径。
		'swf'      : 'uploaddify/uploadify.swf',//默认为uploadify.swf
		'uploader' : 'modules/XlsImport/ImportXls_upload.php',//服务端处理脚本,
		'buttonText': arrJsPopLabel['IMPORT'],//按扭的文字 arrJsPopLabel['BROWSETHEFILE']
		'height' : 20,//按扭高度
		'width' :50 ,//按扭宽度
		'onDialogClose':function(){},
		'buttonClass':'mybutton',
		'removeTimeout':1,
		'progressData':'percentage',
		'queueID'  : 'queue',
		//'queueSizeLimit':10,
	     'debug':true,
		'uploadLimit':1,
		'successTimeout' : 5,
		//上传成功回调函数
		'onUploadSuccess' : function(file, data, response) {
			if(!empty(callback.success)){
				data = trim(data);
				callback.success(file, data, response);
			}
		},
		//上传完成
		//会先调用onUploadSuccess然后才调用onUploadComplete
		'onUploadComplete' : function(file) {
			if(!empty(callback.complete)){
				callback.complete(file);
			}
		},
		//从对话框回选择了文件
		//对不起，目前只支持单文件上传,'+ file_name_value1+ ' 已经上传成功! 
		'onSelectError' : function(file,errorCode,errorMsg) {
		  
			if(!empty(callback.error)){
				callback.error(file,errorCode,errorMsg);
			}
		},

		//上传进度
		'onUploadProgress' : function(file, bytesUploaded, bytesTotal, totalBytesUploaded, totalBytesTotal) {
			ld('#progress').html(totalBytesUploaded + ' bytes uploaded of ' + totalBytesTotal + ' bytes.');
		},
	
		//开始上传
		'onUploadStart' : function(file) {
			if(!empty(callback.start)){
				callback.start(file);
			}
		}, 
		//选择上传文件时触发。
		'onSelect':function(file)
		{
			if(!empty(callback.select)){
				callback.select(file);
			}
		},
	});
	if(!empty(callback.end)){
		callback.end();
	}
}

calendarParentid="ImportXlsDiv";
function defaultImportXls(obj,rowindex)
 {
    
    var tab=document.getElementById('Importtable');
    rowindex=parseInt(rowindex)+1;
    var cellobj=tab.rows[rowindex].cells[3];
    var oldspanobj=cellobj.firstChild;
    var parentnode=cellobj;
    var optvalue=obj.options[obj.selectedIndex].value;
    var newspanobj=document.getElementById(optvalue+'-defaultvalue-container');
    var defaultValuesElementsContainer=document.getElementById('defaultValuesElementsContainer');
    var childhtml= parentnode.innerHTML;
     if(newspanobj.parentNode.id==undefined||newspanobj.parentNode.id=='')
     {
        
          parentnode.innerHTML='';
          defaultValuesElementsContainer.innerHTML+=childhtml;
        
         return ;
     }
   
    parentnode.innerHTML='';
    defaultValuesElementsContainer.removeChild(newspanobj);
    parentnode.appendChild(newspanobj);
    defaultValuesElementsContainer.innerHTML+=childhtml;;
   
 }
 
 //获取页面数组，并json传到php页面
 function ImportXlsSecondStep(obj,importmodel)
 {
     var mappfields=document.getElementsByName('mapped_fields[]');
     var optvalues=''
     var arrimport;
     for(var i=0;i<mappfields.length;i++)
     {
        optvalues=optvalues+mappfields[i].options[mappfields[i].selectedIndex].value+',';
     }
     
     var mapped_fields=document.getElementsByName('mapped_fields[]');
     var mapped_fieldsList=new Array();
     var defaultvalueList=new Array();
     for(var i=0;i<mapped_fields.length;i++)
     {
        mapped_fieldsList[i]=mapped_fields[i].value;
        if(mapped_fields[i].value!='none-field'){
            defaultvalueList[i]=document.getElementById(mapped_fields[i].value+'-defaultvalue').value;
        }
     }
     
     var isfieldnamevalue=document.getElementsByName('isfieldnamevalue[]');
     var isfieldnamevalueList=new Array();
     for(var i=0;i<isfieldnamevalue.length;i++)
     {
        isfieldnamevalueList[i]=isfieldnamevalue[i].value;
     }
     
     var isfieldname=document.getElementsByName('isfieldname[]');
     var isfieldnameList=new Array();
     for(var i=0;i<isfieldname.length;i++)
     {
        isfieldnameList[i]=isfieldname[i].value;
     }
     
     for(var i=0;i<mappfields.length;i++)
     {
            
            importopt=mappfields[i].options[mappfields[i].selectedIndex].value;
          
             for(var j=0;j<mappfields.length;j++)
             {
                if(mappfields[i].options[mappfields[i].selectedIndex].value!='none-field'&&j!=i&&mappfields[i].options[mappfields[i].selectedIndex].value==mappfields[j].options[mappfields[j].selectedIndex].value&&mappfields[j].options[mappfields[j].selectedIndex].value != 'taxclass-field')
                {
					var jspop = arrJsPopLabel['FIELDMATCHESTIMES'];
					jspop = jspop.replace("$fldname$",mappfields[i].options[mappfields[i].selectedIndex].text);
                    RemindsMsg("","LdPopWidth400px","","yes","",jspop);
                    return false;
                }
             }
             
     }
     var mapped_fieldsListListjson=JSON.stringify(mapped_fieldsList);
     var defaultvalueListjson=JSON.stringify(defaultvalueList);
     var isfieldnamevalueListjson=JSON.stringify(isfieldnamevalueList);
     var isfieldnameListjson=JSON.stringify(isfieldnameList);
            openNewDiv('newDiv');
    showDivImportThird(importmodel,mapped_fieldsListListjson,defaultvalueListjson,isfieldnamevalueListjson,isfieldnameListjson);
 }