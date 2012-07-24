Ext.define('Vmoss.view.main.button.GridDestroy', {
    extend:'Ext.button.Button',

    text:'删除',
    iconCls:"icon-delete",

    handler:function () {
        var grid = this,
            selected = grid.selModel.getSelection();

        if (selected.length > 0) {
            Ext.Msg.confirm('提示信息', '确实要删除选中的' + grid.instanceLabel + '吗?', function (confirm) {
                if (confirm === 'yes') {
                    Ext.each(selected, function (instance) {
                        instance.destroy();
                    });
                    grid.store.load();
                }
            })
        } else {
            Vmoss.Tool.promptBox('错误操作', '请选择' + grid.instanceLabel + '!')
        }
    },

// '删除'按钮构造
    initComponent:function () {
        this.tooltip = '删除选中的' + this.instanceLabel;
        this.callParent(arguments);
    }
});