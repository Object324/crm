function cls_ScopePopup(scopepopupobj,obj) {
	cls_ScopePopup.cnt++;
	this.scopepopupobj = scopepopupobj;
	cls_ScopePopup.popup_divid = 'selectpopup_' + cls_ScopePopup.cnt;
	this.createDiv();
	this.chooseInfo = [];
	this.chooseInfoIdIndex = [];
	cls_ScopePopup.return_obj = '';
	cls_ScopePopup.triggertype = '';
	this.currindex = -1;
}


cls_ScopePopup.cnt = 0;
cls_ScopePopup.triggertype = '';
cls_ScopePopup.return_obj = '';//回传对象
cls_ScopePopup.popup_selecttype = 'user';//选择类型：用户user，部门group，角色profile
cls_ScopePopup.popup_more_selecttype = '';//多选时，默认选项
cls_ScopePopup.splice_symbol = ',';
cls_ScopePopup.popup_inputtype = 'checkbox'; //选择类型,多选 单选
cls_ScopePopup.prop = {
	'popup_url': '',
	'popup_module': '',
	'popup_value': '',
	'disabled_value': '',
	'popup_inputclick': function (obj) {
		cls_ScopePopup.return_obj = obj;
	}
};

//创建div
cls_ScopePopup.prototype.createDiv = function(){
	let that = this;
    if(!empty(this.scopepopupobj.popup_caption_value)){
        this.scopepopupobj.popup_caption_html = this.scopepopupobj.popup_caption_html.replace('##title##',this.scopepopupobj.popup_caption_value);
    }else{
		this.scopepopupobj.popup_caption_html = '';
	}
	this.innerHTML = '';
	var popup_header = this.scopepopupobj.header;
    if(this.scopepopupobj.header && popup_header != undefined){
		this.innerHTML += popup_header;
	}

    this.innerHTML +=
		'<div class="" id="treeviewcontent" style="background-color: #fff;">'+
			'<div name="selectpopup_content" class="selectPop" style="height: 360px;">' +
				'<div class="el-loading-mask ld-loading-mask">' +
				'    <div class="el-loading-spinner">' +
				'        <svg viewBox="25 25 50 50" class="circular"><circle cx="50" cy="50" r="20" fill="none" class="path"></circle></svg>' +
				'    </div>' +
				'</div>' +
			'</div>' +
		'</div>';

	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px","","",'none',"","");

	crmPopupobj.createHeadHtml = function (){
		this.popupheadhtml = '<div class="E_pop_tit" id="' + crmPopupobj.divid + '_head">' +
			'<strong class="E_ptita">'+that.scopepopupobj.popup_caption_value+'</strong>' +
			'<div class="E_pop_tit_Second_Right">' +
			'<div class="ld-fonticon ld-fonticon-close tip-items-pop" value="'+arrJsPopLabel['LBL_CLOSE']+'" data-tip="'+arrJsPopLabel['LBL_CLOSE']+'" data-direction="bottom" data-type="position" id="'+crmPopupobj.divid+'_imgclose"></div>' +
			'</div>' +
			'</div>';
	}

	crmPopupobj.createBottomHtml = function(){
		this.popupbottomhtml = '<div class="E_pbtn" id="' + crmPopupobj.divid + '_popupbottom" style="display: flex;align-items: center;padding: 16px 24px;background: #fff;border-top: 1px solid #DCDEE0 ;">';
		this.popupbottomhtml += '<div style="margin-left: 0px;">';
		if(that.scopepopupobj.AccountHierarchy && that.scopepopupobj.AccountHierarchy == 'AccountHierarchy'){
			this.popupbottomhtml += '<input type="checkbox" class="checkbox-item j-all-checkbox tb-checkbox-selected" id="viewaccount_contacts" checked style="cursor: pointer;">';
			this.popupbottomhtml += '<label for="viewaccount_contacts" style="margin-left: 5px;">'+arrJsPopLabel['Displaycontacts']+'</label>';
		}
		else{
			if(cls_ScopePopup.popup_selecttype == 'user'){
				if(window.localStorage && window.localStorage.getItem('viewuser_disableuser') && window.localStorage.getItem('viewuser_disableuser') == 'yes'){
					this.popupbottomhtml += '<input type="checkbox" class="checkbox-item j-all-checkbox tb-checkbox-selected" id="viewuser_disableuser" checked style="cursor: pointer;">';
				}else{
					this.popupbottomhtml += '<input type="checkbox" class="checkbox-item j-all-checkbox" id="viewuser_disableuser" style="cursor: pointer;">';
				}
				this.popupbottomhtml += '<label for="viewuser_disableuser" style="margin-left: 5px;margin-right: 16px;">'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label>';
			}
			if(cls_ScopePopup.popup_selecttype == 'user' || cls_ScopePopup.popup_selecttype == 'group'){
				this.popupbottomhtml += '<input type="checkbox" class="checkbox-item j-all-checkbox" id="viewuser_unfoldsubgroup" style="cursor: pointer;display: none;">';
				this.popupbottomhtml += '<label for="viewuser_unfoldsubgroup" style="margin-left: 5px;display: none;">'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label>';
			}
		}
		this.popupbottomhtml += '</div>';
		this.popupbottomhtml += '<div style="margin-left: auto;">' +
			'<input name="button" id="' + crmPopupobj.divid + '_btnok" class="E_pbtnok ld-button ld-button-primary" value="'+arrJsPopLabel['CONFIRME']+'" tagclick="" type="button">' +
			'<input name="button" class="E_pbtncancel ld-button ld-button-cancel" value="'+arrJsPopLabel['CANCEL']+'" id="' + crmPopupobj.divid + '_btncancel" type="button" style="margin-left: 16px !important;">' +
			'</div>' +
			'</div>';
	}

	crmPopupobj.setParams(this.scopepopupobj.popup_caption_value,this.scopepopupobj.setEventBtnOk,this.scopepopupobj.setEventBtnCancel,"LdPopWidth600px",cls_ScopePopup.prop.popup_module,"",arrJsPopLabel['CONFIRME'],"",arrJsPopLabel['CANCEL']);
	crmPopupobj.show(this.innerHTML);


	ld('#'+crmPopupobj.divid +" #popup_locationdiv").focus();
	cls_ScopePopup.popup_divid = crmPopupobj.divid;
	cls_ScopePopup.popupobj = crmPopupobj;

	//wyt BUG0054119 220722 工作汇报->现在点评，点评弹出层中选择“抄送人员”弹出层被遮挡
	ld('#'+crmPopupobj.divid).css('z-index','9001');

	var subgroupcheckbox = '';
    if(ld('#'+crmPopupobj.divid+' #viewuser_unfoldsubgroup').length>0){ //获取缓存的CheckBox，若为‘checked’则保存将CheckBox勾选
		subgroupcheckbox = getsubGroupCheckbox(); //2023-8-9 xxy 判断弹出层中有子部门默认收起才读缓存
		if(subgroupcheckbox == 'checked'){
        	ld('#'+crmPopupobj.divid+' #viewuser_unfoldsubgroup').prop('checked',true);
			ld('#'+crmPopupobj.divid+' #viewuser_unfoldsubgroup').addClass('tb-checkbox-selected');
		}
    }
	//231031 wym XUQIU1002054 查看范围弹框的 是否显示离职成员 根据数据库值显示
	if(this.scopepopupobj.popup_check_inactiveuser=='yes'){
		if(cls_ScopePopup.prop.chuantoumodule){ //wym 231115 BUG0075530 首页-数据简报穿透-取消勾选“显示离职成员” 与首页保持一致 关联需求:XUQIU1002054
			var tmpurlsting = 'index.php?module=Users&action=UsersAjax&file=viewInactiveusers&frommodule='+cls_ScopePopup.prop.chuantoumodule;
		}else if(cls_ScopePopup.prop.reportmodule){ //wym 231221 BUG0077370 自定义报表-筛选负责人查看范围，勾选显示离职成员，没有记住用户上次选择
			var tmpurlsting = 'index.php?module=Users&action=UsersAjax&file=viewInactiveusers&frommodule='+cls_ScopePopup.prop.reportmodule;
		} else{
			var tmpurlsting = 'index.php?module=Users&action=UsersAjax&file=viewInactiveusers&frommodule='+cls_ScopePopup.prop.popup_module;
		}
		ldAjaxNoProgresssync(tmpurlsting,'',function(data){
			if(data.code == 1){
				var displayinactiv = data.result.displayinactiv;
				if(displayinactiv=='yes'){
					ld('#'+crmPopupobj.divid+' #viewuser_disableuser').prop('checked',true);
					ld('#'+crmPopupobj.divid+' #viewuser_disableuser').addClass('tb-checkbox-selected');
				}
			}
		})
	}
if(!empty(this.scopepopupobj.displayinactiv)){
	//XUQIU20240415-03 目标管理，增加“显示离职成员”参数（杨雅媚）wsh 20240918
	if (this.scopepopupobj.displayinactiv == 'yes'){
		ld('#'+crmPopupobj.divid+' #viewuser_disableuser').prop('checked',true);
		ld('#'+crmPopupobj.divid+' #viewuser_disableuser').addClass('tb-checkbox-selected');
	}else{
		ld('#'+crmPopupobj.divid+' #viewuser_disableuser').prop('checked',false);
		ld('#'+crmPopupobj.divid+' #viewuser_disableuser').removeClass('tb-checkbox-selected');
	}
}
    if(!empty(cls_ScopePopup.prop.popup_url)){
        cls_ScopePopup.prop.popup_url = cls_ScopePopup.prop.popup_url+'&subgroupcheckbox='+subgroupcheckbox;
		var urlstring = cls_ScopePopup.prop.popup_url;
	}else{
		var urlstring = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=public&popup_module='+cls_ScopePopup.prop.popup_module+'&popup_inputtype=checkbox&popup_selecttype=user&subgroupcheckbox='+subgroupcheckbox;
	}
    this.viewTree(urlstring);
}

