

function CrmPopupWindow(a,b){getJsScript('include/js/SystemPopup/CrmPopupWindows.js',function(){fun_setCrmPopupWindow(a,b);});}
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
var gValidationCall='';
if (document.all)
	var browser_ie=true
else if (document.layers)
	var browser_nn4=true
else if (document.layers || (!document.all && document.getElementById))
	var browser_nn6=true
var gBrowserAgent = navigator.userAgent.toLowerCase();


function getObj(n,d) {
	var p,i,x;
	if(!d) d=document;
	if(n != undefined) {
		if((p=n.indexOf("?"))>0&&parent.frames.length) {
			d=parent.frames[n.substring(p+1)].document;
			n=n.substring(0,p);
		}
	}
	if(d.getElementById) {
		x=d.getElementById(n);
		if(x && x.id != n) x = false;
	}
    if(d.forms==undefined ){
        x=d[n];
    }else{
        for(i=0;!x && i<d.forms.length;i++) {
            x=d.forms[i][n];
        }
    }
	for(i=0; !x && d.layers && i<d.layers.length;i++) {
		x=getObj(n,d.layers[i].document);
	}
	if(!x && !(x=d[n]) && d.all) x=d.all[n];
	if(typeof x == 'string') x=null;
	return x;
}
function getOpenerObj(n) {return getObj(n,opener.document)}
function findPosX(obj) {
	var curleft = 0;
	if (document.getElementById || document.all) {
		while (obj.offsetParent) {
			curleft += obj.offsetLeft
			obj = obj.offsetParent;
		}
	} else if (document.layers) {
		curleft += obj.x;
	}
	return curleft;
}
function findPosY(obj) {
	var curtop = 0;
	if (document.getElementById || document.all) {
		while (obj.offsetParent) {
			curtop += obj.offsetTop
			obj = obj.offsetParent;
		}
	}else if (document.layers) {
		curtop += obj.y;
	}
	return curtop;
}


/**
*更新操作
*edit:kevin
*date:2013-11-27
*reason:
*/
function fnvshobj(obj,idname)
{
    var isIE = (document.all) ? true : false;
    //var isIE6 = isIE && ([/MSIE (\d)\.0/i.exec(navigator.userAgent)][0][1] == 6);
    var isIE6 = isIE;
    var newbox=document.getElementById(idname);
	//editor:gyqX160811  Bug:0023798: 页面设置>付款计划>页面设置：新增区块保存后再点击【新增区块】按钮，弹出层的值没有清空
	if(idname == 'addblock'){
		ld('#blocklabel,#blocklabel2,#after_blockid').val('');
	}
    if(idname=='approvestepresult' || idname=='approvelog' || idname=='check_repeat'|| idname=='selectrelateddiv'){
		if(ld("#qcformDiv").css('display')=='block')
			 newbox.style.zIndex="10201";
		else if(ld("#Second_qcformDiv").css('display')=='block')
			 newbox.style.zIndex="10203";
		else
			newbox.style.zIndex="10100";
	}else if(idname=='qcformDiv')
        newbox.style.zIndex="10200";
    else if(idname=='Second_qcformDiv')
        newbox.style.zIndex="10202";
    else if(idname=='div_check_repeat')
    	newbox.style.zIndex="10300";
    else if(idname=='div_setDuplicates' || idname=='setColumnDisplay')
        newbox.style.zIndex="10400";
    else
        newbox.style.zIndex="9999";
        newbox.style.display="block";
    
    if(idname =='check_repeat')
    {
        newbox.style.position = "absolute";
    }
    else
    {
        newbox.style.position = (!isIE6 && (idname !='check_repeat' || !isIE))? "fixed" : "absolute";    
    }
    if(idname =='EditWorkingSpace'){
       newbox.style.top='40%';
       newbox.style.left = "50%";  
    }else{
       newbox.style.top =newbox.style.left = "50%"; 
    }  
    if(newbox.offsetHeight == 0)
    {
        newbox.style.marginTop = - 130  + "px";
    }
    else
    {   
        if(idname == 'qcbomnumberDiv'){
            newbox.style.marginTop = - newbox.clientHeight / 2 -115 + "px";
        }else{
            if(document.all){
				newbox.style.marginTop = - newbox.offsetHeight / 2 + document.documentElement.scrollTop +"px";
			}

            else{
				newbox.style.marginTop = - newbox.offsetHeight / 2 +"px";
				/*
				* editor:gyq_05  gyq_09
				* reason:根据新增审批通知标签页高度微调审批弹框上边距
				* date : 2016 2 23
				* reason:派息规则界面上边距微调
				  date:2016 4 5
				* */
				//idname == 'approvestep' || 0028125: 控制面板>审批流程管理：新增审批步骤，弹出框没有显示在居中位置。
				if(idname == 'Products_dividendRules'){
					newbox.style.marginTop = - newbox.offsetHeight / 2 - 80 + "px";
				}
			}

        }

    }
    newbox.style.marginLeft = - newbox.offsetWidth / 2 + "px";  
    
    if(!document.getElementById("layer"))
    {
        var layer=document.createElement("div");
        layer.id="layer";
        layer.style.width=layer.style.height="100%";
        //(!isIE6 && (idname !='check_repeat' || !isIE)) ? "fixed" : "absolute"
        layer.style.position= "fixed";
      
        layer.style.top=layer.style.left=0;
        layer.style.backgroundColor="#808080";
        layer.style.zIndex="9998";
        layer.style.opacity="0.6";
        if(idname == 'check_repeat')//快速创建中客户查重
        {
            //puyoungJS_DialogBox.unblock();
        }
        else
        {
            document.body.appendChild(layer);
        }
    }
    else
    {
        var layer=document.getElementById("layer");
    }
    var sel=document.getElementsByTagName("select");
    if(isIE){layer.style.filter ="alpha(opacity=60)";}
    //14582: 关于"高级"弹出层显示问题
    /*function layer_iestyle(){      
        layer.style.width=Math.max(document.documentElement.scrollWidth, document.documentElement.clientWidth)+ "px";
        layer.style.height= Math.max(document.documentElement.scrollHeight, document.documentElement.clientHeight) +"px";
    }*/
   
    function newbox_iestyle(){   
        //17323: 首页>组件视图：销售漏斗点击后，弹出层显示在最上方，需要滑动滚动条到最上方才能看到弹出层
        if(document.documentElement.scrollTop - newbox.offsetHeight / 2>0)
        {
            newbox.style.marginTop = document.documentElement.scrollTop - newbox.offsetHeight / 2 + "px";
       
            newbox.style.marginLeft = document.documentElement.scrollLeft - newbox.offsetWidth / 2 + "px";
        }
        else
        {
            newbox.style.top=( document.documentElement.clientHeight-newbox.offsetHeight)/2+document.documentElement.scrollTop+"px";   
            //23898：审批流程管理 > 产品 ，【新增审批步骤】弹出窗口贴顶部且被挡住的部分内容
            newbox.style.marginTop=0;
        }
        
    }
 
    
    if(isIE6){  
        //layer_iestyle()
      //17323: 首页>组件视图：销售漏斗点击后，弹出层显示在最上方，需要滑动滚动条到最上方才能看到弹出层
        //newbox_iestyle();
        window.attachEvent("onscroll",function(){                              
            newbox_iestyle();
        })
        
       // window.attachEvent("onresize",layer_iestyle);          
    }
 
}

