/**
 * 新增渠道码
 * @param
 * @returns
 * @author chj 
 */
function channelcode_refresh(){
	var  gstart = "&start=" + document.forms['massdelete'].pagenum.value;
	getListViewEntries_js('ChannelCode','&start='+gstart);
    
}

function channelcode_uploadimg(img_url){
	window.open(img_url) ;
}
/**
 * 新增渠道码
 * @param
 * @returns
 * @author Tujt 
 */
function channelcode_add(record,surl=''){
    var surl = 'index.php?module=ChannelCode&action=ChannelCodeAjax&file=EditView'+surl;
	if(record > 0){
		surl += '&record='+record+"&mode=edit";
	}
	var popupobj=CrmPopup.getPopupObj("last");
	//wym 240514 BUG20240513-71 渠道码 新建和编辑界面都没有全屏和缩小(现已添加并重写了对应需要的方法)
	var fullscreen='yes';
	var tmpurlstring = "index.php?module=Users&action=UsersAjax&file=ModuleSettingbyuser&mode=get&label=EditFullscreen";
	ldAjaxNoProgresssync(tmpurlstring,'',function(data) {
		if(data.code==1){
			if(data.result.content != ''){
				fullscreen=data.result.content;
			}
		}
	});
	if(fullscreen=='yes'){
		var csswidth=CrmPopup.getClientWidth();
	}else{
		var csswidth=CrmPopup.getClientWidth()*0.8;
	}
	var crmPopupobj=CrmPopup.load("","","",csswidth,'Settings',"","","","");
	crmPopupobj.isShowFullscreen='yes';
	crmPopupobj.fullscreenlabel='EditFullscreen';//全屏缩小用于保存后台的label值
	crmPopupobj.fullscreen = fullscreen ;
	crmPopupobj.getFullscreen = function () {
		if(empty(this.fullscreen)){
			var urlstring = "index.php?module=Users&action=UsersAjax&file=ModuleSettingbyuser&mode=get&label=EditFullscreen";
			ldAjaxNoProgresssync(urlstring,'',function(data) {
				if(data.code==1){
					if(data.result.content != ''){
						this.fullscreen=data.result.content;
					} else{
						this.fullscreen = 'yes';
					}
				}
			});
		}
		var fullscreen = this.fullscreen;
		return fullscreen;
	}
	//wym 231220 BUG0077428 渠道码新建界面，没有全屏显示，重写设置高度函数，修改宽度传值
	crmPopupobj.setScrollDivMaxHeight = function () {
		var fullscreen=this.getFullscreen();
		if(fullscreen=='no'){//缩小
			var maxheight = this.getMaxHeight();
			ld("#" + this.divid + " .dvpopupsroll").css("max-height", maxheight);
			ld("#" + this.divid + " .dvpopupsroll").css("height", 'auto');
		}else{//全屏
			var maxheight = CrmPopup.getClientHeight();
			if(ld("#" + this.divid + '_head').length>0){
				maxheight -= ld("#" + this.divid + '_head').outerHeight();
			}
			if(ld("#" + this.divid + '_popupbottom').length>0){
				maxheight -= ld("#" + this.divid + '_popupbottom').outerHeight();
			}
			ld("#" + this.divid + " .dvpopupsroll").css("height", maxheight);
			ld("#" + this.divid + " .dvpopupsroll").css("max-height", maxheight);
		}
	}
	crmPopupobj.getBigpopupwidth = function (){
		return parseInt(CrmPopup.getClientWidth());
	}
	crmPopupobj.getSmallpopupwidth = function (){//全屏与缩小界面切换比例
		return parseInt(CrmPopup.getClientWidth()*0.8);
	}
	crmPopupobj.Fullscreencallback = function (switchtotype){
		if(switchtotype=="fullscreen"){
			this.fullscreen='yes';
		}else{
			this.fullscreen='no';
		}
		this.setScrollDivMaxHeight();
		this.center();
	}
	crmPopupobj.createHeadHtml = function () {
		this.popupheadhtml = '<div class="E_pop_tit" id="' + this.divid + '_head" style="cursor:move">';
		this.popupheadhtml += '<strong class="E_ptita">' + this.headtitle + '</strong>';
		this.popupheadhtml+='<div class="E_pop_tit_Second_Right">';
		//wym 240326 XUQIU20240322-06 新增界面，可以放大缩小，可以记住当前用户的选择
		if(this.isShowFullscreen && this.getFullscreen()=='yes'){
			this.popupheadhtml += "<i class='ld-fonticon ld-fonticon-gosmall tip-items-pop' data-tip='" + arrJsPopLabel['RECOVERY'] + "' data-direction='left' data-type='position' id='"+ this.divid +"_fullscreen' switchtotype='recovery'></i> ";
		} else if(this.isShowFullscreen && this.getFullscreen()=='no'){
			this.popupheadhtml += "<i class='ld-fonticon ld-fonticon-gobig tip-items-pop' data-tip='" + arrJsPopLabel['FULLSCREEN'] + "' data-direction='left' data-type='position' id='"+ this.divid +"_fullscreen' switchtotype='fullscreen'></i> ";
		}
		this.popupheadhtml += '<div class="E_ptitc tip-items-pop" value="' + arrJsPopLabel['LBL_CLOSE'] + '" data-tip="' + arrJsPopLabel['LBL_CLOSE'] + '" data-direction="bottom" data-type="position"  id="' + this.divid + '_imgclose"></div>';
		this.popupheadhtml += '</div>';
		this.popupheadhtml += '</div>';
	}

	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,channelcode_save,"",document.documentElement.clientWidth,'Settings',"",data.result.oktext,"",data.result.canceltext,"");
			crmPopupobj.createScrollDiv();//创建滚动条
			crmPopupobj.show(data.result.content);
			crmPopupobj.fields=data.result.fields;
			ld("#mul_moduledata_label").select2({closeOnSelect: false});
			crmPopupobj.setScrollDivMaxHeight();
			crmPopupobj.center();
			contact_way_num = 0;
			updateBlocklist();
			var blocklist_obj=ld('#'+crmPopupobj.divid+' .block-list');
			ld.each(blocklist_obj,function(tmpindex,tmpblockobj){//wym XUQIU1002285 新增编辑界面，点击左侧快速定位到指定区块
				ld(tmpblockobj).unbind("click").bind("click", function () {
					blocklist_anchor(this);
				})
			})
			ld("#" + crmPopupobj.divid + " .dvpopupsroll").get(0).addEventListener('scroll', blocklist_scroll);
			blocklist_scroll();//一进界面先触发一下滚动事件
		}else{
			crmPopupobj.CancelEvent();
			RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['YouhavenotinstalledenterprisewechatCRM']+'<br ><a href="http://www.51mis.cn/webapi/weixinapi_v5/wx_suite/authorize.html" target="_blank";">'+arrJsPopLabel['Installenterprisewechatversion']+'</a>');
			return false;
		}
	})
}
//附件图片验证
function channel_validateFile(form_ele,channelcode_type){
	if (form_ele.value == '') return true;
	var value = getFileNameOnlys(form_ele.value);
	var files = form_ele.files[0];
	var _size = files.size/1024/1024;
	//chj 2021/5/17 45898: （https://61mis.com/kfbcrm [^]）渠道码，自动打招呼设置，上传图片太大时，增加提示信息【$图片名称$不能上传,允许的类型PNG、JPG，且大小不能超过2MB】（需要补丁）
	if(!/\.(jpg|jpeg|png)$/.test(value) || _size > 2)
	{
		var confirm_str = value+arrJsPopLabel['CANNOTUOLOAD']+','+arrJsPopLabel['THEALLOWEDTYPES']+'PNG、JPG'+arrJsPopLabel['Andthesizecannotexceed2MB'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		form_ele.value = '';
		return false;
	}
	var popupobj=CrmPopup.getPopupObj('last');
	CrmPopup.setHtmlobjval(popupobj.divid,channelcode_type+ '_hidden',value);
	CrmPopup.findHtmlobj(popupobj.divid,"span_"+channelcode_type).html(value);
}

//编辑
function detail_channelcode_edit(event,record){
	var popupobj=CrmPopup.getPopupObj("last");
	popupobj.CancelEvent();
	channelcode_add(record);
}

//详情页-删除
function detail_channelcode_delete(event,record){
	RemindsMsg("", "LdPopWidth400px", 'ChannelCode', "yes", "yes", arrJsPopLabel['SUREWANTDELETE']);
	//确定按钮
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
		var surl = 'index.php?module=ChannelCode&action=ChannelCodeAjax&file=Delete&record='+record;
		ldAjax(surl,"",function(data){
			if(data.code==1){
				var popupobj=CrmPopup.getPopupObj("last");
				popupobj.CancelEvent();
				channelcode_refresh();//刷新页面
				DelProgressObjs();
			}
		})
	})
	
}
//删除
function channelcode_delete(obj){
	List_CheckBox_Ids.getIds('ChannelCode');
    var idstring = List_CheckBox_Ids.ids;
	count = List_CheckBox_Ids.num_rows;

    var excludedRecords = $('excludedRecords').value;
    var numOfRows = List_CheckBox_Ids.num_rows;

    if (count <= 0) {
        RemindsMsg("", "LdPopWidth400px", 'ChannelCode', "yes", "yes", "");
        return false;
    }
	 var confirm_status = true;

    var url = "&excludedRecords=" + excludedRecords;
    var alert_str = arrJsPopLabel['SUREWANTDELETETHEDELECTED'] + ' ' + parseInt(count) + ' ' + arrJsPopLabel['RECORDS'];
    if (parseInt(count) > parseInt(getMaxMassOperationLimit())) {
        alert_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT', parseInt(count), getMaxMassOperationLimit(), '');
    }

    var searchScope = "";
    if (document.getElementById("SmOwnerSearchScope") != undefined)
        searchScope = encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);

    RemindsMsg("", "LdPopWidth400px", 'ChannelCode', "yes", "yes", alert_str + arrJsPopLabel['WENHAO']);
	 //确定按钮
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
		var surl = 'index.php?module=ChannelCode&action=ChannelCodeAjax&file=Delete&idlist='+idstring;
		ldAjax(surl,"",function(data){
			if(data.code==1){
				channelcode_refresh();//刷新页面
				DelProgressObjs();
			}
		})
	})
}

