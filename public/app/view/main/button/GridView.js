Ext.define('Vmoss.view.main.button.GridView', {
    extend:'Ext.button.Button',

    text:'查看',
    iconCls:"icon-view",

    handler:function () {
        var grid = this,
            selected = grid.selModel.getSelection();

        if (selected.length == 0) {
            Vmoss.Tool.promptBox('错误操作', '请选择!');
        } else if (selected.length > 1) {
            Vmoss.Tool.promptBox('错误操作', '请选择一个' + grid.instanceLabel + '进行修改!');
        } else {
            Ext.create('Vmoss.view.main.ModifyView', {
                selInstance:selected[0],
                instanceLabel:grid.instanceLabel,
                modelField:(grid.featureList.modfiyFeature || grid.featureList.benchFeature)
            }).viewVersion().show();
        }
    },

// '查看'按钮构造
    initComponent:function () {
        this.tooltip = '查看选中的' + this.instanceLabel;
        this.callParent(arguments);
    }
});