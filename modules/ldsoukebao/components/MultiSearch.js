function MultiSearch(){
    return {
        template: `
            <div class="ld_mainpagecontent">
                <div class="ld-search-filter">
                    <el-text size="large" tag="b">
                   行业模板
                   </el-text>
                </div>
                
                <div style="background: #fff;margin-top: 20px;">
                    查找条件
                </div>
                <div style="background: #fff;margin-top: 20px;">
                    <component :is="ResultContent"></component>
                </div>
            </div>
        `,
        data() {
            return {
                ResultContent: {}
            };
        },
        props: {
            message: Object
        },
        methods: {
        },
        mounted() {
            this.ResultContent = ResultContent();
        },
        inject: [],
    };
}