//查看
function channelcode_view(record){
	var surl = 'index.php?module=ChannelCode&action=ChannelCodeAjax&file=DetailView&record='+record;
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth1100px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,"","","LdPopWidth1100px",'Settings',"","","","","");  
			crmPopupobj.show(data.result.content);
			ld("#mul_moduledata_label").select2({closeOnSelect: false});
			crmPopupobj.setScrollDivMaxHeight();
			crmPopupobj.center();
		}
	})
}

function channelcode_save(){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid = popupobj.divid;
	var userid = CrmPopup.findHtmlobj(divid,"userid").val();
	if(userid == ''){
		var input_label = CrmPopup.findHtmlobj(divid,"userid").attr('input_label');
		RemindsMsg("","LdPopWidth400px","","yes","",input_label+arrJsPopLabel['CANOTEMPTY']);	//选择企业微信员工不能为空！
		return false;
	}
	var channelname = CrmPopup.findHtmlobj(divid,"channelname").val();
	if(channelname == ''){
		var input_label = CrmPopup.findHtmlobj(divid,"channelname").attr('input_label');
		RemindsMsg("","LdPopWidth400px","","yes","",input_label+arrJsPopLabel['CANOTEMPTY']);	//渠道名称不能为空！
		return false;
	}
	var related = CrmPopup.findHtmlobj(divid,"related").val();
	//开启自动打招呼
	if(ld("#"+popupobj.divid+" [name=contact_way]").is(':checked') == true){
		var contact_way_type = '';
		if(ld("#"+popupobj.divid+" input[name='contact_way_other']:checked").val() != undefined){
			contact_way_type = ld("#"+popupobj.divid+" input[name='contact_way_other']:checked").val();
		}
		if(ld("#"+popupobj.divid+" [name=contact_way_wenzi]").is(':checked') == false && contact_way_type == ''){
			RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['Selectatleastonemessagetypewhenautogreetingison']);
			return false;
		}else{
			//文字
			if(ld("#"+popupobj.divid+" [name=contact_way_wenzi]").is(':checked') == true){
				var words_content = CrmPopup.findHtmlobj(divid,"words_content").val();
				if(words_content == ''){
					var input_label = CrmPopup.findHtmlobj(divid,"words_content").attr('input_label');
					RemindsMsg("","LdPopWidth400px","","yes","",input_label+arrJsPopLabel['CANOTEMPTY']);	//文字不能为空！
					return false;
				}
			}
			//链接卡片
			if(contact_way_type == 'card'){
				var card_title = CrmPopup.findHtmlobj(divid,"card_title").val();
				if(card_title == ''){
					var input_label = CrmPopup.findHtmlobj(divid,"card_title").attr('input_label');
					RemindsMsg("","LdPopWidth400px","","yes","",input_label+arrJsPopLabel['CANOTEMPTY']);	//链接卡片标题不能为空！
					return false;
				}
				var img_hidden = CrmPopup.findHtmlobj(divid,"card_hidden").val();
				if(img_hidden == ''){
					var input_label = CrmPopup.findHtmlobj(divid,"card_hidden").attr('input_label');
					RemindsMsg("","LdPopWidth400px","","yes","",input_label+arrJsPopLabel['CANOTEMPTY']);	//链接卡片图片不能为空！
					return false;
				}
				var card_href = CrmPopup.findHtmlobj(divid,"card_href").val();
				if(card_href == ''){
					var input_label = CrmPopup.findHtmlobj(divid,"card_href").attr('input_label');
					RemindsMsg("","LdPopWidth400px","","yes","",input_label+arrJsPopLabel['CANOTEMPTY']);	//卡片链接不能为空！
					return false;
				}
			}
			//小程序
			if(contact_way_type == 'app'){
				var app_title = CrmPopup.findHtmlobj(divid,"app_title").val();
				if(app_title == ''){
					var input_label = CrmPopup.findHtmlobj(divid,"app_title").attr('input_label');
					RemindsMsg("","LdPopWidth400px","","yes","",input_label+arrJsPopLabel['CANOTEMPTY']);	//小程序标题不能为空！
					return false;
				}
				var img_hidden = CrmPopup.findHtmlobj(divid,"app_hidden").val();
				if(img_hidden == ''){
					var input_label = CrmPopup.findHtmlobj(divid,"app_hidden").attr('input_label');
					RemindsMsg("","LdPopWidth400px","","yes","",input_label+arrJsPopLabel['CANOTEMPTY']);	//小程序封面图不能为空！
					return false;
				}
				var app_id = CrmPopup.findHtmlobj(divid,"app_id").val();
				if(app_id == ''){
					var input_label = CrmPopup.findHtmlobj(divid,"app_id").attr('input_label');
					RemindsMsg("","LdPopWidth400px","","yes","",input_label+arrJsPopLabel['CANOTEMPTY']);	//小程序AppID不能为空！
					return false;
				}
				var app_src = CrmPopup.findHtmlobj(divid,"app_src").val();
				if(app_src == ''){
					var input_label = CrmPopup.findHtmlobj(divid,"app_src").attr('input_label');
					RemindsMsg("","LdPopWidth400px","","yes","",input_label+arrJsPopLabel['CANOTEMPTY']);	//小程序Page路径不能为空！
					return false;
				}
			}
			//图片
			if(contact_way_type == 'img'){
				var img_hidden = CrmPopup.findHtmlobj(divid,"img_hidden").val();
				if(img_hidden == ''){
					var input_label = CrmPopup.findHtmlobj(divid,"img_hidden").attr('input_label');
					RemindsMsg("","LdPopWidth400px","","yes","",input_label+arrJsPopLabel['CANOTEMPTY']);	//消息图片不能为空！
					return false;
				}
				
			}

		}
	}
	var fromdata = new FormData(ld(".ajax_form")[0]);
	ld('#rptContentLoading').show();
	ld.ajax({
		type: 'POST',
		dataType: 'json',
		processData: false, // 告诉jquery不要处理数据
		contentType: false, // 告诉jquery不要设置contentType
		data: fromdata,
		url: 'index.php?module=ChannelCode&action=ChannelCodeAjax&file=Save',
		success: function(res) {
			var popupobjprev=CrmPopup.getPopupObj("lastprev");
			popupobj.CancelEvent();
			popupobjprev.CancelEvent();
			ld('#rptContentLoading').hide();
			if(related == 'yes'){
				var cr_popupobj=CrmPopup.getPopupObj("last");
				CrmPopup.findHtmlobj(cr_popupobj.divid,"channelcode_id").val(res.result.channelcode_id);
				CrmPopup.findHtmlobj(cr_popupobj.divid,"channelcode_id_name").val(res.result.channelname);
				
			}else{
				channelcode_refresh();		
			}
			
		},
		error: function(xhr, textStatus, errorThrown) {

		}
	})
}

