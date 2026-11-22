var ScopePopupObj = function(methodObj){
    this.popup_caption_value = '';
	this.popup_check_inactiveuser = 'yes';	//默认显示 选择停用用户选项
	this.popup_check_nogroupuser = 'yes';	//默认显示 是否显示无部门用户选项
	this.checkSelectNum = 0;	//选项数
    this.rRowNum = 1;    //选择条数，目前仅用于共享 diony 20210430
    var that=this;
	if(!empty(methodObj)){
		if(!empty(methodObj.popup_check_inactiveuser)){
			this.popup_check_inactiveuser = methodObj.popup_check_inactiveuser;
		}
		if(!empty(methodObj.popup_check_nogroupuser)){
			this.popup_check_nogroupuser = methodObj.popup_check_nogroupuser;
		}
        if(!empty(methodObj.rRowNum)){
            this.rRowNum = methodObj.rRowNum;
        }
        if(!empty(methodObj.functiontype)){
            this.functiontype = methodObj.functiontype;
        }
	}
	if(this.popup_check_inactiveuser == 'yes')this.checkSelectNum++;
	if(this.popup_check_nogroupuser == 'yes')this.checkSelectNum++;
	//弹出层标题
	this.popup_caption_html = '<div class="E_pop_tit" name="popup_title">'+
                                '<strong class="E_ptita" id="titlename">##title##</strong>'+
                                '<button class="E_ptitc" value="'+arrJsPopLabel['LBL_CLOSE']+'" title="'+arrJsPopLabel['LBL_CLOSE']+'"></button>'+
						      '</div>';
	//查询框内容
	this.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];//默认为查询用户
    //弹出层查询框下拉div
    if(this.rRowNum > 1){
        //zkt 20221010 BUG0057324首字母查询时，有一部分选不到
        this.popup_searchTextDiv = '<div id=\'popup_search_div\' style=\'left:72px;display: block;position: absolute;top: 32px;\'><div class=\'view-search\' style=\'max-height: 325px;overflow: auto;\'></div></div>';
    }
    else{
        this.popup_searchTextDiv = '<div id=\'popup_search_div\' style=\'left:72px;display: block;position: absolute;top: 32px;\'><div class=\'view-search\' style=\'max-height: 325px;overflow: auto;\'></div></div>';
    }

	this.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+this.popup_searchvalue+'\'>';

	if(this.checkSelectNum > 0){
		//当只有一个选项时，则与查询框并行显示
		if(this.checkSelectNum > 1){
			//this.popup_header += '</p><p id="selectUserCheck" style="margin-top:10px;">';
		}
		if(this.popup_check_inactiveuser == 'yes'){
			this.popup_header += '<input type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label>'+'<input id=\'viewuser_unfoldsubgroup\' type="checkbox" class="marL10"><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label>';
		}
		if(this.popup_check_nogroupuser == 'yes'){
			// this.popup_header += '<input type="checkbox" id=\'viewuser_nogroupuser\'><label for=\'viewuser_nogroupuser\'>'+arrJsPopLabel['SHOWNOGROUPUSER']+'</label>';
		}
	}
	this.popup_header += '</div>';

	//弹出层底部
	this.popup_footer = '<div class="E_pbtn"><input class="E_pbtnok ld-button ld-button-primary" value="'+arrJsPopLabel['CONFIRME']+'" type="button">'+'<input class="E_pbtncancel ld-button ld-button-cancel" value="'+arrJsPopLabel['CANCEL']+'" type="button"></div>';
    var ScopePopupObjs = this;
    this.setEvent=function(cls_ScopePopup){
        // 使用placeholder
        //查询选择:
        // var popup_searchvalue = this.popup_searchvalue;
        // ld('#popup_locationdiv').unbind('focus').on('focus',function(){
        //     cls_ScopePopup.searchTextFocus('popup_locationdiv',popup_searchvalue);
        // });
        //查询选择:失去焦点时触发
        // ld('#popup_locationdiv').unbind('blur').on('blur',function(){
        //     cls_ScopePopup.searchTextBlur('popup_locationdiv',popup_searchvalue);
        // });
        cls_ScopePopup.searchTextKeyUp('popup_locationdiv');
        //显示、隐藏停用用户
        ld('#viewuser_disableuser').unbind('click').on('click',function(){
            if(ld(this).prop('checked')){
                ld(this).addClass('tb-checkbox-selected');
                window.localStorage.setItem('viewuser_disableuser','yes');
            }
            else{
                ld(this).removeClass('tb-checkbox-selected');
                window.localStorage.setItem('viewuser_disableuser','no');
            }
            cls_ScopePopup.inactiveUser('viewuser_disableuser');
        });
        //显示、隐藏无部门用户
        ld('#viewuser_nogroupuser').unbind('click').on('click',function(){
            cls_ScopePopup.noGroupUser('viewuser_nogroupuser');
        });
		//显示、隐藏联系人
        ld('#viewaccount_contacts').unbind('click').on('click',function(){
            cls_ScopePopup.hideAccountUser('viewaccount_contacts');
        });
        //子部门默认收起
        ld('#viewuser_unfoldsubgroup').unbind('click').on('click',function(){
            cls_ScopePopup.unFoldsubGroup('viewuser_unfoldsubgroup');
        })
    }
    //editor:gyqX160803 Bug:0023880 Exp:新增方法，重写查询框内容
    this.get_popup_header = function(){
        this.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+this.popup_searchvalue+'\'></div><div id="selectUserCheck" class="select-input"><input type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label><input id=\'viewuser_unfoldsubgroup\' type="checkbox" class="marL10"><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label></div>';
		return this.popup_header;
    }
    //确认按钮事件
    this.setEventBtnOk=function(){}
    //关闭、取消按钮事件
    this.setEventBtnCancel=function(divid){
        
    }
	//选择部门、用户事件
	this.setEventSelGroupByUsers=function(){}
    //弹出层加载后的执行方法
    this.setEventLoad=function(){}
    //更改弹出层中间内容
    this.setEventContent=function(urlstring){
        cls_ScopePopup.viewTree();
    }
    //加载后执行展开收起事件
    this.setEventOpenClose=function(divid){
		//chj 2021/6/23 46518: （https://81mis.com/kfbcrm [^]）客户问题（梁文乐），成员管理，选中用户点击【部门设置】，点击取消或者确认后，在点击别的部门没反应（需要补丁）
        ld("#"+divid+" [name=tree_iconshowhide]").unbind("click").on("click",function(event){
            event.stopPropagation();
            if (ld(this).hasClass('icon-hide-tip')){
                ld(this).removeClass('icon-hide-tip');
                ld("#"+divid+" li[name=scopenode_item][data-record="+ld(this).data('record')+"]").find('ul.scopetree_items').eq(0).show();
                if(ld("#"+divid+" li[name=scopenode_item][data-record="+ld(this).data('record')+"]").data('parentidvalue') != -1){
                    ld("#"+divid+" li[name=scopenode_item][data-record="+ld(this).data('record')+"]").find('[name=scopetree_node]').eq(0).find('img.treenode_img').attr('src','themes/icon/groupshow.png');
                }
            }
            else{
                ld("#"+divid+" li[name=scopenode_item][data-record="+ld(this).data('record')+"]").find('[name=tree_iconshowhide]').addClass('icon-hide-tip');
                ld("#"+divid+" li[name=scopenode_item][data-record="+ld(this).data('record')+"]").find('ul.scopetree_items').hide();
                if(ld("#"+divid+" li[name=scopenode_item][data-record="+ld(this).data('record')+"]").data('parentidvalue') != -1){
                    ld("#"+divid+" li[name=scopenode_item][data-record="+ld(this).data('record')+"]").find('[name=scopetree_node]').eq(0).find('img.treenode_img').attr('src','themes/icon/grouphide.png');
                }
                ld("#"+divid+" li[name=scopenode_item][data-record="+ld(this).data('record')+"]").find('[name=scopenode_item]').each(function () {
                    if(ld(this).data('type') == 'group'){
                        ld(this).find('[name=scopetree_node]').eq(0).find('img.treenode_img').attr('src','themes/icon/grouphide.png');
                    }
                });
            }
        });
        if(cls_ScopePopup.popup_inputtype == 'radio'){
            ld("#"+divid+" [name=tree_iconshowhide]").parent().unbind("click").on("click",function(event){
                ld(this).find('[name=tree_iconshowhide]').click();
            });
        }
    }
    this.setInactiveNoShow=function(obj)
    {
        //CRM首页界面，“查看范围-高级”弹出层中，默认勾选显示离职人员
        ld(obj).parent().css('display','none');
    }
};