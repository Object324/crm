function MapCustomer(){
    var map; // 地图
    var editor; // 编辑器
    let circles = []; // 用于跟踪所有绘制的圆形
    let currentCircle; // 用于跟踪当前绘制的圆形

    return {
        template: `
            <div class="mapCustomer">
                <div id="container"></div>
                    <div id="toolControl">
                        <div class="el-input" style="width: 280px;height: 46px;box-shadow: 0px 1px 5px 0px rgba(0,0,0,0.2);">
                            <div class="el-input__wrapper" tabindex="-1" style="padding: 0;">
                                <input id="searchInput" v-model="searchQuery" class="el-input__inner" style="height: 46px;padding: 13px 11px;" type="text" autocomplete="off" tabindex="0" placeholder="输入地址查询附近企业"/>
                            </div>
                        </div>
                        <div class="selectdropdown" v-if="suggestionResult && suggestionResult.length > 0">
                            <ul>
                                <li v-for="item in suggestionResult" @click="selectAddress(item)">
                                    <div class="selectdropdown_companyname">{{item.title}}</div>
                                    <div class="selectdropdown_address">{{item.address}}</div>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
            <el-drawer id="mapcustomer_resultdrawer" class="ld-bg-color ld_drawer" class="ld-bg-color" style="background: #E4E7ED;" v-model="drawer" size="70%" :show-close="false" modal-class="bgfff0">
                <template #header>
                    <div class="ld_drawer_header" style="background: #fff;">
                        <div class="flex" style="height: 62px;padding: 10px 16px;align-items: center;border-bottom: 1px solid #E9E9E9;font-size: 14px;color: #333;" v-if="keyword != ''">
                            <span>当前区域</span>
                            <span style="font-weight: bold;margin: 0 8px;">{{keyword}}</span>
                            <span>附近</span>
                            <el-select v-model="distancevalue" style="width: 90px;margin: 0 8px;text-align: center;" @change="changedistance">
                              <el-option
                                v-for="item in distancelist"
                                :key="item.value"
                                :label="item.label"
                                :value="item.value"
                              />
                            </el-select>
                            <span>内的公司</span>
                        </div>
                        <div class="drawer_filter">
                            <div class="flex">
                                <div class="drawer_filter_title">更多筛选：</div>
                                <div class="flex flex_1" style="margin-bottom: 4px;">
                                    <div>
                                        <el-dropdown trigger="click" placement="bottom" v-for="(advanceitem,adindex) in FilterBaseDataBefore.filtergroup" ref="advancedropdown" @visible-change="CancelDowndropBefore">
                                            <div class="ld_search-width154 mar0 marb12 fontnowrap" style="display: inline-flex;cursor: pointer;height: 16px;color: var(--ld-font-color-primary);" :style="{display : advanceitem.value == 'province' ? 'none' : 'inline-flex'}">
                                                <span :class="{fontcolor_link : advanceitem.selected}">{{advanceitem.label}}</span>
                                                <b class="ld_Select_arrowicon" :class="{bordercolor_link : advanceitem.selected}"></b>
                                            </div>
                                            <template #dropdown>
                                                <div class="map_falte_dropdown" style="max-width: 770px;padding: 0px 16px;">
                                                    <div style="height: 45px;line-height: 45px;font-size: 14px;">{{advanceitem.label}}</div>
                                                    <div class="flex" style="overflow: hidden;">
                                                        <div>
                                                            <el-tooltip :show-after="800" effect="dark" placement="top" v-for="(ckeckitem,itindex) in advanceitem.checklist" :content="ckeckitem.label">
                                                                <el-checkbox class="ld_search-width154 mar0 marb12 fontnowrap" v-model="ckeckitem.selected" :label="ckeckitem.label" @change="advanceDropdownSelect(adindex,itindex,'base')"/>
                                                            </el-tooltip>
                                                        </div>
                                                    </div>
                                                    <div style="padding: 10px 0 20px 0;">
                                                        <div style="display: inline-block;line-height: 32px;cursor: pointer;" @click="SubtitlesDowndrop(adindex)">重置</div>
                                                        <div style="float: right;display: inline-block;">
                                                            <el-button style="margin-right: 20px;" @click="CancelDowndrop">取消</el-button><el-button type="primary" @click="ConfirmDowndrop">确认</el-button>
                                                        </div>
                                                    </div>
                                                </div>
                                            </template>
                                        </el-dropdown>
                                    </div>
                                </div>
                            </div>
                            <div class="flex">
                                <div style="width: 92px;height: 14px;line-height: 14px;">高级筛选：</div>
                                <div class="flex flex_1" style="margin-bottom: 4px;">
                                    <div>
                                        <el-dropdown trigger="click" placement="bottom" v-for="(advanceitem,adindex) in FilterAdvanceData.filtergroup" ref="advancedropdown">
                                            <div class="ld_search-width154 mar0 marb12 fontnowrap" style="display: inline-flex;cursor: pointer;height: 16px;color: var(--ld-font-color-primary);">
                                                <span :class="{fontcolor_link : advanceitem.selected}">{{advanceitem.label}}</span>
                                                <b class="ld_Select_arrowicon" :class="{bordercolor_link : advanceitem.selected}"></b>
                                            </div>
                                            <template #dropdown>
                                                <div class="ld_search-width154 advancefilter_dropdown">
                                                    <div class="advancefilter_dropdown_item" :class="{is_active : ckeckitem.selected}" v-for="(ckeckitem,itindex) in advanceitem.checklist" @click="advanceDropdownSelect(adindex,itindex,'advance')">
                                                        <span class="fontnowrap">{{ckeckitem.label}}</span>
                                                        <b class="ld_dropdown_checked-icon" v-if="ckeckitem.selected"></b>
                                                    </div>
                                                </div>
                                            </template>
                                        </el-dropdown>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </template>
                <template #default>
                    <div style="margin-bottom: 60px;padding-top: 10px;">
                        <component :is="ResultContent" v-bind="ResultContentData"></component>
                    </div>
                    <div class="drawertoggle" @click="drawertoggle">
                        <div class="mart10">收</div>
                        <div>起</div>
                        <div class="drawertoggle_icon">
                            <div class="icon_hide"></div>
                        </div>
                    </div>
                </template>
            </el-drawer>
            <div class="drawertoggle" style="right: 0;left: unset;" @click="drawertoggle" v-if="!drawer">
                <div class="mart10">展</div>
                <div>开</div>
                <div class="drawertoggle_icon">
                    <div class="icon_show"></div>
                </div>
            </div>
        `,
        data() {
            return {
                activeType: 'marker',// 激活的图形编辑类型
                drawer: false,
                ResultContent: shallowRef(null),//查找结果列表组件
                ResultContentData: {},//子组件传参
                FilterBaseData: {},
                FilterAdvanceData: {},
                FilterBaseDataBefore: {},
                addressinfo: {
                    mapCenter: {lat:31.247459,lng:121.548956}, mapRadius: 1000
                },
                markers: [],// 用于存储所有标记和圆形的列表、
                circles: [],
                latlngBounds: null,
                map: null,
                keyword: '',
                searchQuery: '',
                distancevalue: 1000,
                timeoutId: null,
                suggestionResult: [],
                distancelist: [{
                    value: 1000,
                    label: '1KM',
                },{
                    value: 2000,
                    label: '2KM',
                },{
                    value: 5000,
                    label: '5KM',
                },{
                    value: 10000,
                    label: '10KM',
                },{
                    value: 20000,
                    label: '20KM',
                },
                ],
            };
        },
        props: {
            message: Object
        },
        methods: {
            getAddress: function(){
                let that = this;
                fetch('https://api.ipify.org?format=json')
                    .then(response => response.json())
                    .then(data => {
                        console.log('Your IP address is:', data.ip);
                        // 你可以在这里添加代码，比如将IP地址显示在网页上等。
                        let param = {};
                        param['module'] = that.module;
                        param['action'] = 'ldsoukebaomapAjax';
                        param['file'] = 'soukebaoindex';
                        param['getfile'] = 'getaddress';
                        param['ip'] = data.ip;
                        Skb_Ajax(param,function (data) {
                            if(data.code == 1){
                                if(data.result.location){
                                    that.addressinfo.mapCenter = data.result.location;
                                }
                                if(data.result.ad_info){
                                    that.keyword = data.result.ad_info;
                                }
                            }
                            that.initMap();
                        })
                    })
                    .catch(error => console.error('There was an error!', error));

                that.initMap();
            },
            //确定取消弹出层效果
            initMap: function () {

                let that = this;

                that.map = new qq.maps.Map(document.getElementById("container"), {
                    center: new qq.maps.LatLng(31.247459, 121.548956),
                    zoom: 13
                });

            },
            // 清除地图上的所有标记和圆形
            clearOverlays: function() {
                while (this.markers.length) {
                    this.markers.pop().setMap(null);
                }
                while (this.circles.length) {
                    this.circles.pop().setMap(null);
                }
            },
            //修改距离
            changedistance: function(value){
                this.distancevalue = value;
                if(this.circles[0]){
                    this.circles[0].setRadius(value);
                }
                var param = { mapCenter: this.addressinfo.mapCenter, mapRadius: this.distancevalue };
                this.addressinfo = param;
                this.showResultContent();
            },
            // 打开抽屉，返回查找结果
            showResultContent: function () {
                let param = {};
                param = this.addressinfo;
                param['BaseData'] = this.FilterBaseData;
                param['AdvanceData'] = this.FilterAdvanceData;
                this.ResultContentData = {
                    message: {
                        searchcriteria:param,
                        ldpaginationwidth: '70%',
                    }
                }
                this.ResultContent = markRaw(ResultContent());
            },
            //列表抽屉展开收起
            drawertoggle: function(){
                if(this.drawer){
                    this.drawer = false;
                }else{
                    this.drawer = true;
                }
            },
            //获取筛选器
            getFilterInfo: function(){
                let that = this;
                if(Object.keys(that.FilterBaseData).length === 0 && Object.keys(that.FilterAdvanceData).length === 0){
                    let param = {};
                    param['module'] = that.module;
                    param['action'] = 'ldsoukebaomapAjax';
                    param['file'] = 'soukebaoindex';
                    param['getfile'] = 'ConditionalCustomer';
                    Skb_Ajax(param,function (ajaxdata){
                        if(ajaxdata.result.FilterBaseData){
                            that.FilterBaseData = ajaxdata.result.FilterBaseData;
                            that.FilterBaseDataBefore = JSON.parse(JSON.stringify(ajaxdata.result.FilterBaseData));
                        }
                        if(ajaxdata.result.FilterAdvanceData){
                            that.FilterAdvanceData = ajaxdata.result.FilterAdvanceData;
                        }
                        that.showResultContent();
                    });
                }
            },
            advanceDropdownSelect: function (adindex,itindex,type) {
                if(type == 'base'){
                    if(this.FilterBaseDataBefore['filtergroup'][adindex]['checklist'][itindex]['selected']){
                        this.FilterBaseDataBefore['filtergroup'][adindex]['selected'] = true;
                    }else{
                        this.FilterBaseDataBefore['filtergroup'][adindex]['selected'] = false;
                        for(let i = 0;i<this.FilterBaseDataBefore['filtergroup'][adindex]['checklist'].length;i++ ){
                            if(this.FilterBaseDataBefore['filtergroup'][adindex]['checklist'][i]['selected']){
                                this.FilterBaseDataBefore['filtergroup'][adindex]['selected'] = true;
                                break;
                            }
                        }
                    }
                }else if(type == 'advance'){
                    if(this.FilterAdvanceData['filtergroup'][adindex]['checklist'][itindex]['selected']){
                        this.FilterAdvanceData['filtergroup'][adindex]['checklist'][itindex]['selected'] = false;
                        this.FilterAdvanceData['filtergroup'][adindex]['selected'] = false;
                    }else{
                        for(let i = 0;i<this.FilterAdvanceData['filtergroup'][adindex]['checklist'].length;i++){
                            if(itindex == i){
                                this.FilterAdvanceData['filtergroup'][adindex]['checklist'][i]['selected'] = true;
                                this.FilterAdvanceData['filtergroup'][adindex]['selected'] = true;
                            }else{
                                this.FilterAdvanceData['filtergroup'][adindex]['checklist'][i]['selected'] = false;
                            }
                        }
                        this.showResultContent();
                    }
                }
            },
            //更多筛选弹出框
            SubtitlesDowndrop: function (adindex) {
                this.FilterBaseDataBefore['filtergroup'][adindex]['selected'] = false;
                if(this.FilterBaseDataBefore['filtergroup'][adindex]['checklist'].length > 0){
                    let checklist = this.FilterBaseDataBefore['filtergroup'][adindex]['checklist'];
                    for(let i = 0;i<checklist.length;i++){
                        this.FilterBaseDataBefore['filtergroup'][adindex]['checklist'][i]['selected'] = false;
                    }
                }
            },
            CancelDowndropBefore: function(visible){
                if(!visible){
                    this.CancelDowndrop();
                }
            },
            CancelDowndrop: function () {
                if(this.$refs.advancedropdown.length > 0){
                    for(let i = 0;i<this.$refs.advancedropdown.length;i++){
                        this.$refs.advancedropdown[i].handleClose();
                    }
                }
                this.FilterBaseDataBefore = JSON.parse(JSON.stringify(this.FilterBaseData));
            },
            ConfirmDowndrop: function () {
                this.FilterBaseData = JSON.parse(JSON.stringify(this.FilterBaseDataBefore));
                if(this.$refs.advancedropdown.length > 0){
                    for(let i = 0;i<this.$refs.advancedropdown.length;i++){
                        this.$refs.advancedropdown[i].handleClose();
                    }
                }
                this.showResultContent();
            },
            searchAreaBytext: function (newQuery) {
                let that = this;
                let param = {};
                param['module'] = that.module;
                param['action'] = 'ldsoukebaomapAjax';
                param['file'] = 'soukebaoindex';
                param['getfile'] = 'SearchMapApi';
                param['searchtext'] = newQuery;
                Skb_Ajax(param,function (ajaxdata){
                    if(ajaxdata.result.data && ajaxdata.result.data.length > 0){
                        that.suggestionResult = ajaxdata.result.data;
                    }
                });
            },
            selectAddress: function (addressinfo) {
                let that = this;
                console.log(addressinfo);
                that.suggestionResult = [];
                that.searchQuery = '';

                that.keyword = addressinfo.title;

                that.clearOverlays();

                var latlngBounds = new qq.maps.LatLngBounds();


                var poiLatLng = addressinfo.location;

                // 创建圆形
                var circle = new qq.maps.Circle({
                    center: new qq.maps.LatLng(poiLatLng.lat, poiLatLng.lng),
                    radius: that.distancevalue,
                    map: that.map,
                    fillColor: new qq.maps.Color(59, 124, 255, 0.1),
                    strokeColor: new qq.maps.Color(59, 124, 255, 1),
                    strokeWeight: 3
                });
                that.circles.push(circle);

                // 创建标记
                var marker = new qq.maps.Marker({
                    map: that.map,
                    position: new qq.maps.LatLng(poiLatLng.lat, poiLatLng.lng),
                    icon: new qq.maps.MarkerImage(
                        'img/icon/mappoint.png',
                        new qq.maps.Size(36, 40),  // 图标尺寸
                    )
                });
                marker.setTitle(addressinfo.title);
                that.markers.push(marker);

                var circleBounds = circle.getBounds();
                latlngBounds.union(circleBounds);

                that.map.fitBounds(latlngBounds);

                //获取工商数据
                var param = {mapCenter: poiLatLng, mapRadius: that.distancevalue};
                that.drawer = true;
                that.addressinfo = param;
                that.showResultContent();

            }
        },
        watch: {
            // 输入框输入绑定事件
            searchQuery: {
                handler(newQuery) {
                    if(newQuery != ''){
                        if (this.timeoutId) clearTimeout(this.timeoutId);
                        this.timeoutId = setTimeout(() => {
                            this.searchAreaBytext(newQuery);
                        }, 500); // 1秒后搜索
                    }
                },
                immediate: true
            }
        },
        provide() {
            return {
                module: this.module,
                current_user_id: this.current_user_id,
            };
        },
        inject: ['module','current_user_id'],
        mounted() {
            this.getAddress();
            this.getFilterInfo();
        },
    };
}