/*居中 可以被回调*/
cls_ScopePopup.prototype.center=function(obj){

}

//显示树形结构
cls_ScopePopup.prototype.viewTree=function(urlstring){
	var popup_selecttype = getSplitString(urlstring,'popup_selecttype');
    if(!empty(popup_selecttype)){
		cls_ScopePopup.popup_selecttype = popup_selecttype;
    }
	var cls_ScopePopups = this;
	var that=this;
	var viewuser_nogroupuser = false;
    if(cls_ScopePopup.popup_selecttype=='user')
		ldAjax("index.php?module=Users&action=UsersAjax&file=Group2UserList",{},function(ajaxdata){
		    cls_ScopePopups.user2grouplist=ajaxdata.result.list;

			//ld('#rptContentLoading').hide();
		    cls_ScopePopups.showhtml(urlstring);

		})
   	else
   		cls_ScopePopups.showhtml(urlstring);
}

//访问后台 生成html
cls_ScopePopup.prototype.showhtml=function(urlstring) {
	var popup_selecttype = getSplitString(urlstring,'popup_selecttype');
    if(!empty(popup_selecttype)){
		cls_ScopePopup.popup_selecttype = popup_selecttype;
    }
	var cls_ScopePopups = this;
	var that=this;
	ldAjax('index.php?'+urlstring,{},function(rest){
		if(empty(rest)) return false;
		if(rest.code == 1) {
			that.listdata = rest.result.listdata
			that.groupuser = rest.result.groupuser
			if(rest.result.popup_inputtype){
				cls_ScopePopup.popup_inputtype = rest.result.popup_inputtype;
			}

			that.choosedtype = '';
			var viewhtml = '';
			viewhtml += '<div id="choosescopecontent" name="choosescopecontent" class="choosescopecontent">' +
				'<div class="choosescope_list">';
			if(that.listdata.length > 1){
				if(window.localStorage && window.localStorage.getItem('choosescope_choosedtype') && window.localStorage.getItem('choosescope_choosedtype')!=''){
					that.choosedtype = window.localStorage.getItem('choosescope_choosedtype');
					var find = 'no';
					for(let i = 0;i<that.listdata.length;i++){
						if(that.choosedtype == that.listdata[i].value){
							find = 'yes';
							break;
						}
					}
					if(find == 'no'){that.choosedtype = that.listdata[0].value;}
				}
				else{
					that.choosedtype = that.listdata[0].value;
				}
				viewhtml += '<div class="choosescope_listtype" id="choosescope_listtype">';
				for(let i = 0;i<that.listdata.length;i++){
					if(that.choosedtype == that.listdata[i].value){
						viewhtml += '<div name="listtype_item" class="listtype_item choosedtype" data-type="'+that.listdata[i].value+'"><span>'+that.listdata[i].label+'</span></div>';
					}
					else{
						viewhtml += '<div name="listtype_item" class="listtype_item" data-type="'+that.listdata[i].value+'"><span>'+that.listdata[i].label+'</span></div>';
					}
				}
				viewhtml += '</div>' +
					'<div class="choosescope_listcontent" style="width: 320px;">';
			}
			else{
				viewhtml += '<div class="choosescope_listcontent">';
				that.choosedtype = that.listdata[0].value;
			}
			if(cls_ScopePopup.popup_selecttype != 'user'){
				ld('#viewuser_disableuser').hide();
				ld('[for=viewuser_disableuser]').hide();
			}
			viewhtml += '<div class="choosescope_searcharea">' +
				'<input id="popup_locationdiv" class="ld-input-inner" style="margin: 0;padding: 0 0 0 32px;" /><b class="ld-icon-search" style=""></b>' +
				'<b name="scope_search_clear" style="position: absolute; right: 0px; top: 0px; cursor: pointer; visibility: visible;display: none;" class="ld-icon-clearsearch"></b></div>' +
				'<div id="choosescope_listcontent_tree" class="choosescope_listcontent_tree">';

			for(let i = 0;i<that.listdata.length;i++){
				if(that.choosedtype == that.listdata[i].value){
					viewhtml += that.showlisthtml(that.listdata[i]);
				}
			}
			viewhtml += '</div>' +
				'</div>' +
				'</div>' +
				'<div class="choosescope_choosed" id="choosescope_choosed_div">' +
				'<div class="choosescope_choosed_head">' +
				'<div class="choosescope_choosed_head_num">'+arrJsPopLabel['isselect']+'（<span id="choosescope_choosed_head_num_value">0</span>）</div>' +
				'<div class="choosescope_choosed_head_delete" id="choosescope_choosed_head_delete">'+arrJsPopLabel['SETEMPTY']+'</div>' +
				'</div>' +
				'<div class="choosescope_choosed_list" id="choosescope_choosed_list">' +
				'</div>' +
				'</div>' +
				'</div>';
			//ld('#'+cls_ScopePopup.popup_divid+'content').html(viewhtml);
			ld('#' + cls_ScopePopup.popup_divid).find(' [name=selectpopup_content]').html(viewhtml);
			//ld('#' + cls_ScopePopup.popup_divid).find(' [name=selectpopup_content]').html(rest.result.content);

			ld('#' + cls_ScopePopup.popup_divid).find('#popup_locationdiv').focus();

			var crmPopupobj = CrmPopup.getPopupObj("last");
			if (empty(crmPopupobj.divid)) {
				var crmPopupobj = CrmPopup.getPopupObj("lastprev");
			}
			crmPopupobj.center();
			ld('#' + cls_ScopePopup.popup_divid).addClass('ui-popup');
			ld('#' + cls_ScopePopup.popup_divid).css('border', '0');
			cls_ScopePopups.center(ld('#' + cls_ScopePopup.popup_divid));

			//左侧类型切换事件
			if(ld('#'+crmPopupobj.divid+' #choosescope_listtype [name=listtype_item]').length > 0){
				ld('#'+crmPopupobj.divid+' #choosescope_listtype [name=listtype_item]').unbind('click').bind('click',function () {
					if(ld(this).hasClass('choosedtype')){
						return false;
					}
					ld('#'+crmPopupobj.divid+' #popup_locationdiv').val('');
					ld('#'+crmPopupobj.divid+' #popup_locationdiv').blur();
					var type = ld(this).data('type');
					if(type == 'user'){
						cls_ScopePopups.currindex = -1;
					}
					ld('#popup_locationdiv').focus();
					for(let i = 0;i<that.listdata.length;i++){
						if(type == that.listdata[i].value){
							window.localStorage.setItem('choosescope_choosedtype',type);
							that.choosedtype = type;
							ld('#'+crmPopupobj.divid+' #choosescope_listtype [name=listtype_item]').removeClass('choosedtype');
							ld(this).addClass('choosedtype');
							ld('#'+crmPopupobj.divid+' #choosescope_listcontent_tree').html(that.showlisthtml(that.listdata[i]));
							break;
						}
					}
					//子部门展开收起  加载后执行展开收起事件
					cls_ScopePopups.scopepopupobj.setEventOpenClose(cls_ScopePopup.popup_divid);
					that.initlistdata();
					cls_ScopePopups.selectGroupByUsers();
					cls_ScopePopups.setUserChecked();


				})
			}

			if (typeof cls_wxOpenDataobj != undefined && typeof cls_wxOpenDataobj != "undefined") {
				//pc企业微信需要绑定
				cls_wxOpenDataobj.bindAllOpenData();
			}

			//子部门展开收起  加载后执行展开收起事件
			cls_ScopePopups.scopepopupobj.setEventOpenClose(cls_ScopePopup.popup_divid);
			that.initlistdata();
			//选择部门后全选下级所有部门和用户
			cls_ScopePopups.selectGroupByUsers();
			//设置默认选中
			cls_ScopePopups.setUserChecked();

			ld('#'+cls_ScopePopup.popup_divid+' [name=scope_search_clear]').unbind('click').bind('click',function(){
				ld('#'+cls_ScopePopup.popup_divid+' #popup_locationdiv').val('');
				ld('#'+cls_ScopePopup.popup_divid+' [name=scope_search_clear]').hide();
				ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree').find('ul.scopetree_items').eq(0).show();
				ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree').find('ul.scope_search_list_items').eq(0).hide();
			});

			cls_ScopePopups.scopepopupobj.setEvent(cls_ScopePopups);//设置用户自定义html绑定事件
			cls_ScopePopups.scopepopupobj.setEventBtnOk();//绑定确认按钮事件
			cls_ScopePopups.scopepopupobj.setEventBtnCancel(cls_ScopePopup.popup_divid);//绑定关闭、取消弹出层事件
			cls_ScopePopups.scopepopupobj.setEventLoad();//加载后执行事件

			DelProgressObjs();
			if (typeof cls_wxOpenDataobj != undefined && typeof cls_wxOpenDataobj != "undefined") {
				//通讯录
				cls_wxOpenDataobj.bindAllOpenData();
			}
		}
    });
}

