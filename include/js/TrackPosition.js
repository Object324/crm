function TrackPosition()
{
    var that=this;
    this.init=function(containerid){
        this.containerid=containerid;	
        if(this.mapobj== undefined){
			var lat='39.984104';
			var lng='116.307503';
			this.mapobj = new TMap.Map(that.containerid, {
				center: new TMap.LatLng(lat, lng),//地图显示中心点
				zoom:12, //缩放级别
                baseMap: {			//底图设置（参数为：VectorBaseMap对象）
                    type: 'vector',	//类型：失量底图
                    features: ['base', 'building2d','arrow','label','point']
                }
			});
		}
    }
    this.draw=function(trackposition_arr){
        if(trackposition_arr==undefined)
            return ;


        //清空地图标记
        this.clearmap();

        if(trackposition_arr.length>0)
        {
            var lat=trackposition_arr[0].lat;
            var lng=trackposition_arr[0].lng;
            this.mapobj.setCenter(new TMap.LatLng(lat,lng));
            //根据地址信息计算需要的缩放比例
            this.setzoomlevel(trackposition_arr);
        }


        var arr=[];
        var rowindex=1;
        var geometries_arr=[];
        var address_arr=[];
        var createdtime_arr=[];
        var len=trackposition_arr.length;

        var step=2;
        var polyArray=[];
        for(var i=0;i<len;i++)
        {


            var j=0;
            while(j<step&&i<len)
            {
                arr.push([trackposition_arr[i].lat,trackposition_arr[i].lng])
                address_arr.push(trackposition_arr[i].address);
                createdtime_arr.push(trackposition_arr[i].createdtime);
                i++;
                j++;

            }
            if(i>=len)
            {
                break;
            }
            i--;
            i--;
            geometries_arr.push(that.setgeometries(arr,rowindex, address_arr,createdtime_arr))


            arr=[];
            polyArray=[];
            rowindex++;
            address_arr=[];
            createdtime_arr=[];

        }


        if(polyArray.length>0)
        {
            if(address_arr.length==0)
            {
                address_arr[1]='';
                createdtime_arr[1]='';
            }
            geometries_arr.push(that.setgeometries(arr,rowindex, address_arr,createdtime_arr))
        }
        if(this.polylineLayer == undefined){
			var polylineLayer = new TMap.MultiPolyline({
				id: 'polyline-layer', //图层唯一标识
				map: that.mapobj,//设置折线图层显示到哪个地图实例中
				//折线样式定义
				styles: {
					'style_blue': new TMap.PolylineStyle({
						'color': '#3777FF', //线填充色
						'width': 10, //折线宽度
						'borderWidth': 1, //边线宽度
						'borderColor': '#FFF', //边线颜色
						'lineCap': 'butt', //线端头方式
						'showArrow':true
					}),
					'style_red': new TMap.PolylineStyle({
						'color': '#CC0000', //线填充色
						'width': 10, //折线宽度
						'borderWidth': 1, //边线宽度
						'borderColor': '#CCC', //边线颜色
						'lineCap': 'round' ,//线端头方式
						'showArrow':true
					}),
					'style_golden': new TMap.PolylineStyle({
						'color': '#CC9900', //线填充色
						'width': 10, //折线宽度
						'borderWidth': 1, //边线宽度
						'borderColor': '#CCC', //边线颜色
						'lineCap': 'round' ,//线端头方式
						'showArrow':true
					})
				},
				//折线数据定义
				geometries: geometries_arr
			});
			this.polylineLayer = polylineLayer;
		}else{
			this.polylineLayer.setGeometries(geometries_arr);
		}
        that.curlat='';
        that.curlng='';
        that.mapobj.on("click",function(evt){
            that.curlat = evt.latLng.getLat().toFixed(6);
            that.curlng = evt.latLng.getLng().toFixed(6);

            if(that.islineclick)
            {
                if(that.lineinfo!=undefined)
                {
                    var infoWindowLocation = new TMap.LatLng(that.curlat,that.curlng);//创建一个坐标
                    var contenthtml="";
                    if(that.lineinfo.properties.address_start=='')
                    {
                            contenthtml="<div style='text-align: left;line-height: 24px;'>地址："+that.lineinfo.properties.address_start+"</div>" +
                                "<div style='text-align: left;line-height: 24px;'>时间："+that.lineinfo.properties.time_start+"</div>";
                    }
                    else{

                        contenthtml="<div style='text-align: left;line-height: 24px;'>起始地址："+that.lineinfo.properties.address_start+"</div>" +
                            "<div style='text-align: left;line-height: 24px;'>结束地址："+that.lineinfo.properties.address_end+"</div>"+
                            "<div style='text-align: left;line-height: 24px;'>起始时间："+that.lineinfo.properties.time_start+"</div>"+
                            "<div style='text-align: left;line-height: 24px;'>结束时间："+that.lineinfo.properties.time_end+"</div>"
                    }
                    if(that.infowindow == undefined){
                        var infoWindow = new TMap.InfoWindow({
                            map: that.mapobj,
                            position: infoWindowLocation,
                            content:contenthtml
                        });
                        that.infowindow = infoWindow;
                    }else{
						that.infowindow.open()
                        that.infowindow.setContent(contenthtml);
                        that.infowindow.setPosition(infoWindowLocation);
                    }



                }
                that.islineclick=false;
            }
        })
        this.polylineLayer.on('click', function (res) {
            that.islineclick=true;
            var res = res && res.geometry;
            that.lineinfo=undefined;
            if (res) {
                that.lineinfo=res;

            }
        });
        
    }
    this.drawpoint = function (locationinfo) {

        if(!empty(locationinfo.lat)){
            var center_lat = locationinfo.lat;
            var center_lng = locationinfo.lng;
        }else{
            var center_lat = 31.247788;
            var center_lng = 121.548513;
        }
        //清空地图标记
        this.clearmap();

        this.mapobj.setCenter(new TMap.LatLng(center_lat,center_lng));
        this.mapobj.setZoom(12);


        var content='<div style="width:300px;text-align: left;"><div style="display:flex;align-items: center;">' +
            '<div style="background-image: url('+locationinfo.imageurl+');width:36px;height:36px;background-size:100% 100%;border-radius: 100%;"></div>'+
            '<div style="color: #555;font-size: 16px;padding-left:8px;">'+locationinfo.last_name+'</div>'+
            ' </div>' +
			'<div style="display: flex;" >' +
            '<div style="flex:1">' +
			'<div style="padding: 4px 0;max-width: 250px;overflow-wrap: break-word;white-space: normal;">定位地址：'+locationinfo.address+'</div>'+
            '<div style="padding: 4px 0;">定位时间：'+locationinfo.createdtime+'</div>'+
			'</div>' +
			'<div style="display: flex;flex-direction: column;">' +
			'<div class="track_position_changemap_left_icon" style="height: 36px;width: 36px;cursor: pointer;" onclick="TrackLocationMap.changeMap(\'showtrack\','+locationinfo.tmpuserid+')" ></div>'+
			'<div style="padding: 0 5px;" >足迹</div>'+
			' </div>' +
			' </div>' +
            ' </div> ';

        if(!empty(locationinfo.lat)){
            //创建一个自定义的infoWindow
            var myIW = new TMap.InfoWindow({
                map:that.mapobj,
                position: new TMap.LatLng(locationinfo.lat, locationinfo.lng),
                content:content
            })
            this.infowindow = myIW;
        }


        //两秒钟后更新文字内容
        setInterval(function(){
            ldAjaxNoProgress("index.php?module=TrackLocationMap&action=TrackLocationMapAjax&file=ShowLocationPosition&getpoisiont=yes&userid="+userid,{},function(ajaxdata){

                that.mapobj.setCenter(new TMap.LatLng(ajaxdata.result.info.lat,ajaxdata.result.info.lng));
            })

        },1000*60*2);
    }

    this.setgeometries=function(arr,rowindex,address_arr,time_arr){
        var geometries_arr={};
        polyArray = arr.map(p => {
            return new TMap.LatLng(p[0], p[1]);
        });

        if(rowindex%3==0 &&rowindex%2!=0)
        {

            geometries_arr.styleId='style_golden';

        }
        else if(rowindex%2==0)
            geometries_arr.styleId='style_blue';//绑定样式名

        else
        {

            geometries_arr.styleId='style_red';//绑定样式名
        }

        var len=geometries_arr.length;
        geometries_arr.id="pl_"+rowindex;
        geometries_arr.paths=polyArray;
        geometries_arr.properties= {
            'address_start':address_arr[0],
                'address_end':address_arr[1],
                'time_start':time_arr[0],
                'time_end':time_arr[1]
        };

        return geometries_arr;
    }
    this.setzoomlevel = function(trackposition_arr){

        var first_map_lat = 31.247788;
        var first_map_lng = 121.548513;
        var zoom_level;
        var distance = 0;
        var get_center = 'no';
        if(trackposition_arr[0] != null){
            for(var i = 0; i <trackposition_arr.length; i++){
                var _lat = trackposition_arr[i]['lat'];
                var _lng = trackposition_arr[i]['lng'];
                if(empty(_lat)||empty(_lng)){
                    continue;
                }
                if(get_center == 'no'){
                    first_map_lat = _lat;
                    first_map_lng = _lng;
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
		
		//根据距离显示缩放比例的效果不太好，先不用
		zoom_level = 16;
        this.mapobj.setZoom(zoom_level);
    }

    this.clearmap = function () {
        if(this.polylineLayer != undefined){
			this.polylineLayer.setGeometries([]);
		}
            
        if(this.infowindow != undefined){
            this.infowindow.close();
        }
    }
}
TrackPosition.staticobj = '';
TrackPosition.getInstance=function(){
    if(empty(TrackPosition.staticobj)){
        TrackPosition.staticobj=new TrackPosition();
    }

    return TrackPosition.staticobj;
}

