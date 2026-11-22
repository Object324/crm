/*
*edit:chj
*2021/12/28
*树结构设置
*/
function cls_ModuleTree(module){
	this.module = module;
	var that = this;
    
	
	//显示树结构设置
	this.show=function(){
		var urlstring = 'index.php?module='+that.module+'&action='+that.module+'Ajax&file=ModuleTree';
		ldAjax(urlstring,{},function(data){
			DelProgressObjs();
			if(data.code == 1){
				var crmPopupobj=CrmPopup.load("","","","720",that.module,"","","","");
				crmPopupobj.prevshow();
				crmPopupobj.setParams(data.result.title,that.save,"","600",that.module,"",data.result.oktext,"",data.result.canceltext);
				crmPopupobj.refresh='yes'
                CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
				that.create_tree_field_bind();
				that.search_rowid();
				// ljj 20230904 BUG0072070 kfbcrm-弹出层的× title改为tip
				tooltip(".tip-items-pop", {transition: true, time: 200});
			}
		})
	}
	
	//树结构设置页面按钮绑定
	this.create_tree_field_bind = function(){
		//树结构分组字段
		var popupobj=CrmPopup.getPopupObj("last");
		ld("#"+popupobj.divid+" [name=tree_fieldname]").unbind('change').on('change',function(){
			var fieldname = ld(this).val()
			var urlstring = 'index.php?module='+that.module+'&action='+that.module+'Ajax&file=ModuleTree&getFieldForPickListDependency=yes&fieldname='+fieldname;
			ldAjax(urlstring,{},function(data){
				if(data.code == 1){
					if(data.result == ''){
						ld("#"+popupobj.divid+" [name=div_show_tree_depency]").hide();
					}else{
						var table_html = '';
						ld("#"+popupobj.divid+" [name=tree_table]").find("tr:not(:first)").remove();
						var i = 1;
						ld.each(data.result, function (fieldname, fieldlabel) {
							var _disabled = '';
							if(i == 1){
								var _disabled = 'disabled="" checked=""';
                                table_html += '<tr class="lvtColData"><td align="left">'+fieldlabel+'</td><td align="center"><input type="checkbox" rowid="'+i+'" name="is_tree_field_'+i+'" '+_disabled+' value="'+fieldname+'"></td><td style="text-align: center;"></td></tr>';
							}else{
							     table_html += '<tr class="lvtColData"><td align="left">'+fieldlabel+'</td><td align="center"><input type="checkbox" rowid="'+i+'" name="is_tree_field_'+i+'" '+_disabled+' value="'+fieldname+'"></td><td style="text-align: center;"><a class="cursorPointer" style="display:none" name="set_field_'+i+'" rowid="'+i+'">'+arrJsPopLabel['SetCascadingOptions']+'</a></td></tr>';
                             }
							i++;
						});
						ld("#"+popupobj.divid+" [name=tree_table]").find("tr:eq(0)").after(table_html);
						
						ld("#"+popupobj.divid+" [name=div_show_tree_depency]").show();

					}
					that.created_tree_depency_div();
                    that.search_rowid();
					DelProgressObjs();
					popupobj.setScrollDivMaxHeight();
					popupobj.center();
				}
			})
		});
		that.created_tree_depency_div();
        that.search_rowid();
        //设置按钮跳转值页面设置界面
        if(ld("#"+popupobj.divid+" [name=tree_openModuleSettings]")!=undefined&&ld("#"+popupobj.divid+" [name=tree_openModuleSettings]").length>0){
            ld("#"+popupobj.divid+" [name=tree_openModuleSettings]").unbind('click').on('click',function(){
                window.open("index.php?pageto_module=Settings&pageto_action=SettingLeftRight&pageto_menufile=ModuleSettings&formodule="+that.module);
            })
        }
            
	}
	
	//树结构分类 - 级联字段checlbox按钮点击事件和“设置级联选项”按钮绑定事件
	this.created_tree_depency_div = function(){
		var popupobj=CrmPopup.getPopupObj("last");
		if(ld("#"+popupobj.divid+" [name=div_show_tree_depency]").css('display') == 'block'){
			var table_tr =  ld("#"+popupobj.divid+" [name=tree_table]").find("tr").length;
			for(var i = 2; i <= table_tr - 1; i++){
				var rowid = i;
				ld("#"+popupobj.divid+" [name=is_tree_field_"+rowid+"]").unbind('click').on('click',function(){
					var cur_rowid = ld(this).attr('rowid');
					var cur_field_chk = ld(this).is(":checked");
					if(cur_rowid > 2){
						for(var j= 2; j < cur_rowid; j++){
							if(cur_field_chk){
								ld("#"+popupobj.divid+" [name=is_tree_field_"+j+"]").prop("checked",true);
								ld("#"+popupobj.divid+" [name=is_tree_field_"+j+"]").prop("disabled","disabled");
                                ld("#"+popupobj.divid+" [name=set_field_"+j+"]").show();
							}else{
								var last_rowid = cur_rowid - 1;
								ld("#"+popupobj.divid+" [name=is_tree_field_"+last_rowid+"]").prop("disabled",false);
                                ld("#"+popupobj.divid+" [name=set_field_"+cur_rowid+"]").hide();
							}
						}
                        if(cur_field_chk){
                            ld("#"+popupobj.divid+" [name=set_field_"+cur_rowid+"]").show();
                        }else{
                            ld("#"+popupobj.divid+" [name=set_field_"+cur_rowid+"]").hide();
                        }
					}
                    if(cur_rowid == 2){
                        if(cur_field_chk){
                            ld("#"+popupobj.divid+" [name=set_field_"+cur_rowid+"]").show();
                        }else{
                            ld("#"+popupobj.divid+" [name=set_field_"+cur_rowid+"]").hide();
                        }
                    }
				})
				
			}
		}
	}
    

    //定位表格中的rowid找到value值添加到设置级联选项函数中
    this.search_rowid = function(){
        var popupobj=CrmPopup.getPopupObj("last");
        if(ld("#"+popupobj.divid+" [name=div_show_tree_depency]").css('display') == 'block'){
            var table_tr =  ld("#"+popupobj.divid+" [name=tree_table]").find("tr").length;
           	for(var i = 2; i <= table_tr-1; i++){
   	            var rowid = i;
                ld("#"+popupobj.divid+" [name=set_field_"+rowid+"]").unbind('click').on('click',function(){
                    var cur_rowid = ld(this).attr('rowid');
                    var targetfield = ld("#"+popupobj.divid+" [name=is_tree_field_"+cur_rowid+"]").val();
                    var pre_cur_rowid = cur_rowid-1;
                    var sourcefield = ld("#"+popupobj.divid+" [name=is_tree_field_"+pre_cur_rowid+"]").val();
                    DepencyEditFirst(that.module,sourcefield,targetfield);
                })
            }
        }
    }

	//保存
	this.save = function(){
		var popupobj=CrmPopup.getPopupObj("last");
		var is_module_tree = ld("#"+popupobj.divid+" [name=is_module_tree]").is(":checked");
		var tree_fieldname = ld("#"+popupobj.divid+" [name=tree_fieldname]").val();
        //zkt 20230105 BUG0060517kfbcrm   当表单中没有下拉框字段时---打开树结构设置---再关闭树结构----后面再打开树结构设置时，会默认勾选启用，实际应该不勾选
        if(ld("#"+popupobj.divid+" [name=tree_fieldname]").get(0).length == 0){
            tree_fieldname = '';
        }
		var urlstring = 'index.php?module='+that.module+'&action='+that.module+'Ajax&file=ModuleTree&save=yes&is_module_tree='+is_module_tree+"&tree_fieldname="+tree_fieldname;
		var tree_field_arr = [];
		if(ld("#"+popupobj.divid+" [name=div_show_tree_depency]").css('display') == 'block'){
			var table_tr =  ld("#"+popupobj.divid+" [name=tree_table]").find("tr").length;
			for(var i = 2; i <= table_tr - 1; i++){
				var rowid = i;
				var is_tree_field = ld("#"+popupobj.divid+" [name=is_tree_field_"+rowid+"]").is(":checked");
				var is_tree_fieldname = ld("#"+popupobj.divid+" [name=is_tree_field_"+rowid+"]").val();
				tree_field_arr.push(is_tree_fieldname +'__'+is_tree_field);
			}
			urlstring += '&tree_field_json='+JSON.stringify(tree_field_arr);
		}
		ldAjax(urlstring,{},function(data){
    			if(data.code == 1){
    				var popupobj=CrmPopup.getPopupObj("last");
                    popupobj.CancelEvent();
                    // zkt 20220601 0052417（https://81mis.com/kfbtest/index.php）客户列表》树结构设置，保存后应自动刷新界面，不需要提示保存成功请刷新界面 
                    var urlstring = 'index.php?module='+that.module+'&action='+that.module+'Ajax&file=ModuleTree&setsession=yes';
                    ldAjax(urlstring,{},function(data){
                        if(data.code == 1){
                            window.location.reload();
                        }
                    });
    			}
                //zkt 20230328 BUG0062968  kfbcrm 若单据没有下拉框字段---点击树结构设置--点击保存页面一直转圈 例：自定义表单22 
                else if(data.code == -2){
    				if(!empty(data.msg)){
    				    var confirm_str = data.msg;
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
    				}
    			}
                DelProgressObjs();
		});
	}
}