//生成列表 html
cls_ScopePopup.prototype.showlisthtml=function(datainfo){
	var listhtml = '<ul name="scopenode_items" class="scopetree_items">';
	if(datainfo.value == 'user'){
		if(cls_ScopePopup.popup_inputtype == 'checkbox') {
			listhtml += '<li name="scopenode_item" class="scopetree_item" data-record="searchall">' +
				'<div name="scopetree_node" class="scopetree_node">' +
				'<input type="checkbox" tag="popup_inputtype" name="search_popup_inputtype" class="checkbox-item" data-record="searchall" data-trueid="searchall" id="id_searchall">' +
				'<label for="id_searchall" class="treenode_label">' +
				'<span name="treenode_label">' + arrJsPopLabel['ALLSELECT'] + '</span>' +
				'</label>' +
				'</div>' +
				'</li>';
		}
		ld.each(datainfo.list,function (itemid,iteminfo) {
			var display = '';
			if(iteminfo.status && iteminfo.status == 'Inactive'){
				display = 'none';
			}
			listhtml += '<li name="scopenode_item" class="scopetree_item" style="display: '+display+';" data-record="'+itemid+'"';
			ld.each(iteminfo,function (key,value) {
				if(key != 'children' && typeof value != 'object'){
					if(iskehu001=='yes' && key == 'name'){

					}else{
						listhtml += ' data-'+key+'="'+value+'"';
					}
				}
			})
			listhtml += '>';
			var itemidarr = itemid.split('_');
			var tmp_inputid = itemidarr[0]+'_'+itemidarr[1]+'_'+iteminfo.parentidvalue;
			listhtml += '<div name="scopetree_node" class="scopetree_node">';
			if(cls_ScopePopup.popup_inputtype == 'checkbox'){
				listhtml += '<input tag="popup_inputtype" type="checkbox" name="popup_inputtype" class="checkbox-item" id="id_'+tmp_inputid+'" data-record="'+itemid+'">';
			}
			else{
				listhtml += '<input tag="popup_inputtype" type="radio" id="id_'+tmp_inputid+'" data-record="'+itemid+'">';
			}
			listhtml +=	'<img class="treenode_img user_img" src="'+iteminfo.imagepath+'"/>';
			listhtml += '<label class="treenode_label"><span name="treenode_label">'+iteminfo.name;
			if(iteminfo.status && iteminfo.status == 'Inactive'){
				listhtml += '<span style="color: red;">（'+arrJsPopLabel['Quit']+'）</span>'
			}
			listhtml += '</span></label></div>';
			listhtml += '</li>';
		})
	}
	else{
		listhtml += this.showtreelisthtml(datainfo.group_parent_key,datainfo.list);
	}
	listhtml += '</ul>';
	listhtml += '<ul class="scope_search_list_items"></ul>';
	return listhtml;
}

//树形结构 递归
cls_ScopePopup.prototype.showtreelisthtml=function(itemid,treenode){
	let that = this;
	if(cls_ScopePopup.popup_selecttype == 'user'){
		//BUG20241213-39 ls 241216 	客户详情页“查看合作单位关系”，显示不全
		if(treenode.type == 'user' || treenode.type == 'Contacts' || treenode.type == 'account' || treenode.children){

		}else{
			return '';
		}

	}
	var display = '';
	if(treenode.status == 'Inactive' && treenode.type == 'user'){
		display = 'none';
	}
	var treenodehtml = '<li name="scopenode_item" class="scopetree_item" style="display: '+display+';" data-record="'+itemid+'"';
	if(treenode.type != 'Contacts'){
		ld.each(treenode,function (key,value) {
			if(key != 'children' && typeof value != 'object'){
				if(iskehu001=='yes' && key == 'name'){

				}else{
					treenodehtml += ' data-'+key+'="'+value+'"';
				}
			}
		})
	}
	treenodehtml += '>';
	var itemidarr = itemid.split('_');
	var tmp_inputid = itemidarr[0]+'_'+itemidarr[1]+'_'+treenode.parentidvalue;
	treenodehtml += '<div name="scopetree_node" class="scopetree_node">';
	if(treenode.type != 'Contacts' && treenode.type != 'account'){
		if(cls_ScopePopup.popup_inputtype == 'checkbox'){
			treenodehtml += '<input tag="popup_inputtype" type="checkbox" name="popup_inputtype" class="checkbox-item" id="id_'+tmp_inputid+'" data-record="'+itemid+'">';
		}
		else{
			if(cls_ScopePopup.popup_selecttype == 'user'){
				if(treenode.type == 'user'){
					treenodehtml += '<input tag="popup_inputtype" type="radio" id="id_'+tmp_inputid+'" data-record="'+itemid+'">';
				}
			}
			else{
				treenodehtml += '<input tag="popup_inputtype" type="radio" id="id_'+tmp_inputid+'" data-record="'+itemid+'">';
			}
		}
	}
	if(treenode.children){
		treenodehtml += '<i name="tree_iconshowhide" data-record="'+itemid+'" class="tree_iconshowhide"></i>';
	}
	if(treenode.type == 'user'){
		treenodehtml += '<img class="treenode_img user_img" src="'+treenode.imagepath+'"/>';
	}
	else if(treenode.type == 'Contacts'){

	}
	else{
		if(treenode.parentidvalue && treenode.parentidvalue == -1){
			treenodehtml += '<img class="treenode_img group_img company_img" src="themes/icon/companyicon.png"/>';
		}
		else{
			treenodehtml += '<img class="treenode_img group_img" src="themes/icon/groupshow.png"/>';
		}
	}
	treenodehtml += '<label class="treenode_label"';
	var pageto_record = '';
	if(treenode.type == 'Contacts'){
		pageto_record = itemid.split("_")[1];
		treenodehtml += ' style="cursor:pointer;" onclick="window.open(\'index.php?pageto_action=index&pageto_module=Contacts&SearchScope=&pageto_record='+pageto_record+'\');"';
	}
	else if(treenode.type == 'account'){
		pageto_record = itemid.split("_")[1];
		treenodehtml += ' style="cursor:pointer;" onclick="window.open(\'index.php?pageto_action=index&pageto_module=Accounts&SearchScope=&pageto_record='+pageto_record+'\');"';
	}
	treenodehtml += '><span name="treenode_label">'+treenode.name;
	if(treenode.type == 'user' && treenode.status == 'Inactive'){
		treenodehtml += '<span style="color: red;">（'+arrJsPopLabel['Quit']+'）</span>'
	}
	treenodehtml += '</span></label></div>';
	if(treenode.children){
		treenodehtml += '<ul class="scopetree_items">';
		ld.each(treenode.children,function (key,item) {
			treenodehtml += that.showtreelisthtml(key,item);
		});
		treenodehtml += '</ul>';
	}
	treenodehtml += '</li>';
	return treenodehtml;
}

//初始化列表
cls_ScopePopup.prototype.initlistdata=function (){
	//初始化 各个选项
	ld('#' + cls_ScopePopup.popup_divid + ' #choosescopecontent [name=scopenode_item]').each(function () {
		var liobj = ld(this);
		var record = liobj.data('record');
		var recordarr = record.split('_');
		//处理用户图标

		if ('user' == recordarr[0] || 'contacts' == recordarr[0] || 'account_contacts' == recordarr[0]) {//判断是用户
			var parentfilter = ld(this).data('parentgroup');
			if(parentfilter == undefined){
				return true;
			}
			var parentarr = parentfilter.split('_');
			var parentuserid = parentarr[0].split('::');
			//隐藏停用的用户
			if ('Inactive' == parentarr[2] || 'Inactive' == parentarr[1]) {
				if (ld('#' + cls_ScopePopup.popup_divid + ' #viewuser_disableuser').prop('checked')) {
					liobj.show();
				}
				else{
					liobj.hide();
				}
			}

			//默认选中不可选
			if (cls_ScopePopup.prop.disabled_value == recordarr[1]) {
				liobj.find('input[tag=popup_inputtype]').prop('checked', true);
				liobj.find('input[tag=popup_inputtype]').prop('disabled', 'disabled');
				liobj.find('input[tag=popup_inputtype]').addClass('tb-checkbox-selected');
			}
		}
	});
	if(this.choosedtype == 'group'){
		ld('#' + cls_ScopePopup.popup_divid + ' #viewuser_unfoldsubgroup').show();
		ld('#' + cls_ScopePopup.popup_divid + ' label[for=viewuser_unfoldsubgroup]').show();
		this.unFoldsubGroup('viewuser_unfoldsubgroup');
	}else{
		ld('#' + cls_ScopePopup.popup_divid + ' #viewuser_unfoldsubgroup').hide();
		ld('#' + cls_ScopePopup.popup_divid + ' label[for=viewuser_unfoldsubgroup]').hide();
	}

}

