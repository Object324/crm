function SearchAccounts(){
    return {
        template: `
            <div class="ld_mainpagecontent" style="background:#FFF;"><!-- style="background:#FFF;"-->
                <div class="ld-home-search-header">
                    <div class="ld-home-search-header-content">
                        <div class="ld_search_toptitle">
                            <span>{{title}}</span>
                        </div>
                        <div class="ld_search_input">
                            <div class="ld_search_input-group">
                                <div class="ld_search_input-wrapper">
                                    <input class="ld_search_input-inner" v-model="searchtext" :placeholder="placeholder" type="text" @keyup.enter="searchchangeevent"/>
                                    <el-button class="ld_search_input-btn" type="primary" @click="searchevent"><i class="el-icon-search"></i>{{searchbuttontext}}</el-button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <!--  style="display:none;" -->
                <div class="ld-container" style="display:none;">
                    <div class="ld-container-header">
                        <div class="ld-container-header-left">
                            <img src="img/icon/industry.png">
                            <span>行业标签</span>
                        </div>
                        <div class="ld-container-header-right">
                        </div>
                    </div>
                    <div class="ld-container-tab">
                        <el-tabs type="border-card" class="demo-tabs">
                            <el-tab-pane label="原材料">
                                <div class="ld-home-tab-content">
                                    <span>建材1</span><span>纺织1</span><span>农业1</span>
                                    <span>建材4</span><span>纺织5</span><span>农业6</span>
                                </div>
                            </el-tab-pane>
                            <el-tab-pane label="工业品">
                                <div class="ld-home-tab-content">
                                    <span>建材一</span><span>纺织二</span><span>农业三</span>
                                    <span>建材四</span><span>纺织五</span><span>农业六</span>
                                </div>
                            </el-tab-pane>
                            <el-tab-pane label="消费品">
                                <div class="ld-home-tab-content">
                                    <span>建材A</span><span>纺织B</span><span>农业C</span>
                                    <span>建材D</span><span>纺织E</span><span>农业F</span>
                                </div>
                            </el-tab-pane>
                            <el-tab-pane label="商业服务">
                                <div class="ld-home-tab-content">
                                    <span>建材a</span><span>纺织b</span><span>农业c</span>
                                    <span>建材d</span><span>纺织e</span><span>农业f</span>
                                </div>
                            </el-tab-pane>
                        </el-tabs>
                    </div>
                </div>
                <div class="ld-container" style="display:none;">
                    <div class="ld-container-header">
                        <div class="ld-container-header-left">
                            <img src="img/icon/location.png">
                            <span>附近客户</span>
                        </div>
                        <div class="ld-container-header-right">
                            <span>查看更多 ></span>
                        </div>
                    </div>
                    <div class="ld-container-content">
                        <div class="ld-container-content-card">
                            <el-card shadow="hover">
                                <div class="ld-container-content-card-content">
                                    <div class="ld-container-content-card-title">
                                        扬州母婴缘百货超市有限公司
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        赵四儿  |  2018-06-12  |  4674.90万人民币
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        所属行业：贸易业
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        距你3.5公里
                                    </div>
                                </div>
                            </el-card>
                            <el-card shadow="hover">
                                <div class="ld-container-content-card-content">
                                    <div class="ld-container-content-card-title">
                                        扬州母婴缘百货超市有限公司
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        赵四儿  |  2018-06-12  |  4674.90万人民币
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        所属行业：贸易业
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        距你3.5公里
                                    </div>
                                </div>
                            </el-card>
                            <el-card shadow="hover">
                                <div class="ld-container-content-card-content">
                                    <div class="ld-container-content-card-title">
                                        扬州母婴缘百货超市有限公司
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        赵四儿  |  2018-06-12  |  4674.90万人民币
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        所属行业：贸易业
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        距你3.5公里
                                    </div>
                                </div>
                            </el-card>
                            <el-card shadow="hover">
                                <div class="ld-container-content-card-content">
                                    <div class="ld-container-content-card-title">
                                        扬州母婴缘百货超市有限公司
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        赵四儿  |  2018-06-12  |  4674.90万人民币
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        所属行业：贸易业
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        距你3.5公里
                                    </div>
                                </div>
                            </el-card>
                            <el-card shadow="hover">
                                <div class="ld-container-content-card-content">
                                    <div class="ld-container-content-card-title">
                                        扬州母婴缘百货超市有限公司
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        赵四儿  |  2018-06-12  |  4674.90万人民币
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        所属行业：贸易业
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        距你3.5公里
                                    </div>
                                </div>
                            </el-card>
                            <el-card shadow="hover">
                                <div class="ld-container-content-card-content">
                                    <div class="ld-container-content-card-title">
                                        扬州母婴缘百货超市有限公司
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        赵四儿  |  2018-06-12  |  4674.90万人民币
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        所属行业：贸易业
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        距你3.5公里
                                    </div>
                                </div>
                            </el-card>
                            <el-card shadow="hover">
                                <div class="ld-container-content-card-content">
                                    <div class="ld-container-content-card-title">
                                        扬州母婴缘百货超市有限公司
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        赵四儿  |  2018-06-12  |  4674.90万人民币
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        所属行业：贸易业
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        距你3.5公里
                                    </div>
                                </div>
                            </el-card>
                            <el-card shadow="hover">
                                <div class="ld-container-content-card-content">
                                    <div class="ld-container-content-card-title">
                                        扬州母婴缘百货超市有限公司
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        赵四儿  |  2018-06-12  |  4674.90万人民币
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        所属行业：贸易业
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        距你3.5公里
                                    </div>
                                </div>
                            </el-card>
                            <el-card shadow="hover">
                                <div class="ld-container-content-card-content">
                                    <div class="ld-container-content-card-title">
                                        扬州母婴缘百货超市有限公司
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        赵四儿  |  2018-06-12  |  4674.90万人民币
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        所属行业：贸易业
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        距你3.5公里
                                    </div>
                                </div>
                            </el-card>
                            <el-card shadow="hover">
                                <div class="ld-container-content-card-content">
                                    <div class="ld-container-content-card-title">
                                        扬州母婴缘百货超市有限公司
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        赵四儿  |  2018-06-12  |  4674.90万人民币
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        所属行业：贸易业
                                    </div>
                                    <div class="ld-container-content-card-subtitle">
                                        距你3.5公里
                                    </div>
                                </div>
                            </el-card>
                        </div>
                    </div>
                </div>
            </div>
        `,
        data() {
            return {
                searchtext: '',
                searchcolumn: 'corpname',
                searchbuttontext: '搜一搜',
                title: '找企业，就上搜客宝',
                placeholder: '请输入公司名称'
            };
        },
        props: {
            message: Object
        },
        methods: {
            searchchangeevent(){
                let that = this;
                that.searchevent();
            },
            searchevent(){
                let that = this;
                that.searchByText('ConditionalCustomer',that.searchtext,that.searchcolumn);
            }
        },
        mounted() {
            let that = this;
            let param = {};
            param['module'] = 'ldsoukebao';
            param['action'] = 'ldsoukebaoAjax';
            param['file'] = 'soukebaoindex';
            param['getfile'] = 'SearchAccounts';
            Skb_Ajax(param,function (ajaxdata){
                that.title = ajaxdata.result.title;
                that.placeholder = ajaxdata.result.placeholder;
                that.searchbuttontext = ajaxdata.result.searchbuttontext;
            });
        },
        inject: ['searchByText'],
    };
}
