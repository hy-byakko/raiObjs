/**
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

        if(!options) {
            options = {};
            arguments[0] = options;
            arguments.length = 1;
        }

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