//选择企业微信员工
function channelcode_selectuser(){
	 getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function(){
        
        ScopePopup_Details.getInstance().wx_user('userid','userid_name','');
    });
}

//企业微信标签
function channelcode_label(){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid = popupobj.divid;
	var channellabel_id = CrmPopup.findHtmlobj(divid,"channellabel_id").val();
	var surl = 'index.php?module=ChannelCode&action=ChannelCodeAjax&file=ChannelLabel&channellabel_id='+encodeURIComponent(channellabel_id);
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,sel_channelcode_label,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");  
			crmPopupobj.show(data.result.content);
			ld("#mul_moduledata_label").select2({closeOnSelect: false});
			var tableobj = ld('#'+crmPopupobj.divid).find("table#assignPicklistTable");
			var LeftObj = tableobj.find("#AssmablyList");
			var RightObj = tableobj.find("#selectedAssmablyColumns");
			var Drag_Transfer = new DragTransfer();
			var translabel = {
				available: arrJsPopLabel['Optionaltag'],
				selected: arrJsPopLabel['SelectedTags'],
				placeholder: arrJsPopLabel['PleaseEnterTagSearchFor'],
			};
			Drag_Transfer.SetTranslabel(translabel);
			Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'reset','290');
			crmPopupobj.setScrollDivMaxHeight();
			crmPopupobj.center();
		}
	})
}

