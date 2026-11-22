function loadScript(){ 
    //创建script标签
	var script = document.createElement("script");
	//设置标签的type属性
	script.type = "text/javascript";
    script.charset="utf-8";
	//设置标签的链接地址
	script.src = "https://map.qq.com/api/js?v=2.exp&callback=initMaps&key=P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X";
	//添加标签到dom
	document.body.appendChild(script);
}

//地图初始化时应加载所有的标记点，地图中心点为默认值
function initMaps(){
    //根据用户输入的检索半径选择合适的地图比例尺（缩放级别）
    var zoom_level;  
    if(distance>50000){
        zoom_level=11;
    }else if(distance>10000){
        zoom_level=12;
    }else if(distance>5000){
        zoom_level=13;
    }else if(distance>1000){
        zoom_level=14;
    }else if(distance>500){
        zoom_level=15;
    }else if(distance>100){
        zoom_level=16;      
    }else{
        zoom_level=18;
    }          
    var mapobj = ld("#"+"pagecontent"+" [name=map_div]");
    
    
    //接收地图的中心点
    if(first_map_lat == '' || first_map_lat == undefined || first_map_lat == null || first_map_lng == '' || first_map_lng == undefined || first_map_lng == null){             
        alert("当前中心点地址无法获取经纬度，请重新输入");
        return -1;                
    }else{
        account_center = new qq.maps.LatLng(first_map_lat,first_map_lng);
    }  
    //实例化地图对象
    account_map = new qq.maps.Map(mapobj.get(0), {        
    	center: account_center,      
    	zoom:zoom_level,                                      
    	disableDefaultUI: true
    });
    //account_map.setOpacity(opacity: 0);
    
            
    //实例化信息窗对象
    InfoWindow = new qq.maps.InfoWindow({ map: account_map });
    InfoWindow.close();
    
    //实例化中心点标记Marker
    var center_marker = new qq.maps.Marker({
        //设置Marker的位置坐标
        position:account_center,
        //设置Marker被添加到Map上时的动画效果为落下
        animation: qq.maps.MarkerAnimation.DOWN,
        //设置显示Marker的地图
        map:account_map,
        //设置Marker可拖动
        draggable:true,
        //自定义中心点Marker图标
        icon:new qq.maps.MarkerImage(
            'https://mapapi.qq.com/web/lbs/javascriptGL/demo/img/markerNew.png',
        )
    });
    
    //监听中心点的拖动事件
    qq.maps.event.addListener(center_marker, 'mouseup', function(event) {
        account_center_drag = new qq.maps.LatLng(event.latLng.lat,event.latLng.lng);
        
        //获取用户选择的产品类型
        var listvalue_product_str = "";
        if(ld('#checkAll').prop("checked")){
            listvalue_product_str = 'All';
        }
        else{
            var objs = ld("input[name='chb[]']");
            ld.each(objs,function(){
                if(ld(this).is(':checked')){
                    listvalue_product_str += ld(this).attr('listvalue')+',';
                }
            })
        }
        
        //获取用户选择的大巴车类型
        var listvalue_bus_str = "";
        if(ld('#checkAll2').prop("checked")){
            listvalue_bus_str = 'All';
        }
        else{
            var objs = ld("input[name='chb2[]']");
            ld.each(objs,function(){
                if(ld(this).is(':checked')){
                    listvalue_bus_str += ld(this).attr('listvalue')+',';
                }
            })
        }
        
        //判断用户勾选条件是否为空
        if(listvalue_product_str.length<1 && listvalue_bus_str.length<1){
            var confirmstr = '请选择您要查询的主营品类或大巴车类型';
            RemindsMsg("","LdPopWidth400px","","yes","",confirmstr);
            return false;
        }
        //获取用户输入端搜索距离并判断是否为空
        var distance_obj=ld("input[name=distanceinput]");
        var distance_str=ld(distance_obj).val();
        if (distance_str == '' || distance_str == undefined || distance_str == null){
            var confirmstr = '请输入搜索距离';
            RemindsMsg("","LdPopWidth400px","","yes","",confirmstr);
            return false;
        } 
        var distance_str=parseInt(distance_str);
        
        //连用Ajax携带用户输入的数据到后端进行查询  
        var url = 'index.php?module=ServiceCharge&action=ServiceChargeAjax&file=map_distribution';
        url += '&listvalue_product_str='+listvalue_product_str;
        url += '&listvalue_bus_str='+listvalue_bus_str;
        url += '&account_center_drag_lat='+account_center_drag.lat;
        url += '&account_center_drag_lng='+account_center_drag.lng;
        url += '&distance_str='+distance_str;
        url += '&mode=drag';    
        ldAjax(url,"",function(data){
            DelProgressObjs();
            //接收后台返回的客户相关信息
            if(data.code == 1){
                address = data.result.address;
                obj = JSON.parse(address);
                address=obj.result.formatted_addresses.recommend;
                point_arr = data.result.all_accountinfo;
                ld('input[id=centeraddress]').val(address);
                first_map_lat=account_center_drag.lat;
                first_map_lng=account_center_drag.lng;
                all_count=data.result.all_count;
                ld('span[tag=all_quantity]').text(all_count);
                product_count=data.result.product_count;
                ld('span[tag=quantity_product]').text(product_count);
                bus_count=data.result.bus_count;
                ld('span[tag=quantity_bus]').text(bus_count);
                //更新地图显示
                initMaps();
            }
        })
        
    });
    

    //遍历PHP返回的客户标记点
    var point_arr_json = eval('('+ point_arr +')')?eval('('+ point_arr +')'):JSON.parse(point_arr);
	for (id in point_arr_json){
	   
	   
        var obj = point_arr_json[id];
        var _lat =  obj.latitude[0];
		var _lng =  obj.longtitude[0];    
        var _locationaddress = obj.locationaddress[0];
        var _bus_number = obj.bus_number[0];                
        var _accountname = obj.accountname;          
        var _product_type = obj.product_type;
        var _bus_type = obj.bus_type;
        var base_url = 'storage/shangmaopifa/icon/';
        
        //在同一个标记点合并下游客户的信息        
        var product_str='';
        for(i=1;i<_accountname.length;i++){
            product_str+='<div style="font-size: 13px;font-weight: bold;color: #666;">'+_accountname[i]+'</div>'+'<div style="font-size: 12px;color: #999;margin-bottom:10px;">'+ "主营品类："+_product_type[i].replace(/[&\|\\\*^%$#@\-]/g,"")+'</div>';
        };
        
        //在同一个标记点合并大巴车客户的信息
        var bus_str='';
        for(i=1;i<_accountname.length;i++){
            bus_str+='<div style="font-size: 13px;font-weight: bold;color: #666;">'+_accountname[i]+'</div>'+'<div style="font-size: 12px;color: #999;margin-bottom:10px;">'+ "大巴车类型："+_bus_type[i]+'</div>';
        };
        if(obj.type[0]=='大巴车'){
            var icon_src=base_url+'8.png';
            if(_accountname.length>=2){
                icon_src=base_url+'8-'+_accountname.length+'.png';
                if(_accountname.length>10){
                    icon_src=base_url+'8-11.png';
                }
            }
    		marker_bus =make_marker(_lat,_lng,account_map,icon_src);
            bus_marker_onclick(_lat,_lng,_locationaddress,_accountname,_bus_type,marker_bus,bus_str,InfoWindow);
        }
        else{
            var type_arr=new Array();//品类
            type_arr=unique(_product_type);
			type_arr=type_arr[0];
        		if(_accountname.length>=2){
                    var icon_src=base_url+'10-'+_accountname.length+'.png';
                    if(_accountname.length>10){
                        icon_src=base_url+'10-11.png';
                    }
            		marker_product =make_marker(_lat,_lng,account_map,icon_src);
                    product_marker_onclick(_lat,_lng,_locationaddress,_accountname,_product_type,marker_product,product_str,InfoWindow);
                    //console.log(type_arr);
        		
        		}else if(type_arr.indexOf(product_listvalue_arr_json[0]) > -1 || type_arr.indexOf(product_listvalue_arr_json[1]) > -1){
                    var icon_src=base_url+'1.png'; 
            		marker_product1 =make_marker(_lat,_lng,account_map,icon_src);
                    product_marker_onclick(_lat,_lng,_locationaddress,_accountname,_product_type,marker_product1,product_str,InfoWindow);
                    //console.log(type_arr);
        		
        		}else if(type_arr.indexOf(product_listvalue_arr_json[2]) > -1 || type_arr.indexOf(product_listvalue_arr_json[3]) > -1){
                    var icon_src=base_url+'2.png'; 
            		marker_product2 =make_marker(_lat,_lng,account_map,icon_src);
                    product_marker_onclick(_lat,_lng,_locationaddress,_accountname,_product_type,marker_product2,product_str,InfoWindow);
                    //console.log(type_arr);
        		
        		}else if(type_arr.indexOf(product_listvalue_arr_json[4]) > -1){
                    var icon_src=base_url+'3.png'; 
            		marker_product3 =make_marker(_lat,_lng,account_map,icon_src);
                    product_marker_onclick(_lat,_lng,_locationaddress,_accountname,_product_type,marker_product3,product_str,InfoWindow);
                    //console.log(type_arr);
        		
        		}else if(type_arr.indexOf(product_listvalue_arr_json[5]) > -1){
                    var icon_src=base_url+'4.png'; 
            		marker_product4 =make_marker(_lat,_lng,account_map,icon_src);
                    product_marker_onclick(_lat,_lng,_locationaddress,_accountname,_product_type,marker_product4,product_str,InfoWindow);
                    //console.log(type_arr);
        		
        		}else if(type_arr.indexOf(product_listvalue_arr_json[6]) > -1 || type_arr.indexOf(product_listvalue_arr_json[7]) > -1){
                    var icon_src=base_url+'5.png'; 
            		marker_product5 =make_marker(_lat,_lng,account_map,icon_src);
                    product_marker_onclick(_lat,_lng,_locationaddress,_accountname,_product_type,marker_product5,product_str,InfoWindow);
                    //console.log(type_arr);
        		
        		}else if(type_arr.indexOf(product_listvalue_arr_json[10]) > -1 || type_arr.indexOf(product_listvalue_arr_json[11]) > -1|| type_arr.indexOf(product_listvalue_arr_json[12]) > -1|| type_arr.indexOf(product_listvalue_arr_json[13]) > -1){
                    var icon_src=base_url+'6.png'; 
            		marker_product6 =make_marker(_lat,_lng,account_map,icon_src);
                    product_marker_onclick(_lat,_lng,_locationaddress,_accountname,_product_type,marker_product6,product_str,InfoWindow);
                    //console.log(type_arr);
        		
        		}else if(type_arr.indexOf(product_listvalue_arr_json[14]) > -1){
                    var icon_src=base_url+'7.png'; 
            		marker_product7 =make_marker(_lat,_lng,account_map,icon_src);
                    product_marker_onclick(_lat,_lng,_locationaddress,_accountname,_product_type,marker_product7,product_str,InfoWindow);
                    //console.log(type_arr);
        		}else{
                    var icon_src=base_url+'9.png'; 
            		marker_product8 =make_marker(_lat,_lng,account_map,icon_src);
                    product_marker_onclick(_lat,_lng,_locationaddress,_accountname,_product_type,marker_product8,product_str,InfoWindow);
        		  
        		}
        };      
        

  
	}

         
}

function make_marker(_lat,_lng,account_map,icon_src){
    //实例化下游客户标记点 
	marker = new qq.maps.Marker({
        position: new qq.maps.LatLng(_lat,_lng),
        map: account_map,
        animation: qq.maps.MarkerAnimation.DOWN,
        icon:new qq.maps.MarkerImage(icon_src)
    });
    return marker;
}

function product_marker_onclick(_lat,_lng,_locationaddress,_accountname,_product_type,marker_product,product_str,InfoWindow){
    marker_product.lat=_lat;
    marker_product.lng=_lng;
    marker_product.locationaddress=_locationaddress;
    marker_product.accountname=_accountname[0];
    marker_product.product_type=_product_type[0];
    marker_product.product_str=product_str;
    marker_product.num=_accountname.length;
    //监听下游客户标记点的点击事件(弹出信息窗)
	qq.maps.event.addListener(marker_product, 'click', function(event) {
		InfoWindow.open();
        var content_product = '';
        if(event.target.product_str == ''){
            content_product =
                '<div style="width:320px;max-height:350px;overflow-y:auto;" charset="utf-8;">' +
                '<div style="font-size: 13px;font-weight: bold;color: #3B4859;">'+ event.target.accountname +'</div>' +
                '<div style="font-size: 12px;color: #999;">'+ "主营品类："+event.target.product_type.replace(/[&\|\\\*^%$#@\-]/g,"") +'</div>' +
                '<div style="font-size: 12px;color: #999;">'+ "地址："+event.target.locationaddress +'</div>' +
    			'</div>';   
        }
        else{
            content_product =
                '<div style="width:320px;max-height:350px;overflow-y:auto;" charset="utf-8;">' +
    			'<div style="font-size: 13px;font-weight: bold;color: #3B4859;">'+ "地址："+event.target.locationaddress +'</div>' +
                '<div style="font-size: 13px;font-weight: bold;color: #3B4859;margin-bottom:10px;">'+ "共"+event.target.num +'条，如下：</div>' +
                '<div style="font-size: 13px;font-weight: bold;color: #3B4859;">'+ event.target.accountname +'</div>' +
                '<div style="font-size: 12px;color: #999;margin-bottom:10px;">'+ "主营品类："+event.target.product_type.replace(/[&\|\\\*^%$#@\-]/g,"") +'</div>' +
                '<div style="font-size: 12px;color: #999;">'+event.target.product_str +'</div>' +
    			'</div>';   
        }
		InfoWindow.setContent(content_product);
		InfoWindow.setPosition(new qq.maps.LatLng(event.latLng.getLat(), event.latLng.getLng()));         
	});
}


function bus_marker_onclick(_lat,_lng,_locationaddress,_accountname,_bus_type,marker_bus,bus_str,InfoWindow){
    marker_bus.lat=_lat;
    marker_bus.lng=_lng;
    marker_bus.accountname=_accountname[0];
    marker_bus.locationaddress=_locationaddress;
    marker_bus.bus_type=_bus_type[0];
    marker_bus.bus_str=bus_str;
    marker_bus.num=_accountname.length;
    //监听大巴车标记点的点击事件(弹出信息窗)
	qq.maps.event.addListener(marker_bus, 'click', function(event) {
		InfoWindow.open();
        var content_bus = '';
        if(event.target.bus_str == ''){
            content_bus =
                '<div style="width:320px;max-height:350px;overflow-y:auto;" charset="utf-8;">' +
                '<div style="font-size: 13px;font-weight: bold;color: #3B4859;">'+ event.target.accountname +'</div>' +
                '<div style="font-size: 12px;color: #999;">'+ "大巴车类型："+event.target.bus_type.replace(/[&\|\\\*^%$#@\-]/g,"") +'</div>' +
                '<div style="font-size: 12px;color: #999;">'+ "地址："+event.target.locationaddress +'</div>' +
    			'</div>';   
        }
        else{
            content_bus =
                '<div style="width:320px;max-height:350px;overflow-y:auto;" charset="utf-8;">' +
    			'<div style="font-size: 13px;font-weight: bold;color: #3B4859;">'+ "地址："+event.target.locationaddress +'</div>' +
                '<div style="font-size: 13px;font-weight: bold;color: #3B4859;margin-bottom:10px;">'+ "共"+event.target.num +'条，如下：</div>' +
                '<div style="font-size: 13px;font-weight: bold;color: #3B4859;">'+ event.target.accountname +'</div>' +
                '<div style="font-size: 12px;color: #999;margin-bottom:10px;">'+ "大巴车类型："+event.target.bus_type.replace(/[&\|\\\*^%$#@\-]/g,"") +'</div>' +
                '<div style="font-size: 12px;color: #999;">'+event.target.bus_str +'</div>' +
    			'</div>';   
        }
		InfoWindow.setContent(content_bus);
		InfoWindow.setPosition(new qq.maps.LatLng(event.latLng.getLat(), event.latLng.getLng()));         
	});
}

function unique(arr){
	// 遍历arr，把元素分别放入tmp数组(不存在才放)
	var tmp = new Array();
    
    for(var i=0;i<arr.length;i++){
        if(tmp.indexOf(arr[i])==-1){
			tmp.push(arr[i]);
		}
    }
	return tmp;
}

//查询指定类型的客户标记点
function typesSearch(){
    //获取用户输入的地址
    var address_obj=ld("input[name=addressinput]"); 
    var address_str=ld(address_obj).val();
    var address_str=trim(address_str);
    if (address_str == '' || address_str == undefined || address_str == null){
        var confirmstr = '请输入中心点地址';
        RemindsMsg("","LdPopWidth400px","","yes","",confirmstr);
        return false;
    };
    
    //获取用户选择的产品类型
    var listvalue_product_str = "";
    if(ld('#checkAll').prop("checked")){
        listvalue_product_str = 'All';
    }
    else{
        var objs = ld("input[name='chb[]']");
        ld.each(objs,function(){
            if(ld(this).is(':checked')){
                listvalue_product_str += ld(this).attr('listvalue')+',';
            }
        })
    }
    
    //获取用户选择的大巴车类型
    var listvalue_bus_str = "";
    if(ld('#checkAll2').prop("checked")){
        listvalue_bus_str = 'All';
    }
    else{
        var objs = ld("input[name='chb2[]']");
        ld.each(objs,function(){
            if(ld(this).is(':checked')){
                listvalue_bus_str += ld(this).attr('listvalue')+',';
            }
        })
    }
  
    if(listvalue_product_str.length<1 && listvalue_bus_str.length<1){
        var confirmstr = '请选择您要查询的主营品或大巴车类型';
        RemindsMsg("","LdPopWidth400px","","yes","",confirmstr);
        return false;
    }
    //获取用户输入端搜索距离
    var distance_obj=ld("input[name=distanceinput]");
    var distance_str=ld(distance_obj).val();
    if (distance_str == '' || distance_str == undefined || distance_str == null){
        var confirmstr = '请输入搜索距离';
        RemindsMsg("","LdPopWidth400px","","yes","",confirmstr);
        return false;
    } 
    var distance_str=parseInt(distance_str);  
    var url = 'index.php?module=ServiceCharge&action=ServiceChargeAjax&file=map_distribution';
    url += '&address_str='+address_str;
    url += '&listvalue_product_str='+listvalue_product_str;
    url += '&listvalue_bus_str='+listvalue_bus_str;
    url += '&distance_str='+distance_str;
    url += '&mode=search';
    //console.log(url);
    //携带用户输入的数据到后端进行查询    
    ldAjax(url,"",function(data){
        DelProgressObjs();
        if(data.code == 1){
             first_map_lat = data.result.first_map_lat;
             first_map_lng = data.result.first_map_lng;
             distance = data.result.distance;
            if(first_map_lat == '' || first_map_lat == undefined || first_map_lat == null || first_map_lng == '' || first_map_lng == undefined || first_map_lng == null){
                var confirmstr = '该地址无法获取经纬度，请重新输入中心点地址';
                RemindsMsg("","LdPopWidth400px","","yes","",confirmstr);
                return false;
            };
            point_arr = data.result.all_accountinfo;
            address = data.result.address;
            ld('input[id=centeraddress]').val(address);
            all_count=data.result.all_count;
            ld('span[tag=all_quantity]').text(all_count);
            product_count=data.result.product_count;
            ld('span[tag=quantity_product]').text(product_count);
            bus_count=data.result.bus_count;
            ld('span[tag=quantity_bus]').text(bus_count);
            //更新地图显示
            initMaps();
        }
    })
}



//为主营品类型全选框绑定事件
function setAllChecked(){
    var chbs=document.getElementsByName("chb[]");
    if(ld('#checkAll').prop("checked")){
        for(var i=0;i<chbs.length;i++){     
          chbs[i].checked=true;
        }
    }
    else{
        for(var i=0;i<chbs.length;i++){     
          chbs[i].checked=false;          
        }
    }
}

//为主营品类型多选框绑定事件
function setChecked(obj){
    var status = 'yes';
    var chbs=document.getElementsByName("chb[]");
    for(var i=0;i<chbs.length;i++){     
      if(chbs[i].checked == false){
        status = 'no';
        break;
      }           
    }
    if(status == 'yes'){
        ld("#checkAll").prop("checked",true);
    }
    else{
        ld("#checkAll").prop("checked",false);
    }
}

//为大巴车类型全选框绑定事件
function setAllChecked2(){
    var chbs=document.getElementsByName("chb2[]");
    if(ld('#checkAll2').prop("checked")){
        for(var i=0;i<chbs.length;i++){     
          chbs[i].checked=true;
        }
    }
    else{
        for(var i=0;i<chbs.length;i++){     
          chbs[i].checked=false;          
        }
    }
}

//为大巴车类型多选框绑定事件
function setChecked2(obj){
    var status = 'yes';
    var chbs=document.getElementsByName("chb2[]");
    for(var i=0;i<chbs.length;i++){     
      if(chbs[i].checked == false){
        status = 'no';
        break;
      }           
    }
    if(status == 'yes'){
        ld("#checkAll2").prop("checked",true);
    }
    else{
        ld("#checkAll2").prop("checked",false);
    }
}