//默认选中
cls_ScopePopup.prototype.setUserChecked=function(){
	var that = this;
	if(!empty(cls_ScopePopup.prop.popup_value) || !empty(cls_ScopePopup.return_obj.return_id)){
		var curr_id = cls_ScopePopup.prop.popup_value;//默认选中值
		if(!empty(cls_ScopePopup.return_obj.return_id)){
			curr_id = cls_ScopePopup.return_obj.return_id;
		}
		var curr_type = cls_ScopePopup.popup_selecttype;//默认选中类型
		if(!empty(cls_ScopePopup.popup_more_selecttype)){
			curr_type = cls_ScopePopup.popup_more_selecttype;
		}
		if(!empty(curr_id)) curr_id = ','+curr_id+',';
		ld('#'+cls_ScopePopup.popup_divid+' #choosescopecontent [name=scopenode_item]').each(function(){
			var record = ld(this).data('record');
			var recordarr = record.split('_');
			if(recordarr[0] == curr_type){
				if(curr_id.indexOf(','+recordarr[1]+',') > -1){
					// Frank: 恢复隐藏部门
					// 父类恢复 子类不恢复
					// 子类恢复 父类恢复
					// 更新“恢复/取消”字段的同时 更新display none的勾选框来判断保存哪些更改
					if(cls_ScopePopup.triggertype=='recover'){
						ld(this).find('label').eq(0).css({'color': '#999'});
						var liobj = ld(this);
						ld(this).find('[name=scopetree_node]').eq(0).append('<a href="javascript:;" style="margin-left: 3px;" id="recover_toggle_'+recordarr[1]+'">恢复</a>');
						ld("#recover_toggle_"+recordarr[1]).unbind('click').on('click', function(){
							var status = ld(this).text();
							if(status=='恢复'){
								ld(this).text('取消');
								ld(this).parent().find('label').first().css({'color': '#000'});
								var dataString = ld(this).parent().parent().data('parentgroup');
								var cleanString = dataString.split('_')[0];
								var numbersArray = cleanString.split('::');
								numbersArray.shift();
								//numbersArray.pop();
								if(numbersArray.length==0){

								}else if(numbersArray.length > 0){
									if (numbersArray.length > 1) {
										numbersArray.reverse();
									}
									for(var i = 0; i<numbersArray.length; i++){
										ld("#recover_toggle_" + numbersArray[i]).text('取消');
										ld("#recover_toggle_" + numbersArray[i]).parent().find('label').first().css({'color': '#000'});
										var tmp_inputid = 'id_'+recordarr[0]+'_'+recordarr[1]+'_'+liobj.data('parentidvalue');
										if(liobj.find('#'+tmp_inputid).length > 0 && !liobj.find('#'+tmp_inputid).prop('checked')){
											liobj.find('#'+tmp_inputid).eq(0).click();
										}
									}
								}
							}else if(status=='取消'){
								ld(this).parent().find('a').text('恢复');
								ld(this).parent().find('label').css({'color': '#999'});
								//ld(this).parent().find('input[tag=popup_inputtype]').prop('checked',false);
								//ld(this).parent().find('input[tag=popup_inputtype]').removeClass('tb-checkbox-selected');
								var tmp_inputid = 'id_'+recordarr[0]+'_'+recordarr[1]+'_'+liobj.data('parentidvalue');
								if(liobj.find('#'+tmp_inputid).length > 0 && liobj.find('#'+tmp_inputid).prop('checked')){
									liobj.find('#'+tmp_inputid).eq(0).click();
								}
							}
						});
					}
					else{
						var tmp_inputid = 'id_'+recordarr[0]+'_'+recordarr[1]+'_'+ld(this).data('parentidvalue');
						if(ld(this).find('#'+tmp_inputid).length > 0 && !ld(this).find('#'+tmp_inputid).prop('checked')){
							if(cls_ScopePopup.popup_inputtype == 'checkbox'){
								ld(this).find('#'+tmp_inputid).eq(0).prop('checked',true);
								ld(this).find('#'+tmp_inputid).eq(0).addClass('tb-checkbox-selected');
							}
							else{
								ld(this).find('#'+tmp_inputid).eq(0).click();
							}
						}
					}
				}
			}
		});
		if(cls_ScopePopup.popup_selecttype == 'user' && cls_ScopePopup.popup_inputtype == 'checkbox'){
			var viewuser_disableuser = ld('#'+cls_ScopePopup.popup_divid+' #viewuser_disableuser').prop('checked');
			var disable = '[data-status=Active]';
			if(viewuser_disableuser){
				disable = '';
			}
			if(that.choosedtype == 'group'){
				ld('#'+cls_ScopePopup.popup_divid+' #choosescopecontent [name=scopenode_item][data-type=group]').each(function () {
					var numtotal = ld(this).find('[name=scopenode_item]'+disable+' input[tag=popup_inputtype][data-record^=user]').length;
					var numcheck = ld(this).find('[name=scopenode_item]'+disable+' input[tag=popup_inputtype][data-record^=user]:checked').length;
					if(numtotal == numcheck){
						ld(this).find('input[tag=popup_inputtype][data-record^=group]').eq(0).prop('checked',true);
						ld(this).find('input[tag=popup_inputtype][data-record^=group]').eq(0).addClass('tb-checkbox-selected');
					}
				});
			}
			else{
				var liobjs = ld('#'+cls_ScopePopup.popup_divid+' #choosescopecontent [name=scopenode_item]'+disable);
				var numtotal = liobjs.find('input[tag=popup_inputtype][data-record^=user]').length;
				var numcheck = liobjs.find('input[tag=popup_inputtype][data-record^=user]:checked').length;
				if(numtotal == numcheck){
					ld('#'+cls_ScopePopup.popup_divid+' #choosescopecontent [name=scopenode_item]').find('input[tag=popup_inputtype][data-record=searchall]').eq(0).prop('checked',true);
					ld('#'+cls_ScopePopup.popup_divid+' #choosescopecontent [name=scopenode_item]').find('input[tag=popup_inputtype][data-record=searchall]').eq(0).addClass('tb-checkbox-selected');
				}
			}
		}

	}
	this.returnObj();
}

//显示、隐藏停用用户
cls_ScopePopup.prototype.inactiveUser=function(viewuser_disableuser){
	if(ld('#'+cls_ScopePopup.popup_divid+' #'+viewuser_disableuser).prop('checked')){
		ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree').find('#id_searchall').prop('checked',false);
		ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree').find('#id_searchall').removeClass('tb-checkbox-selected');
		ld('#'+cls_ScopePopup.popup_divid+' #choosescopecontent [name=scopenode_item]').each(function(){
			var parentfilter = ld(this).data('parentgroup');
			if(parentfilter != undefined){
				var parentarr = parentfilter.split('_');
				if('Inactive' == parentarr[1]){//显示停用的用户
					ld(this).css('display','');
				}
			}
		});
	}else{
		ld('#'+cls_ScopePopup.popup_divid+' #choosescopecontent [name=scopenode_item]').each(function(){//循环所有file图标
			var parentfilter = ld(this).data('parentgroup');
			if(parentfilter != undefined){
				var parentarr = parentfilter.split('_');
				if('Inactive' == parentarr[1]){//隐藏停用的用户
					ld(this).css('display','none');
					if(ld(this).find('input[tag=popup_inputtype]').eq(0).prop('checked') == true){
						ld(this).find('input[tag=popup_inputtype]').eq(0).click();//取消选择
					}
				}
			}
		});
	}
	//获取回传对象值
	this.returnObj();
}

//上下键 聚焦
cls_ScopePopup.prototype.updownkeyfocus=function(index,jqueryselect){
	var treeobj = ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree');
	var liobj = treeobj.find('ul'+jqueryselect).find('li.scopetree_item:visible');
	var treetop = treeobj.offset().top;
	var liobjtop = liobj.eq(index).offset().top;
	var treeheight = treeobj.outerHeight();
	var liobjheight = liobj.eq(index).outerHeight();

	var treescrolltop = treeobj.scrollTop();
	if(liobjtop < treetop){
		treescrolltop = treescrolltop - treetop + liobjtop;
		treeobj.scrollTop(treescrolltop);
	}
	else if((treetop + treeheight - liobjheight) < liobjtop){
		treescrolltop = treescrolltop + liobjtop - (treetop + treeheight - liobjheight);
		treeobj.scrollTop(treescrolltop);
	}
}