function AddPicklistField(blockid,tabid){
	var popupobj = CrmPopup.getPopupObj('last');
    var module = popupobj.module;
	var that = this;
	var fld_module = that.module;
	//zxm @date:2024/10/23 @reason: 订货商城 用的是产品模块的字段
	if(fld_module=='ShoppingMall'){
		fld_module = 'Products';
	}

    var	nowmodule = "Settings";
    var urlstring = 'index.php?module='+nowmodule+'&action='+nowmodule+'Ajax&file=AddPicklistField&blockid='+blockid+'&currentmodule='+fld_module;
	getJsScript('include/js/customview.js',function(){
		ldAjax(urlstring,'',function(data){
			if(data.code == 1){
					var crmPopupobj=CrmPopup.load("","","","600",module,"","","","");
					crmPopupobj.type='ismoduletree';
					crmPopupobj.prevshow();
					crmPopupobj.setParams(data.result.title,"","","600",module,"",data.result.oktext,"",data.result.canceltext);
					getJsScript('include/js/modules/Settings/Settings.js', function () {
						PageSetup();//js报错未定义PageSetup
					});
					CrmPopup.setPopupobjHtmlContent_scroll_jquery(crmPopupobj,data.result.content);
					var selectfieldtype = ld("#"+crmPopupobj.divid+" [name=selectfieldtype]").get(0);
					for(var i=0; i<selectfieldtype.options.length; i++){
						if(selectfieldtype.options[i].value == 7){
							selectfieldtype[i].selected=true;
							break;
						}
					}
				ld("#"+crmPopupobj.divid+" [name=selectfieldtype]").prop("disabled","disabled");
				ld("#"+crmPopupobj.divid + " .selectfieldtype").next().remove();
				ld("#"+crmPopupobj.divid + " .selectfieldtype").select2({
					templateResult: selectfieldtypeImage,
				
					width:'90%'
				});
				
				//ld("#fldpicklist_"+blockid).select2({closeOnSelect: false, dropdownParent: ld("#"+crmPopupobj.divid)});//新建详情页面的多选框支持连续多选不收起
				makeFieldSelected(selectfieldtype,'',blockid);
				
				ld("#fldpicklist_"+blockid).select2({tags:true,width:'90%'
						,closeOnSelect: true
						
						,minimumResultsForSearch: Infinity
						,dropdownParent: ld("#"+crmPopupobj.divid)
					});
			addField(blockid,tabid);
			}       
		})
	})
}

