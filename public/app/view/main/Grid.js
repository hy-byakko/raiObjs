/**
 * ExtendConfig:
 *  searchInstance:Model
 *  instanceLabel:String
 *  model:String
 *  featureList:Array
 *  buttonList:Array
 */
Ext.define('Vmoss.view.main.Grid', {
    extend:'Ext.grid.Panel',

//    stripeRows:true,
//    clicksToEdit:1,
//    loadMask:true,

    setLoading:true,
    autoScroll:true,
    border:false,
    pageSize:20,

    initComponent:function () {
        var me = this,
            options,
            store = Ext.create('Vmoss.view.main.BindStore', {
//                autoLoad:true,
                dispatch:'search',
                pageSize:me.pageSize,
                model:'Vmoss.model.major.' + me.model,
                searchInstance:me.searchInstance
            });

// store强制读取, 触发时机先于autoLoad
        store.load();

        options = {
            selModel: Ext.create('Ext.selection.CheckboxModel'),
            columns:me.columnsBuilder(),
            store:store,
            dockedItems:[
                {
                    xtype:'toolbar',
                    dock:'top',
                    items:me.tbarBuilder(me.buttonList)
                },
                {
                    xtype:'pagingtoolbar',
                    dock:'bottom',
                    store:store,
                    displayInfo:true,
                    displayMsg:'显示{2}条记录中的第{0}条到{1}条',
                    items:[
                        '-',
                        me.sizeComboBuilder({
                            store: store
                        }),
                        '-'
                    ],
                    emptyMsg:"没有符合条件的记录"
                }
            ]
        }

        Ext.apply(me, options);

        me.callParent(arguments);
    },

// Grid构造column对象数组
    columnsBuilder:function () {
        var me = this,
            configs = {},
            fieldList;

        configs = [Ext.create('Ext.grid.RowNumberer')];

        fieldList = (me.featureList.gridFeature || me.searchInstance.getFeatureList('grid') || me.searchInstance.fields.keys);
        Ext.Array.each(fieldList, function (field) {
                configs.push(me.getColumn({
                    instance:me.searchInstance,
                    field:field,
                    feature:'gird'
                }));
            }
        );

        return configs;
    },

    getColumn:function (options) {
        options = options || {};
        var instance = options.instance,
            field = options.field,
            feature = options.feature,
            fieldKey = (Ext.typeOf(field) == 'string') ? field : (field.name || field.field),
            config = instance.getFeatureExtend(fieldKey, feature),
            item = {};

        if (Ext.typeOf(field) !== 'string') {
            config = Ext.Object.mergeIf(field, config);
        }
        if (config) {
            for (var attr in config) {
                switch (attr) {
                    case 'field':
                        item.dataIndex = config[attr];
                        break
                    case 'label':
                        item.header = config[attr];
                        break
                    default:
                        item[attr] = config[attr];
                }
            }
        }
        else {
            item = {
                dataIndex:fieldKey,
                header:fieldKey
            };
        }

        return item;
    },

// Grid构造tbar对象数组
    tbarBuilder:function (buttonList) {
        var me = this,
            tbar = [];
        for (var i = 0, length = buttonList.length; i < length; i++) {
            tbar.push(Ext.create('Vmoss.view.main.button.Grid' + buttonList[i], {
                instanceLabel:me.instanceLabel,
                scope:me
            }));
            tbar.push('-');
        }
        tbar.pop();
        return tbar;

//            {
//                text:"导出",
//                tooltip:"导出符合检索条件的",
////                hidden:ExportHiddenFlag,
////                iconCls:"icon-export",
//                handler:function () {
//                    Ext.Msg.confirm("提示!", "您确定要导出吗?&nbsp;&nbsp;&nbsp;&nbsp;", function (btn) {
//                        if (btn == "yes") {
//                        }
//                    })
//                }
//            },
//            "-",
//            {
//                text:"打印",
//                tooltip:"打印",
////                hidden:PrintHiddenFlag,
//                iconCls:"icon-print",
//                handler:function () {
//                    var selected = grid.getSelectionModel().getSelections();
//                    //判断是否可以选择多条数据打印
//                    //判断多条数据打印按钮是否定义
//                    var _OnePrintFlag = true;
//                    if (typeof(OnePrintFlag) != 'undefined') {
//                        _OnePrintFlag = OnePrintFlag;
//                    }
//                    var printkind = '';
//                    if (selected.length == 0 && printkind != 'printall') {
//                        Ext.MessageBox.show({
//                            title:'错误信息',
//                            msg:'请选择' + objName + '!',
//                            buttons:Ext.MessageBox.OK,
//                            icon:Ext.MessageBox.ERROR
//                        });
//                    } else if (selected.length > 1 && _OnePrintFlag && printkind != 'printall') {
//                        Ext.MessageBox.show({
//                            title:'错误信息',
//                            msg:'请选择一个' + objName + '进行打印!',
//                            buttons:Ext.MessageBox.OK,
//                            icon:Ext.MessageBox.ERROR
//                        });
//                    } else if (selected.length > 1 && !_OnePrintFlag && printkind != 'printall') {
//                        grid.suspendEvents();
//                        var ids = ""
//                        for (var i = 0; i < selected.length; i++) {
//                            if (i == 0) {
//                                ids = selected[i].data.id;
//                            } else {
//                                ids = ids + "," + selected[i].data.id;
//                            }
//                        }
//                        Ext.Msg.confirm("提示!", "您确定要打印吗?&nbsp;&nbsp;&nbsp;&nbsp;", function (btn) {
//                            if (btn == "yes") {
//                                var mk = new Ext.LoadMask(Ext.getBody(), {
//                                    msg:'报表输出中,请稍候...', removeMask:true
//                                });
//                                mk.show();
//                                var conn = new Ext.data.Connection();
//                                conn.request({
//                                    url:'/bumons' + '/' + 'do_print.ext_json',
//                                    method:'GET',
//                                    params:{ids:ids},
//                                    success:function (res) {
//                                        mk.hide();
//                                        var obj = Ext.decode(res.responseText);
//                                        if (obj.success && obj.store_empty) {
//                                            Ext.MessageBox.show({
//                                                title:'提示信息',
//                                                msg:'没有相关的数据！',
//                                                buttons:Ext.MessageBox.OK,
//                                                icon:Ext.MessageBox.WARNING
//                                            });
//                                        } else if (obj.success) {
//                                            window.location.href = obj.filepath;
//                                        }
//                                    }, failture:function () {
//                                        mk.hide();
//                                    }
//                                })
//                            }
//                        });
//                    } else if (printkind == 'printall') {
//                        Ext.Msg.confirm("提示!", "您确定要打印吗?&nbsp;&nbsp;&nbsp;&nbsp;", function (btn) {
//                            if (btn == "yes") {
//                                var mk = new Ext.LoadMask(Ext.getBody(), {msg:'报表输出中,请稍候...', removeMask:true});
//                                mk.show();
//                                setPrintCondtion();//取得打印的页面输入条件
//                                var paramsobject = {}//不能传数组，所以定义传递的参数对象
//                                for (var k = 0; k < fields.length; k++) {
//                                    paramsobject['' + fields[k] + ''] = querys[k]
//                                }
//                                var pagekind = '';
//                                paramsobject['pagekind'] = pagekind;
//                                var conn = new Ext.data.Connection();
//                                conn.request({
//                                    url:'/bumons' + '/' + 'do_print.ext_json',
//                                    method:'GET',
//                                    params:paramsobject,
//                                    //{ params
//                                    // , authenticity_token: 'Vl5ZGmlwgu+IPK6qhsfLccqrfiBF/I2zrdj3T+4buMM='
//                                    //},
//                                    success:function (res) {
//                                        mk.hide();
//                                        var obj = Ext.decode(res.responseText);
//                                        if (obj.success && obj.store_empty) {
//                                            Ext.MessageBox.show({title:'提示信息', msg:'没有相关的数据！', buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.WARNING});
//                                        } else if (obj.success) {
//                                            window.location.href = obj.filepath;
//                                        }
//                                    },
//                                    failture:function () {
//                                        mk.hide();
//                                    }
//                                })//conn.request结束
//                            }
//                        });//Ext.Msg.confirm结束
//                    }
//                    else {
//                        grid.suspendEvents();
//                        var id = selected[0].data.id;
//                        Ext.Msg.confirm("提示!", "您确定要打印吗?&nbsp;&nbsp;&nbsp;&nbsp;", function (btn) {
//                            if (btn == "yes") {
//                                var mk = new Ext.LoadMask(Ext.getBody(), {
//                                    msg:'报表输出中,请稍候...', removeMask:true
//                                });
//                                mk.show();
//                                var conn = new Ext.data.Connection();
//                                conn.request({
//                                    url:'/bumons' + '/' + 'do_print.ext_json',
//                                    method:'GET',
//                                    params:{id:id},
//                                    success:function (res) {
//                                        mk.hide();
//                                        var obj = Ext.decode(res.responseText);
//                                        if (obj.success && obj.store_empty) {
//                                            Ext.MessageBox.show({
//                                                title:'提示信息',
//                                                msg:'没有相关的数据！',
//                                                buttons:Ext.MessageBox.OK,
//                                                icon:Ext.MessageBox.WARNING
//                                            });
//                                        } else if (obj.success) {
//                                            window.location.href = obj.filepath;
//                                        }
//                                    }, failture:function () {
//                                        mk.hide();
//                                    }
//                                })
//                            }
//                        });
//                    }
//                }
//            },
//            {
//                text:"反映",
//                tooltip:"反映到点位表",
//                hidden:_ReflectHiddenFlag,
//                iconCls:"icon-reflect",
//                handler:function () {
//                    var selected = grid.getSelectionModel().getSelections();
//                    if (selected.length == 0) {
//                        Ext.MessageBox.show({ title:'错误信息', msg:'请选择' + objName + '!', buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
//                    } else if (selected.length > 1) {
//                        Ext.MessageBox.show({ title:'错误信息', msg:'只能选择一个' + objName + '进行反映!', buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
//                    } else if (selected[0].data['vmsettingfile[synchronized]'] == 2) {
//                        Ext.MessageBox.show({ title:'错误信息', msg:'请选择一个未反映过的文件进行反映!', buttons:Ext.MessageBox.OK, icon:Ext.MessageBox.ERROR});
//                    } else {
//                        grid.suspendEvents();
//                        window.location.href = '/bumons/new' + '/' + selected[0].data.id;
//                    }
//                }
//            }//end 反映
//            ,
//            '',
//            '->'
    },

    sizeComboBuilder:function (options) {
        options = options || {};
        var store = options.store;

        return Ext.create('Ext.form.field.ComboBox', {
            store:Ext.create('Ext.data.Store', {
                fields:['abbr', 'name'],
                data:[
                    {"abbr":'10', "name":'10'},
                    {"abbr":'20', "name":'20'},
                    {"abbr":'40', "name":'40'},
                    {"abbr":'100', "name":'100'}
                ]
            }),
            valueField:'abbr',
            displayField:'name',
            queryMode:'local',
            editable:false,
            width:80,
            value:this.pageSize,
            listeners: {
                select: function(combo, records, eOpts){
                    store.pageSize = records.pop().get('abbr');
                    store.load();
                }
            }
        });
    }
});