//查询
cls_ScopePopup.prototype.searchTextKeyUp=function(popup_locationdiv){
	var that = this;
	ld('#'+popup_locationdiv).attr("autocomplete","off");
	var searchinfo = {};//查询信息
	var curr_idx = -1;var foridx = 0;
	var cls_ScopePopups = this;
	getScriptBackWithURL('include/js/multipingyin.js',null);//加载拼音代码
	//duan 20230920 输入法通过数字键输入时,页面没有触发keyup事件,增加输入法结束输入时,触发keyup事件
	ld('#'+popup_locationdiv).unbind('compositionend').bind('compositionend',function(){ //结束输入
		ld(this).trigger('keyup');
	})
	ld('#'+popup_locationdiv).unbind('keydown').on('keydown',function(event){
		ld(this).val(trim(ld(this).val()));//去掉输入框中的多余空格
		var searchtext = trim(ld(this).val());//获取输入值
		if(event.keyCode == 40 || event.keyCode == 38){
			event.preventDefault();
			//搜索列表上下键
			if(!empty(searchtext)){
				var liobj = ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree').find('ul.scope_search_list_items').find('li[name=scope_search_list_item]:visible');
				if(liobj.length > 0){
					if(event.keyCode == 40){
						if(curr_idx < liobj.length - 1){
							curr_idx++;
							liobj.removeClass('currfocus');
							liobj.eq(curr_idx).addClass('currfocus');
						}
					}
					else{
						if(curr_idx > 0){
							curr_idx--;
							liobj.removeClass('currfocus');
							liobj.eq(curr_idx).addClass('currfocus');
						}
					}
					that.updownkeyfocus(curr_idx,'.scope_search_list_items');
				}
			}
			//用户列表界面 上下键
			else{
				if(that.choosedtype == 'user'){
					var liobj = ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree').find('ul.scopetree_items').find('li[name=scopenode_item]:visible');
					if(liobj.length > 0){
						if(event.keyCode == 40){
							if(that.currindex < liobj.length - 1){
								that.currindex++;
								liobj.removeClass('currfocus');
								liobj.eq(that.currindex).addClass('currfocus');
							}
						}
						else{
							if(that.currindex > 0){
								that.currindex--;
								liobj.removeClass('currfocus');
								liobj.eq(that.currindex).addClass('currfocus');
							}
						}
						that.updownkeyfocus(that.currindex,'.scopetree_items[name="scopenode_items"]');
					}
				}
			}
		}
	});
	ld('#'+popup_locationdiv).unbind('keyup').on('keyup',function(event){
		var e = event || window.event;

		ld(this).val(trim(ld(this).val()));//去掉输入框中的多余空格
		var searchtext = trim(ld(this).val());//获取输入值
		if (e.keyCode == 13 || e.keyCode == 32) {
			if(!empty(searchtext)){
				var liobj = ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree').find('ul.scope_search_list_items').find('li[name=scope_search_list_item]');
				if(liobj.length == 1){
					liobj.find('input[tag=popup_inputtype]').click();
				}
				else if(liobj.length > 1){
					if(curr_idx > -1){
						liobj.eq(curr_idx).find('input[tag=popup_inputtype]').click();
					}
				}
			}
			else{
				if(that.choosedtype == 'user'){
					var liobj = ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree').find('ul[name=scopenode_items]').find('li[name=scopenode_item]');
					if(that.currindex > -1){
						liobj.eq(that.currindex).find('input[tag=popup_inputtype]').click();
					}
				}
			}
		}
		else if(e.keyCode == 40 || e.keyCode == 38){// 向下箭头  向上箭头

		}
		else{
			if(empty(searchtext)){
				ld('#'+cls_ScopePopup.popup_divid+' [name=scope_search_clear]').hide();
				ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree').find('ul.scopetree_items').eq(0).show();
				ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree').find('ul.scope_search_list_items').eq(0).hide();
				return false;
			}

			curr_idx = -1;

			ld('#'+cls_ScopePopup.popup_divid+' [name=scope_search_clear]').show();
			ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree').find('ul.scopetree_items').eq(0).hide();
			ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree').find('ul.scope_search_list_items').eq(0).show();

			var searchtext=searchtext.toLowerCase();
			var viewuser_disable = ld('#'+cls_ScopePopup.popup_divid+' #viewuser_disableuser').prop('checked');
			var userpinyin = '';
			var useridlist = [];
			ld.each(that.groupuser,function(itemid,itemdata){

				if(iskehu001=='yes'){
					userpinyin = makePy(ld('#'+cls_ScopePopup.popup_divid+' #choosescopecontent li.scopetree_item[data-record='+itemid+']').find('.treenode_label').text());
				}else{
					userpinyin = makePy(itemdata.name);
				}
				userpinyin=userpinyin.join("").toLowerCase();

				if(cls_ScopePopup.popup_selecttype=='user'){
					if(itemdata.type == 'user'){
						if(useridlist.indexOf(itemdata.groupid) < 0){
							useridlist.push(itemdata.groupid);
							searchinfo[itemid] = {'data':itemdata,'pinyin':userpinyin,'record':itemid,'checked':ld('#'+cls_ScopePopup.popup_divid+' #choosescopecontent [name=scopenode_item][data-record='+itemid+']').find('input[tag=popup_inputtype]').eq(0).prop('checked')};
						}
					}
				}else{
					searchinfo[itemid] = {'data':itemdata,'pinyin':userpinyin,'record':itemid,'checked':ld('#'+cls_ScopePopup.popup_divid+' #choosescopecontent [name=scopenode_item][data-record='+itemid+']').find('input[tag=popup_inputtype]').eq(0).prop('checked')};
				}

			});
			var searchhtml = '';var searchnum = 0;
			if(iskehu001=='yes'){
				if(cls_ScopePopup.popup_selecttype == 'user')
				{
					EmptyProgressObjs();//清空
					ldAjaxNoProgress("index.php?module=Users&action=UsersAjax&file=searchUserByKehu001&iskehu001="+iskehu001,{'searchvalue':searchtext},function(callbackdata){
						if(callbackdata.result.list.length>0)
						{
							ld.each(searchinfo,function(userid,userobj){
								var userids=userobj.record.split('_');
								var tmpuserid=userids[1];
								if(userids[0]=='user'&&ld.inArray(tmpuserid,callbackdata.result.list)>=0){
									searchnum++;
									searchhtml += '<li name="scope_search_list_item" class="scopetree_item" data-record="'+userid+'">' +
										'<div name="scopetree_node" class="scopetree_node">';
									var record = userid;
									var recordarr = userid.split('_');
									var temp_id = recordarr[0]+'_'+recordarr[1]+'_'+userobj.data.parentidvalue;
									var classname = 'checkbox-item';
									if(cls_ScopePopup.popup_inputtype != 'checkbox'){
										classname = '';
									}
									if(userobj.checked){
										searchhtml += '<input type="'+cls_ScopePopup.popup_inputtype+'" tag="popup_inputtype" name="search_popup_inputtype" class="'+classname+' tb-checkbox-selected" checked data-record="'+userid+'" data-trueid="'+temp_id+'" id="cid_'+temp_id+'">';
									}
									else{
										searchhtml += '<input type="'+cls_ScopePopup.popup_inputtype+'" tag="popup_inputtype" name="search_popup_inputtype" class="'+classname+'" data-record="'+userid+'" data-trueid="'+temp_id+'" id="cid_'+temp_id+'">';
									}
									if(userobj.data.imagepath){
										searchhtml += '<img class="treenode_img" src="'+userobj.data.imagepath+'" style="border-radius: 100%;">';
									}
									else{
										searchhtml += '<img class="treenode_img group_img" src="themes/icon/groupshow.png">';
									}
									searchhtml += '<label for="cid_'+temp_id+'" class="treenode_label">' +
										'<span name="treenode_label">'+userobj.data.name;
									if(userobj.data.status && userobj.data.status == 'Inactive'){
										searchhtml += '<span style="color: red;">（'+arrJsPopLabel['Quit']+'）</span>';
									}
									searchhtml += '</span></label></div></li>';
								}
							});
							if(searchnum > 0){
								if(cls_ScopePopup.popup_inputtype == 'checkbox' && searchnum > 1){
									searchhtml = '<li name="scope_search_list_item" class="scopetree_item" data-record="searchall">' +
										'<div name="scopetree_node" class="scopetree_node">' +
										'<input type="checkbox" tag="popup_inputtype" name="search_popup_inputtype" class="checkbox-item" data-record="searchall" data-trueid="searchall" id="cid_searchall">' +
										'<label for="cid_searchall" class="treenode_label">' +
										'<span name="treenode_label">'+arrJsPopLabel['ALLSELECT']+'</span></label></div></li>'+searchhtml;
								}
							}
							else{
								searchhtml = '<li class="scopetree_item" style="text-align: center;"><div name="scopetree_node" class="scopetree_node"><div class="treenode_label">'+arrJsPopLabel['NODATAFOUND']+'</div></div></li>';
							}
							cls_ScopePopups.searchResultPopup(searchhtml);
						}
					})
				}
			}
			else{
				ld.each(searchinfo,function(userid,userobj){
					//搜索用户时，如果为选择显示停用用户，则允许搜索出停用用户
					if(cls_ScopePopup.popup_selecttype=='user' && !viewuser_disable && userobj.data.status != 'Active'){
						return true;
					}
					if(userobj.data.name.indexOf(searchtext)>= 0 || userobj.pinyin.indexOf(searchtext) >= 0){
						searchnum++;
						searchhtml += '<li name="scope_search_list_item" class="scopetree_item" data-record="'+userid+'">' +
							'<div name="scopetree_node" class="scopetree_node">';
						var record = userid;
						var recordarr = userid.split('_');
						var temp_id = recordarr[0]+'_'+recordarr[1]+'_'+userobj.data.parentidvalue;
						var classname = 'checkbox-item';
						if(cls_ScopePopup.popup_inputtype != 'checkbox'){
							classname = '';
						}
						if(userobj.checked){
							searchhtml += '<input type="'+cls_ScopePopup.popup_inputtype+'" tag="popup_inputtype" name="search_popup_inputtype" class="'+classname+' tb-checkbox-selected" checked data-record="'+userid+'" data-trueid="'+temp_id+'" id="cid_'+temp_id+'">';
						}
						else{
							searchhtml += '<input type="'+cls_ScopePopup.popup_inputtype+'" tag="popup_inputtype" name="search_popup_inputtype" class="'+classname+'" data-record="'+userid+'" data-trueid="'+temp_id+'" id="cid_'+temp_id+'">';
						}
						if(userobj.data.imagepath){
							searchhtml += '<img class="treenode_img" src="'+userobj.data.imagepath+'" style="border-radius: 100%;">';
						}
						else{
							searchhtml += '<img class="treenode_img group_img" src="themes/icon/groupshow.png">';
						}
						searchhtml += '<label for="cid_'+temp_id+'" class="treenode_label">' +
							'<span name="treenode_label">'+userobj.data.name;
						if(userobj.data.status && userobj.data.status == 'Inactive'){
							searchhtml += '<span style="color: red;">（'+arrJsPopLabel['Quit']+'）</span>';
						}
						searchhtml += '</span></label></div></li>';
					}
				});
				if(searchnum > 0){
					if(cls_ScopePopup.popup_inputtype == 'checkbox' && searchnum > 1){
						searchhtml = '<li name="scope_search_list_item" class="scopetree_item" data-record="searchall">' +
							'<div name="scopetree_node" class="scopetree_node">' +
							'<input type="checkbox" tag="popup_inputtype" name="search_popup_inputtype" class="checkbox-item" data-record="searchall" data-trueid="searchall" id="cid_searchall">' +
							'<label for="cid_searchall" class="treenode_label">' +
							'<span name="treenode_label">'+arrJsPopLabel['ALLSELECT']+'</span></label></div></li>'+searchhtml;
					}
				}
				else{
					searchhtml = '<li class="scopetree_item" style="text-align: center;"><div name="scopetree_node" class="scopetree_node"><div class="treenode_label">'+arrJsPopLabel['NODATAFOUND']+'</div></div></li>';
				}
				cls_ScopePopups.searchResultPopup(searchhtml);
			}
		}


	});
	return true;
}

