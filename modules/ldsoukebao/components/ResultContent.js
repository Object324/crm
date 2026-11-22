function ResultContent(){

    return {
        template: `
            <!-- list所在界面  -->
            <div>
                <div class="flex ldtabeltotal">
                    <span class="ldtabeltotal_text">共</span><span class="ldtabeltotal_count">{{resultcountStr}}</span><span style="margin-left: 4px;" class="ldtabeltotal_text">个</span>
                    
                    <template v-if="multipleSelection.length > 0">
                        <span style="margin: 0 10px;">|</span>
                        <span class="ldtabeltotal_multitext">已选</span>
                        <span class="ldtabeltotal_multinum">{{multipleSelection.length}}</span>
                        <span class="ldtabeltotal_multitext">条</span>
                        <span class="ldtabeltotal_importselect fontcolor_link" style="margin: 0;width: 56px;height: 20px;overflow-wrap: break-word;color: rgba(59, 124, 255, 1);font-size: 14px;font-family: PingFangSC-Regular;font-weight: normal;text-align: left;white-space: nowrap;line-height: 20px;display: flex;" @click="ImportSelectedToCRM"><img src="img/icon/import_ico.png?" v-if="multipleSelection.length>0" style="width: 16px; height: 16px; margin: 3px 1px 1px 15px;">导入选中</span>
                    
                    </template>
                    
                        
                    <div class="ld-flex-end ld-flex-wrap" v-if="isadmin" style="margin-left: auto;">
                        <i class="ld-listview-setting-icon" @click="SettingImportmodule"></i>
                    </div>
                </div>
                <el-table
                    :data="tableData"
                    v-loading="loading"
                    style="width: 100%"
                    class="ldcustomertable"
                    empty-text="没有查询到企业"
                    @selection-change="handleSelectionChange"
                    @row-click="rowClick"
                >
                    <el-table-column type="selection" width="38" />
                    <el-table-column>
                        <template #header>
                            <div class="flex" style="align-items: center;">
                                <span>企业名片</span>
                            </div>
                        </template>
                        <template #default="scope">
                            <div class="padtb8">
                                <div class="flex">
                                    <div class="companyname">
                                        <span v-html="scope.row.data.namelabel"></span>
                                        <span class="regstatus" :style="{color: 'rgb('+ scope.row.data.regstatus.color +')', background: 'rgba('+ scope.row.data.regstatus.color +',0.09)'}" v-if="scope.row.data.regstatus">{{ scope.row.data.regstatus.text }}</span>
                                    </div>
                                </div>
                                <div class="flex">
                                    <div style="width: 65%;">
                                        <template v-if="scope.row.data.otherinfo" v-for="(otherinfo,indexrow) in scope.row.data.otherinfo">
                                            <div class="flex">
                                                <template v-if="otherinfo.length > 0" v-for="(iteminfo,indexcol) in otherinfo">
                                                    <div class="flex infogroup" style="max-width: calc(33% - 24px);">
                                                        <span class="ldtabletd_label">{{iteminfo.label}}：</span>
                                                        <span class="ldtabletd_value fontnowrap" :title="iteminfo.text">{{iteminfo.text}}</span>
                                                    </div>
                                                </template>
                                                <template v-else>
                                                    <span class="ldtabletd_label">{{otherinfo.label}}：</span>
                                                    <span class="ldtabletd_value fontnowrap" :title="otherinfo.text">{{otherinfo.text}}</span>
                                                </template>
                                            </div>
                                        </template>
                                    </div>
                                    <div style="width: 35%;padding-left: 12px;">
                                        <template v-for="(contactinfo,index) in scope.row.contactinfo">
                                            <div class="flex">
                                                <span class="ldtabletd_label">{{contactinfo.label}}：</span>
                                                <span class="ldtabletd_value fontnowrap" :title="contactinfo.text">{{contactinfo.text}}</span>
                                            </div>
                                        </template>
                                    </div>
                                </div>
                            </div>
                        </template>
                    </el-table-column>
                    <!--<el-table-column label="联系方式">
                        <template #default="scope">
                            <div class="padtb15">
                                <template v-for="(contactinfo,index) in scope.row.contactinfo">
                                    <div class="flex">
                                        <span class="ldtabletd_label">{{contactinfo.label}}：</span>
                                        <span class="ldtabletd_value">{{contactinfo.text}}</span>
                                    </div>
                                </template>
                            </div>
                        </template>
                    </el-table-column>-->
                    <el-table-column label="操作" width="140">
                        <template #default="scope">
                            <div class="padtb8">
                                <template v-for="operationbtn in scope.row.operation">
                                    <el-button type="info" plain v-if="operationbtn.disabled" disabled>{{operationbtn.label}}</el-button>
                                    <el-button type="primary" @click="ImportToCRM(scope.row.id)" style="background-color: #3B7CFF;" v-else>{{operationbtn.label}}{{importmodulename}}</el-button>
                                </template>
                            </div>
                        </template>
                    </el-table-column>
                    <template #empty>
                        <div class="warningTableContent" style="padding-top: 30px;">
                            <div class="wtc_img"><img style="width: 280px;" src="../../themes/icon2023/ld-no-records.png?v=8630"></div>
                            <div class="wtc_content">未查询到企业，请重新搜索</div>
                        </div>
                    </template>
                </el-table>
            </div>
            <div class="ldpagination" :style="{width:ldpaginationwidth,display: pagecount > 0 ? '' : 'none'}">
                <!--<el-pagination background 
                    @size-change="handleSizeChange"
                    @current-change="handleCurrentChange"
                    v-model:current-page="currentPage"
                    :page-sizes="[10, 20, 50, 100]"
                    v-model:page-size="pagesize"
                    v-model:total="pagecount"
                    layout="sizes, prev, pager, next, jumper">
                </el-pagination>-->
                <div id="ld_list_pageination"></div>
            </div>
            <el-dialog class="importmodule" v-model="dialogImport" title="导入数据" width="800" :close-on-click-modal="false" :close-on-press-escape="false" :before-close="closedialogImport" :show-close="false">
                <el-progress :text-inside="true" :stroke-width="24" v-if="importStatue" :percentage="progressWidth" status="success"/>
                <div style="max-height: 320px;overflow: hidden auto;" :style="!importStatue ? '': 'margin: 20px 0;'">
                    <div style="line-height: 24px;font-size: 14px;color: var(--ld-font-color-primary);padding: 0px 8px;" v-for="(itemlog,index) in importLog"  track-by="">
                        <span v-html="itemlog"></span>
                    </div>
                </div>
                <template #footer>
                    <div class="dialog-footer">
                        <el-button type="primary" @click="closedialogImport" disabled v-if="importStatue">确认</el-button>
                        <el-button type="primary" @click="closedialogImport" v-else>确认</el-button>
                    </div>
                </template>
            </el-dialog>
            <el-drawer
                v-model="innerDrawer"
                size="50%"
                :append-to-body="true"
                :before-close="handleClose">
                <template #header="{ close, titleId, titleClass }">
                    <span>{{innerDrawer_title}}</span>
                </template>
                <p>第二层</p>
            </el-drawer>
            <el-drawer
                class="drawersetting"
                v-model="settingDrawer"
                size="300"
                modal-class="bgfff0" 
                :before-close="cancelImportModule">
                <template #header>
                    <div class="flex ld_drawer_header" style="width: 100%;height: 50px;align-items: center;"><span style="font-size: 18px;color: #323232;">设置</span></div>
                </template>
                <template #default>
                    <div>
                        <el-collapse v-model="activeNames">
                            <el-collapse-item title="企业导入路径设置" name="importmodule" style="font-size: 15px;">
                                <template #default>
                                    <div style="padding: 0 24px;">
                                        <el-radio-group v-model="importmodulebefore" class="ml-4">
                                            <el-radio :value="moduelitem.value" size="large" v-for="moduelitem in importModuleList">{{moduelitem.label}}</el-radio>
                                        </el-radio-group>
                                    </div>
                                </template>
                            </el-collapse-item>
                        </el-collapse>
                    </div>
                </template>
                <template #footer>
                    <div style="height: 58px;width: 100%;background: #F7F9FB;text-align: center;">
                        <div class="flex" style="height: 100%;align-items: center;margin: 0 auto;">
                        <div style="margin:auto;">
                            <el-button type="primary" @click="saveImportModule" style="margin-right: 16px;">保存</el-button>
                            <el-button @click="settingDrawer = false;importmodulebefore = importmodule" style="border: 1px solid #DCDFE6;">取消</el-button></div>
                        </div>
                    </div>
                </template>
            </el-drawer>
        `,
        data() {
            return {
                loading:false,
                isadmin:false,
                searchcriteria: {},
                currentPage: 1,//当前页码
                pagesize: 10,//每页多少条
                resultcountStr: 0,//单据总数
                pagecount: 0,//下面显示总条数
                tableData : [],//表单数据
                multipleSelection:[],//表单多选选中单据
                innerDrawer: false,//详情弹窗是否开启
                innerDrawer_title : '',//相亲页头部
                ldpaginationwidth: '',//分页宽度
                dialogImport: false,//导入弹出框
                cropidarr: [],//需要后续导入的id
                cropidtonamearr: [],//导入id对应的name
                importStatue: false,
                progressWidth: 0,//进度条长度
                importLog: [],//导入日志
                intervalimportcount: 10,//批导入数据条数
                settingDrawer: false,
                importModuleList: [],
                importmodule: '',
                importmodulebefore: '',
                activeNames: 'importmodule',
                importmodulename: '',
            };
        },
        props: {
            message: Object
        },
        methods: {
            //获取查询结果
            getTableContent(){
                if(this.message.searchcriteria){
                    this.searchcriteria = this.message.searchcriteria;
                }
                if(this.message.ldpaginationwidth){
                    this.ldpaginationwidth = this.message.ldpaginationwidth;
                }
                if(sessionStorage.getItem('ld_soukebao_list_pagesize') != null){
                    this.pagesize = parseInt(sessionStorage.getItem('ld_soukebao_list_pagesize'));
                }
                this.submitSearch();
            },
            //查询
            submitSearch(){
                let that = this;
                let param = {};
                param = that.searchcriteria;
                param['currentPage'] = that.currentPage;
                param['pagesize'] = that.pagesize;
                param['module'] = that.module;
                param['action'] = that.module+'Ajax';
                param['file'] = 'soukebaoindex';
                param['getfile'] = 'ResultContent';
                that.loading = true;
                Skb_Ajax(param,function (data) {
                    if(data.code == 1){
                        that.loading = false;
                        if(data.result.list && data.result.list.length > 0){
                            that.tableData = data.result.list;
                        }
                        if(data.result.currentpage){
                            that.currentpage = parseInt(data.result.currentpage);
                        }
                        if(data.result.isadmin){
                            that.isadmin = data.result.isadmin;
                        }
                        if(data.result.pagecount){
                            that.pagecount = parseInt(data.result.pagecount);
                        }
                        if(data.result.pagecountstr){
                            that.resultcountStr = data.result.pagecountstr;
                        }
                        if(data.result.pagesize){
                            that.pagesize = parseInt(data.result.pagesize);
                        }
                        if(data.result.importmodulename){
                            that.importmodulename = data.result.importmodulename;
                        }
                        if(that.importModuleList.length < 1 && data.result.importModuleList){
                            that.importModuleList = data.result.importModuleList;
                            that.importmodule = data.result.importmodule;
                            that.importmodulebefore = data.result.importmodule;
                        }
                        document.getElementById('pagecontent').scrollTop = 0;
                        that.ShowPageination();
                    }
                })

            },
            //分页事件
            handleSizeChange(number){
                this.pagesize = number;
                this.currentPage = 1;
                sessionStorage.setItem('ld_soukebao_list_pagesize',number);
                this.submitSearch();
            },
            handleCurrentChange(pagenum){
                this.currentPage = pagenum;
                this.submitSearch();
            },
            //表单选择-多选
            handleSelectionChange(rowdata){
                this.multipleSelection = rowdata;
            },
            //打开详情
            rowClick(rowdata){
                return;
                if(rowdata.data){
                    this.innerDrawer_title = rowdata.data.name;
                }
                this.innerDrawer = true;
            },
            //关闭详情弹出层
            handleClose(){
                this.innerDrawer = false;
            },
            //导入按钮
            ImportToCRM(id){
                this.ImportsoukebaoTocrm(id);
            },
            //导入已选中
            ImportSelectedToCRM(){
                if(this.multipleSelection.length > 0){
                    if(this.multipleSelection.length == 1){
                        for(let i = 0;i<this.tableData.length;i++){
                            if(this.tableData[i].id == this.multipleSelection[0].id){
                                if(this.tableData[i].operation[0].disabled == true){
                                    var msg_str = this.multipleSelection[0].data.namelabel + this.importmodulename + '已导入过,跳过!';
                                    parent.MessagePopup.TipZero_error(msg_str);
                                    return;
                                }
                                break;
                            }
                        }
                        this.multipleSelection[0]
                    }
                    let cropidarr = [];
                    for(let i = 0;i<this.multipleSelection.length;i++){
                        cropidarr.push(this.multipleSelection[i].id);
                    }
                    if(cropidarr.length > 1){
                        parent.showCrmOverlay();
                        this.dialogImport = true;
                        this.importStatue = true;
                        this.progressWidth = 0;
                    }

                    this.ImportsoukebaoTocrm(cropidarr);
                }
            },
            ImportsoukebaoTocrm(cropidarr){
                let maxtimes = 1;
                let totalrows = 1;
                if(typeof cropidarr == 'object'){
                    let cropidnamearr = [];
                    totalrows = cropidarr.length;
                    let intervalimportcount = this.intervalimportcount;
                    if(cropidarr.length > 0){
                        maxtimes = Math.ceil(cropidarr.length/intervalimportcount);
                    }
                    if(maxtimes > 1){
                        cropidnamearr = cropidarr.splice(0,intervalimportcount);
                        this.cropidarr = cropidarr;
                        cropidarr = cropidnamearr;
                    }
                }
                this.ImportsoukebaoData(maxtimes,1,cropidarr,0,totalrows);
            },
            //导入访问后台
            ImportsoukebaoData(maxtimes,currenttimes,cropidarr,logid,totalrows){
                let that = this;
                let param = {};
                let cropids = '';

                let importcroptonamearr = {};
                if(typeof cropidarr == 'object') {
                    let importnum = cropidarr.length;
                    for (let i = 0; i < importnum; i++) {
                        for (let j = 0; j < this.tableData.length; j++) {
                            if (cropidarr[i] == this.tableData[j].id) {
                                importcroptonamearr[this.tableData[j].id] = this.tableData[j].data.name;
                                break;
                            }
                        }
                    }
                    cropids = cropidarr.toString();
                }
                else{
                    cropids = cropidarr;
                    for (let j = 0; j < this.tableData.length; j++) {
                        if (cropidarr == this.tableData[j].id) {
                            importcroptonamearr[this.tableData[j].id] = this.tableData[j].data.name;
                            break;
                        }
                    }
                }
                param['module'] = that.module;
                param['action'] = that.module+'Ajax';
                param['file'] = 'soukebaoindex';
                param['getfile'] = 'ImportsoukebaoTocrm';
                param['cropidarr'] = cropids;
                param['cropidtonamearr'] = importcroptonamearr;
                param['maxtimes'] = maxtimes;
                param['totalrows'] = totalrows;
                param['intervalimportcount'] = this.intervalimportcount;
                param['currenttimes'] = currenttimes;
                param['logid'] = logid;
                Skb_Ajax(param,function (data) {
                    if(data.code == 1){
                        if((maxtimes == 1 && cropidarr.length == 1) || typeof cropidarr != 'object'){
                            if(data.result.log.length && data.result.log.length > 0){
                                parent.MessagePopup.TipZero_success(data.result.log[0]);
                                for(let i = 0;i<that.tableData.length;i++){
                                    if(that.tableData[i].id == cropids){
                                        that.tableData[i].operation[0].disabled = true;
                                        that.tableData[i].operation[0].label = '已导入';
                                        break;
                                    }
                                }
                            }
                        }
                        else{
                            that.importLog = [];
                            if(data.result.log.length && data.result.log.length > 0){
                                for(let i = 0;i<data.result.log.length;i++){
                                    that.importLog.push(data.result.log[i]);
                                }
                            }
                            that.progressWidth = currenttimes/maxtimes*100;
                            let new_currenttimes = currenttimes + 1;
                            if(new_currenttimes > maxtimes){
                                that.cropidarr = [];
                                that.importStatue = false;
                                return ;
                            }
                            let new_logid = data.result.logid;
                            let cropidnamearr = [];
                            var tmp_cropidarr = that.cropidarr;
                            let num = tmp_cropidarr.length;
                            let intervalimportcount = that.intervalimportcount;
                            if(num > intervalimportcount){
                                cropidnamearr = tmp_cropidarr.splice(0,intervalimportcount);
                                that.cropidarr = tmp_cropidarr;
                                tmp_cropidarr = cropidnamearr;
                            }else{
                                that.cropidarr = [];
                            }
                            that.ImportsoukebaoData(maxtimes,new_currenttimes,tmp_cropidarr,new_logid,totalrows);
                        }
                    }else if(data.code == -1){
                        this.dialogImport = false;
                        this.importStatue = false;
                        this.cropidarr = [];
                        ElementPlus.ElMessageBox.alert(data.msg, '提示', {
                            confirmButtonText: '确定',
                        })
                    }

                })
            },
            //关闭crm遮盖层
            closedialogImport(){
                parent.hideCrmOverlay();
                this.dialogImport = false;
                this.importLog = [];
                this.getTableContent();
            },
            //显示页码
            ShowPageination(){
                let that = this;
                let listviewpaginationObj = document.getElementById('ld_list_pageination');
                if(listviewpaginationObj != undefined){
                    let count = Math.ceil(that.pagecount/that.pagesize);
                    let pagepernumarr = [{label:'10条/页',value:10,selected:false}, {label:'20条/页',value:20,selected:false}, {label:'50条/页',value:50,selected:false}, {label:'100条/页',value:100,selected:false}];
                    for(let i = 0;i<pagepernumarr.length;i++){
                        if(pagepernumarr[i].value == that.pagesize){
                            pagepernumarr[i].selected = true;
                            break;
                        }
                    }
                    var tmp_pagedata = {
                        'currentpage': that.currentPage,
                        'count': that.pagecount,
                        'pagecount': count,
                        'changepage': function (pagenum){
                            if(document.querySelector('#mapcustomer_resultdrawer .el-drawer__body') != null){
                                document.querySelector('#mapcustomer_resultdrawer .el-drawer__body').scrollTop = 0;
                            }
                            that.handleCurrentChange(pagenum);
                        },
                        'pagepernumarr': pagepernumarr,
                        'changepagecount': function (evt){
                            that.handleSizeChange(evt.NavBarItem.value);
                        }
                    }
                    ld_Pagination.showPagination(listviewpaginationObj, tmp_pagedata);
                }
            },
            //设置导入模块
            SettingImportmodule(){
                this.settingDrawer = true;
            },
            saveImportModule(){
                let that = this;
                that.importmodule = that.importmodulebefore;
                that.settingDrawer = false;
                let param = {};
                param['module'] = that.module;
                param['action'] = that.module+'Ajax';
                param['file'] = 'soukebaoindex';
                param['getfile'] = 'soukebaoSetting';
                param['mode'] = 'importmodule';
                param['importmodule'] = that.importmodule;
                Skb_Ajax(param,function (data) {
                    if(data.code == 1){
                        if(data.result.importmodulename){
                            that.importmodulename = data.result.importmodulename;
                        }
                    }
                });
            },
            cancelImportModule(){
                this.importmodulebefore = this.importmodule;
                this.settingDrawer = false;
            },
        },
        mounted() {
            let that = this;
            if(that.message.searchcriteria){
                that.getTableContent();
            }
        },
        inject: ['module','current_user_id'],
    };
}
