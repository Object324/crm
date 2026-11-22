//地图视图加载
function ListViewMap(){
	var that = this;
	var location_lat = 0;
	var location_lng = 0;
	this.data_map_detail = '';
	this.mapobj = '';
	this.linkfield = '';//超链接字段和提示窗加粗字段

	this.getLocationAddress = function(fldname,mode){
		
		var popupobj=CrmPopup.getPopupObj("last");
		var divid=popupobj.divid;
		//默认省份
		var bill_state = '';
		var bill_city = '';
		
		if(popupobj.pagetype==CreatePagePopup.pagetype){
			bill_state = CrmPopup.findHtmlobj(divid,'bill_state').val();
			bill_city = CrmPopup.findHtmlobj(divid,'bill_city').val();
		}else if(popupobj.pagetype==DetailViewPage.pagetype){
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
						var restobj = eval('('+ results +')')?eval('('+ results +')'):JSON.parse(results);
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
									info += '<li state="'+restobj['entries'][i]['state']+'" city="'+restobj['entries'][i]['city']+'" district="'+restobj['entries'][i]['district']+'" address="'+restobj['entries'][i]['address']+'" point="'+restobj['entries'][i]['point']+'" country="'+restobj['entries'][i]['country']+'">';
									info += '<span>'+restobj['entries'][i]['address']+'</span>';
									info += '</li>';

								}
							}

							CrmPopup.findHtmlobj(divid,'search_location_address').html(info);
							CrmPopup.findHtmlobj(divid,'search_location_address').show();
							ld('#'+divid + ' .f-item').css('display', 'block');

							ld('#'+divid).unbind('click').on('click',function(){
								CrmPopup.findHtmlobj(divid,'search_location_address').hide();
							});


							ld('#search_location_address').find('li').each(function() {
								ld(this).click(function() {
									var district = ld(this).attr('district');
									var state = ld(this).attr('state');
									var city = ld(this).attr('city');
									var address = ld(this).attr('address');
									var point = ld(this).attr('point');
									var country = ld(this).attr('country');
									var point_arr = point.split(',');
									location_lat = point_arr[0];
									location_lng = point_arr[1];
									//city = trim(city.replace('市',''));
									if((CrmPopup.findHtmlobj(divid,'bill_street').val() != undefined && CrmPopup.findHtmlobj(divid,'bill_street').val() != '')||(CrmPopup.findHtmlobj(divid,'mailingstreet').val() != undefined && CrmPopup.findHtmlobj(divid,'mailingstreet').val() != '')||(CrmPopup.findHtmlobj(divid,'street').val() != undefined && CrmPopup.findHtmlobj(divid,'street').val() != '')){
										RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['doyouuselocationaddress']);
										ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
											CrmPopup.findHtmlobj(divid,'locationaddress').val(address);
											that.scriptMap(address,district,city,state,country)
										});
										ld('input[class="D_pbtncancel"]').unbind('click').on('click',function(){
											CrmPopup.findHtmlobj(divid,'search_location_address').hide();
										});
									}else{
										CrmPopup.findHtmlobj(divid,'locationaddress').val(address);
										that.scriptMap(address,district,city,state,country)
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
	this.scriptMap = function(address,district,city,state,country){
		var popupobj=CrmPopup.getPopupObj("last");
		var divid=popupobj.divid;
		//ls 20221228 按照district分割，地址只显示省市区后面的信息。
		if (!empty(address) && !empty(district)) {
			var address_arr = address.split(district);
			if (address_arr.length == 2) {//没有被分割或者分割多次则使用原地址
				address = address_arr[1];
			}
		}
		CrmPopup.findHtmlobj(divid,'bill_street').val(address);
		if(CrmPopup.findHtmlobj(divid,'mailingstreet').val() != undefined){
			CrmPopup.findHtmlobj(divid,'mailingstreet').val(address);
		}
		if(CrmPopup.findHtmlobj(divid,'street').val() != undefined){
			CrmPopup.findHtmlobj(divid,'street').val(address);
		}
		if(CrmPopup.findHtmlobj(divid,'bill_city').val() != undefined){
			CrmPopup.findHtmlobj(divid,'bill_city').val(city);
			CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_bill_city').val(city);
		}
		if(CrmPopup.findHtmlobj(divid,'bill_state').val() != undefined){
			CrmPopup.findHtmlobj(divid,'bill_state').val(state);
			CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_bill_state').val(state);
		}
		if(CrmPopup.findHtmlobj(divid,'bill_area').val() != undefined){
			CrmPopup.findHtmlobj(divid,'bill_area').val(district);
			CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_bill_area').val(district);
		}
		if(CrmPopup.findHtmlobj(divid,'bill_country').val() != undefined){
			CrmPopup.findHtmlobj(divid,'bill_country').val(country);
			CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_bill_country').val(country);
		}
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
	this.initMap = function(){
		var popupobj=CrmPopup.getPopupObj("last");
		var divid=popupobj.divid;
		ld("#"+divid+" [name=location_map_td]").show();
		var center = new qq.maps.LatLng(location_lat,location_lng);
		//定义map变量 调用 qq.maps.Map() 构造函数   获取地图显示容器
		var map = new qq.maps.Map(ld("#"+divid+" [name=container]")[0], {
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
	}

	this.enlarge_map = function(address){
		var popupobj=CrmPopup.getPopupObj("last");
		var divid=popupobj.divid;
		if(empty(address)){
			address = CrmPopup.findHtmlobj(divid,'locationaddress').val();
		}
		var record = CrmPopup.findHtmlobj(divid,'record').val();
		var urlajax = "module=Accounts&action=AccountsAjax&file=TencentMap&address="+encodeURIComponent(address)+"&getpoint=yes&record="+popupobj.record+"&frommodule="+popupobj.module;	//单
		//alert(urlajax);
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
						var table_html = '<div name="big_container" id="big_container" style="height:400px;"></div>';
						resultRemindsMsg(arrJsPopLabel['ACCOUNTSMAP'],"LdPopWidth800px","","yes","",table_html);
						//创建script标签
						var script = document.createElement("script");
						//设置标签的type属性
						script.type = "text/javascript";
						//设置标签的链接地址
						script.src = "https://map.qq.com/api/js?v=2.exp&key=P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X&callback=Big_initMap";
						//添加标签到dom
						document.body.appendChild(script);
					}
				}
			}
		)
	}
	//
	this.Big_initMap = function(){
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
	}
	var account_map,account_center,InfoWindow,infoWin;

	//加载地图上客户信息
	this.initMapAccount = function(){
		// BUG0071118 ls 20230816 项目信息（客户）模块的地图模式，第1、2页的地图点还显示正常，但是切换到第3页，地图点就只能显示一个，多的显示不出来(json解析错误)
		account_map = ListViewMap.curobj.mapobj;
		var data_map_detail = that.data_map_detail.replace(/\s+/g, ' ');
		if(!empty(data_map_detail)){
			var data_map_detail_json = eval('('+ data_map_detail +')')?eval('('+ data_map_detail +')'):JSON.parse(data_map_detail);
		}
		InfoWindow = new qq.maps.InfoWindow({ map: account_map });//添加提示窗

		var i = 0;
		for (account_id in data_map_detail_json){
			var _rotation = '';	//其他内
			var _name = '';	//主题
			var _lat = '';
			var _lng = '';
			for (fieldname in data_map_detail_json[account_id]){
				if(fieldname == that.linkfield){
					_name = data_map_detail_json[account_id][fieldname];
				}else if(fieldname == 'lat'){
					_lat = data_map_detail_json[account_id][fieldname];
				}else if(fieldname == 'lng'){
					_lng = data_map_detail_json[account_id][fieldname];
				}else{
					_rotation += data_map_detail_json[account_id][fieldname]+'<br>';
				}
			}
			var marker = new qq.maps.Marker({ position: new qq.maps.LatLng(_lat, _lng), map: account_map });//创建标记
			
			//***将必要的数据存入每一个对应的marker对象
			var j = i+1;
			marker.id = j;
			marker.name = _name;
			marker.rotation = _rotation;
			qq.maps.event.addListener(marker, 'click', function(event) {//获取标记的点击事件
				InfoWindow.open();//点击标记打开提示窗
				var content =   '<div style="width:320px;">' +
					'<div style="font-size: 14px;font-weight: bold;color: #333;padding-bottom: 5px;">'+ event.target.name +'</div>' +
					'<div style="font-size: 12px;color: #999;">'+ event.target.rotation +'</div>' +
					'</div>';
				InfoWindow.setContent(content);
				InfoWindow.setPosition(new qq.maps.LatLng(event.latLng.getLat(), event.latLng.getLng()));//提示窗位置
				setTimeout(function() {
					InfoWindow.close();
				}, 20 * 1000);
			});
			i++;
		}
	}

	this.changeListMap = function(obj,module,btn_type,page,popupobj){
			
		var a = ld('#pagehead').outerHeight(true),//头部高度
			//zxm BUG0060693	已分派	功能BUG	正常处理	客户地图视图列表界面，左侧单据列表界面，没有显示上一页和下一页操作按钮
			//b = ld('.tabHieght').outerHeight(true),//标签高度
			b = 0,
			c = ld('.main_grid_top').outerHeight(true),//数据分类/按钮等区块的高度
			// d = ld('.D_btn_box').outerHeight(true);//按钮高度
			d = 0;//按钮高度
		h_height = 0,
		s_height = ld(window).height();

		if(a==null) a=0;
		if(a == 0) a=55;
		if(b==null) b=0;
		if(b == 0) b=10;
		if(c==null) c=0;
		if(d==null) d=0;
		h_height = a+b+c+d;		

		var divid=popupobj.divid;

		popupobj.page=page;
		if(empty(page))page = 1;
		if(btn_type=='list')
		{
			popupobj.type=ListPagePopup.type;
		}
		else
			popupobj.type='maplist';

		var urlstring = "index.php?module="+module+'&action='+module+'Ajax&file=Map_ListView&page='+page+'&frommodule='+module+'&';

		//基本、高级查询条件
	// alert(searchtype_btn);
		//if(!empty(searchtype_btn)){
		//	urlstring += getUrlString(searchtype_btn);
		//edit:can 20210514 0045889: （https://61mis.com/kfbcrm [^]）客户问题（广东新业），客户地图，点击“广东->广州”，进入客户单据列表界面，再点击“地图视图”模式图标时，带过来的查询条件没有生效（需要补丁）
			urlstring += "query_session=1";
	//	}
		urlstring += '&btn_type='+btn_type;
		//zkt 20230703 BUG0068992  单据单页条数设置显示200条后打开客户档案中的客户地图一直装圈，无法加载
		ldAjax(urlstring,'',function(data){
			if(data.code==1)
				{
					ld("#divMapLeft").html(data.result.content);
					ld('.map-list').css('height',s_height-h_height-60);
					that.data_map_detail = data.result.map_content;
					var data_map_detail_json = eval('('+ data.result.map_content +')')?eval('('+ data.result.map_content +')'):JSON.parse(data.result.map_content);
					that.linkfield = data.result.linkfield;

					if(btn_type == 'list'){
						ld('#hdScrolllistentries_yy').show();
						ld(' .list-item span').removeClass('cur');
						ld(' .list-item span i.list-btn').parent().addClass('cur');
						ld('#divMapShow').hide();
					}else{
						ld('#hdScrolllistentries_yy').hide();
						ld(' .list-item span').removeClass('cur');
						ld(' .list-item span i.map-btn').parent().addClass('cur');
						ld('#divMapShow').show();
						ld('#divMapShow').css('height',s_height-h_height-5);
						ld('#map_div').css('height',s_height-h_height-5);

						//客户名称绑定事件
						ld('.map-list .map-list-item').on('click',function(e){
							var account_id = ld(this).attr('data-id');
							var account_latitude = ld(this).attr('data-latitude');
							var account_longtitude = ld(this).attr('data-longtitude');
							ld('.map-list .map-list-item').removeClass('cur');
							ld('.map-list .map-list-item[data-id='+account_id+']').addClass('cur');
							//明细界面
							if(ld(e.target).hasClass('title')){
								//console.log('明细界面');
							}
							//编辑界面
							else if(ld(e.target).hasClass('change-geo')){
								//alert('编辑界面');
								// var module = 'Accounts';
								var urlstring = 'module=Users&action=UsersAjax&file=callStaticMethod';
								urlstring += '&static=puyoung&method=checkEditInfo';
								urlstring += '&fld_module='+module+'&record='+account_id;

								RequestAjax(urlstring,function(rest){
									if(empty(rest)){
										DelProgressObjs();
										return false;
									}
									var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
									if(restobj.check.indexOf('SUCCESS')>=0){
										var Popupobj=PageRecordPopup.loadobj("","","","LdPopWidth950px",module,"","","","",account_id);
										Popupobj.prevshow();
										var url = 'module='+module+'&action=EditView&record='+account_id;
										url += '&return_module=module&return_action=ListView';

										//列表和相关信息编辑
										PageRecordPopup.params['refreshpage']='no';

										PageRecordPopup.showpage(module,account_id,"", PageRecordPopup.params);
										//zxm20230329  kfbcrm 客户地图--点击左侧列表编辑---弹出层会闪过空白页---没加载出来时，应该显示转圈
										//DelProgressObjs();
									}else{
										RemindsMsg("","LdPopWidth400px",module,"yes","",restobj.check);
										//zxm20230329  kfbcrm 客户地图--点击左侧列表编辑---弹出层会闪过空白页---没加载出来时，应该显示转圈
										//DelProgressObjs();
										return false;
									}
								});
							}
							//显示地图
							else{
								//console.log('显示地图');
								if (infoWin && infoWin.getMap()) {
									infoWin.setMap(null);
								}
								if(account_latitude == '' || account_longtitude == ''){
									return;
								}
								var title='', text = '';
								title = data_map_detail_json[account_id][that.linkfield];
								for (fieldname in data_map_detail_json[account_id])
								{
									if(fieldname != that.linkfield && fieldname != 'local_address' && fieldname != 'lat' && fieldname != 'lng'){
										text +=data_map_detail_json[account_id][fieldname] + '<br/>';
									}
								}

								account_map = ListViewMap.curobj.mapobj;
								account_center = new qq.maps.LatLng(account_latitude,account_longtitude);
								account_map.setCenter(account_center);

								that.initMapAccount();
								infoWin = new qq.maps.InfoWindow({
									map: account_map
								});
								infoWin.open();
								infoWin.setContent( '<div style="width:320px;">' +
									'<div style="font-size: 14px;font-weight: bold;color: #333;padding-bottom: 5px;">'+ title +'</div>' +
									'<div style="font-size: 12px;color: #999;">'+ text +'</div>' +
									'</div>');
								infoWin.setPosition(account_center);
								setTimeout(function() {
									infoWin.close();
								}, 20 * 1000);
							}
						});
						//创建script标签
						var script = document.createElement("script");
						//设置标签的type属性
						script.type = "text/javascript";
						//设置标签的链接地址
						script.src = "https://map.qq.com/api/js?v=2.exp&callback=initMap_common&key=P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X";
						//添加标签到dom
						document.body.appendChild(script);
						
						//zxm 20230201 	BUG0060954	已分派	功能BUG	客户地图视图模式，左侧第一页点击详细地址时，右侧地图中没有显示地图详情信息
						setTimeout(function(){
							ld('.map-list .map-list-item').first().click();
						},500);
					}
					
					//yujun 只显示一个图标,先显示地图图标 2023-6-6
					var tmp_listbtn = ld(obj);
					if(obj.id == 'tip_list'){
						var parent_another_child = tmp_listbtn.parent().find('#tip_map');
						parent_another_child.css('display','block');
						tmp_listbtn.css('display','none');
					}else{
						var parent_another_child = tmp_listbtn.parent().find('#tip_list');
						parent_another_child.css('display','block');
						tmp_listbtn.css('display','none');
					}
				}
				else{
					var confirm_str = arrJsPopLabel['NORECORDSAREFOUND'];
					RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
					return false;
				}
				DelProgressObjs();
		})
		
	}
	this.updateAddress = function(obj, module){
		var popupobj=CrmPopup.getPopupObj("last");
		var select_options = ld("#"+popupobj.divid+" [name=allselectedboxes]").val();
		if(select_options == 'all'){
			//获取全选数量
			var selectlen = ld("#"+popupobj.divid+" [name=numOfRows]").val();
			if (parseInt(selectlen) > parseInt(getMaxMassOperationLimit())) {
				var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT', selectlen, getMaxMassOperationLimit(), '');
				RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", confirm_str + arrJsPopLabel['WENHAO']);
				//确定事件
				ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
					that.update(select_options, module);
				});
			}
			else {
				that.update(select_options, module);
			}
		}else{
			if(select_options == ''){
				RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['PLEASESELECTONEENTITY']);
				return false;
			}
			var x = select_options.split(';');
            var count = x.length;
            if (parseInt(count) - 1 > parseInt(getMaxMassOperationLimit())) {
                var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT', parseInt(count) - 1, getMaxMassOperationLimit(), '');
                //创建提示弹出层
                RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", confirm_str + arrJsPopLabel['WENHAO']);
                //确定事件
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                    that.update(select_options, module);
                });
            } else {
                that.update(select_options, module);
            }
		}
	}
	//更新地址信息
	this.update = function(select_options, module){
		var urlstring = "index.php?module="+module+'&action='+module+'Ajax&file=UpdateAddress&frommodule='+module+'&select_ids='+select_options;
		ldAjax(urlstring,'',function(data){
			if(data.code==1)
				{
					var confirm_str = arrJsPopLabel['SUCCESSFULOPERATION'];
					MessagePopup.TipZero_success(confirm_str);
					//刷新列表
					var tmparra=new Array();
					var tmpobj= new AfterUpdatePrevPopupObjContent(module,"",tmparra);
					var refreshlistmodules = new Array(module);
					tmpobj.eachrefreshlistbyModules(refreshlistmodules);
				}
				else{
					var confirm_str = arrJsPopLabel['NORECORDSAREFOUND'];
					MessagePopup.TipOne_success(confirm_str);
					return false;
				}
				DelProgressObjs();
		})
	}
}
ListViewMap.curobj = '';
ListViewMap.getInstance=function(){
	if(!empty(ListViewMap.curobj)){
	}else{
		ListViewMap.curobj=new ListViewMap();
	}
    return ListViewMap.curobj;
}

//加载地图api后的回调函数
function initMap_common(){
	var InfoWindow = null;
	
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	
	var account_center = new qq.maps.LatLng(first_map_lat,first_map_lng);
	//定义map变量 调用 qq.maps.Map() 构造函数   获取地图显示容器
	var account_map = new qq.maps.Map(ld("#"+divid+" [name=map_div]")[0], {
		center: account_center,      // 地图的中心地理坐标。
		zoom:15,                                           // 地图的中心地理坐标。
		disableDefaultUI: true
	});
	
	//创建标记
	var anchor = new qq.maps.Point(6, 6),
		size = new qq.maps.Size(23, 38),
		origin = new qq.maps.Point(0, 0);
	//icon = new qq.maps.MarkerImage('themes/images/location.png', size, origin, anchor);
	var marker = new qq.maps.Marker({
		//icon: icon,
		position: account_center,
		map: account_map
	});
	
	var listViewMap = ListViewMap.getInstance();
	listViewMap.mapobj = account_map;
	listViewMap.initMapAccount();
	
}