//添加企业微信标签
function add_channelcode_label(){
	var surl = 'index.php?module=ChannelCode&action=ChannelCodeAjax&file=ChannelLabel_add';
	var popupobj=CrmPopup.getPopupObj("last");
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,save_channelcode_label,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");  
			crmPopupobj.show(data.result.content);
			ld("#mul_moduledata_label").select2({closeOnSelect: false});
			crmPopupobj.setScrollDivMaxHeight();
			crmPopupobj.center();
		}
	})
}
//新增标签 - 添加标签
function add_channelcode_tr(){
	var popupobj=CrmPopup.getPopupObj("last");
	var channelcode_tr_obj = ld("#"+popupobj.divid+" [name=div_moduletag_tr]");
	var label_content_num = ld("#"+popupobj.divid+" [name=label_content_num]").val();
	var placeholder = ld("#"+popupobj.divid+" [name=div_moduletag_tr]").attr('input_val');
	var new_label_content_num = parseInt(label_content_num) + 1;
	channelcode_tr_obj.append( ld('<div name="channelcode_tr_num_'+new_label_content_num+'"><br /><input type="text" name="label_content" id="label_content" style="width:60%;margin-top: 5px;" placeholder="'+placeholder+'" class="detailedViewTextBox" tabindex="'+new_label_content_num+'" /><a class="icon-homeimg icon-sdel2" href="javascript:;" style="margin-left: 10px;margin-top: 9px;" onclick="del_channelcode_tr('+new_label_content_num+')" title="'+arrJsPopLabel['DELETE']+'"></a></div>') );
	ld("#"+popupobj.divid+" [name=label_content_num]").val(new_label_content_num);
	popupobj.setScrollDivMaxHeight();
	popupobj.center();
	ld("#"+popupobj.divid+" [name=div_moduletag_tr]").scrollTop(ld("#"+popupobj.divid+" [name=div_moduletag_tr]")[0].scrollHeight );
}

//新增标签 - 删除标签
function del_channelcode_tr(row){
	var popupobj=CrmPopup.getPopupObj("last");
	ld("#"+popupobj.divid+" [name=channelcode_tr_num_"+row+"]").hide();
}

