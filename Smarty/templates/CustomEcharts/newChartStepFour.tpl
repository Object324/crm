            <div class="set-info" id="condition_set">
                <div class="base-info">
                    <form id="info4">
                    <div style="display:flex;justify-content: flex-end;margin-bottom: 10px;">
                        <div class="btn btn-primary" id="addNewConditionGroup" data-groupid="1" onclick="selfDefinedReport.addNewConditionGroup(this);">添加组合条件</div>
                    </div>
                    <table class="table">
                    <thead>
                    <tr>
                        <th scope="col" width="10%">选择字段</th>
                        <th scope="col" width="10%">选择条件</th>
                        <th scope="col" width="20%">关键词</th>
                        <th scope="col" width="5%">选择关系</th>
                        <th scope="col" width="5%">操作</th>
                    </tr>
                    </thead>
                    <tbody id="highSearch">
                    </tbody>
                </table>
                    </form>
                    <div>
                        <div onclick="selfDefinedReport.beforeStep(4)" type="button" class="btn btn-light">{'ASTEP'|@getFixedLabel}</div>
                        <div onclick="selfDefinedReport.nextStep(4)" class="btn btn-primary">{'NEXTSTEP'|@getFixedLabel}</div>
                        <button onclick="selfDefinedReport.nextStep(4,'preview')" type="button" class="btn btn-primary">{'PREVIEW'|@getFixedLabel}</button>
                    </div>
                </div>
            </div>