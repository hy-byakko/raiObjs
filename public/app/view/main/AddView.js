/**
 * ExtendConfig:
 *  model:String,
 *  instanceLabel:String,
 *  modelField:Array
 *  grid:Ext.grid.Panel //传入链接用于load触发
 */
Ext.define('Vmoss.view.main.AddView', {
    extend:'Ext.window.Window',

    resizable:false,
    modal:true,
    layout:'fit',

    initComponent:function () {
        var me = this,
            options,
            instance = Ext.create('Vmoss.model.major.' + me.model),
            modelBench = Ext.create('Vmoss.view.main.ModelBench', {
                bind:instance,
                modelField:me.modelField
            });

        options = {
            title:'添加' + me.instanceLabel,
            items:[
                modelBench
            ],
            buttons:[
                {
                    xtype:"button",
                    text:"确定",
                    handler:function () {
                        modelBench.modelSubmit({
                            success: function(){
                                me.destroy();
                                me.grid.store.load();
                            }
                        })
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