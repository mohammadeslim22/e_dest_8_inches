import 'package:agent_second/constants/colors.dart';
import 'package:agent_second/constants/config.dart';
import 'package:agent_second/constants/styles.dart';
import 'package:agent_second/localization/trans.dart';
import 'package:agent_second/models/Items.dart';
import 'package:agent_second/models/ben.dart';
import 'package:agent_second/providers/export.dart';
import 'package:agent_second/util/service_locator.dart';
import 'package:agent_second/widgets/delete_tarnsaction_dialog.dart';
import 'package:agent_second/widgets/text_form_input.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:agent_second/providers/order_provider.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen(
      {Key key,
      this.ben,
      this.isORderOrReturn,
      this.isAgentOrder,
      this.transId})
      : super(key: key);
  final Ben ben;
  final bool isORderOrReturn;
  final bool isAgentOrder;
  final int transId;
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  int indexedStackId = 0;
  Ben ben;
  bool isORderOrReturn;
  double animatedHight = 0;
  int transId;
  final TextEditingController searchController = TextEditingController();
  Map<String, String> itemsBalances = <String, String>{};
  List<int> prices = <int>[];
  Widget childForDragging(
      SingleItem item, OrderListProvider orsderListProvider) {
    return Card(
      shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Colors.green),
          borderRadius: BorderRadius.circular(8.0)),
      color: getIt<OrderListProvider>().selectedOptions.contains(item.id)
          ? Colors.grey
          : colors.white,
      child: InkWell(
        onTap: () {
          !orsderListProvider.selectedOptions.contains(item.id)
              ? setState(() {
                  getIt<OrderListProvider>().addItemToList(
                      item.id,
                      item.name,
                      item.notes,
                      item.queantity,
                      item.unit,
                      item.agentPrice,
                      item.image);
                  orsderListProvider.selectedOptions.add(item.id);
                })
              // ignore: unnecessary_statements
              : () {};
        },
        child: Column(
          children: <Widget>[
            if (ben != null)
              if (ben.itemsBalances[item.id.toString()] != "0" &&
                  ben.itemsBalances[item.id.toString()] != "" &&
                  ben.itemsBalances[item.id.toString()] != null)
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(width: 1.0, color: Colors.green)),
                      child: Text(ben.itemsBalances[item.id.toString()],
                          style: styles.smallButton),
                    )
                  ],
                ),
            const SizedBox(height: 2),
            FutureBuilder<FileInfo>(
              future: DefaultCacheManager()
                  .getFileFromCache("${config.imageUrl}${item.image}"),
              builder:
                  (BuildContext context, AsyncSnapshot<FileInfo> snapshot) {
                if (snapshot.hasData) {
                  return Container(
                      height: 30,
                      width: 40,
                      child: Image.file(snapshot.data.file));
                } else {
                  return const Icon(Icons.error);
                }
              },
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Text(item.name,
                  style: styles.smallItembluestyle,
                  textAlign: TextAlign.center),
            ),
            Text(item.agentPrice, style: styles.mystyle),
          ],
        ),
      ),
    );
  }

  String totalAfterDiscount = "0.0";
  @override
  void initState() {
    super.initState();
    discountController.text = "0.0";
    isORderOrReturn = widget.isORderOrReturn;
    ben = widget.ben;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (getIt<OrderListProvider>().itemsDataLoaded) {
      } else {
        getIt<OrderListProvider>().indexedStack = 0;
        getIt<OrderListProvider>().getItems();
      }
    });
    transId = widget.transId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: !widget.isAgentOrder
            ? isORderOrReturn ? colors.blue : colors.red
            : colors.blue,
        title: Text(trans(context, "altariq"), style: styles.appBar),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh, size: 16),
            onPressed: () async {
              if (await getIt<OrderListProvider>().checkItemsUpdate()) {
                getIt<OrderListProvider>().getItems();
              }
            },
          ),
          Row(
            children: <Widget>[
              IconButton(
                  icon: const Icon(Icons.delete, size: 16),
                  onPressed: () {
                    cacelTransaction(false);
                  }),
              Container(
                margin: const EdgeInsets.only(top: 2, right: 6, left: 6),
                width: 200,
                child: TextFormInput(
                  text: trans(context, 'type'),
                  cController: searchController,
                  prefixIcon: Icons.search,
                  kt: TextInputType.emailAddress,
                  obscureText: false,
                  readOnly: false,
                  onTab: () {},
                  onFieldChanged: (String st) {
                    setState(() {});
                  },
                  onFieldSubmitted: () {},
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<OrderListProvider>(
        builder: (BuildContext context, OrderListProvider value, Widget child) {
          return Stack(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Consumer<OrderListProvider>(
                      builder: (BuildContext context,
                          OrderListProvider orderProvider, Widget child) {
                        return Container(
                          alignment: Alignment.topCenter,
                          width: MediaQuery.of(context).size.width / 2,
                          child: IndexedStack(
                              index: orderProvider.indexedStack,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      width: 400,
                                      height: 200,
                                      child: FlareActor(
                                          "assets/images/analysis_new.flr",
                                          alignment: Alignment.center,
                                          fit: BoxFit.cover,
                                          isPaused:
                                              orderProvider.itemsDataLoaded,
                                          animation: "analysis"),
                                    ),
                                    const SizedBox(height: 25),
                                    Text(trans(context, "please_wait_loading"),
                                        style: styles.plzWaitLoading)
                                  ],
                                ),
                                if (orderProvider.itemsDataLoaded)
                                  GridView.count(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 12),
                                      physics: const ScrollPhysics(),
                                      shrinkWrap: true,
                                      primary: true,
                                      crossAxisSpacing: 4,
                                      mainAxisSpacing: 1,
                                      crossAxisCount: 6,
                                      childAspectRatio: .7,
                                      addRepaintBoundaries: true,
                                      children: orderProvider.itemsList
                                          .where((SingleItem element) {
                                        return element.name
                                            .trim()
                                            .toLowerCase()
                                            .contains(searchController.text
                                                .trim()
                                                .toLowerCase());
                                      }).map((SingleItem item) {
                                        return !getIt<OrderListProvider>()
                                                .selectedOptions
                                                .contains(item.id)
                                            ? dragableItem(item, orderProvider)
                                            : childForDragging(
                                                item, orderProvider);
                                      }).toList())
                                else
                                  Container()
                              ]),
                        );
                      },
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              color: Colors.grey[300]),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                  flex: 1,
                                  child: Text(trans(context, "type"),
                                      style: styles.mystyle)),
                              Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: <Widget>[
                                      const SizedBox(width: 32),
                                      Text(trans(context, "quantity"),
                                          style: styles.mystyle,
                                          textAlign: TextAlign.start),
                                    ],
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Text(trans(context, "unit"),
                                      style: styles.mystyle)),
                              Expanded(
                                  flex: 1,
                                  child: Text(trans(context, "u_price"),
                                      style: styles.mystyle)),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  trans(context, "t_price"),
                                  style: styles.mystyle,
                                  textAlign: TextAlign.end,
                                ),
                              )
                            ],
                          ),
                        ),
                        if (indexedStackId == 1) dragHere() else Container(),
                        Expanded(
                          child: value.selectedOptions.isNotEmpty
                              ? GridView.count(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  physics: const ScrollPhysics(),
                                  shrinkWrap: true,
                                  primary: true,
                                  crossAxisSpacing: 3,
                                  mainAxisSpacing: 3,
                                  crossAxisCount: 1,
                                  childAspectRatio: 6,
                                  addRepaintBoundaries: true,
                                  children: value.ordersList.reversed
                                      .map((SingleItemForSend item) {
                                    return Slidable(
                                        actionPane:
                                            const SlidableDrawerActionPane(),
                                        actionExtentRatio: 0.25,
                                        secondaryActions: <Widget>[
                                          IconSlideAction(
                                            caption: 'Delete',
                                            color: Colors.red,
                                            icon: Icons.delete,
                                            onTap: () {
                                              setState(() {
                                                value.removeItemFromList(
                                                    item.id);
                                              });
                                            },
                                          ),
                                        ],
                                        child: cartItem(item));
                                  }).toList())
                              : Container(),
                        ),
                        bottomTotal()
                      ],
                    ),
                  ),
                ],
              ),
              if (value.loadingStar) Center(child: loadingStarWidget()),
            ],
          );
        },
      ),
    );
  }

  Widget dragableItem(SingleItem item, OrderListProvider orderProvider) {
    return Draggable<SingleItem>(
        childWhenDragging: childForDragging(item, orderProvider),
        onDragStarted: () {
          setState(() {
            indexedStackId = 1;
            animatedHight = 160;
          });
        },
        onDragEnd: (DraggableDetails t) {
          setState(() {
            indexedStackId = 0;
            animatedHight = 0;
          });
        },
        data: item,
        feedback: Column(
          children: <Widget>[
            Material(
                color: Colors.transparent,
                textStyle: styles.smallItembluestyle,
                child: Text(item.name)),
          ],
        ),
        child: childForDragging(item, orderProvider));
  }

  Widget cartItem(SingleItemForSend item) {
    return Card(
      shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Colors.green),
          borderRadius: BorderRadius.circular(8.0)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(item.name, style: styles.typeNameinOrderScreen),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Container(
                        height: 25,
                        width: 25,
                        clipBehavior: Clip.hardEdge,
                        decoration: const BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(120))),
                        child: FutureBuilder<FileInfo>(
                          future: DefaultCacheManager().getFileFromCache(
                              "${config.imageUrl}${item.image}"),
                          builder: (BuildContext context,
                              AsyncSnapshot<FileInfo> snapshot) {
                            if (snapshot.hasData) {
                              return Container(
                                  height: 40,
                                  width: 60,
                                  child: Image.file(snapshot.data.file));
                            } else {
                              return const Icon(Icons.error);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.blue[700],
                        radius: 12,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.add),
                          color: colors.white,
                          onPressed: () {
                            !widget.isAgentOrder
                                ? getIt<OrderListProvider>()
                                    .incrementQuantity(item.id)
                                : getIt<OrderListProvider>()
                                    .incrementQuantityForAgentOrder(item.id);
                          },
                        ),
                      ),
                      InkWell(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(item.queantity.toString(),
                              style: styles.mystyle),
                        ),
                        onTap: () {
                          showQuantityDialog(item.id);
                        },
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.blue[700],
                        radius: 12,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.remove),
                          color: colors.white,
                          onPressed: () {
                            getIt<OrderListProvider>()
                                .decrementQuantity(item.id);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Row(
                      children: <Widget>[
                        Text(item.unit,
                            style: styles.mystyle, textAlign: TextAlign.start),
                      ],
                    )),
                Expanded(
                    child: InkWell(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(item.unitPrice,
                        style: styles.mystyle, textAlign: TextAlign.center),
                  ),
                  onTap: () {
                    showPriceDialog(item.id);
                  },
                )),
                Expanded(
                  child: Text(
                    "${double.parse(item.unitPrice) * item.queantity}",
                    style: styles.mystyle,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomTotal() {
    return Consumer<OrderListProvider>(
        builder: (BuildContext context, OrderListProvider value, Widget child) {
      return Column(
        children: <Widget>[
          Card(
            color: Colors.grey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(trans(context, 'discount') + " ",
                          style: styles.mywhitestyle),
                      Text(value.discount.toString(),
                          style: styles.mywhitestyle),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(trans(context, 'total') + " ",
                          style: styles.mywhitestyle),
                      Text(
                          (value.sumTotal * (1 + config.tax / 100))
                              .toStringAsFixed(2),
                          style: styles.mywhitestyle),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(trans(context, 'cash_rquired') + " ",
                          style: styles.mywhitestyle),
                      Text(value.totalAfterDiscount.toStringAsFixed(2),
                          style: styles.mywhitestyle),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  //  width: 110,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    color: colors.purple,
                    onPressed: () {
                      showDiscountDialog(value.sumTotal);
                    },
                    child: Text(trans(context, "discount"),
                        style: styles.mywhitestyle),
                  ),
                ),
                const SizedBox(width: 8),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  color: colors.green,
                  onPressed: () {
                    showDialog<dynamic>(
                        context: context,
                        builder: (_) => FlareGiffyDialog(
                              flarePath: 'assets/images/space_demo.flr',
                              flareAnimation: 'loading',
                              title: Text(
                                trans(context, "save_transaction"),
                                textAlign: TextAlign.center,
                                style: styles.underHeadblack,
                              ),
                              flareFit: BoxFit.cover,
                              entryAnimation: EntryAnimation.TOP,
                              onOkButtonPressed: () async {
                                Navigator.pop(context);
                                value.changeLoadingStare(true);

                                if (await sendTransFunction(
                                    widget.isAgentOrder, "draft")) {
                                } else {
                                  showOverQuantitySnakBar(context);
                                }
                                value.changeLoadingStare(false);
                                Navigator.pop(context);
                              },
                            ));
                  },
                  child:
                      Text(trans(context, "draft"), style: styles.mywhitestyle),
                ),
                const SizedBox(width: 8),
                Container(
                  //width: 110,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    color: colors.blue,
                    onPressed: () async {
                      showDialog<dynamic>(
                        context: context,
                        builder: (BuildContext contex) => AlertDialog(
                          titlePadding: EdgeInsets.zero,
                          contentPadding: EdgeInsets.zero,
                          actionsPadding: EdgeInsets.zero,
                          buttonPadding: EdgeInsets.zero,
                          insetPadding: EdgeInsets.zero,
                          title: Image.asset("assets/images/movingcloud.gif",
                              height: 260.0, width: 400.0, fit: BoxFit.cover),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const SizedBox(height: 8),
                              Text(trans(context, 'confirm_or_pay'),
                                  style: styles.typeOrderScreen,
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  FlatButton(
                                    color: colors.pink,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      value.changeLoadingStare(true);
                                      if (isORderOrReturn) {
                                        if (value
                                            .checkItemsBalancesBrforeLeaving()) {
                                          if (await sendTransFunction(
                                              widget.isAgentOrder,
                                              "confirmed")) {
                                            print("order sent");
                                            Navigator.pop(context);
                                          } else {
                                            showErrorSnakBar(context);
                                          }
                                        } else {
                                          showOverQuantitySnakBar(context);
                                        }
                                      } else {
                                        if (await sendTransFunction(
                                            widget.isAgentOrder, "confirmed")) {
                                          print("order sent");
                                          Navigator.pop(context);
                                        } else {
                                          showErrorSnakBar(context);
                                        }
                                      }

                                      value.changeLoadingStare(false);
                                    },
                                    child: Text(trans(context, 'other_confirm'),
                                        style: styles.screenOrderDialoge),
                                  ),
                                  if (!widget.isAgentOrder)
                                    FlatButton(
                                      color: Colors.grey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        value.changeLoadingStare(true);
                                        if (value
                                            .checkItemsBalancesBrforeLeaving()) {
                                          if (await sendTransFunction(
                                              widget.isAgentOrder,
                                              "confirmed")) {
                                            Navigator.popAndPushNamed(
                                                context, "/Payment_Screen",
                                                arguments: <String, dynamic>{
                                                  "orderTotal": ben.totalOrders,
                                                  "returnTotal":
                                                      ben.totalReturns,
                                                  "cashTotal":
                                                      double.parse(ben.balance),
                                                });
                                          } else {
                                            showErrorSnakBar(context);
                                          }
                                        } else {
                                          showOverQuantitySnakBar(context);
                                        }
                                        value.changeLoadingStare(false);
                                      },
                                      child: Text(trans(context, 'confirm&pay'),
                                          style: styles.screenOrderDialoge),
                                    )
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    child: Text(
                        widget.isAgentOrder
                            ? trans(context, "agent_transaction")
                            : isORderOrReturn
                                ? trans(context, "order_short")
                                : trans(context, "make_return"),
                        style: styles.mywhitestyle),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  // width: 110,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    color: colors.red,
                    onPressed: () {
                      cacelTransaction(true);
                    },
                    child: Text(trans(context, "cancel"),
                        style: styles.mywhitestyle),
                  ),
                ),
              ],
            ),
          )
        ],
      );
    });
  }

  Widget loadingStarWidget() {
    return RotatedBox(
      quarterTurns: 1,
      child: Container(
        width: 100,
        height: 1000,
        child: LiquidLinearProgressIndicator(
          value: getIt<OrderListProvider>().progress, // Defaults to 0.5.
          valueColor: AlwaysStoppedAnimation<Color>(
              colors.blue), // Defaults to the current Theme's accentColor.
          backgroundColor:
              colors.white, // Defaults to the current Theme's backgroundColor.
          borderColor: colors.pink,
          borderWidth: 5.0,
          borderRadius: 12.0,
          direction: Axis
              .vertical, // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.horizontal.
          center: const RotatedBox(quarterTurns: 3, child: Text("Loading...")),
        ),
      ),
    );
  }

  Future<bool> sendTransFunction(bool agentOrBen, String status) async {
    if (agentOrBen) {
      bool res;
      res = await getIt<OrderListProvider>().sendAgentOrder(
          getIt<OrderListProvider>().sumTotal, 0, "preorder", status);

      return res;
    } else {
      return await getIt<OrderListProvider>().sendOrder(
          ben.id,
          getIt<OrderListProvider>().sumTotal,
          getIt<OrderListProvider>().discount,
          0,
          isORderOrReturn ? "order" : "return",
          status,
          transId);
    }
  }

  void showOverQuantitySnakBar(BuildContext c) {
    final SnackBar snackBar = SnackBar(
      content: Text(trans(c, "some_items_quantities are more than_u_have"),
          style: styles.angrywhitestyle),
      duration: const Duration(milliseconds: 1700),
      action: SnackBarAction(
          label: trans(c, 'ok'),
          onPressed: () {
            Scaffold.of(c).hideCurrentSnackBar();
          }),
      backgroundColor: const Color(0xFF3B3B3B),
    );
    Scaffold.of(c).showSnackBar(snackBar);
  }

  void showErrorSnakBar(BuildContext c) {
    final SnackBar snackBar = SnackBar(
      content: Text(trans(c, "error_happened"), style: styles.angrywhitestyle),
      duration: const Duration(milliseconds: 1700),
      action: SnackBarAction(
          label: trans(c, 'ok'),
          onPressed: () {
            Scaffold.of(c).hideCurrentSnackBar();
          }),
      backgroundColor: const Color(0xFF3B3B3B),
    );
    Scaffold.of(c).showSnackBar(snackBar);
  }

  void cacelTransaction(bool downCacel) {
    showGeneralDialog<dynamic>(
        barrierLabel: "Label",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.73),
        transitionDuration: const Duration(milliseconds: 350),
        context: context,
        pageBuilder: (BuildContext context, Animation<double> anim1,
            Animation<double> anim2) {
          return TransactionDeleteDialog(downCacel: downCacel, c: context);
        });
  }

  Widget dragHere() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.grey[300],
      child: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 36),
              Center(
                child: Text(
                  trans(context, 'drage_here'),
                  style: styles.dargHereStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          AnimatedContainer(
            height: animatedHight,
            duration: const Duration(milliseconds: 900),
            child: DottedBorder(
              color: colors.black,
              borderType: BorderType.RRect,
              strokeWidth: 2,
              child: DragTarget<SingleItem>(
                onWillAccept: (SingleItem data) {
                  return true;
                },
                onAccept: (SingleItem value) {
                  setState(() {
                    getIt<OrderListProvider>().addItemToList(
                        value.id,
                        value.name,
                        value.notes,
                        value.queantity,
                        value.unit,
                        value.agentPrice,
                        value.image);
                    getIt<OrderListProvider>().selectedOptions.add(value.id);
                    indexedStackId = 0;
                    animatedHight = 0;
                  });
                },
                onLeave: (dynamic value) {},
                builder: (BuildContext context, List<SingleItem> candidateData,
                    List<dynamic> rejectedData) {
                  return Container(
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.width / 2,
                      color: Colors.transparent);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextEditingController quantityController = TextEditingController();

  Future<dynamic> showQuantityDialog(int itemId) async {
    await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                autofocus: true,
                controller: quantityController,
                keyboardType: TextInputType.number,
              ),
            )
          ],
        ),
        actions: <Widget>[
          FlatButton(
              child: Text(trans(context, "cancel")),
              onPressed: () {
                Navigator.pop(context);
              }),
          FlatButton(
              child: Text(trans(context, "set")),
              onPressed: () {
                !widget.isAgentOrder
                    ? getIt<OrderListProvider>()
                        .setQuantity(itemId, int.parse(quantityController.text))
                    : getIt<OrderListProvider>().setQuantityForAgentOrder(
                        itemId, int.parse(quantityController.text));
                quantityController.clear();
                Navigator.pop(context);
              })
        ],
      ),
    );
  }

  TextEditingController discountController = TextEditingController();

  Future<dynamic> showDiscountDialog(double total) async {
    await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                autofocus: true,
                controller: discountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                //TextInputType.number,
              ),
            )
          ],
        ),
        actions: <Widget>[
          FlatButton(
              child: Text(trans(context, "cancel")),
              onPressed: () {
                Navigator.pop(context);
              }),
          FlatButton(
              child: Text(trans(context, "set")),
              onPressed: () {
                getIt<OrderListProvider>()
                    .setDiscount(double.parse(discountController.text));
                Navigator.pop(context);
              })
        ],
      ),
    );
  }

  TextEditingController newPriceController = TextEditingController();
  Future<dynamic> showPriceDialog(int itemId) async {
    await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                autofocus: true,
                controller: newPriceController,
                keyboardType: TextInputType.number,
              ),
            )
          ],
        ),
        actions: <Widget>[
          FlatButton(
              child: Text(trans(context, "cancel")),
              onPressed: () {
                Navigator.pop(context);
              }),
          FlatButton(
              child: Text(trans(context, "set")),
              onPressed: () {
                getIt<OrderListProvider>()
                    .changePrice(itemId, double.parse(newPriceController.text));
                setState(() {
                  newPriceController.text = "";
                });
                Navigator.pop(context);
              })
        ],
      ),
    );
  }
}
