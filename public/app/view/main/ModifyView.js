/**
 * ExtendConfig:
 * selInstance:Model,
 * instanceLabel:String,
 * modelField:Array
 */
Ext.define('Vmoss.view.main.ModifyView', {
    extend:'Ext.window.Window',

    resizable:false,
    modal:true,
    layout:'fit',

    initComponent:function () {
        var me = this,
            modelBench = Ext.create('Vmoss.view.main.ModelBench', {
                bind:me.selInstance,
                modelField:me.modelField
            }),
            editButton = Ext.create('Ext.button.Button', {
                text:"修改",
                iconCls:'icon-change',
                handler:function (button) {
                    me.editVersion();
                }
            }),
            saveButton = Ext.create('Ext.button.Button', {
                text:"保存",
                iconCls:'icon-save',
                handler:function (button) {
                    modelBench.modelSubmit({
                        success:function () {
                            me.destroy();
                        }
                    })
                }
            });

        me.selInstance.singleLoad();
        Vmoss.Tool.cacheById(me.selInstance);

        Ext.apply(me, {
            title:'修改' + me.instanceLabel,
            items:[
                modelBench
            ],
            modelBench:modelBench,
            editButton:editButton,
            saveButton:saveButton,
            buttons:[
                editButton,
                saveButton,
                {
                    xtype:"button",
                    text:"取消",
                    iconCls:'icon-back',
                    handler:function (button) {
                        me.destroy();
                    }
                }
            ]
        });

        me.callParent(arguments);
    },

    viewVersion:function () {
        this.editButton.show();
        this.saveButton.hide();
        this.modelBench.disable();
        return this;
    },

    editVersion:function () {
        this.editButton.hide();
        this.saveButton.show();
        this.modelBench.enable();
        return this;
    }
});