function emptyCheck(fldName,fldLabel,fldType) {
//	var currObj = getObj(fldName);
	var currObj;
	var popupobj=CrmPopup.getPopupObj("last");
	if(popupobj != undefined){
		currObj=CrmPopup.findHtmlobj(popupobj.divid,fldName);
	}

  
    if(fldName=='filename')
    {
     
        //31845: 附件管理新增界面：添加附件，在删除掉添加的附件。结果：也能保存。
        for(var i=0;i<=60;i++)
        {
            if(CrmPopup.findHtmlobj(popupobj.divid,'filename-file_name_'+i)!=undefined&&CrmPopup.findHtmlobj(popupobj.divid,'filename-file_name_'+i).length>0&&
                CrmPopup.findHtmlobj(popupobj.divid,'filename-file_name_'+i).val()!='')
            {
                return true;
            }
            
        }
	        var confirm_str = fldLabel+arrJsPopLabel['CANOTEMPTY'];
	    	RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
    }
    if(currObj=='undefined'||currObj==undefined)
    {
        return true;
    }

	if (fldType=="text") {
		if (currObj.val() != undefined && currObj.val().replace(/^\s+/g, '').replace(/\s+$/g, '').length==0) {
			var confirm_str = fldLabel+arrJsPopLabel['CANOTEMPTY'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			try {
				currObj.focus()
			} catch(error) {
		
			}
			return false
		}
		else{  
			return true
		}
	}else if((fldType == "textarea")
		&& (typeof(CKEDITOR)!=='undefined' && CKEDITOR.intances[fldName] !== 'undefined')) {

		var textObj = CKEDITOR.intances[fldName];
		var textValue = textObj.getData();
		if (trim(textValue) == '' || trim(textValue) == '<br>') {
			var confirm_str = fldLabel+arrJsPopLabel['CANOTEMPTY'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			return false;
		} else{
			return true;
		}
	}
    else if(fldType=='select-multiple')
    {
        //23925: 联系人>编辑：多选框字段设为必填字段，编辑联系人，保存提示“多选框”不能为空。实际上已经录入内容。
        if(CrmPopup.findHtmlobj(this.divid,curr_fieldname).find( "option:selected").length<=0){
        	var confirm_str = fldLabel+arrJsPopLabel['CANOTEMPTY'];
        	RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			return false;
        }
    }
    else if(currObj.prop("tagName")!=undefined&&currObj.prop("tagName").toLowerCase()=='select')
    {
        if(trim(currObj.find("option:selected").text())=='')
        {
            var confirm_str = fldLabel+arrJsPopLabel['CANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        }
    }
    	else{
	  
		if (trim(currObj.val()) == '' || trim(currObj.val()) == '0') {
			var confirm_str = fldLabel+arrJsPopLabel['CANOTEMPTY'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			return false
		} else
			return true
	}
    return true;
}

function clearId(fldName){var currObj=getObj(fldName);currObj.value='';}
function comparestartdate(chkdate) {var currdate = new Date();
return compareDates(chkdate,arrJsPopLabel['STARTTIME'],currdate,arrJsPopLabel['CURRENTTIMESTATEISPLANNED'],"GE");}

//自动执行的js，暂时不知道是干什么的
var scrX=0,scrY=0,pgeX=0,pgeY=0;
if (browser_nn4 || browser_nn6) {
	document.addEventListener("click",popUpListener,true)
}
function popUpListener(ev) {
	if (browser_nn4 || browser_nn6) {
		scrX=ev.screenX
		scrY=ev.screenY
		pgeX=ev.pageX
		pgeY=ev.pageY
	}
}
function toggleDiv(id) {
	var listTableObj=getObj(id)
	if (listTableObj.style.display=="block")
		listTableObj.style.display="none"
	else listTableObj.style.display="block"
}

function show(divId){ld('#'+divId).css('display','inline');}
function hide(divId){ld('#'+divId).css('display','none');}
function showBlock(divId){
	var id = document.getElementById(divId);
	id.style.display = 'block';
    if(document.getElementById("reminderOptions3")!=undefined)
        document.getElementById("reminderOptions3").style.display="block";
}
function fnhide(divId){
	var id = document.getElementById(divId);
	id.style.display = 'none';
    //Edit by LD Can  邮件提醒添加提醒框
    if(document.getElementById("reminderOptions2")!=undefined && document.getElementById("reminderOptions")!=undefined)
        if(document.getElementById("reminderOptions2").style.display=="none" && document.getElementById("reminderOptions").style.display=="none")
            document.getElementById("reminderOptions3").style.display="none";
}

function fnCopy(source,design){
	document.getElementById(source).value=document.getElementById(design).value;
	document.getElementById(source).disabled=true;
}
function fnClear(source){
	document.getElementById(source).value=" ";
	document.getElementById(source).disabled=false;
}
/*
* javascript function to add field rows
* @param option_values :: List of Field names
*/
var count = 0;
var rowCnt = 1;
function fnvsh(obj,Lay){
	var tagName = document.getElementById(Lay);
	var leftSide = findPosX(obj);
	var topSide = findPosY(obj);
	tagName.style.left= leftSide + 175 + 'px';
	tagName.style.top= topSide + 'px';
	tagName.style.visibility = 'visible';
}
function hideOptions(id){hide(id);}

function fnvshobj_back(a,b){getJsScript('include/js/ldcrm.core.js',function(){fnvshobj_backs(a,b);});}
function posLay(a,b){getJsScript('include/js/ldcrm.core.js',function(){posLays(a,b);});}
function fninvsh(a){getJsScript('include/js/ldcrm.core.js',function(){fninvshs(a);});}
/*
edit:can
date:20140306
reason:获取月份最大天数
*/
function getDaysInMonth(year,month){
    month = parseInt(month,10);  
    var temp = new Date(year,month,0);
    return temp.getDate();
}
function fninvshnew(idname){
	puyoungJS_DialogBox.unblock();
	if(document.getElementById(idname) != undefined){
		var newbox=document.getElementById(idname);
		newbox.style.display="none";	
	}
    if(idname=='qcformDiv'&& typeof isPopupButton!=undefined)//用于选择客户，联系人等判断弹出框是否为快速创建
    {
        isPopupButton='no';
		if(document.getElementById('qcform') != undefined){
			document.getElementById('qcform').innerHTML = '';	
		}
        cur_PageInfo.clear();
    }
    
    
}
function fnvshNrm(Lay){
	var tagName = document.getElementById(Lay);
	tagName.style.visibility = 'visible';
	tagName.style.display = 'block';
    show(Lay);
    puyoungJS_DialogBox.block();
}
function cancelForm(frm){window.history.back();}
function trim(str){
	if(str != '' && str != undefined){
		var s = str.replace(/\s+$/,'');
		s = s.replace(/^\s+/,'');
		return s;
	}
	return '';
}
function clear_form(form){
	for (j = 0; j < form.elements.length; j++){
		if (form.elements[j].type == 'text' || form.elements[j].type == 'select-one')
			form.elements[j].value = '';
	}
}
function ActivateCheckBox(){
	var map = document.getElementById("saved_map_checkbox");
	var source = document.getElementById("saved_source");
	if(map.checked == true){
		source.disabled = false;
	}else source.disabled = true;
}

function fnHide_Event(obj){document.getElementById(obj).style.visibility = 'hidden';}
function ReplyCompose(id,mode){
	var url = 'index.php?module=Emails&action=EmailsAjax&file=EditView&record='+id+'&reply=true';
	openPopUp('xComposeEmail',this,url,'createemailWin',820,689,'menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes');
}

function ShowEmail(id){
	url = 'index.php?module=Emails&action=EmailsAjax&file=DetailView&record='+id;
	openPopUp('xComposeEmail',this,url,'createemailWin',820,695,'menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes');
}
var bSaf = (navigator.userAgent.indexOf('Safari') != -1);
var bOpera = (navigator.userAgent.indexOf('Opera') != -1);
var bMoz = (navigator.appName == 'Netscape');

function fnDropDown(a,b,c){getJsScript('include/js/ldcrm.core.js',function(){fnDropDowns(a,b,c);});}
function fnShowDrop(obj){
    if(document.getElementById(obj)!=undefined)
	document.getElementById(obj).style.display = 'block';
}
function fnHideDrop(obj){
    if(document.getElementById(obj)!=undefined)
	document.getElementById(obj).style.display = 'none';
}
function _2digit( no ){
	if(no < 10) return "0" + no;
	else return "" + no;
}
//function modified to apply the patch ref : Ticket #4065
function valid(c,type){
	if(type == 'name'){
		return (((c >= 'a') && (c <= 'z')) ||((c >= 'A') && (c <= 'Z')) ||((c >= '0') && (c <= '9')) || (c == '.') || (c == '_') || (c == '-') || (c == '@') );
	}else if(type == 'namespace'){
		return (((c >= 'a') && (c <= 'z')) ||((c >= 'A') && (c <= 'Z')) ||((c >= '0') && (c <= '9')) || (c == '.')||(c==' ') || (c == '_') || (c == '-') );
	}
}
function CharValidation(s,type){
	for (var i = 0; i < s.length; i++){
		if (!valid(s.charAt(i),type))
			return false;
	}
	return true;
}

function LTrim( value ){var re = /\s*((\S+\s*)*)/;return value.replace(re, "$1");}
function selectedRecords(a,b){getJsScript('include/js/ldcrm.core.js',function(){selectedRecordss(a,b);});}
function expoer_account(a,b,c,d){getJsScript('include/js/ldcrm.core.js',function(){expoer_accounts(a,b,c,d);});}

function hideErrorMsg1(){$('not_search').style.display = 'none';}
function escapeAll(tagValue){return encodeURIComponent(tagValue.replace(/%/g, '%25'));}
function removeHTMLFormatting(str) {
	str = str.replace(/<([^<>]*)>/g, " ");
	str = str.replace(/&nbsp;/g, " ");
	return str;
}
function get_converted_html(str){
	var temp = str.toLowerCase();
	if(temp.indexOf('<') != '-1' || temp.indexOf('>') != '-1'){
		str = str.replace(/</g,'&lt;');
		str = str.replace(/>/g,'&gt;');
	}
	if( temp.match(/(script).*(\/script)/))
		str = str.replace(/&/g,'&amp;');
	else if(temp.indexOf('&') != '-1')
		str = str.replace(/&/g,'&amp;');
	return str;
}

function gotourl(url){document.location.href=url;}


/**
edit:can
reason:产品编辑界面更多币种弹出框隐藏和显示
**/
function fnshowHide(currObj,txtObj) {
	if(currObj.checked == true)
		document.getElementById(txtObj).style.visibility = 'visible';
	else
		document.getElementById(txtObj).style.visibility = 'hidden';
}
/**
*edit:kevin
*date:2013-05-30
*reason:4050
numValidate(txtObj,'Tax',"any")
*/
function fntaxValidation(txtObj) {
	if (!numValidate(txtObj,arrJsPopLabel['SURTAXESSALESSERVICE'],"any"))
		document.getElementById(txtObj).value = 0;
}
function fnpriceValidation(txtObj) {
	if (!numValidate(txtObj,"Price","any"))
		document.getElementById(txtObj).value = 0;
}
// Function to enable/disable related elements based on whether the current object is checked or not
function fnenableDisable(currObj,enableId,price_type) {
	var disable_flag = true;
	if(currObj.checked == true)
		disable_flag = false;
  
    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
  
    CrmPopup.findHtmlobj(divid,price_type+'_curname'+enableId).attr("disabled",disable_flag); 
//	document.getElementById(price_type+'_curname'+enableId).disabled = disable_flag;
}

function positionDivToCenter(targetDiv){
	getViewPortDimension();
	divWidth =(parseInt(document.getElementById(targetDiv).style.width))/2;
	divHeight=(parseInt(document.getElementById(targetDiv).style.height))/2;
	mx = parseInt(XX/2)-parseInt(divWidth);
	my = parseInt(YY/3)-parseInt(divHeight);
	document.getElementById(targetDiv).style.left=mx+"px";
	document.getElementById(targetDiv).style.top=my+"px";
}
function getViewPortDimension(){
	if(!document.all){
		XX = self.innerWidth;
		YY = self.innerHeight;
	}else if(document.all){
		XX = document.documentElement.clientWidth;
		YY = document.documentElement.clientHeight;
	}
}
function toggleTable(id) {
	var listTableObj=getObj(id);
	if(listTableObj.style.display=="none")
		listTableObj.style.display="";
	else
		listTableObj.style.display="none";
}
function FileAdd(obj,Lay,return_action){
	fnvshobj(obj,Lay);
	window.frames['AddFile'].document.getElementById('divHeader').innerHTML="Add file";
	window.frames['AddFile'].document.FileAdd.return_action.value=return_action;
	positionDivToCenter(Lay);
}
function placeAtCenter(id){
	var centerPixel = getViewPortCenter();
	document.getElementById(id).style.position = "absolute";
	var point = getDimension(id);
	var topvalue = (centerPixel.y - point.y/2) ;
	var rightvalue = (centerPixel.x - point.x/2);
	if(topvalue<0) topvalue = 0;
	if(rightvalue < 0) rightvalue = 0;
	if(topvalue<80)
		document.getElementById(id).style.top = topvalue  + "px";
	else
		document.getElementById(id).style.top = topvalue - 80 + "px";
	document.getElementById(id).style.right =rightvalue + 250 + "px";
}

/**
 * this function gets the dimension of a node
 * @param node - the node whose dimension you want
 * @return height and width in array format
 */
function getDimension(id){
    if(document.getElementById(id)==undefined) return;
	var ht = document.getElementById(id).offsetHeight;
	var wdth = document.getElementById(id).offsetWidth;
	var nodeChildren = document.getElementById(id).getElementsByTagName("*");
	//var nodeChildren = 1;
    var noOfChildren = nodeChildren.length;
	for(var index =0;index<noOfChildren;++index){
		ht = Math.max(nodeChildren[index].offsetHeight, ht);
		wdth = Math.max(nodeChildren[index].offsetWidth,wdth);
	}
	return {
		x: wdth,
		y: ht
	};
}



/*
who:BY LD CAN
Date:20130118
reason:鎵€鏈夋槑缁嗙晫闈㈠鍔犺繑鍥炲垪琛ㄥ拰鏂板鎸夐挳
*/
function NewInfo(event,module,parenttab){
    window.location="index.php?module="+module+"&action=EditView&return_action=DetailView&parenttab="+parenttab;
}
function submitFormForAction(a,b){getJsScript('include/js/ldcrm.core.js',function(){submitFormForActions(a,b);});}
/** Javascript dialog box utility functions **/
puyoungJS_DialogBox = {
	_olayer : function(toggle) {
		var olayerid = "__puyoungjs_dialogbox_olayer__";
		puyoungJS_DialogBox._removebyid(olayerid);
		if(typeof(toggle) == 'undefined' || !toggle) return;
		var olayer = document.getElementById(olayerid);
		if(!olayer) {
			olayer = document.createElement("div");
			olayer.id = olayerid;
			olayer.className = "small veil veil_p";
			olayer.style.zIndex = 1;
			if(olayer.style.zIndex < 0) olayer.style.zIndex *= -1;
			if (browser_ie) {
				olayer.style.height = document.body.offsetHeight + (document.body.scrollHeight - document.body.offsetHeight) + "px";
			} else if (browser_nn4 || browser_nn6) {
				olayer.style.height = document.body.offsetHeight + "px";
			}
			olayer.style.width = "100%";
            olayer.style.height = "100%";
			document.body.appendChild(olayer);
		}
		if(olayer) {
		  olayer.style.zIndex = 1001;
			if(toggle) olayer.style.display = "block";
			else olayer.style.display = "none";
		}
		return olayer;
	},
	_removebyid : function(id) {
		if($(id)) $(id).remove();
	},
	unblock : function() {
	   if(document.getElementById("layer"))
       {
        var layer=document.getElementById('layer');
        layer.style.display="none";
        document.body.removeChild(layer); 
       }
       if(document.getElementById("olayernodeid"))
       {
        var olayer=document.getElementById("olayernodeid");
        olayer.style.display = "none";
        document.body.removeChild(olayer);
       }
	},
	block : function(opacity) {
	  if(!document.getElementById("layer")&&!document.getElementById("olayernodeid")){
		if(typeof(opactiy)=='undefined') opacity = '0.5';
		var olayernode = puyoungJS_DialogBox._olayer(true); 
        olayernode.id="olayernodeid";     
        olayernode.className = 'mask opacity';
		olayernode.style.opacity = opacity;
       }
	},
	hideprogress : function() {
		puyoungJS_DialogBox._olayer(false);
		puyoungJS_DialogBox._removebyid('__puyoungjs_dialogbox_progress_id__');
	},
	progress : function(imgurl) {
		puyoungJS_DialogBox._olayer(true);
        if(typeof(imgurl) == 'undefined') imgurl = 'themes/images/plsWaitAnimated.gif';
		var prgbxid = "__puyoungjs_dialogbox_progress_id__";
		var prgnode = document.getElementById(prgbxid);
		if(!prgnode) {
			prgnode = document.createElement("div");
			prgnode.id = prgbxid;
			prgnode.className = 'veil_new';
			prgnode.style.position = 'absolute';
			prgnode.style.width = '100%';
			prgnode.style.top = '0';
			prgnode.style.left = '0';
			prgnode.style.display = 'block';
			document.body.appendChild(prgnode);
			prgnode.innerHTML =
			'<table border="0" cellpadding="0" cellspacing="0" align="center" style="vertical-align:middle;width:100%;height:100%;">' +
			'<tr><td class="big" align="center"><img src="'+ imgurl + '"></td></tr></table>';
		}
		if(prgnode) prgnode.style.display = 'block';
	},
	hideconfirm : function() {
		puyoungJS_DialogBox._olayer(false);
		puyoungJS_DialogBox._removebyid('__puyoungjs_dialogbox_alert_boxid__');
	},
	confirm : function(msg, onyescode) {
		puyoungJS_DialogBox._olayer(true);

		var dlgbxid = "__puyoungjs_dialogbox_alert_boxid__";
		var dlgbxnode = document.getElementById(dlgbxid);
		if(!dlgbxnode) {
			dlgbxnode = document.createElement("div");
			dlgbxnode.style.display = 'none';
			dlgbxnode.className = 'veil_new small';
			dlgbxnode.id = dlgbxid;
			dlgbxnode.innerHTML =
			'<table cellspacing="0" cellpadding="18" border="0" class="options small">' +
			'<tbody>' +
			'<tr>' +
			'<td nowrap="" align="center" style="color: rgb(255, 255, 255); font-size: 15px;">' +
			'<b>'+ msg + '</b></td>' +
			'</tr>' +
			'<tr>' +
			'<td align="center">' +
			'<input type="button" style="text-transform: capitalize;" onclick="$(\''+ dlgbxid + '\').hide();puyoungJS_DialogBox._olayer(false);puyoungJS_DialogBox._confirm_handler();" value="'+ arrJsPopLabel['YES'] + '"/>' +
			'<input type="button" style="text-transform: capitalize;" onclick="$(\''+ dlgbxid + '\').hide();puyoungJS_DialogBox._olayer(false)" value="' + arrJsPopLabel['NO'] + '"/>' +
			'</td>'+
			'</tr>' +
			'</tbody>' +
			'</table>';
			document.body.appendChild(dlgbxnode);
		}
		if(typeof(onyescode) == 'undefined') onyescode = '';
		dlgbxnode._onyescode = onyescode;
		if(dlgbxnode) dlgbxnode.style.display = 'block';
	},
	_confirm_handler : function() {
		var dlgbxid = "__puyoungjs_dialogbox_alert_boxid__";
		var dlgbxnode = document.getElementById(dlgbxid);
		if(dlgbxnode) {
			if(typeof(dlgbxnode._onyescode) != 'undefined' && dlgbxnode._onyescode != '') {
				eval(dlgbxnode._onyescode);
			}
		}
	}
}

function convertOptionsToJSONArray(objName,targetObjName) {
	var obj = $(objName);
	var arr = [];
	if(typeof(obj) != 'undefined') {
		for (i=0; i<obj.options.length; ++i) {
			arr.push(obj.options[i].value);
		}
	}
	if(targetObjName != 'undefined') {
		var targetObj = $(targetObjName);
		if(typeof(targetObj) != 'undefined') targetObj.value = JSON.stringify(arr);
	}
	return arr;
}
function fnvshobjMore(a,b,c){getJsScript('include/js/ldcrm.core.js',function(){fnvshobjMores(a,b,c);});}

function updateParentCheckbox(obj,id){
	var parentCheck=true;
	if (obj) {
		for (var i=0; i<obj.length; ++i) {
			if(obj[i].checked != true){
				var parentCheck=false;
			}
		}
	}
	if(parentCheck){
		$(id+'_selectCurrentPageRec').checked=parentCheck;
	}
}

function showSelectAllLink(obj,exculdedArray){
	var viewForSelectLink = true;
	for (var i=0; i<obj.length; ++i) {
		obj[i].checked = true;
		for(var j=0; j<exculdedArray.length; ++j) {
			if(exculdedArray[j] == obj[i].value) {
				obj[i].checked = false;
				viewForSelectLink = false;
			}
		}
	}
	return viewForSelectLink;
}



function addListener(element, e, fn) {
    if (element.addEventListener) {
        element.addEventListener(e, fn, false);
    } else {
        element.attachEvent("on" + e, fn);
    }
}
function BodyClick(obj,lay){
    addListener(document, "click",
    function(evt) {
        var evt = window.event ? window.event: evt,
        target = evt.srcElement || evt.target;
        
        if (target == obj||target.id == lay||target.parentNode==undefined) {
            document.getElementById(lay).style.display = "";
            document.getElementById(lay).style.zIndex=1; 
            return;
        } else {
            while (target.nodeName.toLowerCase()) {
                target = target.parentNode;
                if(target==undefined)
                {
                    document.getElementById(lay).style.display="";
                    return ;
                }
                if (target== obj||target.id == lay) {
                    document.getElementById(lay).style.display = "";
                    return;
                }
                if (target.nodeName.toLowerCase() == "body") {
                    document.getElementById(lay).style.display = "none";
                    return;
                }
            }
        }
    });
}

function fn_display_div(){
    obj=document.getElementById('reminds_popup');
    if(obj!=undefined)
    obj.style.display='';
	if(ld('#reminds_popup_expansion') != undefined){
		ld('#reminds_popup_expansion').hide();
	}
}
function fn_close_div(){
    obj=document.getElementById('reminds_popup');
    if(obj!=undefined)
    obj.style.display='none';
	if(ld('#reminds_popup_expansion') != undefined){
		//ld('#reminds_popup_expansion').show();
	}
}


function getDigital(num){
    if(num<10){
        num='0'+num;
    }
    return num;
}

function findPopX(obj)
{
  var curleft = 0;
        if (document.getElementById || document.all) {
                while (obj.offsetParent && obj.offsetParent.id!="qcform") { curleft += obj.offsetLeft; obj = obj.offsetParent;}
        }        
        else if (document.layers) { curleft += obj.x; }
        return curleft;
}

function findPopY(obj)
{
  var curtop = 0;
        if (document.getElementById || document.all) {
                while (obj.offsetParent && obj.offsetParent.id!="qcform") { curtop += obj.offsetTop; obj = obj.offsetParent;}
        }        
        else if (document.layers) { curtop += obj.Y; }
        return curtop;

}
/**
*edit:kevin
*date:2013-07-08
reason:价格表选择产品时用到
*/
function toggleSelectAll(relCheckName,selectAllName,sel_id) {
if (typeof(getObj(relCheckName).length)=="undefined") {
getObj(selectAllName).checked=getObj(relCheckName).checked
} else {
var atleastOneFalse=false;
for (var i=0;i<getObj(relCheckName).length;i++) {
if (getObj(relCheckName)[i].checked==false) {
atleastOneFalse=true
break;
}
}
getObj(selectAllName).checked=!atleastOneFalse
}
}
function toggleSelect(state,relCheckName) {
	if (getObj(relCheckName)) {
		if (typeof(getObj(relCheckName).length)=="undefined") {
			getObj(relCheckName).checked=state
		} else {
			for (var i=0;i<getObj(relCheckName).length;i++){
			 if(!getObj(relCheckName)[i].disabled){
			     getObj(relCheckName)[i].checked=state 
			 }
			}
		}
	}
    if(state){
	    ld('input[name=selected_id]').parent().parent().attr('class','lvtColDataSelected');
	}else{
	    ld('input[name=selected_id]').parent().parent().attr('class','lvtColDataBj');
	    var checkObj = document.getElementsByName(relCheckName);
        for(var i=0;i<checkObj.length;i++){
            var rows = "row_"+checkObj[i].value;
			if(document.getElementById(rows) != undefined){
				if((i+1)%2==1){
					document.getElementById(rows).className = "lvtColData";    
				}
				else{
					document.getElementById(rows).className = "lvtColDataBj";
				}   
			}
        }	    
	}
    //027265: 市场活动>明细>相关信息>客户：选择客户，没有显示【全选所有N条记录】按钮。
    if(state==true&&document.getElementById("popup_cur_rows_count")!='undefined'&&document.getElementById("popup_cur_rows_count")!=undefined)
    {
       
        if(parseInt(ld("#popup_cur_rows_count").val())<parseInt(ld("#popup_num_rows").val()))
       {
         $('Popup_choose_linkForSelectAll').show();
        $("Popup_choose_selectAllRec").show();
       }
        
    }
}

function ViewfnDropDown(a,b){getJsScript('include/js/ldcrm.core.js',function(){ViewfnDropDown(a,b);});}
/**
edit:kevin
date:2013-09-10
reason:弹出框位置计算
*/
function setPosition(obj,divid){
	oBtnObj = obj;
	var tagName = document.getElementById(divid);
	leftpos  = document.body.scrollLeft;
	toppos = document.body.scrollTop;
	aTag = oBtnObj;
	do{
	  leftpos  += aTag.offsetLeft;
	  toppos += aTag.offsetTop;
	} while(aTag = aTag.offsetParent);

	tagName.style.top= toppos + 20 + 'px';
	tagName.style.left= leftpos - 276 + 'px';
	tagName.style.display = 'block';
	tagName.style.visibility = "visible";
}
function getSelectedappove(txtid){
    cbobj=document.getElementsByName('cb_select_user');
    txtidobj=document.getElementById(txtid);
    txtobj=document.getElementById('username');
    if(cbobj!=undefined&&txtobj!=undefined&&txtidobj!=undefined){
        txtobj_str='';
        txtidobj_str='';
        for(i=0;i<cbobj.length;i++){
            if(cbobj[i].checked){
                sp_obj=document.getElementById('sp_user_'+i);
                txt_obj=document.getElementById('txt_user_'+i);
                txtobj_str=txtobj_str+sp_obj.innerHTML+',';
                txtidobj_str=txtidobj_str+txt_obj.value+',';
            }
        }
        txtobj_str=txtobj_str.substr(0,txtobj_str.lastIndexOf(','));
        txtidobj_str=txtidobj_str.substr(0,txtidobj_str.lastIndexOf(','));
        txtobj.value=trim(txtobj_str);
        txtidobj.value=trim(txtidobj_str);
    }
}
function ExportTemplate(obj)
{
    var frm=document.forms['frmExport'];
    frm.submit();
}
function validateInputData(a,b,c){getJsScript('include/js/ldcrm.core.js',function(){validateInputDatas(a,b,c);});}
function merge_fields(a,b,c){getJsScript('include/js/ldcrm.core.js',function(){merge_fieldss(a,b,c);});}
/*
edit:can
date:20140402
reason:获取带变量的字符串（inventory.js用到该函数)
*/
function getThreeVarJsPop(labelbol,t0,t1,t2)
{
    var jspopinfo=arrJsPopLabel[labelbol];
    var res=jspopinfo.split('{Var}');
    jspopinfo=res[0]+t0+res[1]+t1+res[2]+t2;
    if(res.length>3)
    {
        jspopinfo+=res[3];
    }
    return jspopinfo;
}

/**
更新操作
edit:cdw
date:20131025
reason:客户查重：再次查的时候如果input为空则不显示
**/
function cleandata()
{
     if(document.getElementById('accounts_table')!=undefined)
     {
        while(document.getElementById('accounts_table').rows.length>1)
        {
            document.getElementById('accounts_table').deleteRow(1);
        }
     }
     
}

/**
更新操作
edit:diony
date:20140708
reason:特殊字符转义
**/
function charEscape(str) {
	var RexStr = /\<|\>|\"|\'|\&/g
	str = str.replace(RexStr, function(MatchStr) {
		switch (MatchStr) {
		case "<":
			return "&lt;";
			break;
		case ">":
			return "&gt;";
			break;
		case "\"":
			return "&quot;";
			break;
		case "'":
			return "&#39;";
			break;
		case "&":
			return "&amp;";
			break;
		default:
			break;
		}
	})
	return str;
}
function selectSalesOrder(a){getJsScript('include/js/ldcrm.core.js',function(){selectSalesOrders(a);});}
function originBill_select(a){getJsScript('include/js/ldcrm.core.js',function(){originBill_selects(a);});}


function ApproveStepChange(a){getJsScript('include/js/ldcrm.core.js',function(){ApproveStepChange(a);});}
/**
 * edit:chj
 * date:2014-9-13
 * reason: 屏蔽页面所有的回车键事件
 **/
document.onkeypress=function(event)
{
    var e = event || window.event;
    var obj=e.srcElement||e.target;
   if(obj.tagName=='TEXTAREA'&&e.keyCode==13)
   {
    return true;
    
   }
   
    if(e.keyCode==13)
    {
        
        return false;
    }
}

function userEnterKey()
{
    //16845: 销售机会>新建：客户名称、联系人模糊匹配功能失效。（IE10、IE9）
    //arguments:是js系统变量，可以上网查看
    var event=arguments[arguments.length-1];
    
     var e=event||window.event;
     var code=e.keyCode||e.which;
     var obj=e.srcElement||e.target;
     
     if(e.keyCode==13)
     {
        
      
               var fun=arguments[0];
               
              fun.apply(this,arguments[1]);
             
               
     }
     return true;
}
/**
 * Ajax 封装方法
 * @author Tujt 2014-11-03
 */
function RequestAjax(data,callback){
    if(document.getElementById('status')!=undefined)
	   document.getElementById('status').style.display = 'inline';
	new Ajax.Request(
		'index.php',
		{queue:{position:"end", scope:"command"},
			method:"post",
			postBody:data,
			onComplete:function (response) {
				document.getElementById('status').style.display = 'none';
				callback(trim(response.responseText));
			}
		}
	);
}

/**
 * IE浏览器下innerHTML有的时候会出问题，
 * 用try监控，如果出现问题则使用另一种方式插入数据
 * @param Object obj 相关节点
 * @param String html 要插入的html
 * @returns 替代innerHTML方法
 * @author Tujt 2015-01-06
 */
function sethtml(obj,html){
	try{
		obj.innerHTML = html;
	}catch(e){
		var div = document.createElement('div');
		div.innerHTML = '<table cellspacing="0" cellpadding="0" border="0" width="100%"><tr><td>' + html + '</td></tr></table>';
		while(obj.firstChild) {
			obj.removeChild(obj.firstChild);
		}
		obj.appendChild(div.firstChild);
	}
}
/**
 * 获取对应id的节点对象，取不到返回空
 * @param String ids 节点id值
 * @returns 替代getElementById方法
 * @author Tujt 2015-01-22
 */
function getId(ids){
	return document.getElementById(ids);
}

/**
 *@edit:diony 
 *@date:2014-01-06
 *@reason:关闭一个DIV，再打开另外的一个DIV
 */
function closeAndOpenDiv(idname,divold){
    var newbox=document.getElementById(idname);
    newbox.style.display="none";
    var divold=document.getElementById(divold);
    divold.style.display="inline";
}
/**
 * 明细选择源单 模糊匹配
 * @param
 * @returns
 * @author Chj 
 */
function getKeyWordsDetail(obj,rowid,event){
	var module;
	if(obj.getAttribute("tag") != null){
		var column = obj.getAttribute("tag");
		if(ld('#select_'+column) != undefined){
			module = ld('#select_'+column).val();
		}
		getKeyWords(obj,rowid,module,event);
	}
}
//当前选择的区域ID
var dropselectField='';
//匹配项 当前选择行数
var trNum = 0;
//当前匹配区域总行数
var trRowNum;
//滚动条默认TOP位置
var scrollTop = 0;
//默认8行 出现下拉拖动按钮
var scrollTrNum = 8;
var swidth = 0;//默认下拉表格宽度
var search_form_obj;//from obj
var search_form;
var search_obj;//div obj
var selectFieldName;

//判断非空
function empty(v){
	switch (typeof v){
		case 'undefined' : return true;
		case 'string' : if(trim(v).length == 0) return true; break; 
		case 'boolean' : if(!v) return true; break; 
		case 'number' : if(0 === v) return true; break; 
		case 'object' : 
		if(null === v) return true; 
		if(undefined !== v.length && v.length==0) return true; 
		for(var k in v){return false;} return true; 
		break; 
	}
	return false; 
}

function ModuleDetailmoveUp(objid)
{
	var elem = document.getElementById(objid);
    if(elem.options.selectedIndex>=0){
    	for (var i=1;i<elem.options.length;i++){
    		if(elem.options[i].selected == true){
    			//swap with one up
    			var first = elem.options[i-1];
    			var second = elem.options[i];
    			var temp = new Array();
    
    			temp.value = first.value;
    			temp.innerHTML = first.innerHTML;
    
    			first.value = second.value;
    			first.innerHTML = second.innerHTML;
    
    			second.value = temp.value;
    			second.innerHTML = temp.innerHTML;
    
    			first.selected = true;
    			second.selected = false;
    		}
    	}
    }
	
}


//function clickSelectMember(a,b){	getJsScript('include/js/multipingyin.js',function(){clickSelectMembers(a,b)});}
function clickSelectMember(a,b){	getJsScript('include/js/multipingyin.js',function(){//Liver 20170217,bug0027285: 控制面板-部门设置-添加成员可用成员和选择成员不能进行模糊查寻
    getJsScript('include/js/ldcrm.core.js',function(){clickSelectMembers(a,b);});});}

function createElementDiv(a){createElementDivs(a);}

function closeDiv(){
	var divid = arguments[0]?arguments[0]:'bgDiv';
	if(document.getElementById(divid))
		document.getElementById(divid).style.display = 'none';
}
function checkProductNum(a,b,c,d,e){getJsScript('include/js/ldcrm.core.js',function(){checkProductNum(a,b,c,d,e);});}
/**
edit:can
reason:动态加载js
**/
var loadScript = function(url, callback, charset){
    var head = document.getElementsByTagName('head')[0];
    var script = document.createElement('script');
    if(charset){
        script.charset = charset;
    }
    script.src = url;
    if(!callback){
        return;
    }
    script.onload = script.onreadystatechange = function(){
        if(!this.readyState || this.readyState==='loaded' || this.readyState==='complete'){
            callback();
        }
    };
    head.appendChild(script);
};

/**
 * 跳转页面
 * @author Tujt 2015-05-29
 */
function redirect(url){
	var target = arguments[1]?arguments[1]:0;
	url = 'index.php?'+url;
	switch (target){
	    case 0://当前页跳转
			location.href = url;
			break;
		case 1://打开新标签页
			var linkObj;var ids = 'redirect_link_target';
			if(ld('#'+ids).length == 0){
			 
				linkObj = document.createElement('a');
				linkObj.id = ids;
				linkObj.target = '_blank';
				linkObj.style.display = "none";
				document.body.appendChild(linkObj);
			}else{
				linkObj = document.getElementById(ids);
			}
			linkObj.href = url;
			linkObj.click();
			break;
	}
}
/**
 * 异步加载js文件，然后执行方法
 * @author Tujt 2015-06-02
 */
var dynamicJsScript = {};
function getJsScript(JsFile,callback){
   
	if(dynamicJsScript != undefined && 1 == dynamicJsScript[JsFile]){
		callback();//不加载第二次
	}else{//异步加载
		ld.getScript(JsFile,function(data, textStatus, jqxhr) {
		
	         if('success' == textStatus){
				
	         	dynamicJsScript[JsFile] = 1;
                
	            callback();
	         }
	    });
	}
}
/**
 * 同步加载js文件，然后执行方法
 * @author Tujt 2015-06-02
 */
function getScriptBack(JsFile,callback){
	if(dynamicJsScript != undefined && 1 == dynamicJsScript[JsFile]){
	   if(callback!=undefined)
		  callback();//不加载第二次
	}else{//同步加载
		ld.ajax({
			url: JsFile,
			dataType: 'script',
			async: false,
          
			success: function(rest){
				eval(rest);
				dynamicJsScript[JsFile] = 1;
                if(callback!=undefined)
			     	callback();
			}
		});
	}
}
/**
 * 同步加载js文件，然后执行方法，用于数据分类
 * @author diony 2016-10-19
 */
function getJsScriptCategory(JsFile,callback){   
    ld.ajax({
		url: JsFile,
		dataType: 'script',
		async: false,      
		success: function(rest){
			eval(rest);
			dynamicJsScript[JsFile] = 1;
            if(callback!=undefined)
		     	callback();
		}
	});
}
/**
 * 图片延迟加载，这个还没考虑好！
 * @author Tujt 2015-06-05
 */
function setlazyload(){
	if(ld('img[lazy_src]').length > 0){
		ld('img[lazy_src]').each(function(){
			ld(this).attr('src',ld(this).attr('lazy_src'))
		});
	}
}
var viewuserpopup_type = '';
function ViewUserPopup(obj,saveback,callback){
	getJsScript('include/jquery/treeview/jquery.treeview.js',function(){
		getJsScript('include/js/higerUser.js',function(){
			ViewUserPopups(obj,saveback,callback);
		});
	});
}

function showrelatedlist(module,selectmodule,type,isPopupButton,fieldname){
	getJsScript('include/js/popupselectfield.js',function(){
        
		showrelatedlists(module,selectmodule,type,isPopupButton,fieldname);

	});

}
function showrelatedlist_special(module,selectmodule,type,isPopupButton,fieldname){
	getJsScript('include/js/popupselectfield.js',function(){
        
		showrelatedlists_special(module,selectmodule,type,isPopupButton,fieldname);

	});

}
function scopePopup_All(module,inputid,scopetype){
	getJsScript('include/js/ScopePopup_All.js',function(){
        
		scopePopup_Alls(module,inputid,scopetype);

	});
}
//服务单 - 常见问题，弹出层特殊控制展示层
function showrelatedspeciallist(module,selectmodule,type,isPopupButton){
	getJsScript('include/js/popupselectfield.js',function(){
        
		showrelatedspeciallists(module,selectmodule,type,isPopupButton);

	});

}

function selectSearch(fieldname){
	getJsScript('include/js/popupselectfield.js',function(){
		selectSearchs(fieldname);
	});
}

function setSearch(module,frommodule,fieldname){
	getJsScript('include/js/popupselectfield.js',function(){
		setSearchs(module,frommodule,fieldname);
	});
}

function checkFieldlist(module,frommodule,fieldname){
	getJsScript('include/js/popupselectfield.js',function(){
		checkFieldlists(module,frommodule,fieldname);
	});
}
function checkDupFieldlist(module,frommodule){
	getJsScript('include/js/popupselectfield.js',function(){
		checkDupFieldlists(module,frommodule);
	});
}
//选择弹出层
function selectrelated(module,rowid,mid,entityname,fieldname,smownerid,frommodule){
	getJsScript('include/js/popupselectfield.js',function(){
		selectrelateds.spop = 'pop_div';
		selectrelateds(module,rowid,mid,entityname,fieldname,smownerid,frommodule);
	});
}
//选择新窗口
function pop_selectrelated(module,rowid,mid,entityname,fieldname,smownerid,frommodule){
	getJsScript('include/js/popupselectfield.js',function(){
		selectrelateds.spop = 'pop';
		selectrelateds(module,rowid,mid,entityname,fieldname,smownerid,frommodule);
	});
}
function selectrelated_special(module,mid,entityname,fieldname,frommodule){
	getJsScript('include/js/popupselectfield.js',function(){
		selectrelateds_special(module,mid,entityname,fieldname,frommodule);
	});
}

function selectTabDetailRelated(module,columnname,mid,entityname,linkname,rowid,frommodule){
	getJsScript('include/js/popupselectfield.js',function(){
		selectTabDetailRelateds(module,columnname,mid,entityname,linkname,rowid,frommodule);
	});
}

function ShowSetUeryScop(userid){
	getJsScript('include/js/SetUeryScope.js',function(){
		ShowSetUeryScops(userid);
	});
}
function massDividends(obj,operationtype,idkey,stype){
   getJsScript('modules/DividendOrder/DividendOrder.js',function(){
		massDividend(obj,operationtype,idkey,stype);
	});
}

function InsertTemplate(obj){
	getJsScript('modules/Settings/Settings.js',function(){
		InsertTemplates(obj);
	});
}


function show_contactEmailList(contactid)
{
    document.getElementById('contactid').value = contactid;
    document.getElementById('SMSedit').style.display = 'block';
}

function selectprojecttask(mod){
	getJsScript('include/js/popupselectfield.js',function(){
		selectprojecttask(mod);
	});
}
//客户相关信息 - 邮件管理-发送邮件
function sendmail(module,idstrings){
	getJsScript('include/js/Mail.js',function(){
		sendmails(module,idstrings)
	});
  
}

function setDuplicate(module,frommodule){
	getJsScript('include/js/popupselectfield.js',function(){
		setDuplicates(module,frommodule);
	});
}


/**
更新操作
edit:cyb
date:2015-10-27
reason:客户模块界面，查重按钮事件。
**/
function look_check_repeat(obj,module)
{   

     
  
    	getJsScript('include/js/popupselectfield.js',function(){
		look_check_repeats(obj,module);
	}
    );

}
look_check_repeat.pagetype='editview';

/* editor:gyq_12  reason:显示列设置按钮 date:20160531*/
function button_setDuplicateColumnDisplay(module,frommodule){
    getJsScript('modules/Accounts/setDuplicateColumnDisplay.js',function(){
        setDuplicateColumnDisplay.getInstance().button_setColumnDisplay(module,frommodule);
    });
}
//客户模块界面，查重按钮。
function search_account(obj,module)
{
    	getJsScript('include/js/popupselectfield.js',function(){
		search_accounts(obj,module);
	});
              
}


/*
*新增操作 by andy
*联系记录新增服务单字段，弹出窗
*date:20140108
*/
function selecttroubleticket(mod)
{
	// To support both B2B and B2C model
	var record_id = '';
	var parent_module = '';
	//0017453: 客户/销售机会>序时簿,关于跟进时选择服务单的问题
	if(document.QcEditView != undefined){
		var acc_element = document.QcEditView.account_id;
		var module=document.QcEditView.module.value;	
	}else{
		var acc_element = document.EditView.account_id;
		var module=document.EditView.module.value;
	}
    var accountid;
	if (acc_element != null) {
		record_id= acc_element.value;
		parent_module = 'Accounts';
	}

	if(record_id != ''){
		window.open("index.php?module=HelpDesk&action=Popup&html=Popup_picker&popuptype=specific&form=EditView&accountid="+record_id+"&parent_module="+parent_module+"&fromModule=1&frommodule="+mod,"test","width=840,height=602,resizable=1,scrollbars=1");
	}else{
		window.open("index.php?module=HelpDesk&action=Popup&html=Popup_picker&popuptype=specific&form=EditView&frommodule="+mod,"test","width=840,height=602,resizable=1,scrollbars=1");
    }

}
$('.wx-login-btn').click(function(){
    if(weixinlogin == 'yes'){
		var bodyWidth = window.screen.availWidth; 
        window.location = weixinloginurl+'&languageType='+languageType+'&bodywidth='+bodyWidth;
       // window.location = 'http://www.51mis.cn/webapi/weixinapi_v5/function/crm_login_transfer.html?orignurl='+weixinloginurl+'&languageType='+languageType;
    }else{
        var r='当前登录地址没有绑定企业微信，是否立即绑定？';
        var close_alt='关闭';
        var popTitle = '温馨提示';
        var popbtn_ok = '确定';
        var popbtn_cancel = '取消'
        if(languageType == 'en'){
         r='The current login address is not bound to the enterprise WeChat, or is it immediately bound?';
         popTitle = 'Warm prompt';
         close_alt = 'Close';
         popbtn_ok = 'Confirmed';
         popbtn_cancel = 'Cancel';
        }
       
            //创建提示弹出层
            create_divobj('weixinloginError',popTitle,r,'yes','','yes');
            ld('#weixinloginError .D_ptitc .D_ptitcimg').attr({alt:close_alt});
            ld('#weixinloginError .D_ptitc .D_ptitcimg').attr({title:close_alt});    
            ld('#weixinloginError .D_pbtn .D_pbtnok').val(popbtn_ok);
            ld('#weixinloginError .D_pbtn .D_pbtncancel').val(popbtn_cancel);

            $('#weixinloginError .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
                fninvshnew('weixinloginError');
                if(weixinlogin.indexOf("kehu001") > -1){
                    window.open('http://www.kehu001.com');
                }else{
                    window.open('http://www.51mis.cn/webapi/weixinapi_v5/wx_suite/authorize.html');
                }
            });
        
           
    }
});

function getLoginerror(labelbol)
{
    var enjspop={'USERNAMECANOTEMPTY':'User name can not be empty!',
    'VERIFICATIONCODENOTEMPTY':'Verification code can not be empty!',
    'VERIFICATIONCODEERROR':'Verification code is incorrect, please re-enter!'};
    
    var zhjspop={'USERNAMECANOTEMPTY':'用户名不能为空！',
    'VERIFICATIONCODENOTEMPTY':'验证码不能为空！',
     'VERIFICATIONCODEERROR':'验证码不正确，请重新输入！'};
     
     if(languageType=='zh')
     {
        return zhjspop[labelbol];
     }
     else
     {
        return enjspop[labelbol];
     }
}
function _createElementDiv(divid){
	var divObj;
	if(languageType == 'zh'){
		var _lbl_close = '关闭';
		var _lbl_confirme = '确定';
		var _lbl_cancel = '取消';
	}else{
		var _lbl_close = 'Close';
		var _lbl_confirme = 'Confirm';
		var _lbl_cancel = 'Cancel';
	}
	if(0 == ld('#'+divid).length){//当层未创建时，创建层
		divObj = document.createElement("div");
		divObj.setAttribute('id',divid);
		divObj.className = 'D_pop_box LdPopWidth650px';
		divObj.style.position = "absolute";
		divObj.style.zIndex = "10001";
		divObj.style.top = "120px";
		divObj.style.left = "350px";
		//divObj.style.maxHeight = "200px";
		divObj.style.display = "none";
		//divObj.style.backgroundColor = "#ffffff";
		document.body.appendChild(divObj);
		divObj.innerHTML = '<div class="D_pop_tit">'+
								'<strong class="D_ptita" id="'+divid+'titlename"></strong>'+
								'<a href="javascript:;" class="D_ptitc">'+
									'<img class="D_ptitcimg" src="themes/icon/pop_close.png" '+
									'alt="'+_lbl_close+'" title="'+_lbl_close+'">'+
								'</a>'+
							'</div>'+
							'<div id="'+divid+'content" class="pop_remind_content">'+
								'&nbsp;'+
							'</div>'+
							'<div class="D_pbtn"><input class="D_pbtnok" value="'+_lbl_confirme+'" type="button"><span>&nbsp;</span>'+
							'<input class="D_pbtncancel" value="'+_lbl_cancel+'" type="button"></div>';
		var isbg = 0;
		if(ld('#layer').length > 0){
			isbg = 1;
			ld('#'+divid).css('display','');
		}else{
			fnvshobj('', divid);
		}
		/**
		 * 关闭事件
		 * @author Tujt 2015-04-15
		 */
		ld('#'+divid+' .D_pop_tit .D_ptitc').on('click',function(){
			ld('#'+divid+' .D_pbtn .D_pbtncancel').click();
			return false;
		});
		ld('#'+divid+' .D_pbtn .D_pbtncancel').on('click',function(){
			if(0 == isbg){
				fninvshnew(divid);
			}else{
				ld('#'+divid).css('display','none');
			}
		});
	}else{
		divObj = document.getElementById(divid);
		if(ld('#layer').length > 0){
			ld('#'+divid).css('display','');
		}else{
			fnvshobj('', divid);
		}
	}
	return divObj;
}
function Check(){ 
    var form=document.forms['DetailView'];
    var code=form.code.value;
	//var bodyWidth = document.body.scrollWidth;	//网页正文全文宽
    var bodyWidth = window.screen.availWidth;	//屏幕可用工作区宽度
	if(form.secutity_code!=undefined)
    var inputcode=form.secutity_code.value;
    else
    var inputcode='';
    //获取屏幕分辨率的可见宽度
	if(document.getElementById('bodywidth') != undefined){
		document.getElementById('bodywidth').value = bodyWidth;
	}
	
    if(form.login_user_name.value==''){
      
       alert( getLoginerror('USERNAMECANOTEMPTY'));
        form.login_user_name.focus();
        return false;
    }
   
     if(form.secutity_code!=undefined){
        if(form.secutity_code.value==''){
        //alert(arrJsPopLabel['VERIFICATIONCODENOTEMPTY']);
         alert( getLoginerror('VERIFICATIONCODENOTEMPTY'));
        form.secutity_code.focus();
        return false;
        }
     } 
    
    ld_login_submit();
   
	
     
}

function ld_login_submit()
{
    var encode_login_password_value='';
	var encode_login_user_name_value='';
	var login_user_name_value='';
	if(ld("#login_password").length>0){

		var login_user_name_obj = ld("#login_user_name");
		var login_password_obj = ld("#login_password");
		//登录密码加密
		var login_password_value = ld(login_password_obj).val();
		login_user_name_value = ld(login_user_name_obj).val();
		encode_login_password_value = ld_login_secret(login_password_value,login_user_name_value,false);
		encode_login_user_name_value = ld_login_secret(login_user_name_value,encode_login_password_value,false);


		//ld(login_password_obj).val(encode_login_password_value);

	}
    var formData = new FormData();
    var formobj = ld("#form_login");
    formData.set('module','Users');
    formData.set('action','Authenticate');
    formData.set('return_module','Users');
    formData.set('return_action','Login');
    formData.set('ldtokenrand',ldtokenrand);
    //获取值
    if(ld(formobj).find("#sessionrand").length >0){
        formData.set('sessionrand',ld(formobj).find("#sessionrand").val());
    }
    if(ld(formobj).find("#login_method").length >0){
        formData.set('login_method',ld(formobj).find("#login_method").val());
    }
    if(ld(formobj).find("#code").length >0){
        formData.set('code',ld(formobj).find("#code").val());
    }
    if(ld(formobj).find("#bodywidth").length >0){
        formData.set('bodywidth',ld(formobj).find("#bodywidth").val());
    }
    if(ld(formobj).find("#hantianlogin").length >0){
        formData.set('hantianlogin',ld(formobj).find("#hantianlogin").val());
    }
    if(ld(formobj).find("#languageType").length >0){
        formData.set('languageType',ld(formobj).find("#languageType").val());
    }
    if(ld(formobj).find("#CrmClientIp").length >0){
        formData.set('CrmClientIp',ld(formobj).find("#CrmClientIp").val());
    }
	formData.append('login_user_password',encode_login_password_value);
	formData.append('encode_login_user_name_value',encode_login_user_name_value);
    
    //添加辨别参数，告诉后台这里是ajax访问
    formData.append('loginajax','yes');
	formData.append('pc_puyoung_loginajax','yes');
    
    ld.ajax({
        url:'index.php?',
        type: 'POST',
        cache: false,
        data:formData,
        processData: false,
        contentType: false,
        timeout:20000,
        dataType:'json',
        success: function(data)
        {
            if(data.code==1){
                //记住密码
                if(ld("#remember_password").length>0){
                    if(ld("#remember_password").prop('checked')){
                        ld_storagepassword_bytype('set','',encode_login_password_value);//保存密码
                        ld_storagepassword_bytype('set','ldcrm_remember_password','yes');//保存记住密码勾选状态
                    }
                    else{
                        ld_storagepassword_bytype('delete','','');//清除保存的密码
                        ld_storagepassword_bytype('set','ldcrm_remember_password','no');//保存记住密码勾选状态
                    }
                }
                ld("#login_password").remove();
                // 获取当前页面的URL
                var currentUrl = new URL(window.location.href);
                // 构造新的URL
                var newUrl = new URL(data.result.href, currentUrl.origin + currentUrl.pathname);
                // 重定向到新的URL
                window.location.href = newUrl.href;
            }
            //需跳转值其他界面
            else if(data.code==2){
                // 获取当前页面的URL
                var currentUrl = new URL(window.location.href);
                // 构造新的URL
                var newUrl = new URL(data.result.href, currentUrl.origin + currentUrl.pathname);
                // 重定向到新的URL
                window.location.href = newUrl.href;
            }
            //产生提示信息 -- 过段时间消失
            else if(data.code == -1&&data.msg!=''){
                MessagePopup.TipZero_warning(data.msg);
            }
            //产生提示信息 -- 带有按钮
            else if(data.code == -2&&data.msg!=''){
                windowDiv(data.msg,400,'');
            }
            else{
                window.location.href = location.href;
            }
			if(data.code < 0){
				if(ld(formobj).find('#secutity_code').length > 0){
					ld(formobj).find('#secutity_code').val('');
					ld(formobj).find('#img_codepicture').click();
				}
			}
			if(data.result.ldtokenrand != undefined){
				ldtokenrand = data.result.ldtokenrand;
			}
            
        },
        error:function(jqXHR, textStatus, errorThrown)
        {
            console.log(jqXHR);
            console.log(textStatus);
			if(textStatus == 'timeout'){
				window.location.href = location.href;
			}

        }
    })
}
//获取用户对应的key
function getuserstoragekey(obj){
    var key = '';
    if(obj==undefined||obj ==''){
        obj = ld("#login_user_name");
    }
    username = ld(obj).val();
	//处理key ,
	username = username.trim();
    key = window.location.origin+window.location.pathname+username;
    return key;
}
//设置、获取、清除 浏览器缓存，默认key为用户密码对应key
function ld_storagepassword_bytype(type,key,secretpassword){
    if(key == '' || key == undefined){
        key = getuserstoragekey();    
    }
    if(secretpassword == '' || secretpassword == undefined){
        secretpassword = '';    
    }
    if(type == 'set'){
        localStorage.setItem(key, secretpassword);
    }
    else if(type == 'get'){
        return localStorage.getItem(key);
    }
    else if(type == 'delete'){
        localStorage.removeItem(key);
    }
}
//输入用户名后设置密码
function ldcrm_setpassword(obj){
    var inputusername = ld(obj).val();//用户名
    var storagepassword = ld_storagepassword_bytype('get');
	//账号直接加载对应密码
    if(ld("#login_password").length>0&&storagepassword!=undefined){
        if(ld("#remember_password").length>0&&ld("#remember_password").prop('checked')){
            storagepassword = ld_login_secret(storagepassword, inputusername, true);
            ld("#login_password").val(storagepassword);
        }
    }
}

function windowDiv(msg,width,type,title=''){  //BUG0067660 BUG0067657 xxy 2023-6-13 登陆界面弹出框样式优化
    var divobj = _createElementDiv('loginreminder');
    if(title == ''){
        title = '温馨提示';
        if(language == 'zh'){
            title = '温馨提示';
        }
        else{
            title = 'Warm prompt';
        }
    }
    var titleicon = '<div class="ld-E-ptita ld-E-ptita-left-headicon-1" style="margin:0px 10px 0px 0px"></div>'; //灯泡图标
    var div_text = '<div class="qui_dialog_body ld-dialog-Boxbody">'
    +'<div class="ld-msgDlg-Boxtop">';
    if(type == 'success'){ 
        div_text +='<div class="ld-commonImg ld-commonImg-BoxSuccess ld-msgDlg-top-icon"></div>'
    }
    else{
        div_text +='<div class="ld-commonImg ld-commonImg-BoxAlert ld-msgDlg-top-icon"></div>'
    }
    div_text += '</div>'
    +'<div class="ld-msgDlg-Boxbottom">'   
    +'<div class="ld-msgDlg-bottom-Boxtext" style="font-size:15px;padding-left: 8px;">'+msg
    +'</div>'
    +'</div>'
    +'</div>';
    ld(divobj).find('.ld-E-pop-tit .ld-E-ptita').html(titleicon+title);
    ld('#loginremindercontent').html(div_text);
    ld(divobj).css('max-height','500px');
    ld(divobj).css('width',width+'px');
    ld(divobj).css('background','#FDFDFD');
    ld('#loginremindercontent').css('max-height','400px');
    ld('#loginremindercontent').css('border','none');
    ld(divobj).find('div.ld-E-pbtn-bg .ld-E-pbtncancel').remove();
    ld(divobj).find('div.ld-E-pop-tit a').remove();
    ld(divobj).find('div.ld-E-pbtn-bg .ld-E-pbtnok').attr("onclick","fninvshnew('loginreminder');");
    fnvshobj(this,'loginreminder');  
    return divobj;
}

function changeLangage(obj)
{ 
    window.location='index.php?languageType='+obj.value+'&login_method=1';

}

function yzm_change(obj)
{
 
    document.getElementById('img_codepicture').src="picture.php?"+Math.random()*10000;

}

/**
    * 控制按tab键时,焦点只在指定元素中切换
    * edit:zhuyiping
    * date:20160714
    * */
function tabGoHome(){
    document.getElementById("login_user_name").focus();
}
function stopEvent(e)
{
    if(e.stopPropagation)
    {
        e.stopPropagation();
    }
    else
    {
        e.cancelBubble=true;
    };
     
    if(e.preventDefault)
    {
        e.preventDefault();
    }
    else
    {
        e.returnValue=false;
    }
}
function tabchange(event){        
    var e = event || window.event;
    var target = e.target||e.srcElement;
    var keyCode = e.keyCode||e.which;
    var stop="";
    if(document.getElementById("secutity_code")==null)
    {
        stop="login_password";
    }else{
        stop="secutity_code";     
    };
    
    if(9 == keyCode)
	{
		if(stop!="" && stop == target.id)
		{
			stopEvent(e);
			tabGoHome();
		}
	}
}

/*editor:gyq_05 reason:关闭按钮适配审批通知  date:2016 2 26*/
function CloseDivSendInformContent(idname,divold){

    if(ld('#div_approveRemindsContent').attr("href") == "###"){
        divold = 'approvestep';
    }
  
    /*var newbox=document.getElementById(idname);
    newbox.style.display="none";
    var divold=document.getElementById(divold);
    divold.style.display="inline";*/
    //29270: 控制面板>审批流程管理：审批通知，点击审批通知的“设置提醒内容”弹出框的【取消】按钮，结果：没有显示审批步骤弹出层，而是显示了遮罩层
    fninvshnew(idname);
    fninvshnew(divold);

}


/*
* editor:gyq_05
* reason:改进设置信息弹框，适应审批步骤
* date  :2016 2 23
* */
function SaveSendSMSContent()
{


     var popupobj=CrmPopup.getPopupObj("last");
     var divid=popupobj.divid;
     var obj=popupobj.getbtnOkobj();
     
    var textRecipient=ld("#CKcontent").val();
    if(textRecipient==''){
        //内容模板为空！
        var confirm_str = arrJsPopLabel['CONTENTTEMPLATEEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }

    var form=document.forms['frmsendInfoContent'];
    form.submit();
	


}
SaveSendSMSContent.funname="SaveSendSMSContent";


function getBrowserInfo()
{
        var agent = navigator.userAgent.toLowerCase() ;
        
        var regStr_ie = /msie [\d.]+;/gi ;
        var regStr_ff = /firefox\/[\d.]+/gi
        var regStr_chrome = /chrome\/[\d.]+/gi ;
        var regStr_saf = /safari\/[\d.]+/gi ;
        //IE
        if(agent.indexOf("msie") > 0)
        {
        return agent.match(regStr_ie) ;
        }
        
        //firefox
        if(agent.indexOf("firefox") > 0)
        {
        return agent.match(regStr_ff) ;
        }
        
        //Chrome
        if(agent.indexOf("chrome") > 0)
        {
        return agent.match(regStr_chrome) ;
        }
        
        //Safari
        if(agent.indexOf("safari") > 0 && agent.indexOf("chrome") < 0)
        {
        return agent.match(regStr_saf) ;
        }

}

/**
*edit:cyb
*date:20151015
*reason:联系人明细界面中点击手机图标时关联短信群发界面时，接收人手机列表显示。
**/
function toChangeMobileStyle(id,module,fieldname){
	
	window.open("index.php?module=MassSMS&action=index&parenttab=Marketing&select_options="+id+"&return_module="+module+"&return_action=DetailView&fieldname="+fieldname,null,'1024,768,menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes');
            
}
//新增函數，在js里边解密php传递过来的值。


//弹出框列表选中变色
function setPopTrColor(sel_id){
    document.getElementById(sel_id).className = "lvtColDataHover";   
}
function setPopTrColorOut(sel_id,type){
    if(type == 'On'){
        document.getElementById(sel_id).className = "lvtColDataBj";
    }else{
        document.getElementById(sel_id).className = "lvtColData";
    } 
}
//相关信息列表选中变色
function relationListOnMouseOver(sel_id){
    var rows = "relation_"+sel_id;
    document.getElementById(rows).className = "lvtColDataHover";
}
function relationListOnMouseOut(sel_id,type){
    var rows = "relation_"+sel_id;
    if(type == 'On'){
        document.getElementById(rows).className = "lvtColDataBj";
    }else{
        document.getElementById(rows).className = "lvtColData";
    }
}


//控制面板列表选中变色
function settingListOnMouseOver(sel_id){
    var rows = "setting_"+sel_id;
    document.getElementById(rows).className = "lvtColDataHover";
}
function settingListOnMouseOut(sel_id,type){
    var rows = "setting_"+sel_id;
    if(type == 'On'){
        document.getElementById(rows).className = "lvtColDataBj";
    }else{
        document.getElementById(rows).className = "lvtColData";
    }
}
//报表选中变色
function reportListOnMouseOver(sel_id){
    var rows = "report_"+sel_id;
    document.getElementById(rows).className = "lvtColDataHover";
}
function reportListOnMouseOut(sel_id,type){
    var rows = "report_"+sel_id;
    if(type == 'On'){
        document.getElementById(rows).className = "lvtColDataBj";
    }else{
        document.getElementById(rows).className = "lvtColData";
    }
}
//明细界面分录
function detailListOnMouseOver(sel_id){
    var rows = "row"+sel_id;
    document.getElementById(rows).className = "lvtColDataHover";
}
function detailListOnMouseOut(sel_id,type){
    var rows = "row"+sel_id;
    if(type == 'On'){
        document.getElementById(rows).className = "lvtColDataBj";
    }else{
        document.getElementById(rows).className = "lvtColData";
    }
}


function htmldecode(str) {
 str = str.replace(/&amp;/gi, '&');
 str = str.replace(/&nbsp;/gi, ' ');
 str = str.replace(/&quot;/gi, '"');
 str = str.replace(/&#39;/g, "'");
 str = str.replace(/&lt;/gi, '<');
 str = str.replace(/&gt;/gi, '>');
 //str = str.replace(/<br[^>]*>(?:(rn)|r|n)?/gi, 'n');
 return str;
}
/*
当前页详细信息
*/
var cur_PageInfo={
    pagetype:new Array(),//listview detailview,editview create,quickcreate，poplayerlistview,poppagelistview
    modulenames:new Array(),//模块名称数组
    pagemode:new Array(),//poplayer,wholepage,popwindow
    fieldinfoobjs:new Array(),
    clear:function()
    {
        if(cur_PageInfo.pagemode.length>0)
        {
            cur_PageInfo.pagemode.pop();
            cur_PageInfo.modulenames.pop();
            cur_PageInfo.pagetype.pop();
            cur_PageInfo.fieldinfoobjs.pop();
        }
        
    }
    
}


var Base64 = {
    // 转码表
    table : [
            'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
            'I', 'J', 'K', 'L', 'M', 'N', 'O' ,'P',
            'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
            'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
            'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
            'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
            'w', 'x', 'y', 'z', '0', '1', '2', '3',
            '4', '5', '6', '7', '8', '9', '+', '/'
    ],
    UTF16ToUTF8 : function(str) {
        var res = [], len = str.length;
        for (var i = 0; i < len; i++) {
            var code = str.charCodeAt(i);
            if (code > 0x0000 && code <= 0x007F) {
                // 单字节，这里并不考虑0x0000，因为它是空字节
                // U+00000000 – U+0000007F  0xxxxxxx
                res.push(str.charAt(i));
            } else if (code >= 0x0080 && code <= 0x07FF) {
                // 双字节
                // U+00000080 – U+000007FF  110xxxxx 10xxxxxx
                // 110xxxxx
                var byte1 = 0xC0 | ((code >> 6) & 0x1F);
                // 10xxxxxx
                var byte2 = 0x80 | (code & 0x3F);
                res.push(
                    String.fromCharCode(byte1), 
                    String.fromCharCode(byte2)
                );
            } else if (code >= 0x0800 && code <= 0xFFFF) {
                // 三字节
                // U+00000800 – U+0000FFFF  1110xxxx 10xxxxxx 10xxxxxx
                // 1110xxxx
                var byte1 = 0xE0 | ((code >> 12) & 0x0F);
                // 10xxxxxx
                var byte2 = 0x80 | ((code >> 6) & 0x3F);
                // 10xxxxxx
                var byte3 = 0x80 | (code & 0x3F);
                res.push(
                    String.fromCharCode(byte1), 
                    String.fromCharCode(byte2), 
                    String.fromCharCode(byte3)
                );
            } else if (code >= 0x00010000 && code <= 0x001FFFFF) {
                // 四字节
                // U+00010000 – U+001FFFFF  11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
            } else if (code >= 0x00200000 && code <= 0x03FFFFFF) {
                // 五字节
                // U+00200000 – U+03FFFFFF  111110xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
            } else /** if (code >= 0x04000000 && code <= 0x7FFFFFFF)*/ {
                // 六字节
                // U+04000000 – U+7FFFFFFF  1111110x 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
            }
        }
 
        return res.join('');
    },
    UTF8ToUTF16 : function(str) {
        var res = [], len = str.length;
        var i = 0;
        for (var i = 0; i < len; i++) {
            var code = str.charCodeAt(i);
            // 对第一个字节进行判断
            if (((code >> 7) & 0xFF) == 0x0) {
                // 单字节
                // 0xxxxxxx
                res.push(str.charAt(i));
            } else if (((code >> 5) & 0xFF) == 0x6) {
                // 双字节
                // 110xxxxx 10xxxxxx
                var code2 = str.charCodeAt(++i);
                var byte1 = (code & 0x1F) << 6;
                var byte2 = code2 & 0x3F;
                var utf16 = byte1 | byte2;
                
                    res.push(String.fromCharCode(utf16));
            } else if (((code >> 4) & 0xFF) == 0xE) {
                // 三字节
                // 1110xxxx 10xxxxxx 10xxxxxx
                var code2 = str.charCodeAt(++i);
                var code3 = str.charCodeAt(++i);
                var byte1 = (code << 4) | ((code2 >> 2) & 0x0F);
                var byte2 = ((code2 & 0x03) << 6) | (code3 & 0x3F);
                var utf16 = ((byte1 & 0x00FF) << 8) | byte2
                res.push(String.fromCharCode(utf16));
            } else if (((code >> 3) & 0xFF) == 0x1E) {
                // 四字节
                // 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
            } else if (((code >> 2) & 0xFF) == 0x3E) {
                // 五字节
                // 111110xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
            } else /** if (((code >> 1) & 0xFF) == 0x7E)*/ {
                // 六字节
                // 1111110x 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
            }
        }
 
        return res.join('');
    },
    encode : function(str) {
        if (!str) {
            return '';
        }
        var utf8    = this.UTF16ToUTF8(str); // 转成UTF8
        var i = 0; // 遍历索引
        var len = utf8.length;
        var res = [];
        while (i < len) {
            var c1 = utf8.charCodeAt(i++) & 0xFF;
            res.push(this.table[c1 >> 2]);
            // 需要补2个=
            if (i == len) {
                res.push(this.table[(c1 & 0x3) << 4]);
                res.push('==');
                break;
            }
            var c2 = utf8.charCodeAt(i++);
            // 需要补1个=
            if (i == len) {
                res.push(this.table[((c1 & 0x3) << 4) | ((c2 >> 4) & 0x0F)]);
                res.push(this.table[(c2 & 0x0F) << 2]);
                res.push('=');
                break;
            }
            var c3 = utf8.charCodeAt(i++);
            res.push(this.table[((c1 & 0x3) << 4) | ((c2 >> 4) & 0x0F)]);
            res.push(this.table[((c2 & 0x0F) << 2) | ((c3 & 0xC0) >> 6)]);
            res.push(this.table[c3 & 0x3F]);
        }
 
        return res.join('');
    },
    decode : function(str) {
        if (!str) {
            return '';
        }
 
        var len = str.length;
        var i   = 0;
        var res = [];
 
        while (i < len) {
            code1 = this.table.indexOf(str.charAt(i++));
            code2 = this.table.indexOf(str.charAt(i++));
            code3 = this.table.indexOf(str.charAt(i++));
            code4 = this.table.indexOf(str.charAt(i++));
 
            c1 = (code1 << 2) | (code2 >> 4);
            c2 = ((code2 & 0xF) << 4) | (code3 >> 2);
            c3 = ((code3 & 0x3) << 6) | code4;
 
            res.push(String.fromCharCode(c1));
 
            if (code3 != 64) {
                res.push(String.fromCharCode(c2));
            }
            if (code4 != 64) {
                res.push(String.fromCharCode(c3));
            }
 
        }
 
        return this.UTF8ToUTF16(res.join(''));
    }    
};
function getSplitString(string,parameter){
	if(!empty(string)){
		var strs = string.split('&');
		if(strs.length > 0){
			for(var i= 0; i<strs.length;i++){
				var strMethod = strs[i].split('=');
				if(strMethod[0] == parameter){
					return strMethod[1];
				}
			}
		}
	}
	return '';
}





/*
* editor:gyq_09
* explain:JS异步加载基类方法
* date: 2016 4 7
* */
var scriptsArray = new Array();
ld.cachedScript = function (url, options) {
//循环script标记数组
	for (var s in scriptsArray) {
//如果某个数组已经下载到了本地
		if (scriptsArray[s]==url) {
			return { //则返回一个对象字面量，其中的done之所以叫做done是为了与下面$.ajax中的done相对应
				done: function (method) {
					if (typeof method == 'function'){ //如果传入参数为一个方法
						method();
					}
				}
			};
		}
	}
//这里是jquery官方提供类似getScript实现的方法，也就是说getScript其实也就是对ajax方法的一个拓展
	options = ld.extend(options || {}, {
		dataType: "script",
		url: url,
		cache:true //其实现在这缓存加与不加没多大区别
	});
	scriptsArray.push(url); //将url地址放入script标记数组中

	return ld.ajax(options);
}

//同步，获取模块列表数据

/**
*edit:cyb
*date:2016-05-23
*reason:帮我吧接口设置密钥以及vendorid输入框清空；
*/
function cleanInfo(obj){
    obj.value="";
}
function js_unique(arr) {
    var result = [], hash = {};
    for (var i = 0, elem; (elem = arr[i]) != null; i++) {
        if (!hash[elem]) {
            result.push(elem);
            hash[elem] = true;
        }
    }
    return result;
//http://www.cnblogs.com/sosoft/
}
var auto;
js_autocomplete = function(obj,input_class){
	getJsScript('include/js/autocomplete.js',function(){
		if(auto instanceof Object == false){
			auto = new AutoComplete({
			   // url: '/rocky/commonservice/user/find.json'
			}); 
		}
	});
}
autocolse = function(){
	alert(111);
}
/*gyq_23 微信消息提醒定时器 date:20170207*/

function myIntervalForSendNews(){
	var AjaxUrl = 'WeiXinApp/modules/Reminds/SendRemindsWX.php';
	ld.ajax(
		{
			type: "get",
			contentType: "application/json; charset=utf-8",
			dataType: "jsonp",
			url: AjaxUrl
		});
}
var ld_defer = ld.Deferred();


//获取url中的参数，Liver 20170209 需求审批中心单据明细返回列表功能改进
function getUrlParam(name) {
 var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)"); //构造一个含有目标参数的正则表达式对象
 var r = window.location.search.substr(1).match(reg); //匹配目标参数
 if (r != null) return unescape(r[2]); return null; //返回参数值
}