//添加保存企业标签
function save_channelcode_label(){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid = popupobj.divid;
	var label_group_name = CrmPopup.findHtmlobj(divid,"label_group_name").val();
	if(label_group_name == ''){
		var input_label = CrmPopup.findHtmlobj(divid,"label_group_name").attr('input_label');
		RemindsMsg("","LdPopWidth400px","","yes","",input_label+arrJsPopLabel['CANOTEMPTY']);
		return false;
	}
	/*if(label_content == ''){
		
	}*/
	var label_num = parseInt(ld("#"+popupobj.divid+" [name=label_content_num]").val());
	if(label_num >= 1){
		var lanel_json = new Array();
		for(var i = 1; i <= label_num; i++){
			var div_display = ld("#"+popupobj.divid+" [name=channelcode_tr_num_"+i+"]").css('display');
			if(div_display == 'block'){
				var _label = ld("#"+popupobj.divid+" [name=label_content][tabindex="+i+"]").val();
				if(_label != '')
					lanel_json.push(encodeURIComponent(_label));
			}
		}
		if(lanel_json.length < 1){
			var input_label = ld("#"+popupobj.divid+" [name=label_content][tabindex=1]").attr('input_label');
			RemindsMsg("","LdPopWidth400px","","yes","",input_label+arrJsPopLabel['CANOTEMPTY']);
			return false;
		}
	}
	//
	var surl = 'index.php?module=ChannelCode&action=ChannelCodeAjax&file=ChannelLabel_save&label_group_name='+encodeURIComponent(label_group_name)+"&label_content="+JSON.stringify(lanel_json);
	ldAjax(surl,"",function(data){
		if(data.code==1){
			var prevpopupobj=CrmPopup.getPopupObj("lastprev");
			prevpopupobj.CancelEvent();
			var prevpopupobj=CrmPopup.getPopupObj("lastprev");
			var divid = prevpopupobj.divid;
			//edit 2020/11/12 43213: （61mis.com/kfbcrm）（渠道码）渠道码新建/编辑界面，点击添加“企业微信标签”，选择完标签后，若再点击“新增标签”，则已选标签只有最新的这个标签，而之前的已选标签消失
			var channellabel = CrmPopup.findHtmlobj(divid,'channellabel').val();
			var channellabel_id = CrmPopup.findHtmlobj(divid,'channellabel_id').val();
			if(channellabel != ''){
				CrmPopup.findHtmlobj(divid,'channellabel').val(channellabel + ','+data.result.name);
				CrmPopup.findHtmlobj(divid,'channellabel_id').val(channellabel_id+'|::##::|'+data.result.label);
			}else{
				CrmPopup.findHtmlobj(divid,'channellabel').val(data.result.name);
				CrmPopup.findHtmlobj(divid,'channellabel_id').val(data.result.label);
			}
			
			popupobj.CancelEvent();
			DelProgressObjs();
			
		}else{
			RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
		}
	})
}

//企业微信保存确定事件
function sel_channelcode_label(){
	//组件
	var prevpopupobj=CrmPopup.getPopupObj("lastprev");
	var popupobj=CrmPopup.getPopupObj("last");
	var prevdivid=prevpopupobj.divid;
	var selectedAssmablyColumnsObj=getObj("selectedAssmablyColumns")
	var selectedAssmablyColumnsString = [];
	var selectedAssmablyColumnsName = [];
	var selectedAssmablyColumnsArray = new Array();
	for (i=0;i<selectedAssmablyColumnsObj.options.length;i++) 
	{
		selectedAssmablyColumnsArray = selectedAssmablyColumnsObj.options[i].value.split('|::|');
		selectedAssmablyColumnsName[i] = selectedAssmablyColumnsArray[2];
		selectedAssmablyColumnsString[i] = selectedAssmablyColumnsObj.options[i].value;
	}
	if(empty(selectedAssmablyColumnsString)){
		 CrmPopup.findHtmlobj(prevdivid,'channellabel').val('');
		 CrmPopup.findHtmlobj(prevdivid,'channellabel_id').val('');
	}else{
		CrmPopup.findHtmlobj(prevdivid,'channellabel').val(selectedAssmablyColumnsName.join(' , '));
		CrmPopup.findHtmlobj(prevdivid,'channellabel_id').val(selectedAssmablyColumnsString.join('|::##::|'));
	}
	popupobj.CancelEvent();
}