//查询页面显示 以及页面绑定
cls_ScopePopup.prototype.searchResultPopup=function(searchhtml){
	var cls_ScopePopups=this;
	var searchulobj = ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree').find('ul.scope_search_list_items');
	searchulobj.html(searchhtml);

	//绑定点击事件
	var liobjs = searchulobj.find('[name=scope_search_list_item]');
	if(liobjs.length > 0){
		liobjs.find('input[tag=popup_inputtype]').unbind('click').on('click',function(){
			var record = ld(this).data('trueid');
			var checked = ld(this).prop('checked');
			if(checked){
				ld(this).addClass('tb-checkbox-selected');
			}
			else{
				ld(this).removeClass('tb-checkbox-selected');
			}
			if(record == 'searchall'){
				liobjs.find('input[tag=popup_inputtype]').each(function(index,obj){
					if(ld(obj).data('trueid') == 'searchall' || ld(obj).prop('checked') === checked){
						return true;
					}
					ld(obj).prop('checked',checked);
					if(checked){
						ld(obj).addClass('tb-checkbox-selected');
					}
					else{
						ld(obj).removeClass('tb-checkbox-selected');
					}
					ld('#'+cls_ScopePopup.popup_divid+' #id_'+ld(obj).data('trueid')).click();
				});
			}
			else{
				ld('#'+cls_ScopePopup.popup_divid+' #id_'+record).click();
				var numtotal = liobjs.find('input[tag=popup_inputtype]:not([data-trueid="searchall"])').length;
				var numcheck = liobjs.find('input[tag=popup_inputtype]:not([data-trueid="searchall"]):checked').length;
				if(numtotal == numcheck){
					liobjs.find('input[tag=popup_inputtype][data-trueid="searchall"]').prop('checked',true);
					liobjs.find('input[tag=popup_inputtype][data-trueid="searchall"]').addClass('tb-checkbox-selected');
				}
				else{
					liobjs.find('input[tag=popup_inputtype][data-trueid="searchall"]').prop('checked',false);
					liobjs.find('input[tag=popup_inputtype][data-trueid="searchall"]').removeClass('tb-checkbox-selected');
				}
			}
		});
	}
}

