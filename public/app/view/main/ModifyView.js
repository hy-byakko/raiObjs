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
            options,
            modelBench = Ext.create('Vmoss.view.main.ModelBench', {
                bind:me.selInstance,
                modelField:me.modelField
            });

        options = {
            title:'修改' + me.instanceLabel,
            items:[
                modelBench
            ],
            buttons:[
                {
                    xtype:"button",
                    text:"确定",
                    handler:function (button) {
                        if (modelBench.getForm().isValid()) {
                            me.selInstance.save()
                        }
                    }
                },
                {
                    xtype:"button",
                    text:"取消",
                    handler:function (button) {
                        me.destroy();
                    }
                }
            ]
        }

        Ext.apply(me, options);

        me.callParent(arguments);
    }
});