var contact_way_num = 0;
//自动打招呼
function contact_way_chk(event,waytype){
	var popupobj=CrmPopup.getPopupObj("last");
	//开启自动打招呼
	if(waytype == 'open'){
		if(ld("#"+popupobj.divid+" [name=contact_way]").is(':checked') == true){
			ld("#"+popupobj.divid+" [name=contact_way_tr]").show();
		}else{
			ld("#"+popupobj.divid+" [name=contact_way_words_tr]").hide();
			ld("#"+popupobj.divid+" [name=contact_way_tr]").hide();
			ld("#"+popupobj.divid+" [name=contact_way_card_tr1]").hide();
			ld("#"+popupobj.divid+" [name=contact_way_card_tr2]").hide();
			ld("#"+popupobj.divid+" [name=contact_way_card_tr3]").hide();
			ld("#"+popupobj.divid+" [name=contact_way_card_tr4]").hide();
			ld("#"+popupobj.divid+" [name=contact_way_img_tr1]").hide();
			ld("#"+popupobj.divid+" [name=contact_way_app_tr1]").hide();
			ld("#"+popupobj.divid+" [name=contact_way_app_tr2]").hide();
			ld("#"+popupobj.divid+" [name=contact_way_app_tr3]").hide();
			ld("#"+popupobj.divid+" [name=contact_way_app_tr4]").hide();
		}
	}
	//文字
	if(waytype == 'words'){
		if(ld("#"+popupobj.divid+" [name=contact_way_wenzi]").is(':checked') == true){
			ld("#"+popupobj.divid+" [name=contact_way_words_tr]").show();
		}else{
			ld("#"+popupobj.divid+" [name=contact_way_words_tr]").hide();
		}
	}
    //其他 勾选其他时：链接卡片、图片、小程序可以勾选。取消勾选其他时：链接卡片、图片、小程序勾选取消，并设置为不可勾选。
    if(waytype == 'others'){
        if(ld("#"+popupobj.divid+" [name=contact_way_others]").is(':checked')==true){
            ld("#"+popupobj.divid+" [name=contact_way_other]").attr("disabled",false);
        }else{
            ld("#"+popupobj.divid+" [name=contact_way_other]").attr("disabled",true);
            ld("#"+popupobj.divid+" [name=contact_way_other]").prop('checked',false);//不选中
            ld("#"+popupobj.divid+" [name=contact_way_card_tr1]").hide();
            ld("#"+popupobj.divid+" [name=contact_way_card_tr2]").hide();
            ld("#"+popupobj.divid+" [name=contact_way_card_tr3]").hide();
            ld("#"+popupobj.divid+" [name=contact_way_card_tr4]").hide();
            ld("#"+popupobj.divid+" [name=contact_way_img_tr1]").hide();
            ld("#"+popupobj.divid+" [name=contact_way_app_tr1]").hide();
            ld("#"+popupobj.divid+" [name=contact_way_app_tr2]").hide();
            ld("#"+popupobj.divid+" [name=contact_way_app_tr3]").hide();
            ld("#"+popupobj.divid+" [name=contact_way_app_tr4]").hide();
        }
    }
	//链接卡片、图片、、小程序
	if(waytype == 'card' || waytype == 'img' || waytype == 'app'){
		
		var contact_way_type = ld("#"+popupobj.divid+" input[name='contact_way_other']:checked").val();
		ld("#"+popupobj.divid+" [name=contact_way_card_tr1]").hide();
		ld("#"+popupobj.divid+" [name=contact_way_card_tr2]").hide();
		ld("#"+popupobj.divid+" [name=contact_way_card_tr3]").hide();
		ld("#"+popupobj.divid+" [name=contact_way_card_tr4]").hide();
		ld("#"+popupobj.divid+" [name=contact_way_img_tr1]").hide();
		ld("#"+popupobj.divid+" [name=contact_way_app_tr1]").hide();
		ld("#"+popupobj.divid+" [name=contact_way_app_tr2]").hide();
		ld("#"+popupobj.divid+" [name=contact_way_app_tr3]").hide();
		ld("#"+popupobj.divid+" [name=contact_way_app_tr4]").hide();
		if(contact_way_type == 'card'){
			ld("#"+popupobj.divid+" [name=contact_way_card_tr1]").show();
			ld("#"+popupobj.divid+" [name=contact_way_card_tr2]").show();
			ld("#"+popupobj.divid+" [name=contact_way_card_tr3]").show();
			ld("#"+popupobj.divid+" [name=contact_way_card_tr4]").show();
			if(contact_way_num == 0){
				popupobj.setScrollDivMaxHeight();
				popupobj.center();
				contact_way_num = 1;
			}
		}else if(contact_way_type == 'img'){
			ld("#"+popupobj.divid+" [name=contact_way_img_tr1]").show();
			popupobj.setScrollDivMaxHeight();
			popupobj.center();
		}else if(contact_way_type == 'app'){
			ld("#"+popupobj.divid+" [name=contact_way_app_tr1]").show();
			ld("#"+popupobj.divid+" [name=contact_way_app_tr2]").show();
			ld("#"+popupobj.divid+" [name=contact_way_app_tr3]").show();
			ld("#"+popupobj.divid+" [name=contact_way_app_tr4]").show();
			if(contact_way_num == 0){
				popupobj.setScrollDivMaxHeight();
				popupobj.center();
				contact_way_num = 1;
			}
		}
		
	}
}

function addColumn(source, destination) 
{
    var availListObj=getObj(source)
    var selectedColumnsObj=getObj(destination)


    for (i=0;i<availListObj.length;i++) 
    {
        if (availListObj.options[i].selected==true) 
        {            	
        	var rowFound=false;
        	var existingObj=null;
            for (j=0;j<selectedColumnsObj.length;j++) 
            {
                if (selectedColumnsObj.options[j].value==availListObj.options[i].value) 
                {
                    rowFound=true
                    existingObj=selectedColumnsObj.options[j]
                    break
                }
            }
            if (rowFound!=true) 
            {
                var newColObj=document.createElement("OPTION")
                newColObj.value=availListObj.options[i].value
                if (browser_ie) newColObj.innerText=availListObj.options[i].innerText
                else if (browser_nn4 || browser_nn6) newColObj.text=availListObj.options[i].text
                selectedColumnsObj.appendChild(newColObj)
                availListObj.options[i].selected=false
                newColObj.selected=true
                availListObj.remove(i);//20140902，diony，右移时删除左边信息
                rowFound=false
            } 
            else 
            {
                if(existingObj != null) existingObj.selected=true
            }
        }
    }
}