//绑定选择事件
cls_ScopePopup.prototype.selectGroupByUsers=function(){


	var cls_ScopePopups = this;
	var that=this;
	ld('#'+cls_ScopePopup.popup_divid+' [name=scopenode_item] input[tag=popup_inputtype]').unbind('click').on('click',function(event){
		event.stopPropagation();
		var record = ld(this).data('record');
		var checked = ld(this).prop('checked');
		if(cls_ScopePopup.popup_inputtype == 'checkbox'){
			if(checked){
				ld(this).addClass('tb-checkbox-selected');
			}else{
				ld(this).removeClass('tb-checkbox-selected');
			}
			//树形结构点击
			if(that.choosedtype == 'group'){

				if(cls_ScopePopup.popup_selecttype == 'profile' || cls_ScopePopup.popup_selecttype == 'level'){
					if(record == 'profile' || record == 'level'){
						var obj = ld('#'+cls_ScopePopup.popup_divid+' [name=scopenode_item][data-record='+record+']');
						var childobjs = obj.find('ul.scopetree_items').eq(0).find('[name=scopenode_item]');
						childobjs.find('input[tag=popup_inputtype]').prop('checked',checked);
						if(checked){
							childobjs.find('input[tag=popup_inputtype]').addClass('tb-checkbox-selected');
						}
						else{
							childobjs.find('input[tag=popup_inputtype]').removeClass('tb-checkbox-selected');
						}
					}
					else{
						var obj = ld('#'+cls_ScopePopup.popup_divid+' [name=scopenode_item][data-record=profile]');
						var childobjsnum = obj.find('ul.scopetree_items').eq(0).find('[name=scopenode_item]').length;
						var checkednum = obj.find('ul.scopetree_items').eq(0).find('[name=scopenode_item]').find('input[tag=popup_inputtype]:checked').length;
						if(childobjsnum == checkednum){
							obj.find('input[tag=popup_inputtype]').eq(0).prop('checked',true);
							obj.find('input[tag=popup_inputtype]').eq(0).addClass('tb-checkbox-selected');
						}
						else{
							obj.find('input[tag=popup_inputtype]').eq(0).prop('checked',false);
							obj.find('input[tag=popup_inputtype]').eq(0).removeClass('tb-checkbox-selected');
						}
					}
				}
				else{
					if(that.groupuser[record]){
						var tmp_groupuser = that.groupuser[record];
						if(tmp_groupuser.type == 'user'){
							ld('#'+cls_ScopePopup.popup_divid+' [name=scopenode_item][data-type='+tmp_groupuser.type+'][data-groupid='+tmp_groupuser.groupid+']').each(function(){
								ld(this).find('input[tag=popup_inputtype]').prop('checked',checked);
								if(checked){
									ld(this).find('input[tag=popup_inputtype]').addClass('tb-checkbox-selected');
								}else{
									ld(this).find('input[tag=popup_inputtype]').removeClass('tb-checkbox-selected');
								}
								//that.changeparentchecked(ld(this).data('parentid'),checked);
							});
						}
						else{
							//下级元素全选中  不过滤离职
							//if(cls_ScopePopup.popup_selecttype != 'group'){
								var obj = ld('#'+cls_ScopePopup.popup_divid+' [name=scopenode_item][data-record='+record+']');
								var childobjs = obj.find('ul.scopetree_items').eq(0).find('[name=scopenode_item][data-type=user]');
								var hadclickid = [];
								childobjs.each(function (index,childobj) {
									if(ld(childobj).find('input[tag=popup_inputtype]').eq(0).prop('checked') === checked){
										return true;
									}
									if(ld(childobj).data('type') == 'user' && hadclickid.indexOf(ld(childobj).data('groupid')) < 0){
										//ld(childobj).find('input[tag=popup_inputtype]').eq(0).click();
										hadclickid.push(ld(childobj).data('groupid'));
										ld('#'+cls_ScopePopup.popup_divid+' [name=scopenode_item][data-type=user][data-groupid='+ld(childobj).data('groupid')+']').each(function(){
											ld(this).find('input[tag=popup_inputtype]').prop('checked',checked);
											if(checked){
												ld(this).find('input[tag=popup_inputtype]').addClass('tb-checkbox-selected');
											}else{
												ld(this).find('input[tag=popup_inputtype]').removeClass('tb-checkbox-selected');
											}
											//that.changeparentchecked(ld(this).data('parentid'),checked);
										});
									}
									else{
										ld(childobj).find('input[tag=popup_inputtype]').eq(0).prop('checked',checked);
										if(checked){
											ld(childobj).find('input[tag=popup_inputtype]').eq(0).addClass('tb-checkbox-selected');
										}
										else{
											ld(childobj).find('input[tag=popup_inputtype]').eq(0).removeClass('tb-checkbox-selected');
										}
									}
								});
							//}

							if(cls_ScopePopup.popup_selecttype == 'user'){
								if(obj.data('parentidvalue') != -1){
									//that.changeparentchecked(obj.data('parentid'),checked);
								}
							}
						}
					}
					if(cls_ScopePopup.popup_selecttype == 'user' && cls_ScopePopup.popup_inputtype == 'checkbox'){
						var viewuser_disableuser = ld('#'+cls_ScopePopup.popup_divid+' #viewuser_disableuser').prop('checked');
						var disable = '[data-status=Active]';
						if(viewuser_disableuser){
							disable = '';
						}
						if(that.choosedtype == 'group'){
							ld('#'+cls_ScopePopup.popup_divid+' #choosescopecontent [name=scopenode_item][data-type=group]').each(function () {
								var numtotal = ld(this).find('[name=scopenode_item]'+disable+' input[tag=popup_inputtype][data-record^=user]').length;
								var numcheck = ld(this).find('[name=scopenode_item]'+disable+' input[tag=popup_inputtype][data-record^=user]:checked').length;
								if(numtotal == numcheck){
									ld(this).find('input[tag=popup_inputtype][data-record^=group]').eq(0).prop('checked',true);
									ld(this).find('input[tag=popup_inputtype][data-record^=group]').eq(0).addClass('tb-checkbox-selected');
								}
								else{
									ld(this).find('input[tag=popup_inputtype][data-record^=group]').eq(0).prop('checked',false);
									ld(this).find('input[tag=popup_inputtype][data-record^=group]').eq(0).removeClass('tb-checkbox-selected');
								}
							});
						}
						else{
							var liobjs = ld('#'+cls_ScopePopup.popup_divid+' #choosescopecontent [name=scopenode_item]'+disable);
							var numtotal = liobjs.find('input[tag=popup_inputtype][data-record^=user]').length;
							var numcheck = liobjs.find('input[tag=popup_inputtype][data-record^=user]:checked').length;
							if(numtotal == numcheck){
								ld('#'+cls_ScopePopup.popup_divid+' #choosescopecontent [name=scopenode_item]').find('input[tag=popup_inputtype][data-record=searchall]').eq(0).prop('checked',true);
								ld('#'+cls_ScopePopup.popup_divid+' #choosescopecontent [name=scopenode_item]').find('input[tag=popup_inputtype][data-record=searchall]').eq(0).addClass('tb-checkbox-selected');
							}
							else{
								ld('#'+cls_ScopePopup.popup_divid+' #choosescopecontent [name=scopenode_item]').find('input[tag=popup_inputtype][data-record=searchall]').eq(0).prop('checked',false);
								ld('#'+cls_ScopePopup.popup_divid+' #choosescopecontent [name=scopenode_item]').find('input[tag=popup_inputtype][data-record=searchall]').eq(0).removeClass('tb-checkbox-selected');
							}
						}
					}
				}
			}
			else{
				if(record == 'searchall'){
					ld('#'+cls_ScopePopup.popup_divid+' [name=scopenode_item] input[tag=popup_inputtype]').each(function (index,inputobj) {
						if(checked){
							ld(inputobj).prop('checked',true);
							ld(inputobj).addClass('tb-checkbox-selected');
						}else{
							ld(inputobj).prop('checked',false);
							ld(inputobj).removeClass('tb-checkbox-selected');
						}
					});
				}
				else{
					var viewuser_disableuser = ld('#'+cls_ScopePopup.popup_divid+' #viewuser_disableuser').prop('checked');
					var disable = '[data-status=Active]';
					if(viewuser_disableuser){
						disable = '';
					}
					var totel = ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree').find('ul.scopetree_items').eq(0).find('[name=scopenode_item]'+disable+' input[tag=popup_inputtype]:not(#id_searchall)').length;
					var checkednum = ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree').find('ul.scopetree_items').eq(0).find('[name=scopenode_item]'+disable+' input[tag=popup_inputtype]:not(#id_searchall):checked').length;
					if(totel == checkednum){
						ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree').find('#id_searchall').prop('checked',true);
						ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree').find('#id_searchall').addClass('tb-checkbox-selected');
					}
					else{
						ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree').find('#id_searchall').prop('checked',false);
						ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree').find('#id_searchall').removeClass('tb-checkbox-selected');
					}
				}
			}
		}
		else{
			ld('#'+cls_ScopePopup.popup_divid+' [name=scopenode_item] input[tag=popup_inputtype]').prop('checked',false);
			if(that.groupuser[record]){
				var tmp_groupuser = that.groupuser[record];
				if(tmp_groupuser.type == 'user'){
					ld('#'+cls_ScopePopup.popup_divid+' [name=scopenode_item][data-type='+tmp_groupuser.type+'][data-groupid='+tmp_groupuser.groupid+']').each(function(){
						ld(this).find('input[tag=popup_inputtype]').prop('checked',checked);
					});
				}
			}
		}

		//获取回传对象值
		cls_ScopePopups.returnObj();
		//用户选择后的执行事件，方便其他地方选择用户时做一些特殊处理
		cls_ScopePopups.scopepopupobj.setEventSelGroupByUsers();
		return ;
	});
	ld('#'+cls_ScopePopup.popup_divid+' [name=scopenode_item]').off('click').on('click',function () {
		event.stopPropagation();
		var tmp_record = ld(this).data('record');
		var inputobj = ld(this).find('input[tag=popup_inputtype][data-record='+tmp_record+']');
		if(inputobj.length > 0){
			inputobj.click();
		}
	})
}

//递归修改父级的选中状态
cls_ScopePopup.prototype.changeparentchecked=function(parentid,checked){
	if(parentid == undefined || parentid == 'undefined'){
		return false;
	}
	var parentobj = ld('#'+cls_ScopePopup.popup_divid+' [name=scopenode_item][data-record='+parentid+']');

	if(parentobj.length > 0){
		if(checked){
			var viewuser_disableuser = ld('#'+cls_ScopePopup.popup_divid+' #viewuser_disableuser').prop('checked');
			var disable = '[data-status=Active]';
			if(viewuser_disableuser){
				disable = '';
			}
			var totel = parentobj.find('ul.scopetree_items').eq(0).find('[name=scopenode_item]'+disable+' input[tag=popup_inputtype]').length;
			var checkednum = parentobj.find('ul.scopetree_items').eq(0).find('[name=scopenode_item]'+disable+' input[tag=popup_inputtype]:checked').length;
			if(totel == checkednum){
				parentobj.find('input[tag=popup_inputtype]').eq(0).prop('checked',checked);
				parentobj.find('input[tag=popup_inputtype]').eq(0).addClass('tb-checkbox-selected');
				if(parentobj.data('parentidvalue') != -1){
					this.changeparentchecked(parentobj.data('parentid'),checked);
				}

			}
		}
		else{
			if(parentobj.find('input[tag=popup_inputtype]').eq(0).prop('checked')){
				parentobj.find('input[tag=popup_inputtype]').eq(0).prop('checked',checked);
				parentobj.find('input[tag=popup_inputtype]').eq(0).removeClass('tb-checkbox-selected');
				if(parentobj.data('parentidvalue') != -1){
					this.changeparentchecked(parentobj.data('parentid'),checked);
				}
			}
		}
	}
}

//回传对象：return_id选择的id,return_name选择的对应label,return_type选择类型
cls_ScopePopup.prototype.returnObj=function() {

	var return_array = {};
	var return_id = '', return_name = '';
	var that = this;
	var curr_popup_selecttype = cls_ScopePopup.popup_selecttype;//默认选中类型
	if (cls_ScopePopup.popup_selecttype == 'user' && that.user2grouplist != undefined){
		ld('#' + cls_ScopePopup.popup_divid + ' [name=scopenode_item]').each(function () {//循环所有User用户
			var liobj = ld(this);
			var record = ld(this).data('record');
			var recordarr = record.split('_');
			var inputid = recordarr[0]+'_'+recordarr[1]+'_'+ld(this).data('parentidvalue');
			if (liobj.css('display') == 'none') {//跳过当前循环
				return true;
			}
			var tmprecord = liobj.data("record");
			if (tmprecord == undefined) {
				return true;
			}
			var recordarr = tmprecord.split('_');
			if (recordarr[0] == 'user') {
				var tmpgroup_arr = that.user2grouplist[recordarr[1] + 'aa'];
				if (tmpgroup_arr != undefined){
					ld.each(tmpgroup_arr, function (tmpindex, tmpgroupid) {//循环所有User用户
						//对应id应为id_label_user_+userid+groupid
						var htmlid = "id_user_" + recordarr[1] + "_" + tmpgroupid;
						if (liobj.find("#" + htmlid).length > 0) {
							if (liobj.find("#" + htmlid).eq(0).prop('checked')) {
								if (recordarr[0] == cls_ScopePopup.popup_selecttype && recordarr[1] != undefined) {
									return_array[recordarr[1]] = {'name':liobj.find('label [name=treenode_label]').html(),'namelabel':liobj.find('label [name=treenode_label]').text(),'imagepath':liobj.data('imagepath'),'inputid':inputid};//kehu001(必须用html)
								}
							}
							return false;
						}
					});
				}
				else{
					if(liobj.find('input[tag=popup_inputtype]').eq(0).prop('checked')){
						var recordarr = ld(this).data('record').split('_');
						if(recordarr[0] == cls_ScopePopup.popup_selecttype && recordarr[1] != undefined){
							return_array[recordarr[1]] = {'name':liobj.find('label [name=treenode_label]').html(),'namelabel':liobj.find('label [name=treenode_label]').text(),'imagepath':liobj.data('imagepath'),'inputid':inputid};//kehu001(必须用html)
						}
					}
				}
			}
		});
	}
	else
	{
		ld('#'+cls_ScopePopup.popup_divid+'  [name=scopenode_item]').each(function(){//循环所有User用户
			var liobj = ld(this);
			var record = ld(this).data('record');
			var recordarr = record.split('_');
			var inputid = recordarr[0]+'_'+recordarr[1]+'_'+ld(this).data('parentidvalue');
			if(ld(this).css('display') == 'none'){
				return true;//跳过当前循环
			}
			if(ld(this).find('input[tag=popup_inputtype]').eq(0).prop('checked')){
				var recordarr = ld(this).data('record').split('_');
				if(recordarr[0] == cls_ScopePopup.popup_selecttype && recordarr[1] != undefined){
					return_array[recordarr[1]] = {'name':liobj.find('label [name=treenode_label]').html(),'namelabel':liobj.find('label [name=treenode_label]').text(),'imagepath':'themes/icon/groupshow.png','inputid':inputid};//kehu001(必须用html)
				}
			}
		});
	}
	var choosednum = 0;
	ld.each(return_array,function(id,data){
		choosednum++;
		if(!empty(return_id)) return_id += ',' + id;
		else return_id = id;
		if(!empty(return_name)) return_name += cls_ScopePopup.splice_symbol + data.name;
		else return_name = data.name;
	});

	ld('#'+cls_ScopePopup.popup_divid+' #choosescope_choosed_head_num_value').html(choosednum);
	that.showreturnhtml(return_array);
	//XUQIU20240415-03 目标管理，增加“显示离职成员”参数（杨雅媚）wsh 20240918
	if (ld('#'+cls_ScopePopup.popup_divid+' #viewuser_disableuser').prop('checked')){
		var return_displayinactiv = 'yes';
	}else {
		var return_displayinactiv = 'no';
	}
	var returnobj = {'return_id':return_id,'return_name':return_name,'return_array':return_array,'return_type':cls_ScopePopup.popup_selecttype,'return_displayinactiv':return_displayinactiv};
	cls_ScopePopup.prop.popup_inputclick(returnobj);
}

//内容显示 以及事件绑定
cls_ScopePopup.prototype.showreturnhtml=function(return_array){
	var that = this;
	var returnhtml ='<ul class="chooseditems">';
	ld.each(return_array,function (id,data) {
		if(iskehu001 == 'yes'){
			returnhtml += '<li class="chooseditem" name="chooseditem">';
		}
		else{
			returnhtml += '<li class="chooseditem tip-items-list" name="chooseditem" data-tip="'+data.namelabel+'" data-direction="top" data-type="position" onmouseenter="tooltip.bind(this)">';
		}
		if(cls_ScopePopup.popup_selecttype == 'user'){
			returnhtml += '<img class="chooseditem_img" src="'+data.imagepath+'"/>';
		}
		returnhtml += '<span class="chooseditem_label">'+data.name+'</span>';
		returnhtml += '<b name="chooseditem_delicon" class="chooseditem_delicon" data-trueid="'+data.inputid+'"></b>' +
			'</li>';
	});
	returnhtml += '</ul>';

	ld('#'+cls_ScopePopup.popup_divid+' #choosescope_choosed_list').html(returnhtml);

	ld('#'+cls_ScopePopup.popup_divid+' #choosescope_choosed_list [name=chooseditem_delicon]').unbind('click').on('click',function(){
		if(cls_ScopePopup.popup_inputtype == 'radio'){
			ld('#'+cls_ScopePopup.popup_divid+' #id_'+ld(this).data('trueid')).prop('checked',false);
			ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree').find('input[tag=popup_inputtype]').removeClass('tb-checkbox-selected');
			that.returnObj();
		}
		else{
			ld('#'+cls_ScopePopup.popup_divid+' #id_'+ld(this).data('trueid')).click();
		}
	});

	ld('#'+cls_ScopePopup.popup_divid+' #choosescope_choosed_head_delete').unbind('click').on('click',function () {
		ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree').find('input[tag=popup_inputtype]').prop('checked',false);
		ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree').find('input[tag=popup_inputtype]').removeClass('tb-checkbox-selected');
		that.returnObj();
	});

}

//查询选择:进入焦点时触发
cls_ScopePopup.prototype.searchTextFocus=function(searchtext_id,searchtext_value){

	ld('#'+searchtext_id).val(trim(ld('#'+searchtext_id).val()));
	if(ld('#'+searchtext_id).val() == searchtext_value){
		ld('#'+searchtext_id).val('');
		// ld('#'+searchtext_id).css('color','#000');//建议使用placeholder
	}
}

//查询选择:失去焦点时触发
cls_ScopePopup.prototype.searchTextBlur=function(searchtext_id,searchtext_value){
	ld('#'+searchtext_id).val(trim(ld('#'+searchtext_id).val()));
	if(empty(ld('#'+searchtext_id).val())){
		ld('#'+searchtext_id).val(searchtext_value);
		// ld('#'+searchtext_id).css('color','#999');//建议使用placeholder
	}
}

//子部门默认收起
cls_ScopePopup.prototype.unFoldsubGroup = function(viewuser_unfoldsubgroup){
	var obj = ld('#'+viewuser_unfoldsubgroup);
	var checked = obj.prop('checked');
	setsubGroupCheckbox(checked);
	if(checked){
		obj.addClass('tb-checkbox-selected');
		var childrenonjs = ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree').find('[name=scopenode_item][data-parentidvalue="-1"] ul.scopetree_items').eq(0).children();
		childrenonjs.each(function (index,nodeobj) {
			var iconobj = ld(nodeobj).find('[name=scopetree_node]').eq(0).find('[name=tree_iconshowhide]')
			if(iconobj.length > 0 && !iconobj.hasClass('icon-hide-tip')){
				iconobj.click();
			}
		});
	}else{
		obj.removeClass('tb-checkbox-selected');
		var treeobj = ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree');
		treeobj.find('[name=tree_iconshowhide]').removeClass('icon-hide-tip');
		treeobj.find('.treenode_img.group_img:not(.company_img)').attr('src','themes/icon/groupshow.png');
		treeobj.find('[name=scopenode_items]').find('ul.scopetree_items').show();
	}
}

//设置子部门CheckBox暂存
function setsubGroupCheckbox(checked){
	var current_userid = CURRENT_USER_ID;
	var viewname_unFoldcheckbox = 'viewname_unFoldcheckbox';
	var key = current_userid+'_'+viewname_unFoldcheckbox;//key:(id)_viewname_unFoldcheckbox
	if(checked){
		localStorage.setItem(key,'checked');
	}
	else{
		localStorage.setItem(key,'unchecked');
	}
}

//获取子部门CheckBox暂存
function getsubGroupCheckbox(){
	var current_userid = CURRENT_USER_ID;
	var viewname_unFoldcheckbox = 'viewname_unFoldcheckbox';
	var key = current_userid+'_'+viewname_unFoldcheckbox;//key:(id)_viewname_unFoldcheckbox
	var unFoldcheckbox_value = localStorage.getItem(key);
	if(unFoldcheckbox_value && unFoldcheckbox_value!=''){
		return unFoldcheckbox_value;
	}
	else{
		localStorage.setItem(key,'unchecked')
		getsubGroupCheckbox();
	}
}





//显示、隐藏无部门用户
cls_ScopePopup.prototype.noGroupUser=function(viewuser_nogroupuser){
	if(ld('#'+viewuser_nogroupuser).prop('checked')){
    	ld('#'+cls_ScopePopup.popup_divid+' .filetree span.user').each(function(){//循环所有file图标
    		var parentfilter = ld(this).attr('parent');
    		var parentarr = parentfilter.split('_');
			var parentuserid = parentarr[0].split('::');
			var viewuser_disable = ld('#viewuser_disableuser').prop('checked');
			if(viewuser_disable == true){
				ld(this).parent().css('display','');
			}else{
				if('nogroup' == parentarr[1]){//显示无部门的用户
					if(parentarr[2]=='Inactive'){
						ld(this).parent().css('display','none');
					}else{
						ld(this).parent().css('display','');
					}
				}
			}
			var curr_id = cls_ScopePopup.prop.popup_value;//默认选中值
			if(!empty(curr_id)){
				var curr_id_array = curr_id.split(',');
				if(ld.inArray(parentuserid[1],curr_id_array) > 0){
					ld(this).find('input[type=checkbox]').prop('checked',true);
				}
			}
    	});
	}else{
		ld('#'+cls_ScopePopup.popup_divid+' .filetree span.user').each(function(){//循环所有file图标
			var parentfilter = ld(this).attr('parent');
			var parentarr = parentfilter.split('_');
			if('nogroup' == parentarr[1]){//隐藏无部门的用户
				ld(this).parent().css('display','none');
				ld(this).find('input[type=checkbox]').prop('checked',false);//取消选择
			}
		});
	}
	//获取回传对象值
    this.returnObj();
}
cls_ScopePopup.prototype.hideAccountUser = function(viewaccount_contacts){
	var contactobj = ld('#'+cls_ScopePopup.popup_divid+' #choosescope_listcontent_tree [name=scopenode_item][data-record^=contacts_]');
	var viewaccount_contactsobj = ld('#'+cls_ScopePopup.popup_divid+' #'+viewaccount_contacts);
	if(viewaccount_contactsobj.prop('checked')){
		viewaccount_contactsobj.addClass('tb-checkbox-selected');
		contactobj.show();
	}
	else{
		viewaccount_contactsobj.removeClass('tb-checkbox-selected');
		contactobj.hide();
	}
}

function recover_toggle(obj){
    var status = ld(obj).find("a").text();
    if(status=='恢复'){
        ld(obj).find("a").text('取消');
    }else if(status=='取消'){
        ld(obj).find("a").text('恢复');
    }
}