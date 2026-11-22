function SigninTrackMap_old(){
    var that=this;
    this.ue = '';
    this.init=function(){
        
    }
    this.create_signin_track_map = function(){
        //重设地图高度
        var box_height = ld('.main_grid_box').height();
        var header_height = ld('.grid-analysis-header').height();
        var map_height = box_height-header_height;
        ld("[name=map_div_signin]").css('height',map_height);
        var signin_info_json = ld("[name=signin_info]").val();
        if(signin_info_json!=''){
            var signin_info = eval('(' + signin_info_json + ')') ? eval('(' + signin_info_json + ')') : JSON.parse(signin_info_json);
        }
        var InfoWindow = null;
    	var popupobj=CrmPopup.getPopupObj("last");
    	var divid=popupobj.divid;
        var first_map_lat = 31.247788;
        var first_map_lng = 121.548513;
        var zoom_level;      
        var distance = 0;
        var get_center = 'no';
        if(signin_info[0] != null){ 
            for(var i = 0; i <signin_info.length; i++){
                var _lat = signin_info[i]['latitude'];
                var _lng = signin_info[i]['longtitude'];
                if(empty(_lat)||empty(_lng)){
                    continue;
                }
                if(get_center == 'no'){ //默认使用第一点作为中心点
                    var first_map_lat = _lat;
                    var first_map_lng = _lng;
                    get_center = 'yes';
                }
                var cur_distance = this.getDistancebetweenlatlng(first_map_lat, first_map_lng, _lat, _lng);//计算距离
                if(cur_distance>distance){
                    distance = cur_distance;
                }
            }
        }
        
        if(distance>500000){
            zoom_level = 3;
        }else if(distance>200000){
            zoom_level = 4;
        }else if(distance >100000){
            zoom_level = 5;
        }else if(distance >50000){
            zoom_level = 6;
        }else if(distance >30000){
            zoom_level = 7;
        }else if(distance >20000){
            zoom_level = 8;
        }else if(distance >10000){
            zoom_level = 9;
        }else if(distance>5000){
            zoom_level=10;
        }else if(distance>2000){
            zoom_level=11;
        }else if(distance>1000){
            zoom_level=12;
        }else if(distance>500){
            zoom_level=13;
        }else{
            zoom_level=14;
        }
        zoom_level+= 2;   
    
    	account_center = new qq.maps.LatLng(first_map_lat,first_map_lng);
    	//定义map变量 调用 qq.maps.Map() 构造函数   获取地图显示容器
    	account_map = new qq.maps.Map(ld("[name=map_div_signin]")[0], {
    		center: account_center,      // 地图的中心地理坐标
    		zoom:zoom_level,             // 地图的缩放级别
    		disableDefaultUI: true
    	});
        
        this.mapobj = account_map;
        if(signin_info[0]!=null){  
            this.show_signin_point(signin_info);
        }
    }
    this.show_signin_point = function(signin_info){
        InfoWindow = new qq.maps.InfoWindow({ 
            map: this.mapobj
        });//添加提示窗
        var content_arr = new Array();
        var logingo_arr = new Array();
        var i = 0;
        var k = 0;
        var tmp_key = '';
        var key = 0;
        for(i = 0;i<signin_info.length;i++){
            
    		var _name = '';	//成员姓名
    		var _lat = '';
    		var _lng = '';
            var signin_time = '';//签到时间
            for(fieldname in signin_info[i]){
    			if(fieldname == 'oftenusereport_last_name'){
    				_name = signin_info[i][fieldname];
    			}else if(fieldname == 'latitude'){
    				_lat = signin_info[i][fieldname];
    			}else if(fieldname == 'longtitude'){
    				_lng = signin_info[i][fieldname];
    			}else if(fieldname == 'oftenusereport_createdtime'){
                    signin_time = arrJsPopLabel['SIGNTIMEJS']+'：' + signin_info[i][fieldname] + '<br>';
    			}
            }
            if(empty(_lat)||empty(_lng)){
                continue;
            }
    		//***将必要的数据存入数组
    		var j = k+1;
    		var mark_id = j;
    		var mark_name = _name;
            //
            var mark_aobj = arrJsPopLabel['VISITORS']+'：' + '<a referencemodule="'+signin_info[i].oftenusereport_module+'" referencerecord="'+signin_info[i].oftenusereport_record+
        '" onclick="ListReferenceLinkClick(ld(this),event)"  title="'+signin_info[i].oftenusereport_entityname+'" >'+signin_info[i].oftenusereport_entityname+'</a><br>';
            var mark_rotation = signin_time;
            var mark_signin_place = arrJsPopLabel['SINGINADDRESSJS']+'：<a onclick="change_map_center_basic('+signin_info[i].latitude+','+signin_info[i].longtitude+')">'  + signin_info[i].oftenusereport_address+ '</a><br>';
    		
            var mark_allcontent = '<div style="width:320px;">' +
    				'<div style="font-size: 14px;font-weight: bold;color: #333;padding-bottom: 5px;">'+mark_name +'</div>' +
                    '<div style="font-size: 12px;color: #999;">'+ mark_aobj +'</div>' +
    				'<div style="font-size: 12px;color: #999;">'+ mark_rotation +'</div>' +
                    '<div style="font-size: 12px;color: #999;">'+ mark_signin_place +'</div>' +
    				'</div>';
                    
            tmp_info = {'lat':_lat,'lng':_lng};
            tmp_info['count'] = 1;
            tmp_info['userid'] = signin_info[i]['oftenusereport_userid'];
            tmp_info['content'] = '';
            
            var loginfo_str = _lat+','+_lng;
            if(logingo_arr.indexOf(loginfo_str) != -1){
                key = logingo_arr.indexOf(loginfo_str);
                content_arr[key]['count'] += 1;
                content_arr[key]['content'] += mark_allcontent;                    
            }else{
                logingo_arr.push(loginfo_str);
                key = logingo_arr.indexOf(loginfo_str);
                tmp_info['content']+= mark_allcontent;     
                content_arr.push(tmp_info);   
            }
            
    		k++;
        }
        this.make_signin_marker(content_arr);//hjz 数组中存了标签和次数，创建每一个对应的marker对象
        
    }
    
    this.make_signin_marker = function(content_arr){
        var icon_src = '';
        var _lat;
        var _lng;
        var _userid;
        var base_url = 'themes/images/sign_in_track/';
        var icon_count = 0;
        var icon_count_limit = 10; //图标类型数量
        var userid_arr = new Array();
        for(var key = 0;key<content_arr.length;key++){
            _lat = content_arr[key]['lat'];
            _lng = content_arr[key]['lng'];
            if(content_arr[key]['count']>10){ //控制多个点重叠时，图标显示数字
                icon_src = base_url+'10-11.png';
            }else if(content_arr[key]['count']>1){
                icon_src = base_url+'10-'+(content_arr[key]['count']-1)+'.png';
            }else if(content_arr[key]['count'] == 1){
                _userid = content_arr[key]['userid'];
                icon_count = parseInt(_userid)%10+1;//控制图标类型跟userid关联，保证颜色变化的同时，相同的人图标颜色相同
                icon_src = base_url+icon_count+'.png';
            }else{
                continue;
            }//
//            icon_count = 5;
//            icon_src = base_url+icon_count+'.png';
            marker = new qq.maps.Marker({
                position: new qq.maps.LatLng(_lat,_lng),
                map: that.mapobj,
                icon:new qq.maps.MarkerImage(icon_src)
            });
            marker.allcontent = '<div style="width:350px;max-height:174px;overflow-y:auto;"><div style="position: absolute;right:20px;top:0px;">'+arrJsPopLabel['ATOTALOF']+content_arr[key]['count']+arrJsPopLabel['RECORDS']+'</div>' + content_arr[key]['content']+'</div>';
            
            qq.maps.event.addListener(marker, 'mouseover', function(event){//获取标记的点击事件
    			InfoWindow.open();//点击标记打开提示窗
    
    			var content = event.target.allcontent;
                InfoWindow.setContent(content);
    			InfoWindow.setPosition(new qq.maps.LatLng(event.latLng.getLat(), event.latLng.getLng()));//提示窗位置
    			setTimeout(function(){
    				InfoWindow.close();
    			}, 20 * 1000);
    		});
        }
    }
    
    this.change_map_center=function(_lat,_lng){//hjz 重新定位中心点
    	account_center = new qq.maps.LatLng(_lat,_lng);
    	this.mapobj.setCenter(account_center);
        this.mapobj.setZoom(16);
    }
    
    this.getDistancebetweenlatlng=function(lat1, lng1, lat2, lng2) {//hjz 计算各签到点的距离 选择适合的缩放大小
        var radLat1 = lat1 * Math.PI / 180.0;
        var radLat2 = lat2 * Math.PI / 180.0;
        var a = radLat1 - radLat2;
        var b = lng1 * Math.PI / 180.0 - lng2 * Math.PI / 180.0;
        var distance = 2 * Math.asin(Math.sqrt(Math.pow(Math.sin(a / 2), 2) + Math.cos(radLat1) * Math.cos(radLat2) * Math.pow(Math.sin(b / 2), 2)));
        distance = distance * 6378.137;
        distance = Math.round(distance * 1000);
        return distance;
    }
    
    this.update_signin_track_map = function(signin_info_json){
        //重设地图高度
        var signin_info = [];
        if(signin_info_json!=''){
            var signin_info = eval('(' + signin_info_json + ')') ? eval('(' + signin_info_json + ')') : JSON.parse(signin_info_json);
        }
        var InfoWindow = null;
    	var popupobj=CrmPopup.getPopupObj("last");
    	var divid=popupobj.divid;
        var first_map_lat = 31.247788;
        var first_map_lng = 121.548513;
        var zoom_level;      
        var distance = 0;
        var get_center = 'no';
        if(signin_info[0] != null){ 
            for(var i = 0; i <signin_info.length; i++){
                var _lat = signin_info[i]['latitude'];
                var _lng = signin_info[i]['longtitude'];
                if(empty(_lat)||empty(_lng)){
                    continue;
                }
                if(get_center == 'no'){
                    var first_map_lat = _lat;
                    var first_map_lng = _lng;
                    get_center = 'yes';
                }
                var cur_distance = this.getDistancebetweenlatlng(first_map_lat, first_map_lng, _lat, _lng);//计算距离
                if(cur_distance>distance){
                    distance = cur_distance;
                }
            }
        }
        if(distance>500000){
            zoom_level = 3;
        }else if(distance>200000){
            zoom_level = 4;
        }else if(distance >100000){
            zoom_level = 5;
        }else if(distance >50000){
            zoom_level = 6;
        }else if(distance >30000){
            zoom_level = 7;
        }else if(distance >20000){
            zoom_level = 8;
        }else if(distance >10000){
            zoom_level = 9;
        }else if(distance>5000){
            zoom_level=10;
        }else if(distance>2000){
            zoom_level=11;
        }else if(distance>1000){
            zoom_level=12;
        }else if(distance>500){
            zoom_level=13;
        }else{
            zoom_level=14;
        }
        zoom_level+= 2; 
    
    	account_center = new qq.maps.LatLng(first_map_lat,first_map_lng);
    	//定义map变量 调用 qq.maps.Map() 构造函数   获取地图显示容器
    	account_map = new qq.maps.Map(ld("[name=map_div_signin]")[0], {
    		center: account_center,      // 地图的中心地理坐标
    		zoom:zoom_level,             // 地图的缩放级别
    		disableDefaultUI: true
    	});
        
        this.mapobj = account_map;
        if(signin_info[0]!=null){  
            this.show_signin_point(signin_info);
        }
    }
}


