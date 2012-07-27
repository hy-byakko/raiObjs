/**
 * 此Store为一个search instance所绑定, 当实例发生变化时, Store即会远程请求数据
 * ExtendConfig:
 *  searchInstance:Model(require),
 *
 */
Ext.define('Vmoss.view.main.BindStore', {
    extend:'Vmoss.lib.CStore',

    constructor:function (config) {
        config = config ||{};

        var me = this,
            searchInstance = config.searchInstance;

        if(searchInstance){
            searchInstance.on('afterset', function(){
                me.load();
            });
        }

        this.callParent(arguments);
    },

    buildParams:function () {
        return Ext.merge({
            dispatch:'search'
        },
            this.searchInstance.modifyValue(),
// searchInstance应仅存在一个form与之绑定
            this.searchInstance.bindForms[0].extendValues()
        )
    }
});
