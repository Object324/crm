function Lingdang_Map(mapid)
{
    this.mapid=mapid;
  
   
}
Lingdang_Map.prototype.show_map=function(map_center_lng,map_center_lat)
{
      this.map_center_lng=map_center_lng;
      this.map_center_lat=map_center_lat;
      this.map = new BMap.Map(this.mapid);
	  var point = new BMap.Point(map_center_lng, map_center_lat);
	  this.map.centerAndZoom(point,13);
      
      //this.map.enableScrollWheelZoom(true);
     // 添加带有定位的导航控件
      var navigationControl = new BMap.NavigationControl({
        // 靠左上角位置
        anchor: BMAP_ANCHOR_TOP_LEFT,
        // LARGE类型
        type: BMAP_NAVIGATION_CONTROL_LARGE,
        // 启用显示定位
        enableGeolocation: true
      });
     this.map.addControl(navigationControl);
     this.map.addControl(new BMap.OverviewMapControl());

}
Lingdang_Map.prototype.clearOverlay=function()
{
    this.map.clearOverlays();
}
Lingdang_Map.prototype.setTrackReport=function(pointjson)
{
     this.clearOverlay();
    this.pointjson=pointjson;
    this.pointobj=pointjson;
  
    var map_points=[];
    var prev_i=0;
    for(var i=0 ;i<this.pointobj.length-1;i++)
    {
         
        var obj_point_one=new BMap.Point(this.pointobj[i].lng,this.pointobj[i].lat);
      
        var obj_point_two=new BMap.Point(this.pointobj[i+1].lng,this.pointobj[i+1].lat);
       // var obj_point_three=new BMap.Point(this.pointobj[i+2].lng,this.pointobj[i+2].lat);
       
        var polyline = new BMap.Polyline([obj_point_one,obj_point_two], {strokeColor:"#3D75E6", strokeWeight:4, strokeOpacity:1}); 
   	    this.map.addOverlay(polyline); 
       
        var dot_myIcon = new BMap.Icon("themes/softed/images/map_dot_ico.png", new BMap.Size(10,10));
   	    var marker = new BMap.Marker(obj_point_two,{icon:dot_myIcon});  // 创建标注
        this.map.addOverlay(marker);
        marker.pointinfo=this.pointobj[i+1];
            
        marker.addEventListener("click", function(){
                
                alert("地址："+this.pointinfo.address+"\n日期："+this.pointinfo.createdtime);
            });
  
        map_points[i]=obj_point_one;
    }
    //var myIcon = new BMap.Icon("http://api.map.baidu.com/img/dest_markers.png",new BMap.Size(28, 32),  {     offset: new BMap.Size(10, 25),  imageOffset: new BMap.Size(0, 0)  });    
// var myIcon2 = new BMap.Icon("http://api.map.baidu.com/img/dest_markers.png",new BMap.Size(28, 32),  {     offset: new BMap.Size(-150, -205),  imageOffset: new BMap.Size(0, -34)  });
   
    map_points[i]=new BMap.Point(this.pointobj[i].lng,this.pointobj[i].lat);;
  
    var obj_point_start=new BMap.Point(this.pointobj[0].lng,this.pointobj[0].lat);
    var start_myIcon = new BMap.Icon("themes/softed/images/icon_st.png", new BMap.Size(30,36));
    var start_marker = new BMap.Marker(obj_point_start,{icon:start_myIcon});  // 创建标注
    this.map.addOverlay(start_marker);
    start_marker.pointinfo=this.pointobj[0];
    start_marker.addEventListener("click", function(){
                
                alert("地址："+this.pointinfo.address+"\n日期："+this.pointinfo.createdtime);
            });
            
     var end_myIcon = new BMap.Icon("themes/softed/images/icon_en.png", new BMap.Size(30,36));
     var  obj_point_end=new BMap.Point(this.pointobj[this.pointobj.length-1].lng,this.pointobj[this.pointobj.length-1].lat);
     var  end_marker = new BMap.Marker(obj_point_end,{icon:end_myIcon});  // 创建标注
     end_marker.pointinfo=this.pointobj[this.pointobj.length-1];
     end_marker.addEventListener("click", function(){
                
                alert("地址："+this.pointinfo.address+"\n日期："+this.pointinfo.createdtime);
            });
     this.map.addOverlay(end_marker);
    
     var cur_this=this;
     cur_this.map.setViewport(map_points);          //调整到最佳视野
     
    
     var lushu = new BMapLib.LuShu(cur_this.map, map_points, {
        defaultContent: "",
        speed: 500,
        autoView: true, //是否开启自动视野调整，如果开启那么路书在运动过程中会根据视野自动调整
        icon: new BMap.Icon('themes/softed/images/Mario.png', new BMap.Size(32, 32), { anchor: new BMap.Size(32, 32) }),
        enableRotation: false, //是否设置marker随着道路的走向进行旋转
        landmarkPois: []
    });    

    lushu.start();
    
}



Lingdang_Map.prototype.setMarker_Rotation=function(marker,points)
{
    if(points.length > 1) {
        var curIndex = points.length - 1;
        var curPoint = points[curIndex];
        var lastPoint = points[curIndex - 1];
        var distance = this.map.getDistance(lastPoint, curPoint);
        
        if(curPoint.lng - lastPoint.lng > 0 && curPoint.lat - lastPoint.lat >= 0) {
                var distanceX = this.map.getDistance(lastPoint, new BMap.Point(curPoint.lng, lastPoint.lat));
                marker.setRotation(0 + Math.asin(distanceX / distance) / (Math.PI / 2) * 90);
        } else if(curPoint.lng - lastPoint.lng >= 0 && curPoint.lat - lastPoint.lat < 0) {
                var distanceY = this.map.getDistance(lastPoint, new BMap.Point(lastPoint.lng, curPoint.lat));
                marker.setRotation(90 + Math.asin(distanceY / distance) / (Math.PI / 2) * 90);
        } else if(curPoint.lng - lastPoint.lng < 0 && curPoint.lat - lastPoint.lat <= 0) {
                var distanceX = this.map.getDistance(lastPoint, new BMap.Point(curPoint.lng, lastPoint.lat));
                marker.setRotation(180 + Math.asin(distanceX / distance) / (Math.PI / 2) * 90);
        } else {
                var distanceY = this.map.getDistance(lastPoint, new BMap.Point(lastPoint.lng, curPoint.lat));
                marker.setRotation(270 + Math.asin(distanceY / distance) / (Math.PI / 2) * 90);
        }
    }
}