function SigninTrackMap_new(){
    var that=this;
    this.ue = '';
    this.markerLayer_arr = [];
    this.init=function(){
        
    }
    this.create_signin_track_map = function(signin_info_json){
        //重设地图高度
        var box_height = ld('.main_grid_box').height();
        var header_height = ld('.grid-analysis-header').height();
        var map_height = box_height-header_height;
        ld("[name=map_div_signin]").css('height',map_height);
        var signin_info = [];
        if(signin_info_json != undefined && signin_info_json!=''){
            var signin_info = eval('(' + signin_info_json + ')') ? eval('(' + signin_info_json + ')') : JSON.parse(signin_info_json);
        }
        var InfoWindow = null;
    	var popupobj=CrmPopup.getPopupObj("last");
    	var divid=popupobj.divid;
        var first_map_lat = 31.247788;
        var first_map_lng = 121.548513;
        var zoom_level;      
        var distance = 0;
        var get_center = 'no';
        if(signin_info[0] != null){ 
            for(var i = 0; i <signin_info.length; i++){
                var _lat = signin_info[i]['latitude'];
                var _lng = signin_info[i]['longtitude'];
                if(empty(_lat)||empty(_lng)){
                    continue;
                }
                if(get_center == 'no'){
                    var first_map_lat = _lat;
                    var first_map_lng = _lng;
                    get_center = 'yes';
                }
                var startPoint = new TMap.LatLng(_lat,_lng);
                var endPoint= new TMap.LatLng(first_map_lat,first_map_lng);
                var path = [startPoint , endPoint]
                // 计算路径的实际距离
                var cur_distance = TMap.geometry.computeDistance(path);
                if(cur_distance>distance){
                    distance = cur_distance;
                }
            }
        }
        if(distance>500000){
            zoom_level = 3;
        }else if(distance>200000){
            zoom_level = 4;
        }else if(distance >100000){
            zoom_level = 5;
        }else if(distance >50000){
            zoom_level = 6;
        }else if(distance >30000){
            zoom_level = 7;
        }else if(distance >20000){
            zoom_level = 8;
        }else if(distance >10000){
            zoom_level = 9;
        }else if(distance>5000){
            zoom_level=10;
        }else if(distance>2000){
            zoom_level=11;
        }else if(distance>1000){
            zoom_level=12;
        }else if(distance>500){
            zoom_level=13;
        }else{
            zoom_level=14;
        }
        zoom_level+= 2;
        //定义地图中心点坐标
        var center=new TMap.LatLng(first_map_lat,first_map_lng)
        //定义map变量，调用 TMap.Map() 构造函数创建地图
        var map = new TMap.Map(ld("[name=map_div_signin]")[0], {
            center: center,//设置地图中心点坐标
            zoom:zoom_level,   //设置地图缩放级别
        });
        this.mapobj = map;
        
        if(signin_info[0]!=null){  
            this.show_signin_point(signin_info);
        }
    }
    this.show_signin_point = function(signin_info){
        var content_arr = new Array();
        var logingo_arr = new Array();
        var i = 0;
        var k = 0;
        var tmp_key = '';
        var key = 0;
        var polyArray = [];
        for(i = 0;i<signin_info.length;i++){
    		var _name = '';	//成员姓名
    		var _lat = '';
    		var _lng = '';
            var signin_time = '';//签到时间
            for(fieldname in signin_info[i]){
    			if(fieldname == 'oftenusereport_last_name'){
    				_name = signin_info[i][fieldname];
    			}else if(fieldname == 'latitude'){
    				_lat = signin_info[i][fieldname];
    			}else if(fieldname == 'longtitude'){
    				_lng = signin_info[i][fieldname];
    			}else if(fieldname == 'oftenusereport_createdtime'){
                    signin_time = arrJsPopLabel['SIGNTIMEJS']+'：' + signin_info[i][fieldname] + '<br>';
    			}
            }
            if(empty(_lat)||empty(_lng)){
                continue;
            }
    		//***将必要的数据存入数组
    		var j = k+1;
    		var mark_id = j;
    		var mark_name = _name;
            
            var mark_aobj = arrJsPopLabel['VISITORS']+'：' + '<a referencemodule="'+signin_info[i].oftenusereport_module+'" referencerecord="'+signin_info[i].oftenusereport_record+
        '" onclick="ListReferenceLinkClick(ld(this),event)"  title="'+signin_info[i].oftenusereport_entityname+'" >'+signin_info[i].oftenusereport_entityname+'</a><br>';
            var mark_rotation = signin_time;
            var mark_signin_place = arrJsPopLabel['SINGINADDRESSJS']+'：<a onclick="change_map_center_basic('+signin_info[i].latitude+','+signin_info[i].longtitude+')">'  + signin_info[i].oftenusereport_address+ '</a><br>';
    		
            var mark_allcontent = '<div style="width:320px;">' +
    				'<div style="font-size: 14px;font-weight: bold;color: #333;padding-bottom: 5px;">'+mark_name +'</div>' +
                    '<div style="font-size: 12px;color: #999;">'+ mark_aobj +'</div>' +
    				'<div style="font-size: 12px;color: #999;">'+ mark_rotation +'</div>' +
                    '<div style="font-size: 12px;color: #999;">'+ mark_signin_place +'</div>' +
    				'</div>';
                    
            tmp_info = {'lat':_lat,'lng':_lng};
            tmp_info['count'] = 1;
            tmp_info['userid'] = signin_info[i]['oftenusereport_userid'];
            tmp_info['content'] = '';
            
            var loginfo_str = _lat+','+_lng;
            if(logingo_arr.indexOf(loginfo_str) != -1){
                key = logingo_arr.indexOf(loginfo_str);
                content_arr[key]['count'] += 1;
                content_arr[key]['content'] += mark_allcontent;                    
            }else{
                logingo_arr.push(loginfo_str);
                key = logingo_arr.indexOf(loginfo_str);
                tmp_info['content']+= mark_allcontent;     
                content_arr.push(tmp_info);   
            }
    		k++;
            polyArray.push(new TMap.LatLng(_lat,_lng));
        
        }
        this.make_signin_marker(content_arr,polyArray);//hjz 数组中存了标签和次数，创建每一个对应的marker对象
        
        
    }
    
    this.make_signin_marker = function(content_arr,polyArray){
        var icon_src = '';
        var _lat;
        var _lng;
        var _userid;
        var base_url = 'themes/images/sign_in_track/';
        var icon_count = 0;
        var icon_count_limit = 10; //图标类型数量
        var userid_arr = new Array();
        if(!empty(that.infoWindowobj)){
            
        }else{
            var infoWindow = new TMap.InfoWindow({
                map: that.mapobj,
                position: new TMap.LatLng(39.984104,116.307503),
                offset: { x: 0, y: -32 } //设置信息窗相对position偏移像素，为了使其显示在Marker的上方
            });
            that.infoWindowobj = infoWindow;
        }
        
        that.infoWindowobj.close();
        var round_icon = 10;
        var prev_icon_src = '';
        this.markerLayer_arr = [];
        var pre_size = size;
        var size = 20;
        
        var markerLayer = new TMap.MultiMarker({
            map: that.mapobj,  //指定地图容器
            //样式定义
            styles: {
                //创建一个styleId为"myStyle"的样式（styles的子属性名即为styleId）
                "myStyle": new TMap.MarkerStyle({ 
                    "width": 25,  // 点标记样式宽度（像素）
                    "height": 35, // 点标记样式高度（像素）
                    "src":base_url+'1.png',  //图片路径
                    //焦点在图片中的像素位置，一般大头针类似形式的图片以针尖位置做为焦点，圆形点以圆心位置为焦点
                    "anchor": { x: 16, y: 32 }  
                }) 
            }
        });
        this.markerLayer_arr.push(markerLayer);
        
        for(var key = 0;key<content_arr.length;key++){
            _lat = content_arr[key]['lat'];
            _lng = content_arr[key]['lng'];
            if(content_arr[key]['count']>10){
                icon_src = base_url+'10-11.png';
            }else if(content_arr[key]['count']>1){
                icon_src = base_url+'10-'+(content_arr[key]['count']-1)+'.png';
            }else if(content_arr[key]['count'] == 1){
                _userid = content_arr[key]['userid'];
                icon_count = parseInt(_userid)%10+1;
                icon_src = base_url+icon_count+'.png';
            }else{
                continue;
            }
            icon_count = 5;
            icon_src = base_url+icon_count+'.png';
            
            if(key >100){
                size = 15;
            }
            
            
            if( prev_icon_src=='' || prev_icon_src !=icon_src || size != pre_size ){
                 markerLayer = new TMap.MultiMarker({
                    map: that.mapobj,  //指定地图容器
                    //样式定义
                    styles: {
                        //创建一个styleId为"myStyle"的样式（styles的子属性名即为styleId）
                        "myStyle": new TMap.MarkerStyle({ 
                            "width": 25,  // 点标记样式宽度（像素）
                            "height": 35, // 点标记样式高度（像素）
                            "src":icon_src,  //图片路径
                            //焦点在图片中的像素位置，一般大头针类似形式的图片以针尖位置做为焦点，圆形点以圆心位置为焦点
                            "anchor": { x: 16, y: 32 }  
                        }),
                        'myStyle_new': new TMap.MarkerStyle({
                          "width": 25, // 宽度
                          "height": 35, // 高度
                          "anchor": { x: 10, y: 32 }, // 锚点位置
                          "src": icon_src,
                          "color": '#fff', // 标注点文本颜色
                          "size": size, // 标注点文本文字大小
                          "offset": { x: 0, y: -5 } // 标注点文本文字基于direction方位的偏移属性
                        })
                    }
                });
                this.markerLayer_arr.push(markerLayer);
            }
            pre_size = size;
            
            var content = '<div style="width:350px;max-height:174px;overflow-y:auto;text-align:left;"><div style="position: absolute;right:20px;top:5px;">'+arrJsPopLabel['ATOTALOF']+content_arr[key]['count']+arrJsPopLabel['RECORDS']+'</div>' + content_arr[key]['content']+'</div>';
            
            var sequence = (key+1)+"";
            markerLayer.add([{
                "id": key,   //点标记唯一标识，后续如果有删除、修改位置等操作，都需要此id
                "styleId": 'myStyle_new',  //指定样式id
                "position": new TMap.LatLng(_lat,_lng),  //点标记坐标位置
                "content":sequence,
                "properties": {//自定义属性
                    "title": content
                    }
                },
            ]);
            
            markerLayer.on("hover", function (evt) {
                //设置infoWindow
                if(evt.geometry != undefined && evt.geometry.position != undefined){
                    that.infoWindowobj.open(); //打开信息窗
                    that.infoWindowobj.setPosition(evt.geometry.position);//设置信息窗位置
                    that.infoWindowobj.setContent(evt.geometry.properties.title.toString());//设置信息窗内容
                }
            })
            
            prev_icon_src = icon_src;
        }
        
        if(polyArray.length>1){ 
            this.display_polyline(polyArray);//创建轨迹
        }
    }
    
    this.change_map_center=function(_lat,_lng){//hjz 重新定位中心点
    	this.mapobj.setCenter(new TMap.LatLng(_lat,_lng));
        this.mapobj.setZoom(16);
    }
    
    this.display_polyline = function(polyArray){
        if(this.tmp_polylineLayer != undefined){
            this.tmp_polylineLayer.setGeometries([{
                        'id': 'pl_1',//折线唯一标识，删除时使用
                        'styleId': 'style_blue',//绑定样式名
                        'paths': polyArray
                    }]);
        }else{
            var polylineLayer = new TMap.MultiPolyline({
                id: 'polyline-layer', //图层唯一标识
                map: that.mapobj,//绘制到目标地图
                //折线样式定义
                styles: {
                        'style_blue': new TMap.PolylineStyle({
                        'color': '#3777FF', //线填充色
                        'width': 6, //折线宽度
                        'borderWidth': 5, //边线宽度
                        'borderColor': '#FFF', //边线颜色
                        'lineCap': 'butt', //线端头方式
                        'showArrow':true
                    })
                },
                //折线数据定义
                geometries: [
                    {
                        'id': 'pl_1',//折线唯一标识，删除时使用
                        'styleId': 'style_blue',//绑定样式名
                        'paths': polyArray
                    }
                ]
            });
            this.tmp_polylineLayer = polylineLayer;
        }
    }
    this.update_signin_track_map = function(signin_info_json){
        var i = 0;
        var dot_length = this.markerLayer_arr.length;
        //重置地图标记和折线
        for(i=0;i<dot_length;i++){
            this.markerLayer_arr[i].setGeometries([]);
        }
        if(this.tmp_polylineLayer != undefined){
            this.tmp_polylineLayer.setGeometries([]);
        }
        
        var signin_info = [];
        if(signin_info_json != undefined && signin_info_json!=''){
            var signin_info = eval('(' + signin_info_json + ')') ? eval('(' + signin_info_json + ')') : JSON.parse(signin_info_json);
        }
        var InfoWindow = null;
    	var popupobj=CrmPopup.getPopupObj("last");
    	var divid=popupobj.divid;
        if(signin_info[0] != null){       
            var first_map_lat = signin_info[0]['latitude'];//如果signin_info中有信息，则用第一个点作为中心点，若没有点以公司地点为中心点
        }else{
            var first_map_lat = 31.247788;
        }
        if(signin_info[0] != null){       
            var first_map_lng = signin_info[0]['longtitude'];
        }else{
            var first_map_lng = 121.548513;
        }
        var zoom_level;      
        var distance = 0;
        var get_center = 'no';
        if(signin_info[0] != null){ 
            for(var i = 0; i <signin_info.length; i++){
                var _lat = signin_info[i]['latitude'];
                var _lng = signin_info[i]['longtitude'];
                if(empty(_lat)||empty(_lng)){
                    continue;
                }
                if(get_center == 'no'){
                    var first_map_lat = _lat;
                    var first_map_lng = _lng;
                    get_center = 'yes';
                }
                var startPoint = new TMap.LatLng(_lat,_lng);
                var endPoint= new TMap.LatLng(first_map_lat,first_map_lng);
                var path = [startPoint , endPoint]
                // 计算路径的实际距离
                var cur_distance = TMap.geometry.computeDistance(path);
                if(cur_distance>distance){
                    distance = cur_distance;
                }
            }
        }
        //根据中心点到其他点的最大距离计算比例尺
        if(distance>0){
            //distance = distance/5;    
        }
        if(distance>500000){
            zoom_level = 3;
        }else if(distance>200000){
            zoom_level = 4;
        }else if(distance >100000){
            zoom_level = 5;
        }else if(distance >50000){
            zoom_level = 6;
        }else if(distance >30000){
            zoom_level = 7;
        }else if(distance >20000){
            zoom_level = 8;
        }else if(distance >10000){
            zoom_level = 9;
        }else if(distance>5000){
            zoom_level=10;
        }else if(distance>2000){
            zoom_level=11;
        }else if(distance>1000){
            zoom_level=12;
        }else if(distance>500){
            zoom_level=13;
        }else{
            zoom_level=14;
        }
        zoom_level+= 2;
        this.mapobj.setCenter(new TMap.LatLng(first_map_lat,first_map_lng));
        this.mapobj.setZoom(zoom_level);
        
        if(signin_info[0]!=null){  
            this.show_signin_point(signin_info);
        }
        
    }
}

