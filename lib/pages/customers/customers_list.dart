//import 'package:flutter/material.dart';
//import 'package:caving_app/models/authentication_model.dart';
//import 'package:caving_app/services/navigation_service.dart';
//import '../../locator.dart';
//import '../../shared/global_config.dart';
//import 'package:provider/provider.dart';
//import '../../models/customers_model.dart';
//import '../../constants/route_paths.dart' as routes;
//
//class CustomersListPage extends StatefulWidget {
//
//  CustomersListPage();
//
//  @override
//  State<StatefulWidget> createState() {
//    // TODO: implement createState
//    return _CustomersListPageState();
//  }
//}
//
//class _CustomersListPageState extends State<CustomersListPage> {
//
//  String _customerControllerLastValue;
//  bool _loadingMore = false;
//  final NavigationService _navigationService = locator<NavigationService>();
//  final TextEditingController _searchController = TextEditingController();
//
//
//  @override
//  initState() {
//
//    super.initState();
//    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//      context.read<CustomersModel>().getCustomers();
//      _setUpSearchController();
//    });
//  }
//
//  @override
//  void dispose() {
//    _searchController.dispose();
//    super.dispose();
//  }
//
//  _setUpSearchController(){
//
//    context.read<CustomersModel>().setSearchControllerValue(_searchController.text);
//
//
//    _searchController.addListener((){
//
//      if(_searchController.text == '' && _customerControllerLastValue != null && _customerControllerLastValue != ''){
//
//        context.read<CustomersModel>().setShouldUpdateCustomers(false);
//        context.read<CustomersModel>().getCustomers();
//
//      } else if(_searchController.text == '' && _customerControllerLastValue != null && _customerControllerLastValue.length == 1){
//
//        context.read<CustomersModel>().setShouldUpdateCustomers(false);
//        context.read<CustomersModel>().getCustomers();
//
//      }
//
//      else if(_searchController.text != context.read<CustomersModel>().searchControllerValue && _customerControllerLastValue != null && _customerControllerLastValue != '' && _searchController.text.length > 2){
//        context.read<CustomersModel>().setShouldUpdateCustomers(true);
//        context.read<CustomersModel>().searchCustomers();
//      }
//
//
//      _customerControllerLastValue = _searchController.text;
//
//
//    });
//
//
//
//  }
//
//  Future<bool> outstandingJobAlert() async{
//
//    bool clearJob = false;
//
//    await showDialog(
//        context: context,
//        builder: (BuildContext context) {
//          return AlertDialog(
//            shape: RoundedRectangleBorder(
//                borderRadius: BorderRadius.all(Radius.circular(32.0))),
//            title: Text(
//              'Notice',
//              style: TextStyle(fontWeight: FontWeight.bold),
//            ),
//            content: Text('You already have an outstanding job for this customer, do you want to continue creating a new job?'),
//            actions: <Widget>[
//              FlatButton(
//                onPressed: () {
//                  clearJob = true;
//                  Navigator.of(context).pop();
//                },
//                child: Text(
//                  'No',
//                  style: TextStyle(color: darkBlue),
//                ),
//              ),
//              GestureDetector(
//                  behavior: HitTestBehavior.opaque,
//                  child: FlatButton(
//                    onPressed: () {
//                      Navigator.of(context).pop();
//                    },
//                    child: Text(
//                      'Yes',
//                      style: TextStyle(color: darkBlue),
//                    ),
//                  ),
//                  onTap: () {
//                    FocusScope.of(context).requestFocus(new FocusNode());
//                  }),
//            ],
//          );
//        });
//
//    return clearJob;
//  }
//
//  Widget _buildEditButton(int index, BuildContext context, Customer customer) {
//
//    String edit = 'View/Edit';
//    String newJob = 'Raise Job';
//    String viewJobs = 'View Jobs';
//    String delete = 'Delete';
//
//
//    final List<String> _userOptions = [edit, newJob, viewJobs, delete];
//
//    return PopupMenuButton(
//        onSelected: (String value) async {
//          FocusScope.of(context).requestFocus(new FocusNode());
//          if (value == 'Delete') {
//
//            showDialog(
//                context: context,
//                builder: (BuildContext context) {
//                  return AlertDialog(shape: RoundedRectangleBorder(
//                      borderRadius: BorderRadius.all(Radius.circular(32.0))),
//                    title: Text('Notice'),
//                    content: Text('Are you sure you wish to delete this Customer?'),
//                    actions: <Widget>[
//                      FlatButton(
//                        onPressed: () => Navigator.of(context).pop(),
//                        child: Text('cancel', style: TextStyle(color: darkBlue),),
//                      ),
//                      FlatButton(
//                        onPressed: () async {
//                          context.read<CustomersModel>().selectCustomer(context.read<CustomersModel>().allCustomers[index].documentId);
//                          Navigator.of(context).pop();
//                          await context.read<CustomersModel>().deleteCustomer();
//                        },
//                        child: Text('ok', style: TextStyle(color: darkBlue),),
//                      )
//                    ],
//                  );
//                });
//
//
//          } else if (value == 'View/Edit') {
//            context.read<CustomersModel>().selectCustomer(context.read<CustomersModel>().allCustomers[index].documentId);
//            _navigationService.navigateTo(routes.CustomersEditPageRoute).then((_) => context.read<CustomersModel>().selectCustomer(null));
//
//          } else if (value == 'Raise Job'){
////            bool clearJob = false;
////            DatabaseHelper databaseHelper = DatabaseHelper();
////            context.read<CustomersModel>().selectCustomer(context.read<CustomersModel>().allCustomers[index].documentId);
////
////
////            List<Map<String, dynamic>> customer = await databaseHelper.getSingleCustomer(context.read<CustomersModel>().selectedCustomer.documentId);
////
////            if(customer.length > 0){
////
////              if(customer[0][Strings.customerJobOutstanding] == 1){
////
////                clearJob = await outstandingJobAlert();
////              }
////
////            } else {
////
////              if(context.read<CustomersModel>().selectedCustomer.customerJobOutstanding) clearJob = await outstandingJobAlert();
////
////            }
////
////            if(clearJob){
////
////              context.read<CustomersModel>().selectCustomer(null);
////
////
////            } else {
////              widget.jobModel.jobClient.text = model.selectedCustomer.fullName;
////              widget.jobModel.jobAddress.text = model.selectedCustomer.address;
////              widget.jobModel.jobPostCode.text = model.selectedCustomer.postcode;
////              widget.jobModel.jobContactNo.text = model.selectedCustomer.telephone;
////              widget.jobModel.jobMobile.text = model.selectedCustomer.mobile;
////              widget.jobModel.jobEmail.text = model.selectedCustomer.email;
////              widget.jobModel.customerDocumentId = model.selectedCustomer.customerDocumentId;
////
////
////              Navigator.of(context)
////                  .push(MaterialPageRoute(builder: (BuildContext context) {
////                return Job(widget.usersModel, widget.jobModel, true, model.selectedCustomer);
////              })).then((_) async{
////                widget.jobModel.fromCalendar = false;
////                model.selectCustomer(null);
////                widget.jobModel.jobClient.text = '';
////                widget.jobModel.jobAddress.text = '';
////                widget.jobModel.jobPostCode.text = '';
////                widget.jobModel.jobContactNo.text = '';
////                widget.jobModel.jobMobile.text = '';
////                widget.jobModel.jobEmail.text = '';
////                widget.jobModel.customerDocumentId = null;
////                widget.jobModel.resetTemporaryJob();
////
////              });
////            }
//
//          } else if (value == 'View Jobs'){
//
////            model.selectCustomer(model.allCustomers[index].customerDocumentId);
////            setState(() {
////              widget.jobModel.searchFromDateTime = null;
////              widget.jobModel.searchFromDate.text = '';
////              widget.jobModel.searchToDateTime = null;
////              widget.jobModel.searchToDate.text = '';
////              widget.jobModel.customerSearchDocumentId = model.selectedCustomer.customerDocumentId;
////              widget.jobModel.jobSearchClient.text = model.selectedCustomer.fullName;
////            });
//
//            //_selectJob(context);
//          }
//        },
//        icon: Icon(Icons.more_horiz, color: darkBlue,),
//        itemBuilder: (BuildContext context) {
//          return _userOptions.map((String option){
//            return PopupMenuItem<String>(value: option, child: Row(children: <Widget>[
//              Expanded(child: Text(option)),
//              Icon(_buildOptionIcon(option), color: darkBlue,)
//            ],));
//          }).toList();
//        });
//  }
//
////  _selectJob(BuildContext context) async {
////    showDialog(
////        barrierDismissible: false,
////        context: context,
////        builder: (BuildContext context) {
////          return JobDialog(
////              widget.jobModel,
////              widget.usersModel
////          );
////        }).then((_) {
////
////      widget.usersModel.selectCustomer(null);
////      widget.jobModel.customerSearchDocumentId = null;
////      widget.jobModel.jobSearchClient.text = '';
////
////
////    });
////  }
//
//  IconData _buildOptionIcon(String option){
//
//    IconData returnedIcon;
//
//    if(option == 'View/Edit') returnedIcon = Icons.person;
//    if(option == 'Raise Job') returnedIcon = Icons.edit;
//    if(option == 'View Jobs') returnedIcon = Icons.list;
//    if(option == 'Delete') returnedIcon = Icons.delete;
//
//    return returnedIcon;
//
//
//  }
//
//
//  Widget _buildPageContent() {
//
//    if (context.read<CustomersModel>().isLoading) {
//      return Expanded(
//          child: LayoutBuilder(
//            builder: (context, constraints) => Container(
//              padding: const EdgeInsets.all(20.0),
//              constraints: BoxConstraints(
//                minHeight: constraints.maxHeight * 0.9,),
//              child: Column(
//                  mainAxisAlignment: MainAxisAlignment.center,
//                  children: <Widget>[
//                    CircularProgressIndicator(
//                      valueColor: new AlwaysStoppedAnimation<Color>(darkBlue),
//                    ),
//                    SizedBox(height: 10.0),
//                    Text('Fetching Customers')
//                  ]),
//            ),
//          ));
//    } else if (context.read<CustomersModel>().allCustomers.length == 0) {
//      return Expanded(child: RefreshIndicator(
//          color: darkBlue,
//          child: LayoutBuilder(
//            builder: (context, constraints) => ListView(padding: EdgeInsets.all(10.0), physics: AlwaysScrollableScrollPhysics(), shrinkWrap: false, children: <Widget>[
//              Container(
//            padding: const EdgeInsets.all(20.0),
//              constraints: BoxConstraints(
//                  minHeight: constraints.maxHeight * 0.9,),
//                    child: Center(
//                      child: Column(
//                        mainAxisAlignment: MainAxisAlignment.center,
//                        children: <Widget>[
//                          Text(
//                            'No Customers available pull down to refesh',
//                            textAlign: TextAlign.center,
//                          ),
//                          SizedBox(height: 10.0),
//                          Icon(
//                            Icons.warning,
//                            size: 40.0,
//                            color: darkBlue,
//                          )
//                        ],
//                      ),
//                    )),
//            ]),
//          ),
//          onRefresh: () => context.read<CustomersModel>().getCustomers().then((_){
//            if(mounted){
//              _searchController.clear();
//              context.read<CustomersModel>().setSearchControllerValue('');
//            }
//          })),);
//    } else {
//      return Expanded(child: RefreshIndicator(
//        color: darkBlue,
//        child: Consumer<CustomersModel>(
//            builder: (BuildContext context, CustomersModel model, _) {
//              return ListView.builder(shrinkWrap: true,
//                itemBuilder: (BuildContext context, int index) {
//                  return _buildListTile(index);
//                },
//                itemCount: model.allCustomers.length >= 20 ? model.allCustomers.length + 1 : model.allCustomers.length,
//              );}),
//        onRefresh: () => context.read<CustomersModel>().getCustomers(),
//      ));
//    }
//  }
//
//  Widget _buildListTile(int index) {
//    Widget returnedWidget;
//
//    if (context.read<CustomersModel>().allCustomers.length >= 20 && index == context.read<CustomersModel>().allCustomers.length) {
//      if (_loadingMore) {
//        returnedWidget = Center(child: Image.asset('assets/spinner.gif'),);
//      } else {
//        returnedWidget = Container(
//          child: Center(child: Container(width: MediaQuery.of(context).size.width * 0.5, child: RaisedButton(color: greyDesign1,
//            child: Text("Load More", style: TextStyle(color: darkBlue),),
//            onPressed: () async {
//              setState(() {
//                _loadingMore = true;
//
//              });
//              await context.read<CustomersModel>().getMoreCustomers();
//              setState(() {
//                _loadingMore = false;
//              });
//            },
//          ),),),
//        );
//      }
//    } else {
//      returnedWidget = Column(
//        children: <Widget>[
//          ListTile(
//            leading: Icon(Icons.person),
//            title: Row(children: <Widget>[
//              context.read<CustomersModel>().allCustomers[index].prefix != 'N/A'  && context.read<CustomersModel>().allCustomers[index].prefix != '' && context.read<CustomersModel>().allCustomers[index].prefix != null ? Text('(' + context.read<CustomersModel>().allCustomers[index].prefix + ')' + ' ', style: TextStyle(color: Colors.grey),) : Container(),
//              Text(context.read<CustomersModel>().allCustomers[index].fullName)
//            ],),
//            subtitle: Text(context.read<CustomersModel>().allCustomers[index].address),
//            trailing: _buildEditButton(index, context, context.read<CustomersModel>().allCustomers[index]),
//          ),
//          Divider(),
//        ],
//      );
//    }
//    return returnedWidget;
//
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    // TODO: implement build
//    return Consumer<CustomersModel>(
//      builder: (BuildContext context, CustomersModel customersModel, _) {
//
//        //return model.isLoading ? Center(child: Image.asset('assets/spinner.gif'),) : _buildListView(model);
//        return Column(children: <Widget>[
//          SizedBox(height: 5),
//          Container(margin: EdgeInsets.all(5), decoration: BoxDecoration(border: Border.all(color: darkBlue), borderRadius: BorderRadius.circular(50)),padding: EdgeInsets.only(left: 5, right: 5), child: Row(children: <Widget>[
//            SizedBox(width: 5),
//            Icon(Icons.search, color: darkBlue,),
//            SizedBox(width: 5,),
//            Expanded(child: TextFormField(decoration: InputDecoration(
//                focusedBorder: InputBorder.none,
//                border: InputBorder.none,
//                hintText: 'Search Customers',
//                hintStyle: TextStyle(color: darkBlue.withOpacity(0.6)),
//            ),
//              controller: _searchController,)),
//            IconButton(icon: Icon(Icons.cancel, size: 15, color: darkBlue), onPressed: () => setState(() {
//              _searchController.clear();
//            })),
//          ],),),
//          _buildPageContent()
//        ],
//        );
//      },
//    );
//  }
//
//
////  @override
////  void afterFirstLayout(BuildContext context) {
////
////    setState(() {
////      widget.usersModel.searchController.clear();
////      widget.usersModel.searchControllerValue = '';
////    });
////  }
//}
//
////
////class JobDialog extends StatefulWidget {
////  final JobModel jobModel;
////  final UsersModel usersModel;
////
////  JobDialog(
////      this.jobModel,
////      this.usersModel);
////  @override
////  _JobDialogState createState() => new _JobDialogState();
////}
////
////class _JobDialogState extends State<JobDialog> {
////
////  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
////  final dateFormat = DateFormat("dd/MM/yyyy");
////  final FocusNode _clientFocusNode = new FocusNode();
////  Color _clientLabelColor = Colors.grey;
////  bool _showEngineerDrop = true;
////
////
////
////  @override
////  void initState() {
////    // TODO: implement initState
////    _setupFocusNodes();
////    if(user.role != 'Engineer'){
////      _populateEngineerDrop();
////    } else {
////      setState(() {
////        _showEngineerDrop = false;
////      });
////    }
////    super.initState();
////  }
////
////  _setupFocusNodes() {
////    _clientFocusNode.addListener(() {
////      if (mounted) {
////        if (_clientFocusNode.hasFocus) {
////          setState(() {
////            _clientLabelColor = darkBlue;
////          });
////        } else {
////          setState(() {
////            _clientLabelColor = Colors.grey;
////          });
////        }
////      }
////    });
////  }
////
////  _populateEngineerDrop(){
////
////    widget.jobModel.searchEngineerValue = widget.jobModel.searchEngineerDrop[0];
////    widget.jobModel.searchEngineerDrop = [widget.jobModel.searchEngineerDrop[0]];
////
////    widget.usersModel.fetchUsers().then((Map<String, dynamic> result){
////
////      if(widget.usersModel.allUsers.length > 0){
////
////        for(User userObject in widget.usersModel.allUsers){
////
////          widget.jobModel.searchEngineerDrop.add(Engineer(uid: userObject.uid,
////              name: userObject.firstName + ' ' + userObject.lastName,
////              email: userObject.email));
////
////        }
////
////        setState(() {
////          _showEngineerDrop = true;
////        });
////
////
////      } else {
////        _showEngineerDrop = true;
////
////      }
////    });
////
////  }
////
////  Widget _buildEngDrop() {
////    return DropdownFormFieldEngineer(
////      expanded: false,
////      hint: 'Engineer',
////      value: widget.jobModel.searchEngineerValue,
////      items: widget.jobModel.searchEngineerDrop.toList(),
////      onChanged: (Engineer val) => setState(() {
////        widget.jobModel.searchEngineerValue = val;
////        FocusScope.of(context).unfocus();
////
////      }),
////      initialValue: widget.jobModel.searchEngineerDrop[0],
////    );
////  }
////
////  Widget _buildStatusDrop() {
////
////    if(user.role == 'Engineer'){
////      widget.jobModel.searchStatusDrop = <String>['All', 'Assigned', 'Completed', 'Reschedule', 'Cancelled'];
////    } else {
////      widget.jobModel.searchStatusDrop = <String>['All', 'Assigned', 'Completed', 'Reschedule', 'Cancelled', 'Unassigned'];
////
////    }
////
////    return DropdownFormField(
////      expanded: false,
////      hint: 'Job Status',
////      value: widget.jobModel.searchStatusValue,
////      items: widget.jobModel.searchStatusDrop.toList(),
////      onChanged: (String val) => setState(() {
////        widget.jobModel.searchStatusValue = val;
////        FocusScope.of(context).unfocus();
////
////      }),
////      initialValue: widget.jobModel.searchStatusDrop[0],
////    );
////  }
////
////  Widget _buildDateFromField() {
////    return Column(
////      children: <Widget>[
////        Row(
////          children: <Widget>[
////            Flexible(
////              child: IgnorePointer(
////                child: TextFormField(
////                  enabled: true,
////                  decoration: InputDecoration(labelText: 'Date From:'),
////                  initialValue: null,
////                  controller: widget.jobModel.searchFromDate,
////                  validator: (String value) {
////                    if (value.trim().length <= 0 && value.isEmpty) {
////                      return 'Please enter a Date from';
////                    }
////                  },
////                  onSaved: (String value) {
////                    setState(() {
////                      widget.jobModel.searchFromDate.text = value;
////                    });
////                  },
////                ),
////              ),
////            ),
////            widget.jobModel.searchFromDate.text == ''
////                ? Container()
////                : IconButton(
////                color: Colors.grey,
////                icon: Icon(Icons.clear),
////                onPressed: () {
////                  setState(() {
////                    widget.jobModel.searchFromDate.text = '';
////                    widget.jobModel.searchFromDateTime = null;
////
////                  });
////                }),
////            IconButton(
////                icon: Icon(Icons.access_time,
////                    color: Color.fromARGB(255, 255, 147, 94)),
////                onPressed: () {
////                  FocusScope.of(context).unfocus();
////                  EditedDatePicker.showDatePicker(
////                      context: context,
////                      initialDate: DateTime.now(),
////                      firstDate: DateTime(1970),
////                      lastDate: DateTime(2100))
////                      .then((DateTime newDate) {
////                    if (newDate != null) {
////                      newDate = startOfDay(newDate);
////                      String dateTime = dateFormat.format(newDate);
////                      setState(() {
////                        widget.jobModel.searchFromDate.text = dateTime;
////                        widget.jobModel.searchFromDateTime = newDate;
////                      });
////                    }
////                  });
////                })
////          ],
////        ),
////      ],
////    );
////  }
////
////  Widget _buildDateToField() {
////    return Column(
////      children: <Widget>[
////        Row(
////          children: <Widget>[
////            Flexible(
////              child: IgnorePointer(
////                child: TextFormField(
////                  enabled: true,
////                  decoration: InputDecoration(labelText: 'Date To:'),
////                  initialValue: null,
////                  controller: widget.jobModel.searchToDate,
////                  validator: (String value) {
////                    if (value.trim().length <= 0 && value.isEmpty) {
////                      return 'Please enter a Date to';
////                    }
////                  },
////                  onSaved: (String value) {
////                    setState(() {
////                      widget.jobModel.searchToDate.text = value;
////                    });
////                  },
////                ),
////              ),
////            ),
////            widget.jobModel.searchToDate.text == ''
////                ? Container()
////                : IconButton(
////                color: Colors.grey,
////                icon: Icon(Icons.clear),
////                onPressed: () {
////                  setState(() {
////                    widget.jobModel.searchToDate.text = '';
////                    widget.jobModel.searchToDateTime = null;
////
////                  });
////                }),
////            IconButton(
////                icon: Icon(Icons.access_time,
////                    color: Color.fromARGB(255, 255, 147, 94)),
////                onPressed: () {
////                  FocusScope.of(context).unfocus();
////                  EditedDatePicker.showDatePicker(
////                      context: context,
////                      initialDate: DateTime.now(),
////                      firstDate: DateTime(1970),
////                      lastDate: DateTime(2100))
////                      .then((DateTime newDate) {
////                    if (newDate != null) {
////                      newDate = startOfDay(newDate);
////                      String dateTime = dateFormat.format(newDate);
////                      setState(() {
////                        widget.jobModel.searchToDate.text = dateTime;
////                        widget.jobModel.searchToDateTime = newDate;
////                      });
////                    }
////                  });
////                })
////          ],
////        ),
////      ],
////    );
////  }
////
////  @override
////  Widget build(BuildContext context) {
////
////    return AlertDialog(
////      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
////      titlePadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
////      title: Container(
////        padding: EdgeInsets.only(top: 10, bottom: 10),
////        color: greyDesign1,
////        child: Center(
////          child: Text(
////            "Job Search",
////            style: TextStyle(color: darkBlue),
////          ),
////        ),
////      ),
////      content: Form(
////          key: _formKey,
////          child: SingleChildScrollView(
////            child: Column(
////              mainAxisSize: MainAxisSize.min,
////              children: <Widget>[
////                Container(
////                  width: 350,
////                  child: Text(
////                      'Use the options below to search for any Jobs for this customer.'),
////                ),
////                _buildDateFromField(),
////                _buildDateToField(),
////                _buildStatusDrop(),
////                _showEngineerDrop == true ?
////                _buildEngDrop() : Container(),
////                _showEngineerDrop == true ? IgnorePointer(ignoring: true, child: TextFormField(decoration: InputDecoration(labelText: 'Customer'),
////                    initialValue: widget.usersModel.selectedCustomer.prefix == null || widget.usersModel.selectedCustomer.prefix == '' || widget.usersModel.selectedCustomer.prefix == 'N/A' ? widget.jobModel.jobSearchClient.text : widget.usersModel.selectedCustomer.prefix + ' ' + widget.jobModel.jobSearchClient.text, enabled: true),)
////                    : Container(),
////
////              ],
////            ),
////          )),
////      actions: <Widget>[
////        FlatButton(
////          onPressed: () => Navigator.of(context).pop(),
////          child: Text(
////            'Cancel',
////            style: TextStyle(color: darkBlue),
////          ),
////        ),
////        FlatButton(
////          onPressed: () async {
////            if (_formKey.currentState.validate()) {
////              GlobalFunctions.showLoadingDialog(context, 'Searching');
////
////              widget.jobModel.customerSearchDocumentId = widget.usersModel.selectedCustomer.customerDocumentId;
////
////              widget.jobModel.searchJobs()
////                  .then((Map<String, dynamic> response) {
////                if (response['success']) {
////                  Navigator.pop(context);
////                  Navigator.push(context, MaterialPageRoute(builder: (context) => SearchResultsPage(widget.jobModel, widget.usersModel)));
////                } else {
////                  Navigator.pop(context);
////                  GlobalFunctions.showBottomNotificationError(response['message']);
////                }
////              });
////            }
////          },
////          child: Text(
////            'OK',
////            style: TextStyle(color: darkBlue),
////          ),
////        ),
////      ],
////    );
////  }
////}
//