function channel_SmOwnerSearchScopeChange(selectView,module,parenttab){
	var popupobj=CrmPopup.getPopupObj("last");
	var searchscope = encodeURIComponent(selectView.options[selectView.options.selectedIndex].value);

	/**
	 * 查看范围 高级功能实现
	 * @project PROT180 角色权限改进
	 * @author Tujt 2015-03-25
	 */
	if('smowner_search_senior' == searchscope){//高级
		SmOwnerSearchSenior(module,searchscope);return false;
	}

	var viewnamid="";
    
   // if(module=='Reminds'){
    //记住选择的数据分类
       var viewnamid = '&viewname='+ld('#viewname').val();
   // }
    var  customtype="";
    if(document.massdelete.publicaccounttype!=undefined)
    customtype=document.massdelete.publicaccounttype.value;
    //alert("module="+module+"&action="+module+"Ajax&file=ListView&ajax=true&start=1&query=true &SearchScope="+viewName+"&parenttab="+parenttab+"&accounttype="+customtype);
	ld('#rptContentLoading').show();
    //35186: （1.6账户）银行账户列表界面：勾选单据删除弹出的提示内容错误应该是：原因：该单据已经初始化。
	var urlstring = "module="+module+"&action="+module+"Ajax&file=ListView&ajax=true&start=1&query=true&SearchScope="+searchscope+"&accounttype="+customtype+viewnamid+"&query=true&querysession=1";
	if(module == 'Approve'){
		if(ld('#fromapprovemodule') != undefined){
			urlstring += '&fromapprovemodule='+ld('#fromapprovemodule').val();
		}
		if(ld('#approvestatus') != undefined){
			urlstring += '&approvestatus='+ld('#approvestatus').val();
		}
	}
	if(popupobj != undefined){
		if(popupobj.searchtype=='Advanced')
		{
			//32156: 单据列表：设置高级查询后，切换查看范围时，不清空高级查询条件
			var advft_criteria = $('advft_criteria').value;
			var advft_criteria_groups = $('advft_criteria_groups').value;
			urlstring += '&advft_criteria='+encodeURIComponent(advft_criteria)+'&advft_criteria_groups='+advft_criteria_groups+'&';
			urlstring += 'searchtype=advance';
		}
		else if(popupobj.searchtype=='Basic')
		{
			var divid="dv_listbasiscsearch";
			search_fld_val= CrmPopup.findHtmlobj(divid,"search_field").val();
		   search_txt_val= encodeURIComponent(CrmPopup.findHtmlobj(divid,'search_text').val());
		   urlstring += '&search_field='+search_fld_val+'&searchtype=BasicSearch&search_text='+search_txt_val+'&searchtype=BasicSearch';
		}else if(popupobj.searchtype=='Tiled'){
			// @edit:dong @date:2020/08/24 @reason: 平铺查找 获取本地搜索条件
			var criteriaConditions = getlocalStorageConditions(popupobj.module);
			var criteriaGroups = getlocalStorageGroups(popupobj.module);

			urlstring += '&advft_criteria='+encodeURIComponent(criteriaConditions)+'&advft_criteria_groups='+criteriaGroups+'&';
			urlstring += 'searchtype=tiled';
		}
	}

	ld('#rptContentLoading').show();
	new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:urlstring,
			onComplete: function(response) {
				ld('#rptContentLoading').hide();
				//alert(response.responseText);
				var result = response.responseText;
				// alert(result);
				document.getElementById('ListViewContents').innerHTML= result;
			}
		}
	);
}

//相关信息
function channelcode_relateds(obj){
	var popupobj=CrmPopup.getPopupObj("last");
	ld("#"+popupobj.divid+" [type=DetailViewTab]").removeClass("current");
    //ld("#"+popupobj.divid+" [type=DetailViewTab][relatetag=detailview]").addClass("current")
	var relatetag = ld(obj).attr('relatetag');
	ld("#"+popupobj.divid+" [type=DetailViewTab][relatetag="+relatetag+"]").addClass("current");
	var record = ld("#"+popupobj.divid+" [type=DetailViewTab][relatetag="+relatetag+"]").attr("relatedid");
	//alert(relatetag);
	if(relatetag == 'detailview'){
		var surl = 'index.php?module=ChannelCode&action=ChannelCodeAjax&file=DetailView&ajax=yes&record='+record;
		ldAjax(surl,"",function(data){
			if(data.code==1){
				ld("#"+popupobj.divid+" [name=channelcode_detail_div]").html(data.result.content);
				DelProgressObjs();
			}
		})
	}else if(relatetag == 'code_history'){
		var surl = 'index.php?module=ChannelCode&action=ChannelCodeAjax&file=Channelcode_history&ajax=yes&record='+record;
		ldAjax(surl,"",function(data){
			if(data.code==1){
				//alert(data.result.content);
				ld("#"+popupobj.divid+" [name=channelcode_detail_div]").html(data.result.content);
				DelProgressObjs();
			}
		})
	}
}