//根据浏览器判断使用不同版本的腾讯地图api
function UseTencentMapByexploer(){
    //创建script标签
    var popupobj=CrmPopup.getPopupObj("last");
    if(popupobj.signinmap != undefined && popupobj.signinmap.mapobj != undefined&&popupobj.trickmap == 'yes'){
        initMap_signin_track();
    }else{
        popupobj.trickmap = 'yes';
        var script = document.createElement("script");
    	//设置标签的type属性
    	script.type = "text/javascript";
        var exploer = navigator.userAgent.toLowerCase();
        //火狐浏览器不能使用新版本腾讯地图
        if(exploer.indexOf('firefox')>0){
        	script.src = "https:map.qq.com/api/js?v=2.exp&callback=initMap_signin_track&key=P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X";
        }else{
            script.src = "https:map.qq.com/api/gljs?v=1.exp&key=P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X&callback=initMap_signin_track&libraries=geometry";
        }
        //设置标签的链接地址 
        script.src = "https://map.qq.com/api/gljs?v=1.exp&key=P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X&callback=initMap_signin_track&libraries=geometry";
        //添加标签到dom
       	document.body.appendChild(script);
    }
}


function initMap_signin_track(){
    var popupobj=CrmPopup.getPopupObj("last");
    var exploer = navigator.userAgent.toLowerCase();
    if(exploer.indexOf('firefox')>0){
        var map_obj = new SigninTrackMap_old();
    }else{
        var map_obj = new SigninTrackMap_new();
    }
    popupobj.signinmap = map_obj;
    popupobj.maptype = 'track';
    map_obj.create_signin_track_map();
}
//外部调用对象方法
function change_map_center_basic(_lat,_lng){
    var popupobj=CrmPopup.getPopupObj("last");
    popupobj.signinmap.change_map_center(_lat,_lng);
}
//生成报表时只更新地图，不重新生成地图，不然内存负载很高，电脑会卡
function update_signin_track_map(signin_info_json){
    var popupobj=CrmPopup.getPopupObj("last");
    popupobj.signinmap.update_signin_track_map(signin_info_json);
}
//签到分布表生成地图
function initMap_signin_distribution(){
    //创建script标签
    var popupobj=CrmPopup.getPopupObj("last");
    if(popupobj.signinmap != undefined && popupobj.signinmap.mapobj != undefined && popupobj.distributemap== 'yes'){
        signin_distribution_init();
    }else{
        popupobj.distributemap = 'yes';
        var script = document.createElement("script");
    	//设置标签的type属性
    	script.type = "text/javascript";
        var exploer = navigator.userAgent.toLowerCase();
        script.src = "https://map.qq.com/api/js?v=2.exp&callback=signin_distribution_init&key=P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X";
        //添加标签到dom
       	document.body.appendChild(script);
    }
}
function signin_distribution_init(){
    var popupobj=CrmPopup.getPopupObj("last");
    var map_obj = new SigninTrackMap_old();
    popupobj.signinmap = map_obj;
    map_obj.create_signin_track_map();
}