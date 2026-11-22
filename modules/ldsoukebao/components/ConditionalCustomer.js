function ConditionalCustomer(){
    return {
        template:
            `<div class="ld_mainpagecontent">
                <div class="ld-search-header">
                    <el-input v-model="searchtext" style="max-width: 600px;height: 40px;" :placeholder="searchplaceholder" class="input-with-select" @keyup.enter="submitForm">
                        <!--<template #prepend>
                            <el-select v-model="searchcolumn" placeholder="企业名称" size="large" style="width: 120px;" @change="changesearcolumn">
                                <el-option v-for="item in searchcolumnoption" :key="item.value" :label="item.label" :value="item.value"/>
                            </el-select>
                        </template>-->
                        <template #append>
                            <el-button style="width: 80px;;background-color: #3B7CFF;" type="primary" @click="submitForm">搜一搜</el-button>
                        </template>
                    </el-input>
                </div>
                <div class="ld-search-filter" v-if="FilterBaseData.filtergroup || FilterAdvanceData.filtergroup">
                    <div style="height: auto;overflow: hidden;" >
                        <div class="ld-search-filter_base">
                            <div class="flex">
    <!--不要删除                            <div class="ld-search-filter_type">{{FilterBaseData.label}}</div>-->
                                <div class="flex_1">
                                    <template  v-for="(baseitem,index) in FilterBaseData.filtergroup">
                                        <div class="flex ld-search-filter_items" v-if="index < baseFilterHeight">
                                            <div class="ld_search-width92 ld-search-filter_typetitle">{{baseitem.label}}</div>
                                            <div class="flex" :class="{'flex_1': filtergroupistoggle(baseitem)}" style="overflow: hidden;margin-bottom: 8px;" :style="{ height : baseFilterGroupToggle[baseitem.value] == 1 ? 'auto' : '28px' }">
                                                <div>
                                                    <el-tooltip :show-after="800" effect="dark" placement="top" v-for="ckeckitem in baseitem.checklist" :content="ckeckitem.label" :class="{dispaly: ckeckitem.display == 'yes' ? '' : 'none'}">
                                                        <el-checkbox class="ld_search-width154 mar0 marb12 fontnowrap" v-model="ckeckitem.selected" :indeterminate="ckeckitem.indeterminate" :label="ckeckitem.label" @change="changeFilter" />
                                                    </el-tooltip>
                                                    <template v-if="baseitem.dependencyfield && baseitem.dependencyfield == 'yes' && baseitem.value == 'province'">
                                                <el-dropdown
                                                    ref="dropdownRef"
                                                    trigger="click"
                                                    :hide-on-click="false"
                                                    placement="left"
                                                    @visible-change="handleVisibleChange">
                                                        <div style="display: inline-flex;cursor: pointer;height: 16px;color: var(--ld-font-color-primary);">
                                                            {{baseitem.dependencyfieldlabel}}
                                                            <b class="ld_Select_arrowicon"></b>
                                                        </div>
                                                        <template #dropdown>
                                                            <div class="regiondrop">
                                                                <div class="regiondropheader flex">
                                                                    <div class="regiondroptitle">所属地区选择</div>
                                                                    <img class="closeicon" src="img/icon/close-circle.png" @click="btnRegionCancle"/>
                                                                </div>
                                                                <div class="flex" style="align-items: center;">
                                                                    <div style="background: #1771EB;border-radius: 4px;font-size: 14px;color: #FFFFFF;line-height: 20px;margin-left:16px;padding: 4px 12px;">中国</div>
<!--                                                                    <el-input placeholder="请输入" style="width: 350px;padding: 8px 0 8px 20px;margin-right:16px;margin-left: auto;"></el-input>-->
                                                                        <el-select
                                                                            v-model="regionselectvalue"
                                                                            filterable
                                                                            remote
                                                                            reserve-keyword
                                                                            placeholder="请输入"
                                                                            remote-show-suffix
                                                                            :remote-method="remoteMethod"
                                                                            :loading="selectloading"
                                                                            :teleported="false"
                                                                            placement="bottom"
                                                                            @change="searchregion"
                                                                            style="width: 240px;padding: 8px 0 8px 20px;margin-right:16px;margin-left: auto;">
                                                                            <el-option
                                                                                v-for="item in selectregionooptions"
                                                                                :key="item.value"
                                                                                :label="item.label"
                                                                                :value="item.value"
                                                                            />
                                                                        </el-select>
                                                                </div>
                                                                <div class="regiondropInitial">
                                                                    <span style="margin-left:16px;">省份首字母：</span>
                                                                    <span style="margin-left:6px;margin-right:8px;">全部</span>
                                                                    <ul>
                                                                        <li :class="{active: regionInitial == 'A'}" @click="regionInitialSearch('A')">A</li>
                                                                        <li :class="{active: regionInitial == 'B'}" @click="regionInitialSearch('B')">B</li>
                                                                        <li :class="{active: regionInitial == 'C'}" @click="regionInitialSearch('C')">C</li>
                                                                        <li :class="{active: regionInitial == 'F'}" @click="regionInitialSearch('F')">F</li>
                                                                        <li :class="{active: regionInitial == 'G'}" @click="regionInitialSearch('G')">G</li>
                                                                        <li :class="{active: regionInitial == 'H'}" @click="regionInitialSearch('H')">H</li>
                                                                        <li :class="{active: regionInitial == 'J'}" @click="regionInitialSearch('J')">J</li>
                                                                        <li :class="{active: regionInitial == 'L'}" @click="regionInitialSearch('L')">L</li>
                                                                        <li :class="{active: regionInitial == 'N'}" @click="regionInitialSearch('N')">N</li>
                                                                        <li :class="{active: regionInitial == 'Q'}" @click="regionInitialSearch('Q')">Q</li>
                                                                        <li :class="{active: regionInitial == 'S'}" @click="regionInitialSearch('S')">S</li>
                                                                        <li :class="{active: regionInitial == 'T'}" @click="regionInitialSearch('T')">T</li>
                                                                        <li :class="{active: regionInitial == 'X'}" @click="regionInitialSearch('X')">X</li>
                                                                        <li :class="{active: regionInitial == 'Y'}" @click="regionInitialSearch('Y')">Y</li>
                                                                        <li :class="{active: regionInitial == 'Z'}" @click="regionInitialSearch('Z')">Z</li>
                                                                    </ul>
                                                                </div>
                                                                <div class="flex">
                                                                    <el-scrollbar ref="provincescroll" height="240px" class="flex_1 cascadescroll" @scroll="provincescrollEvent">
                                                                        <div class="flex cascadescrolldiv" v-for="(item,index) in regionoptions.province" @click="getchildrenoption(index,regionoptions.province,1,item.value)" :class="{active : item.value == chooseRegionFirst}">
                                                                            <div style="width: 24px;"><span>{{item.Initial}}</span></div>
                                                                            <div style="margin-right: auto;">
                                                                                <span>{{item.label}}</span>
                                                                            </div>
                                                                            <i class="ld_Select_rigthicon" v-if="item.children && item.children.length > 0"></i>
                                                                        </div>
                                                                    </el-scrollbar>
                                                                    <el-scrollbar ref="provincescroll2" height="240px" class="flex_1 cascadescroll" v-if="regionoptions2.length > 0">
                                                                        <div class="flex cascadescrolldiv" v-for="(item,index) in regionoptions2" @click="getchildrenoption(index,regionoptions2,2,item.value)" :class="{active : item.value == chooseRegionSecond}">
                                                                            <div class="flex" style="align-items: center;">
                                                                                <el-checkbox @click.stop="selectedregion(index,regionoptions2,2,item.value,item.selected)" checked v-if="item.selected"></el-checkbox>
                                                                                <el-checkbox @click.stop="selectedregion(index,regionoptions2,2,item.value,item.selected)" :indeterminate="item.indeterminate" v-else></el-checkbox>
                                                                                <span style="margin-left: 8px;">{{item.label}}</span>
                                                                            </div>
                                                                            <i class="ld_Select_rigthicon" v-if="item.children && item.children.length > 0"></i>
                                                                        </div>
                                                                    </el-scrollbar>
                                                                    <el-scrollbar ref="provincescroll3" height="240px" class="flex_1 cascadescroll" v-if="regionoptions3.length > 0">
                                                                        <div class="flex cascadescrolldiv" v-for="(item,index) in regionoptions3" :class="{active : item.value == chooseRegionthird}">
                                                                            <div class="flex" style="align-items: center;">
                                                                                <el-checkbox @click="selectedregion(index,regionoptions3,3,item.value,item.selected)" checked v-if="item.selected"></el-checkbox>
                                                                                <el-checkbox @click="selectedregion(index,regionoptions3,3,item.value,item.selected)" :indeterminate="item.indeterminate" v-else></el-checkbox>
                                                                                <span style="margin-left: 8px;">{{item.label}}</span>
                                                                            </div>
                                                                            <i class="ld_Select_rigthicon" v-if="item.children && item.children.length > 0"></i>
                                                                        </div>
                                                                    </el-scrollbar>
                                                                </div>
                                                                <div v-if="moreprovinceselectcount>0 && moreprovinceselect.length > 0 ">
                                                                    <div class="flex" style="height: 45px;align-items: center;padding: 0 20px;">
                                                                        <div style="width: 70px;margin-right: auto;">已选（{{moreprovinceselectcount}}）</div>
                                                                        <div style="padding: 5px 10px;color: var(--ld-font-color-link);cursor: pointer;" @click="removeALledregion">清除</div>
                                                                    </div>
                                                                    <div class="flex" style="max-height: 128px;overflow-y: auto;padding: 0 20px;">
                                                                        <div class="flex_1">
                                                                            <template v-for="(proitem,proindex) in moreprovinceselect">
                                                                                <template v-if="proitem.children && proitem.children.length > 0">
                                                                                    <template v-for="(cityitem,cityindex) in proitem.children">
                                                                                        <template v-if="cityitem.children && cityitem.children.length > 0">
                                                                                            <template v-for="(regionitem,regionindex) in cityitem.children">
                                                                                                <el-tag type="info" closable @close="removeedregion(regionitem)">{{proitem.label}}：{{cityitem.label}}-{{regionitem.label}}</el-tag>
                                                                                            </template>
                                                                                        </template>
                                                                                        <template v-else>
                                                                                            <el-tag type="info" closable @close="removeedregion(cityitem)">{{proitem.label}}：{{cityitem.label}}</el-tag>
                                                                                        </template>
                                                                                    </template>
                                                                                </template>
                                                                                <template v-else>
                                                                                    <el-tag type="info" closable @close="removeedregion(proitem)">{{proitem.label}}：</el-tag>
                                                                                </template>
                                                                            </template>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <div class="flex" style="justify-content: flex-end;height: 64px;padding: 0 24px;align-items: center;">
                                                                    <el-button @click="btnRegionCancle" style="width: 120px;height: 40px;margin-right: 16px;font-size: 16px;">取消</el-button>
                                                                    <el-button @click="btnRegionOk" style="width: 120px;height: 40px;font-size: 16px;" type="primary">确认</el-button>
                                                                </div>
                                                            </div>
                                                        </template>
                                                </el-dropdown>
                                            </template>
                                                </div>
                                            </div>
                                            <div class="ld-search-filter_items_more" v-if="filtergroupistoggle(baseitem)" @click="filterItemToggle(baseitem.value)">
                                                <template v-if="baseFilterGroupToggle[baseitem.value] == 1">
                                                    收起
                                                    <b class="ld_Select_upicon" style="border-color: #999;"></b>
                                                </template>
                                                <template v-else>
                                                    展开
                                                    <b class="ld_Select_arrowicon" style="border-color: #999;"></b>
                                                </template>
                                            </div>
                                        </div>
                                    </template>
                                </div>
                            </div>
                        </div>
                        <div class="ld-search-filter_advance" v-if="ExpandBaseFilter">
                            <div class="flex">
    <!--不要删除                          <div class="ld-search-filter_type">{{FilterAdvanceData.label}}</div>-->
                                <div class="flex_1">
                                    <div class="flex ld-search-filter_items">
                                        <div class="ld_search-width92 ld-search-filter_typetitle">高级筛选</div>
                                        <div class="flex">
                                            <div>
                                                <el-dropdown trigger="click" placement="bottom" v-for="(advanceitem,adindex) in FilterAdvanceData.filtergroup" ref="advancedropdown">
                                                    <div class="ld_search-width154 mar0 marb20 fontnowrap" style="display: inline-flex;cursor: pointer;height: 16px;color: var(--ld-font-color-primary);">
                                                        <span :class="{fontcolor_link : advanceitem.selected}">{{advanceitem.label}}</span>
                                                        <b class="ld_Select_arrowicon" :class="{bordercolor_link : advanceitem.selected}"></b>
                                                    </div>
                                                    <template #dropdown>
                                                        <div class="ld_search-width154 advancefilter_dropdown">
                                                            <div class="advancefilter_dropdown_item" :class="{is_active : ckeckitem.selected}" v-for="(ckeckitem,itindex) in advanceitem.checklist" @click="advanceDropdownSelect(adindex,itindex)">
                                                                <span>{{ckeckitem.label}}</span>
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
                        </div>
                    </div>
                    <div style="height: 1px;width: 100%;background: #ebeef5;margin-bottom: 26px;" v-if="ConditionalNum > 0"></div>
                    <div class="flex" style="margin-bottom: 8px;" v-if="ConditionalNum > 0">
                        <div style="width: 92px;">已选条件：</div>
                        <div class="flex_1" style="margin-top: -4px;">
                            <template v-for="selectgroupitem in haveSelectedData">
                                <el-tag v-for="selectitem in selectgroupitem.itemlist" :key="selectitem" closable type="info" @close="removeFilter(selectgroupitem,selectitem)">{{selectgroupitem.label}}:{{selectitem.label}}</el-tag>
                            </template>
                            <div class="conditional_delect_all" @click="removeAllFilter"><img src="img/icon/delete.png"/><span>清除所选</span></div>
                        </div>
                        
                    </div>
                    <el-tooltip :show-after="500" :auto-close="3000" effect="dark" placement="top" :content="toggleToolTip">
                        <div class="ld-filter-slideToggle" @click="ExpandBaseFilterEvent">
                            <i class="ld_Select_upicon" style="margin: -2px auto 0px;float: none;" v-if="ExpandBaseFilter"></i>
                            <i class="ld_Select_arrowicon" style="margin: -8px auto 0px;float: none;" v-else></i>
                        </div>
                    </el-tooltip>
                </div>
                <div style="background: #fff;margin-top: 16px;border-radius: 4px;overflow: hidden;padding: 10px 20px 20px;margin-bottom: 60px;">
                    <component :is="ResultContent" v-bind="ResultContentData"></component>
                </div>
            </div>
        `,
        data(){
            return {
                searchplaceholder: '请输入企业名称',//查找值
                searchtext: '',//查找值
                searchcolumn: '',//查找下拉框选中值
                searchcolumnoption: '',//查找下拉框选中值
                FilterBaseData: {},//基本查找条件筛选器
                FilterAdvanceData: {},//高级查找条件筛选器
                haveSelectedData: [],//已经选中的筛选条件
                ConditionalNum: 0,//已选筛选条件的数量
                ResultContent: shallowRef(null),//查找结果列表组件
                ExpandBaseFilter: true,//基本查找是否展开收起
                baseFilterHeight: 1000,//基本查找高度
                ResultContentData: {},//子组件传参
                regionoptions:{},
                chooseRegionFirst: '',
                regionoptions2: [],
                chooseRegionSecond: '',
                regionoptions3: [],
                chooseRegionthird: '',
                moreprovinceselect: [],//更多区域筛选条件
                moreprovinceselectcount: 0,
                regionInitial: "A",
                baseFilterGroupToggle: {},//每种过滤条件是否展开收起
                toggleToolTip: '更多筛选',//筛选器展开收起提示
                selectloading: false,
                selectregionooptions: [],
                regionselectvalue: '',
            }
        },
        props: {
            message: Object
        },
        methods: {
            handleVisibleChange(visible){
                if(visible){
                    for(let i = 0;i<this.FilterBaseData.filtergroup.length;i++){
                        if(this.FilterBaseData.filtergroup[i].value == 'province'){
                            this.regionoptions.province = this.FilterBaseData.filtergroup[i].checklist;
                            break;
                        }
                    }
                    this.getregioncascadeselect();
                }
            },
            //搜索地区
            searchregion(value){
                let that = this;
                for(let i = 0;i<that.selectregionooptions.length;i++){
                    if(that.selectregionooptions[i].value == value){
                        var tem_position = that.selectregionooptions[i].position;
                        if(tem_position.length == 1){
                            that.getchildrenoption(tem_position[0],that.regionoptions.province,1,value);
                            setTimeout(function () {
                                if(that.$refs.provincescroll){
                                    that.$refs.provincescroll[0].setScrollTop(tem_position[0]*35-111);
                                }
                            },200);
                            that.chooseRegionSecond = '';
                            that.chooseRegionthird = '';
                        }
                        else if(tem_position.length == 2){
                            that.getchildrenoption(tem_position[0],that.regionoptions.province,1,that.regionoptions.province[tem_position[0]].value);
                            setTimeout(function () {
                                if(that.$refs.provincescroll2){
                                    that.$refs.provincescroll[0].setScrollTop(tem_position[0]*35-111);
                                    that.$refs.provincescroll2[0].setScrollTop(tem_position[1]*35-111);
                                }
                            },200);
                            that.chooseRegionSecond = value;
                            that.chooseRegionthird = '';
                        }
                        else if(tem_position.length == 3){
                            that.getchildrenoption(tem_position[0],that.regionoptions.province,1,that.regionoptions.province[tem_position[0]].value);
                            that.getchildrenoption(tem_position[1],that.regionoptions.province[tem_position[0]].children,2,that.regionoptions.province[tem_position[0]].children[tem_position[1]].value);
                            setTimeout(function () {
                                if(that.$refs.provincescroll3){
                                    that.$refs.provincescroll[0].setScrollTop(tem_position[0]*35-111);
                                    that.$refs.provincescroll2[0].setScrollTop(tem_position[1]*35-111);
                                    that.$refs.provincescroll3[0].setScrollTop(tem_position[2]*35-111);
                                }
                            },200);
                            that.chooseRegionthird = value;
                        }
                        break;
                    }
                }
            },
            //匹配地区
            remoteMethod(search){
                let that = this;
                if(search){
                    that.selectloading = true;
                    let tmp_optionlist = [];
                    var iteminfo = {};
                    for(let i = 0;i<that.regionoptions.province.length;i++){
                        if(that.regionoptions.province[i].label.includes(search)){
                            iteminfo = JSON.parse(JSON.stringify(that.regionoptions.province[i]));
                            if(iteminfo.children){
                                delete iteminfo.children;
                            }
                            iteminfo.position = [i];
                            tmp_optionlist.push(iteminfo);
                        }
                        if(that.regionoptions.province[i].children && that.regionoptions.province[i].children.length > 0){
                            for(let j = 0;j<that.regionoptions.province[i].children.length;j++){
                                if(that.regionoptions.province[i].children[j].label && that.regionoptions.province[i].children[j].label.includes(search)){
                                    iteminfo = JSON.parse(JSON.stringify(that.regionoptions.province[i].children[j]));
                                    if(iteminfo.children){
                                        delete iteminfo.children;
                                    }
                                    iteminfo.position = [i,j];
                                    tmp_optionlist.push(iteminfo);
                                }
                                if(that.regionoptions.province[i].children[j].children && that.regionoptions.province[i].children[j].children.length > 0){
                                    for(let k = 0;k<that.regionoptions.province[i].children[j].children.length;k++){
                                        if(that.regionoptions.province[i].children[j].children[k].label && that.regionoptions.province[i].children[j].children[k].label.includes(search)){
                                            iteminfo = JSON.parse(JSON.stringify(that.regionoptions.province[i].children[j].children[k]));
                                            iteminfo.position = [i,j,k];
                                            tmp_optionlist.push(iteminfo);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    that.selectregionooptions = tmp_optionlist;
                    that.selectloading = false;
                }
            },
            //首字母筛选
            regionInitialSearch(Initial){
                let that = this;
                if(that.regionoptions.province.length > 0){
                    for(let i = 0;i<that.regionoptions.province.length;i++){
                        if(Initial == that.regionoptions.province[i]['Initial']){
                            that.$refs.provincescroll[0].setScrollTop(i*35);
                            break;
                        }
                    }

                }
                that.regionInitial = Initial;
            },
            //省份滚动事件
            provincescrollEvent(event){
                let that = this;
                if(that.regionoptions.province.length > 0){
                    var Initial = '';
                    for(let i = 0;i<that.regionoptions.province.length;i++){
                        if(that.regionoptions.province[i]['Initial'] != ''){
                            Initial = that.regionoptions.province[i]['Initial'];
                        }
                        if((event.scrollTop-10) < (i*35)){
                            that.regionInitial = Initial;
                            break;
                        }
                    }

                }
            },
            //每个检索维度是否显示更多
            filtergroupistoggle(baseitem){
                var item_num = baseitem.checklist.length;
                if((item_num * 154) > (window.innerWidth - 40 - 92)){
                    if(this.baseFilterGroupToggle[baseitem.value]){

                    }else{
                        this.baseFilterGroupToggle[baseitem.value] = 0;
                    }
                    return true;
                }else{
                    return false;
                }
            },
            //每行筛选的展开收起
            filterItemToggle(value){
                if(this.baseFilterGroupToggle[value]){
                    this.baseFilterGroupToggle[value] = 0;
                }else{
                    this.baseFilterGroupToggle[value] = 1;
                }
            },
            //选择区域
            selectedregion(index,options,level,value,selected){
                if(level == 2 && value != 'all' && options[index].children){
                    this.getchildrenoption(index,options,level,value);    
                }

                if(value == 'all'){
                    for(let i = 0; i < options.length; i++){
                        if(selected){
                            options[i].selected = false;
                        }
                        else{
                            options[i].selected = true;
                        }
                    }
                    options[0].indeterminate = false;
                    if(level == 2){
                        this.regionoptions3 = [];
                    }
                }
                else{
                    var count = 0;
                    var count_in = 0
                    for(let i = 1; i < options.length; i++){
                        if(options[i].value == value){
                            if(selected){
                                options[i].selected = false;
                                if(options[index].children){
                                    for(let j = 0; j < options[index].children.length; j++){
                                        options[index].children[j].selected = false;
                                    }
                                }
                            }
                            else{
                                options[i].selected = true;
                                if(options[index].children){
                                    for(let j = 0; j < options[index].children.length; j++){
                                        options[index].children[j].selected = true;
                                    }
                                }
                            }
                        }
                        if(options[i].selected){
                            count++;
                        }
                        if(options[i].indeterminate){
                            count_in++;
                        }
                    }
                    if(count > 0 && count < options.length-1){
                        options[0].selected = false;
                        options[0].indeterminate = true;
                    }
                    else if(count == options.length-1){
                        options[0].indeterminate = false;
                        options[0].selected = true;
                    }else if(count == 0){
                        options[0].selected = false;
                        if(count_in > 0){
                            options[0].indeterminate = true;
                        }else{
                            options[0].indeterminate = false;
                        }
                    }
                }


                if(level == 3){

                    for(let i = 0; i < this.regionoptions.province.length; i++){
                        if(this.regionoptions.province[i].children && this.regionoptions.province[i].value == this.chooseRegionFirst){
                            var parcount = 0;
                            var parcount_in = 0;
                            for(let j = 0; j < this.regionoptions.province[i].children.length; j++){
                                if(this.regionoptions.province[i].children[j].value == this.chooseRegionSecond){
                                    this.regionoptions.province[i].children[j].children  = options;
                                    if(options[0].selected){
                                        this.regionoptions.province[i].children[j].selected = true;
                                    }
                                    else{
                                        this.regionoptions.province[i].children[j].selected = false;
                                    }
                                    if(options[0].indeterminate){
                                        this.regionoptions.province[i].children[j].indeterminate = true;
                                    }
                                    else{
                                        this.regionoptions.province[i].children[j].indeterminate = false;
                                    }
                                }
                                if(this.regionoptions.province[i].children[j].selected && this.regionoptions.province[i].children[j].value != 'all'){
                                    parcount++;
                                }
                                if(this.regionoptions.province[i].children[j].indeterminate && this.regionoptions.province[i].children[j].value != 'all'){
                                    parcount_in++;
                                }
                            }
                            if(parcount > 0 && parcount < this.regionoptions.province[i].children.length-1){
                                this.regionoptions.province[i].children[0].selected = false;
                                this.regionoptions.province[i].selected = false;
                                this.regionoptions.province[i].children[0].indeterminate = true;
                                this.regionoptions.province[i].indeterminate = true;
                            }
                            else if(parcount == this.regionoptions.province[i].children.length-1){
                                this.regionoptions.province[i].children[0].indeterminate = false;
                                this.regionoptions.province[i].indeterminate = false;
                                this.regionoptions.province[i].children[0].selected = true;
                                this.regionoptions.province[i].selected = true;
                            }
                            else if(parcount == 0){
                                this.regionoptions.province[i].children[0].selected = false;
                                this.regionoptions.province[i].selected = false;
                                if(parcount_in > 0){
                                    this.regionoptions.province[i].children[0].indeterminate = true;
                                    this.regionoptions.province[i].indeterminate = true;
                                }else{
                                    this.regionoptions.province[i].children[0].indeterminate = false;
                                    this.regionoptions.province[i].indeterminate = false;
                                }
                            }
                            break;
                        }
                    }
                }
                else if(level == 2){
                    for(let i = 0; i < this.regionoptions.province.length; i++){
                        if(this.regionoptions.province[i].children){
                            if(this.regionoptions.province[i].value == this.chooseRegionFirst){
                                this.regionoptions.province[i].children  = options;
                                this.regionoptions.province[i].selected = this.regionoptions.province[i].children[0].selected;
                                this.regionoptions.province[i].indeterminate = this.regionoptions.province[i].children[0].indeterminate;
                                break;
                            }
                        }
                    }
                }
                //获取已选中的区域筛选条件
                this.getregioncascadeselect();
            },
            //获取已选中的区域筛选条件
            getregioncascadeselect(){
                let that = this;
                let count = 0;
                var tmp_proarray= [];
                for(let i = 0;i<that.regionoptions.province.length;i++){
                    if(that.regionoptions.province[i].children && that.regionoptions.province[i].children.length > 0){
                        if(that.regionoptions.province[i].children[0].value == 'all' && that.regionoptions.province[i].children[0].selected || that.regionoptions.province[i].selected){
                                var tmp_pro = JSON.parse(JSON.stringify(that.regionoptions.province[i]));
                                delete tmp_pro.children;
                                tmp_pro.selected = true;
                                tmp_pro.position = [i];
                                tmp_proarray.push(tmp_pro);
                                count++;
                        }
                        else{
                            var tmp_secondlist = [];
                            for(let j = 1;j<that.regionoptions.province[i].children.length > 0;j++){
                                if(that.regionoptions.province[i].children[j].selected){
                                    var tmp_second = JSON.parse(JSON.stringify(that.regionoptions.province[i].children[j]));
                                    tmp_second.position = [i,j];
                                    if(tmp_second.children){
                                        delete tmp_second.children;
                                    }
                                    tmp_secondlist.push(tmp_second);
                                    count++;
                                }
                                else if(that.regionoptions.province[i].children[j].indeterminate && that.regionoptions.province[i].children[j].children && that.regionoptions.province[i].children[j].children.length > 0){
                                    var tmp_second = JSON.parse(JSON.stringify(that.regionoptions.province[i].children[j]));
                                    var tmp_thirdlist = [];
                                    for(let k = 1;k<that.regionoptions.province[i].children[j].children.length;k++){
                                        if(that.regionoptions.province[i].children[j].children[k].selected){
                                            var tmp_third = JSON.parse(JSON.stringify(that.regionoptions.province[i].children[j].children[k]));
                                            tmp_third.position = [i,j,k];
                                            tmp_thirdlist.push(tmp_third);
                                            count++;
                                        }
                                    }
                                    if(tmp_thirdlist.length > 0){
                                        tmp_second.children = tmp_thirdlist;
                                        tmp_secondlist.push(tmp_second);
                                    }
                                }
                            }
                            if(tmp_secondlist.length > 0){
                                var tmp_pro = JSON.parse(JSON.stringify(that.regionoptions.province[i]));
                                tmp_pro.children = tmp_secondlist;
                                tmp_pro.selected = false;
                                tmp_proarray.push(tmp_pro);
                            }
                        }
                    }
                }
                that.moreprovinceselect = tmp_proarray;
                that.moreprovinceselectcount = count;
            },
            //删除区域级联
            removeedregion(item){
                if(item.position){
                    if(item.position.length == 1){
                        this.regionoptions.province[item.position[0]].selected = false;
                        if(this.regionoptions.province[item.position[0]].children){
                            for(let i = 0;i<this.regionoptions.province[item.position[0]].children.length;i++){
                                this.regionoptions.province[item.position[0]].children[i].selected = false
                                this.regionoptions.province[item.position[0]].children[i].indeterminate = false;
                                if(this.regionoptions.province[item.position[0]].children[i].children){
                                    for(let j = 0;j<this.regionoptions.province[item.position[0]].children[i].children.length;j++){
                                        this.regionoptions.province[item.position[0]].children[i].children[j].selected = false
                                        this.regionoptions.province[item.position[0]].children[i].children[j].indeterminate = false;
                                    }
                                }
                            }
                        }
                    }
                    else if(item.position.length == 2) {
                        this.regionoptions.province[item.position[0]].children[item.position[1]].selected = false;
                        if(this.regionoptions.province[item.position[0]].children[item.position[1]].children){
                            for(let j = 0;j<this.regionoptions.province[item.position[0]].children[item.position[1]].children.lenght;j++){
                                this.regionoptions.province[item.position[0]].children[item.position[1]].children[j].selected = false
                                this.regionoptions.province[item.position[0]].children[item.position[1]].children[j].indeterminate = false;
                            }
                        }
                    }
                    else if(item.position.length == 3){
                        this.regionoptions.province[item.position[0]].children[item.position[1]].children[item.position[2]].selected = false;
                    }
                    if(item.position.length > 1){
                        if(item.position.length > 2){
                            let citycount = 0;
                            let citycount_in = 0
                            let option_len = this.regionoptions.province[item.position[0]].children[item.position[1]].children.length
                            for(let i = 1;i<option_len;i++){
                                if(this.regionoptions.province[item.position[0]].children[item.position[1]].children[i].selected){
                                    citycount++;
                                }
                                if(this.regionoptions.province[item.position[0]].children[item.position[1]].children[i].indeterminate){
                                    citycount_in++;
                                }
                            }
                            if(citycount > 0 && citycount < option_len-1){
                                this.regionoptions.province[item.position[0]].children[item.position[1]].children[0].selected = false;
                                this.regionoptions.province[item.position[0]].children[item.position[1]].selected = false;
                                this.regionoptions.province[item.position[0]].children[item.position[1]].children[0].indeterminate = true;
                                this.regionoptions.province[item.position[0]].children[item.position[1]].indeterminate = true;
                            }
                            else if(citycount == option_len-1){
                                this.regionoptions.province[item.position[0]].children[item.position[1]].children[0].indeterminate = false;
                                this.regionoptions.province[item.position[0]].children[item.position[1]].indeterminate = false;
                                this.regionoptions.province[item.position[0]].children[item.position[1]].selected = true;
                                this.regionoptions.province[item.position[0]].children[item.position[1]].children[0].selected = true;
                            }else if(citycount == 0){
                                this.regionoptions.province[item.position[0]].children[item.position[1]].children[0].selected = false;
                                this.regionoptions.province[item.position[0]].children[item.position[1]].selected = false;
                                if(citycount_in > 0){
                                    this.regionoptions.province[item.position[0]].children[item.position[1]].children[0].indeterminate = true;
                                    this.regionoptions.province[item.position[0]].children[item.position[1]].indeterminate = true;
                                }else{
                                    this.regionoptions.province[item.position[0]].children[item.position[1]].children[0].indeterminate = false;
                                    this.regionoptions.province[item.position[0]].children[item.position[1]].indeterminate = false;
                                }
                            }
                        }
                        let count = 0;
                        let count_in = 0;
                        let optionlen = this.regionoptions.province[item.position[0]].children.length;
                        for(let i = 1;i<optionlen;i++){
                            if(this.regionoptions.province[item.position[0]].children[i].selected){
                                count++;
                            }
                            if(this.regionoptions.province[item.position[0]].children[i].indeterminate){
                                count_in++;
                            }
                        }
                        if(count > 0 && count < optionlen-1){
                            this.regionoptions.province[item.position[0]].children[0].selected = false;
                            this.regionoptions.province[item.position[0]].selected = false;
                            this.regionoptions.province[item.position[0]].children[0].indeterminate = true;
                            this.regionoptions.province[item.position[0]].indeterminate = false;
                        }
                        else if(count == optionlen-1){
                            this.regionoptions.province[item.position[0]].children[0].indeterminate = false;
                            this.regionoptions.province[item.position[0]].indeterminate = false;
                            this.regionoptions.province[item.position[0]].selected = true;
                            this.regionoptions.province[item.position[0]].children[0].selected = true;
                        }else if(count == 0){
                            this.regionoptions.province[item.position[0]].children[0].selected = false;
                            this.regionoptions.province[item.position[0]].selected = false;
                            if(count_in > 0){
                                this.regionoptions.province[item.position[0]].children[0].indeterminate = true;
                                this.regionoptions.province[item.position[0]].indeterminate = true;
                            }else{
                                this.regionoptions.province[item.position[0]].children[0].indeterminate = false;
                                this.regionoptions.province[item.position[0]].indeterminate = false;
                            }
                        }
                    }
                }
                this.getregioncascadeselect();
            },
            //删除区域级联(全部)
            removeALledregion(){
                let that = this;
                that.moreprovinceselect = [];
                that.moreprovinceselectcount = 0;
                for(let i = 0;i<that.regionoptions.province.length;i++){
                    that.regionoptions.province[i].selected = false;
                    that.regionoptions.province[i].indeterminate = false;
                    if(that.regionoptions.province[i].children && that.regionoptions.province[i].children.length > 0){
                        for(let j = 0;j<that.regionoptions.province[i].children.length;j++){
                            that.regionoptions.province[i].children[j].selected = false;
                            that.regionoptions.province[i].children[j].indeterminate = false;
                            if(that.regionoptions.province[i].children[j].children && that.regionoptions.province[i].children[j].children.length > 0){
                                for(let k = 0;k<that.regionoptions.province[i].children[j].children.length;k++){
                                    that.regionoptions.province[i].children[j].children[k].selected = false;
                                    that.regionoptions.province[i].children[j].children[k].indeterminate = false;
                                }
                            }
                        }
                    }
                }
            },
            //区域级联
            getchildrenoption(index,options,level,value){
                this.regionselectvalue = '';
                if(options[index]){
                    if(options[index].selected && options[index].children){
                        for(let i = 0; i < options[index].children.length; i++){
                            options[index].children[i].selected = true;
                        }
                    }

                    if(level == 1){
                        this.chooseRegionFirst = value;
                        if(options[index].children){
                            this.regionoptions2 = options[index].children;
                            this.regionoptions3 = [];
                        }
                        else{
                            this.regionoptions2 = [];
                            this.regionoptions3 = [];
                        }
                    }
                    else if(level == 2){
                        this.chooseRegionSecond = value;
                        if(options[index].children){
                            this.regionoptions3 = options[index].children;
                        }
                        else{
                            this.chooseRegionthird = '';
                            this.regionoptions3 = [];   
                        }
                    }
                }
            },
            //获取筛选器
            getFilterInfo(){
                let that = this;
                if(that.message.searchtext){
                    that.searchtext = that.message.searchtext;
                }
                if(that.message.searchcolumn){
                    that.searchcolumn = that.message.searchcolumn;
                }
                if(Object.keys(that.FilterBaseData).length === 0 && Object.keys(that.FilterAdvanceData).length === 0){
                    let param = {};
                    param['module'] = that.module;
                    param['action'] = 'ldsoukebaoAjax';
                    param['file'] = 'soukebaoindex';
                    param['getfile'] = 'ConditionalCustomer';
                    Skb_Ajax(param,function (ajaxdata){
                        if(ajaxdata.result.searchcolumnoption && ajaxdata.result.searchcolumnoption.length > 0){
                            that.searchcolumnoption = ajaxdata.result.searchcolumnoption;
                            if(that.searchcolumn == ''){
                                that.searchcolumn = that.searchcolumnoption[0].value;
                            }
                        }
                        if(ajaxdata.result.searchplaceholder){
                            that.searchplaceholder = ajaxdata.result.searchplaceholder;
                        }
                        if(ajaxdata.result.FilterBaseData){
                            that.FilterBaseData = ajaxdata.result.FilterBaseData;
                        }
                        if(ajaxdata.result.FilterAdvanceData){
                            that.FilterAdvanceData = ajaxdata.result.FilterAdvanceData;
                        }
                        if(ajaxdata.result.FilterBaseData){
                            if(ajaxdata.result.FilterBaseData.filtergroup && ajaxdata.result.FilterBaseData.filtergroup.length > 0){
                                for(let i = 0;i<ajaxdata.result.FilterBaseData.filtergroup.length;i++){
                                    if(ajaxdata.result.FilterBaseData.filtergroup[i].value == 'province'){
                                        for(let j = 0;j < ajaxdata.result.FilterBaseData.filtergroup[i].checklist.length;j++ ){
                                            var Initial = '';
                                            switch (ajaxdata.result.FilterBaseData.filtergroup[i].checklist[j].label) {
                                                case '安徽省':
                                                    Initial = 'A';
                                                    break;
                                                case '北京市':
                                                    Initial = 'B';
                                                    break;
                                                case '重庆市':
                                                    Initial = 'C';
                                                    break;
                                                case '福建省':
                                                    Initial = 'F';
                                                    break;
                                                case '甘肃省':
                                                    Initial = 'G';
                                                    break;
                                                case '海南省':
                                                    Initial = 'H';
                                                    break;
                                                case '吉林省':
                                                    Initial = 'J';
                                                    break;
                                                case '辽宁省':
                                                    Initial = 'L';
                                                    break;
                                                case '内蒙古自治区':
                                                    Initial = 'N';
                                                    break;
                                                case '青海省':
                                                    Initial = 'Q';
                                                    break;
                                                case '山西省':
                                                    Initial = 'S';
                                                    break;
                                                case '台湾省':
                                                    Initial = 'T';
                                                    break;
                                                case '西藏自治区':
                                                    Initial = 'X';
                                                    break;
                                                case '云南省':
                                                    Initial = 'Y';
                                                    break;
                                                case '浙江省':
                                                    Initial = 'Z';
                                                    break;
                                                default:
                                                    Initial = '';
                                                    break;
                                            }
                                            ajaxdata.result.FilterBaseData.filtergroup[i].checklist[j]['Initial'] = Initial;
                                        }
                                        break;
                                    }
                                }
                            }
                        }
                        if(Object.keys(that.FilterBaseData).length > 0 || Object.keys(that.FilterAdvanceData).length > 0){
                            that.submitForm();
                            that.changeFilter();
                        }
                        
                    });
                }
            },

            // 取消按钮的逻辑
            btnRegionCancle(){
                // 关闭下拉菜单
                this.$refs.dropdownRef[0].handleClose();
                this.chooseRegionFirst='';
                this.regionoptions2=[];
                this.chooseRegionSecond='';
                this.regionoptions3=[];
                this.chooseRegionthird='';
            },
            // 确认按钮的逻辑
            btnRegionOk(){
                let that = this;
                that.$refs.dropdownRef[0].handleClose();
                this.chooseRegionFirst='';
                this.regionoptions2=[];
                this.chooseRegionSecond='';
                this.regionoptions3=[];
                this.chooseRegionthird='';
                for(let i = 0;i<this.FilterBaseData.filtergroup.length;i++){
                    if(this.FilterBaseData.filtergroup[i].value == 'province'){
                        this.FilterBaseData.filtergroup[i].checklist = this.regionoptions.province;
                        break;
                    }
                }
                that.changeFilter();
            },

            //查找
            submitForm(){
                let param = {};
                param['searchcolumn'] = this.searchcolumn;
                param['searchtext'] = this.searchtext;
                param['BaseData'] = this.FilterBaseData;
                param['AdvanceData'] = this.FilterAdvanceData;
                this.ResultContentData = {
                    message: {
                        searchcriteria:param,
                        ldpaginationwidth: 'calc(100% - 10px)',
                    }
                }
                this.ResultContent = markRaw(ResultContent());
            },

            //修改下拉框值
            changesearcolumn(){
                this.searchtext = '';
            },
            //高级筛选下拉框点击事件
            advanceDropdownSelect(adindex,itindex){
                if(this.$refs.advancedropdown.length > 0){
                    for(let i = 0;i<this.$refs.advancedropdown.length;i++){
                        this.$refs.advancedropdown[i].handleClose();
                    }
                }
                if(this.FilterAdvanceData['filtergroup'][adindex]['checklist'][itindex]['selected']){
                    this.FilterAdvanceData['filtergroup'][adindex]['checklist'][itindex]['selected'] = false;
                    this.FilterAdvanceData['filtergroup'][adindex]['selected'] = false;
                }else{
                    this.FilterAdvanceData['filtergroup'][adindex]['selected'] = true;
                    for(let i = 0;i<this.FilterAdvanceData['filtergroup'][adindex]['checklist'].length;i++){
                        if(itindex == i){
                            this.FilterAdvanceData['filtergroup'][adindex]['checklist'][i]['selected'] = true;
                        }else{
                            this.FilterAdvanceData['filtergroup'][adindex]['checklist'][i]['selected'] = false;
                        }

                    }
                }
                this.changeFilter();
            },
            //筛选器修改事件
            changeFilter(){
                let that = this;
                let haveSelectedData = [];
                let ConditionalNum = 0;
                let tmp_provaluelist = [];
                if(that.FilterBaseData && that.FilterBaseData.filtergroup.length > 0){
                    let FilterBaseData = that.FilterBaseData;
                    for(let i = 0; i < FilterBaseData.filtergroup.length; i++){
                        if(FilterBaseData.filtergroup[i].checklist && FilterBaseData.filtergroup[i].checklist.length > 0){
                            let checklist = FilterBaseData.filtergroup[i].checklist;
                            let checklist_select_arr = [];
                            for(let j = 0; j < checklist.length; j++){
                                if(checklist[j].selected){
                                    that.FilterBaseData.filtergroup[i].checklist[j].indeterminate = false;
                                    checklist_select_arr.push({label:checklist[j].label,value:checklist[j].value});
                                    ConditionalNum++;
                                }
                                else if(checklist[j].indeterminate){
                                    checklist_select_arr.push({label:checklist[j].label,value:checklist[j].value});
                                    ConditionalNum++;
                                }
                                else{
                                    that.FilterBaseData.filtergroup[i].checklist[j].selected = false;
                                    that.FilterBaseData.filtergroup[i].checklist[j].indeterminate = false;
                                }
                            }
                            if(checklist_select_arr.length > 0){
                                haveSelectedData.push({
                                    label: FilterBaseData.filtergroup[i].label,
                                    value: FilterBaseData.filtergroup[i].value,
                                    itemlist: checklist_select_arr
                                });
                            }
                        }
                    }
                }
                if(that.FilterAdvanceData && that.FilterAdvanceData.filtergroup.length > 0){
                    let FilterAdvanceData = that.FilterAdvanceData;
                    for(let i = 0; i < FilterAdvanceData.filtergroup.length; i++){
                        if(FilterAdvanceData.filtergroup[i].checklist && FilterAdvanceData.filtergroup[i].checklist.length > 0){
                            let checklist = FilterAdvanceData.filtergroup[i].checklist;
                            let checklist_select_arr = [];
                            for(let j = 0; j < checklist.length; j++){
                                if(checklist[j].selected){
                                    checklist_select_arr.push({label:checklist[j].label,value:checklist[j].value});
                                    ConditionalNum++;
                                }
                            }
                            if(checklist_select_arr.length > 0){
                                haveSelectedData.push({
                                    label: FilterAdvanceData.filtergroup[i].label,
                                    value: FilterAdvanceData.filtergroup[i].value,
                                    itemlist: checklist_select_arr
                                });
                            }
                        }
                    }
                }
                this.haveSelectedData = haveSelectedData;
                this.ConditionalNum = ConditionalNum;
                this.submitForm();
            },
            //移除筛选项
            removeFilter(group,item){
                let that = this;
                if(that.FilterBaseData && that.FilterBaseData.filtergroup.length > 0){
                    let FilterBaseData = that.FilterBaseData;
                    for(let i = 0; i < FilterBaseData.filtergroup.length; i++){
                        if(group.value == FilterBaseData.filtergroup[i].value){
                            let checklist = FilterBaseData.filtergroup[i].checklist;
                            for(let j = 0; j < checklist.length; j++){
                                if(checklist[j].value == item.value){
                                    that.FilterBaseData.filtergroup[i].checklist[j].selected = false;
                                    that.FilterBaseData.filtergroup[i].checklist[j].indeterminate = false;
                                    if(group.value == 'province' && that.regionoptions.province){
                                        var item = {};
                                        item.position = [j];
                                        that.removeedregion(item);
                                        that.FilterBaseData.filtergroup[i].checklist = that.regionoptions.province;
                                    }
                                    break;
                                }
                            }
                            break;
                        }
                    }
                }
                if(that.FilterAdvanceData && that.FilterAdvanceData.filtergroup.length > 0){
                    let FilterAdvanceData = that.FilterAdvanceData;
                    for(let i = 0; i < FilterAdvanceData.filtergroup.length; i++){
                        if(group.value == FilterAdvanceData.filtergroup[i].value){
                            let checklist = FilterAdvanceData.filtergroup[i].checklist;
                            for(let j = 0; j < checklist.length; j++){
                                if(checklist[j].value == item.value){
                                    that.FilterAdvanceData.filtergroup[i].checklist[j].selected = false;
                                    break;
                                }
                            }
                            break;
                        }
                    }
                }
                that.changeFilter();
            },
            //移除所有筛选项
            removeAllFilter(){
                let that = this;
                that.haveSelectedData = [];
                that.ConditionalNum = 0;
                if(that.FilterBaseData && that.FilterBaseData.filtergroup.length > 0){
                    let FilterBaseData = that.FilterBaseData;
                    for(let i = 0; i < FilterBaseData.filtergroup.length; i++){
                        if(FilterBaseData.filtergroup[i].checklist && FilterBaseData.filtergroup[i].checklist.length > 0){
                            let checklist = FilterBaseData.filtergroup[i].checklist;
                            for(let j = 0; j < checklist.length; j++){
                                that.FilterBaseData.filtergroup[i].checklist[j].selected = false;
                                that.FilterBaseData.filtergroup[i].checklist[j].indeterminate = false;
                            }
                        }
                    }
                }
                if(that.FilterAdvanceData && that.FilterAdvanceData.filtergroup.length > 0){
                    let FilterAdvanceData = that.FilterAdvanceData;
                    for(let i = 0; i < FilterAdvanceData.filtergroup.length; i++){
                        if(FilterAdvanceData.filtergroup[i].checklist && FilterAdvanceData.filtergroup[i].checklist.length > 0){
                            let checklist = FilterAdvanceData.filtergroup[i].checklist;
                            for(let j = 0; j < checklist.length; j++){
                                that.FilterAdvanceData.filtergroup[i].checklist[j].selected = false;
                            }
                        }
                    }
                }
                if(that.regionoptions.province){
                    that.removeALledregion();
                    for(let i = 0;i<this.FilterBaseData.filtergroup.length;i++){
                        if(that.FilterBaseData.filtergroup[i].value == 'province'){
                            that.FilterBaseData.filtergroup[i].checklist = that.regionoptions.province;
                            break;
                        }
                    }
                }

                that.changeFilter();
            },
            //展开收起
            ExpandBaseFilterEvent(){
                if(this.ExpandBaseFilter){
                    this.ExpandBaseFilter = false;
                    this.toggleToolTip = '更多筛选';
                    this.baseFilterHeight = 4;
                }
                else{
                    this.ExpandBaseFilter = true;
                    this.toggleToolTip = '收起筛选';
                    this.baseFilterHeight = 10000;
                }
            }
        },
        provide() {
            return {
                module: this.module,
                current_user_id: this.current_user_id,
            };
        },
        mounted() {
            this.getFilterInfo();
        },
        inject: ['module','current_user_id'],
    };
}
