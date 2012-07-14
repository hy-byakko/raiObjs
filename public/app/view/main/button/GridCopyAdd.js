Ext.define('Vmoss.view.main.button.GridCopyAdd', {
    extend:'Ext.button.Button',

    text:'复制添加',
    iconCls:"icon-add",

    handler:function () {
        var selected = grid.getSelectionModel().getSelections();
        if (selected.length == 0) {
            Ext.MessageBox.show({
                title:'错误信息',
                msg:'请选择' + objName + '!',
                buttons:Ext.MessageBox.OK,
                icon:Ext.MessageBox.ERROR
            });
        } else if (selected.length > 1) {
            Ext.MessageBox.show({
                title:'错误信息',
                msg:'请能选择一个' + objName + '进行复制添加!',
                buttons:Ext.MessageBox.OK,
                icon:Ext.MessageBox.ERROR
            });
        } else {
            grid.suspendEvents();
            window.location.href = '/bumons/new' + '/' + selected[0].data.id;
        }
    },

// '复制添加'按钮构造
    initComponent:function () {
        this.tooltip = "复制添加新的" + this.instanceLabel,
            this.callParent(arguments);
    }
});