/**
 * ExtendConfig
 *  scaffold:Object
 *
 *  featureList:Object
 *  searchFeature:Array
 *  addFeature:Array
 *  benchFeature:Array...
 */
Ext.define('Vmoss.view.main.Standard', {
    extend:'Vmoss.lib.CPanel',

    layout:{
        type:'vbox',
        align:'stretch'
    },
    frame:true,
    closable:true,
    buttonList:['Add', 'Modify', 'Destroy', 'View'],

    initComponent:function () {
        Vmoss.Tool.log('Standard running.');

        var me = this,
            title = me.scaffold.text,
            instance = Ext.create('Vmoss.model.major.' + me.scaffold.model),
            featureList = Vmoss.Tool.featureCollect(me, {
                scan:true
            });

        Ext.apply(me, {
            title:title,
            items:[
                Ext.create('Ext.form.FieldSet', {
                    layout:'fit',
                    title:'检索条件',
                    collapsible:true,
                    items:[
                        Ext.create('Vmoss.view.main.SearchForm', {
                            bind:instance,
                            modelField:featureList.searchFeature
                        })
                    ]
                }),
                Ext.create('Vmoss.view.main.Grid', {
                    instanceLabel:me.instanceLabel,
                    searchInstance:instance,
                    model:me.scaffold.model,
                    featureList:featureList,
                    buttonList:me.buttonList
                })
            ]
        });

        me.callParent(arguments);
    }
});