/**
 * CStore可创建未配置model的远程连接Store, 参数需提供url, dispatch(可选)
 * ExtendConfig:
 *  dispatch: String,
 *  url: String
 */
Ext.define('Vmoss.lib.CStore', {
    extend:'Ext.data.Store',

    constructor:function (config) {
        Vmoss.Tool.log('CStore running.');
        var me = this,
            options = {};

        if (!config.model && config.url) {
            options.queryMode = 'remote';
            options.proxy = {
                type:'ajax',
                url:config.url,
                reader:{
                    root:'root',
                    totalProperty:'totalLength'
                }
            };
            Ext.applyIf(me, options);
        }

        this.callParent(arguments);
    },

    load:function (options) {
        Vmoss.Tool.log('Store loads here.');
        options = options || Vmoss.Tool.insureArg(options, arguments) ;

        options.params = options.params || {};

        Ext.Object.mergeIf(options.params, this.buildParams());

        this.callParent(arguments);
    },

    buildParams:function () {
        return {
            dispatch:this.dispatch
        }
    }
});