// 1000125 ls 20230531 树结构设置和成员管理，左侧分类名称增加拖动列宽、展开收起
function structureTree() {
	var that=this;
	var popupobj=CrmPopup.getPopupObj("last");
	this.popupobj = popupobj;
	this.module=popupobj.module;
	this.pagetype = popupobj.pagetype || 'popuppage';//popuppage 分录选产品弹出层
	if (popupobj.pagetype == "listpage") {
		//this.tdObj =ld(".user-left-td");//树结构td区块
		this.tdDivObj =ld("#structuretree");//树结构区块
		this.tdExpandObj =ld("#listviewtreeopen");//展开收起图标td
		this.sidebarDragObj = ld(".sidebar-drag");//拖拽线
		this.dragAreaObj = ld(".ld-drag-area");//拖拽区域
	}
	else{
		//this.tdObj =ld("#"+popupobj.divid+" .user-left-td");//树结构td区块
		this.tdDivObj =ld("#"+popupobj.divid+" #structuretree");//树结构区块
		this.tdExpandObj =ld("#"+popupobj.divid+" #listviewtreeopen");//展开收起图标td
		this.sidebarDragObj = ld("#"+popupobj.divid+" .sidebar-drag");//拖拽线
		this.dragAreaObj = ld("#"+popupobj.divid+" .ld-drag-area");//拖拽区域
	}
	
	this.isMouseDown = false; // 标记鼠标按下状态
	this.mixWidth = 120;//最小宽度
	this.maxWidth = 500;//最大宽度
	this.treeWidth = 0;//树宽度
	this.clientWidth = parseInt(CrmPopup.getClientWidth());

	this.scrollulobj = ld('#'+popupobj.divid+' #moduletreelist');
	if(this.scrollulobj.length == 0){
		this.scrollulobj = ld('#'+popupobj.divid+' #popupmoduletreelist');
	}

	this.setEvent=function()
	{
		that.setTreeExpandData();
		that.sidebarDragObj.on('mousedown', that.handleMouseDown);
		that.dragAreaObj.on('mousemove', that.handleMouseMove);//无法回拖,也是因为鼠标离开td区域,所以需要扩大区域
		that.dragAreaObj.on('mouseup', that.handleMouseUp); //鼠标移动过程中,鼠标位置时常会离开td区域,导致鼠标抬起时up/leave事件无法触发,所以需要扩大区域

		that.dragAreaObj.on('mouseleave', function(){
			that.isMouseDown = false;//鼠标离开拖拽区域即不再设置宽度.
		});

		that.scrollulobj.slimscroll({
			// width: '100%', //可滚动区域宽度
			height: that.scrollulobj.height(), //可滚动区域高度
			size: '5px', //滚动条宽度，即组件宽度
			color: '#DCDEE0', //滚动条颜色
			position: 'right', //组件位置：left/right
			distance: '0px', //组件与侧边之间的距离
			start: 'top', //默认滚动位置：top/bottom
			opacity: 1, //滚动条透明度
			alwaysVisible: false, //是否 始终显示组件
			disableFadeOut: true, //是否 鼠标经过可滚动区域时显示组件，离开时隐藏组件
			// railVisible: true, //是否 显示轨道
			// railColor: 'rgba(15,41,80,1)', //轨道颜色
			// railOpacity: 1, //轨道透明度
			// railDraggable: true, //是否 滚动条可拖动
			// railClass: 'slimScrollRail', //轨道div类名
			barClass: 'slimScrollBar', //滚动条div类名
			wrapperClass: 'slimScrollDiv', //外包div类名
			allowPageScroll: true, //是否 使用滚轮到达顶端/底端时，滚动窗口
			wheelStep: 5, //滚轮滚动量
			touchScrollStep: 50, //滚动量当用户使用手势
			borderRadius: '7px', //滚动条圆角
			railBorderRadius: '7px' //轨道圆角
		});

		that.tdExpandObj.off("click").on("click",function(){
			that.tdDivObj.toggle();
			if(ld('#users_left_top_title').length > 0){
				ld('#users_left_top_title').toggle();
			}
			//列表界面宽度重新加载
			that.reloadRightContent();

			//更新图标data
			that.setTreeExpandData();

			//保存
			that.saveTreeExpand();
		})
	}


	this.handleMouseDown = function(event){
		that.isMouseDown = true;

		var evt =event||window.event;
		//阻止默认事件
		//evt.preventDefault();
	}

	this.handleMouseMove = function(event){
		var evt =event||window.event;
		if (that.isMouseDown) {
			var width = evt.clientX - ld(this).offset().left;//计算鼠标在td元素内的相对位置
			if(width < that.mixWidth){
				width = that.mixWidth;
			}
			if(width < that.mixWidth-5){
				that.isMouseDown = false;
			}
			if(width > that.maxWidth){
				width = that.maxWidth;
			}
			if(width > that.maxWidth+5){
				that.isMouseDown = false;
			}
			that.tdDivObj.css('width', width + 'px'); // 鼠标移动时更新td元素的宽度  不要用ld(this)
			that.treeWidth = width;
			that.reloadRightContent();
		}
		else{
		}
	}
	this.handleMouseUp = function(event){//鼠标松开时
		if (that.isMouseDown) {
			that.isMouseDown = false;
			//写入数据库
			that.saveTreeWidth();
			that.reloadRightContent();
		}
	}


	//保存 树结构展开状态
	this.saveTreeExpand=function (){
		var expand = that.tdDivObj.css("display")=='none'?'no':'yes';

		var urlstring = 'index.php?module='+that.module+'&action='+that.module+'Ajax&file=ModuleTree&setexpand='+expand;
		ldAjaxsyncNoProgress(urlstring,'',function(ajaxdata){});

	}

	//保存 树结构宽度
	this.saveTreeWidth=function (){
		var urlstring = 'index.php?module='+that.module+'&action='+that.module+'Ajax&file=ModuleTree&setwidth='+that.treeWidth;
		ldAjaxNoProgress(urlstring,'',function(ajaxdata){});
	}

	this.reloadRightContent=function (){
		var expand = that.tdDivObj.css("display")=='none'?'no':'yes';
		var width = 0;
		if (that.pagetype == "listpage") {
			width = ld("#"+that.popupobj.divid).width();//10是展开收起图标的宽度
		}
		else{
			width = ld("#"+that.popupobj.divid).width() - 20;//10是展开收起图标的宽度
		}
		if (expand == 'yes') {
			width = width - parseInt(that.treeWidth);
		}

		// 右侧列表内容宽度  参考方法 rightContentWidth()
		if (that.pagetype == "listpage") {
			ld('#'+ListView_Page.fullwidth_divid).css('width',width);
			ld('#'+ListView_Page.content_tableid).css("width",width);
			ld('#'+ListView_Page.header_table_divid).css("width",width);
			ld('#'+ListView_Page.content_table_divid).css("width",width);
			ld('#'+ListView_Page.header_tableid).css("width",width);
		}
		else{
			ld("#"+that.popupobj.divid + ' #'+ListView_Page.fullwidth_divid).css('width',width);
			ld("#"+that.popupobj.divid + ' #'+ListView_Page.content_tableid).css("width",width);
			ld("#"+that.popupobj.divid + ' #'+ListView_Page.header_table_divid).css("width",width);
			ld("#"+that.popupobj.divid + ' #'+ListView_Page.content_table_divid).css("width",width);
			ld("#"+that.popupobj.divid + ' #'+ListView_Page.header_tableid).css("width",width);
			ld("#"+that.popupobj.divid + ' [name=resize_popupsearch_tableid]').css("width",width);
			//wym BUG0075945 报价单--新建单据，选择产品，对窗口全屏，然后再点一下树结构，UI界面会立刻变换
			if(ld("#"+that.popupobj.divid + ' [name=ListViewContents]').find('table').first()){
				ld("#"+that.popupobj.divid + ' [name=ListViewContents]').find('table').first().css("width",width);
			}
		}
	}

	// 给展开收起图标写入数据
	this.setTreeExpandData=function (){
		var expand = that.tdDivObj.css("display")=='none'?'no':'yes';
		that.tdExpandObj.attr("data-tip",expand=='no'?arrJsPopLabel['EXPANSION']:arrJsPopLabel['COLLAPSE']);//展开 EXPANSION 收起COLLAPSE
		//console.log('setTreeExpandData:'+expand);
		if(expand == 'yes'){
			that.tdExpandObj.removeClass('opentree').addClass('closetree');
		}
		else{
			that.tdExpandObj.removeClass('closetree').addClass('opentree');
		}
	}

	this.getModuleTreeCount=function(popupobj) {
		var list_TreeWhere =popupobj.list_TreeWhere;
		var group_array = new Array();
		//edit: xll 2023/11/09 BUG0074711 kfbcrm-收款计划-统计报表漏斗，点击穿透，树结构单据数量显示正常，弹出层中切换页签后，树结构只显示点击进入的分类的单据数量
		var structuretreeObj = ld("#"+popupobj.divid+" #structuretree");
		if(popupobj.pagetype !== 'homestuffchuantou')
			structuretreeObj = ld(" #structuretree");
		if(structuretreeObj.length === 0)
			return false;
		var showspan = structuretreeObj.find('span[show="yes"]');
		ld(showspan).each(function () {
			var tmpparentchild = ld(this).attr('parentchild');
			if (group_array.indexOf(tmpparentchild) < 0) {
				group_array.push(tmpparentchild);
			}
		});

		var urlstring = 'index.php?module=Users&action=UsersAjax&frommodule=' + module + '&file=Module_Tree_Count&treewhere=' + list_TreeWhere;
		ldAjaxNoProgress(urlstring, '', function (data) {
			if (data.code == 1) {
				//每次请求后清除全部在赋html
				var totalspan = structuretreeObj.find('span[name=totalcount]');
				totalspan.remove();
				var tmpshowcountarr = data.result;
				if (module == 'Users') {
					var usersspan = structuretreeObj.find('span[tag="user_group"]');
					ld(usersspan).each(function () {
						var key = ld(this).attr('key');
						if (key != undefined && tmpshowcountarr[key] != undefined) {
							var countkey = ld(this).find('span[name=totalcount]').attr("key");
							if (countkey == undefined) {
								ld(this).append('<span class="greyFont9 marL10" name="totalcount" key="' + key + '" value="' + tmpshowcountarr[key]['totalcount'] + '">' + tmpshowcountarr[key]['totalcount'] + '</span>');
							} else {
								ld(this).find('span[name=totalcount]').remove();
								ld(this).append('<span class="greyFont9 marL10" name="totalcount" key="' + key + '" value="' + tmpshowcountarr[key]['totalcount'] + '">' + tmpshowcountarr[key]['totalcount'] + '</span>');
							}
						}
					});
				} else {
				ld(showspan).each(function () {
					var tmpparentchildid = ld(this).attr('parentchild');
					if (tmpparentchildid != undefined && tmpshowcountarr[tmpparentchildid] != undefined) {
						var parentchild = ld(this).find('span[name=totalcount]').attr("parentchild");
						if (parentchild == undefined) {
							ld(this).append('<span class="greyFont9 marL10" name="totalcount" parentchild="' + tmpparentchildid + '" value="' + tmpshowcountarr[tmpparentchildid]['totalcount'] + '">' + tmpshowcountarr[tmpparentchildid]['totalcount'] + '</span>');
						} else {
							ld(this).find('span[name=totalcount]').remove();
							ld(this).append('<span class="greyFont9 marL10" name="totalcount" parentchild="' + tmpparentchildid + '" value="' + tmpshowcountarr[tmpparentchildid]['totalcount'] + '">' + tmpshowcountarr[tmpparentchildid]['totalcount'] + '</span>');
						}
					}
				});
			}
			}
		});
	}

	//弹窗界面的树结构
	this.getPopupModuleTreeCount=function (popupobj) {
		var list_TreeWhere = popupobj.list_TreeWhere;
		var urlstring = 'index.php?module=Users&action=UsersAjax&frommodule=' + module + '&file=Module_Tree_Count&treewhere=' +list_TreeWhere;
		ldAjaxNoProgress(urlstring, '', function (data) {
			if (data.code == 1) {
				var module_tree_span = ld("#" + popupobj.divid + " #structuretree").find('span[tag=moudle_tree]');
				//每次请求后清除全部在赋html
				var totalspan = ld("#" + popupobj.divid + " #structuretree").find('span[name=totalcount]');
				totalspan.remove();
				var tmpshowcountarr = data.result;
				ld(module_tree_span).each(function () {
					var tmpparentchildid = ld(this).attr('parentchild');
					if (tmpparentchildid != undefined && tmpshowcountarr[tmpparentchildid] != undefined) {
						var parentchild = ld(this).find('span[name=totalcount]').attr("parentchild");
						if (parentchild == undefined) {
							ld(this).append('<span class="greyFont9 marL10" name="totalcount" parentchild="' + tmpparentchildid + '" value="' + tmpshowcountarr[tmpparentchildid]['totalcount'] + '">' + tmpshowcountarr[tmpparentchildid]['totalcount'] + '</span>');
						} else {
							ld(this).find('span[name=totalcount]').remove();
							ld(this).append('<span class="greyFont9 marL10" name="totalcount" parentchild="' + tmpparentchildid + '" value="' + tmpshowcountarr[tmpparentchildid]['totalcount'] + '">' + tmpshowcountarr[tmpparentchildid]['totalcount'] + '</span>');
						}
					}
				});
			}
		});
	}

}