//相关信息分页
function channelcode_related_page(record,page){
	if(page >= 1){
		var popupobj=CrmPopup.getPopupObj("last");
		var surl = 'index.php?module=ChannelCode&action=ChannelCodeAjax&file=Channelcode_history&ajax=yes&record='+record+"&start="+page;
		ldAjax(surl,"",function(data){
			if(data.code==1){
				//alert(data.result.content);
				ld("#"+popupobj.divid+" [name=channelcode_detail_div]").html(data.result.content);
				DelProgressObjs();
			}
		})
	}
}
function channelcode_related_pagebygo(event,thisobj){
	
	var popupobj=CrmPopup.getPopupObj("last");
	var record = thisobj.attr('record');
	var page = CrmPopup.findHtmlobj(popupobj.divid,"pagenum").val();
	if(empty(page) || page < 0){
		page = 1;
	}
	var surl = 'index.php?module=ChannelCode&action=ChannelCodeAjax&file=Channelcode_history&ajax=yes&record='+record+"&start="+page;
	ldAjax(surl,"",function(data){
		if(data.code==1){
			//alert(data.result.content);
			ld("#"+popupobj.divid+" [name=channelcode_detail_div]").html(data.result.content);
			DelProgressObjs();
		}
	})
	
}
function updateBlocklist()
{
	//XUQIU1002354 新增编辑界面优化
	var popupobj=CrmPopup.getPopupObj("last");
	var blockobjs=ld("#"+popupobj.divid).find("[tag=headblock-title]");
	var block_list = [];
	ld.each(ld(blockobjs),function(tmpindex,tmpblockobj){
		block_list[tmpindex]=ld(tmpblockobj).text();
	})
	var editleft_html = '<ul>';
	ld.each(block_list,function(tmpindex,tmpblock_label) {
		editleft_html += '<li><div class="block-list" block_index="'+tmpindex+'"><a title="'+tmpblock_label+'">'+tmpblock_label+'</a></div></li>';
	});
	editleft_html += '</ul>';
	ld("#"+popupobj.divid+" .edit-left").html(editleft_html);
}
//wym XUQIU1002285 新增编辑界面，左侧增加快速定位到指定区块
function blocklist_anchor(obj) {
	var popupobj=CrmPopup.getPopupObj("last");
	var blockobj= ld('#'+popupobj.divid+' .block-list.selected');
	ld(blockobj).removeClass('selected');
	ld(blockobj).find('a').css('color','#8392A7');
	ld(obj).addClass('selected');
	ld(obj).find('a').css('color','#3B7CFF');
	var target_index = ld(obj).attr('block_index'); // 获取点击的区块序号
	//XUQIU1002354 新增编辑界面优化
	var targetElement = ld("#"+popupobj.divid+" [tag=headblock-title]").eq(target_index); // 查找对应序号的区块
	if (targetElement.length) {
		var scrollobj= ld('#'+popupobj.divid+' .dvpopupsroll');
		var currentScrollPosition = ld(scrollobj).scrollTop();
		if(ld("#" + popupobj.divid + '_head').length>0){
			var headheight = ld("#" + popupobj.divid + '_head').outerHeight();
		}
		//点击事件不能触发滚动事件，先把右侧滚动条事件解绑
		ld(scrollobj).get(0).removeEventListener('scroll', blocklist_scroll);
		// 使用动画效果滚动到目标元素
		ld(scrollobj).get(0).scrollTop = currentScrollPosition+targetElement.offset().top-headheight;            // 等待一段时间，然后重新绑定滚动事件处理程序
		setTimeout(function () {
			ld(scrollobj).get(0).addEventListener('scroll', blocklist_scroll);
		}, 1000); // 1秒后重新绑定滚动事件处理程序
	}
}
//wym XUQIU1002285 右侧滚动，左侧选中当前区块
function blocklist_scroll() {
	//XUQIU1002354 新增编辑界面优化
	var popupobj=CrmPopup.getPopupObj("last");
	var blockobjs=ld("#"+popupobj.divid+" [tag=headblock-title]"); //区块标题元素
	var headheight=0;
	if(ld("#" + popupobj.divid + '_head').length>0) {
		headheight = ld("#" + popupobj.divid + '_head').outerHeight();
	}
	ld.each(ld(blockobjs),function(tmpindex,tmpobj){
		var targettop = ld(tmpobj).offset().top-headheight;
		if(targettop>=0){
			var select_blockobj= ld('#'+popupobj.divid+' .block-list.selected');
			if(ld(select_blockobj).length>0){
				ld(select_blockobj).removeClass('selected');
				ld(select_blockobj).find('a').css('color','#8392A7');
			}
			var blockobjs= ld('#'+popupobj.divid+' .block-list');
			if(targettop>0){//targettop大于零，则表示是上一个区块
				if(tmpindex==0){ //BUG0077529 如果是第一个区块 则选中第一个
					var cur_blockobj=ld(blockobjs).eq(tmpindex);
				}else{
					var cur_blockobj=ld(blockobjs).eq(tmpindex-1);
				}
			}else if(targettop==0){//targettop等于零，则表示是当前区块
				var cur_blockobj=ld(blockobjs).eq(tmpindex);
			}
			ld(cur_blockobj).addClass('selected');
			ld(cur_blockobj).find('a').css('color','#3B7CFF');
			return false;
		}
	})
}